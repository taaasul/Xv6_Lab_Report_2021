
user/_mmaptest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <err>:

char* testname = "???";

void
err(char* why)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
  printf("mmaptest: %s failed: %s, pid=%d\n", testname, why, getpid());
   e:	00001917          	auipc	s2,0x1
  12:	3f293903          	ld	s2,1010(s2) # 1400 <testname>
  16:	00001097          	auipc	ra,0x1
  1a:	afe080e7          	jalr	-1282(ra) # b14 <getpid>
  1e:	86aa                	mv	a3,a0
  20:	8626                	mv	a2,s1
  22:	85ca                	mv	a1,s2
  24:	00001517          	auipc	a0,0x1
  28:	f9c50513          	addi	a0,a0,-100 # fc0 <malloc+0xe6>
  2c:	00001097          	auipc	ra,0x1
  30:	df0080e7          	jalr	-528(ra) # e1c <printf>
  exit(1);
  34:	4505                	li	a0,1
  36:	00001097          	auipc	ra,0x1
  3a:	a5e080e7          	jalr	-1442(ra) # a94 <exit>

000000000000003e <_v1>:
//
// check the content of the two mapped pages.
//
void
_v1(char* p)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  46:	4781                	li	a5,0
  int i;
  for (i = 0; i < PGSIZE * 2; i++) {
    if (i < PGSIZE + (PGSIZE / 2)) {
  48:	6685                	lui	a3,0x1
  4a:	7ff68693          	addi	a3,a3,2047 # 17ff <buf+0x3ef>
  for (i = 0; i < PGSIZE * 2; i++) {
  4e:	6889                	lui	a7,0x2
      if (p[i] != 'A') {
  50:	04100813          	li	a6,65
  54:	a811                	j	68 <_v1+0x2a>
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
        err("v1 mismatch (1)");
      }
    }
    else {
      if (p[i] != 0) {
  56:	00f50633          	add	a2,a0,a5
  5a:	00064603          	lbu	a2,0(a2)
  5e:	e221                	bnez	a2,9e <_v1+0x60>
  for (i = 0; i < PGSIZE * 2; i++) {
  60:	2705                	addiw	a4,a4,1
  62:	05175e63          	bge	a4,a7,be <_v1+0x80>
  66:	0785                	addi	a5,a5,1
  68:	0007871b          	sext.w	a4,a5
  6c:	85ba                	mv	a1,a4
    if (i < PGSIZE + (PGSIZE / 2)) {
  6e:	fee6c4e3          	blt	a3,a4,56 <_v1+0x18>
      if (p[i] != 'A') {
  72:	00f50733          	add	a4,a0,a5
  76:	00074603          	lbu	a2,0(a4)
  7a:	ff0606e3          	beq	a2,a6,66 <_v1+0x28>
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
  7e:	00001517          	auipc	a0,0x1
  82:	f6a50513          	addi	a0,a0,-150 # fe8 <malloc+0x10e>
  86:	00001097          	auipc	ra,0x1
  8a:	d96080e7          	jalr	-618(ra) # e1c <printf>
        err("v1 mismatch (1)");
  8e:	00001517          	auipc	a0,0x1
  92:	f8250513          	addi	a0,a0,-126 # 1010 <malloc+0x136>
  96:	00000097          	auipc	ra,0x0
  9a:	f6a080e7          	jalr	-150(ra) # 0 <err>
        printf("mismatch at %d, wanted zero, got 0x%x\n", i, p[i]);
  9e:	00001517          	auipc	a0,0x1
  a2:	f8250513          	addi	a0,a0,-126 # 1020 <malloc+0x146>
  a6:	00001097          	auipc	ra,0x1
  aa:	d76080e7          	jalr	-650(ra) # e1c <printf>
        err("v1 mismatch (2)");
  ae:	00001517          	auipc	a0,0x1
  b2:	f9a50513          	addi	a0,a0,-102 # 1048 <malloc+0x16e>
  b6:	00000097          	auipc	ra,0x0
  ba:	f4a080e7          	jalr	-182(ra) # 0 <err>
      }
    }
  }
}
  be:	60a2                	ld	ra,8(sp)
  c0:	6402                	ld	s0,0(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <makefile>:
// create a file to be mapped, containing
// 1.5 pages of 'A' and half a page of zeros.
//
void
makefile(const char* f)
{
  c6:	7179                	addi	sp,sp,-48
  c8:	f406                	sd	ra,40(sp)
  ca:	f022                	sd	s0,32(sp)
  cc:	ec26                	sd	s1,24(sp)
  ce:	e84a                	sd	s2,16(sp)
  d0:	e44e                	sd	s3,8(sp)
  d2:	1800                	addi	s0,sp,48
  d4:	84aa                	mv	s1,a0
  int i;
  int n = PGSIZE / BSIZE;

  unlink(f);
  d6:	00001097          	auipc	ra,0x1
  da:	a0e080e7          	jalr	-1522(ra) # ae4 <unlink>
  int fd = open(f, O_WRONLY | O_CREATE);
  de:	20100593          	li	a1,513
  e2:	8526                	mv	a0,s1
  e4:	00001097          	auipc	ra,0x1
  e8:	9f0080e7          	jalr	-1552(ra) # ad4 <open>
  if (fd == -1)
  ec:	57fd                	li	a5,-1
  ee:	06f50163          	beq	a0,a5,150 <makefile+0x8a>
  f2:	892a                	mv	s2,a0
    err("open");
  memset(buf, 'A', BSIZE);
  f4:	40000613          	li	a2,1024
  f8:	04100593          	li	a1,65
  fc:	00001517          	auipc	a0,0x1
 100:	31450513          	addi	a0,a0,788 # 1410 <buf>
 104:	00000097          	auipc	ra,0x0
 108:	78c080e7          	jalr	1932(ra) # 890 <memset>
 10c:	4499                	li	s1,6
  // write 1.5 page
  for (i = 0; i < n + n / 2; i++) {
    if (write(fd, buf, BSIZE) != BSIZE)
 10e:	00001997          	auipc	s3,0x1
 112:	30298993          	addi	s3,s3,770 # 1410 <buf>
 116:	40000613          	li	a2,1024
 11a:	85ce                	mv	a1,s3
 11c:	854a                	mv	a0,s2
 11e:	00001097          	auipc	ra,0x1
 122:	996080e7          	jalr	-1642(ra) # ab4 <write>
 126:	40000793          	li	a5,1024
 12a:	02f51b63          	bne	a0,a5,160 <makefile+0x9a>
  for (i = 0; i < n + n / 2; i++) {
 12e:	34fd                	addiw	s1,s1,-1
 130:	f0fd                	bnez	s1,116 <makefile+0x50>
      err("write 0 makefile");
  }
  if (close(fd) == -1)
 132:	854a                	mv	a0,s2
 134:	00001097          	auipc	ra,0x1
 138:	988080e7          	jalr	-1656(ra) # abc <close>
 13c:	57fd                	li	a5,-1
 13e:	02f50963          	beq	a0,a5,170 <makefile+0xaa>
    err("close");
}
 142:	70a2                	ld	ra,40(sp)
 144:	7402                	ld	s0,32(sp)
 146:	64e2                	ld	s1,24(sp)
 148:	6942                	ld	s2,16(sp)
 14a:	69a2                	ld	s3,8(sp)
 14c:	6145                	addi	sp,sp,48
 14e:	8082                	ret
    err("open");
 150:	00001517          	auipc	a0,0x1
 154:	f0850513          	addi	a0,a0,-248 # 1058 <malloc+0x17e>
 158:	00000097          	auipc	ra,0x0
 15c:	ea8080e7          	jalr	-344(ra) # 0 <err>
      err("write 0 makefile");
 160:	00001517          	auipc	a0,0x1
 164:	f0050513          	addi	a0,a0,-256 # 1060 <malloc+0x186>
 168:	00000097          	auipc	ra,0x0
 16c:	e98080e7          	jalr	-360(ra) # 0 <err>
    err("close");
 170:	00001517          	auipc	a0,0x1
 174:	f0850513          	addi	a0,a0,-248 # 1078 <malloc+0x19e>
 178:	00000097          	auipc	ra,0x0
 17c:	e88080e7          	jalr	-376(ra) # 0 <err>

0000000000000180 <mmap_test>:

void
mmap_test(void)
{
 180:	7139                	addi	sp,sp,-64
 182:	fc06                	sd	ra,56(sp)
 184:	f822                	sd	s0,48(sp)
 186:	f426                	sd	s1,40(sp)
 188:	f04a                	sd	s2,32(sp)
 18a:	ec4e                	sd	s3,24(sp)
 18c:	e852                	sd	s4,16(sp)
 18e:	0080                	addi	s0,sp,64
  int fd;
  int i;
  const char* const f = "mmap.dur";
  printf("mmap_test starting\n");
 190:	00001517          	auipc	a0,0x1
 194:	ef050513          	addi	a0,a0,-272 # 1080 <malloc+0x1a6>
 198:	00001097          	auipc	ra,0x1
 19c:	c84080e7          	jalr	-892(ra) # e1c <printf>
  testname = "mmap_test";
 1a0:	00001797          	auipc	a5,0x1
 1a4:	ef878793          	addi	a5,a5,-264 # 1098 <malloc+0x1be>
 1a8:	00001717          	auipc	a4,0x1
 1ac:	24f73c23          	sd	a5,600(a4) # 1400 <testname>
  //
  // create a file with known content, map it into memory, check that
  // the mapped memory has the same bytes as originally written to the
  // file.
  //
  makefile(f);
 1b0:	00001517          	auipc	a0,0x1
 1b4:	ef850513          	addi	a0,a0,-264 # 10a8 <malloc+0x1ce>
 1b8:	00000097          	auipc	ra,0x0
 1bc:	f0e080e7          	jalr	-242(ra) # c6 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
 1c0:	4581                	li	a1,0
 1c2:	00001517          	auipc	a0,0x1
 1c6:	ee650513          	addi	a0,a0,-282 # 10a8 <malloc+0x1ce>
 1ca:	00001097          	auipc	ra,0x1
 1ce:	90a080e7          	jalr	-1782(ra) # ad4 <open>
 1d2:	57fd                	li	a5,-1
 1d4:	30f50e63          	beq	a0,a5,4f0 <mmap_test+0x370>
 1d8:	84aa                	mv	s1,a0
    err("open");

  printf("test mmap read-only\n");
 1da:	00001517          	auipc	a0,0x1
 1de:	ede50513          	addi	a0,a0,-290 # 10b8 <malloc+0x1de>
 1e2:	00001097          	auipc	ra,0x1
 1e6:	c3a080e7          	jalr	-966(ra) # e1c <printf>

  char* p = mmap(0, PGSIZE * 2, PROT_READ, MAP_SHARED, fd, 0);
 1ea:	4781                	li	a5,0
 1ec:	8726                	mv	a4,s1
 1ee:	4685                	li	a3,1
 1f0:	4605                	li	a2,1
 1f2:	6589                	lui	a1,0x2
 1f4:	4501                	li	a0,0
 1f6:	00001097          	auipc	ra,0x1
 1fa:	93e080e7          	jalr	-1730(ra) # b34 <mmap>
 1fe:	892a                	mv	s2,a0
  if (p == MAP_FAILED)
 200:	57fd                	li	a5,-1
 202:	2ef50f63          	beq	a0,a5,500 <mmap_test+0x380>
    err("mmap (1)");
  _v1(p);
 206:	00000097          	auipc	ra,0x0
 20a:	e38080e7          	jalr	-456(ra) # 3e <_v1>
  if (munmap(p, PGSIZE * 2) == -1)
 20e:	6589                	lui	a1,0x2
 210:	854a                	mv	a0,s2
 212:	00001097          	auipc	ra,0x1
 216:	92a080e7          	jalr	-1750(ra) # b3c <munmap>
 21a:	57fd                	li	a5,-1
 21c:	2ef50a63          	beq	a0,a5,510 <mmap_test+0x390>
    err("munmap (1)");

  if (close(fd) == -1)
 220:	8526                	mv	a0,s1
 222:	00001097          	auipc	ra,0x1
 226:	89a080e7          	jalr	-1894(ra) # abc <close>
 22a:	57fd                	li	a5,-1
 22c:	2ef50a63          	beq	a0,a5,520 <mmap_test+0x3a0>
    err("close");

  printf("test mmap read-only: OK\n");
 230:	00001517          	auipc	a0,0x1
 234:	ec050513          	addi	a0,a0,-320 # 10f0 <malloc+0x216>
 238:	00001097          	auipc	ra,0x1
 23c:	be4080e7          	jalr	-1052(ra) # e1c <printf>

  printf("test mmap read/write\n");
 240:	00001517          	auipc	a0,0x1
 244:	ed050513          	addi	a0,a0,-304 # 1110 <malloc+0x236>
 248:	00001097          	auipc	ra,0x1
 24c:	bd4080e7          	jalr	-1068(ra) # e1c <printf>

  // check that mmap does allow read/write mapping of a
  // file opened read/write.
  if ((fd = open(f, O_RDWR)) == -1)
 250:	4589                	li	a1,2
 252:	00001517          	auipc	a0,0x1
 256:	e5650513          	addi	a0,a0,-426 # 10a8 <malloc+0x1ce>
 25a:	00001097          	auipc	ra,0x1
 25e:	87a080e7          	jalr	-1926(ra) # ad4 <open>
 262:	84aa                	mv	s1,a0
 264:	57fd                	li	a5,-1
 266:	2cf50563          	beq	a0,a5,530 <mmap_test+0x3b0>
    err("open");
  p = mmap(0, PGSIZE * 3, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
 26a:	4781                	li	a5,0
 26c:	872a                	mv	a4,a0
 26e:	4685                	li	a3,1
 270:	460d                	li	a2,3
 272:	658d                	lui	a1,0x3
 274:	4501                	li	a0,0
 276:	00001097          	auipc	ra,0x1
 27a:	8be080e7          	jalr	-1858(ra) # b34 <mmap>
 27e:	89aa                	mv	s3,a0
  if (p == MAP_FAILED)
 280:	57fd                	li	a5,-1
 282:	2af50f63          	beq	a0,a5,540 <mmap_test+0x3c0>
    err("mmap (3)");
  if (close(fd) == -1)
 286:	8526                	mv	a0,s1
 288:	00001097          	auipc	ra,0x1
 28c:	834080e7          	jalr	-1996(ra) # abc <close>
 290:	57fd                	li	a5,-1
 292:	2af50f63          	beq	a0,a5,550 <mmap_test+0x3d0>
    err("close");

  // check that the mapping still works after close(fd).
  _v1(p);
 296:	854e                	mv	a0,s3
 298:	00000097          	auipc	ra,0x0
 29c:	da6080e7          	jalr	-602(ra) # 3e <_v1>

  // write the mapped memory.
  for (i = 0; i < PGSIZE * 2; i++)
 2a0:	87ce                	mv	a5,s3
 2a2:	6709                	lui	a4,0x2
 2a4:	974e                	add	a4,a4,s3
    p[i] = 'Z';
 2a6:	05a00693          	li	a3,90
 2aa:	00d78023          	sb	a3,0(a5)
  for (i = 0; i < PGSIZE * 2; i++)
 2ae:	0785                	addi	a5,a5,1
 2b0:	fee79de3          	bne	a5,a4,2aa <mmap_test+0x12a>

  // unmap just the first two of three pages of mapped memory.
  if (munmap(p, PGSIZE * 2) == -1)
 2b4:	6589                	lui	a1,0x2
 2b6:	854e                	mv	a0,s3
 2b8:	00001097          	auipc	ra,0x1
 2bc:	884080e7          	jalr	-1916(ra) # b3c <munmap>
 2c0:	57fd                	li	a5,-1
 2c2:	28f50f63          	beq	a0,a5,560 <mmap_test+0x3e0>
    err("munmap (3)");

  printf("test mmap read/write: OK\n");
 2c6:	00001517          	auipc	a0,0x1
 2ca:	e8250513          	addi	a0,a0,-382 # 1148 <malloc+0x26e>
 2ce:	00001097          	auipc	ra,0x1
 2d2:	b4e080e7          	jalr	-1202(ra) # e1c <printf>

  printf("test mmap dirty\n");
 2d6:	00001517          	auipc	a0,0x1
 2da:	e9250513          	addi	a0,a0,-366 # 1168 <malloc+0x28e>
 2de:	00001097          	auipc	ra,0x1
 2e2:	b3e080e7          	jalr	-1218(ra) # e1c <printf>

  // check that the writes to the mapped memory were
  // written to the file.
  if ((fd = open(f, O_RDWR)) == -1)
 2e6:	4589                	li	a1,2
 2e8:	00001517          	auipc	a0,0x1
 2ec:	dc050513          	addi	a0,a0,-576 # 10a8 <malloc+0x1ce>
 2f0:	00000097          	auipc	ra,0x0
 2f4:	7e4080e7          	jalr	2020(ra) # ad4 <open>
 2f8:	892a                	mv	s2,a0
 2fa:	57fd                	li	a5,-1
 2fc:	6489                	lui	s1,0x2
 2fe:	80048493          	addi	s1,s1,-2048 # 1800 <buf+0x3f0>
    err("open");
  for (i = 0; i < PGSIZE + (PGSIZE / 2); i++) {
    char b;
    if (read(fd, &b, 1) != 1)
      err("read (1)");
    if (b != 'Z')
 302:	05a00a13          	li	s4,90
  if ((fd = open(f, O_RDWR)) == -1)
 306:	26f50563          	beq	a0,a5,570 <mmap_test+0x3f0>
    if (read(fd, &b, 1) != 1)
 30a:	4605                	li	a2,1
 30c:	fcf40593          	addi	a1,s0,-49
 310:	854a                	mv	a0,s2
 312:	00000097          	auipc	ra,0x0
 316:	79a080e7          	jalr	1946(ra) # aac <read>
 31a:	4785                	li	a5,1
 31c:	26f51263          	bne	a0,a5,580 <mmap_test+0x400>
    if (b != 'Z')
 320:	fcf44783          	lbu	a5,-49(s0)
 324:	27479663          	bne	a5,s4,590 <mmap_test+0x410>
  for (i = 0; i < PGSIZE + (PGSIZE / 2); i++) {
 328:	34fd                	addiw	s1,s1,-1
 32a:	f0e5                	bnez	s1,30a <mmap_test+0x18a>
      err("file does not contain modifications");
  }
  if (close(fd) == -1)
 32c:	854a                	mv	a0,s2
 32e:	00000097          	auipc	ra,0x0
 332:	78e080e7          	jalr	1934(ra) # abc <close>
 336:	57fd                	li	a5,-1
 338:	26f50463          	beq	a0,a5,5a0 <mmap_test+0x420>
    err("close");

  printf("test mmap dirty: OK\n");
 33c:	00001517          	auipc	a0,0x1
 340:	e7c50513          	addi	a0,a0,-388 # 11b8 <malloc+0x2de>
 344:	00001097          	auipc	ra,0x1
 348:	ad8080e7          	jalr	-1320(ra) # e1c <printf>

  printf("test not-mapped unmap\n");
 34c:	00001517          	auipc	a0,0x1
 350:	e8450513          	addi	a0,a0,-380 # 11d0 <malloc+0x2f6>
 354:	00001097          	auipc	ra,0x1
 358:	ac8080e7          	jalr	-1336(ra) # e1c <printf>

  // unmap the rest of the mapped memory.
  if (munmap(p + PGSIZE * 2, PGSIZE) == -1)
 35c:	6585                	lui	a1,0x1
 35e:	6509                	lui	a0,0x2
 360:	954e                	add	a0,a0,s3
 362:	00000097          	auipc	ra,0x0
 366:	7da080e7          	jalr	2010(ra) # b3c <munmap>
 36a:	57fd                	li	a5,-1
 36c:	24f50263          	beq	a0,a5,5b0 <mmap_test+0x430>
    err("munmap (4)");

  printf("test not-mapped unmap: OK\n");
 370:	00001517          	auipc	a0,0x1
 374:	e8850513          	addi	a0,a0,-376 # 11f8 <malloc+0x31e>
 378:	00001097          	auipc	ra,0x1
 37c:	aa4080e7          	jalr	-1372(ra) # e1c <printf>

  printf("test mmap two files\n");
 380:	00001517          	auipc	a0,0x1
 384:	e9850513          	addi	a0,a0,-360 # 1218 <malloc+0x33e>
 388:	00001097          	auipc	ra,0x1
 38c:	a94080e7          	jalr	-1388(ra) # e1c <printf>

  //
  // mmap two files at the same time.
  // offset the second to avoid deadlock in the kernel.
  //
  int fd1 = open("mmap1", O_RDWR | O_CREATE);
 390:	20200593          	li	a1,514
 394:	00001517          	auipc	a0,0x1
 398:	e9c50513          	addi	a0,a0,-356 # 1230 <malloc+0x356>
 39c:	00000097          	auipc	ra,0x0
 3a0:	738080e7          	jalr	1848(ra) # ad4 <open>
 3a4:	892a                	mv	s2,a0
  if (fd1 < 0)
 3a6:	20054d63          	bltz	a0,5c0 <mmap_test+0x440>
    err("open mmap1");
  if (write(fd1, "12345", 5) != 5)
 3aa:	4615                	li	a2,5
 3ac:	00001597          	auipc	a1,0x1
 3b0:	e9c58593          	addi	a1,a1,-356 # 1248 <malloc+0x36e>
 3b4:	00000097          	auipc	ra,0x0
 3b8:	700080e7          	jalr	1792(ra) # ab4 <write>
 3bc:	4795                	li	a5,5
 3be:	20f51963          	bne	a0,a5,5d0 <mmap_test+0x450>
    err("write mmap1");
  char* p1 = mmap(0, PGSIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd1, 0);
 3c2:	4781                	li	a5,0
 3c4:	874a                	mv	a4,s2
 3c6:	4685                	li	a3,1
 3c8:	460d                	li	a2,3
 3ca:	6585                	lui	a1,0x1
 3cc:	4501                	li	a0,0
 3ce:	00000097          	auipc	ra,0x0
 3d2:	766080e7          	jalr	1894(ra) # b34 <mmap>
 3d6:	8a2a                	mv	s4,a0
  if (p1 == MAP_FAILED)
 3d8:	57fd                	li	a5,-1
 3da:	20f50363          	beq	a0,a5,5e0 <mmap_test+0x460>
    err("mmap mmap1");

  int fd2 = open("mmap2", O_RDWR | O_CREATE);
 3de:	20200593          	li	a1,514
 3e2:	00001517          	auipc	a0,0x1
 3e6:	e8e50513          	addi	a0,a0,-370 # 1270 <malloc+0x396>
 3ea:	00000097          	auipc	ra,0x0
 3ee:	6ea080e7          	jalr	1770(ra) # ad4 <open>
 3f2:	84aa                	mv	s1,a0
  if (fd2 < 0)
 3f4:	1e054e63          	bltz	a0,5f0 <mmap_test+0x470>
    err("open mmap2");
  if (write(fd2, "67890", 5) != 5)
 3f8:	4615                	li	a2,5
 3fa:	00001597          	auipc	a1,0x1
 3fe:	e8e58593          	addi	a1,a1,-370 # 1288 <malloc+0x3ae>
 402:	00000097          	auipc	ra,0x0
 406:	6b2080e7          	jalr	1714(ra) # ab4 <write>
 40a:	4795                	li	a5,5
 40c:	1ef51a63          	bne	a0,a5,600 <mmap_test+0x480>
    err("write mmap2");
  char* p2 = mmap(0, PGSIZE, PROT_READ | PROT_WRITE, MAP_SHARED, fd2, 0);
 410:	4781                	li	a5,0
 412:	8726                	mv	a4,s1
 414:	4685                	li	a3,1
 416:	460d                	li	a2,3
 418:	6585                	lui	a1,0x1
 41a:	4501                	li	a0,0
 41c:	00000097          	auipc	ra,0x0
 420:	718080e7          	jalr	1816(ra) # b34 <mmap>
 424:	89aa                	mv	s3,a0
  if (p2 == MAP_FAILED)
 426:	57fd                	li	a5,-1
 428:	1ef50463          	beq	a0,a5,610 <mmap_test+0x490>
    err("mmap mmap2");

  if (memcmp(p1, "12345", 5) != 0)
 42c:	4615                	li	a2,5
 42e:	00001597          	auipc	a1,0x1
 432:	e1a58593          	addi	a1,a1,-486 # 1248 <malloc+0x36e>
 436:	8552                	mv	a0,s4
 438:	00000097          	auipc	ra,0x0
 43c:	602080e7          	jalr	1538(ra) # a3a <memcmp>
 440:	1e051063          	bnez	a0,620 <mmap_test+0x4a0>
    err("mmap1 mismatch");
  if (memcmp(p2, "67890", 5) != 0)
 444:	4615                	li	a2,5
 446:	00001597          	auipc	a1,0x1
 44a:	e4258593          	addi	a1,a1,-446 # 1288 <malloc+0x3ae>
 44e:	854e                	mv	a0,s3
 450:	00000097          	auipc	ra,0x0
 454:	5ea080e7          	jalr	1514(ra) # a3a <memcmp>
 458:	1c051c63          	bnez	a0,630 <mmap_test+0x4b0>
    err("mmap2 mismatch");

  munmap(p1, PGSIZE);
 45c:	6585                	lui	a1,0x1
 45e:	8552                	mv	a0,s4
 460:	00000097          	auipc	ra,0x0
 464:	6dc080e7          	jalr	1756(ra) # b3c <munmap>
  if (memcmp(p2, "67890", 5) != 0)
 468:	4615                	li	a2,5
 46a:	00001597          	auipc	a1,0x1
 46e:	e1e58593          	addi	a1,a1,-482 # 1288 <malloc+0x3ae>
 472:	854e                	mv	a0,s3
 474:	00000097          	auipc	ra,0x0
 478:	5c6080e7          	jalr	1478(ra) # a3a <memcmp>
 47c:	1c051263          	bnez	a0,640 <mmap_test+0x4c0>
    err("mmap2 mismatch (2)");
  munmap(p2, PGSIZE);
 480:	6585                	lui	a1,0x1
 482:	854e                	mv	a0,s3
 484:	00000097          	auipc	ra,0x0
 488:	6b8080e7          	jalr	1720(ra) # b3c <munmap>

  close(fd1);
 48c:	854a                	mv	a0,s2
 48e:	00000097          	auipc	ra,0x0
 492:	62e080e7          	jalr	1582(ra) # abc <close>
  close(fd2);
 496:	8526                	mv	a0,s1
 498:	00000097          	auipc	ra,0x0
 49c:	624080e7          	jalr	1572(ra) # abc <close>
  unlink("mmap1");
 4a0:	00001517          	auipc	a0,0x1
 4a4:	d9050513          	addi	a0,a0,-624 # 1230 <malloc+0x356>
 4a8:	00000097          	auipc	ra,0x0
 4ac:	63c080e7          	jalr	1596(ra) # ae4 <unlink>
  unlink("mmap2");
 4b0:	00001517          	auipc	a0,0x1
 4b4:	dc050513          	addi	a0,a0,-576 # 1270 <malloc+0x396>
 4b8:	00000097          	auipc	ra,0x0
 4bc:	62c080e7          	jalr	1580(ra) # ae4 <unlink>

  printf("test mmap two files: OK\n");
 4c0:	00001517          	auipc	a0,0x1
 4c4:	e2850513          	addi	a0,a0,-472 # 12e8 <malloc+0x40e>
 4c8:	00001097          	auipc	ra,0x1
 4cc:	954080e7          	jalr	-1708(ra) # e1c <printf>

  printf("mmap_test: ALL OK\n");
 4d0:	00001517          	auipc	a0,0x1
 4d4:	e3850513          	addi	a0,a0,-456 # 1308 <malloc+0x42e>
 4d8:	00001097          	auipc	ra,0x1
 4dc:	944080e7          	jalr	-1724(ra) # e1c <printf>
}
 4e0:	70e2                	ld	ra,56(sp)
 4e2:	7442                	ld	s0,48(sp)
 4e4:	74a2                	ld	s1,40(sp)
 4e6:	7902                	ld	s2,32(sp)
 4e8:	69e2                	ld	s3,24(sp)
 4ea:	6a42                	ld	s4,16(sp)
 4ec:	6121                	addi	sp,sp,64
 4ee:	8082                	ret
    err("open");
 4f0:	00001517          	auipc	a0,0x1
 4f4:	b6850513          	addi	a0,a0,-1176 # 1058 <malloc+0x17e>
 4f8:	00000097          	auipc	ra,0x0
 4fc:	b08080e7          	jalr	-1272(ra) # 0 <err>
    err("mmap (1)");
 500:	00001517          	auipc	a0,0x1
 504:	bd050513          	addi	a0,a0,-1072 # 10d0 <malloc+0x1f6>
 508:	00000097          	auipc	ra,0x0
 50c:	af8080e7          	jalr	-1288(ra) # 0 <err>
    err("munmap (1)");
 510:	00001517          	auipc	a0,0x1
 514:	bd050513          	addi	a0,a0,-1072 # 10e0 <malloc+0x206>
 518:	00000097          	auipc	ra,0x0
 51c:	ae8080e7          	jalr	-1304(ra) # 0 <err>
    err("close");
 520:	00001517          	auipc	a0,0x1
 524:	b5850513          	addi	a0,a0,-1192 # 1078 <malloc+0x19e>
 528:	00000097          	auipc	ra,0x0
 52c:	ad8080e7          	jalr	-1320(ra) # 0 <err>
    err("open");
 530:	00001517          	auipc	a0,0x1
 534:	b2850513          	addi	a0,a0,-1240 # 1058 <malloc+0x17e>
 538:	00000097          	auipc	ra,0x0
 53c:	ac8080e7          	jalr	-1336(ra) # 0 <err>
    err("mmap (3)");
 540:	00001517          	auipc	a0,0x1
 544:	be850513          	addi	a0,a0,-1048 # 1128 <malloc+0x24e>
 548:	00000097          	auipc	ra,0x0
 54c:	ab8080e7          	jalr	-1352(ra) # 0 <err>
    err("close");
 550:	00001517          	auipc	a0,0x1
 554:	b2850513          	addi	a0,a0,-1240 # 1078 <malloc+0x19e>
 558:	00000097          	auipc	ra,0x0
 55c:	aa8080e7          	jalr	-1368(ra) # 0 <err>
    err("munmap (3)");
 560:	00001517          	auipc	a0,0x1
 564:	bd850513          	addi	a0,a0,-1064 # 1138 <malloc+0x25e>
 568:	00000097          	auipc	ra,0x0
 56c:	a98080e7          	jalr	-1384(ra) # 0 <err>
    err("open");
 570:	00001517          	auipc	a0,0x1
 574:	ae850513          	addi	a0,a0,-1304 # 1058 <malloc+0x17e>
 578:	00000097          	auipc	ra,0x0
 57c:	a88080e7          	jalr	-1400(ra) # 0 <err>
      err("read (1)");
 580:	00001517          	auipc	a0,0x1
 584:	c0050513          	addi	a0,a0,-1024 # 1180 <malloc+0x2a6>
 588:	00000097          	auipc	ra,0x0
 58c:	a78080e7          	jalr	-1416(ra) # 0 <err>
      err("file does not contain modifications");
 590:	00001517          	auipc	a0,0x1
 594:	c0050513          	addi	a0,a0,-1024 # 1190 <malloc+0x2b6>
 598:	00000097          	auipc	ra,0x0
 59c:	a68080e7          	jalr	-1432(ra) # 0 <err>
    err("close");
 5a0:	00001517          	auipc	a0,0x1
 5a4:	ad850513          	addi	a0,a0,-1320 # 1078 <malloc+0x19e>
 5a8:	00000097          	auipc	ra,0x0
 5ac:	a58080e7          	jalr	-1448(ra) # 0 <err>
    err("munmap (4)");
 5b0:	00001517          	auipc	a0,0x1
 5b4:	c3850513          	addi	a0,a0,-968 # 11e8 <malloc+0x30e>
 5b8:	00000097          	auipc	ra,0x0
 5bc:	a48080e7          	jalr	-1464(ra) # 0 <err>
    err("open mmap1");
 5c0:	00001517          	auipc	a0,0x1
 5c4:	c7850513          	addi	a0,a0,-904 # 1238 <malloc+0x35e>
 5c8:	00000097          	auipc	ra,0x0
 5cc:	a38080e7          	jalr	-1480(ra) # 0 <err>
    err("write mmap1");
 5d0:	00001517          	auipc	a0,0x1
 5d4:	c8050513          	addi	a0,a0,-896 # 1250 <malloc+0x376>
 5d8:	00000097          	auipc	ra,0x0
 5dc:	a28080e7          	jalr	-1496(ra) # 0 <err>
    err("mmap mmap1");
 5e0:	00001517          	auipc	a0,0x1
 5e4:	c8050513          	addi	a0,a0,-896 # 1260 <malloc+0x386>
 5e8:	00000097          	auipc	ra,0x0
 5ec:	a18080e7          	jalr	-1512(ra) # 0 <err>
    err("open mmap2");
 5f0:	00001517          	auipc	a0,0x1
 5f4:	c8850513          	addi	a0,a0,-888 # 1278 <malloc+0x39e>
 5f8:	00000097          	auipc	ra,0x0
 5fc:	a08080e7          	jalr	-1528(ra) # 0 <err>
    err("write mmap2");
 600:	00001517          	auipc	a0,0x1
 604:	c9050513          	addi	a0,a0,-880 # 1290 <malloc+0x3b6>
 608:	00000097          	auipc	ra,0x0
 60c:	9f8080e7          	jalr	-1544(ra) # 0 <err>
    err("mmap mmap2");
 610:	00001517          	auipc	a0,0x1
 614:	c9050513          	addi	a0,a0,-880 # 12a0 <malloc+0x3c6>
 618:	00000097          	auipc	ra,0x0
 61c:	9e8080e7          	jalr	-1560(ra) # 0 <err>
    err("mmap1 mismatch");
 620:	00001517          	auipc	a0,0x1
 624:	c9050513          	addi	a0,a0,-880 # 12b0 <malloc+0x3d6>
 628:	00000097          	auipc	ra,0x0
 62c:	9d8080e7          	jalr	-1576(ra) # 0 <err>
    err("mmap2 mismatch");
 630:	00001517          	auipc	a0,0x1
 634:	c9050513          	addi	a0,a0,-880 # 12c0 <malloc+0x3e6>
 638:	00000097          	auipc	ra,0x0
 63c:	9c8080e7          	jalr	-1592(ra) # 0 <err>
    err("mmap2 mismatch (2)");
 640:	00001517          	auipc	a0,0x1
 644:	c9050513          	addi	a0,a0,-880 # 12d0 <malloc+0x3f6>
 648:	00000097          	auipc	ra,0x0
 64c:	9b8080e7          	jalr	-1608(ra) # 0 <err>

0000000000000650 <fork_test>:
// mmap a file, then fork.
// check that the child sees the mapped file.
//
void
fork_test(void)
{
 650:	7139                	addi	sp,sp,-64
 652:	fc06                	sd	ra,56(sp)
 654:	f822                	sd	s0,48(sp)
 656:	f426                	sd	s1,40(sp)
 658:	f04a                	sd	s2,32(sp)
 65a:	ec4e                	sd	s3,24(sp)
 65c:	0080                	addi	s0,sp,64
  int fd;
  int pid;
  const char* const f = "mmap.dur";

  printf("fork_test starting\n");
 65e:	00001517          	auipc	a0,0x1
 662:	cc250513          	addi	a0,a0,-830 # 1320 <malloc+0x446>
 666:	00000097          	auipc	ra,0x0
 66a:	7b6080e7          	jalr	1974(ra) # e1c <printf>
  testname = "fork_test";
 66e:	00001797          	auipc	a5,0x1
 672:	cca78793          	addi	a5,a5,-822 # 1338 <malloc+0x45e>
 676:	00001717          	auipc	a4,0x1
 67a:	d8f73523          	sd	a5,-630(a4) # 1400 <testname>

  // mmap the file twice.
  makefile(f);
 67e:	00001517          	auipc	a0,0x1
 682:	a2a50513          	addi	a0,a0,-1494 # 10a8 <malloc+0x1ce>
 686:	00000097          	auipc	ra,0x0
 68a:	a40080e7          	jalr	-1472(ra) # c6 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
 68e:	4581                	li	a1,0
 690:	00001517          	auipc	a0,0x1
 694:	a1850513          	addi	a0,a0,-1512 # 10a8 <malloc+0x1ce>
 698:	00000097          	auipc	ra,0x0
 69c:	43c080e7          	jalr	1084(ra) # ad4 <open>
 6a0:	57fd                	li	a5,-1
 6a2:	0af50f63          	beq	a0,a5,760 <fork_test+0x110>
 6a6:	84aa                	mv	s1,a0
    err("open");
  unlink(f);
 6a8:	00001517          	auipc	a0,0x1
 6ac:	a0050513          	addi	a0,a0,-1536 # 10a8 <malloc+0x1ce>
 6b0:	00000097          	auipc	ra,0x0
 6b4:	434080e7          	jalr	1076(ra) # ae4 <unlink>
  char* p1 = mmap(0, PGSIZE * 2, PROT_READ, MAP_SHARED, fd, 0);
 6b8:	4781                	li	a5,0
 6ba:	8726                	mv	a4,s1
 6bc:	4685                	li	a3,1
 6be:	4605                	li	a2,1
 6c0:	6589                	lui	a1,0x2
 6c2:	4501                	li	a0,0
 6c4:	00000097          	auipc	ra,0x0
 6c8:	470080e7          	jalr	1136(ra) # b34 <mmap>
 6cc:	892a                	mv	s2,a0
  if (p1 == MAP_FAILED)
 6ce:	57fd                	li	a5,-1
 6d0:	0af50063          	beq	a0,a5,770 <fork_test+0x120>
    err("mmap (4)");
  char* p2 = mmap(0, PGSIZE * 2, PROT_READ, MAP_SHARED, fd, 0);
 6d4:	4781                	li	a5,0
 6d6:	8726                	mv	a4,s1
 6d8:	4685                	li	a3,1
 6da:	4605                	li	a2,1
 6dc:	6589                	lui	a1,0x2
 6de:	4501                	li	a0,0
 6e0:	00000097          	auipc	ra,0x0
 6e4:	454080e7          	jalr	1108(ra) # b34 <mmap>
 6e8:	89aa                	mv	s3,a0
  if (p2 == MAP_FAILED)
 6ea:	57fd                	li	a5,-1
 6ec:	08f50a63          	beq	a0,a5,780 <fork_test+0x130>
    err("mmap (5)");

  // read just 2nd page.
  if (*(p1 + PGSIZE) != 'A')
 6f0:	6785                	lui	a5,0x1
 6f2:	97ca                	add	a5,a5,s2
 6f4:	0007c703          	lbu	a4,0(a5) # 1000 <malloc+0x126>
 6f8:	04100793          	li	a5,65
 6fc:	08f71a63          	bne	a4,a5,790 <fork_test+0x140>
    err("fork mismatch (1)");

  if ((pid = fork()) < 0)
 700:	00000097          	auipc	ra,0x0
 704:	38c080e7          	jalr	908(ra) # a8c <fork>
 708:	08054c63          	bltz	a0,7a0 <fork_test+0x150>
    err("fork");
  if (pid == 0) {
 70c:	c155                	beqz	a0,7b0 <fork_test+0x160>
    munmap(p2, PGSIZE * 2);
    exit(0);
  }

  int status;
  wait(&status);
 70e:	fcc40513          	addi	a0,s0,-52
 712:	00000097          	auipc	ra,0x0
 716:	38a080e7          	jalr	906(ra) # a9c <wait>
  if (status != 0)
 71a:	fcc42783          	lw	a5,-52(s0)
 71e:	efdd                	bnez	a5,7dc <fork_test+0x18c>
    err("fork_test failed in child");

  munmap(p1, PGSIZE * 2);
 720:	6589                	lui	a1,0x2
 722:	854a                	mv	a0,s2
 724:	00000097          	auipc	ra,0x0
 728:	418080e7          	jalr	1048(ra) # b3c <munmap>
  munmap(p2, PGSIZE * 2);
 72c:	6589                	lui	a1,0x2
 72e:	854e                	mv	a0,s3
 730:	00000097          	auipc	ra,0x0
 734:	40c080e7          	jalr	1036(ra) # b3c <munmap>
  close(fd);
 738:	8526                	mv	a0,s1
 73a:	00000097          	auipc	ra,0x0
 73e:	382080e7          	jalr	898(ra) # abc <close>

  printf("fork_test: OK\n");
 742:	00001517          	auipc	a0,0x1
 746:	c6650513          	addi	a0,a0,-922 # 13a8 <malloc+0x4ce>
 74a:	00000097          	auipc	ra,0x0
 74e:	6d2080e7          	jalr	1746(ra) # e1c <printf>
}
 752:	70e2                	ld	ra,56(sp)
 754:	7442                	ld	s0,48(sp)
 756:	74a2                	ld	s1,40(sp)
 758:	7902                	ld	s2,32(sp)
 75a:	69e2                	ld	s3,24(sp)
 75c:	6121                	addi	sp,sp,64
 75e:	8082                	ret
    err("open");
 760:	00001517          	auipc	a0,0x1
 764:	8f850513          	addi	a0,a0,-1800 # 1058 <malloc+0x17e>
 768:	00000097          	auipc	ra,0x0
 76c:	898080e7          	jalr	-1896(ra) # 0 <err>
    err("mmap (4)");
 770:	00001517          	auipc	a0,0x1
 774:	bd850513          	addi	a0,a0,-1064 # 1348 <malloc+0x46e>
 778:	00000097          	auipc	ra,0x0
 77c:	888080e7          	jalr	-1912(ra) # 0 <err>
    err("mmap (5)");
 780:	00001517          	auipc	a0,0x1
 784:	bd850513          	addi	a0,a0,-1064 # 1358 <malloc+0x47e>
 788:	00000097          	auipc	ra,0x0
 78c:	878080e7          	jalr	-1928(ra) # 0 <err>
    err("fork mismatch (1)");
 790:	00001517          	auipc	a0,0x1
 794:	bd850513          	addi	a0,a0,-1064 # 1368 <malloc+0x48e>
 798:	00000097          	auipc	ra,0x0
 79c:	868080e7          	jalr	-1944(ra) # 0 <err>
    err("fork");
 7a0:	00001517          	auipc	a0,0x1
 7a4:	be050513          	addi	a0,a0,-1056 # 1380 <malloc+0x4a6>
 7a8:	00000097          	auipc	ra,0x0
 7ac:	858080e7          	jalr	-1960(ra) # 0 <err>
    _v1(p1);
 7b0:	854a                	mv	a0,s2
 7b2:	00000097          	auipc	ra,0x0
 7b6:	88c080e7          	jalr	-1908(ra) # 3e <_v1>
    munmap(p1, PGSIZE * 2);
 7ba:	6589                	lui	a1,0x2
 7bc:	854a                	mv	a0,s2
 7be:	00000097          	auipc	ra,0x0
 7c2:	37e080e7          	jalr	894(ra) # b3c <munmap>
    munmap(p2, PGSIZE * 2);
 7c6:	6589                	lui	a1,0x2
 7c8:	854e                	mv	a0,s3
 7ca:	00000097          	auipc	ra,0x0
 7ce:	372080e7          	jalr	882(ra) # b3c <munmap>
    exit(0);
 7d2:	4501                	li	a0,0
 7d4:	00000097          	auipc	ra,0x0
 7d8:	2c0080e7          	jalr	704(ra) # a94 <exit>
    err("fork_test failed in child");
 7dc:	00001517          	auipc	a0,0x1
 7e0:	bac50513          	addi	a0,a0,-1108 # 1388 <malloc+0x4ae>
 7e4:	00000097          	auipc	ra,0x0
 7e8:	81c080e7          	jalr	-2020(ra) # 0 <err>

00000000000007ec <main>:
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e406                	sd	ra,8(sp)
 7f0:	e022                	sd	s0,0(sp)
 7f2:	0800                	addi	s0,sp,16
  mmap_test();
 7f4:	00000097          	auipc	ra,0x0
 7f8:	98c080e7          	jalr	-1652(ra) # 180 <mmap_test>
  fork_test();
 7fc:	00000097          	auipc	ra,0x0
 800:	e54080e7          	jalr	-428(ra) # 650 <fork_test>
  printf("mmaptest: all tests succeeded\n");
 804:	00001517          	auipc	a0,0x1
 808:	bb450513          	addi	a0,a0,-1100 # 13b8 <malloc+0x4de>
 80c:	00000097          	auipc	ra,0x0
 810:	610080e7          	jalr	1552(ra) # e1c <printf>
  exit(0);
 814:	4501                	li	a0,0
 816:	00000097          	auipc	ra,0x0
 81a:	27e080e7          	jalr	638(ra) # a94 <exit>

000000000000081e <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 81e:	1141                	addi	sp,sp,-16
 820:	e422                	sd	s0,8(sp)
 822:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 824:	87aa                	mv	a5,a0
 826:	0585                	addi	a1,a1,1
 828:	0785                	addi	a5,a5,1
 82a:	fff5c703          	lbu	a4,-1(a1) # 1fff <__global_pointer$+0x406>
 82e:	fee78fa3          	sb	a4,-1(a5)
 832:	fb75                	bnez	a4,826 <strcpy+0x8>
    ;
  return os;
}
 834:	6422                	ld	s0,8(sp)
 836:	0141                	addi	sp,sp,16
 838:	8082                	ret

000000000000083a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 83a:	1141                	addi	sp,sp,-16
 83c:	e422                	sd	s0,8(sp)
 83e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 840:	00054783          	lbu	a5,0(a0)
 844:	cb91                	beqz	a5,858 <strcmp+0x1e>
 846:	0005c703          	lbu	a4,0(a1)
 84a:	00f71763          	bne	a4,a5,858 <strcmp+0x1e>
    p++, q++;
 84e:	0505                	addi	a0,a0,1
 850:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 852:	00054783          	lbu	a5,0(a0)
 856:	fbe5                	bnez	a5,846 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 858:	0005c503          	lbu	a0,0(a1)
}
 85c:	40a7853b          	subw	a0,a5,a0
 860:	6422                	ld	s0,8(sp)
 862:	0141                	addi	sp,sp,16
 864:	8082                	ret

0000000000000866 <strlen>:

uint
strlen(const char *s)
{
 866:	1141                	addi	sp,sp,-16
 868:	e422                	sd	s0,8(sp)
 86a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 86c:	00054783          	lbu	a5,0(a0)
 870:	cf91                	beqz	a5,88c <strlen+0x26>
 872:	0505                	addi	a0,a0,1
 874:	87aa                	mv	a5,a0
 876:	4685                	li	a3,1
 878:	9e89                	subw	a3,a3,a0
 87a:	00f6853b          	addw	a0,a3,a5
 87e:	0785                	addi	a5,a5,1
 880:	fff7c703          	lbu	a4,-1(a5)
 884:	fb7d                	bnez	a4,87a <strlen+0x14>
    ;
  return n;
}
 886:	6422                	ld	s0,8(sp)
 888:	0141                	addi	sp,sp,16
 88a:	8082                	ret
  for(n = 0; s[n]; n++)
 88c:	4501                	li	a0,0
 88e:	bfe5                	j	886 <strlen+0x20>

0000000000000890 <memset>:

void*
memset(void *dst, int c, uint n)
{
 890:	1141                	addi	sp,sp,-16
 892:	e422                	sd	s0,8(sp)
 894:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 896:	ce09                	beqz	a2,8b0 <memset+0x20>
 898:	87aa                	mv	a5,a0
 89a:	fff6071b          	addiw	a4,a2,-1
 89e:	1702                	slli	a4,a4,0x20
 8a0:	9301                	srli	a4,a4,0x20
 8a2:	0705                	addi	a4,a4,1
 8a4:	972a                	add	a4,a4,a0
    cdst[i] = c;
 8a6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 8aa:	0785                	addi	a5,a5,1
 8ac:	fee79de3          	bne	a5,a4,8a6 <memset+0x16>
  }
  return dst;
}
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	addi	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <strchr>:

char*
strchr(const char *s, char c)
{
 8b6:	1141                	addi	sp,sp,-16
 8b8:	e422                	sd	s0,8(sp)
 8ba:	0800                	addi	s0,sp,16
  for(; *s; s++)
 8bc:	00054783          	lbu	a5,0(a0)
 8c0:	cb99                	beqz	a5,8d6 <strchr+0x20>
    if(*s == c)
 8c2:	00f58763          	beq	a1,a5,8d0 <strchr+0x1a>
  for(; *s; s++)
 8c6:	0505                	addi	a0,a0,1
 8c8:	00054783          	lbu	a5,0(a0)
 8cc:	fbfd                	bnez	a5,8c2 <strchr+0xc>
      return (char*)s;
  return 0;
 8ce:	4501                	li	a0,0
}
 8d0:	6422                	ld	s0,8(sp)
 8d2:	0141                	addi	sp,sp,16
 8d4:	8082                	ret
  return 0;
 8d6:	4501                	li	a0,0
 8d8:	bfe5                	j	8d0 <strchr+0x1a>

00000000000008da <gets>:

char*
gets(char *buf, int max)
{
 8da:	711d                	addi	sp,sp,-96
 8dc:	ec86                	sd	ra,88(sp)
 8de:	e8a2                	sd	s0,80(sp)
 8e0:	e4a6                	sd	s1,72(sp)
 8e2:	e0ca                	sd	s2,64(sp)
 8e4:	fc4e                	sd	s3,56(sp)
 8e6:	f852                	sd	s4,48(sp)
 8e8:	f456                	sd	s5,40(sp)
 8ea:	f05a                	sd	s6,32(sp)
 8ec:	ec5e                	sd	s7,24(sp)
 8ee:	1080                	addi	s0,sp,96
 8f0:	8baa                	mv	s7,a0
 8f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 8f4:	892a                	mv	s2,a0
 8f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 8f8:	4aa9                	li	s5,10
 8fa:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 8fc:	89a6                	mv	s3,s1
 8fe:	2485                	addiw	s1,s1,1
 900:	0344d863          	bge	s1,s4,930 <gets+0x56>
    cc = read(0, &c, 1);
 904:	4605                	li	a2,1
 906:	faf40593          	addi	a1,s0,-81
 90a:	4501                	li	a0,0
 90c:	00000097          	auipc	ra,0x0
 910:	1a0080e7          	jalr	416(ra) # aac <read>
    if(cc < 1)
 914:	00a05e63          	blez	a0,930 <gets+0x56>
    buf[i++] = c;
 918:	faf44783          	lbu	a5,-81(s0)
 91c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 920:	01578763          	beq	a5,s5,92e <gets+0x54>
 924:	0905                	addi	s2,s2,1
 926:	fd679be3          	bne	a5,s6,8fc <gets+0x22>
  for(i=0; i+1 < max; ){
 92a:	89a6                	mv	s3,s1
 92c:	a011                	j	930 <gets+0x56>
 92e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 930:	99de                	add	s3,s3,s7
 932:	00098023          	sb	zero,0(s3)
  return buf;
}
 936:	855e                	mv	a0,s7
 938:	60e6                	ld	ra,88(sp)
 93a:	6446                	ld	s0,80(sp)
 93c:	64a6                	ld	s1,72(sp)
 93e:	6906                	ld	s2,64(sp)
 940:	79e2                	ld	s3,56(sp)
 942:	7a42                	ld	s4,48(sp)
 944:	7aa2                	ld	s5,40(sp)
 946:	7b02                	ld	s6,32(sp)
 948:	6be2                	ld	s7,24(sp)
 94a:	6125                	addi	sp,sp,96
 94c:	8082                	ret

000000000000094e <stat>:

int
stat(const char *n, struct stat *st)
{
 94e:	1101                	addi	sp,sp,-32
 950:	ec06                	sd	ra,24(sp)
 952:	e822                	sd	s0,16(sp)
 954:	e426                	sd	s1,8(sp)
 956:	e04a                	sd	s2,0(sp)
 958:	1000                	addi	s0,sp,32
 95a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 95c:	4581                	li	a1,0
 95e:	00000097          	auipc	ra,0x0
 962:	176080e7          	jalr	374(ra) # ad4 <open>
  if(fd < 0)
 966:	02054563          	bltz	a0,990 <stat+0x42>
 96a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 96c:	85ca                	mv	a1,s2
 96e:	00000097          	auipc	ra,0x0
 972:	17e080e7          	jalr	382(ra) # aec <fstat>
 976:	892a                	mv	s2,a0
  close(fd);
 978:	8526                	mv	a0,s1
 97a:	00000097          	auipc	ra,0x0
 97e:	142080e7          	jalr	322(ra) # abc <close>
  return r;
}
 982:	854a                	mv	a0,s2
 984:	60e2                	ld	ra,24(sp)
 986:	6442                	ld	s0,16(sp)
 988:	64a2                	ld	s1,8(sp)
 98a:	6902                	ld	s2,0(sp)
 98c:	6105                	addi	sp,sp,32
 98e:	8082                	ret
    return -1;
 990:	597d                	li	s2,-1
 992:	bfc5                	j	982 <stat+0x34>

0000000000000994 <atoi>:

int
atoi(const char *s)
{
 994:	1141                	addi	sp,sp,-16
 996:	e422                	sd	s0,8(sp)
 998:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 99a:	00054603          	lbu	a2,0(a0)
 99e:	fd06079b          	addiw	a5,a2,-48
 9a2:	0ff7f793          	andi	a5,a5,255
 9a6:	4725                	li	a4,9
 9a8:	02f76963          	bltu	a4,a5,9da <atoi+0x46>
 9ac:	86aa                	mv	a3,a0
  n = 0;
 9ae:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 9b0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 9b2:	0685                	addi	a3,a3,1
 9b4:	0025179b          	slliw	a5,a0,0x2
 9b8:	9fa9                	addw	a5,a5,a0
 9ba:	0017979b          	slliw	a5,a5,0x1
 9be:	9fb1                	addw	a5,a5,a2
 9c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 9c4:	0006c603          	lbu	a2,0(a3)
 9c8:	fd06071b          	addiw	a4,a2,-48
 9cc:	0ff77713          	andi	a4,a4,255
 9d0:	fee5f1e3          	bgeu	a1,a4,9b2 <atoi+0x1e>
  return n;
}
 9d4:	6422                	ld	s0,8(sp)
 9d6:	0141                	addi	sp,sp,16
 9d8:	8082                	ret
  n = 0;
 9da:	4501                	li	a0,0
 9dc:	bfe5                	j	9d4 <atoi+0x40>

00000000000009de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 9de:	1141                	addi	sp,sp,-16
 9e0:	e422                	sd	s0,8(sp)
 9e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 9e4:	02b57663          	bgeu	a0,a1,a10 <memmove+0x32>
    while(n-- > 0)
 9e8:	02c05163          	blez	a2,a0a <memmove+0x2c>
 9ec:	fff6079b          	addiw	a5,a2,-1
 9f0:	1782                	slli	a5,a5,0x20
 9f2:	9381                	srli	a5,a5,0x20
 9f4:	0785                	addi	a5,a5,1
 9f6:	97aa                	add	a5,a5,a0
  dst = vdst;
 9f8:	872a                	mv	a4,a0
      *dst++ = *src++;
 9fa:	0585                	addi	a1,a1,1
 9fc:	0705                	addi	a4,a4,1
 9fe:	fff5c683          	lbu	a3,-1(a1)
 a02:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 a06:	fee79ae3          	bne	a5,a4,9fa <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 a0a:	6422                	ld	s0,8(sp)
 a0c:	0141                	addi	sp,sp,16
 a0e:	8082                	ret
    dst += n;
 a10:	00c50733          	add	a4,a0,a2
    src += n;
 a14:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 a16:	fec05ae3          	blez	a2,a0a <memmove+0x2c>
 a1a:	fff6079b          	addiw	a5,a2,-1
 a1e:	1782                	slli	a5,a5,0x20
 a20:	9381                	srli	a5,a5,0x20
 a22:	fff7c793          	not	a5,a5
 a26:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 a28:	15fd                	addi	a1,a1,-1
 a2a:	177d                	addi	a4,a4,-1
 a2c:	0005c683          	lbu	a3,0(a1)
 a30:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 a34:	fee79ae3          	bne	a5,a4,a28 <memmove+0x4a>
 a38:	bfc9                	j	a0a <memmove+0x2c>

0000000000000a3a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 a3a:	1141                	addi	sp,sp,-16
 a3c:	e422                	sd	s0,8(sp)
 a3e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 a40:	ca05                	beqz	a2,a70 <memcmp+0x36>
 a42:	fff6069b          	addiw	a3,a2,-1
 a46:	1682                	slli	a3,a3,0x20
 a48:	9281                	srli	a3,a3,0x20
 a4a:	0685                	addi	a3,a3,1
 a4c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 a4e:	00054783          	lbu	a5,0(a0)
 a52:	0005c703          	lbu	a4,0(a1)
 a56:	00e79863          	bne	a5,a4,a66 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 a5a:	0505                	addi	a0,a0,1
    p2++;
 a5c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 a5e:	fed518e3          	bne	a0,a3,a4e <memcmp+0x14>
  }
  return 0;
 a62:	4501                	li	a0,0
 a64:	a019                	j	a6a <memcmp+0x30>
      return *p1 - *p2;
 a66:	40e7853b          	subw	a0,a5,a4
}
 a6a:	6422                	ld	s0,8(sp)
 a6c:	0141                	addi	sp,sp,16
 a6e:	8082                	ret
  return 0;
 a70:	4501                	li	a0,0
 a72:	bfe5                	j	a6a <memcmp+0x30>

0000000000000a74 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 a74:	1141                	addi	sp,sp,-16
 a76:	e406                	sd	ra,8(sp)
 a78:	e022                	sd	s0,0(sp)
 a7a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 a7c:	00000097          	auipc	ra,0x0
 a80:	f62080e7          	jalr	-158(ra) # 9de <memmove>
}
 a84:	60a2                	ld	ra,8(sp)
 a86:	6402                	ld	s0,0(sp)
 a88:	0141                	addi	sp,sp,16
 a8a:	8082                	ret

0000000000000a8c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 a8c:	4885                	li	a7,1
 ecall
 a8e:	00000073          	ecall
 ret
 a92:	8082                	ret

0000000000000a94 <exit>:
.global exit
exit:
 li a7, SYS_exit
 a94:	4889                	li	a7,2
 ecall
 a96:	00000073          	ecall
 ret
 a9a:	8082                	ret

0000000000000a9c <wait>:
.global wait
wait:
 li a7, SYS_wait
 a9c:	488d                	li	a7,3
 ecall
 a9e:	00000073          	ecall
 ret
 aa2:	8082                	ret

0000000000000aa4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 aa4:	4891                	li	a7,4
 ecall
 aa6:	00000073          	ecall
 ret
 aaa:	8082                	ret

0000000000000aac <read>:
.global read
read:
 li a7, SYS_read
 aac:	4895                	li	a7,5
 ecall
 aae:	00000073          	ecall
 ret
 ab2:	8082                	ret

0000000000000ab4 <write>:
.global write
write:
 li a7, SYS_write
 ab4:	48c1                	li	a7,16
 ecall
 ab6:	00000073          	ecall
 ret
 aba:	8082                	ret

0000000000000abc <close>:
.global close
close:
 li a7, SYS_close
 abc:	48d5                	li	a7,21
 ecall
 abe:	00000073          	ecall
 ret
 ac2:	8082                	ret

0000000000000ac4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 ac4:	4899                	li	a7,6
 ecall
 ac6:	00000073          	ecall
 ret
 aca:	8082                	ret

0000000000000acc <exec>:
.global exec
exec:
 li a7, SYS_exec
 acc:	489d                	li	a7,7
 ecall
 ace:	00000073          	ecall
 ret
 ad2:	8082                	ret

0000000000000ad4 <open>:
.global open
open:
 li a7, SYS_open
 ad4:	48bd                	li	a7,15
 ecall
 ad6:	00000073          	ecall
 ret
 ada:	8082                	ret

0000000000000adc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 adc:	48c5                	li	a7,17
 ecall
 ade:	00000073          	ecall
 ret
 ae2:	8082                	ret

0000000000000ae4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 ae4:	48c9                	li	a7,18
 ecall
 ae6:	00000073          	ecall
 ret
 aea:	8082                	ret

0000000000000aec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 aec:	48a1                	li	a7,8
 ecall
 aee:	00000073          	ecall
 ret
 af2:	8082                	ret

0000000000000af4 <link>:
.global link
link:
 li a7, SYS_link
 af4:	48cd                	li	a7,19
 ecall
 af6:	00000073          	ecall
 ret
 afa:	8082                	ret

0000000000000afc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 afc:	48d1                	li	a7,20
 ecall
 afe:	00000073          	ecall
 ret
 b02:	8082                	ret

0000000000000b04 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 b04:	48a5                	li	a7,9
 ecall
 b06:	00000073          	ecall
 ret
 b0a:	8082                	ret

0000000000000b0c <dup>:
.global dup
dup:
 li a7, SYS_dup
 b0c:	48a9                	li	a7,10
 ecall
 b0e:	00000073          	ecall
 ret
 b12:	8082                	ret

0000000000000b14 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 b14:	48ad                	li	a7,11
 ecall
 b16:	00000073          	ecall
 ret
 b1a:	8082                	ret

0000000000000b1c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 b1c:	48b1                	li	a7,12
 ecall
 b1e:	00000073          	ecall
 ret
 b22:	8082                	ret

0000000000000b24 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 b24:	48b5                	li	a7,13
 ecall
 b26:	00000073          	ecall
 ret
 b2a:	8082                	ret

0000000000000b2c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 b2c:	48b9                	li	a7,14
 ecall
 b2e:	00000073          	ecall
 ret
 b32:	8082                	ret

0000000000000b34 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
 b34:	48dd                	li	a7,23
 ecall
 b36:	00000073          	ecall
 ret
 b3a:	8082                	ret

0000000000000b3c <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
 b3c:	48e1                	li	a7,24
 ecall
 b3e:	00000073          	ecall
 ret
 b42:	8082                	ret

0000000000000b44 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 b44:	1101                	addi	sp,sp,-32
 b46:	ec06                	sd	ra,24(sp)
 b48:	e822                	sd	s0,16(sp)
 b4a:	1000                	addi	s0,sp,32
 b4c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 b50:	4605                	li	a2,1
 b52:	fef40593          	addi	a1,s0,-17
 b56:	00000097          	auipc	ra,0x0
 b5a:	f5e080e7          	jalr	-162(ra) # ab4 <write>
}
 b5e:	60e2                	ld	ra,24(sp)
 b60:	6442                	ld	s0,16(sp)
 b62:	6105                	addi	sp,sp,32
 b64:	8082                	ret

0000000000000b66 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 b66:	7139                	addi	sp,sp,-64
 b68:	fc06                	sd	ra,56(sp)
 b6a:	f822                	sd	s0,48(sp)
 b6c:	f426                	sd	s1,40(sp)
 b6e:	f04a                	sd	s2,32(sp)
 b70:	ec4e                	sd	s3,24(sp)
 b72:	0080                	addi	s0,sp,64
 b74:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 b76:	c299                	beqz	a3,b7c <printint+0x16>
 b78:	0805c863          	bltz	a1,c08 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 b7c:	2581                	sext.w	a1,a1
  neg = 0;
 b7e:	4881                	li	a7,0
 b80:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 b84:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 b86:	2601                	sext.w	a2,a2
 b88:	00001517          	auipc	a0,0x1
 b8c:	86050513          	addi	a0,a0,-1952 # 13e8 <digits>
 b90:	883a                	mv	a6,a4
 b92:	2705                	addiw	a4,a4,1
 b94:	02c5f7bb          	remuw	a5,a1,a2
 b98:	1782                	slli	a5,a5,0x20
 b9a:	9381                	srli	a5,a5,0x20
 b9c:	97aa                	add	a5,a5,a0
 b9e:	0007c783          	lbu	a5,0(a5)
 ba2:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 ba6:	0005879b          	sext.w	a5,a1
 baa:	02c5d5bb          	divuw	a1,a1,a2
 bae:	0685                	addi	a3,a3,1
 bb0:	fec7f0e3          	bgeu	a5,a2,b90 <printint+0x2a>
  if(neg)
 bb4:	00088b63          	beqz	a7,bca <printint+0x64>
    buf[i++] = '-';
 bb8:	fd040793          	addi	a5,s0,-48
 bbc:	973e                	add	a4,a4,a5
 bbe:	02d00793          	li	a5,45
 bc2:	fef70823          	sb	a5,-16(a4)
 bc6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 bca:	02e05863          	blez	a4,bfa <printint+0x94>
 bce:	fc040793          	addi	a5,s0,-64
 bd2:	00e78933          	add	s2,a5,a4
 bd6:	fff78993          	addi	s3,a5,-1
 bda:	99ba                	add	s3,s3,a4
 bdc:	377d                	addiw	a4,a4,-1
 bde:	1702                	slli	a4,a4,0x20
 be0:	9301                	srli	a4,a4,0x20
 be2:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 be6:	fff94583          	lbu	a1,-1(s2)
 bea:	8526                	mv	a0,s1
 bec:	00000097          	auipc	ra,0x0
 bf0:	f58080e7          	jalr	-168(ra) # b44 <putc>
  while(--i >= 0)
 bf4:	197d                	addi	s2,s2,-1
 bf6:	ff3918e3          	bne	s2,s3,be6 <printint+0x80>
}
 bfa:	70e2                	ld	ra,56(sp)
 bfc:	7442                	ld	s0,48(sp)
 bfe:	74a2                	ld	s1,40(sp)
 c00:	7902                	ld	s2,32(sp)
 c02:	69e2                	ld	s3,24(sp)
 c04:	6121                	addi	sp,sp,64
 c06:	8082                	ret
    x = -xx;
 c08:	40b005bb          	negw	a1,a1
    neg = 1;
 c0c:	4885                	li	a7,1
    x = -xx;
 c0e:	bf8d                	j	b80 <printint+0x1a>

0000000000000c10 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 c10:	7119                	addi	sp,sp,-128
 c12:	fc86                	sd	ra,120(sp)
 c14:	f8a2                	sd	s0,112(sp)
 c16:	f4a6                	sd	s1,104(sp)
 c18:	f0ca                	sd	s2,96(sp)
 c1a:	ecce                	sd	s3,88(sp)
 c1c:	e8d2                	sd	s4,80(sp)
 c1e:	e4d6                	sd	s5,72(sp)
 c20:	e0da                	sd	s6,64(sp)
 c22:	fc5e                	sd	s7,56(sp)
 c24:	f862                	sd	s8,48(sp)
 c26:	f466                	sd	s9,40(sp)
 c28:	f06a                	sd	s10,32(sp)
 c2a:	ec6e                	sd	s11,24(sp)
 c2c:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 c2e:	0005c903          	lbu	s2,0(a1)
 c32:	18090f63          	beqz	s2,dd0 <vprintf+0x1c0>
 c36:	8aaa                	mv	s5,a0
 c38:	8b32                	mv	s6,a2
 c3a:	00158493          	addi	s1,a1,1
  state = 0;
 c3e:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 c40:	02500a13          	li	s4,37
      if(c == 'd'){
 c44:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 c48:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 c4c:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 c50:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c54:	00000b97          	auipc	s7,0x0
 c58:	794b8b93          	addi	s7,s7,1940 # 13e8 <digits>
 c5c:	a839                	j	c7a <vprintf+0x6a>
        putc(fd, c);
 c5e:	85ca                	mv	a1,s2
 c60:	8556                	mv	a0,s5
 c62:	00000097          	auipc	ra,0x0
 c66:	ee2080e7          	jalr	-286(ra) # b44 <putc>
 c6a:	a019                	j	c70 <vprintf+0x60>
    } else if(state == '%'){
 c6c:	01498f63          	beq	s3,s4,c8a <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 c70:	0485                	addi	s1,s1,1
 c72:	fff4c903          	lbu	s2,-1(s1)
 c76:	14090d63          	beqz	s2,dd0 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 c7a:	0009079b          	sext.w	a5,s2
    if(state == 0){
 c7e:	fe0997e3          	bnez	s3,c6c <vprintf+0x5c>
      if(c == '%'){
 c82:	fd479ee3          	bne	a5,s4,c5e <vprintf+0x4e>
        state = '%';
 c86:	89be                	mv	s3,a5
 c88:	b7e5                	j	c70 <vprintf+0x60>
      if(c == 'd'){
 c8a:	05878063          	beq	a5,s8,cca <vprintf+0xba>
      } else if(c == 'l') {
 c8e:	05978c63          	beq	a5,s9,ce6 <vprintf+0xd6>
      } else if(c == 'x') {
 c92:	07a78863          	beq	a5,s10,d02 <vprintf+0xf2>
      } else if(c == 'p') {
 c96:	09b78463          	beq	a5,s11,d1e <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 c9a:	07300713          	li	a4,115
 c9e:	0ce78663          	beq	a5,a4,d6a <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 ca2:	06300713          	li	a4,99
 ca6:	0ee78e63          	beq	a5,a4,da2 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 caa:	11478863          	beq	a5,s4,dba <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 cae:	85d2                	mv	a1,s4
 cb0:	8556                	mv	a0,s5
 cb2:	00000097          	auipc	ra,0x0
 cb6:	e92080e7          	jalr	-366(ra) # b44 <putc>
        putc(fd, c);
 cba:	85ca                	mv	a1,s2
 cbc:	8556                	mv	a0,s5
 cbe:	00000097          	auipc	ra,0x0
 cc2:	e86080e7          	jalr	-378(ra) # b44 <putc>
      }
      state = 0;
 cc6:	4981                	li	s3,0
 cc8:	b765                	j	c70 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 cca:	008b0913          	addi	s2,s6,8
 cce:	4685                	li	a3,1
 cd0:	4629                	li	a2,10
 cd2:	000b2583          	lw	a1,0(s6)
 cd6:	8556                	mv	a0,s5
 cd8:	00000097          	auipc	ra,0x0
 cdc:	e8e080e7          	jalr	-370(ra) # b66 <printint>
 ce0:	8b4a                	mv	s6,s2
      state = 0;
 ce2:	4981                	li	s3,0
 ce4:	b771                	j	c70 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 ce6:	008b0913          	addi	s2,s6,8
 cea:	4681                	li	a3,0
 cec:	4629                	li	a2,10
 cee:	000b2583          	lw	a1,0(s6)
 cf2:	8556                	mv	a0,s5
 cf4:	00000097          	auipc	ra,0x0
 cf8:	e72080e7          	jalr	-398(ra) # b66 <printint>
 cfc:	8b4a                	mv	s6,s2
      state = 0;
 cfe:	4981                	li	s3,0
 d00:	bf85                	j	c70 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 d02:	008b0913          	addi	s2,s6,8
 d06:	4681                	li	a3,0
 d08:	4641                	li	a2,16
 d0a:	000b2583          	lw	a1,0(s6)
 d0e:	8556                	mv	a0,s5
 d10:	00000097          	auipc	ra,0x0
 d14:	e56080e7          	jalr	-426(ra) # b66 <printint>
 d18:	8b4a                	mv	s6,s2
      state = 0;
 d1a:	4981                	li	s3,0
 d1c:	bf91                	j	c70 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 d1e:	008b0793          	addi	a5,s6,8
 d22:	f8f43423          	sd	a5,-120(s0)
 d26:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 d2a:	03000593          	li	a1,48
 d2e:	8556                	mv	a0,s5
 d30:	00000097          	auipc	ra,0x0
 d34:	e14080e7          	jalr	-492(ra) # b44 <putc>
  putc(fd, 'x');
 d38:	85ea                	mv	a1,s10
 d3a:	8556                	mv	a0,s5
 d3c:	00000097          	auipc	ra,0x0
 d40:	e08080e7          	jalr	-504(ra) # b44 <putc>
 d44:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 d46:	03c9d793          	srli	a5,s3,0x3c
 d4a:	97de                	add	a5,a5,s7
 d4c:	0007c583          	lbu	a1,0(a5)
 d50:	8556                	mv	a0,s5
 d52:	00000097          	auipc	ra,0x0
 d56:	df2080e7          	jalr	-526(ra) # b44 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 d5a:	0992                	slli	s3,s3,0x4
 d5c:	397d                	addiw	s2,s2,-1
 d5e:	fe0914e3          	bnez	s2,d46 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 d62:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 d66:	4981                	li	s3,0
 d68:	b721                	j	c70 <vprintf+0x60>
        s = va_arg(ap, char*);
 d6a:	008b0993          	addi	s3,s6,8
 d6e:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 d72:	02090163          	beqz	s2,d94 <vprintf+0x184>
        while(*s != 0){
 d76:	00094583          	lbu	a1,0(s2)
 d7a:	c9a1                	beqz	a1,dca <vprintf+0x1ba>
          putc(fd, *s);
 d7c:	8556                	mv	a0,s5
 d7e:	00000097          	auipc	ra,0x0
 d82:	dc6080e7          	jalr	-570(ra) # b44 <putc>
          s++;
 d86:	0905                	addi	s2,s2,1
        while(*s != 0){
 d88:	00094583          	lbu	a1,0(s2)
 d8c:	f9e5                	bnez	a1,d7c <vprintf+0x16c>
        s = va_arg(ap, char*);
 d8e:	8b4e                	mv	s6,s3
      state = 0;
 d90:	4981                	li	s3,0
 d92:	bdf9                	j	c70 <vprintf+0x60>
          s = "(null)";
 d94:	00000917          	auipc	s2,0x0
 d98:	64c90913          	addi	s2,s2,1612 # 13e0 <malloc+0x506>
        while(*s != 0){
 d9c:	02800593          	li	a1,40
 da0:	bff1                	j	d7c <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 da2:	008b0913          	addi	s2,s6,8
 da6:	000b4583          	lbu	a1,0(s6)
 daa:	8556                	mv	a0,s5
 dac:	00000097          	auipc	ra,0x0
 db0:	d98080e7          	jalr	-616(ra) # b44 <putc>
 db4:	8b4a                	mv	s6,s2
      state = 0;
 db6:	4981                	li	s3,0
 db8:	bd65                	j	c70 <vprintf+0x60>
        putc(fd, c);
 dba:	85d2                	mv	a1,s4
 dbc:	8556                	mv	a0,s5
 dbe:	00000097          	auipc	ra,0x0
 dc2:	d86080e7          	jalr	-634(ra) # b44 <putc>
      state = 0;
 dc6:	4981                	li	s3,0
 dc8:	b565                	j	c70 <vprintf+0x60>
        s = va_arg(ap, char*);
 dca:	8b4e                	mv	s6,s3
      state = 0;
 dcc:	4981                	li	s3,0
 dce:	b54d                	j	c70 <vprintf+0x60>
    }
  }
}
 dd0:	70e6                	ld	ra,120(sp)
 dd2:	7446                	ld	s0,112(sp)
 dd4:	74a6                	ld	s1,104(sp)
 dd6:	7906                	ld	s2,96(sp)
 dd8:	69e6                	ld	s3,88(sp)
 dda:	6a46                	ld	s4,80(sp)
 ddc:	6aa6                	ld	s5,72(sp)
 dde:	6b06                	ld	s6,64(sp)
 de0:	7be2                	ld	s7,56(sp)
 de2:	7c42                	ld	s8,48(sp)
 de4:	7ca2                	ld	s9,40(sp)
 de6:	7d02                	ld	s10,32(sp)
 de8:	6de2                	ld	s11,24(sp)
 dea:	6109                	addi	sp,sp,128
 dec:	8082                	ret

0000000000000dee <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 dee:	715d                	addi	sp,sp,-80
 df0:	ec06                	sd	ra,24(sp)
 df2:	e822                	sd	s0,16(sp)
 df4:	1000                	addi	s0,sp,32
 df6:	e010                	sd	a2,0(s0)
 df8:	e414                	sd	a3,8(s0)
 dfa:	e818                	sd	a4,16(s0)
 dfc:	ec1c                	sd	a5,24(s0)
 dfe:	03043023          	sd	a6,32(s0)
 e02:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 e06:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 e0a:	8622                	mv	a2,s0
 e0c:	00000097          	auipc	ra,0x0
 e10:	e04080e7          	jalr	-508(ra) # c10 <vprintf>
}
 e14:	60e2                	ld	ra,24(sp)
 e16:	6442                	ld	s0,16(sp)
 e18:	6161                	addi	sp,sp,80
 e1a:	8082                	ret

0000000000000e1c <printf>:

void
printf(const char *fmt, ...)
{
 e1c:	711d                	addi	sp,sp,-96
 e1e:	ec06                	sd	ra,24(sp)
 e20:	e822                	sd	s0,16(sp)
 e22:	1000                	addi	s0,sp,32
 e24:	e40c                	sd	a1,8(s0)
 e26:	e810                	sd	a2,16(s0)
 e28:	ec14                	sd	a3,24(s0)
 e2a:	f018                	sd	a4,32(s0)
 e2c:	f41c                	sd	a5,40(s0)
 e2e:	03043823          	sd	a6,48(s0)
 e32:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 e36:	00840613          	addi	a2,s0,8
 e3a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 e3e:	85aa                	mv	a1,a0
 e40:	4505                	li	a0,1
 e42:	00000097          	auipc	ra,0x0
 e46:	dce080e7          	jalr	-562(ra) # c10 <vprintf>
}
 e4a:	60e2                	ld	ra,24(sp)
 e4c:	6442                	ld	s0,16(sp)
 e4e:	6125                	addi	sp,sp,96
 e50:	8082                	ret

0000000000000e52 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 e52:	1141                	addi	sp,sp,-16
 e54:	e422                	sd	s0,8(sp)
 e56:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 e58:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e5c:	00000797          	auipc	a5,0x0
 e60:	5ac7b783          	ld	a5,1452(a5) # 1408 <freep>
 e64:	a805                	j	e94 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 e66:	4618                	lw	a4,8(a2)
 e68:	9db9                	addw	a1,a1,a4
 e6a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 e6e:	6398                	ld	a4,0(a5)
 e70:	6318                	ld	a4,0(a4)
 e72:	fee53823          	sd	a4,-16(a0)
 e76:	a091                	j	eba <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 e78:	ff852703          	lw	a4,-8(a0)
 e7c:	9e39                	addw	a2,a2,a4
 e7e:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 e80:	ff053703          	ld	a4,-16(a0)
 e84:	e398                	sd	a4,0(a5)
 e86:	a099                	j	ecc <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e88:	6398                	ld	a4,0(a5)
 e8a:	00e7e463          	bltu	a5,a4,e92 <free+0x40>
 e8e:	00e6ea63          	bltu	a3,a4,ea2 <free+0x50>
{
 e92:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 e94:	fed7fae3          	bgeu	a5,a3,e88 <free+0x36>
 e98:	6398                	ld	a4,0(a5)
 e9a:	00e6e463          	bltu	a3,a4,ea2 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 e9e:	fee7eae3          	bltu	a5,a4,e92 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 ea2:	ff852583          	lw	a1,-8(a0)
 ea6:	6390                	ld	a2,0(a5)
 ea8:	02059713          	slli	a4,a1,0x20
 eac:	9301                	srli	a4,a4,0x20
 eae:	0712                	slli	a4,a4,0x4
 eb0:	9736                	add	a4,a4,a3
 eb2:	fae60ae3          	beq	a2,a4,e66 <free+0x14>
    bp->s.ptr = p->s.ptr;
 eb6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 eba:	4790                	lw	a2,8(a5)
 ebc:	02061713          	slli	a4,a2,0x20
 ec0:	9301                	srli	a4,a4,0x20
 ec2:	0712                	slli	a4,a4,0x4
 ec4:	973e                	add	a4,a4,a5
 ec6:	fae689e3          	beq	a3,a4,e78 <free+0x26>
  } else
    p->s.ptr = bp;
 eca:	e394                	sd	a3,0(a5)
  freep = p;
 ecc:	00000717          	auipc	a4,0x0
 ed0:	52f73e23          	sd	a5,1340(a4) # 1408 <freep>
}
 ed4:	6422                	ld	s0,8(sp)
 ed6:	0141                	addi	sp,sp,16
 ed8:	8082                	ret

0000000000000eda <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 eda:	7139                	addi	sp,sp,-64
 edc:	fc06                	sd	ra,56(sp)
 ede:	f822                	sd	s0,48(sp)
 ee0:	f426                	sd	s1,40(sp)
 ee2:	f04a                	sd	s2,32(sp)
 ee4:	ec4e                	sd	s3,24(sp)
 ee6:	e852                	sd	s4,16(sp)
 ee8:	e456                	sd	s5,8(sp)
 eea:	e05a                	sd	s6,0(sp)
 eec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 eee:	02051493          	slli	s1,a0,0x20
 ef2:	9081                	srli	s1,s1,0x20
 ef4:	04bd                	addi	s1,s1,15
 ef6:	8091                	srli	s1,s1,0x4
 ef8:	0014899b          	addiw	s3,s1,1
 efc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 efe:	00000517          	auipc	a0,0x0
 f02:	50a53503          	ld	a0,1290(a0) # 1408 <freep>
 f06:	c515                	beqz	a0,f32 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f08:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f0a:	4798                	lw	a4,8(a5)
 f0c:	02977f63          	bgeu	a4,s1,f4a <malloc+0x70>
 f10:	8a4e                	mv	s4,s3
 f12:	0009871b          	sext.w	a4,s3
 f16:	6685                	lui	a3,0x1
 f18:	00d77363          	bgeu	a4,a3,f1e <malloc+0x44>
 f1c:	6a05                	lui	s4,0x1
 f1e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 f22:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 f26:	00000917          	auipc	s2,0x0
 f2a:	4e290913          	addi	s2,s2,1250 # 1408 <freep>
  if(p == (char*)-1)
 f2e:	5afd                	li	s5,-1
 f30:	a88d                	j	fa2 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 f32:	00001797          	auipc	a5,0x1
 f36:	8de78793          	addi	a5,a5,-1826 # 1810 <base>
 f3a:	00000717          	auipc	a4,0x0
 f3e:	4cf73723          	sd	a5,1230(a4) # 1408 <freep>
 f42:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 f44:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 f48:	b7e1                	j	f10 <malloc+0x36>
      if(p->s.size == nunits)
 f4a:	02e48b63          	beq	s1,a4,f80 <malloc+0xa6>
        p->s.size -= nunits;
 f4e:	4137073b          	subw	a4,a4,s3
 f52:	c798                	sw	a4,8(a5)
        p += p->s.size;
 f54:	1702                	slli	a4,a4,0x20
 f56:	9301                	srli	a4,a4,0x20
 f58:	0712                	slli	a4,a4,0x4
 f5a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 f5c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 f60:	00000717          	auipc	a4,0x0
 f64:	4aa73423          	sd	a0,1192(a4) # 1408 <freep>
      return (void*)(p + 1);
 f68:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 f6c:	70e2                	ld	ra,56(sp)
 f6e:	7442                	ld	s0,48(sp)
 f70:	74a2                	ld	s1,40(sp)
 f72:	7902                	ld	s2,32(sp)
 f74:	69e2                	ld	s3,24(sp)
 f76:	6a42                	ld	s4,16(sp)
 f78:	6aa2                	ld	s5,8(sp)
 f7a:	6b02                	ld	s6,0(sp)
 f7c:	6121                	addi	sp,sp,64
 f7e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 f80:	6398                	ld	a4,0(a5)
 f82:	e118                	sd	a4,0(a0)
 f84:	bff1                	j	f60 <malloc+0x86>
  hp->s.size = nu;
 f86:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 f8a:	0541                	addi	a0,a0,16
 f8c:	00000097          	auipc	ra,0x0
 f90:	ec6080e7          	jalr	-314(ra) # e52 <free>
  return freep;
 f94:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 f98:	d971                	beqz	a0,f6c <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 f9a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 f9c:	4798                	lw	a4,8(a5)
 f9e:	fa9776e3          	bgeu	a4,s1,f4a <malloc+0x70>
    if(p == freep)
 fa2:	00093703          	ld	a4,0(s2)
 fa6:	853e                	mv	a0,a5
 fa8:	fef719e3          	bne	a4,a5,f9a <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 fac:	8552                	mv	a0,s4
 fae:	00000097          	auipc	ra,0x0
 fb2:	b6e080e7          	jalr	-1170(ra) # b1c <sbrk>
  if(p == (char*)-1)
 fb6:	fd5518e3          	bne	a0,s5,f86 <malloc+0xac>
        return 0;
 fba:	4501                	li	a0,0
 fbc:	bf45                	j	f6c <malloc+0x92>
