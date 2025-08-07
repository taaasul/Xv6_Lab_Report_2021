// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);
struct run {
  struct run* next;
};

struct {
  struct spinlock lock;
  struct run* freelist;
  char lockname[8];
} kmems[NCPU];;

 
struct run*
  steal(void)
{
  struct run* r = 0;
  int c, target_cpu;

  // 获取当前CPU编号
  push_off();
  c = cpuid();
  pop_off();

  // 从下一个CPU开始循环遍历
  for (int i = 1; i < NCPU; i++) {
    target_cpu = (c + i) % NCPU;  // 循环遍历其他CPU

    acquire(&kmems[target_cpu].lock);

    // 检查目标CPU是否有空闲页面
    if (kmems[target_cpu].freelist) {
      // 使用快慢双指针找到链表的中点
      struct run* slow = kmems[target_cpu].freelist;
      struct run* fast = kmems[target_cpu].freelist;
      struct run* prev = 0;

      // 快指针走两步，慢指针走一步
      while (fast && fast->next) {
        prev = slow;
        slow = slow->next;
        fast = fast->next->next;
      }

      // 如果链表只有一个节点，偷取这个节点
      if (!prev) {
        r = kmems[target_cpu].freelist;
        kmems[target_cpu].freelist = r->next;
        r->next = 0;
      }
      else {
        // 偷取前半部分，slow指向中点
        r = kmems[target_cpu].freelist;
        kmems[target_cpu].freelist = slow;
        prev->next = 0;  // 断开链表
      }

      release(&kmems[target_cpu].lock);
      break;  // 找到空闲页面后退出循环
    }

    release(&kmems[target_cpu].lock);
  }

  // 将偷取到的页面链表的第一个节点返回，其余的加入当前CPU的freelist
  if (r && r->next) {
    acquire(&kmems[c].lock);
    struct run* temp = r->next;
    r->next = 0;

    // 将剩余页面加入当前CPU的freelist
    struct run* last = temp;
    while (last->next) {
      last = last->next;
    }
    last->next = kmems[c].freelist;
    kmems[c].freelist = temp;

    release(&kmems[c].lock);
  }

  return r;
}


extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

void
kinit()
{
  int i;
  for (i = 0; i < NCPU; ++i) {
    strncpy(kmems[i].lockname, "kmem", 8);
    initlock(&kmems[i].lock, kmems[i].lockname);
  }
  // initlock(&kmem.lock, "kmem"); // lab8-1
  freerange(end, (void*)PHYSTOP);
}
void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    kfree(p);
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  int c; // cpuid - lab8-1

  // get the current core number - lab8-1
  push_off();
  c = cpuid();
  pop_off();

  // free the page to the current cpu's freelist - lab8-1
  acquire(&kmems[c].lock);
  r->next = kmems[c].freelist;
  kmems[c].freelist = r;
  release(&kmems[c].lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void*
kalloc(void)
{
  struct run* r;
  int c;

  // 获取当前CPU编号
  push_off();
  c = cpuid();
  pop_off();

  // 从当前CPU的freelist中分配页面
  acquire(&kmems[c].lock);
  r = kmems[c].freelist;
  if (r)
    kmems[c].freelist = r->next;
  release(&kmems[c].lock);

  // 如果当前CPU的freelist为空，尝试从其他CPU偷取
  if (!r) {
    r = steal();
  }

  if (r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
