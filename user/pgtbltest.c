#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
ugetpid_test()
{
  int i;

  printf("ugetpid_test starting\n");
  
  for(i = 0; i < 64; i++){
    int ret = ugetpid();
    if(ret != getpid()){
      printf("ugetpid_test: ugetpid() returned %d, getpid() returned %d\n", ret, getpid());
      exit(1);
    }
  }

  printf("ugetpid_test: OK\n");
}

void
pgaccess_test()
{
  char *buf;
  unsigned int mask;
  
  printf("pgaccess_test starting\n");
  
  buf = malloc(32 * 4096);

  // 先调用一次pgaccess来清除所有PTE_A位
  if(pgaccess(buf, 32, &mask) < 0){
    printf("pgaccess failed\n");
    exit(1);
  }
  
  // 现在再次调用pgaccess，应该没有页面被标记为访问过
  if(pgaccess(buf, 32, &mask) < 0){
    printf("pgaccess failed\n");
    exit(1);
  }
  
  // should be no pages accessed
  if(mask != 0){
    printf("pgaccess_test: mask should be 0, got %x\n", mask);
    exit(1);
  }
  
  // access some pages
  buf[4096 * 1] = 1;
  buf[4096 * 2] = 1;
  buf[4096 * 30] = 1;
  
  if(pgaccess(buf, 32, &mask) < 0){
    printf("pgaccess failed\n");
    exit(1);
  }
  
  if(mask != ((1 << 1) | (1 << 2) | (1 << 30))){
    printf("pgaccess_test: mask should be %x, got %x\n", ((1 << 1) | (1 << 2) | (1 << 30)), mask);
    exit(1);
  }
  
  free(buf);
  printf("pgaccess_test: OK\n");
}

int
main(int argc, char *argv[])
{
  ugetpid_test();
  pgaccess_test();
  printf("pgtbltest: all tests succeeded\n");
  exit(0);
}

