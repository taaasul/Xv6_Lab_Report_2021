
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  if(fork() > 0)
   8:	282000ef          	jal	ra,28a <fork>
   c:	00a04563          	bgtz	a0,16 <main+0x16>
    sleep(5);  // Let child exit before parent.
  exit(0);
  10:	4501                	li	a0,0
  12:	280000ef          	jal	ra,292 <exit>
    sleep(5);  // Let child exit before parent.
  16:	4515                	li	a0,5
  18:	30a000ef          	jal	ra,322 <sleep>
  1c:	bfd5                	j	10 <main+0x10>

000000000000001e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  1e:	1141                	addi	sp,sp,-16
  20:	e406                	sd	ra,8(sp)
  22:	e022                	sd	s0,0(sp)
  24:	0800                	addi	s0,sp,16
  extern int main();
  main();
  26:	fdbff0ef          	jal	ra,0 <main>
  exit(0);
  2a:	4501                	li	a0,0
  2c:	266000ef          	jal	ra,292 <exit>

0000000000000030 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  30:	1141                	addi	sp,sp,-16
  32:	e422                	sd	s0,8(sp)
  34:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  36:	87aa                	mv	a5,a0
  38:	0585                	addi	a1,a1,1
  3a:	0785                	addi	a5,a5,1
  3c:	fff5c703          	lbu	a4,-1(a1)
  40:	fee78fa3          	sb	a4,-1(a5)
  44:	fb75                	bnez	a4,38 <strcpy+0x8>
    ;
  return os;
}
  46:	6422                	ld	s0,8(sp)
  48:	0141                	addi	sp,sp,16
  4a:	8082                	ret

000000000000004c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4c:	1141                	addi	sp,sp,-16
  4e:	e422                	sd	s0,8(sp)
  50:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  52:	00054783          	lbu	a5,0(a0)
  56:	cb91                	beqz	a5,6a <strcmp+0x1e>
  58:	0005c703          	lbu	a4,0(a1)
  5c:	00f71763          	bne	a4,a5,6a <strcmp+0x1e>
    p++, q++;
  60:	0505                	addi	a0,a0,1
  62:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	fbe5                	bnez	a5,58 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6a:	0005c503          	lbu	a0,0(a1)
}
  6e:	40a7853b          	subw	a0,a5,a0
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <strlen>:

uint
strlen(const char *s)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e422                	sd	s0,8(sp)
  7c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  7e:	00054783          	lbu	a5,0(a0)
  82:	cf91                	beqz	a5,9e <strlen+0x26>
  84:	0505                	addi	a0,a0,1
  86:	87aa                	mv	a5,a0
  88:	4685                	li	a3,1
  8a:	9e89                	subw	a3,a3,a0
  8c:	00f6853b          	addw	a0,a3,a5
  90:	0785                	addi	a5,a5,1
  92:	fff7c703          	lbu	a4,-1(a5)
  96:	fb7d                	bnez	a4,8c <strlen+0x14>
    ;
  return n;
}
  98:	6422                	ld	s0,8(sp)
  9a:	0141                	addi	sp,sp,16
  9c:	8082                	ret
  for(n = 0; s[n]; n++)
  9e:	4501                	li	a0,0
  a0:	bfe5                	j	98 <strlen+0x20>

00000000000000a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a2:	1141                	addi	sp,sp,-16
  a4:	e422                	sd	s0,8(sp)
  a6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  a8:	ce09                	beqz	a2,c2 <memset+0x20>
  aa:	87aa                	mv	a5,a0
  ac:	fff6071b          	addiw	a4,a2,-1
  b0:	1702                	slli	a4,a4,0x20
  b2:	9301                	srli	a4,a4,0x20
  b4:	0705                	addi	a4,a4,1
  b6:	972a                	add	a4,a4,a0
    cdst[i] = c;
  b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  bc:	0785                	addi	a5,a5,1
  be:	fee79de3          	bne	a5,a4,b8 <memset+0x16>
  }
  return dst;
}
  c2:	6422                	ld	s0,8(sp)
  c4:	0141                	addi	sp,sp,16
  c6:	8082                	ret

00000000000000c8 <strchr>:

char*
strchr(const char *s, char c)
{
  c8:	1141                	addi	sp,sp,-16
  ca:	e422                	sd	s0,8(sp)
  cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ce:	00054783          	lbu	a5,0(a0)
  d2:	cb99                	beqz	a5,e8 <strchr+0x20>
    if(*s == c)
  d4:	00f58763          	beq	a1,a5,e2 <strchr+0x1a>
  for(; *s; s++)
  d8:	0505                	addi	a0,a0,1
  da:	00054783          	lbu	a5,0(a0)
  de:	fbfd                	bnez	a5,d4 <strchr+0xc>
      return (char*)s;
  return 0;
  e0:	4501                	li	a0,0
}
  e2:	6422                	ld	s0,8(sp)
  e4:	0141                	addi	sp,sp,16
  e6:	8082                	ret
  return 0;
  e8:	4501                	li	a0,0
  ea:	bfe5                	j	e2 <strchr+0x1a>

00000000000000ec <gets>:

char*
gets(char *buf, int max)
{
  ec:	711d                	addi	sp,sp,-96
  ee:	ec86                	sd	ra,88(sp)
  f0:	e8a2                	sd	s0,80(sp)
  f2:	e4a6                	sd	s1,72(sp)
  f4:	e0ca                	sd	s2,64(sp)
  f6:	fc4e                	sd	s3,56(sp)
  f8:	f852                	sd	s4,48(sp)
  fa:	f456                	sd	s5,40(sp)
  fc:	f05a                	sd	s6,32(sp)
  fe:	ec5e                	sd	s7,24(sp)
 100:	1080                	addi	s0,sp,96
 102:	8baa                	mv	s7,a0
 104:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 106:	892a                	mv	s2,a0
 108:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 10a:	4aa9                	li	s5,10
 10c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10e:	89a6                	mv	s3,s1
 110:	2485                	addiw	s1,s1,1
 112:	0344d663          	bge	s1,s4,13e <gets+0x52>
    cc = read(0, &c, 1);
 116:	4605                	li	a2,1
 118:	faf40593          	addi	a1,s0,-81
 11c:	4501                	li	a0,0
 11e:	18c000ef          	jal	ra,2aa <read>
    if(cc < 1)
 122:	00a05e63          	blez	a0,13e <gets+0x52>
    buf[i++] = c;
 126:	faf44783          	lbu	a5,-81(s0)
 12a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 12e:	01578763          	beq	a5,s5,13c <gets+0x50>
 132:	0905                	addi	s2,s2,1
 134:	fd679de3          	bne	a5,s6,10e <gets+0x22>
  for(i=0; i+1 < max; ){
 138:	89a6                	mv	s3,s1
 13a:	a011                	j	13e <gets+0x52>
 13c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 13e:	99de                	add	s3,s3,s7
 140:	00098023          	sb	zero,0(s3)
  return buf;
}
 144:	855e                	mv	a0,s7
 146:	60e6                	ld	ra,88(sp)
 148:	6446                	ld	s0,80(sp)
 14a:	64a6                	ld	s1,72(sp)
 14c:	6906                	ld	s2,64(sp)
 14e:	79e2                	ld	s3,56(sp)
 150:	7a42                	ld	s4,48(sp)
 152:	7aa2                	ld	s5,40(sp)
 154:	7b02                	ld	s6,32(sp)
 156:	6be2                	ld	s7,24(sp)
 158:	6125                	addi	sp,sp,96
 15a:	8082                	ret

000000000000015c <stat>:

int
stat(const char *n, struct stat *st)
{
 15c:	1101                	addi	sp,sp,-32
 15e:	ec06                	sd	ra,24(sp)
 160:	e822                	sd	s0,16(sp)
 162:	e426                	sd	s1,8(sp)
 164:	e04a                	sd	s2,0(sp)
 166:	1000                	addi	s0,sp,32
 168:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16a:	4581                	li	a1,0
 16c:	166000ef          	jal	ra,2d2 <open>
  if(fd < 0)
 170:	02054163          	bltz	a0,192 <stat+0x36>
 174:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 176:	85ca                	mv	a1,s2
 178:	172000ef          	jal	ra,2ea <fstat>
 17c:	892a                	mv	s2,a0
  close(fd);
 17e:	8526                	mv	a0,s1
 180:	13a000ef          	jal	ra,2ba <close>
  return r;
}
 184:	854a                	mv	a0,s2
 186:	60e2                	ld	ra,24(sp)
 188:	6442                	ld	s0,16(sp)
 18a:	64a2                	ld	s1,8(sp)
 18c:	6902                	ld	s2,0(sp)
 18e:	6105                	addi	sp,sp,32
 190:	8082                	ret
    return -1;
 192:	597d                	li	s2,-1
 194:	bfc5                	j	184 <stat+0x28>

0000000000000196 <atoi>:

int
atoi(const char *s)
{
 196:	1141                	addi	sp,sp,-16
 198:	e422                	sd	s0,8(sp)
 19a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 19c:	00054603          	lbu	a2,0(a0)
 1a0:	fd06079b          	addiw	a5,a2,-48
 1a4:	0ff7f793          	andi	a5,a5,255
 1a8:	4725                	li	a4,9
 1aa:	02f76963          	bltu	a4,a5,1dc <atoi+0x46>
 1ae:	86aa                	mv	a3,a0
  n = 0;
 1b0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 1b2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 1b4:	0685                	addi	a3,a3,1
 1b6:	0025179b          	slliw	a5,a0,0x2
 1ba:	9fa9                	addw	a5,a5,a0
 1bc:	0017979b          	slliw	a5,a5,0x1
 1c0:	9fb1                	addw	a5,a5,a2
 1c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1c6:	0006c603          	lbu	a2,0(a3)
 1ca:	fd06071b          	addiw	a4,a2,-48
 1ce:	0ff77713          	andi	a4,a4,255
 1d2:	fee5f1e3          	bgeu	a1,a4,1b4 <atoi+0x1e>
  return n;
}
 1d6:	6422                	ld	s0,8(sp)
 1d8:	0141                	addi	sp,sp,16
 1da:	8082                	ret
  n = 0;
 1dc:	4501                	li	a0,0
 1de:	bfe5                	j	1d6 <atoi+0x40>

00000000000001e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e422                	sd	s0,8(sp)
 1e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1e6:	02b57663          	bgeu	a0,a1,212 <memmove+0x32>
    while(n-- > 0)
 1ea:	02c05163          	blez	a2,20c <memmove+0x2c>
 1ee:	fff6079b          	addiw	a5,a2,-1
 1f2:	1782                	slli	a5,a5,0x20
 1f4:	9381                	srli	a5,a5,0x20
 1f6:	0785                	addi	a5,a5,1
 1f8:	97aa                	add	a5,a5,a0
  dst = vdst;
 1fa:	872a                	mv	a4,a0
      *dst++ = *src++;
 1fc:	0585                	addi	a1,a1,1
 1fe:	0705                	addi	a4,a4,1
 200:	fff5c683          	lbu	a3,-1(a1)
 204:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 208:	fee79ae3          	bne	a5,a4,1fc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 20c:	6422                	ld	s0,8(sp)
 20e:	0141                	addi	sp,sp,16
 210:	8082                	ret
    dst += n;
 212:	00c50733          	add	a4,a0,a2
    src += n;
 216:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 218:	fec05ae3          	blez	a2,20c <memmove+0x2c>
 21c:	fff6079b          	addiw	a5,a2,-1
 220:	1782                	slli	a5,a5,0x20
 222:	9381                	srli	a5,a5,0x20
 224:	fff7c793          	not	a5,a5
 228:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 22a:	15fd                	addi	a1,a1,-1
 22c:	177d                	addi	a4,a4,-1
 22e:	0005c683          	lbu	a3,0(a1)
 232:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x4a>
 23a:	bfc9                	j	20c <memmove+0x2c>

000000000000023c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 242:	ca05                	beqz	a2,272 <memcmp+0x36>
 244:	fff6069b          	addiw	a3,a2,-1
 248:	1682                	slli	a3,a3,0x20
 24a:	9281                	srli	a3,a3,0x20
 24c:	0685                	addi	a3,a3,1
 24e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 250:	00054783          	lbu	a5,0(a0)
 254:	0005c703          	lbu	a4,0(a1)
 258:	00e79863          	bne	a5,a4,268 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 25c:	0505                	addi	a0,a0,1
    p2++;
 25e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 260:	fed518e3          	bne	a0,a3,250 <memcmp+0x14>
  }
  return 0;
 264:	4501                	li	a0,0
 266:	a019                	j	26c <memcmp+0x30>
      return *p1 - *p2;
 268:	40e7853b          	subw	a0,a5,a4
}
 26c:	6422                	ld	s0,8(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret
  return 0;
 272:	4501                	li	a0,0
 274:	bfe5                	j	26c <memcmp+0x30>

0000000000000276 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 276:	1141                	addi	sp,sp,-16
 278:	e406                	sd	ra,8(sp)
 27a:	e022                	sd	s0,0(sp)
 27c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 27e:	f63ff0ef          	jal	ra,1e0 <memmove>
}
 282:	60a2                	ld	ra,8(sp)
 284:	6402                	ld	s0,0(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret

000000000000028a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 28a:	4885                	li	a7,1
 ecall
 28c:	00000073          	ecall
 ret
 290:	8082                	ret

0000000000000292 <exit>:
.global exit
exit:
 li a7, SYS_exit
 292:	4889                	li	a7,2
 ecall
 294:	00000073          	ecall
 ret
 298:	8082                	ret

000000000000029a <wait>:
.global wait
wait:
 li a7, SYS_wait
 29a:	488d                	li	a7,3
 ecall
 29c:	00000073          	ecall
 ret
 2a0:	8082                	ret

00000000000002a2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2a2:	4891                	li	a7,4
 ecall
 2a4:	00000073          	ecall
 ret
 2a8:	8082                	ret

00000000000002aa <read>:
.global read
read:
 li a7, SYS_read
 2aa:	4895                	li	a7,5
 ecall
 2ac:	00000073          	ecall
 ret
 2b0:	8082                	ret

00000000000002b2 <write>:
.global write
write:
 li a7, SYS_write
 2b2:	48c1                	li	a7,16
 ecall
 2b4:	00000073          	ecall
 ret
 2b8:	8082                	ret

00000000000002ba <close>:
.global close
close:
 li a7, SYS_close
 2ba:	48d5                	li	a7,21
 ecall
 2bc:	00000073          	ecall
 ret
 2c0:	8082                	ret

00000000000002c2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2c2:	4899                	li	a7,6
 ecall
 2c4:	00000073          	ecall
 ret
 2c8:	8082                	ret

00000000000002ca <exec>:
.global exec
exec:
 li a7, SYS_exec
 2ca:	489d                	li	a7,7
 ecall
 2cc:	00000073          	ecall
 ret
 2d0:	8082                	ret

00000000000002d2 <open>:
.global open
open:
 li a7, SYS_open
 2d2:	48bd                	li	a7,15
 ecall
 2d4:	00000073          	ecall
 ret
 2d8:	8082                	ret

00000000000002da <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2da:	48c5                	li	a7,17
 ecall
 2dc:	00000073          	ecall
 ret
 2e0:	8082                	ret

00000000000002e2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2e2:	48c9                	li	a7,18
 ecall
 2e4:	00000073          	ecall
 ret
 2e8:	8082                	ret

00000000000002ea <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2ea:	48a1                	li	a7,8
 ecall
 2ec:	00000073          	ecall
 ret
 2f0:	8082                	ret

00000000000002f2 <link>:
.global link
link:
 li a7, SYS_link
 2f2:	48cd                	li	a7,19
 ecall
 2f4:	00000073          	ecall
 ret
 2f8:	8082                	ret

00000000000002fa <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 2fa:	48d1                	li	a7,20
 ecall
 2fc:	00000073          	ecall
 ret
 300:	8082                	ret

0000000000000302 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 302:	48a5                	li	a7,9
 ecall
 304:	00000073          	ecall
 ret
 308:	8082                	ret

000000000000030a <dup>:
.global dup
dup:
 li a7, SYS_dup
 30a:	48a9                	li	a7,10
 ecall
 30c:	00000073          	ecall
 ret
 310:	8082                	ret

0000000000000312 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 312:	48ad                	li	a7,11
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 31a:	48b1                	li	a7,12
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 322:	48b5                	li	a7,13
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 32a:	48b9                	li	a7,14
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <ugetpid>:
.global ugetpid
ugetpid:
 li a7, SYS_ugetpid
 332:	48d9                	li	a7,22
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <pgaccess>:
.global pgaccess
pgaccess:
 li a7, SYS_pgaccess
 33a:	48dd                	li	a7,23
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 342:	1101                	addi	sp,sp,-32
 344:	ec06                	sd	ra,24(sp)
 346:	e822                	sd	s0,16(sp)
 348:	1000                	addi	s0,sp,32
 34a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 34e:	4605                	li	a2,1
 350:	fef40593          	addi	a1,s0,-17
 354:	f5fff0ef          	jal	ra,2b2 <write>
}
 358:	60e2                	ld	ra,24(sp)
 35a:	6442                	ld	s0,16(sp)
 35c:	6105                	addi	sp,sp,32
 35e:	8082                	ret

0000000000000360 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 360:	715d                	addi	sp,sp,-80
 362:	e486                	sd	ra,72(sp)
 364:	e0a2                	sd	s0,64(sp)
 366:	fc26                	sd	s1,56(sp)
 368:	f84a                	sd	s2,48(sp)
 36a:	f44e                	sd	s3,40(sp)
 36c:	0880                	addi	s0,sp,80
 36e:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 370:	c299                	beqz	a3,376 <printint+0x16>
 372:	0805c663          	bltz	a1,3fe <printint+0x9e>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 376:	2581                	sext.w	a1,a1
  neg = 0;
 378:	4881                	li	a7,0
 37a:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 37e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 380:	2601                	sext.w	a2,a2
 382:	00000517          	auipc	a0,0x0
 386:	4d650513          	addi	a0,a0,1238 # 858 <digits>
 38a:	883a                	mv	a6,a4
 38c:	2705                	addiw	a4,a4,1
 38e:	02c5f7bb          	remuw	a5,a1,a2
 392:	1782                	slli	a5,a5,0x20
 394:	9381                	srli	a5,a5,0x20
 396:	97aa                	add	a5,a5,a0
 398:	0007c783          	lbu	a5,0(a5)
 39c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a0:	0005879b          	sext.w	a5,a1
 3a4:	02c5d5bb          	divuw	a1,a1,a2
 3a8:	0685                	addi	a3,a3,1
 3aa:	fec7f0e3          	bgeu	a5,a2,38a <printint+0x2a>
  if(neg)
 3ae:	00088b63          	beqz	a7,3c4 <printint+0x64>
    buf[i++] = '-';
 3b2:	fd040793          	addi	a5,s0,-48
 3b6:	973e                	add	a4,a4,a5
 3b8:	02d00793          	li	a5,45
 3bc:	fef70423          	sb	a5,-24(a4)
 3c0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c4:	02e05663          	blez	a4,3f0 <printint+0x90>
 3c8:	fb840793          	addi	a5,s0,-72
 3cc:	00e78933          	add	s2,a5,a4
 3d0:	fff78993          	addi	s3,a5,-1
 3d4:	99ba                	add	s3,s3,a4
 3d6:	377d                	addiw	a4,a4,-1
 3d8:	1702                	slli	a4,a4,0x20
 3da:	9301                	srli	a4,a4,0x20
 3dc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e0:	fff94583          	lbu	a1,-1(s2)
 3e4:	8526                	mv	a0,s1
 3e6:	f5dff0ef          	jal	ra,342 <putc>
  while(--i >= 0)
 3ea:	197d                	addi	s2,s2,-1
 3ec:	ff391ae3          	bne	s2,s3,3e0 <printint+0x80>
}
 3f0:	60a6                	ld	ra,72(sp)
 3f2:	6406                	ld	s0,64(sp)
 3f4:	74e2                	ld	s1,56(sp)
 3f6:	7942                	ld	s2,48(sp)
 3f8:	79a2                	ld	s3,40(sp)
 3fa:	6161                	addi	sp,sp,80
 3fc:	8082                	ret
    x = -xx;
 3fe:	40b005bb          	negw	a1,a1
    neg = 1;
 402:	4885                	li	a7,1
    x = -xx;
 404:	bf9d                	j	37a <printint+0x1a>

0000000000000406 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 406:	7119                	addi	sp,sp,-128
 408:	fc86                	sd	ra,120(sp)
 40a:	f8a2                	sd	s0,112(sp)
 40c:	f4a6                	sd	s1,104(sp)
 40e:	f0ca                	sd	s2,96(sp)
 410:	ecce                	sd	s3,88(sp)
 412:	e8d2                	sd	s4,80(sp)
 414:	e4d6                	sd	s5,72(sp)
 416:	e0da                	sd	s6,64(sp)
 418:	fc5e                	sd	s7,56(sp)
 41a:	f862                	sd	s8,48(sp)
 41c:	f466                	sd	s9,40(sp)
 41e:	f06a                	sd	s10,32(sp)
 420:	ec6e                	sd	s11,24(sp)
 422:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 424:	0005c903          	lbu	s2,0(a1)
 428:	22090e63          	beqz	s2,664 <vprintf+0x25e>
 42c:	8b2a                	mv	s6,a0
 42e:	8a2e                	mv	s4,a1
 430:	8bb2                	mv	s7,a2
  state = 0;
 432:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 434:	4481                	li	s1,0
 436:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 438:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 43c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 440:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 444:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 448:	00000c97          	auipc	s9,0x0
 44c:	410c8c93          	addi	s9,s9,1040 # 858 <digits>
 450:	a005                	j	470 <vprintf+0x6a>
        putc(fd, c0);
 452:	85ca                	mv	a1,s2
 454:	855a                	mv	a0,s6
 456:	eedff0ef          	jal	ra,342 <putc>
 45a:	a019                	j	460 <vprintf+0x5a>
    } else if(state == '%'){
 45c:	03598263          	beq	s3,s5,480 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 460:	2485                	addiw	s1,s1,1
 462:	8726                	mv	a4,s1
 464:	009a07b3          	add	a5,s4,s1
 468:	0007c903          	lbu	s2,0(a5)
 46c:	1e090c63          	beqz	s2,664 <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 470:	0009079b          	sext.w	a5,s2
    if(state == 0){
 474:	fe0994e3          	bnez	s3,45c <vprintf+0x56>
      if(c0 == '%'){
 478:	fd579de3          	bne	a5,s5,452 <vprintf+0x4c>
        state = '%';
 47c:	89be                	mv	s3,a5
 47e:	b7cd                	j	460 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 480:	cfa5                	beqz	a5,4f8 <vprintf+0xf2>
 482:	00ea06b3          	add	a3,s4,a4
 486:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 48a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 48c:	c681                	beqz	a3,494 <vprintf+0x8e>
 48e:	9752                	add	a4,a4,s4
 490:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 494:	03878a63          	beq	a5,s8,4c8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 498:	05a78463          	beq	a5,s10,4e0 <vprintf+0xda>
      } else if(c0 == 'u'){
 49c:	0db78763          	beq	a5,s11,56a <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4a0:	07800713          	li	a4,120
 4a4:	10e78963          	beq	a5,a4,5b6 <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a8:	07000713          	li	a4,112
 4ac:	12e78e63          	beq	a5,a4,5e8 <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4b0:	07300713          	li	a4,115
 4b4:	16e78b63          	beq	a5,a4,62a <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b8:	05579063          	bne	a5,s5,4f8 <vprintf+0xf2>
        putc(fd, '%');
 4bc:	85d6                	mv	a1,s5
 4be:	855a                	mv	a0,s6
 4c0:	e83ff0ef          	jal	ra,342 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4c4:	4981                	li	s3,0
 4c6:	bf69                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 4c8:	008b8913          	addi	s2,s7,8
 4cc:	4685                	li	a3,1
 4ce:	4629                	li	a2,10
 4d0:	000ba583          	lw	a1,0(s7)
 4d4:	855a                	mv	a0,s6
 4d6:	e8bff0ef          	jal	ra,360 <printint>
 4da:	8bca                	mv	s7,s2
      state = 0;
 4dc:	4981                	li	s3,0
 4de:	b749                	j	460 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	03868663          	beq	a3,s8,50c <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4e4:	05a68163          	beq	a3,s10,526 <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 4e8:	09b68d63          	beq	a3,s11,582 <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 4ec:	03a68f63          	beq	a3,s10,52a <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 4f0:	07800793          	li	a5,120
 4f4:	0cf68d63          	beq	a3,a5,5ce <vprintf+0x1c8>
        putc(fd, '%');
 4f8:	85d6                	mv	a1,s5
 4fa:	855a                	mv	a0,s6
 4fc:	e47ff0ef          	jal	ra,342 <putc>
        putc(fd, c0);
 500:	85ca                	mv	a1,s2
 502:	855a                	mv	a0,s6
 504:	e3fff0ef          	jal	ra,342 <putc>
      state = 0;
 508:	4981                	li	s3,0
 50a:	bf99                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 50c:	008b8913          	addi	s2,s7,8
 510:	4685                	li	a3,1
 512:	4629                	li	a2,10
 514:	000bb583          	ld	a1,0(s7)
 518:	855a                	mv	a0,s6
 51a:	e47ff0ef          	jal	ra,360 <printint>
        i += 1;
 51e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 520:	8bca                	mv	s7,s2
      state = 0;
 522:	4981                	li	s3,0
        i += 1;
 524:	bf35                	j	460 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 526:	03860563          	beq	a2,s8,550 <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 52a:	07b60963          	beq	a2,s11,59c <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 52e:	07800793          	li	a5,120
 532:	fcf613e3          	bne	a2,a5,4f8 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 536:	008b8913          	addi	s2,s7,8
 53a:	4681                	li	a3,0
 53c:	4641                	li	a2,16
 53e:	000bb583          	ld	a1,0(s7)
 542:	855a                	mv	a0,s6
 544:	e1dff0ef          	jal	ra,360 <printint>
        i += 2;
 548:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 54a:	8bca                	mv	s7,s2
      state = 0;
 54c:	4981                	li	s3,0
        i += 2;
 54e:	bf09                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 550:	008b8913          	addi	s2,s7,8
 554:	4685                	li	a3,1
 556:	4629                	li	a2,10
 558:	000bb583          	ld	a1,0(s7)
 55c:	855a                	mv	a0,s6
 55e:	e03ff0ef          	jal	ra,360 <printint>
        i += 2;
 562:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 564:	8bca                	mv	s7,s2
      state = 0;
 566:	4981                	li	s3,0
        i += 2;
 568:	bde5                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 56a:	008b8913          	addi	s2,s7,8
 56e:	4681                	li	a3,0
 570:	4629                	li	a2,10
 572:	000ba583          	lw	a1,0(s7)
 576:	855a                	mv	a0,s6
 578:	de9ff0ef          	jal	ra,360 <printint>
 57c:	8bca                	mv	s7,s2
      state = 0;
 57e:	4981                	li	s3,0
 580:	b5c5                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 582:	008b8913          	addi	s2,s7,8
 586:	4681                	li	a3,0
 588:	4629                	li	a2,10
 58a:	000bb583          	ld	a1,0(s7)
 58e:	855a                	mv	a0,s6
 590:	dd1ff0ef          	jal	ra,360 <printint>
        i += 1;
 594:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 596:	8bca                	mv	s7,s2
      state = 0;
 598:	4981                	li	s3,0
        i += 1;
 59a:	b5d9                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 59c:	008b8913          	addi	s2,s7,8
 5a0:	4681                	li	a3,0
 5a2:	4629                	li	a2,10
 5a4:	000bb583          	ld	a1,0(s7)
 5a8:	855a                	mv	a0,s6
 5aa:	db7ff0ef          	jal	ra,360 <printint>
        i += 2;
 5ae:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	8bca                	mv	s7,s2
      state = 0;
 5b2:	4981                	li	s3,0
        i += 2;
 5b4:	b575                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 5b6:	008b8913          	addi	s2,s7,8
 5ba:	4681                	li	a3,0
 5bc:	4641                	li	a2,16
 5be:	000ba583          	lw	a1,0(s7)
 5c2:	855a                	mv	a0,s6
 5c4:	d9dff0ef          	jal	ra,360 <printint>
 5c8:	8bca                	mv	s7,s2
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	bd51                	j	460 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ce:	008b8913          	addi	s2,s7,8
 5d2:	4681                	li	a3,0
 5d4:	4641                	li	a2,16
 5d6:	000bb583          	ld	a1,0(s7)
 5da:	855a                	mv	a0,s6
 5dc:	d85ff0ef          	jal	ra,360 <printint>
        i += 1;
 5e0:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	8bca                	mv	s7,s2
      state = 0;
 5e4:	4981                	li	s3,0
        i += 1;
 5e6:	bdad                	j	460 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 5e8:	008b8793          	addi	a5,s7,8
 5ec:	f8f43423          	sd	a5,-120(s0)
 5f0:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5f4:	03000593          	li	a1,48
 5f8:	855a                	mv	a0,s6
 5fa:	d49ff0ef          	jal	ra,342 <putc>
  putc(fd, 'x');
 5fe:	07800593          	li	a1,120
 602:	855a                	mv	a0,s6
 604:	d3fff0ef          	jal	ra,342 <putc>
 608:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 60a:	03c9d793          	srli	a5,s3,0x3c
 60e:	97e6                	add	a5,a5,s9
 610:	0007c583          	lbu	a1,0(a5)
 614:	855a                	mv	a0,s6
 616:	d2dff0ef          	jal	ra,342 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 61a:	0992                	slli	s3,s3,0x4
 61c:	397d                	addiw	s2,s2,-1
 61e:	fe0916e3          	bnez	s2,60a <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 622:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 626:	4981                	li	s3,0
 628:	bd25                	j	460 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 62a:	008b8993          	addi	s3,s7,8
 62e:	000bb903          	ld	s2,0(s7)
 632:	00090f63          	beqz	s2,650 <vprintf+0x24a>
        for(; *s; s++)
 636:	00094583          	lbu	a1,0(s2)
 63a:	c195                	beqz	a1,65e <vprintf+0x258>
          putc(fd, *s);
 63c:	855a                	mv	a0,s6
 63e:	d05ff0ef          	jal	ra,342 <putc>
        for(; *s; s++)
 642:	0905                	addi	s2,s2,1
 644:	00094583          	lbu	a1,0(s2)
 648:	f9f5                	bnez	a1,63c <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 64a:	8bce                	mv	s7,s3
      state = 0;
 64c:	4981                	li	s3,0
 64e:	bd09                	j	460 <vprintf+0x5a>
          s = "(null)";
 650:	00000917          	auipc	s2,0x0
 654:	20090913          	addi	s2,s2,512 # 850 <malloc+0xea>
        for(; *s; s++)
 658:	02800593          	li	a1,40
 65c:	b7c5                	j	63c <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 65e:	8bce                	mv	s7,s3
      state = 0;
 660:	4981                	li	s3,0
 662:	bbfd                	j	460 <vprintf+0x5a>
    }
  }
}
 664:	70e6                	ld	ra,120(sp)
 666:	7446                	ld	s0,112(sp)
 668:	74a6                	ld	s1,104(sp)
 66a:	7906                	ld	s2,96(sp)
 66c:	69e6                	ld	s3,88(sp)
 66e:	6a46                	ld	s4,80(sp)
 670:	6aa6                	ld	s5,72(sp)
 672:	6b06                	ld	s6,64(sp)
 674:	7be2                	ld	s7,56(sp)
 676:	7c42                	ld	s8,48(sp)
 678:	7ca2                	ld	s9,40(sp)
 67a:	7d02                	ld	s10,32(sp)
 67c:	6de2                	ld	s11,24(sp)
 67e:	6109                	addi	sp,sp,128
 680:	8082                	ret

0000000000000682 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 682:	715d                	addi	sp,sp,-80
 684:	ec06                	sd	ra,24(sp)
 686:	e822                	sd	s0,16(sp)
 688:	1000                	addi	s0,sp,32
 68a:	e010                	sd	a2,0(s0)
 68c:	e414                	sd	a3,8(s0)
 68e:	e818                	sd	a4,16(s0)
 690:	ec1c                	sd	a5,24(s0)
 692:	03043023          	sd	a6,32(s0)
 696:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 69a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 69e:	8622                	mv	a2,s0
 6a0:	d67ff0ef          	jal	ra,406 <vprintf>
}
 6a4:	60e2                	ld	ra,24(sp)
 6a6:	6442                	ld	s0,16(sp)
 6a8:	6161                	addi	sp,sp,80
 6aa:	8082                	ret

00000000000006ac <printf>:

void
printf(const char *fmt, ...)
{
 6ac:	711d                	addi	sp,sp,-96
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	1000                	addi	s0,sp,32
 6b4:	e40c                	sd	a1,8(s0)
 6b6:	e810                	sd	a2,16(s0)
 6b8:	ec14                	sd	a3,24(s0)
 6ba:	f018                	sd	a4,32(s0)
 6bc:	f41c                	sd	a5,40(s0)
 6be:	03043823          	sd	a6,48(s0)
 6c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6c6:	00840613          	addi	a2,s0,8
 6ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6ce:	85aa                	mv	a1,a0
 6d0:	4505                	li	a0,1
 6d2:	d35ff0ef          	jal	ra,406 <vprintf>
}
 6d6:	60e2                	ld	ra,24(sp)
 6d8:	6442                	ld	s0,16(sp)
 6da:	6125                	addi	sp,sp,96
 6dc:	8082                	ret

00000000000006de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6de:	1141                	addi	sp,sp,-16
 6e0:	e422                	sd	s0,8(sp)
 6e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6e8:	00001797          	auipc	a5,0x1
 6ec:	9187b783          	ld	a5,-1768(a5) # 1000 <freep>
 6f0:	a805                	j	720 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6f2:	4618                	lw	a4,8(a2)
 6f4:	9db9                	addw	a1,a1,a4
 6f6:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 6fa:	6398                	ld	a4,0(a5)
 6fc:	6318                	ld	a4,0(a4)
 6fe:	fee53823          	sd	a4,-16(a0)
 702:	a091                	j	746 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 704:	ff852703          	lw	a4,-8(a0)
 708:	9e39                	addw	a2,a2,a4
 70a:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 70c:	ff053703          	ld	a4,-16(a0)
 710:	e398                	sd	a4,0(a5)
 712:	a099                	j	758 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 714:	6398                	ld	a4,0(a5)
 716:	00e7e463          	bltu	a5,a4,71e <free+0x40>
 71a:	00e6ea63          	bltu	a3,a4,72e <free+0x50>
{
 71e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 720:	fed7fae3          	bgeu	a5,a3,714 <free+0x36>
 724:	6398                	ld	a4,0(a5)
 726:	00e6e463          	bltu	a3,a4,72e <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72a:	fee7eae3          	bltu	a5,a4,71e <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 72e:	ff852583          	lw	a1,-8(a0)
 732:	6390                	ld	a2,0(a5)
 734:	02059713          	slli	a4,a1,0x20
 738:	9301                	srli	a4,a4,0x20
 73a:	0712                	slli	a4,a4,0x4
 73c:	9736                	add	a4,a4,a3
 73e:	fae60ae3          	beq	a2,a4,6f2 <free+0x14>
    bp->s.ptr = p->s.ptr;
 742:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 746:	4790                	lw	a2,8(a5)
 748:	02061713          	slli	a4,a2,0x20
 74c:	9301                	srli	a4,a4,0x20
 74e:	0712                	slli	a4,a4,0x4
 750:	973e                	add	a4,a4,a5
 752:	fae689e3          	beq	a3,a4,704 <free+0x26>
  } else
    p->s.ptr = bp;
 756:	e394                	sd	a3,0(a5)
  freep = p;
 758:	00001717          	auipc	a4,0x1
 75c:	8af73423          	sd	a5,-1880(a4) # 1000 <freep>
}
 760:	6422                	ld	s0,8(sp)
 762:	0141                	addi	sp,sp,16
 764:	8082                	ret

0000000000000766 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 766:	7139                	addi	sp,sp,-64
 768:	fc06                	sd	ra,56(sp)
 76a:	f822                	sd	s0,48(sp)
 76c:	f426                	sd	s1,40(sp)
 76e:	f04a                	sd	s2,32(sp)
 770:	ec4e                	sd	s3,24(sp)
 772:	e852                	sd	s4,16(sp)
 774:	e456                	sd	s5,8(sp)
 776:	e05a                	sd	s6,0(sp)
 778:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77a:	02051493          	slli	s1,a0,0x20
 77e:	9081                	srli	s1,s1,0x20
 780:	04bd                	addi	s1,s1,15
 782:	8091                	srli	s1,s1,0x4
 784:	0014899b          	addiw	s3,s1,1
 788:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 78a:	00001517          	auipc	a0,0x1
 78e:	87653503          	ld	a0,-1930(a0) # 1000 <freep>
 792:	c515                	beqz	a0,7be <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 794:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 796:	4798                	lw	a4,8(a5)
 798:	02977f63          	bgeu	a4,s1,7d6 <malloc+0x70>
 79c:	8a4e                	mv	s4,s3
 79e:	0009871b          	sext.w	a4,s3
 7a2:	6685                	lui	a3,0x1
 7a4:	00d77363          	bgeu	a4,a3,7aa <malloc+0x44>
 7a8:	6a05                	lui	s4,0x1
 7aa:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7ae:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b2:	00001917          	auipc	s2,0x1
 7b6:	84e90913          	addi	s2,s2,-1970 # 1000 <freep>
  if(p == (char*)-1)
 7ba:	5afd                	li	s5,-1
 7bc:	a0bd                	j	82a <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 7be:	00001797          	auipc	a5,0x1
 7c2:	85278793          	addi	a5,a5,-1966 # 1010 <base>
 7c6:	00001717          	auipc	a4,0x1
 7ca:	82f73d23          	sd	a5,-1990(a4) # 1000 <freep>
 7ce:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d0:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d4:	b7e1                	j	79c <malloc+0x36>
      if(p->s.size == nunits)
 7d6:	02e48b63          	beq	s1,a4,80c <malloc+0xa6>
        p->s.size -= nunits;
 7da:	4137073b          	subw	a4,a4,s3
 7de:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7e0:	1702                	slli	a4,a4,0x20
 7e2:	9301                	srli	a4,a4,0x20
 7e4:	0712                	slli	a4,a4,0x4
 7e6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7e8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7ec:	00001717          	auipc	a4,0x1
 7f0:	80a73a23          	sd	a0,-2028(a4) # 1000 <freep>
      return (void*)(p + 1);
 7f4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7f8:	70e2                	ld	ra,56(sp)
 7fa:	7442                	ld	s0,48(sp)
 7fc:	74a2                	ld	s1,40(sp)
 7fe:	7902                	ld	s2,32(sp)
 800:	69e2                	ld	s3,24(sp)
 802:	6a42                	ld	s4,16(sp)
 804:	6aa2                	ld	s5,8(sp)
 806:	6b02                	ld	s6,0(sp)
 808:	6121                	addi	sp,sp,64
 80a:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 80c:	6398                	ld	a4,0(a5)
 80e:	e118                	sd	a4,0(a0)
 810:	bff1                	j	7ec <malloc+0x86>
  hp->s.size = nu;
 812:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 816:	0541                	addi	a0,a0,16
 818:	ec7ff0ef          	jal	ra,6de <free>
  return freep;
 81c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 820:	dd61                	beqz	a0,7f8 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 822:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 824:	4798                	lw	a4,8(a5)
 826:	fa9778e3          	bgeu	a4,s1,7d6 <malloc+0x70>
    if(p == freep)
 82a:	00093703          	ld	a4,0(s2)
 82e:	853e                	mv	a0,a5
 830:	fef719e3          	bne	a4,a5,822 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 834:	8552                	mv	a0,s4
 836:	ae5ff0ef          	jal	ra,31a <sbrk>
  if(p == (char*)-1)
 83a:	fd551ce3          	bne	a0,s5,812 <malloc+0xac>
        return 0;
 83e:	4501                	li	a0,0
 840:	bf65                	j	7f8 <malloc+0x92>
