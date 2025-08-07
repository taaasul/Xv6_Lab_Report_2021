
user/_cat:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <cat>:

char buf[512];

void
cat(int fd)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	1800                	addi	s0,sp,48
   e:	89aa                	mv	s3,a0
  int n;

  while((n = read(fd, buf, sizeof(buf))) > 0) {
  10:	00001917          	auipc	s2,0x1
  14:	00090913          	mv	s2,s2
  18:	20000613          	li	a2,512
  1c:	85ca                	mv	a1,s2
  1e:	854e                	mv	a0,s3
  20:	352000ef          	jal	ra,372 <read>
  24:	84aa                	mv	s1,a0
  26:	02a05363          	blez	a0,4c <cat+0x4c>
    if (write(1, buf, n) != n) {
  2a:	8626                	mv	a2,s1
  2c:	85ca                	mv	a1,s2
  2e:	4505                	li	a0,1
  30:	34a000ef          	jal	ra,37a <write>
  34:	fe9502e3          	beq	a0,s1,18 <cat+0x18>
      fprintf(2, "cat: write error\n");
  38:	00001597          	auipc	a1,0x1
  3c:	8d858593          	addi	a1,a1,-1832 # 910 <malloc+0xe2>
  40:	4509                	li	a0,2
  42:	708000ef          	jal	ra,74a <fprintf>
      exit(1);
  46:	4505                	li	a0,1
  48:	312000ef          	jal	ra,35a <exit>
    }
  }
  if(n < 0){
  4c:	00054963          	bltz	a0,5e <cat+0x5e>
    fprintf(2, "cat: read error\n");
    exit(1);
  }
}
  50:	70a2                	ld	ra,40(sp)
  52:	7402                	ld	s0,32(sp)
  54:	64e2                	ld	s1,24(sp)
  56:	6942                	ld	s2,16(sp)
  58:	69a2                	ld	s3,8(sp)
  5a:	6145                	addi	sp,sp,48
  5c:	8082                	ret
    fprintf(2, "cat: read error\n");
  5e:	00001597          	auipc	a1,0x1
  62:	8ca58593          	addi	a1,a1,-1846 # 928 <malloc+0xfa>
  66:	4509                	li	a0,2
  68:	6e2000ef          	jal	ra,74a <fprintf>
    exit(1);
  6c:	4505                	li	a0,1
  6e:	2ec000ef          	jal	ra,35a <exit>

0000000000000072 <main>:

int
main(int argc, char *argv[])
{
  72:	7179                	addi	sp,sp,-48
  74:	f406                	sd	ra,40(sp)
  76:	f022                	sd	s0,32(sp)
  78:	ec26                	sd	s1,24(sp)
  7a:	e84a                	sd	s2,16(sp)
  7c:	e44e                	sd	s3,8(sp)
  7e:	e052                	sd	s4,0(sp)
  80:	1800                	addi	s0,sp,48
  int fd, i;

  if(argc <= 1){
  82:	4785                	li	a5,1
  84:	02a7df63          	bge	a5,a0,c2 <main+0x50>
  88:	00858913          	addi	s2,a1,8
  8c:	ffe5099b          	addiw	s3,a0,-2
  90:	1982                	slli	s3,s3,0x20
  92:	0209d993          	srli	s3,s3,0x20
  96:	098e                	slli	s3,s3,0x3
  98:	05c1                	addi	a1,a1,16
  9a:	99ae                	add	s3,s3,a1
    cat(0);
    exit(0);
  }

  for(i = 1; i < argc; i++){
    if((fd = open(argv[i], O_RDONLY)) < 0){
  9c:	4581                	li	a1,0
  9e:	00093503          	ld	a0,0(s2) # 1010 <buf>
  a2:	2f8000ef          	jal	ra,39a <open>
  a6:	84aa                	mv	s1,a0
  a8:	02054363          	bltz	a0,ce <main+0x5c>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
      exit(1);
    }
    cat(fd);
  ac:	f55ff0ef          	jal	ra,0 <cat>
    close(fd);
  b0:	8526                	mv	a0,s1
  b2:	2d0000ef          	jal	ra,382 <close>
  for(i = 1; i < argc; i++){
  b6:	0921                	addi	s2,s2,8
  b8:	ff3912e3          	bne	s2,s3,9c <main+0x2a>
  }
  exit(0);
  bc:	4501                	li	a0,0
  be:	29c000ef          	jal	ra,35a <exit>
    cat(0);
  c2:	4501                	li	a0,0
  c4:	f3dff0ef          	jal	ra,0 <cat>
    exit(0);
  c8:	4501                	li	a0,0
  ca:	290000ef          	jal	ra,35a <exit>
      fprintf(2, "cat: cannot open %s\n", argv[i]);
  ce:	00093603          	ld	a2,0(s2)
  d2:	00001597          	auipc	a1,0x1
  d6:	86e58593          	addi	a1,a1,-1938 # 940 <malloc+0x112>
  da:	4509                	li	a0,2
  dc:	66e000ef          	jal	ra,74a <fprintf>
      exit(1);
  e0:	4505                	li	a0,1
  e2:	278000ef          	jal	ra,35a <exit>

00000000000000e6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ee:	f85ff0ef          	jal	ra,72 <main>
  exit(0);
  f2:	4501                	li	a0,0
  f4:	266000ef          	jal	ra,35a <exit>

00000000000000f8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f8:	1141                	addi	sp,sp,-16
  fa:	e422                	sd	s0,8(sp)
  fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fe:	87aa                	mv	a5,a0
 100:	0585                	addi	a1,a1,1
 102:	0785                	addi	a5,a5,1
 104:	fff5c703          	lbu	a4,-1(a1)
 108:	fee78fa3          	sb	a4,-1(a5)
 10c:	fb75                	bnez	a4,100 <strcpy+0x8>
    ;
  return os;
}
 10e:	6422                	ld	s0,8(sp)
 110:	0141                	addi	sp,sp,16
 112:	8082                	ret

0000000000000114 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 114:	1141                	addi	sp,sp,-16
 116:	e422                	sd	s0,8(sp)
 118:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 11a:	00054783          	lbu	a5,0(a0)
 11e:	cb91                	beqz	a5,132 <strcmp+0x1e>
 120:	0005c703          	lbu	a4,0(a1)
 124:	00f71763          	bne	a4,a5,132 <strcmp+0x1e>
    p++, q++;
 128:	0505                	addi	a0,a0,1
 12a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12c:	00054783          	lbu	a5,0(a0)
 130:	fbe5                	bnez	a5,120 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 132:	0005c503          	lbu	a0,0(a1)
}
 136:	40a7853b          	subw	a0,a5,a0
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret

0000000000000140 <strlen>:

uint
strlen(const char *s)
{
 140:	1141                	addi	sp,sp,-16
 142:	e422                	sd	s0,8(sp)
 144:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 146:	00054783          	lbu	a5,0(a0)
 14a:	cf91                	beqz	a5,166 <strlen+0x26>
 14c:	0505                	addi	a0,a0,1
 14e:	87aa                	mv	a5,a0
 150:	4685                	li	a3,1
 152:	9e89                	subw	a3,a3,a0
 154:	00f6853b          	addw	a0,a3,a5
 158:	0785                	addi	a5,a5,1
 15a:	fff7c703          	lbu	a4,-1(a5)
 15e:	fb7d                	bnez	a4,154 <strlen+0x14>
    ;
  return n;
}
 160:	6422                	ld	s0,8(sp)
 162:	0141                	addi	sp,sp,16
 164:	8082                	ret
  for(n = 0; s[n]; n++)
 166:	4501                	li	a0,0
 168:	bfe5                	j	160 <strlen+0x20>

000000000000016a <memset>:

void*
memset(void *dst, int c, uint n)
{
 16a:	1141                	addi	sp,sp,-16
 16c:	e422                	sd	s0,8(sp)
 16e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 170:	ce09                	beqz	a2,18a <memset+0x20>
 172:	87aa                	mv	a5,a0
 174:	fff6071b          	addiw	a4,a2,-1
 178:	1702                	slli	a4,a4,0x20
 17a:	9301                	srli	a4,a4,0x20
 17c:	0705                	addi	a4,a4,1
 17e:	972a                	add	a4,a4,a0
    cdst[i] = c;
 180:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 184:	0785                	addi	a5,a5,1
 186:	fee79de3          	bne	a5,a4,180 <memset+0x16>
  }
  return dst;
}
 18a:	6422                	ld	s0,8(sp)
 18c:	0141                	addi	sp,sp,16
 18e:	8082                	ret

0000000000000190 <strchr>:

char*
strchr(const char *s, char c)
{
 190:	1141                	addi	sp,sp,-16
 192:	e422                	sd	s0,8(sp)
 194:	0800                	addi	s0,sp,16
  for(; *s; s++)
 196:	00054783          	lbu	a5,0(a0)
 19a:	cb99                	beqz	a5,1b0 <strchr+0x20>
    if(*s == c)
 19c:	00f58763          	beq	a1,a5,1aa <strchr+0x1a>
  for(; *s; s++)
 1a0:	0505                	addi	a0,a0,1
 1a2:	00054783          	lbu	a5,0(a0)
 1a6:	fbfd                	bnez	a5,19c <strchr+0xc>
      return (char*)s;
  return 0;
 1a8:	4501                	li	a0,0
}
 1aa:	6422                	ld	s0,8(sp)
 1ac:	0141                	addi	sp,sp,16
 1ae:	8082                	ret
  return 0;
 1b0:	4501                	li	a0,0
 1b2:	bfe5                	j	1aa <strchr+0x1a>

00000000000001b4 <gets>:

char*
gets(char *buf, int max)
{
 1b4:	711d                	addi	sp,sp,-96
 1b6:	ec86                	sd	ra,88(sp)
 1b8:	e8a2                	sd	s0,80(sp)
 1ba:	e4a6                	sd	s1,72(sp)
 1bc:	e0ca                	sd	s2,64(sp)
 1be:	fc4e                	sd	s3,56(sp)
 1c0:	f852                	sd	s4,48(sp)
 1c2:	f456                	sd	s5,40(sp)
 1c4:	f05a                	sd	s6,32(sp)
 1c6:	ec5e                	sd	s7,24(sp)
 1c8:	1080                	addi	s0,sp,96
 1ca:	8baa                	mv	s7,a0
 1cc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	892a                	mv	s2,a0
 1d0:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d2:	4aa9                	li	s5,10
 1d4:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d6:	89a6                	mv	s3,s1
 1d8:	2485                	addiw	s1,s1,1
 1da:	0344d663          	bge	s1,s4,206 <gets+0x52>
    cc = read(0, &c, 1);
 1de:	4605                	li	a2,1
 1e0:	faf40593          	addi	a1,s0,-81
 1e4:	4501                	li	a0,0
 1e6:	18c000ef          	jal	ra,372 <read>
    if(cc < 1)
 1ea:	00a05e63          	blez	a0,206 <gets+0x52>
    buf[i++] = c;
 1ee:	faf44783          	lbu	a5,-81(s0)
 1f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f6:	01578763          	beq	a5,s5,204 <gets+0x50>
 1fa:	0905                	addi	s2,s2,1
 1fc:	fd679de3          	bne	a5,s6,1d6 <gets+0x22>
  for(i=0; i+1 < max; ){
 200:	89a6                	mv	s3,s1
 202:	a011                	j	206 <gets+0x52>
 204:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 206:	99de                	add	s3,s3,s7
 208:	00098023          	sb	zero,0(s3)
  return buf;
}
 20c:	855e                	mv	a0,s7
 20e:	60e6                	ld	ra,88(sp)
 210:	6446                	ld	s0,80(sp)
 212:	64a6                	ld	s1,72(sp)
 214:	6906                	ld	s2,64(sp)
 216:	79e2                	ld	s3,56(sp)
 218:	7a42                	ld	s4,48(sp)
 21a:	7aa2                	ld	s5,40(sp)
 21c:	7b02                	ld	s6,32(sp)
 21e:	6be2                	ld	s7,24(sp)
 220:	6125                	addi	sp,sp,96
 222:	8082                	ret

0000000000000224 <stat>:

int
stat(const char *n, struct stat *st)
{
 224:	1101                	addi	sp,sp,-32
 226:	ec06                	sd	ra,24(sp)
 228:	e822                	sd	s0,16(sp)
 22a:	e426                	sd	s1,8(sp)
 22c:	e04a                	sd	s2,0(sp)
 22e:	1000                	addi	s0,sp,32
 230:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 232:	4581                	li	a1,0
 234:	166000ef          	jal	ra,39a <open>
  if(fd < 0)
 238:	02054163          	bltz	a0,25a <stat+0x36>
 23c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 23e:	85ca                	mv	a1,s2
 240:	172000ef          	jal	ra,3b2 <fstat>
 244:	892a                	mv	s2,a0
  close(fd);
 246:	8526                	mv	a0,s1
 248:	13a000ef          	jal	ra,382 <close>
  return r;
}
 24c:	854a                	mv	a0,s2
 24e:	60e2                	ld	ra,24(sp)
 250:	6442                	ld	s0,16(sp)
 252:	64a2                	ld	s1,8(sp)
 254:	6902                	ld	s2,0(sp)
 256:	6105                	addi	sp,sp,32
 258:	8082                	ret
    return -1;
 25a:	597d                	li	s2,-1
 25c:	bfc5                	j	24c <stat+0x28>

000000000000025e <atoi>:

int
atoi(const char *s)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 264:	00054603          	lbu	a2,0(a0)
 268:	fd06079b          	addiw	a5,a2,-48
 26c:	0ff7f793          	andi	a5,a5,255
 270:	4725                	li	a4,9
 272:	02f76963          	bltu	a4,a5,2a4 <atoi+0x46>
 276:	86aa                	mv	a3,a0
  n = 0;
 278:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 27a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 27c:	0685                	addi	a3,a3,1
 27e:	0025179b          	slliw	a5,a0,0x2
 282:	9fa9                	addw	a5,a5,a0
 284:	0017979b          	slliw	a5,a5,0x1
 288:	9fb1                	addw	a5,a5,a2
 28a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 28e:	0006c603          	lbu	a2,0(a3)
 292:	fd06071b          	addiw	a4,a2,-48
 296:	0ff77713          	andi	a4,a4,255
 29a:	fee5f1e3          	bgeu	a1,a4,27c <atoi+0x1e>
  return n;
}
 29e:	6422                	ld	s0,8(sp)
 2a0:	0141                	addi	sp,sp,16
 2a2:	8082                	ret
  n = 0;
 2a4:	4501                	li	a0,0
 2a6:	bfe5                	j	29e <atoi+0x40>

00000000000002a8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e422                	sd	s0,8(sp)
 2ac:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ae:	02b57663          	bgeu	a0,a1,2da <memmove+0x32>
    while(n-- > 0)
 2b2:	02c05163          	blez	a2,2d4 <memmove+0x2c>
 2b6:	fff6079b          	addiw	a5,a2,-1
 2ba:	1782                	slli	a5,a5,0x20
 2bc:	9381                	srli	a5,a5,0x20
 2be:	0785                	addi	a5,a5,1
 2c0:	97aa                	add	a5,a5,a0
  dst = vdst;
 2c2:	872a                	mv	a4,a0
      *dst++ = *src++;
 2c4:	0585                	addi	a1,a1,1
 2c6:	0705                	addi	a4,a4,1
 2c8:	fff5c683          	lbu	a3,-1(a1)
 2cc:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2d0:	fee79ae3          	bne	a5,a4,2c4 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2d4:	6422                	ld	s0,8(sp)
 2d6:	0141                	addi	sp,sp,16
 2d8:	8082                	ret
    dst += n;
 2da:	00c50733          	add	a4,a0,a2
    src += n;
 2de:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2e0:	fec05ae3          	blez	a2,2d4 <memmove+0x2c>
 2e4:	fff6079b          	addiw	a5,a2,-1
 2e8:	1782                	slli	a5,a5,0x20
 2ea:	9381                	srli	a5,a5,0x20
 2ec:	fff7c793          	not	a5,a5
 2f0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2f2:	15fd                	addi	a1,a1,-1
 2f4:	177d                	addi	a4,a4,-1
 2f6:	0005c683          	lbu	a3,0(a1)
 2fa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2fe:	fee79ae3          	bne	a5,a4,2f2 <memmove+0x4a>
 302:	bfc9                	j	2d4 <memmove+0x2c>

0000000000000304 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 304:	1141                	addi	sp,sp,-16
 306:	e422                	sd	s0,8(sp)
 308:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 30a:	ca05                	beqz	a2,33a <memcmp+0x36>
 30c:	fff6069b          	addiw	a3,a2,-1
 310:	1682                	slli	a3,a3,0x20
 312:	9281                	srli	a3,a3,0x20
 314:	0685                	addi	a3,a3,1
 316:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 318:	00054783          	lbu	a5,0(a0)
 31c:	0005c703          	lbu	a4,0(a1)
 320:	00e79863          	bne	a5,a4,330 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 324:	0505                	addi	a0,a0,1
    p2++;
 326:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 328:	fed518e3          	bne	a0,a3,318 <memcmp+0x14>
  }
  return 0;
 32c:	4501                	li	a0,0
 32e:	a019                	j	334 <memcmp+0x30>
      return *p1 - *p2;
 330:	40e7853b          	subw	a0,a5,a4
}
 334:	6422                	ld	s0,8(sp)
 336:	0141                	addi	sp,sp,16
 338:	8082                	ret
  return 0;
 33a:	4501                	li	a0,0
 33c:	bfe5                	j	334 <memcmp+0x30>

000000000000033e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 33e:	1141                	addi	sp,sp,-16
 340:	e406                	sd	ra,8(sp)
 342:	e022                	sd	s0,0(sp)
 344:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 346:	f63ff0ef          	jal	ra,2a8 <memmove>
}
 34a:	60a2                	ld	ra,8(sp)
 34c:	6402                	ld	s0,0(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret

0000000000000352 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 352:	4885                	li	a7,1
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <exit>:
.global exit
exit:
 li a7, SYS_exit
 35a:	4889                	li	a7,2
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <wait>:
.global wait
wait:
 li a7, SYS_wait
 362:	488d                	li	a7,3
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 36a:	4891                	li	a7,4
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <read>:
.global read
read:
 li a7, SYS_read
 372:	4895                	li	a7,5
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <write>:
.global write
write:
 li a7, SYS_write
 37a:	48c1                	li	a7,16
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <close>:
.global close
close:
 li a7, SYS_close
 382:	48d5                	li	a7,21
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <kill>:
.global kill
kill:
 li a7, SYS_kill
 38a:	4899                	li	a7,6
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <exec>:
.global exec
exec:
 li a7, SYS_exec
 392:	489d                	li	a7,7
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <open>:
.global open
open:
 li a7, SYS_open
 39a:	48bd                	li	a7,15
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3a2:	48c5                	li	a7,17
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3aa:	48c9                	li	a7,18
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3b2:	48a1                	li	a7,8
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <link>:
.global link
link:
 li a7, SYS_link
 3ba:	48cd                	li	a7,19
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3c2:	48d1                	li	a7,20
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ca:	48a5                	li	a7,9
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3d2:	48a9                	li	a7,10
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3da:	48ad                	li	a7,11
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3e2:	48b1                	li	a7,12
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3ea:	48b5                	li	a7,13
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3f2:	48b9                	li	a7,14
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <ugetpid>:
.global ugetpid
ugetpid:
 li a7, SYS_ugetpid
 3fa:	48d9                	li	a7,22
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <pgaccess>:
.global pgaccess
pgaccess:
 li a7, SYS_pgaccess
 402:	48dd                	li	a7,23
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 40a:	1101                	addi	sp,sp,-32
 40c:	ec06                	sd	ra,24(sp)
 40e:	e822                	sd	s0,16(sp)
 410:	1000                	addi	s0,sp,32
 412:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 416:	4605                	li	a2,1
 418:	fef40593          	addi	a1,s0,-17
 41c:	f5fff0ef          	jal	ra,37a <write>
}
 420:	60e2                	ld	ra,24(sp)
 422:	6442                	ld	s0,16(sp)
 424:	6105                	addi	sp,sp,32
 426:	8082                	ret

0000000000000428 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 428:	715d                	addi	sp,sp,-80
 42a:	e486                	sd	ra,72(sp)
 42c:	e0a2                	sd	s0,64(sp)
 42e:	fc26                	sd	s1,56(sp)
 430:	f84a                	sd	s2,48(sp)
 432:	f44e                	sd	s3,40(sp)
 434:	0880                	addi	s0,sp,80
 436:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 438:	c299                	beqz	a3,43e <printint+0x16>
 43a:	0805c663          	bltz	a1,4c6 <printint+0x9e>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 43e:	2581                	sext.w	a1,a1
  neg = 0;
 440:	4881                	li	a7,0
 442:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
 446:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 448:	2601                	sext.w	a2,a2
 44a:	00000517          	auipc	a0,0x0
 44e:	51650513          	addi	a0,a0,1302 # 960 <digits>
 452:	883a                	mv	a6,a4
 454:	2705                	addiw	a4,a4,1
 456:	02c5f7bb          	remuw	a5,a1,a2
 45a:	1782                	slli	a5,a5,0x20
 45c:	9381                	srli	a5,a5,0x20
 45e:	97aa                	add	a5,a5,a0
 460:	0007c783          	lbu	a5,0(a5)
 464:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 468:	0005879b          	sext.w	a5,a1
 46c:	02c5d5bb          	divuw	a1,a1,a2
 470:	0685                	addi	a3,a3,1
 472:	fec7f0e3          	bgeu	a5,a2,452 <printint+0x2a>
  if(neg)
 476:	00088b63          	beqz	a7,48c <printint+0x64>
    buf[i++] = '-';
 47a:	fd040793          	addi	a5,s0,-48
 47e:	973e                	add	a4,a4,a5
 480:	02d00793          	li	a5,45
 484:	fef70423          	sb	a5,-24(a4)
 488:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 48c:	02e05663          	blez	a4,4b8 <printint+0x90>
 490:	fb840793          	addi	a5,s0,-72
 494:	00e78933          	add	s2,a5,a4
 498:	fff78993          	addi	s3,a5,-1
 49c:	99ba                	add	s3,s3,a4
 49e:	377d                	addiw	a4,a4,-1
 4a0:	1702                	slli	a4,a4,0x20
 4a2:	9301                	srli	a4,a4,0x20
 4a4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a8:	fff94583          	lbu	a1,-1(s2)
 4ac:	8526                	mv	a0,s1
 4ae:	f5dff0ef          	jal	ra,40a <putc>
  while(--i >= 0)
 4b2:	197d                	addi	s2,s2,-1
 4b4:	ff391ae3          	bne	s2,s3,4a8 <printint+0x80>
}
 4b8:	60a6                	ld	ra,72(sp)
 4ba:	6406                	ld	s0,64(sp)
 4bc:	74e2                	ld	s1,56(sp)
 4be:	7942                	ld	s2,48(sp)
 4c0:	79a2                	ld	s3,40(sp)
 4c2:	6161                	addi	sp,sp,80
 4c4:	8082                	ret
    x = -xx;
 4c6:	40b005bb          	negw	a1,a1
    neg = 1;
 4ca:	4885                	li	a7,1
    x = -xx;
 4cc:	bf9d                	j	442 <printint+0x1a>

00000000000004ce <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ce:	7119                	addi	sp,sp,-128
 4d0:	fc86                	sd	ra,120(sp)
 4d2:	f8a2                	sd	s0,112(sp)
 4d4:	f4a6                	sd	s1,104(sp)
 4d6:	f0ca                	sd	s2,96(sp)
 4d8:	ecce                	sd	s3,88(sp)
 4da:	e8d2                	sd	s4,80(sp)
 4dc:	e4d6                	sd	s5,72(sp)
 4de:	e0da                	sd	s6,64(sp)
 4e0:	fc5e                	sd	s7,56(sp)
 4e2:	f862                	sd	s8,48(sp)
 4e4:	f466                	sd	s9,40(sp)
 4e6:	f06a                	sd	s10,32(sp)
 4e8:	ec6e                	sd	s11,24(sp)
 4ea:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ec:	0005c903          	lbu	s2,0(a1)
 4f0:	22090e63          	beqz	s2,72c <vprintf+0x25e>
 4f4:	8b2a                	mv	s6,a0
 4f6:	8a2e                	mv	s4,a1
 4f8:	8bb2                	mv	s7,a2
  state = 0;
 4fa:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4fc:	4481                	li	s1,0
 4fe:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 500:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 504:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 508:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 50c:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 510:	00000c97          	auipc	s9,0x0
 514:	450c8c93          	addi	s9,s9,1104 # 960 <digits>
 518:	a005                	j	538 <vprintf+0x6a>
        putc(fd, c0);
 51a:	85ca                	mv	a1,s2
 51c:	855a                	mv	a0,s6
 51e:	eedff0ef          	jal	ra,40a <putc>
 522:	a019                	j	528 <vprintf+0x5a>
    } else if(state == '%'){
 524:	03598263          	beq	s3,s5,548 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 528:	2485                	addiw	s1,s1,1
 52a:	8726                	mv	a4,s1
 52c:	009a07b3          	add	a5,s4,s1
 530:	0007c903          	lbu	s2,0(a5)
 534:	1e090c63          	beqz	s2,72c <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
 538:	0009079b          	sext.w	a5,s2
    if(state == 0){
 53c:	fe0994e3          	bnez	s3,524 <vprintf+0x56>
      if(c0 == '%'){
 540:	fd579de3          	bne	a5,s5,51a <vprintf+0x4c>
        state = '%';
 544:	89be                	mv	s3,a5
 546:	b7cd                	j	528 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
 548:	cfa5                	beqz	a5,5c0 <vprintf+0xf2>
 54a:	00ea06b3          	add	a3,s4,a4
 54e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 552:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 554:	c681                	beqz	a3,55c <vprintf+0x8e>
 556:	9752                	add	a4,a4,s4
 558:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 55c:	03878a63          	beq	a5,s8,590 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 560:	05a78463          	beq	a5,s10,5a8 <vprintf+0xda>
      } else if(c0 == 'u'){
 564:	0db78763          	beq	a5,s11,632 <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 568:	07800713          	li	a4,120
 56c:	10e78963          	beq	a5,a4,67e <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 570:	07000713          	li	a4,112
 574:	12e78e63          	beq	a5,a4,6b0 <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 578:	07300713          	li	a4,115
 57c:	16e78b63          	beq	a5,a4,6f2 <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 580:	05579063          	bne	a5,s5,5c0 <vprintf+0xf2>
        putc(fd, '%');
 584:	85d6                	mv	a1,s5
 586:	855a                	mv	a0,s6
 588:	e83ff0ef          	jal	ra,40a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 58c:	4981                	li	s3,0
 58e:	bf69                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
 590:	008b8913          	addi	s2,s7,8
 594:	4685                	li	a3,1
 596:	4629                	li	a2,10
 598:	000ba583          	lw	a1,0(s7)
 59c:	855a                	mv	a0,s6
 59e:	e8bff0ef          	jal	ra,428 <printint>
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b749                	j	528 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	03868663          	beq	a3,s8,5d4 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ac:	05a68163          	beq	a3,s10,5ee <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
 5b0:	09b68d63          	beq	a3,s11,64a <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5b4:	03a68f63          	beq	a3,s10,5f2 <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
 5b8:	07800793          	li	a5,120
 5bc:	0cf68d63          	beq	a3,a5,696 <vprintf+0x1c8>
        putc(fd, '%');
 5c0:	85d6                	mv	a1,s5
 5c2:	855a                	mv	a0,s6
 5c4:	e47ff0ef          	jal	ra,40a <putc>
        putc(fd, c0);
 5c8:	85ca                	mv	a1,s2
 5ca:	855a                	mv	a0,s6
 5cc:	e3fff0ef          	jal	ra,40a <putc>
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	bf99                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000bb583          	ld	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	e47ff0ef          	jal	ra,428 <printint>
        i += 1;
 5e6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
        i += 1;
 5ec:	bf35                	j	528 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5ee:	03860563          	beq	a2,s8,618 <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5f2:	07b60963          	beq	a2,s11,664 <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5f6:	07800793          	li	a5,120
 5fa:	fcf613e3          	bne	a2,a5,5c0 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4641                	li	a2,16
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	e1dff0ef          	jal	ra,428 <printint>
        i += 2;
 610:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 2;
 616:	bf09                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 618:	008b8913          	addi	s2,s7,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e03ff0ef          	jal	ra,428 <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	bde5                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4629                	li	a2,10
 63a:	000ba583          	lw	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	de9ff0ef          	jal	ra,428 <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	b5c5                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	dd1ff0ef          	jal	ra,428 <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	b5d9                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 664:	008b8913          	addi	s2,s7,8
 668:	4681                	li	a3,0
 66a:	4629                	li	a2,10
 66c:	000bb583          	ld	a1,0(s7)
 670:	855a                	mv	a0,s6
 672:	db7ff0ef          	jal	ra,428 <printint>
        i += 2;
 676:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	8bca                	mv	s7,s2
      state = 0;
 67a:	4981                	li	s3,0
        i += 2;
 67c:	b575                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
 67e:	008b8913          	addi	s2,s7,8
 682:	4681                	li	a3,0
 684:	4641                	li	a2,16
 686:	000ba583          	lw	a1,0(s7)
 68a:	855a                	mv	a0,s6
 68c:	d9dff0ef          	jal	ra,428 <printint>
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
 694:	bd51                	j	528 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 696:	008b8913          	addi	s2,s7,8
 69a:	4681                	li	a3,0
 69c:	4641                	li	a2,16
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	d85ff0ef          	jal	ra,428 <printint>
        i += 1;
 6a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 1;
 6ae:	bdad                	j	528 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
 6b0:	008b8793          	addi	a5,s7,8
 6b4:	f8f43423          	sd	a5,-120(s0)
 6b8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6bc:	03000593          	li	a1,48
 6c0:	855a                	mv	a0,s6
 6c2:	d49ff0ef          	jal	ra,40a <putc>
  putc(fd, 'x');
 6c6:	07800593          	li	a1,120
 6ca:	855a                	mv	a0,s6
 6cc:	d3fff0ef          	jal	ra,40a <putc>
 6d0:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6d2:	03c9d793          	srli	a5,s3,0x3c
 6d6:	97e6                	add	a5,a5,s9
 6d8:	0007c583          	lbu	a1,0(a5)
 6dc:	855a                	mv	a0,s6
 6de:	d2dff0ef          	jal	ra,40a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6e2:	0992                	slli	s3,s3,0x4
 6e4:	397d                	addiw	s2,s2,-1
 6e6:	fe0916e3          	bnez	s2,6d2 <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
 6ea:	f8843b83          	ld	s7,-120(s0)
      state = 0;
 6ee:	4981                	li	s3,0
 6f0:	bd25                	j	528 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
 6f2:	008b8993          	addi	s3,s7,8
 6f6:	000bb903          	ld	s2,0(s7)
 6fa:	00090f63          	beqz	s2,718 <vprintf+0x24a>
        for(; *s; s++)
 6fe:	00094583          	lbu	a1,0(s2)
 702:	c195                	beqz	a1,726 <vprintf+0x258>
          putc(fd, *s);
 704:	855a                	mv	a0,s6
 706:	d05ff0ef          	jal	ra,40a <putc>
        for(; *s; s++)
 70a:	0905                	addi	s2,s2,1
 70c:	00094583          	lbu	a1,0(s2)
 710:	f9f5                	bnez	a1,704 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 712:	8bce                	mv	s7,s3
      state = 0;
 714:	4981                	li	s3,0
 716:	bd09                	j	528 <vprintf+0x5a>
          s = "(null)";
 718:	00000917          	auipc	s2,0x0
 71c:	24090913          	addi	s2,s2,576 # 958 <malloc+0x12a>
        for(; *s; s++)
 720:	02800593          	li	a1,40
 724:	b7c5                	j	704 <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
 726:	8bce                	mv	s7,s3
      state = 0;
 728:	4981                	li	s3,0
 72a:	bbfd                	j	528 <vprintf+0x5a>
    }
  }
}
 72c:	70e6                	ld	ra,120(sp)
 72e:	7446                	ld	s0,112(sp)
 730:	74a6                	ld	s1,104(sp)
 732:	7906                	ld	s2,96(sp)
 734:	69e6                	ld	s3,88(sp)
 736:	6a46                	ld	s4,80(sp)
 738:	6aa6                	ld	s5,72(sp)
 73a:	6b06                	ld	s6,64(sp)
 73c:	7be2                	ld	s7,56(sp)
 73e:	7c42                	ld	s8,48(sp)
 740:	7ca2                	ld	s9,40(sp)
 742:	7d02                	ld	s10,32(sp)
 744:	6de2                	ld	s11,24(sp)
 746:	6109                	addi	sp,sp,128
 748:	8082                	ret

000000000000074a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74a:	715d                	addi	sp,sp,-80
 74c:	ec06                	sd	ra,24(sp)
 74e:	e822                	sd	s0,16(sp)
 750:	1000                	addi	s0,sp,32
 752:	e010                	sd	a2,0(s0)
 754:	e414                	sd	a3,8(s0)
 756:	e818                	sd	a4,16(s0)
 758:	ec1c                	sd	a5,24(s0)
 75a:	03043023          	sd	a6,32(s0)
 75e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 766:	8622                	mv	a2,s0
 768:	d67ff0ef          	jal	ra,4ce <vprintf>
}
 76c:	60e2                	ld	ra,24(sp)
 76e:	6442                	ld	s0,16(sp)
 770:	6161                	addi	sp,sp,80
 772:	8082                	ret

0000000000000774 <printf>:

void
printf(const char *fmt, ...)
{
 774:	711d                	addi	sp,sp,-96
 776:	ec06                	sd	ra,24(sp)
 778:	e822                	sd	s0,16(sp)
 77a:	1000                	addi	s0,sp,32
 77c:	e40c                	sd	a1,8(s0)
 77e:	e810                	sd	a2,16(s0)
 780:	ec14                	sd	a3,24(s0)
 782:	f018                	sd	a4,32(s0)
 784:	f41c                	sd	a5,40(s0)
 786:	03043823          	sd	a6,48(s0)
 78a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 78e:	00840613          	addi	a2,s0,8
 792:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 796:	85aa                	mv	a1,a0
 798:	4505                	li	a0,1
 79a:	d35ff0ef          	jal	ra,4ce <vprintf>
}
 79e:	60e2                	ld	ra,24(sp)
 7a0:	6442                	ld	s0,16(sp)
 7a2:	6125                	addi	sp,sp,96
 7a4:	8082                	ret

00000000000007a6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a6:	1141                	addi	sp,sp,-16
 7a8:	e422                	sd	s0,8(sp)
 7aa:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7ac:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b0:	00001797          	auipc	a5,0x1
 7b4:	8507b783          	ld	a5,-1968(a5) # 1000 <freep>
 7b8:	a805                	j	7e8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ba:	4618                	lw	a4,8(a2)
 7bc:	9db9                	addw	a1,a1,a4
 7be:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c2:	6398                	ld	a4,0(a5)
 7c4:	6318                	ld	a4,0(a4)
 7c6:	fee53823          	sd	a4,-16(a0)
 7ca:	a091                	j	80e <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7cc:	ff852703          	lw	a4,-8(a0)
 7d0:	9e39                	addw	a2,a2,a4
 7d2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7d4:	ff053703          	ld	a4,-16(a0)
 7d8:	e398                	sd	a4,0(a5)
 7da:	a099                	j	820 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e7e463          	bltu	a5,a4,7e6 <free+0x40>
 7e2:	00e6ea63          	bltu	a3,a4,7f6 <free+0x50>
{
 7e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	fed7fae3          	bgeu	a5,a3,7dc <free+0x36>
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e6e463          	bltu	a3,a4,7f6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	fee7eae3          	bltu	a5,a4,7e6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7f6:	ff852583          	lw	a1,-8(a0)
 7fa:	6390                	ld	a2,0(a5)
 7fc:	02059713          	slli	a4,a1,0x20
 800:	9301                	srli	a4,a4,0x20
 802:	0712                	slli	a4,a4,0x4
 804:	9736                	add	a4,a4,a3
 806:	fae60ae3          	beq	a2,a4,7ba <free+0x14>
    bp->s.ptr = p->s.ptr;
 80a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80e:	4790                	lw	a2,8(a5)
 810:	02061713          	slli	a4,a2,0x20
 814:	9301                	srli	a4,a4,0x20
 816:	0712                	slli	a4,a4,0x4
 818:	973e                	add	a4,a4,a5
 81a:	fae689e3          	beq	a3,a4,7cc <free+0x26>
  } else
    p->s.ptr = bp;
 81e:	e394                	sd	a3,0(a5)
  freep = p;
 820:	00000717          	auipc	a4,0x0
 824:	7ef73023          	sd	a5,2016(a4) # 1000 <freep>
}
 828:	6422                	ld	s0,8(sp)
 82a:	0141                	addi	sp,sp,16
 82c:	8082                	ret

000000000000082e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82e:	7139                	addi	sp,sp,-64
 830:	fc06                	sd	ra,56(sp)
 832:	f822                	sd	s0,48(sp)
 834:	f426                	sd	s1,40(sp)
 836:	f04a                	sd	s2,32(sp)
 838:	ec4e                	sd	s3,24(sp)
 83a:	e852                	sd	s4,16(sp)
 83c:	e456                	sd	s5,8(sp)
 83e:	e05a                	sd	s6,0(sp)
 840:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 842:	02051493          	slli	s1,a0,0x20
 846:	9081                	srli	s1,s1,0x20
 848:	04bd                	addi	s1,s1,15
 84a:	8091                	srli	s1,s1,0x4
 84c:	0014899b          	addiw	s3,s1,1
 850:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 852:	00000517          	auipc	a0,0x0
 856:	7ae53503          	ld	a0,1966(a0) # 1000 <freep>
 85a:	c515                	beqz	a0,886 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	02977f63          	bgeu	a4,s1,89e <malloc+0x70>
 864:	8a4e                	mv	s4,s3
 866:	0009871b          	sext.w	a4,s3
 86a:	6685                	lui	a3,0x1
 86c:	00d77363          	bgeu	a4,a3,872 <malloc+0x44>
 870:	6a05                	lui	s4,0x1
 872:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 876:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87a:	00000917          	auipc	s2,0x0
 87e:	78690913          	addi	s2,s2,1926 # 1000 <freep>
  if(p == (char*)-1)
 882:	5afd                	li	s5,-1
 884:	a0bd                	j	8f2 <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
 886:	00001797          	auipc	a5,0x1
 88a:	98a78793          	addi	a5,a5,-1654 # 1210 <base>
 88e:	00000717          	auipc	a4,0x0
 892:	76f73923          	sd	a5,1906(a4) # 1000 <freep>
 896:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 898:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89c:	b7e1                	j	864 <malloc+0x36>
      if(p->s.size == nunits)
 89e:	02e48b63          	beq	s1,a4,8d4 <malloc+0xa6>
        p->s.size -= nunits;
 8a2:	4137073b          	subw	a4,a4,s3
 8a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a8:	1702                	slli	a4,a4,0x20
 8aa:	9301                	srli	a4,a4,0x20
 8ac:	0712                	slli	a4,a4,0x4
 8ae:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b4:	00000717          	auipc	a4,0x0
 8b8:	74a73623          	sd	a0,1868(a4) # 1000 <freep>
      return (void*)(p + 1);
 8bc:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c0:	70e2                	ld	ra,56(sp)
 8c2:	7442                	ld	s0,48(sp)
 8c4:	74a2                	ld	s1,40(sp)
 8c6:	7902                	ld	s2,32(sp)
 8c8:	69e2                	ld	s3,24(sp)
 8ca:	6a42                	ld	s4,16(sp)
 8cc:	6aa2                	ld	s5,8(sp)
 8ce:	6b02                	ld	s6,0(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d4:	6398                	ld	a4,0(a5)
 8d6:	e118                	sd	a4,0(a0)
 8d8:	bff1                	j	8b4 <malloc+0x86>
  hp->s.size = nu;
 8da:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8de:	0541                	addi	a0,a0,16
 8e0:	ec7ff0ef          	jal	ra,7a6 <free>
  return freep;
 8e4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8e8:	dd61                	beqz	a0,8c0 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ea:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8ec:	4798                	lw	a4,8(a5)
 8ee:	fa9778e3          	bgeu	a4,s1,89e <malloc+0x70>
    if(p == freep)
 8f2:	00093703          	ld	a4,0(s2)
 8f6:	853e                	mv	a0,a5
 8f8:	fef719e3          	bne	a4,a5,8ea <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
 8fc:	8552                	mv	a0,s4
 8fe:	ae5ff0ef          	jal	ra,3e2 <sbrk>
  if(p == (char*)-1)
 902:	fd551ce3          	bne	a0,s5,8da <malloc+0xac>
        return 0;
 906:	4501                	li	a0,0
 908:	bf65                	j	8c0 <malloc+0x92>
