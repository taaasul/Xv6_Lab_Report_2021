// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

struct spinlock ref_lock;
int ref_count[PHYSTOP / PGSIZE];  // 每个物理页面的引用计数

#define PA2IDX(pa) (((pa) - KERNBASE) / PGSIZE)

void freerange(void* pa_start, void* pa_end);

extern char end[]; // first address after kernel.
// defined by kernel.ld.

struct run {
  struct run* next;
};

struct {
  struct spinlock lock;
  struct run* freelist;
} kmem;

void
mem_count_up(uint64 pa)
{
  acquire(&ref_lock);
  ref_count[PA2IDX(pa)]++;
  release(&ref_lock);
}

int mem_count_down(uint64 pa) {
  int should_free = 0;
  acquire(&ref_lock);
  ref_count[PA2IDX(pa)]--;
  if (ref_count[PA2IDX(pa)] == 0) {
    should_free = 1;
  }
  release(&ref_lock);
  return should_free;
}

void mem_count_set_one(uint64 pa) {
  acquire(&ref_lock);
  ref_count[PA2IDX(pa)] = 1;
  release(&ref_lock);
}

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  initlock(&ref_lock, "ref_count");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void* pa_start, void* pa_end)
{
  char* p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for (; p + PGSIZE <= (char*)pa_end; p += PGSIZE) {
    // 系统初始化时会将内存引用减1，所以这里先设为1
    mem_count_set_one((uint64)p);
    kfree(p);
  }
}

// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void* pa)
{
  struct run* r;

  if (((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  if (mem_count_down((uint64)pa)) {
    // 引用计数为0，释放物理内存
    memset(pa, 1, PGSIZE);
    r = (struct run*)pa;
    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    release(&kmem.lock);
  }
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void*
kalloc(void)
{
  struct run* r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if (r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if (r) {
    memset((char*)r, 5, PGSIZE); // fill with junk
    mem_count_set_one((uint64)r);  // 设置引用计数为1
  }

  return (void*)r;
}
