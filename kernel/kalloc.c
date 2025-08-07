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

  // ��ȡ��ǰCPU���
  push_off();
  c = cpuid();
  pop_off();

  // ����һ��CPU��ʼѭ������
  for (int i = 1; i < NCPU; i++) {
    target_cpu = (c + i) % NCPU;  // ѭ����������CPU

    acquire(&kmems[target_cpu].lock);

    // ���Ŀ��CPU�Ƿ��п���ҳ��
    if (kmems[target_cpu].freelist) {
      // ʹ�ÿ���˫ָ���ҵ�������е�
      struct run* slow = kmems[target_cpu].freelist;
      struct run* fast = kmems[target_cpu].freelist;
      struct run* prev = 0;

      // ��ָ������������ָ����һ��
      while (fast && fast->next) {
        prev = slow;
        slow = slow->next;
        fast = fast->next->next;
      }

      // �������ֻ��һ���ڵ㣬͵ȡ����ڵ�
      if (!prev) {
        r = kmems[target_cpu].freelist;
        kmems[target_cpu].freelist = r->next;
        r->next = 0;
      }
      else {
        // ͵ȡǰ�벿�֣�slowָ���е�
        r = kmems[target_cpu].freelist;
        kmems[target_cpu].freelist = slow;
        prev->next = 0;  // �Ͽ�����
      }

      release(&kmems[target_cpu].lock);
      break;  // �ҵ�����ҳ����˳�ѭ��
    }

    release(&kmems[target_cpu].lock);
  }

  // ��͵ȡ����ҳ������ĵ�һ���ڵ㷵�أ�����ļ��뵱ǰCPU��freelist
  if (r && r->next) {
    acquire(&kmems[c].lock);
    struct run* temp = r->next;
    r->next = 0;

    // ��ʣ��ҳ����뵱ǰCPU��freelist
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

  // ��ȡ��ǰCPU���
  push_off();
  c = cpuid();
  pop_off();

  // �ӵ�ǰCPU��freelist�з���ҳ��
  acquire(&kmems[c].lock);
  r = kmems[c].freelist;
  if (r)
    kmems[c].freelist = r->next;
  release(&kmems[c].lock);

  // �����ǰCPU��freelistΪ�գ����Դ�����CPU͵ȡ
  if (!r) {
    r = steal();
  }

  if (r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
