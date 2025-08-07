
user/_pgtbltest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ugetpid_test>:
#include "kernel/stat.h"
#include "user/user.h"

void
ugetpid_test()
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  int i;

  printf("ugetpid_test starting\n");
   c:	00001517          	auipc	a0,0x1
  10:	9a450513          	addi	a0,a0,-1628 # 9b0 <malloc+0xea>
  14:	7f8000ef          	jal	ra,80c <printf>
  18:	04000913          	li	s2,64
  
  for(i = 0; i < 64; i++){
    int ret = ugetpid();
  1c:	476000ef          	jal	ra,492 <ugetpid>
  20:	84aa                	mv	s1,a0
    if(ret != getpid()){
  22:	450000ef          	jal	ra,472 <getpid>
  26:	02951163          	bne	a0,s1,48 <ugetpid_test+0x48>
  for(i = 0; i < 64; i++){
  2a:	397d                	addiw	s2,s2,-1
  2c:	fe0918e3          	bnez	s2,1c <ugetpid_test+0x1c>
      printf("ugetpid_test: ugetpid() returned %d, getpid() returned %d\n", ret, getpid());
      exit(1);
    }
  }

  printf("ugetpid_test: OK\n");
  30:	00001517          	auipc	a0,0x1
  34:	9d850513          	addi	a0,a0,-1576 # a08 <malloc+0x142>
  38:	7d4000ef          	jal	ra,80c <printf>
}
  3c:	60e2                	ld	ra,24(sp)
  3e:	6442                	ld	s0,16(sp)
  40:	64a2                	ld	s1,8(sp)
  42:	6902                	ld	s2,0(sp)
  44:	6105                	addi	sp,sp,32
  46:	8082                	ret
      printf("ugetpid_test: ugetpid() returned %d, getpid() returned %d\n", ret, getpid());
  48:	42a000ef          	jal	ra,472 <getpid>
  4c:	862a                	mv	a2,a0
  4e:	85a6                	mv	a1,s1
  50:	00001517          	auipc	a0,0x1
  54:	97850513          	addi	a0,a0,-1672 # 9c8 <malloc+0x102>
  58:	7b4000ef          	jal	ra,80c <printf>
      exit(1);
  5c:	4505                	li	a0,1
  5e:	394000ef          	jal	ra,3f2 <exit>

0000000000000062 <pgaccess_test>:

void
pgaccess_test()
{
  62:	7179                	addi	sp,sp,-48
  64:	f406                	sd	ra,40(sp)
  66:	f022                	sd	s0,32(sp)
  68:	ec26                	sd	s1,24(sp)
  6a:	1800                	addi	s0,sp,48
  char *buf;
  unsigned int mask;
  
  printf("pgaccess_test starting\n");
  6c:	00001517          	auipc	a0,0x1
  70:	9b450513          	addi	a0,a0,-1612 # a20 <malloc+0x15a>
  74:	798000ef          	jal	ra,80c <printf>
  
  buf = malloc(32 * 4096);
  78:	00020537          	lui	a0,0x20
  7c:	04b000ef          	jal	ra,8c6 <malloc>
  80:	84aa                	mv	s1,a0

  // 先调用一次pgaccess来清除所有PTE_A位
  if(pgaccess(buf, 32, &mask) < 0){
  82:	fdc40613          	addi	a2,s0,-36
  86:	02000593          	li	a1,32
  8a:	410000ef          	jal	ra,49a <pgaccess>
  8e:	06054963          	bltz	a0,100 <pgaccess_test+0x9e>
    printf("pgaccess failed\n");
    exit(1);
  }
  
  // 现在再次调用pgaccess，应该没有页面被标记为访问过
  if(pgaccess(buf, 32, &mask) < 0){
  92:	fdc40613          	addi	a2,s0,-36
  96:	02000593          	li	a1,32
  9a:	8526                	mv	a0,s1
  9c:	3fe000ef          	jal	ra,49a <pgaccess>
  a0:	06054963          	bltz	a0,112 <pgaccess_test+0xb0>
    printf("pgaccess failed\n");
    exit(1);
  }
  
  // should be no pages accessed
  if(mask != 0){
  a4:	fdc42583          	lw	a1,-36(s0)
  a8:	edb5                	bnez	a1,124 <pgaccess_test+0xc2>
    printf("pgaccess_test: mask should be 0, got %x\n", mask);
    exit(1);
  }
  
  // access some pages
  buf[4096 * 1] = 1;
  aa:	6785                	lui	a5,0x1
  ac:	97a6                	add	a5,a5,s1
  ae:	4705                	li	a4,1
  b0:	00e78023          	sb	a4,0(a5) # 1000 <freep>
  buf[4096 * 2] = 1;
  b4:	6789                	lui	a5,0x2
  b6:	97a6                	add	a5,a5,s1
  b8:	00e78023          	sb	a4,0(a5) # 2000 <base+0xff0>
  buf[4096 * 30] = 1;
  bc:	67f9                	lui	a5,0x1e
  be:	97a6                	add	a5,a5,s1
  c0:	00e78023          	sb	a4,0(a5) # 1e000 <base+0x1cff0>
  
  if(pgaccess(buf, 32, &mask) < 0){
  c4:	fdc40613          	addi	a2,s0,-36
  c8:	02000593          	li	a1,32
  cc:	8526                	mv	a0,s1
  ce:	3cc000ef          	jal	ra,49a <pgaccess>
  d2:	06054263          	bltz	a0,136 <pgaccess_test+0xd4>
    printf("pgaccess failed\n");
    exit(1);
  }
  
  if(mask != ((1 << 1) | (1 << 2) | (1 << 30))){
  d6:	fdc42603          	lw	a2,-36(s0)
  da:	400007b7          	lui	a5,0x40000
  de:	0799                	addi	a5,a5,6
  e0:	06f61463          	bne	a2,a5,148 <pgaccess_test+0xe6>
    printf("pgaccess_test: mask should be %x, got %x\n", ((1 << 1) | (1 << 2) | (1 << 30)), mask);
    exit(1);
  }
  
  free(buf);
  e4:	8526                	mv	a0,s1
  e6:	758000ef          	jal	ra,83e <free>
  printf("pgaccess_test: OK\n");
  ea:	00001517          	auipc	a0,0x1
  ee:	9c650513          	addi	a0,a0,-1594 # ab0 <malloc+0x1ea>
  f2:	71a000ef          	jal	ra,80c <printf>
}
  f6:	70a2                	ld	ra,40(sp)
  f8:	7402                	ld	s0,32(sp)
  fa:	64e2                	ld	s1,24(sp)
  fc:	6145                	addi	sp,sp,48
  fe:	8082                	ret
    printf("pgaccess failed\n");
 100:	00001517          	auipc	a0,0x1
 104:	93850513          	addi	a0,a0,-1736 # a38 <malloc+0x172>
 108:	704000ef          	jal	ra,80c <printf>
    exit(1);
 10c:	4505                	li	a0,1
 10e:	2e4000ef          	jal	ra,3f2 <exit>
    printf("pgaccess failed\n");
 112:	00001517          	auipc	a0,0x1
 116:	92650513          	addi	a0,a0,-1754 # a38 <malloc+0x172>
 11a:	6f2000ef          	jal	ra,80c <printf>
    exit(1);
 11e:	4505                	li	a0,1
 120:	2d2000ef          	jal	ra,3f2 <exit>
    printf("pgaccess_test: mask should be 0, got %x\n", mask);
 124:	00001517          	auipc	a0,0x1
 128:	92c50513          	addi	a0,a0,-1748 # a50 <malloc+0x18a>
 12c:	6e0000ef          	jal	ra,80c <printf>
    exit(1);
 130:	4505                	li	a0,1
 132:	2c0000ef          	jal	ra,3f2 <exit>
    printf("pgaccess failed\n");
 136:	00001517          	auipc	a0,0x1
 13a:	90250513          	addi	a0,a0,-1790 # a38 <malloc+0x172>
 13e:	6ce000ef          	jal	ra,80c <printf>
    exit(1);
 142:	4505                	li	a0,1
 144:	2ae000ef          	jal	ra,3f2 <exit>
    printf("pgaccess_test: mask should be %x, got %x\n", ((1 << 1) | (1 << 2) | (1 << 30)), mask);
 148:	85be                	mv	a1,a5
 14a:	00001517          	auipc	a0,0x1
 14e:	93650513          	addi	a0,a0,-1738 # a80 <malloc+0x1ba>
 152:	6ba000ef          	jal	ra,80c <printf>
    exit(1);
 156:	4505                	li	a0,1
 158:	29a000ef          	jal	ra,3f2 <exit>

000000000000015c <main>:

int
main(int argc, char *argv[])
{
 15c:	1141                	addi	sp,sp,-16
 15e:	e406                	sd	ra,8(sp)
 160:	e022                	sd	s0,0(sp)
 162:	0800                	addi	s0,sp,16
  ugetpid_test();
 164:	e9dff0ef          	jal	ra,0 <ugetpid_test>
  pgaccess_test();
 168:	efbff0ef          	jal	ra,62 <pgaccess_test>
  printf("pgtbltest: all tests succeeded\n");
 16c:	00001517          	auipc	a0,0x1
 170:	95c50513          	addi	a0,a0,-1700 # ac8 <malloc+0x202>
 174:	698000ef          	jal	ra,80c <printf>
  exit(0);
 178:	4501                	li	a0,0
 17a:	278000ef          	jal	ra,3f2 <exit>

000000000000017e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 17e:	1141                	addi	sp,sp,-16
 180:	e406                	sd	ra,8(sp)
 182:	e022                	sd	s0,0(sp)
 184:	0800                	addi	s0,sp,16
  extern int main();
  main();
 186:	fd7ff0ef          	jal	ra,15c <main>
  exit(0);
 18a:	4501                	li	a0,0
 18c:	266000ef          	jal	ra,3f2 <exit>

0000000000000190 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 196:	87aa                	mv	a5,a0
 198:	0585                	addi	a1,a1,1
 19a:	0785                	addi	a5,a5,1
 19c:	fff5c703          	lbu	a4,-1(a1)
 1a0:	fee78fa3          	sb	a4,-1(a5) # 3fffffff <base+0x3fffefef>
 1a4:	fb75                	bnez	a4,198 <strcpy+0x8>
    ;
  return os;
}
 1a6:	6422                	ld	s0,8(sp)
 1a8:	0141                	addi	sp,sp,16
 1aa:	8082                	ret

00000000000001ac <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1ac:	1141                	addi	sp,sp,-16
 1ae:	e422                	sd	s0,8(sp)
 1b0:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1b2:	00054783          	lbu	a5,0(a0)
 1b6:	cb91                	beqz	a5,1ca <strcmp+0x1e>
 1b8:	0005c703          	lbu	a4,0(a1)
 1bc:	00f71763          	bne	a4,a5,1ca <strcmp+0x1e>
    p++, q++;
 1c0:	0505                	addi	a0,a0,1
 1c2:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1c4:	00054783          	lbu	a5,0(a0)
 1c8:	fbe5                	bnez	a5,1b8 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1ca:	0005c503          	lbu	a0,0(a1)
}
 1ce:	40a7853b          	subw	a0,a5,a0
 1d2:	6422                	ld	s0,8(sp)
 1d4:	0141                	addi	sp,sp,16
 1d6:	8082                	ret

00000000000001d8 <strlen>:

uint
strlen(const char *s)
{
 1d8:	1141                	addi	sp,sp,-16
 1da:	e422                	sd	s0,8(sp)
 1dc:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1de:	00054783          	lbu	a5,0(a0)
 1e2:	cf91                	beqz	a5,1fe <strlen+0x26>
 1e4:	0505                	addi	a0,a0,1
 1e6:	87aa                	mv	a5,a0
 1e8:	4685                	li	a3,1
 1ea:	9e89                	subw	a3,a3,a0
 1ec:	00f6853b          	addw	a0,a3,a5
 1f0:	0785                	addi	a5,a5,1
 1f2:	fff7c703          	lbu	a4,-1(a5)
 1f6:	fb7d                	bnez	a4,1ec <strlen+0x14>
    ;
  return n;
}
 1f8:	6422                	ld	s0,8(sp)
 1fa:	0141                	addi	sp,sp,16
 1fc:	8082                	ret
  for(n = 0; s[n]; n++)
 1fe:	4501                	li	a0,0
 200:	bfe5                	j	1f8 <strlen+0x20>

0000000000000202 <memset>:

void*
memset(void *dst, int c, uint n)
{
 202:	1141                	addi	sp,sp,-16
 204:	e422                	sd	s0,8(sp)
 206:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 208:	ce09                	beqz	a2,222 <memset+0x20>
 20a:	87aa                	mv	a5,a0
 20c:	fff6071b          	addiw	a4,a2,-1
 210:	1702                	slli	a4,a4,0x20
 212:	9301                	srli	a4,a4,0x20
 214:	0705                	addi	a4,a4,1
 216:	972a                	add	a4,a4,a0
    cdst[i] = c;
 218:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 21c:	0785                	addi	a5,a5,1
 21e:	fee79de3          	bne	a5,a4,218 <memset+0x16>
  }
  return dst;
}
 222:	6422                	ld	s0,8(sp)
 224:	0141                	addi	sp,sp,16
 226:	8082                	ret

0000000000000228 <strchr>:

char*
strchr(const char *s, char c)
{
 228:	1141                	addi	sp,sp,-16
 22a:	e422                	sd	s0,8(sp)
 22c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 22e:	00054783          	lbu	a5,0(a0)
 232:	cb99                	beqz	a5,248 <strchr+0x20>
    if(*s == c)
 234:	00f58763          	beq	a1,a5,242 <strchr+0x1a>
  for(; *s; s++)
 238:	0505                	addi	a0,a0,1
 23a:	00054783          	lbu	a5,0(a0)
 23e:	fbfd                	bnez	a5,234 <strchr+0xc>
      return (char*)s;
  return 0;
 240:	4501                	li	a0,0
}
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret
  return 0;
 248:	4501                	li	a0,0
 24a:	bfe5                	j	242 <strchr+0x1a>

000000000000024c <gets>:

char*
gets(char *buf, int max)
{
 24c:	711d                	addi	sp,sp,-96
 24e:	ec86                	sd	ra,88(sp)
 250:	e8a2                	sd	s0,80(sp)
 252:	e4a6                	sd	s1,72(sp)
 254:	e0ca                	sd	s2,64(sp)
 256:	fc4e                	sd	s3,56(sp)
 258:	f852                	sd	s4,48(sp)
 25a:	f456                	sd	s5,40(sp)
 25c:	f05a                	sd	s6,32(sp)
 25e:	ec5e                	sd	s7,24(sp)
 260:	1080                	addi	s0,sp,96
 262:	8baa                	mv	s7,a0
 264:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 266:	892a                	mv	s2,a0
 268:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 26a:	4aa9                	li	s5,10
 26c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 26e:	89a6                	mv	s3,s1
 270:	2485                	addiw	s1,s1,1
 272:	0344d663          	bge	s1,s4,29e <gets+0x52>
    cc = read(0, &c, 1);
 276:	4605                	li	a2,1
 278:	faf40593          	addi	a1,s0,-81
 27c:	4501                	li	a0,0
 27e:	18c000ef          	jal	ra,40a <read>
    if(cc < 1)
 282:	00a05e63          	blez	a0,29e <gets+0x52>
    buf[i++] = c;
 286:	faf44783          	lbu	a5,-81(s0)
 28a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 28e:	01578763          	beq	a5,s5,29c <gets+0x50>
 292:	0905                	addi	s2,s2,1
 294:	fd679de3          	bne	a5,s6,26e <gets+0x22>
  for(i=0; i+1 < max; ){
 298:	89a6                	mv	s3,s1
 29a:	a011                	j	29e <gets+0x52>
 29c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 29e:	99de                	add	s3,s3,s7
 2a0:	00098023          	sb	zero,0(s3)
  return buf;
}
 2a4:	855e                	mv	a0,s7
 2a6:	60e6                	ld	ra,88(sp)
 2a8:	6446                	ld	s0,80(sp)
 2aa:	64a6                	ld	s1,72(sp)
 2ac:	6906                	ld	s2,64(sp)
 2ae:	79e2                	ld	s3,56(sp)
 2b0:	7a42                	ld	s4,48(sp)
 2b2:	7aa2                	ld	s5,40(sp)
 2b4:	7b02                	ld	s6,32(sp)
 2b6:	6be2                	ld	s7,24(sp)
 2b8:	6125                	addi	sp,sp,96
 2ba:	8082                	ret

00000000000002bc <stat>:

int
stat(const char *n, struct stat *st)
{
 2bc:	1101                	addi	sp,sp,-32
 2be:	ec06                	sd	ra,24(sp)
 2c0:	e822                	sd	s0,16(sp)
 2c2:	e426                	sd	s1,8(sp)
 2c4:	e04a                	sd	s2,0(sp)
 2c6:	1000                	addi	s0,sp,32
 2c8:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2ca:	4581                	li	a1,0
 2cc:	166000ef          	jal	ra,432 <open>
  if(fd < 0)
 2d0:	02054163          	bltz	a0,2f2 <stat+0x36>
 2d4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2d6:	85ca                	mv	a1,s2
 2d8:	172000ef          	jal	ra,44a <fstat>
 2dc:	892a                	mv	s2,a0
  close(fd);
 2de:	8526                	mv	a0,s1
 2e0:	13a000ef          	jal	ra,41a <close>
  return r;
}
 2e4:	854a                	mv	a0,s2
 2e6:	60e2                	ld	ra,24(sp)
 2e8:	6442                	ld	s0,16(sp)
 2ea:	64a2                	ld	s1,8(sp)
 2ec:	6902                	ld	s2,0(sp)
 2ee:	6105                	addi	sp,sp,32
 2f0:	8082                	ret
    return -1;
 2f2:	597d                	li	s2,-1
 2f4:	bfc5                	j	2e4 <stat+0x28>

00000000000002f6 <atoi>:

int
atoi(const char *s)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2fc:	00054603          	lbu	a2,0(a0)
 300:	fd06079b          	addiw	a5,a2,-48
 304:	0ff7f793          	andi	a5,a5,255
 308:	4725                	li	a4,9
 30a:	02f76963          	bltu	a4,a5,33c <atoi+0x46>
 30e:	86aa                	mv	a3,a0
  n = 0;
 310:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 312:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 314:	0685                	addi	a3,a3,1
 316:	0025179b          	slliw	a5,a0,0x2
 31a:	9fa9                	addw	a5,a5,a0
 31c:	0017979b          	slliw	a5,a5,0x1
 320:	9fb1                	addw	a5,a5,a2
 322:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 326:	0006c603          	lbu	a2,0(a3)
 32a:	fd06071b          	addiw	a4,a2,-48
 32e:	0ff77713          	andi	a4,a4,255
 332:	fee5f1e3          	bgeu	a1,a4,314 <atoi+0x1e>
  return n;
}
 336:	6422                	ld	s0,8(sp)
 338:	0141                	addi	sp,sp,16
 33a:	8082                	ret
  n = 0;
 33c:	4501                	li	a0,0
 33e:	bfe5                	j	336 <atoi+0x40>

0000000000000340 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 346:	02b57663          	bgeu	a0,a1,372 <memmove+0x32>
    while(n-- > 0)
 34a:	02c05163          	blez	a2,36c <memmove+0x2c>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	0785                	addi	a5,a5,1
 358:	97aa                	add	a5,a5,a0
  dst = vdst;
 35a:	872a                	mv	a4,a0
      *dst++ = *src++;
 35c:	0585                	addi	a1,a1,1
 35e:	0705                	addi	a4,a4,1
 360:	fff5c683          	lbu	a3,-1(a1)
 364:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 36c:	6422                	ld	s0,8(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret
    dst += n;
 372:	00c50733          	add	a4,a0,a2
    src += n;
 376:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 378:	fec05ae3          	blez	a2,36c <memmove+0x2c>
 37c:	fff6079b          	addiw	a5,a2,-1
 380:	1782                	slli	a5,a5,0x20
 382:	9381                	srli	a5,a5,0x20
 384:	fff7c793          	not	a5,a5
 388:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 38a:	15fd                	addi	a1,a1,-1
 38c:	177d                	addi	a4,a4,-1
 38e:	0005c683          	lbu	a3,0(a1)
 392:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 396:	fee79ae3          	bne	a5,a4,38a <memmove+0x4a>
 39a:	bfc9                	j	36c <memmove+0x2c>

000000000000039c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 39c:	1141                	addi	sp,sp,-16
 39e:	e422                	sd	s0,8(sp)
 3a0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3a2:	ca05                	beqz	a2,3d2 <memcmp+0x36>
 3a4:	fff6069b          	addiw	a3,a2,-1
 3a8:	1682                	slli	a3,a3,0x20
 3aa:	9281                	srli	a3,a3,0x20
 3ac:	0685                	addi	a3,a3,1
 3ae:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3b0:	00054783          	lbu	a5,0(a0)
 3b4:	0005c703          	lbu	a4,0(a1)
 3b8:	00e79863          	bne	a5,a4,3c8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3bc:	0505                	addi	a0,a0,1
    p2++;
 3be:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3c0:	fed518e3          	bne	a0,a3,3b0 <memcmp+0x14>
  }
  return 0;
 3c4:	4501                	li	a0,0
 3c6:	a019                	j	3cc <memcmp+0x30>
      return *p1 - *p2;
 3c8:	40e7853b          	subw	a0,a5,a4
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  return 0;
 3d2:	4501                	li	a0,0
 3d4:	bfe5                	j	3cc <memcmp+0x30>

00000000000003d6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e406                	sd	ra,8(sp)
 3da:	e022                	sd	s0,0(sp)
 3dc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3de:	f63ff0ef          	jal	ra,340 <memmove>
}
 3e2:	60a2                	ld	ra,8(sp)
 3e4:	6402                	ld	s0,0(sp)
 3e6:	0141                	addi	sp,sp,16
 3e8:	8082                	ret

00000000000003ea <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3ea:	4885                	li	a7,1
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3f2:	4889                	li	a7,2
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <wait>:
.global wait
wait:
 li a7, SYS_wait
 3fa:	488d                	li	a7,3
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 402:	4891                	li	a7,4
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <read>:
.global read
read:
 li a7, SYS_read
 40a:	4895                	li	a7,5
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <write>:
.global write
write:
 li a7, SYS_write
 412:	48c1                	li	a7,16
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <close>:
.global close
close:
 li a7, SYS_close
 41a:	48d5                	li	a7,21
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <kill>:
.global kill
kill:
 li a7, SYS_kill
 422:	4899                	li	a7,6
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <exec>:
.global exec
exec:
 li a7, SYS_exec
 42a:	489d                	li	a7,7
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <open>:
.global open
open:
 li a7, SYS_open
 432:	48bd                	li	a7,15
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 43a:	48c5                	li	a7,17
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 442:	48c9                	li	a7,18
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 44a:	48a1                	li	a7,8
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <link>:
.global link
link:
 li a7, SYS_link
 452:	48cd                	li	a7,19
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 45a:	48d1                	li	a7,20
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 462:	48a5                	li	a7,9
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <dup>:
.global dup
dup:
 li a7, SYS_dup
 46a:	48a9                	li	a7,10
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 472:	48ad                	li	a7,11
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 47a:	48b1                	li	a7,12
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 482:	48b5                	li	a7,13
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 48a:	48b9                	li	a7,14
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <ugetpid>:
.global ugetpid
ugetpid:
 li a7, SYS_ugetpid
 492:	48d9                	li	a7,22
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <pgaccess>:
.global pgaccess
pgaccess:
 li a7, SYS_pgaccess
 49a:	48dd                	li	a7,23
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4a2:	1101                	addi	sp,sp,-32
 4a4:	ec06                	sd	ra,24(sp)
 4a6:	e822                	sd	s0,16(sp)
 4a8:	1000                	addi	s0,sp,32
 4aa:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ae:	4605                	li	a2,1
 4b0:	fef40593          	addi	a1,s0,-17
 4b4:	f5fff0ef          	jal	ra,412 <write>
}
 4b8:	60e2                	ld	ra,24(sp)
 4ba:	6442                	ld	s0,16(sp)
 4bc:	6105                	addi	sp,sp,32
 4be:	8082                	ret

00000000000004c0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4c0:	715d                	addi	sp,sp,-80
 4c2:	e486                	sd	ra,72(sp)
 4c4:	e0a2                	sd	s0,64(sp)
 4c6:	fc26                	sd	s1,56(sp)
 4c8:	f84a                	sd	s2,48(sp)
 4ca:	f44e                	sd	s3,40(sp)
 4cc:	0880                	addi	s0,sp,80
 4ce:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4d0:	c299                	beqz	a3,4d6 <printint+0x16>
 4d2:	0805c663          	bltz	a1,55e <printint+0x9e>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4d6:	2581                	sext.w	a1,a1
  neg = 0;
 4d8:	4881                	li	a7,0
 4da:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 4de:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4e0:	2601                	sext.w	a2,a2
 4e2:	00000517          	auipc	a0,0x0
 4e6:	60e50513          	addi	a0,a0,1550 # af0 <digits>
 4ea:	883a                	mv	a6,a4
 4ec:	2705                	addiw	a4,a4,1
 4ee:	02c5f7bb          	remuw	a5,a1,a2
 4f2:	1782                	slli	a5,a5,0x20
 4f4:	9381                	srli	a5,a5,0x20
 4f6:	97aa                	add	a5,a5,a0
 4f8:	0007c783          	lbu	a5,0(a5)
 4fc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 500:	0005879b          	sext.w	a5,a1
 504:	02c5d5bb          	divuw	a1,a1,a2
 508:	0685                	addi	a3,a3,1
 50a:	fec7f0e3          	bgeu	a5,a2,4ea <printint+0x2a>
  if(neg)
 50e:	00088b63          	beqz	a7,524 <printint+0x64>
    buf[i++] = '-';
 512:	fd040793          	addi	a5,s0,-48
 516:	973e                	add	a4,a4,a5
 518:	02d00793          	li	a5,45
 51c:	fef70423          	sb	a5,-24(a4)
 520:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 524:	02e05663          	blez	a4,550 <printint+0x90>
 528:	fb840793          	addi	a5,s0,-72
 52c:	00e78933          	add	s2,a5,a4
 530:	fff78993          	addi	s3,a5,-1
 534:	99ba                	add	s3,s3,a4
 536:	377d                	addiw	a4,a4,-1
 538:	1702                	slli	a4,a4,0x20
 53a:	9301                	srli	a4,a4,0x20
 53c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 540:	fff94583          	lbu	a1,-1(s2)
 544:	8526                	mv	a0,s1
 546:	f5dff0ef          	jal	ra,4a2 <putc>
  while(--i >= 0)
 54a:	197d                	addi	s2,s2,-1
 54c:	ff391ae3          	bne	s2,s3,540 <printint+0x80>
}
 550:	60a6                	ld	ra,72(sp)
 552:	6406                	ld	s0,64(sp)
 554:	74e2                	ld	s1,56(sp)
 556:	7942                	ld	s2,48(sp)
 558:	79a2                	ld	s3,40(sp)
 55a:	6161                	addi	sp,sp,80
 55c:	8082                	ret
    x = -xx;
 55e:	40b005bb          	negw	a1,a1
    neg = 1;
 562:	4885                	li	a7,1
    x = -xx;
 564:	bf9d                	j	4da <printint+0x1a>

0000000000000566 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 566:	7119                	addi	sp,sp,-128
 568:	fc86                	sd	ra,120(sp)
 56a:	f8a2                	sd	s0,112(sp)
 56c:	f4a6                	sd	s1,104(sp)
 56e:	f0ca                	sd	s2,96(sp)
 570:	ecce                	sd	s3,88(sp)
 572:	e8d2                	sd	s4,80(sp)
 574:	e4d6                	sd	s5,72(sp)
 576:	e0da                	sd	s6,64(sp)
 578:	fc5e                	sd	s7,56(sp)
 57a:	f862                	sd	s8,48(sp)
 57c:	f466                	sd	s9,40(sp)
 57e:	f06a                	sd	s10,32(sp)
 580:	ec6e                	sd	s11,24(sp)
 582:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 584:	0005c903          	lbu	s2,0(a1)
 588:	22090e63          	beqz	s2,7c4 <vprintf+0x25e>
 58c:	8b2a                	mv	s6,a0
 58e:	8a2e                	mv	s4,a1
 590:	8bb2                	mv	s7,a2
  state = 0;
 592:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 594:	4481                	li	s1,0
 596:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 598:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 59c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5a0:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5a4:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5a8:	00000c97          	auipc	s9,0x0
 5ac:	548c8c93          	addi	s9,s9,1352 # af0 <digits>
 5b0:	a005                	j	5d0 <vprintf+0x6a>
        putc(fd, c0);
 5b2:	85ca                	mv	a1,s2
 5b4:	855a                	mv	a0,s6
 5b6:	eedff0ef          	jal	ra,4a2 <putc>
 5ba:	a019                	j	5c0 <vprintf+0x5a>
    } else if(state == '%'){
 5bc:	03598263          	beq	s3,s5,5e0 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 5c0:	2485                	addiw	s1,s1,1
 5c2:	8726                	mv	a4,s1
 5c4:	009a07b3          	add	a5,s4,s1
 5c8:	0007c903          	lbu	s2,0(a5)
 5cc:	1e090c63          	beqz	s2,7c4 <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 5d0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5d4:	fe0994e3          	bnez	s3,5bc <vprintf+0x56>
      if(c0 == '%'){
 5d8:	fd579de3          	bne	a5,s5,5b2 <vprintf+0x4c>
        state = '%';
 5dc:	89be                	mv	s3,a5
 5de:	b7cd                	j	5c0 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5e0:	cfa5                	beqz	a5,658 <vprintf+0xf2>
 5e2:	00ea06b3          	add	a3,s4,a4
 5e6:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ea:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ec:	c681                	beqz	a3,5f4 <vprintf+0x8e>
 5ee:	9752                	add	a4,a4,s4
 5f0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5f4:	03878a63          	beq	a5,s8,628 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5f8:	05a78463          	beq	a5,s10,640 <vprintf+0xda>
      } else if(c0 == 'u'){
 5fc:	0db78763          	beq	a5,s11,6ca <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 600:	07800713          	li	a4,120
 604:	10e78963          	beq	a5,a4,716 <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 608:	07000713          	li	a4,112
 60c:	12e78e63          	beq	a5,a4,748 <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 610:	07300713          	li	a4,115
 614:	16e78b63          	beq	a5,a4,78a <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 618:	05579063          	bne	a5,s5,658 <vprintf+0xf2>
        putc(fd, '%');
 61c:	85d6                	mv	a1,s5
 61e:	855a                	mv	a0,s6
 620:	e83ff0ef          	jal	ra,4a2 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 624:	4981                	li	s3,0
 626:	bf69                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 628:	008b8913          	addi	s2,s7,8
 62c:	4685                	li	a3,1
 62e:	4629                	li	a2,10
 630:	000ba583          	lw	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	e8bff0ef          	jal	ra,4c0 <printint>
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b749                	j	5c0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 640:	03868663          	beq	a3,s8,66c <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 644:	05a68163          	beq	a3,s10,686 <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 648:	09b68d63          	beq	a3,s11,6e2 <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 64c:	03a68f63          	beq	a3,s10,68a <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 650:	07800793          	li	a5,120
 654:	0cf68d63          	beq	a3,a5,72e <vprintf+0x1c8>
        putc(fd, '%');
 658:	85d6                	mv	a1,s5
 65a:	855a                	mv	a0,s6
 65c:	e47ff0ef          	jal	ra,4a2 <putc>
        putc(fd, c0);
 660:	85ca                	mv	a1,s2
 662:	855a                	mv	a0,s6
 664:	e3fff0ef          	jal	ra,4a2 <putc>
      state = 0;
 668:	4981                	li	s3,0
 66a:	bf99                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 66c:	008b8913          	addi	s2,s7,8
 670:	4685                	li	a3,1
 672:	4629                	li	a2,10
 674:	000bb583          	ld	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	e47ff0ef          	jal	ra,4c0 <printint>
        i += 1;
 67e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 680:	8bca                	mv	s7,s2
      state = 0;
 682:	4981                	li	s3,0
        i += 1;
 684:	bf35                	j	5c0 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 686:	03860563          	beq	a2,s8,6b0 <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 68a:	07b60963          	beq	a2,s11,6fc <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 68e:	07800793          	li	a5,120
 692:	fcf613e3          	bne	a2,a5,658 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 696:	008b8913          	addi	s2,s7,8
 69a:	4681                	li	a3,0
 69c:	4641                	li	a2,16
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	e1dff0ef          	jal	ra,4c0 <printint>
        i += 2;
 6a8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 2;
 6ae:	bf09                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4685                	li	a3,1
 6b6:	4629                	li	a2,10
 6b8:	000bb583          	ld	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	e03ff0ef          	jal	ra,4c0 <printint>
        i += 2;
 6c2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c4:	8bca                	mv	s7,s2
      state = 0;
 6c6:	4981                	li	s3,0
        i += 2;
 6c8:	bde5                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 6ca:	008b8913          	addi	s2,s7,8
 6ce:	4681                	li	a3,0
 6d0:	4629                	li	a2,10
 6d2:	000ba583          	lw	a1,0(s7)
 6d6:	855a                	mv	a0,s6
 6d8:	de9ff0ef          	jal	ra,4c0 <printint>
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
 6e0:	b5c5                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	dd1ff0ef          	jal	ra,4c0 <printint>
        i += 1;
 6f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
        i += 1;
 6fa:	b5d9                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4629                	li	a2,10
 704:	000bb583          	ld	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	db7ff0ef          	jal	ra,4c0 <printint>
        i += 2;
 70e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
        i += 2;
 714:	b575                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 716:	008b8913          	addi	s2,s7,8
 71a:	4681                	li	a3,0
 71c:	4641                	li	a2,16
 71e:	000ba583          	lw	a1,0(s7)
 722:	855a                	mv	a0,s6
 724:	d9dff0ef          	jal	ra,4c0 <printint>
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
 72c:	bd51                	j	5c0 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 72e:	008b8913          	addi	s2,s7,8
 732:	4681                	li	a3,0
 734:	4641                	li	a2,16
 736:	000bb583          	ld	a1,0(s7)
 73a:	855a                	mv	a0,s6
 73c:	d85ff0ef          	jal	ra,4c0 <printint>
        i += 1;
 740:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 742:	8bca                	mv	s7,s2
      state = 0;
 744:	4981                	li	s3,0
        i += 1;
 746:	bdad                	j	5c0 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 748:	008b8793          	addi	a5,s7,8
 74c:	f8f43423          	sd	a5,-120(s0)
 750:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 754:	03000593          	li	a1,48
 758:	855a                	mv	a0,s6
 75a:	d49ff0ef          	jal	ra,4a2 <putc>
  putc(fd, 'x');
 75e:	07800593          	li	a1,120
 762:	855a                	mv	a0,s6
 764:	d3fff0ef          	jal	ra,4a2 <putc>
 768:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76a:	03c9d793          	srli	a5,s3,0x3c
 76e:	97e6                	add	a5,a5,s9
 770:	0007c583          	lbu	a1,0(a5)
 774:	855a                	mv	a0,s6
 776:	d2dff0ef          	jal	ra,4a2 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 77a:	0992                	slli	s3,s3,0x4
 77c:	397d                	addiw	s2,s2,-1
 77e:	fe0916e3          	bnez	s2,76a <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 782:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 786:	4981                	li	s3,0
 788:	bd25                	j	5c0 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 78a:	008b8993          	addi	s3,s7,8
 78e:	000bb903          	ld	s2,0(s7)
 792:	00090f63          	beqz	s2,7b0 <vprintf+0x24a>
        for(; *s; s++)
 796:	00094583          	lbu	a1,0(s2)
 79a:	c195                	beqz	a1,7be <vprintf+0x258>
          putc(fd, *s);
 79c:	855a                	mv	a0,s6
 79e:	d05ff0ef          	jal	ra,4a2 <putc>
        for(; *s; s++)
 7a2:	0905                	addi	s2,s2,1
 7a4:	00094583          	lbu	a1,0(s2)
 7a8:	f9f5                	bnez	a1,79c <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 7aa:	8bce                	mv	s7,s3
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bd09                	j	5c0 <vprintf+0x5a>
          s = "(null)";
 7b0:	00000917          	auipc	s2,0x0
 7b4:	33890913          	addi	s2,s2,824 # ae8 <malloc+0x222>
        for(; *s; s++)
 7b8:	02800593          	li	a1,40
 7bc:	b7c5                	j	79c <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 7be:	8bce                	mv	s7,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	bbfd                	j	5c0 <vprintf+0x5a>
    }
  }
}
 7c4:	70e6                	ld	ra,120(sp)
 7c6:	7446                	ld	s0,112(sp)
 7c8:	74a6                	ld	s1,104(sp)
 7ca:	7906                	ld	s2,96(sp)
 7cc:	69e6                	ld	s3,88(sp)
 7ce:	6a46                	ld	s4,80(sp)
 7d0:	6aa6                	ld	s5,72(sp)
 7d2:	6b06                	ld	s6,64(sp)
 7d4:	7be2                	ld	s7,56(sp)
 7d6:	7c42                	ld	s8,48(sp)
 7d8:	7ca2                	ld	s9,40(sp)
 7da:	7d02                	ld	s10,32(sp)
 7dc:	6de2                	ld	s11,24(sp)
 7de:	6109                	addi	sp,sp,128
 7e0:	8082                	ret

00000000000007e2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e2:	715d                	addi	sp,sp,-80
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e010                	sd	a2,0(s0)
 7ec:	e414                	sd	a3,8(s0)
 7ee:	e818                	sd	a4,16(s0)
 7f0:	ec1c                	sd	a5,24(s0)
 7f2:	03043023          	sd	a6,32(s0)
 7f6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7fa:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fe:	8622                	mv	a2,s0
 800:	d67ff0ef          	jal	ra,566 <vprintf>
}
 804:	60e2                	ld	ra,24(sp)
 806:	6442                	ld	s0,16(sp)
 808:	6161                	addi	sp,sp,80
 80a:	8082                	ret

000000000000080c <printf>:

void
printf(const char *fmt, ...)
{
 80c:	711d                	addi	sp,sp,-96
 80e:	ec06                	sd	ra,24(sp)
 810:	e822                	sd	s0,16(sp)
 812:	1000                	addi	s0,sp,32
 814:	e40c                	sd	a1,8(s0)
 816:	e810                	sd	a2,16(s0)
 818:	ec14                	sd	a3,24(s0)
 81a:	f018                	sd	a4,32(s0)
 81c:	f41c                	sd	a5,40(s0)
 81e:	03043823          	sd	a6,48(s0)
 822:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 826:	00840613          	addi	a2,s0,8
 82a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82e:	85aa                	mv	a1,a0
 830:	4505                	li	a0,1
 832:	d35ff0ef          	jal	ra,566 <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83e:	1141                	addi	sp,sp,-16
 840:	e422                	sd	s0,8(sp)
 842:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 844:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	00000797          	auipc	a5,0x0
 84c:	7b87b783          	ld	a5,1976(a5) # 1000 <freep>
 850:	a805                	j	880 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 852:	4618                	lw	a4,8(a2)
 854:	9db9                	addw	a1,a1,a4
 856:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	6318                	ld	a4,0(a4)
 85e:	fee53823          	sd	a4,-16(a0)
 862:	a091                	j	8a6 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 864:	ff852703          	lw	a4,-8(a0)
 868:	9e39                	addw	a2,a2,a4
 86a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 86c:	ff053703          	ld	a4,-16(a0)
 870:	e398                	sd	a4,0(a5)
 872:	a099                	j	8b8 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	6398                	ld	a4,0(a5)
 876:	00e7e463          	bltu	a5,a4,87e <free+0x40>
 87a:	00e6ea63          	bltu	a3,a4,88e <free+0x50>
{
 87e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	fed7fae3          	bgeu	a5,a3,874 <free+0x36>
 884:	6398                	ld	a4,0(a5)
 886:	00e6e463          	bltu	a3,a4,88e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88a:	fee7eae3          	bltu	a5,a4,87e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 88e:	ff852583          	lw	a1,-8(a0)
 892:	6390                	ld	a2,0(a5)
 894:	02059713          	slli	a4,a1,0x20
 898:	9301                	srli	a4,a4,0x20
 89a:	0712                	slli	a4,a4,0x4
 89c:	9736                	add	a4,a4,a3
 89e:	fae60ae3          	beq	a2,a4,852 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8a2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a6:	4790                	lw	a2,8(a5)
 8a8:	02061713          	slli	a4,a2,0x20
 8ac:	9301                	srli	a4,a4,0x20
 8ae:	0712                	slli	a4,a4,0x4
 8b0:	973e                	add	a4,a4,a5
 8b2:	fae689e3          	beq	a3,a4,864 <free+0x26>
  } else
    p->s.ptr = bp;
 8b6:	e394                	sd	a3,0(a5)
  freep = p;
 8b8:	00000717          	auipc	a4,0x0
 8bc:	74f73423          	sd	a5,1864(a4) # 1000 <freep>
}
 8c0:	6422                	ld	s0,8(sp)
 8c2:	0141                	addi	sp,sp,16
 8c4:	8082                	ret

00000000000008c6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c6:	7139                	addi	sp,sp,-64
 8c8:	fc06                	sd	ra,56(sp)
 8ca:	f822                	sd	s0,48(sp)
 8cc:	f426                	sd	s1,40(sp)
 8ce:	f04a                	sd	s2,32(sp)
 8d0:	ec4e                	sd	s3,24(sp)
 8d2:	e852                	sd	s4,16(sp)
 8d4:	e456                	sd	s5,8(sp)
 8d6:	e05a                	sd	s6,0(sp)
 8d8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8da:	02051493          	slli	s1,a0,0x20
 8de:	9081                	srli	s1,s1,0x20
 8e0:	04bd                	addi	s1,s1,15
 8e2:	8091                	srli	s1,s1,0x4
 8e4:	0014899b          	addiw	s3,s1,1
 8e8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ea:	00000517          	auipc	a0,0x0
 8ee:	71653503          	ld	a0,1814(a0) # 1000 <freep>
 8f2:	c515                	beqz	a0,91e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f6:	4798                	lw	a4,8(a5)
 8f8:	02977f63          	bgeu	a4,s1,936 <malloc+0x70>
 8fc:	8a4e                	mv	s4,s3
 8fe:	0009871b          	sext.w	a4,s3
 902:	6685                	lui	a3,0x1
 904:	00d77363          	bgeu	a4,a3,90a <malloc+0x44>
 908:	6a05                	lui	s4,0x1
 90a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 90e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 912:	00000917          	auipc	s2,0x0
 916:	6ee90913          	addi	s2,s2,1774 # 1000 <freep>
  if(p == (char*)-1)
 91a:	5afd                	li	s5,-1
 91c:	a0bd                	j	98a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 91e:	00000797          	auipc	a5,0x0
 922:	6f278793          	addi	a5,a5,1778 # 1010 <base>
 926:	00000717          	auipc	a4,0x0
 92a:	6cf73d23          	sd	a5,1754(a4) # 1000 <freep>
 92e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 930:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 934:	b7e1                	j	8fc <malloc+0x36>
      if(p->s.size == nunits)
 936:	02e48b63          	beq	s1,a4,96c <malloc+0xa6>
        p->s.size -= nunits;
 93a:	4137073b          	subw	a4,a4,s3
 93e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 940:	1702                	slli	a4,a4,0x20
 942:	9301                	srli	a4,a4,0x20
 944:	0712                	slli	a4,a4,0x4
 946:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 948:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 94c:	00000717          	auipc	a4,0x0
 950:	6aa73a23          	sd	a0,1716(a4) # 1000 <freep>
      return (void*)(p + 1);
 954:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 958:	70e2                	ld	ra,56(sp)
 95a:	7442                	ld	s0,48(sp)
 95c:	74a2                	ld	s1,40(sp)
 95e:	7902                	ld	s2,32(sp)
 960:	69e2                	ld	s3,24(sp)
 962:	6a42                	ld	s4,16(sp)
 964:	6aa2                	ld	s5,8(sp)
 966:	6b02                	ld	s6,0(sp)
 968:	6121                	addi	sp,sp,64
 96a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 96c:	6398                	ld	a4,0(a5)
 96e:	e118                	sd	a4,0(a0)
 970:	bff1                	j	94c <malloc+0x86>
  hp->s.size = nu;
 972:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 976:	0541                	addi	a0,a0,16
 978:	ec7ff0ef          	jal	ra,83e <free>
  return freep;
 97c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 980:	dd61                	beqz	a0,958 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 984:	4798                	lw	a4,8(a5)
 986:	fa9778e3          	bgeu	a4,s1,936 <malloc+0x70>
    if(p == freep)
 98a:	00093703          	ld	a4,0(s2)
 98e:	853e                	mv	a0,a5
 990:	fef719e3          	bne	a4,a5,982 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 994:	8552                	mv	a0,s4
 996:	ae5ff0ef          	jal	ra,47a <sbrk>
  if(p == (char*)-1)
 99a:	fd551ce3          	bne	a0,s5,972 <malloc+0xac>
        return 0;
 99e:	4501                	li	a0,0
 9a0:	bf65                	j	958 <malloc+0x92>
