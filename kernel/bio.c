// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

extern uint ticks;

#define NBUCKET 13            // the count of hash table's buckets
#define HASH(blockno) (blockno % NBUCKET)

struct {
  struct spinlock lock;
  struct buf buf[NBUF];
  int size;                // record the count of used buf
  struct buf buckets[NBUCKET];  // 
  struct spinlock locks[NBUCKET]; // buckets' locks
  struct spinlock hashlock; // the hash table's lock

  // Linked list of all buffers, through prev/next.
  // Sorted by how recently the buffer was used.
  // head.next is most recent, head.prev is least.
  struct buf head;
} bcache;

void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");
  initlock(&bcache.hashlock, "bcache.hashlock");

  // 初始化每个bucket的锁
  for (int i = 0; i < NBUCKET; i++) {
    initlock(&bcache.locks[i], "bcache.bucket");
    bcache.buckets[i].next = 0; // 初始化bucket为空
  }

  // 初始化size为0
  bcache.size = 0;
  //// Create linked list of buffers
  //bcache.head.prev = &bcache.head;
  //bcache.head.next = &bcache.head;
  //for(b = bcache.buf; b < bcache.buf+NBUF; b++){
  //  b->next = bcache.head.next;
  //  b->prev = &bcache.head;
  //  initsleeplock(&b->lock, "buffer");
  //  bcache.head.next->prev = b;
  //  bcache.head.next = b;
  //}
  
  // 只初始化每个buf的sleeplock
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    initsleeplock(&b->lock, "buffer");
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf* b;
  int bucket_id = HASH(blockno);

  // 1. 在对应bucket中查找缓存块
  acquire(&bcache.locks[bucket_id]);
  for (b = bcache.buckets[bucket_id].next; b; b = b->next) {
    if (b->dev == dev && b->blockno == blockno) {
      b->refcnt++;
      b->timestamp = ticks;
      release(&bcache.locks[bucket_id]);
      acquiresleep(&b->lock);
      return b;
    }
  }
  // 2. 分配新的缓存块（如果还有未使用的）
  acquire(&bcache.lock);
  if (bcache.size < NBUF) {
    // 找到一个未使用的buf
    for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
      if (b->refcnt == 0 && b->dev == 0) { // 未使用的标志
        bcache.size++;
        b->dev = dev;
        b->blockno = blockno;
        b->valid = 0;
        b->refcnt = 1;
        b->timestamp = ticks;

        // 插入到对应bucket的链表头部
        b->next = bcache.buckets[bucket_id].next;
        bcache.buckets[bucket_id].next = b;

        release(&bcache.lock);
        release(&bcache.locks[bucket_id]);
        acquiresleep(&b->lock);
        return b;
      }
    }
  }
  release(&bcache.lock);
  // 3. 重用缓存块（基于时间戳的LRU）
  release(&bcache.locks[bucket_id]);
  acquire(&bcache.hashlock);

  struct buf* lru_buf = 0;
  uint min_timestamp = 0xffffffff;
  int lru_bucket = -1;
  // 遍历所有bucket寻找LRU缓存块
  for (int i = 0; i < NBUCKET; i++) {
    for (b = bcache.buckets[i].next; b; b = b->next) {
      if (b->refcnt == 0 && b->timestamp < min_timestamp) {
        min_timestamp = b->timestamp;
        lru_buf = b;
        lru_bucket = i;
      }
    }
  }
  if (lru_buf) {
    // 从原bucket中移除
    if (lru_bucket != bucket_id) {
      // 找到并移除lru_buf
      struct buf** pp;
      for (pp = &bcache.buckets[lru_bucket].next; *pp; pp = &(*pp)->next) {
        if (*pp == lru_buf) {
          *pp = lru_buf->next;
          break;
        }
      }
      // 插入到目标bucket
      lru_buf->next = bcache.buckets[bucket_id].next;
      bcache.buckets[bucket_id].next = lru_buf;
    }
    // 重新初始化缓存块
    lru_buf->dev = dev;
    lru_buf->blockno = blockno;
    lru_buf->valid = 0;
    lru_buf->refcnt = 1;
    lru_buf->timestamp = ticks;

    release(&bcache.hashlock);
    acquiresleep(&lru_buf->lock);
    return lru_buf;
  }
  release(&bcache.hashlock);
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  virtio_disk_rw(b, 1);
}

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf* b)
{
  if (!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  int bucket_id = HASH(b->blockno);
  acquire(&bcache.locks[bucket_id]);

  b->refcnt--;
  if (b->refcnt == 0) {
    // 更新时间戳而不是移动到链表头部
    b->timestamp = ticks;
  }

  release(&bcache.locks[bucket_id]);
}

void
bpin(struct buf* b) {
  int bucket_id = HASH(b->blockno);
  acquire(&bcache.locks[bucket_id]);
  b->refcnt++;
  release(&bcache.locks[bucket_id]);
}

void
bunpin(struct buf* b) {
  int bucket_id = HASH(b->blockno);
  acquire(&bcache.locks[bucket_id]);
  b->refcnt--;
  release(&bcache.locks[bucket_id]);
}

