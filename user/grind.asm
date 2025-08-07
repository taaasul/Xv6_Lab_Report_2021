
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	ra,0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7119                	addi	sp,sp,-128
      76:	fc86                	sd	ra,120(sp)
      78:	f8a2                	sd	s0,112(sp)
      7a:	f4a6                	sd	s1,104(sp)
      7c:	f0ca                	sd	s2,96(sp)
      7e:	ecce                	sd	s3,88(sp)
      80:	e8d2                	sd	s4,80(sp)
      82:	e4d6                	sd	s5,72(sp)
      84:	e0da                	sd	s6,64(sp)
      86:	fc5e                	sd	s7,56(sp)
      88:	0100                	addi	s0,sp,128
      8a:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      8c:	4501                	li	a0,0
      8e:	39f000ef          	jal	ra,c2c <sbrk>
      92:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      94:	00001517          	auipc	a0,0x1
      98:	0cc50513          	addi	a0,a0,204 # 1160 <malloc+0xe8>
      9c:	371000ef          	jal	ra,c0c <mkdir>
  if(chdir("grindir") != 0){
      a0:	00001517          	auipc	a0,0x1
      a4:	0c050513          	addi	a0,a0,192 # 1160 <malloc+0xe8>
      a8:	36d000ef          	jal	ra,c14 <chdir>
      ac:	c911                	beqz	a0,c0 <go+0x4c>
    printf("grind: chdir grindir failed\n");
      ae:	00001517          	auipc	a0,0x1
      b2:	0ba50513          	addi	a0,a0,186 # 1168 <malloc+0xf0>
      b6:	709000ef          	jal	ra,fbe <printf>
    exit(1);
      ba:	4505                	li	a0,1
      bc:	2e9000ef          	jal	ra,ba4 <exit>
  }
  chdir("/");
      c0:	00001517          	auipc	a0,0x1
      c4:	0c850513          	addi	a0,a0,200 # 1188 <malloc+0x110>
      c8:	34d000ef          	jal	ra,c14 <chdir>
  
  while(1){
    iters++;
    if((iters % 500) == 0)
      cc:	00001997          	auipc	s3,0x1
      d0:	0cc98993          	addi	s3,s3,204 # 1198 <malloc+0x120>
      d4:	c489                	beqz	s1,de <go+0x6a>
      d6:	00001997          	auipc	s3,0x1
      da:	0ba98993          	addi	s3,s3,186 # 1190 <malloc+0x118>
    iters++;
      de:	4485                	li	s1,1
  int fd = -1;
      e0:	597d                	li	s2,-1
      close(fd);
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
      e2:	00002a17          	auipc	s4,0x2
      e6:	f3ea0a13          	addi	s4,s4,-194 # 2020 <buf.1752>
      ea:	a035                	j	116 <go+0xa2>
      close(open("grindir/../a", O_CREATE|O_RDWR));
      ec:	20200593          	li	a1,514
      f0:	00001517          	auipc	a0,0x1
      f4:	0b050513          	addi	a0,a0,176 # 11a0 <malloc+0x128>
      f8:	2ed000ef          	jal	ra,be4 <open>
      fc:	2d1000ef          	jal	ra,bcc <close>
    iters++;
     100:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     102:	1f400793          	li	a5,500
     106:	02f4f7b3          	remu	a5,s1,a5
     10a:	e791                	bnez	a5,116 <go+0xa2>
      write(1, which_child?"B":"A", 1);
     10c:	4605                	li	a2,1
     10e:	85ce                	mv	a1,s3
     110:	4505                	li	a0,1
     112:	2b3000ef          	jal	ra,bc4 <write>
    int what = rand() % 23;
     116:	f43ff0ef          	jal	ra,58 <rand>
     11a:	47dd                	li	a5,23
     11c:	02f5653b          	remw	a0,a0,a5
    if(what == 1){
     120:	4785                	li	a5,1
     122:	fcf505e3          	beq	a0,a5,ec <go+0x78>
    } else if(what == 2){
     126:	4789                	li	a5,2
     128:	14f50463          	beq	a0,a5,270 <go+0x1fc>
    } else if(what == 3){
     12c:	478d                	li	a5,3
     12e:	14f50c63          	beq	a0,a5,286 <go+0x212>
    } else if(what == 4){
     132:	4791                	li	a5,4
     134:	16f50063          	beq	a0,a5,294 <go+0x220>
    } else if(what == 5){
     138:	4795                	li	a5,5
     13a:	18f50a63          	beq	a0,a5,2ce <go+0x25a>
    } else if(what == 6){
     13e:	4799                	li	a5,6
     140:	1af50463          	beq	a0,a5,2e8 <go+0x274>
    } else if(what == 7){
     144:	479d                	li	a5,7
     146:	1af50e63          	beq	a0,a5,302 <go+0x28e>
    } else if(what == 8){
     14a:	47a1                	li	a5,8
     14c:	1cf50263          	beq	a0,a5,310 <go+0x29c>
    } else if(what == 9){
     150:	47a5                	li	a5,9
     152:	1cf50663          	beq	a0,a5,31e <go+0x2aa>
      mkdir("grindir/../a");
      close(open("a/../a/./a", O_CREATE|O_RDWR));
      unlink("a/a");
    } else if(what == 10){
     156:	47a9                	li	a5,10
     158:	1ef50a63          	beq	a0,a5,34c <go+0x2d8>
      mkdir("/../b");
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
      unlink("b/b");
    } else if(what == 11){
     15c:	47ad                	li	a5,11
     15e:	20f50e63          	beq	a0,a5,37a <go+0x306>
      unlink("b");
      link("../grindir/./../a", "../b");
    } else if(what == 12){
     162:	47b1                	li	a5,12
     164:	22f50c63          	beq	a0,a5,39c <go+0x328>
      unlink("../grindir/../a");
      link(".././b", "/grindir/../a");
    } else if(what == 13){
     168:	47b5                	li	a5,13
     16a:	24f50a63          	beq	a0,a5,3be <go+0x34a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 14){
     16e:	47b9                	li	a5,14
     170:	26f50b63          	beq	a0,a5,3e6 <go+0x372>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 15){
     174:	47bd                	li	a5,15
     176:	2af50163          	beq	a0,a5,418 <go+0x3a4>
      sbrk(6011);
    } else if(what == 16){
     17a:	47c1                	li	a5,16
     17c:	2af50463          	beq	a0,a5,424 <go+0x3b0>
      if(sbrk(0) > break0)
        sbrk(-(sbrk(0) - break0));
    } else if(what == 17){
     180:	47c5                	li	a5,17
     182:	2af50e63          	beq	a0,a5,43e <go+0x3ca>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
      wait(0);
    } else if(what == 18){
     186:	47c9                	li	a5,18
     188:	30f50e63          	beq	a0,a5,4a4 <go+0x430>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 19){
     18c:	47cd                	li	a5,19
     18e:	34f50463          	beq	a0,a5,4d6 <go+0x462>
        exit(1);
      }
      close(fds[0]);
      close(fds[1]);
      wait(0);
    } else if(what == 20){
     192:	47d1                	li	a5,20
     194:	3ef50563          	beq	a0,a5,57e <go+0x50a>
      } else if(pid < 0){
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
    } else if(what == 21){
     198:	47d5                	li	a5,21
     19a:	44f50d63          	beq	a0,a5,5f4 <go+0x580>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
      unlink("c");
    } else if(what == 22){
     19e:	47d9                	li	a5,22
     1a0:	f6f510e3          	bne	a0,a5,100 <go+0x8c>
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     1a4:	f8840513          	addi	a0,s0,-120
     1a8:	20d000ef          	jal	ra,bb4 <pipe>
     1ac:	50054863          	bltz	a0,6bc <go+0x648>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     1b0:	f9040513          	addi	a0,s0,-112
     1b4:	201000ef          	jal	ra,bb4 <pipe>
     1b8:	50054c63          	bltz	a0,6d0 <go+0x65c>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     1bc:	1e1000ef          	jal	ra,b9c <fork>
      if(pid1 == 0){
     1c0:	52050263          	beqz	a0,6e4 <go+0x670>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     1c4:	5a054463          	bltz	a0,76c <go+0x6f8>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     1c8:	1d5000ef          	jal	ra,b9c <fork>
      if(pid2 == 0){
     1cc:	5a050a63          	beqz	a0,780 <go+0x70c>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     1d0:	64054863          	bltz	a0,820 <go+0x7ac>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     1d4:	f8842503          	lw	a0,-120(s0)
     1d8:	1f5000ef          	jal	ra,bcc <close>
      close(aa[1]);
     1dc:	f8c42503          	lw	a0,-116(s0)
     1e0:	1ed000ef          	jal	ra,bcc <close>
      close(bb[1]);
     1e4:	f9442503          	lw	a0,-108(s0)
     1e8:	1e5000ef          	jal	ra,bcc <close>
      char buf[4] = { 0, 0, 0, 0 };
     1ec:	f8042023          	sw	zero,-128(s0)
      read(bb[0], buf+0, 1);
     1f0:	4605                	li	a2,1
     1f2:	f8040593          	addi	a1,s0,-128
     1f6:	f9042503          	lw	a0,-112(s0)
     1fa:	1c3000ef          	jal	ra,bbc <read>
      read(bb[0], buf+1, 1);
     1fe:	4605                	li	a2,1
     200:	f8140593          	addi	a1,s0,-127
     204:	f9042503          	lw	a0,-112(s0)
     208:	1b5000ef          	jal	ra,bbc <read>
      read(bb[0], buf+2, 1);
     20c:	4605                	li	a2,1
     20e:	f8240593          	addi	a1,s0,-126
     212:	f9042503          	lw	a0,-112(s0)
     216:	1a7000ef          	jal	ra,bbc <read>
      close(bb[0]);
     21a:	f9042503          	lw	a0,-112(s0)
     21e:	1af000ef          	jal	ra,bcc <close>
      int st1, st2;
      wait(&st1);
     222:	f8440513          	addi	a0,s0,-124
     226:	187000ef          	jal	ra,bac <wait>
      wait(&st2);
     22a:	f9840513          	addi	a0,s0,-104
     22e:	17f000ef          	jal	ra,bac <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     232:	f8442583          	lw	a1,-124(s0)
     236:	f9842b03          	lw	s6,-104(s0)
     23a:	0165ebb3          	or	s7,a1,s6
     23e:	000b9d63          	bnez	s7,258 <go+0x1e4>
     242:	00001597          	auipc	a1,0x1
     246:	1d658593          	addi	a1,a1,470 # 1418 <malloc+0x3a0>
     24a:	f8040513          	addi	a0,s0,-128
     24e:	710000ef          	jal	ra,95e <strcmp>
     252:	ea0507e3          	beqz	a0,100 <go+0x8c>
     256:	85de                	mv	a1,s7
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     258:	f8040693          	addi	a3,s0,-128
     25c:	865a                	mv	a2,s6
     25e:	00001517          	auipc	a0,0x1
     262:	1c250513          	addi	a0,a0,450 # 1420 <malloc+0x3a8>
     266:	559000ef          	jal	ra,fbe <printf>
        exit(1);
     26a:	4505                	li	a0,1
     26c:	139000ef          	jal	ra,ba4 <exit>
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     270:	20200593          	li	a1,514
     274:	00001517          	auipc	a0,0x1
     278:	f3c50513          	addi	a0,a0,-196 # 11b0 <malloc+0x138>
     27c:	169000ef          	jal	ra,be4 <open>
     280:	14d000ef          	jal	ra,bcc <close>
     284:	bdb5                	j	100 <go+0x8c>
      unlink("grindir/../a");
     286:	00001517          	auipc	a0,0x1
     28a:	f1a50513          	addi	a0,a0,-230 # 11a0 <malloc+0x128>
     28e:	167000ef          	jal	ra,bf4 <unlink>
     292:	b5bd                	j	100 <go+0x8c>
      if(chdir("grindir") != 0){
     294:	00001517          	auipc	a0,0x1
     298:	ecc50513          	addi	a0,a0,-308 # 1160 <malloc+0xe8>
     29c:	179000ef          	jal	ra,c14 <chdir>
     2a0:	ed11                	bnez	a0,2bc <go+0x248>
      unlink("../b");
     2a2:	00001517          	auipc	a0,0x1
     2a6:	f2650513          	addi	a0,a0,-218 # 11c8 <malloc+0x150>
     2aa:	14b000ef          	jal	ra,bf4 <unlink>
      chdir("/");
     2ae:	00001517          	auipc	a0,0x1
     2b2:	eda50513          	addi	a0,a0,-294 # 1188 <malloc+0x110>
     2b6:	15f000ef          	jal	ra,c14 <chdir>
     2ba:	b599                	j	100 <go+0x8c>
        printf("grind: chdir grindir failed\n");
     2bc:	00001517          	auipc	a0,0x1
     2c0:	eac50513          	addi	a0,a0,-340 # 1168 <malloc+0xf0>
     2c4:	4fb000ef          	jal	ra,fbe <printf>
        exit(1);
     2c8:	4505                	li	a0,1
     2ca:	0db000ef          	jal	ra,ba4 <exit>
      close(fd);
     2ce:	854a                	mv	a0,s2
     2d0:	0fd000ef          	jal	ra,bcc <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     2d4:	20200593          	li	a1,514
     2d8:	00001517          	auipc	a0,0x1
     2dc:	ef850513          	addi	a0,a0,-264 # 11d0 <malloc+0x158>
     2e0:	105000ef          	jal	ra,be4 <open>
     2e4:	892a                	mv	s2,a0
     2e6:	bd29                	j	100 <go+0x8c>
      close(fd);
     2e8:	854a                	mv	a0,s2
     2ea:	0e3000ef          	jal	ra,bcc <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     2ee:	20200593          	li	a1,514
     2f2:	00001517          	auipc	a0,0x1
     2f6:	eee50513          	addi	a0,a0,-274 # 11e0 <malloc+0x168>
     2fa:	0eb000ef          	jal	ra,be4 <open>
     2fe:	892a                	mv	s2,a0
     300:	b501                	j	100 <go+0x8c>
      write(fd, buf, sizeof(buf));
     302:	3e700613          	li	a2,999
     306:	85d2                	mv	a1,s4
     308:	854a                	mv	a0,s2
     30a:	0bb000ef          	jal	ra,bc4 <write>
     30e:	bbcd                	j	100 <go+0x8c>
      read(fd, buf, sizeof(buf));
     310:	3e700613          	li	a2,999
     314:	85d2                	mv	a1,s4
     316:	854a                	mv	a0,s2
     318:	0a5000ef          	jal	ra,bbc <read>
     31c:	b3d5                	j	100 <go+0x8c>
      mkdir("grindir/../a");
     31e:	00001517          	auipc	a0,0x1
     322:	e8250513          	addi	a0,a0,-382 # 11a0 <malloc+0x128>
     326:	0e7000ef          	jal	ra,c0c <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     32a:	20200593          	li	a1,514
     32e:	00001517          	auipc	a0,0x1
     332:	eca50513          	addi	a0,a0,-310 # 11f8 <malloc+0x180>
     336:	0af000ef          	jal	ra,be4 <open>
     33a:	093000ef          	jal	ra,bcc <close>
      unlink("a/a");
     33e:	00001517          	auipc	a0,0x1
     342:	eca50513          	addi	a0,a0,-310 # 1208 <malloc+0x190>
     346:	0af000ef          	jal	ra,bf4 <unlink>
     34a:	bb5d                	j	100 <go+0x8c>
      mkdir("/../b");
     34c:	00001517          	auipc	a0,0x1
     350:	ec450513          	addi	a0,a0,-316 # 1210 <malloc+0x198>
     354:	0b9000ef          	jal	ra,c0c <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     358:	20200593          	li	a1,514
     35c:	00001517          	auipc	a0,0x1
     360:	ebc50513          	addi	a0,a0,-324 # 1218 <malloc+0x1a0>
     364:	081000ef          	jal	ra,be4 <open>
     368:	065000ef          	jal	ra,bcc <close>
      unlink("b/b");
     36c:	00001517          	auipc	a0,0x1
     370:	ebc50513          	addi	a0,a0,-324 # 1228 <malloc+0x1b0>
     374:	081000ef          	jal	ra,bf4 <unlink>
     378:	b361                	j	100 <go+0x8c>
      unlink("b");
     37a:	00001517          	auipc	a0,0x1
     37e:	e7650513          	addi	a0,a0,-394 # 11f0 <malloc+0x178>
     382:	073000ef          	jal	ra,bf4 <unlink>
      link("../grindir/./../a", "../b");
     386:	00001597          	auipc	a1,0x1
     38a:	e4258593          	addi	a1,a1,-446 # 11c8 <malloc+0x150>
     38e:	00001517          	auipc	a0,0x1
     392:	ea250513          	addi	a0,a0,-350 # 1230 <malloc+0x1b8>
     396:	06f000ef          	jal	ra,c04 <link>
     39a:	b39d                	j	100 <go+0x8c>
      unlink("../grindir/../a");
     39c:	00001517          	auipc	a0,0x1
     3a0:	eac50513          	addi	a0,a0,-340 # 1248 <malloc+0x1d0>
     3a4:	051000ef          	jal	ra,bf4 <unlink>
      link(".././b", "/grindir/../a");
     3a8:	00001597          	auipc	a1,0x1
     3ac:	e2858593          	addi	a1,a1,-472 # 11d0 <malloc+0x158>
     3b0:	00001517          	auipc	a0,0x1
     3b4:	ea850513          	addi	a0,a0,-344 # 1258 <malloc+0x1e0>
     3b8:	04d000ef          	jal	ra,c04 <link>
     3bc:	b391                	j	100 <go+0x8c>
      int pid = fork();
     3be:	7de000ef          	jal	ra,b9c <fork>
      if(pid == 0){
     3c2:	c519                	beqz	a0,3d0 <go+0x35c>
      } else if(pid < 0){
     3c4:	00054863          	bltz	a0,3d4 <go+0x360>
      wait(0);
     3c8:	4501                	li	a0,0
     3ca:	7e2000ef          	jal	ra,bac <wait>
     3ce:	bb0d                	j	100 <go+0x8c>
        exit(0);
     3d0:	7d4000ef          	jal	ra,ba4 <exit>
        printf("grind: fork failed\n");
     3d4:	00001517          	auipc	a0,0x1
     3d8:	e8c50513          	addi	a0,a0,-372 # 1260 <malloc+0x1e8>
     3dc:	3e3000ef          	jal	ra,fbe <printf>
        exit(1);
     3e0:	4505                	li	a0,1
     3e2:	7c2000ef          	jal	ra,ba4 <exit>
      int pid = fork();
     3e6:	7b6000ef          	jal	ra,b9c <fork>
      if(pid == 0){
     3ea:	c519                	beqz	a0,3f8 <go+0x384>
      } else if(pid < 0){
     3ec:	00054d63          	bltz	a0,406 <go+0x392>
      wait(0);
     3f0:	4501                	li	a0,0
     3f2:	7ba000ef          	jal	ra,bac <wait>
     3f6:	b329                	j	100 <go+0x8c>
        fork();
     3f8:	7a4000ef          	jal	ra,b9c <fork>
        fork();
     3fc:	7a0000ef          	jal	ra,b9c <fork>
        exit(0);
     400:	4501                	li	a0,0
     402:	7a2000ef          	jal	ra,ba4 <exit>
        printf("grind: fork failed\n");
     406:	00001517          	auipc	a0,0x1
     40a:	e5a50513          	addi	a0,a0,-422 # 1260 <malloc+0x1e8>
     40e:	3b1000ef          	jal	ra,fbe <printf>
        exit(1);
     412:	4505                	li	a0,1
     414:	790000ef          	jal	ra,ba4 <exit>
      sbrk(6011);
     418:	6505                	lui	a0,0x1
     41a:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x32b>
     41e:	00f000ef          	jal	ra,c2c <sbrk>
     422:	b9f9                	j	100 <go+0x8c>
      if(sbrk(0) > break0)
     424:	4501                	li	a0,0
     426:	007000ef          	jal	ra,c2c <sbrk>
     42a:	ccaafbe3          	bgeu	s5,a0,100 <go+0x8c>
        sbrk(-(sbrk(0) - break0));
     42e:	4501                	li	a0,0
     430:	7fc000ef          	jal	ra,c2c <sbrk>
     434:	40aa853b          	subw	a0,s5,a0
     438:	7f4000ef          	jal	ra,c2c <sbrk>
     43c:	b1d1                	j	100 <go+0x8c>
      int pid = fork();
     43e:	75e000ef          	jal	ra,b9c <fork>
     442:	8b2a                	mv	s6,a0
      if(pid == 0){
     444:	c10d                	beqz	a0,466 <go+0x3f2>
      } else if(pid < 0){
     446:	02054d63          	bltz	a0,480 <go+0x40c>
      if(chdir("../grindir/..") != 0){
     44a:	00001517          	auipc	a0,0x1
     44e:	e2e50513          	addi	a0,a0,-466 # 1278 <malloc+0x200>
     452:	7c2000ef          	jal	ra,c14 <chdir>
     456:	ed15                	bnez	a0,492 <go+0x41e>
      kill(pid);
     458:	855a                	mv	a0,s6
     45a:	77a000ef          	jal	ra,bd4 <kill>
      wait(0);
     45e:	4501                	li	a0,0
     460:	74c000ef          	jal	ra,bac <wait>
     464:	b971                	j	100 <go+0x8c>
        close(open("a", O_CREATE|O_RDWR));
     466:	20200593          	li	a1,514
     46a:	00001517          	auipc	a0,0x1
     46e:	dd650513          	addi	a0,a0,-554 # 1240 <malloc+0x1c8>
     472:	772000ef          	jal	ra,be4 <open>
     476:	756000ef          	jal	ra,bcc <close>
        exit(0);
     47a:	4501                	li	a0,0
     47c:	728000ef          	jal	ra,ba4 <exit>
        printf("grind: fork failed\n");
     480:	00001517          	auipc	a0,0x1
     484:	de050513          	addi	a0,a0,-544 # 1260 <malloc+0x1e8>
     488:	337000ef          	jal	ra,fbe <printf>
        exit(1);
     48c:	4505                	li	a0,1
     48e:	716000ef          	jal	ra,ba4 <exit>
        printf("grind: chdir failed\n");
     492:	00001517          	auipc	a0,0x1
     496:	df650513          	addi	a0,a0,-522 # 1288 <malloc+0x210>
     49a:	325000ef          	jal	ra,fbe <printf>
        exit(1);
     49e:	4505                	li	a0,1
     4a0:	704000ef          	jal	ra,ba4 <exit>
      int pid = fork();
     4a4:	6f8000ef          	jal	ra,b9c <fork>
      if(pid == 0){
     4a8:	c519                	beqz	a0,4b6 <go+0x442>
      } else if(pid < 0){
     4aa:	00054d63          	bltz	a0,4c4 <go+0x450>
      wait(0);
     4ae:	4501                	li	a0,0
     4b0:	6fc000ef          	jal	ra,bac <wait>
     4b4:	b1b1                	j	100 <go+0x8c>
        kill(getpid());
     4b6:	76e000ef          	jal	ra,c24 <getpid>
     4ba:	71a000ef          	jal	ra,bd4 <kill>
        exit(0);
     4be:	4501                	li	a0,0
     4c0:	6e4000ef          	jal	ra,ba4 <exit>
        printf("grind: fork failed\n");
     4c4:	00001517          	auipc	a0,0x1
     4c8:	d9c50513          	addi	a0,a0,-612 # 1260 <malloc+0x1e8>
     4cc:	2f3000ef          	jal	ra,fbe <printf>
        exit(1);
     4d0:	4505                	li	a0,1
     4d2:	6d2000ef          	jal	ra,ba4 <exit>
      if(pipe(fds) < 0){
     4d6:	f9840513          	addi	a0,s0,-104
     4da:	6da000ef          	jal	ra,bb4 <pipe>
     4de:	02054363          	bltz	a0,504 <go+0x490>
      int pid = fork();
     4e2:	6ba000ef          	jal	ra,b9c <fork>
      if(pid == 0){
     4e6:	c905                	beqz	a0,516 <go+0x4a2>
      } else if(pid < 0){
     4e8:	08054263          	bltz	a0,56c <go+0x4f8>
      close(fds[0]);
     4ec:	f9842503          	lw	a0,-104(s0)
     4f0:	6dc000ef          	jal	ra,bcc <close>
      close(fds[1]);
     4f4:	f9c42503          	lw	a0,-100(s0)
     4f8:	6d4000ef          	jal	ra,bcc <close>
      wait(0);
     4fc:	4501                	li	a0,0
     4fe:	6ae000ef          	jal	ra,bac <wait>
     502:	befd                	j	100 <go+0x8c>
        printf("grind: pipe failed\n");
     504:	00001517          	auipc	a0,0x1
     508:	d9c50513          	addi	a0,a0,-612 # 12a0 <malloc+0x228>
     50c:	2b3000ef          	jal	ra,fbe <printf>
        exit(1);
     510:	4505                	li	a0,1
     512:	692000ef          	jal	ra,ba4 <exit>
        fork();
     516:	686000ef          	jal	ra,b9c <fork>
        fork();
     51a:	682000ef          	jal	ra,b9c <fork>
        if(write(fds[1], "x", 1) != 1)
     51e:	4605                	li	a2,1
     520:	00001597          	auipc	a1,0x1
     524:	d9858593          	addi	a1,a1,-616 # 12b8 <malloc+0x240>
     528:	f9c42503          	lw	a0,-100(s0)
     52c:	698000ef          	jal	ra,bc4 <write>
     530:	4785                	li	a5,1
     532:	00f51f63          	bne	a0,a5,550 <go+0x4dc>
        if(read(fds[0], &c, 1) != 1)
     536:	4605                	li	a2,1
     538:	f9040593          	addi	a1,s0,-112
     53c:	f9842503          	lw	a0,-104(s0)
     540:	67c000ef          	jal	ra,bbc <read>
     544:	4785                	li	a5,1
     546:	00f51c63          	bne	a0,a5,55e <go+0x4ea>
        exit(0);
     54a:	4501                	li	a0,0
     54c:	658000ef          	jal	ra,ba4 <exit>
          printf("grind: pipe write failed\n");
     550:	00001517          	auipc	a0,0x1
     554:	d7050513          	addi	a0,a0,-656 # 12c0 <malloc+0x248>
     558:	267000ef          	jal	ra,fbe <printf>
     55c:	bfe9                	j	536 <go+0x4c2>
          printf("grind: pipe read failed\n");
     55e:	00001517          	auipc	a0,0x1
     562:	d8250513          	addi	a0,a0,-638 # 12e0 <malloc+0x268>
     566:	259000ef          	jal	ra,fbe <printf>
     56a:	b7c5                	j	54a <go+0x4d6>
        printf("grind: fork failed\n");
     56c:	00001517          	auipc	a0,0x1
     570:	cf450513          	addi	a0,a0,-780 # 1260 <malloc+0x1e8>
     574:	24b000ef          	jal	ra,fbe <printf>
        exit(1);
     578:	4505                	li	a0,1
     57a:	62a000ef          	jal	ra,ba4 <exit>
      int pid = fork();
     57e:	61e000ef          	jal	ra,b9c <fork>
      if(pid == 0){
     582:	c519                	beqz	a0,590 <go+0x51c>
      } else if(pid < 0){
     584:	04054f63          	bltz	a0,5e2 <go+0x56e>
      wait(0);
     588:	4501                	li	a0,0
     58a:	622000ef          	jal	ra,bac <wait>
     58e:	be8d                	j	100 <go+0x8c>
        unlink("a");
     590:	00001517          	auipc	a0,0x1
     594:	cb050513          	addi	a0,a0,-848 # 1240 <malloc+0x1c8>
     598:	65c000ef          	jal	ra,bf4 <unlink>
        mkdir("a");
     59c:	00001517          	auipc	a0,0x1
     5a0:	ca450513          	addi	a0,a0,-860 # 1240 <malloc+0x1c8>
     5a4:	668000ef          	jal	ra,c0c <mkdir>
        chdir("a");
     5a8:	00001517          	auipc	a0,0x1
     5ac:	c9850513          	addi	a0,a0,-872 # 1240 <malloc+0x1c8>
     5b0:	664000ef          	jal	ra,c14 <chdir>
        unlink("../a");
     5b4:	00001517          	auipc	a0,0x1
     5b8:	bf450513          	addi	a0,a0,-1036 # 11a8 <malloc+0x130>
     5bc:	638000ef          	jal	ra,bf4 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     5c0:	20200593          	li	a1,514
     5c4:	00001517          	auipc	a0,0x1
     5c8:	cf450513          	addi	a0,a0,-780 # 12b8 <malloc+0x240>
     5cc:	618000ef          	jal	ra,be4 <open>
        unlink("x");
     5d0:	00001517          	auipc	a0,0x1
     5d4:	ce850513          	addi	a0,a0,-792 # 12b8 <malloc+0x240>
     5d8:	61c000ef          	jal	ra,bf4 <unlink>
        exit(0);
     5dc:	4501                	li	a0,0
     5de:	5c6000ef          	jal	ra,ba4 <exit>
        printf("grind: fork failed\n");
     5e2:	00001517          	auipc	a0,0x1
     5e6:	c7e50513          	addi	a0,a0,-898 # 1260 <malloc+0x1e8>
     5ea:	1d5000ef          	jal	ra,fbe <printf>
        exit(1);
     5ee:	4505                	li	a0,1
     5f0:	5b4000ef          	jal	ra,ba4 <exit>
      unlink("c");
     5f4:	00001517          	auipc	a0,0x1
     5f8:	d0c50513          	addi	a0,a0,-756 # 1300 <malloc+0x288>
     5fc:	5f8000ef          	jal	ra,bf4 <unlink>
      int fd1 = open("c", O_CREATE|O_RDWR);
     600:	20200593          	li	a1,514
     604:	00001517          	auipc	a0,0x1
     608:	cfc50513          	addi	a0,a0,-772 # 1300 <malloc+0x288>
     60c:	5d8000ef          	jal	ra,be4 <open>
     610:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     612:	04054763          	bltz	a0,660 <go+0x5ec>
      if(write(fd1, "x", 1) != 1){
     616:	4605                	li	a2,1
     618:	00001597          	auipc	a1,0x1
     61c:	ca058593          	addi	a1,a1,-864 # 12b8 <malloc+0x240>
     620:	5a4000ef          	jal	ra,bc4 <write>
     624:	4785                	li	a5,1
     626:	04f51663          	bne	a0,a5,672 <go+0x5fe>
      if(fstat(fd1, &st) != 0){
     62a:	f9840593          	addi	a1,s0,-104
     62e:	855a                	mv	a0,s6
     630:	5cc000ef          	jal	ra,bfc <fstat>
     634:	e921                	bnez	a0,684 <go+0x610>
      if(st.size != 1){
     636:	fa843583          	ld	a1,-88(s0)
     63a:	4785                	li	a5,1
     63c:	04f59d63          	bne	a1,a5,696 <go+0x622>
      if(st.ino > 200){
     640:	f9c42583          	lw	a1,-100(s0)
     644:	0c800793          	li	a5,200
     648:	06b7e163          	bltu	a5,a1,6aa <go+0x636>
      close(fd1);
     64c:	855a                	mv	a0,s6
     64e:	57e000ef          	jal	ra,bcc <close>
      unlink("c");
     652:	00001517          	auipc	a0,0x1
     656:	cae50513          	addi	a0,a0,-850 # 1300 <malloc+0x288>
     65a:	59a000ef          	jal	ra,bf4 <unlink>
     65e:	b44d                	j	100 <go+0x8c>
        printf("grind: create c failed\n");
     660:	00001517          	auipc	a0,0x1
     664:	ca850513          	addi	a0,a0,-856 # 1308 <malloc+0x290>
     668:	157000ef          	jal	ra,fbe <printf>
        exit(1);
     66c:	4505                	li	a0,1
     66e:	536000ef          	jal	ra,ba4 <exit>
        printf("grind: write c failed\n");
     672:	00001517          	auipc	a0,0x1
     676:	cae50513          	addi	a0,a0,-850 # 1320 <malloc+0x2a8>
     67a:	145000ef          	jal	ra,fbe <printf>
        exit(1);
     67e:	4505                	li	a0,1
     680:	524000ef          	jal	ra,ba4 <exit>
        printf("grind: fstat failed\n");
     684:	00001517          	auipc	a0,0x1
     688:	cb450513          	addi	a0,a0,-844 # 1338 <malloc+0x2c0>
     68c:	133000ef          	jal	ra,fbe <printf>
        exit(1);
     690:	4505                	li	a0,1
     692:	512000ef          	jal	ra,ba4 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     696:	2581                	sext.w	a1,a1
     698:	00001517          	auipc	a0,0x1
     69c:	cb850513          	addi	a0,a0,-840 # 1350 <malloc+0x2d8>
     6a0:	11f000ef          	jal	ra,fbe <printf>
        exit(1);
     6a4:	4505                	li	a0,1
     6a6:	4fe000ef          	jal	ra,ba4 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     6aa:	00001517          	auipc	a0,0x1
     6ae:	cce50513          	addi	a0,a0,-818 # 1378 <malloc+0x300>
     6b2:	10d000ef          	jal	ra,fbe <printf>
        exit(1);
     6b6:	4505                	li	a0,1
     6b8:	4ec000ef          	jal	ra,ba4 <exit>
        fprintf(2, "grind: pipe failed\n");
     6bc:	00001597          	auipc	a1,0x1
     6c0:	be458593          	addi	a1,a1,-1052 # 12a0 <malloc+0x228>
     6c4:	4509                	li	a0,2
     6c6:	0cf000ef          	jal	ra,f94 <fprintf>
        exit(1);
     6ca:	4505                	li	a0,1
     6cc:	4d8000ef          	jal	ra,ba4 <exit>
        fprintf(2, "grind: pipe failed\n");
     6d0:	00001597          	auipc	a1,0x1
     6d4:	bd058593          	addi	a1,a1,-1072 # 12a0 <malloc+0x228>
     6d8:	4509                	li	a0,2
     6da:	0bb000ef          	jal	ra,f94 <fprintf>
        exit(1);
     6de:	4505                	li	a0,1
     6e0:	4c4000ef          	jal	ra,ba4 <exit>
        close(bb[0]);
     6e4:	f9042503          	lw	a0,-112(s0)
     6e8:	4e4000ef          	jal	ra,bcc <close>
        close(bb[1]);
     6ec:	f9442503          	lw	a0,-108(s0)
     6f0:	4dc000ef          	jal	ra,bcc <close>
        close(aa[0]);
     6f4:	f8842503          	lw	a0,-120(s0)
     6f8:	4d4000ef          	jal	ra,bcc <close>
        close(1);
     6fc:	4505                	li	a0,1
     6fe:	4ce000ef          	jal	ra,bcc <close>
        if(dup(aa[1]) != 1){
     702:	f8c42503          	lw	a0,-116(s0)
     706:	516000ef          	jal	ra,c1c <dup>
     70a:	4785                	li	a5,1
     70c:	00f50c63          	beq	a0,a5,724 <go+0x6b0>
          fprintf(2, "grind: dup failed\n");
     710:	00001597          	auipc	a1,0x1
     714:	c9058593          	addi	a1,a1,-880 # 13a0 <malloc+0x328>
     718:	4509                	li	a0,2
     71a:	07b000ef          	jal	ra,f94 <fprintf>
          exit(1);
     71e:	4505                	li	a0,1
     720:	484000ef          	jal	ra,ba4 <exit>
        close(aa[1]);
     724:	f8c42503          	lw	a0,-116(s0)
     728:	4a4000ef          	jal	ra,bcc <close>
        char *args[3] = { "echo", "hi", 0 };
     72c:	00001797          	auipc	a5,0x1
     730:	c8c78793          	addi	a5,a5,-884 # 13b8 <malloc+0x340>
     734:	f8f43c23          	sd	a5,-104(s0)
     738:	00001797          	auipc	a5,0x1
     73c:	c8878793          	addi	a5,a5,-888 # 13c0 <malloc+0x348>
     740:	faf43023          	sd	a5,-96(s0)
     744:	fa043423          	sd	zero,-88(s0)
        exec("grindir/../echo", args);
     748:	f9840593          	addi	a1,s0,-104
     74c:	00001517          	auipc	a0,0x1
     750:	c7c50513          	addi	a0,a0,-900 # 13c8 <malloc+0x350>
     754:	488000ef          	jal	ra,bdc <exec>
        fprintf(2, "grind: echo: not found\n");
     758:	00001597          	auipc	a1,0x1
     75c:	c8058593          	addi	a1,a1,-896 # 13d8 <malloc+0x360>
     760:	4509                	li	a0,2
     762:	033000ef          	jal	ra,f94 <fprintf>
        exit(2);
     766:	4509                	li	a0,2
     768:	43c000ef          	jal	ra,ba4 <exit>
        fprintf(2, "grind: fork failed\n");
     76c:	00001597          	auipc	a1,0x1
     770:	af458593          	addi	a1,a1,-1292 # 1260 <malloc+0x1e8>
     774:	4509                	li	a0,2
     776:	01f000ef          	jal	ra,f94 <fprintf>
        exit(3);
     77a:	450d                	li	a0,3
     77c:	428000ef          	jal	ra,ba4 <exit>
        close(aa[1]);
     780:	f8c42503          	lw	a0,-116(s0)
     784:	448000ef          	jal	ra,bcc <close>
        close(bb[0]);
     788:	f9042503          	lw	a0,-112(s0)
     78c:	440000ef          	jal	ra,bcc <close>
        close(0);
     790:	4501                	li	a0,0
     792:	43a000ef          	jal	ra,bcc <close>
        if(dup(aa[0]) != 0){
     796:	f8842503          	lw	a0,-120(s0)
     79a:	482000ef          	jal	ra,c1c <dup>
     79e:	c919                	beqz	a0,7b4 <go+0x740>
          fprintf(2, "grind: dup failed\n");
     7a0:	00001597          	auipc	a1,0x1
     7a4:	c0058593          	addi	a1,a1,-1024 # 13a0 <malloc+0x328>
     7a8:	4509                	li	a0,2
     7aa:	7ea000ef          	jal	ra,f94 <fprintf>
          exit(4);
     7ae:	4511                	li	a0,4
     7b0:	3f4000ef          	jal	ra,ba4 <exit>
        close(aa[0]);
     7b4:	f8842503          	lw	a0,-120(s0)
     7b8:	414000ef          	jal	ra,bcc <close>
        close(1);
     7bc:	4505                	li	a0,1
     7be:	40e000ef          	jal	ra,bcc <close>
        if(dup(bb[1]) != 1){
     7c2:	f9442503          	lw	a0,-108(s0)
     7c6:	456000ef          	jal	ra,c1c <dup>
     7ca:	4785                	li	a5,1
     7cc:	00f50c63          	beq	a0,a5,7e4 <go+0x770>
          fprintf(2, "grind: dup failed\n");
     7d0:	00001597          	auipc	a1,0x1
     7d4:	bd058593          	addi	a1,a1,-1072 # 13a0 <malloc+0x328>
     7d8:	4509                	li	a0,2
     7da:	7ba000ef          	jal	ra,f94 <fprintf>
          exit(5);
     7de:	4515                	li	a0,5
     7e0:	3c4000ef          	jal	ra,ba4 <exit>
        close(bb[1]);
     7e4:	f9442503          	lw	a0,-108(s0)
     7e8:	3e4000ef          	jal	ra,bcc <close>
        char *args[2] = { "cat", 0 };
     7ec:	00001797          	auipc	a5,0x1
     7f0:	c0478793          	addi	a5,a5,-1020 # 13f0 <malloc+0x378>
     7f4:	f8f43c23          	sd	a5,-104(s0)
     7f8:	fa043023          	sd	zero,-96(s0)
        exec("/cat", args);
     7fc:	f9840593          	addi	a1,s0,-104
     800:	00001517          	auipc	a0,0x1
     804:	bf850513          	addi	a0,a0,-1032 # 13f8 <malloc+0x380>
     808:	3d4000ef          	jal	ra,bdc <exec>
        fprintf(2, "grind: cat: not found\n");
     80c:	00001597          	auipc	a1,0x1
     810:	bf458593          	addi	a1,a1,-1036 # 1400 <malloc+0x388>
     814:	4509                	li	a0,2
     816:	77e000ef          	jal	ra,f94 <fprintf>
        exit(6);
     81a:	4519                	li	a0,6
     81c:	388000ef          	jal	ra,ba4 <exit>
        fprintf(2, "grind: fork failed\n");
     820:	00001597          	auipc	a1,0x1
     824:	a4058593          	addi	a1,a1,-1472 # 1260 <malloc+0x1e8>
     828:	4509                	li	a0,2
     82a:	76a000ef          	jal	ra,f94 <fprintf>
        exit(7);
     82e:	451d                	li	a0,7
     830:	374000ef          	jal	ra,ba4 <exit>

0000000000000834 <iter>:
  }
}

void
iter()
{
     834:	7179                	addi	sp,sp,-48
     836:	f406                	sd	ra,40(sp)
     838:	f022                	sd	s0,32(sp)
     83a:	ec26                	sd	s1,24(sp)
     83c:	e84a                	sd	s2,16(sp)
     83e:	1800                	addi	s0,sp,48
  unlink("a");
     840:	00001517          	auipc	a0,0x1
     844:	a0050513          	addi	a0,a0,-1536 # 1240 <malloc+0x1c8>
     848:	3ac000ef          	jal	ra,bf4 <unlink>
  unlink("b");
     84c:	00001517          	auipc	a0,0x1
     850:	9a450513          	addi	a0,a0,-1628 # 11f0 <malloc+0x178>
     854:	3a0000ef          	jal	ra,bf4 <unlink>
  
  int pid1 = fork();
     858:	344000ef          	jal	ra,b9c <fork>
  if(pid1 < 0){
     85c:	00054f63          	bltz	a0,87a <iter+0x46>
     860:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     862:	e50d                	bnez	a0,88c <iter+0x58>
    rand_next ^= 31;
     864:	00001717          	auipc	a4,0x1
     868:	79c70713          	addi	a4,a4,1948 # 2000 <rand_next>
     86c:	631c                	ld	a5,0(a4)
     86e:	01f7c793          	xori	a5,a5,31
     872:	e31c                	sd	a5,0(a4)
    go(0);
     874:	4501                	li	a0,0
     876:	ffeff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     87a:	00001517          	auipc	a0,0x1
     87e:	9e650513          	addi	a0,a0,-1562 # 1260 <malloc+0x1e8>
     882:	73c000ef          	jal	ra,fbe <printf>
    exit(1);
     886:	4505                	li	a0,1
     888:	31c000ef          	jal	ra,ba4 <exit>
    exit(0);
  }

  int pid2 = fork();
     88c:	310000ef          	jal	ra,b9c <fork>
     890:	892a                	mv	s2,a0
  if(pid2 < 0){
     892:	02054063          	bltz	a0,8b2 <iter+0x7e>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     896:	e51d                	bnez	a0,8c4 <iter+0x90>
    rand_next ^= 7177;
     898:	00001697          	auipc	a3,0x1
     89c:	76868693          	addi	a3,a3,1896 # 2000 <rand_next>
     8a0:	629c                	ld	a5,0(a3)
     8a2:	6709                	lui	a4,0x2
     8a4:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x7b9>
     8a8:	8fb9                	xor	a5,a5,a4
     8aa:	e29c                	sd	a5,0(a3)
    go(1);
     8ac:	4505                	li	a0,1
     8ae:	fc6ff0ef          	jal	ra,74 <go>
    printf("grind: fork failed\n");
     8b2:	00001517          	auipc	a0,0x1
     8b6:	9ae50513          	addi	a0,a0,-1618 # 1260 <malloc+0x1e8>
     8ba:	704000ef          	jal	ra,fbe <printf>
    exit(1);
     8be:	4505                	li	a0,1
     8c0:	2e4000ef          	jal	ra,ba4 <exit>
    exit(0);
  }

  int st1 = -1;
     8c4:	57fd                	li	a5,-1
     8c6:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     8ca:	fdc40513          	addi	a0,s0,-36
     8ce:	2de000ef          	jal	ra,bac <wait>
  if(st1 != 0){
     8d2:	fdc42783          	lw	a5,-36(s0)
     8d6:	eb99                	bnez	a5,8ec <iter+0xb8>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     8d8:	57fd                	li	a5,-1
     8da:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     8de:	fd840513          	addi	a0,s0,-40
     8e2:	2ca000ef          	jal	ra,bac <wait>

  exit(0);
     8e6:	4501                	li	a0,0
     8e8:	2bc000ef          	jal	ra,ba4 <exit>
    kill(pid1);
     8ec:	8526                	mv	a0,s1
     8ee:	2e6000ef          	jal	ra,bd4 <kill>
    kill(pid2);
     8f2:	854a                	mv	a0,s2
     8f4:	2e0000ef          	jal	ra,bd4 <kill>
     8f8:	b7c5                	j	8d8 <iter+0xa4>

00000000000008fa <main>:
}

int
main()
{
     8fa:	1101                	addi	sp,sp,-32
     8fc:	ec06                	sd	ra,24(sp)
     8fe:	e822                	sd	s0,16(sp)
     900:	e426                	sd	s1,8(sp)
     902:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    sleep(20);
    rand_next += 1;
     904:	00001497          	auipc	s1,0x1
     908:	6fc48493          	addi	s1,s1,1788 # 2000 <rand_next>
     90c:	a809                	j	91e <main+0x24>
      iter();
     90e:	f27ff0ef          	jal	ra,834 <iter>
    sleep(20);
     912:	4551                	li	a0,20
     914:	320000ef          	jal	ra,c34 <sleep>
    rand_next += 1;
     918:	609c                	ld	a5,0(s1)
     91a:	0785                	addi	a5,a5,1
     91c:	e09c                	sd	a5,0(s1)
    int pid = fork();
     91e:	27e000ef          	jal	ra,b9c <fork>
    if(pid == 0){
     922:	d575                	beqz	a0,90e <main+0x14>
    if(pid > 0){
     924:	fea057e3          	blez	a0,912 <main+0x18>
      wait(0);
     928:	4501                	li	a0,0
     92a:	282000ef          	jal	ra,bac <wait>
     92e:	b7d5                	j	912 <main+0x18>

0000000000000930 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
     930:	1141                	addi	sp,sp,-16
     932:	e406                	sd	ra,8(sp)
     934:	e022                	sd	s0,0(sp)
     936:	0800                	addi	s0,sp,16
  extern int main();
  main();
     938:	fc3ff0ef          	jal	ra,8fa <main>
  exit(0);
     93c:	4501                	li	a0,0
     93e:	266000ef          	jal	ra,ba4 <exit>

0000000000000942 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     942:	1141                	addi	sp,sp,-16
     944:	e422                	sd	s0,8(sp)
     946:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     948:	87aa                	mv	a5,a0
     94a:	0585                	addi	a1,a1,1
     94c:	0785                	addi	a5,a5,1
     94e:	fff5c703          	lbu	a4,-1(a1)
     952:	fee78fa3          	sb	a4,-1(a5)
     956:	fb75                	bnez	a4,94a <strcpy+0x8>
    ;
  return os;
}
     958:	6422                	ld	s0,8(sp)
     95a:	0141                	addi	sp,sp,16
     95c:	8082                	ret

000000000000095e <strcmp>:

int
strcmp(const char *p, const char *q)
{
     95e:	1141                	addi	sp,sp,-16
     960:	e422                	sd	s0,8(sp)
     962:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     964:	00054783          	lbu	a5,0(a0)
     968:	cb91                	beqz	a5,97c <strcmp+0x1e>
     96a:	0005c703          	lbu	a4,0(a1)
     96e:	00f71763          	bne	a4,a5,97c <strcmp+0x1e>
    p++, q++;
     972:	0505                	addi	a0,a0,1
     974:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     976:	00054783          	lbu	a5,0(a0)
     97a:	fbe5                	bnez	a5,96a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     97c:	0005c503          	lbu	a0,0(a1)
}
     980:	40a7853b          	subw	a0,a5,a0
     984:	6422                	ld	s0,8(sp)
     986:	0141                	addi	sp,sp,16
     988:	8082                	ret

000000000000098a <strlen>:

uint
strlen(const char *s)
{
     98a:	1141                	addi	sp,sp,-16
     98c:	e422                	sd	s0,8(sp)
     98e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     990:	00054783          	lbu	a5,0(a0)
     994:	cf91                	beqz	a5,9b0 <strlen+0x26>
     996:	0505                	addi	a0,a0,1
     998:	87aa                	mv	a5,a0
     99a:	4685                	li	a3,1
     99c:	9e89                	subw	a3,a3,a0
     99e:	00f6853b          	addw	a0,a3,a5
     9a2:	0785                	addi	a5,a5,1
     9a4:	fff7c703          	lbu	a4,-1(a5)
     9a8:	fb7d                	bnez	a4,99e <strlen+0x14>
    ;
  return n;
}
     9aa:	6422                	ld	s0,8(sp)
     9ac:	0141                	addi	sp,sp,16
     9ae:	8082                	ret
  for(n = 0; s[n]; n++)
     9b0:	4501                	li	a0,0
     9b2:	bfe5                	j	9aa <strlen+0x20>

00000000000009b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
     9b4:	1141                	addi	sp,sp,-16
     9b6:	e422                	sd	s0,8(sp)
     9b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     9ba:	ce09                	beqz	a2,9d4 <memset+0x20>
     9bc:	87aa                	mv	a5,a0
     9be:	fff6071b          	addiw	a4,a2,-1
     9c2:	1702                	slli	a4,a4,0x20
     9c4:	9301                	srli	a4,a4,0x20
     9c6:	0705                	addi	a4,a4,1
     9c8:	972a                	add	a4,a4,a0
    cdst[i] = c;
     9ca:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     9ce:	0785                	addi	a5,a5,1
     9d0:	fee79de3          	bne	a5,a4,9ca <memset+0x16>
  }
  return dst;
}
     9d4:	6422                	ld	s0,8(sp)
     9d6:	0141                	addi	sp,sp,16
     9d8:	8082                	ret

00000000000009da <strchr>:

char*
strchr(const char *s, char c)
{
     9da:	1141                	addi	sp,sp,-16
     9dc:	e422                	sd	s0,8(sp)
     9de:	0800                	addi	s0,sp,16
  for(; *s; s++)
     9e0:	00054783          	lbu	a5,0(a0)
     9e4:	cb99                	beqz	a5,9fa <strchr+0x20>
    if(*s == c)
     9e6:	00f58763          	beq	a1,a5,9f4 <strchr+0x1a>
  for(; *s; s++)
     9ea:	0505                	addi	a0,a0,1
     9ec:	00054783          	lbu	a5,0(a0)
     9f0:	fbfd                	bnez	a5,9e6 <strchr+0xc>
      return (char*)s;
  return 0;
     9f2:	4501                	li	a0,0
}
     9f4:	6422                	ld	s0,8(sp)
     9f6:	0141                	addi	sp,sp,16
     9f8:	8082                	ret
  return 0;
     9fa:	4501                	li	a0,0
     9fc:	bfe5                	j	9f4 <strchr+0x1a>

00000000000009fe <gets>:

char*
gets(char *buf, int max)
{
     9fe:	711d                	addi	sp,sp,-96
     a00:	ec86                	sd	ra,88(sp)
     a02:	e8a2                	sd	s0,80(sp)
     a04:	e4a6                	sd	s1,72(sp)
     a06:	e0ca                	sd	s2,64(sp)
     a08:	fc4e                	sd	s3,56(sp)
     a0a:	f852                	sd	s4,48(sp)
     a0c:	f456                	sd	s5,40(sp)
     a0e:	f05a                	sd	s6,32(sp)
     a10:	ec5e                	sd	s7,24(sp)
     a12:	1080                	addi	s0,sp,96
     a14:	8baa                	mv	s7,a0
     a16:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a18:	892a                	mv	s2,a0
     a1a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a1c:	4aa9                	li	s5,10
     a1e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a20:	89a6                	mv	s3,s1
     a22:	2485                	addiw	s1,s1,1
     a24:	0344d663          	bge	s1,s4,a50 <gets+0x52>
    cc = read(0, &c, 1);
     a28:	4605                	li	a2,1
     a2a:	faf40593          	addi	a1,s0,-81
     a2e:	4501                	li	a0,0
     a30:	18c000ef          	jal	ra,bbc <read>
    if(cc < 1)
     a34:	00a05e63          	blez	a0,a50 <gets+0x52>
    buf[i++] = c;
     a38:	faf44783          	lbu	a5,-81(s0)
     a3c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     a40:	01578763          	beq	a5,s5,a4e <gets+0x50>
     a44:	0905                	addi	s2,s2,1
     a46:	fd679de3          	bne	a5,s6,a20 <gets+0x22>
  for(i=0; i+1 < max; ){
     a4a:	89a6                	mv	s3,s1
     a4c:	a011                	j	a50 <gets+0x52>
     a4e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a50:	99de                	add	s3,s3,s7
     a52:	00098023          	sb	zero,0(s3)
  return buf;
}
     a56:	855e                	mv	a0,s7
     a58:	60e6                	ld	ra,88(sp)
     a5a:	6446                	ld	s0,80(sp)
     a5c:	64a6                	ld	s1,72(sp)
     a5e:	6906                	ld	s2,64(sp)
     a60:	79e2                	ld	s3,56(sp)
     a62:	7a42                	ld	s4,48(sp)
     a64:	7aa2                	ld	s5,40(sp)
     a66:	7b02                	ld	s6,32(sp)
     a68:	6be2                	ld	s7,24(sp)
     a6a:	6125                	addi	sp,sp,96
     a6c:	8082                	ret

0000000000000a6e <stat>:

int
stat(const char *n, struct stat *st)
{
     a6e:	1101                	addi	sp,sp,-32
     a70:	ec06                	sd	ra,24(sp)
     a72:	e822                	sd	s0,16(sp)
     a74:	e426                	sd	s1,8(sp)
     a76:	e04a                	sd	s2,0(sp)
     a78:	1000                	addi	s0,sp,32
     a7a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a7c:	4581                	li	a1,0
     a7e:	166000ef          	jal	ra,be4 <open>
  if(fd < 0)
     a82:	02054163          	bltz	a0,aa4 <stat+0x36>
     a86:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a88:	85ca                	mv	a1,s2
     a8a:	172000ef          	jal	ra,bfc <fstat>
     a8e:	892a                	mv	s2,a0
  close(fd);
     a90:	8526                	mv	a0,s1
     a92:	13a000ef          	jal	ra,bcc <close>
  return r;
}
     a96:	854a                	mv	a0,s2
     a98:	60e2                	ld	ra,24(sp)
     a9a:	6442                	ld	s0,16(sp)
     a9c:	64a2                	ld	s1,8(sp)
     a9e:	6902                	ld	s2,0(sp)
     aa0:	6105                	addi	sp,sp,32
     aa2:	8082                	ret
    return -1;
     aa4:	597d                	li	s2,-1
     aa6:	bfc5                	j	a96 <stat+0x28>

0000000000000aa8 <atoi>:

int
atoi(const char *s)
{
     aa8:	1141                	addi	sp,sp,-16
     aaa:	e422                	sd	s0,8(sp)
     aac:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     aae:	00054603          	lbu	a2,0(a0)
     ab2:	fd06079b          	addiw	a5,a2,-48
     ab6:	0ff7f793          	andi	a5,a5,255
     aba:	4725                	li	a4,9
     abc:	02f76963          	bltu	a4,a5,aee <atoi+0x46>
     ac0:	86aa                	mv	a3,a0
  n = 0;
     ac2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     ac4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     ac6:	0685                	addi	a3,a3,1
     ac8:	0025179b          	slliw	a5,a0,0x2
     acc:	9fa9                	addw	a5,a5,a0
     ace:	0017979b          	slliw	a5,a5,0x1
     ad2:	9fb1                	addw	a5,a5,a2
     ad4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ad8:	0006c603          	lbu	a2,0(a3)
     adc:	fd06071b          	addiw	a4,a2,-48
     ae0:	0ff77713          	andi	a4,a4,255
     ae4:	fee5f1e3          	bgeu	a1,a4,ac6 <atoi+0x1e>
  return n;
}
     ae8:	6422                	ld	s0,8(sp)
     aea:	0141                	addi	sp,sp,16
     aec:	8082                	ret
  n = 0;
     aee:	4501                	li	a0,0
     af0:	bfe5                	j	ae8 <atoi+0x40>

0000000000000af2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     af2:	1141                	addi	sp,sp,-16
     af4:	e422                	sd	s0,8(sp)
     af6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     af8:	02b57663          	bgeu	a0,a1,b24 <memmove+0x32>
    while(n-- > 0)
     afc:	02c05163          	blez	a2,b1e <memmove+0x2c>
     b00:	fff6079b          	addiw	a5,a2,-1
     b04:	1782                	slli	a5,a5,0x20
     b06:	9381                	srli	a5,a5,0x20
     b08:	0785                	addi	a5,a5,1
     b0a:	97aa                	add	a5,a5,a0
  dst = vdst;
     b0c:	872a                	mv	a4,a0
      *dst++ = *src++;
     b0e:	0585                	addi	a1,a1,1
     b10:	0705                	addi	a4,a4,1
     b12:	fff5c683          	lbu	a3,-1(a1)
     b16:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b1a:	fee79ae3          	bne	a5,a4,b0e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b1e:	6422                	ld	s0,8(sp)
     b20:	0141                	addi	sp,sp,16
     b22:	8082                	ret
    dst += n;
     b24:	00c50733          	add	a4,a0,a2
    src += n;
     b28:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b2a:	fec05ae3          	blez	a2,b1e <memmove+0x2c>
     b2e:	fff6079b          	addiw	a5,a2,-1
     b32:	1782                	slli	a5,a5,0x20
     b34:	9381                	srli	a5,a5,0x20
     b36:	fff7c793          	not	a5,a5
     b3a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b3c:	15fd                	addi	a1,a1,-1
     b3e:	177d                	addi	a4,a4,-1
     b40:	0005c683          	lbu	a3,0(a1)
     b44:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b48:	fee79ae3          	bne	a5,a4,b3c <memmove+0x4a>
     b4c:	bfc9                	j	b1e <memmove+0x2c>

0000000000000b4e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     b4e:	1141                	addi	sp,sp,-16
     b50:	e422                	sd	s0,8(sp)
     b52:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     b54:	ca05                	beqz	a2,b84 <memcmp+0x36>
     b56:	fff6069b          	addiw	a3,a2,-1
     b5a:	1682                	slli	a3,a3,0x20
     b5c:	9281                	srli	a3,a3,0x20
     b5e:	0685                	addi	a3,a3,1
     b60:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b62:	00054783          	lbu	a5,0(a0)
     b66:	0005c703          	lbu	a4,0(a1)
     b6a:	00e79863          	bne	a5,a4,b7a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b6e:	0505                	addi	a0,a0,1
    p2++;
     b70:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b72:	fed518e3          	bne	a0,a3,b62 <memcmp+0x14>
  }
  return 0;
     b76:	4501                	li	a0,0
     b78:	a019                	j	b7e <memcmp+0x30>
      return *p1 - *p2;
     b7a:	40e7853b          	subw	a0,a5,a4
}
     b7e:	6422                	ld	s0,8(sp)
     b80:	0141                	addi	sp,sp,16
     b82:	8082                	ret
  return 0;
     b84:	4501                	li	a0,0
     b86:	bfe5                	j	b7e <memcmp+0x30>

0000000000000b88 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b88:	1141                	addi	sp,sp,-16
     b8a:	e406                	sd	ra,8(sp)
     b8c:	e022                	sd	s0,0(sp)
     b8e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b90:	f63ff0ef          	jal	ra,af2 <memmove>
}
     b94:	60a2                	ld	ra,8(sp)
     b96:	6402                	ld	s0,0(sp)
     b98:	0141                	addi	sp,sp,16
     b9a:	8082                	ret

0000000000000b9c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     b9c:	4885                	li	a7,1
 ecall
     b9e:	00000073          	ecall
 ret
     ba2:	8082                	ret

0000000000000ba4 <exit>:
.global exit
exit:
 li a7, SYS_exit
     ba4:	4889                	li	a7,2
 ecall
     ba6:	00000073          	ecall
 ret
     baa:	8082                	ret

0000000000000bac <wait>:
.global wait
wait:
 li a7, SYS_wait
     bac:	488d                	li	a7,3
 ecall
     bae:	00000073          	ecall
 ret
     bb2:	8082                	ret

0000000000000bb4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     bb4:	4891                	li	a7,4
 ecall
     bb6:	00000073          	ecall
 ret
     bba:	8082                	ret

0000000000000bbc <read>:
.global read
read:
 li a7, SYS_read
     bbc:	4895                	li	a7,5
 ecall
     bbe:	00000073          	ecall
 ret
     bc2:	8082                	ret

0000000000000bc4 <write>:
.global write
write:
 li a7, SYS_write
     bc4:	48c1                	li	a7,16
 ecall
     bc6:	00000073          	ecall
 ret
     bca:	8082                	ret

0000000000000bcc <close>:
.global close
close:
 li a7, SYS_close
     bcc:	48d5                	li	a7,21
 ecall
     bce:	00000073          	ecall
 ret
     bd2:	8082                	ret

0000000000000bd4 <kill>:
.global kill
kill:
 li a7, SYS_kill
     bd4:	4899                	li	a7,6
 ecall
     bd6:	00000073          	ecall
 ret
     bda:	8082                	ret

0000000000000bdc <exec>:
.global exec
exec:
 li a7, SYS_exec
     bdc:	489d                	li	a7,7
 ecall
     bde:	00000073          	ecall
 ret
     be2:	8082                	ret

0000000000000be4 <open>:
.global open
open:
 li a7, SYS_open
     be4:	48bd                	li	a7,15
 ecall
     be6:	00000073          	ecall
 ret
     bea:	8082                	ret

0000000000000bec <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     bec:	48c5                	li	a7,17
 ecall
     bee:	00000073          	ecall
 ret
     bf2:	8082                	ret

0000000000000bf4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     bf4:	48c9                	li	a7,18
 ecall
     bf6:	00000073          	ecall
 ret
     bfa:	8082                	ret

0000000000000bfc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     bfc:	48a1                	li	a7,8
 ecall
     bfe:	00000073          	ecall
 ret
     c02:	8082                	ret

0000000000000c04 <link>:
.global link
link:
 li a7, SYS_link
     c04:	48cd                	li	a7,19
 ecall
     c06:	00000073          	ecall
 ret
     c0a:	8082                	ret

0000000000000c0c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c0c:	48d1                	li	a7,20
 ecall
     c0e:	00000073          	ecall
 ret
     c12:	8082                	ret

0000000000000c14 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c14:	48a5                	li	a7,9
 ecall
     c16:	00000073          	ecall
 ret
     c1a:	8082                	ret

0000000000000c1c <dup>:
.global dup
dup:
 li a7, SYS_dup
     c1c:	48a9                	li	a7,10
 ecall
     c1e:	00000073          	ecall
 ret
     c22:	8082                	ret

0000000000000c24 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c24:	48ad                	li	a7,11
 ecall
     c26:	00000073          	ecall
 ret
     c2a:	8082                	ret

0000000000000c2c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     c2c:	48b1                	li	a7,12
 ecall
     c2e:	00000073          	ecall
 ret
     c32:	8082                	ret

0000000000000c34 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     c34:	48b5                	li	a7,13
 ecall
     c36:	00000073          	ecall
 ret
     c3a:	8082                	ret

0000000000000c3c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c3c:	48b9                	li	a7,14
 ecall
     c3e:	00000073          	ecall
 ret
     c42:	8082                	ret

0000000000000c44 <ugetpid>:
.global ugetpid
ugetpid:
 li a7, SYS_ugetpid
     c44:	48d9                	li	a7,22
 ecall
     c46:	00000073          	ecall
 ret
     c4a:	8082                	ret

0000000000000c4c <pgaccess>:
.global pgaccess
pgaccess:
 li a7, SYS_pgaccess
     c4c:	48dd                	li	a7,23
 ecall
     c4e:	00000073          	ecall
 ret
     c52:	8082                	ret

0000000000000c54 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c54:	1101                	addi	sp,sp,-32
     c56:	ec06                	sd	ra,24(sp)
     c58:	e822                	sd	s0,16(sp)
     c5a:	1000                	addi	s0,sp,32
     c5c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c60:	4605                	li	a2,1
     c62:	fef40593          	addi	a1,s0,-17
     c66:	f5fff0ef          	jal	ra,bc4 <write>
}
     c6a:	60e2                	ld	ra,24(sp)
     c6c:	6442                	ld	s0,16(sp)
     c6e:	6105                	addi	sp,sp,32
     c70:	8082                	ret

0000000000000c72 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c72:	715d                	addi	sp,sp,-80
     c74:	e486                	sd	ra,72(sp)
     c76:	e0a2                	sd	s0,64(sp)
     c78:	fc26                	sd	s1,56(sp)
     c7a:	f84a                	sd	s2,48(sp)
     c7c:	f44e                	sd	s3,40(sp)
     c7e:	0880                	addi	s0,sp,80
     c80:	84aa                	mv	s1,a0
  char buf[20];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     c82:	c299                	beqz	a3,c88 <printint+0x16>
     c84:	0805c663          	bltz	a1,d10 <printint+0x9e>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     c88:	2581                	sext.w	a1,a1
  neg = 0;
     c8a:	4881                	li	a7,0
     c8c:	fb840693          	addi	a3,s0,-72
  }

  i = 0;
     c90:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
     c92:	2601                	sext.w	a2,a2
     c94:	00000517          	auipc	a0,0x0
     c98:	7bc50513          	addi	a0,a0,1980 # 1450 <digits>
     c9c:	883a                	mv	a6,a4
     c9e:	2705                	addiw	a4,a4,1
     ca0:	02c5f7bb          	remuw	a5,a1,a2
     ca4:	1782                	slli	a5,a5,0x20
     ca6:	9381                	srli	a5,a5,0x20
     ca8:	97aa                	add	a5,a5,a0
     caa:	0007c783          	lbu	a5,0(a5)
     cae:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
     cb2:	0005879b          	sext.w	a5,a1
     cb6:	02c5d5bb          	divuw	a1,a1,a2
     cba:	0685                	addi	a3,a3,1
     cbc:	fec7f0e3          	bgeu	a5,a2,c9c <printint+0x2a>
  if(neg)
     cc0:	00088b63          	beqz	a7,cd6 <printint+0x64>
    buf[i++] = '-';
     cc4:	fd040793          	addi	a5,s0,-48
     cc8:	973e                	add	a4,a4,a5
     cca:	02d00793          	li	a5,45
     cce:	fef70423          	sb	a5,-24(a4)
     cd2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
     cd6:	02e05663          	blez	a4,d02 <printint+0x90>
     cda:	fb840793          	addi	a5,s0,-72
     cde:	00e78933          	add	s2,a5,a4
     ce2:	fff78993          	addi	s3,a5,-1
     ce6:	99ba                	add	s3,s3,a4
     ce8:	377d                	addiw	a4,a4,-1
     cea:	1702                	slli	a4,a4,0x20
     cec:	9301                	srli	a4,a4,0x20
     cee:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
     cf2:	fff94583          	lbu	a1,-1(s2)
     cf6:	8526                	mv	a0,s1
     cf8:	f5dff0ef          	jal	ra,c54 <putc>
  while(--i >= 0)
     cfc:	197d                	addi	s2,s2,-1
     cfe:	ff391ae3          	bne	s2,s3,cf2 <printint+0x80>
}
     d02:	60a6                	ld	ra,72(sp)
     d04:	6406                	ld	s0,64(sp)
     d06:	74e2                	ld	s1,56(sp)
     d08:	7942                	ld	s2,48(sp)
     d0a:	79a2                	ld	s3,40(sp)
     d0c:	6161                	addi	sp,sp,80
     d0e:	8082                	ret
    x = -xx;
     d10:	40b005bb          	negw	a1,a1
    neg = 1;
     d14:	4885                	li	a7,1
    x = -xx;
     d16:	bf9d                	j	c8c <printint+0x1a>

0000000000000d18 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d18:	7119                	addi	sp,sp,-128
     d1a:	fc86                	sd	ra,120(sp)
     d1c:	f8a2                	sd	s0,112(sp)
     d1e:	f4a6                	sd	s1,104(sp)
     d20:	f0ca                	sd	s2,96(sp)
     d22:	ecce                	sd	s3,88(sp)
     d24:	e8d2                	sd	s4,80(sp)
     d26:	e4d6                	sd	s5,72(sp)
     d28:	e0da                	sd	s6,64(sp)
     d2a:	fc5e                	sd	s7,56(sp)
     d2c:	f862                	sd	s8,48(sp)
     d2e:	f466                	sd	s9,40(sp)
     d30:	f06a                	sd	s10,32(sp)
     d32:	ec6e                	sd	s11,24(sp)
     d34:	0100                	addi	s0,sp,128
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d36:	0005c903          	lbu	s2,0(a1)
     d3a:	22090e63          	beqz	s2,f76 <vprintf+0x25e>
     d3e:	8b2a                	mv	s6,a0
     d40:	8a2e                	mv	s4,a1
     d42:	8bb2                	mv	s7,a2
  state = 0;
     d44:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d46:	4481                	li	s1,0
     d48:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d4a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d4e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d52:	06c00d13          	li	s10,108
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     d56:	07500d93          	li	s11,117
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d5a:	00000c97          	auipc	s9,0x0
     d5e:	6f6c8c93          	addi	s9,s9,1782 # 1450 <digits>
     d62:	a005                	j	d82 <vprintf+0x6a>
        putc(fd, c0);
     d64:	85ca                	mv	a1,s2
     d66:	855a                	mv	a0,s6
     d68:	eedff0ef          	jal	ra,c54 <putc>
     d6c:	a019                	j	d72 <vprintf+0x5a>
    } else if(state == '%'){
     d6e:	03598263          	beq	s3,s5,d92 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     d72:	2485                	addiw	s1,s1,1
     d74:	8726                	mv	a4,s1
     d76:	009a07b3          	add	a5,s4,s1
     d7a:	0007c903          	lbu	s2,0(a5)
     d7e:	1e090c63          	beqz	s2,f76 <vprintf+0x25e>
    c0 = fmt[i] & 0xff;
     d82:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d86:	fe0994e3          	bnez	s3,d6e <vprintf+0x56>
      if(c0 == '%'){
     d8a:	fd579de3          	bne	a5,s5,d64 <vprintf+0x4c>
        state = '%';
     d8e:	89be                	mv	s3,a5
     d90:	b7cd                	j	d72 <vprintf+0x5a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d92:	cfa5                	beqz	a5,e0a <vprintf+0xf2>
     d94:	00ea06b3          	add	a3,s4,a4
     d98:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d9c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d9e:	c681                	beqz	a3,da6 <vprintf+0x8e>
     da0:	9752                	add	a4,a4,s4
     da2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     da6:	03878a63          	beq	a5,s8,dda <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     daa:	05a78463          	beq	a5,s10,df2 <vprintf+0xda>
      } else if(c0 == 'u'){
     dae:	0db78763          	beq	a5,s11,e7c <vprintf+0x164>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     db2:	07800713          	li	a4,120
     db6:	10e78963          	beq	a5,a4,ec8 <vprintf+0x1b0>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     dba:	07000713          	li	a4,112
     dbe:	12e78e63          	beq	a5,a4,efa <vprintf+0x1e2>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
     dc2:	07300713          	li	a4,115
     dc6:	16e78b63          	beq	a5,a4,f3c <vprintf+0x224>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     dca:	05579063          	bne	a5,s5,e0a <vprintf+0xf2>
        putc(fd, '%');
     dce:	85d6                	mv	a1,s5
     dd0:	855a                	mv	a0,s6
     dd2:	e83ff0ef          	jal	ra,c54 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
     dd6:	4981                	li	s3,0
     dd8:	bf69                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 1);
     dda:	008b8913          	addi	s2,s7,8
     dde:	4685                	li	a3,1
     de0:	4629                	li	a2,10
     de2:	000ba583          	lw	a1,0(s7)
     de6:	855a                	mv	a0,s6
     de8:	e8bff0ef          	jal	ra,c72 <printint>
     dec:	8bca                	mv	s7,s2
      state = 0;
     dee:	4981                	li	s3,0
     df0:	b749                	j	d72 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'd'){
     df2:	03868663          	beq	a3,s8,e1e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     df6:	05a68163          	beq	a3,s10,e38 <vprintf+0x120>
      } else if(c0 == 'l' && c1 == 'u'){
     dfa:	09b68d63          	beq	a3,s11,e94 <vprintf+0x17c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     dfe:	03a68f63          	beq	a3,s10,e3c <vprintf+0x124>
      } else if(c0 == 'l' && c1 == 'x'){
     e02:	07800793          	li	a5,120
     e06:	0cf68d63          	beq	a3,a5,ee0 <vprintf+0x1c8>
        putc(fd, '%');
     e0a:	85d6                	mv	a1,s5
     e0c:	855a                	mv	a0,s6
     e0e:	e47ff0ef          	jal	ra,c54 <putc>
        putc(fd, c0);
     e12:	85ca                	mv	a1,s2
     e14:	855a                	mv	a0,s6
     e16:	e3fff0ef          	jal	ra,c54 <putc>
      state = 0;
     e1a:	4981                	li	s3,0
     e1c:	bf99                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e1e:	008b8913          	addi	s2,s7,8
     e22:	4685                	li	a3,1
     e24:	4629                	li	a2,10
     e26:	000bb583          	ld	a1,0(s7)
     e2a:	855a                	mv	a0,s6
     e2c:	e47ff0ef          	jal	ra,c72 <printint>
        i += 1;
     e30:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e32:	8bca                	mv	s7,s2
      state = 0;
     e34:	4981                	li	s3,0
        i += 1;
     e36:	bf35                	j	d72 <vprintf+0x5a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e38:	03860563          	beq	a2,s8,e62 <vprintf+0x14a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e3c:	07b60963          	beq	a2,s11,eae <vprintf+0x196>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e40:	07800793          	li	a5,120
     e44:	fcf613e3          	bne	a2,a5,e0a <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e48:	008b8913          	addi	s2,s7,8
     e4c:	4681                	li	a3,0
     e4e:	4641                	li	a2,16
     e50:	000bb583          	ld	a1,0(s7)
     e54:	855a                	mv	a0,s6
     e56:	e1dff0ef          	jal	ra,c72 <printint>
        i += 2;
     e5a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e5c:	8bca                	mv	s7,s2
      state = 0;
     e5e:	4981                	li	s3,0
        i += 2;
     e60:	bf09                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e62:	008b8913          	addi	s2,s7,8
     e66:	4685                	li	a3,1
     e68:	4629                	li	a2,10
     e6a:	000bb583          	ld	a1,0(s7)
     e6e:	855a                	mv	a0,s6
     e70:	e03ff0ef          	jal	ra,c72 <printint>
        i += 2;
     e74:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e76:	8bca                	mv	s7,s2
      state = 0;
     e78:	4981                	li	s3,0
        i += 2;
     e7a:	bde5                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 10, 0);
     e7c:	008b8913          	addi	s2,s7,8
     e80:	4681                	li	a3,0
     e82:	4629                	li	a2,10
     e84:	000ba583          	lw	a1,0(s7)
     e88:	855a                	mv	a0,s6
     e8a:	de9ff0ef          	jal	ra,c72 <printint>
     e8e:	8bca                	mv	s7,s2
      state = 0;
     e90:	4981                	li	s3,0
     e92:	b5c5                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e94:	008b8913          	addi	s2,s7,8
     e98:	4681                	li	a3,0
     e9a:	4629                	li	a2,10
     e9c:	000bb583          	ld	a1,0(s7)
     ea0:	855a                	mv	a0,s6
     ea2:	dd1ff0ef          	jal	ra,c72 <printint>
        i += 1;
     ea6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     ea8:	8bca                	mv	s7,s2
      state = 0;
     eaa:	4981                	li	s3,0
        i += 1;
     eac:	b5d9                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     eae:	008b8913          	addi	s2,s7,8
     eb2:	4681                	li	a3,0
     eb4:	4629                	li	a2,10
     eb6:	000bb583          	ld	a1,0(s7)
     eba:	855a                	mv	a0,s6
     ebc:	db7ff0ef          	jal	ra,c72 <printint>
        i += 2;
     ec0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     ec2:	8bca                	mv	s7,s2
      state = 0;
     ec4:	4981                	li	s3,0
        i += 2;
     ec6:	b575                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, int), 16, 0);
     ec8:	008b8913          	addi	s2,s7,8
     ecc:	4681                	li	a3,0
     ece:	4641                	li	a2,16
     ed0:	000ba583          	lw	a1,0(s7)
     ed4:	855a                	mv	a0,s6
     ed6:	d9dff0ef          	jal	ra,c72 <printint>
     eda:	8bca                	mv	s7,s2
      state = 0;
     edc:	4981                	li	s3,0
     ede:	bd51                	j	d72 <vprintf+0x5a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     ee0:	008b8913          	addi	s2,s7,8
     ee4:	4681                	li	a3,0
     ee6:	4641                	li	a2,16
     ee8:	000bb583          	ld	a1,0(s7)
     eec:	855a                	mv	a0,s6
     eee:	d85ff0ef          	jal	ra,c72 <printint>
        i += 1;
     ef2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     ef4:	8bca                	mv	s7,s2
      state = 0;
     ef6:	4981                	li	s3,0
        i += 1;
     ef8:	bdad                	j	d72 <vprintf+0x5a>
        printptr(fd, va_arg(ap, uint64));
     efa:	008b8793          	addi	a5,s7,8
     efe:	f8f43423          	sd	a5,-120(s0)
     f02:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f06:	03000593          	li	a1,48
     f0a:	855a                	mv	a0,s6
     f0c:	d49ff0ef          	jal	ra,c54 <putc>
  putc(fd, 'x');
     f10:	07800593          	li	a1,120
     f14:	855a                	mv	a0,s6
     f16:	d3fff0ef          	jal	ra,c54 <putc>
     f1a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f1c:	03c9d793          	srli	a5,s3,0x3c
     f20:	97e6                	add	a5,a5,s9
     f22:	0007c583          	lbu	a1,0(a5)
     f26:	855a                	mv	a0,s6
     f28:	d2dff0ef          	jal	ra,c54 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f2c:	0992                	slli	s3,s3,0x4
     f2e:	397d                	addiw	s2,s2,-1
     f30:	fe0916e3          	bnez	s2,f1c <vprintf+0x204>
        printptr(fd, va_arg(ap, uint64));
     f34:	f8843b83          	ld	s7,-120(s0)
      state = 0;
     f38:	4981                	li	s3,0
     f3a:	bd25                	j	d72 <vprintf+0x5a>
        if((s = va_arg(ap, char*)) == 0)
     f3c:	008b8993          	addi	s3,s7,8
     f40:	000bb903          	ld	s2,0(s7)
     f44:	00090f63          	beqz	s2,f62 <vprintf+0x24a>
        for(; *s; s++)
     f48:	00094583          	lbu	a1,0(s2)
     f4c:	c195                	beqz	a1,f70 <vprintf+0x258>
          putc(fd, *s);
     f4e:	855a                	mv	a0,s6
     f50:	d05ff0ef          	jal	ra,c54 <putc>
        for(; *s; s++)
     f54:	0905                	addi	s2,s2,1
     f56:	00094583          	lbu	a1,0(s2)
     f5a:	f9f5                	bnez	a1,f4e <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
     f5c:	8bce                	mv	s7,s3
      state = 0;
     f5e:	4981                	li	s3,0
     f60:	bd09                	j	d72 <vprintf+0x5a>
          s = "(null)";
     f62:	00000917          	auipc	s2,0x0
     f66:	4e690913          	addi	s2,s2,1254 # 1448 <malloc+0x3d0>
        for(; *s; s++)
     f6a:	02800593          	li	a1,40
     f6e:	b7c5                	j	f4e <vprintf+0x236>
        if((s = va_arg(ap, char*)) == 0)
     f70:	8bce                	mv	s7,s3
      state = 0;
     f72:	4981                	li	s3,0
     f74:	bbfd                	j	d72 <vprintf+0x5a>
    }
  }
}
     f76:	70e6                	ld	ra,120(sp)
     f78:	7446                	ld	s0,112(sp)
     f7a:	74a6                	ld	s1,104(sp)
     f7c:	7906                	ld	s2,96(sp)
     f7e:	69e6                	ld	s3,88(sp)
     f80:	6a46                	ld	s4,80(sp)
     f82:	6aa6                	ld	s5,72(sp)
     f84:	6b06                	ld	s6,64(sp)
     f86:	7be2                	ld	s7,56(sp)
     f88:	7c42                	ld	s8,48(sp)
     f8a:	7ca2                	ld	s9,40(sp)
     f8c:	7d02                	ld	s10,32(sp)
     f8e:	6de2                	ld	s11,24(sp)
     f90:	6109                	addi	sp,sp,128
     f92:	8082                	ret

0000000000000f94 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f94:	715d                	addi	sp,sp,-80
     f96:	ec06                	sd	ra,24(sp)
     f98:	e822                	sd	s0,16(sp)
     f9a:	1000                	addi	s0,sp,32
     f9c:	e010                	sd	a2,0(s0)
     f9e:	e414                	sd	a3,8(s0)
     fa0:	e818                	sd	a4,16(s0)
     fa2:	ec1c                	sd	a5,24(s0)
     fa4:	03043023          	sd	a6,32(s0)
     fa8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fac:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fb0:	8622                	mv	a2,s0
     fb2:	d67ff0ef          	jal	ra,d18 <vprintf>
}
     fb6:	60e2                	ld	ra,24(sp)
     fb8:	6442                	ld	s0,16(sp)
     fba:	6161                	addi	sp,sp,80
     fbc:	8082                	ret

0000000000000fbe <printf>:

void
printf(const char *fmt, ...)
{
     fbe:	711d                	addi	sp,sp,-96
     fc0:	ec06                	sd	ra,24(sp)
     fc2:	e822                	sd	s0,16(sp)
     fc4:	1000                	addi	s0,sp,32
     fc6:	e40c                	sd	a1,8(s0)
     fc8:	e810                	sd	a2,16(s0)
     fca:	ec14                	sd	a3,24(s0)
     fcc:	f018                	sd	a4,32(s0)
     fce:	f41c                	sd	a5,40(s0)
     fd0:	03043823          	sd	a6,48(s0)
     fd4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     fd8:	00840613          	addi	a2,s0,8
     fdc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     fe0:	85aa                	mv	a1,a0
     fe2:	4505                	li	a0,1
     fe4:	d35ff0ef          	jal	ra,d18 <vprintf>
}
     fe8:	60e2                	ld	ra,24(sp)
     fea:	6442                	ld	s0,16(sp)
     fec:	6125                	addi	sp,sp,96
     fee:	8082                	ret

0000000000000ff0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     ff0:	1141                	addi	sp,sp,-16
     ff2:	e422                	sd	s0,8(sp)
     ff4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     ff6:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     ffa:	00001797          	auipc	a5,0x1
     ffe:	0167b783          	ld	a5,22(a5) # 2010 <freep>
    1002:	a805                	j	1032 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    1004:	4618                	lw	a4,8(a2)
    1006:	9db9                	addw	a1,a1,a4
    1008:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    100c:	6398                	ld	a4,0(a5)
    100e:	6318                	ld	a4,0(a4)
    1010:	fee53823          	sd	a4,-16(a0)
    1014:	a091                	j	1058 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    1016:	ff852703          	lw	a4,-8(a0)
    101a:	9e39                	addw	a2,a2,a4
    101c:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    101e:	ff053703          	ld	a4,-16(a0)
    1022:	e398                	sd	a4,0(a5)
    1024:	a099                	j	106a <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1026:	6398                	ld	a4,0(a5)
    1028:	00e7e463          	bltu	a5,a4,1030 <free+0x40>
    102c:	00e6ea63          	bltu	a3,a4,1040 <free+0x50>
{
    1030:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1032:	fed7fae3          	bgeu	a5,a3,1026 <free+0x36>
    1036:	6398                	ld	a4,0(a5)
    1038:	00e6e463          	bltu	a3,a4,1040 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    103c:	fee7eae3          	bltu	a5,a4,1030 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
    1040:	ff852583          	lw	a1,-8(a0)
    1044:	6390                	ld	a2,0(a5)
    1046:	02059713          	slli	a4,a1,0x20
    104a:	9301                	srli	a4,a4,0x20
    104c:	0712                	slli	a4,a4,0x4
    104e:	9736                	add	a4,a4,a3
    1050:	fae60ae3          	beq	a2,a4,1004 <free+0x14>
    bp->s.ptr = p->s.ptr;
    1054:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    1058:	4790                	lw	a2,8(a5)
    105a:	02061713          	slli	a4,a2,0x20
    105e:	9301                	srli	a4,a4,0x20
    1060:	0712                	slli	a4,a4,0x4
    1062:	973e                	add	a4,a4,a5
    1064:	fae689e3          	beq	a3,a4,1016 <free+0x26>
  } else
    p->s.ptr = bp;
    1068:	e394                	sd	a3,0(a5)
  freep = p;
    106a:	00001717          	auipc	a4,0x1
    106e:	faf73323          	sd	a5,-90(a4) # 2010 <freep>
}
    1072:	6422                	ld	s0,8(sp)
    1074:	0141                	addi	sp,sp,16
    1076:	8082                	ret

0000000000001078 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    1078:	7139                	addi	sp,sp,-64
    107a:	fc06                	sd	ra,56(sp)
    107c:	f822                	sd	s0,48(sp)
    107e:	f426                	sd	s1,40(sp)
    1080:	f04a                	sd	s2,32(sp)
    1082:	ec4e                	sd	s3,24(sp)
    1084:	e852                	sd	s4,16(sp)
    1086:	e456                	sd	s5,8(sp)
    1088:	e05a                	sd	s6,0(sp)
    108a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    108c:	02051493          	slli	s1,a0,0x20
    1090:	9081                	srli	s1,s1,0x20
    1092:	04bd                	addi	s1,s1,15
    1094:	8091                	srli	s1,s1,0x4
    1096:	0014899b          	addiw	s3,s1,1
    109a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    109c:	00001517          	auipc	a0,0x1
    10a0:	f7453503          	ld	a0,-140(a0) # 2010 <freep>
    10a4:	c515                	beqz	a0,10d0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10a8:	4798                	lw	a4,8(a5)
    10aa:	02977f63          	bgeu	a4,s1,10e8 <malloc+0x70>
    10ae:	8a4e                	mv	s4,s3
    10b0:	0009871b          	sext.w	a4,s3
    10b4:	6685                	lui	a3,0x1
    10b6:	00d77363          	bgeu	a4,a3,10bc <malloc+0x44>
    10ba:	6a05                	lui	s4,0x1
    10bc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10c0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10c4:	00001917          	auipc	s2,0x1
    10c8:	f4c90913          	addi	s2,s2,-180 # 2010 <freep>
  if(p == (char*)-1)
    10cc:	5afd                	li	s5,-1
    10ce:	a0bd                	j	113c <malloc+0xc4>
    base.s.ptr = freep = prevp = &base;
    10d0:	00001797          	auipc	a5,0x1
    10d4:	33878793          	addi	a5,a5,824 # 2408 <base>
    10d8:	00001717          	auipc	a4,0x1
    10dc:	f2f73c23          	sd	a5,-200(a4) # 2010 <freep>
    10e0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    10e2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    10e6:	b7e1                	j	10ae <malloc+0x36>
      if(p->s.size == nunits)
    10e8:	02e48b63          	beq	s1,a4,111e <malloc+0xa6>
        p->s.size -= nunits;
    10ec:	4137073b          	subw	a4,a4,s3
    10f0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    10f2:	1702                	slli	a4,a4,0x20
    10f4:	9301                	srli	a4,a4,0x20
    10f6:	0712                	slli	a4,a4,0x4
    10f8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    10fa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    10fe:	00001717          	auipc	a4,0x1
    1102:	f0a73923          	sd	a0,-238(a4) # 2010 <freep>
      return (void*)(p + 1);
    1106:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    110a:	70e2                	ld	ra,56(sp)
    110c:	7442                	ld	s0,48(sp)
    110e:	74a2                	ld	s1,40(sp)
    1110:	7902                	ld	s2,32(sp)
    1112:	69e2                	ld	s3,24(sp)
    1114:	6a42                	ld	s4,16(sp)
    1116:	6aa2                	ld	s5,8(sp)
    1118:	6b02                	ld	s6,0(sp)
    111a:	6121                	addi	sp,sp,64
    111c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    111e:	6398                	ld	a4,0(a5)
    1120:	e118                	sd	a4,0(a0)
    1122:	bff1                	j	10fe <malloc+0x86>
  hp->s.size = nu;
    1124:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    1128:	0541                	addi	a0,a0,16
    112a:	ec7ff0ef          	jal	ra,ff0 <free>
  return freep;
    112e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1132:	dd61                	beqz	a0,110a <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    1134:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1136:	4798                	lw	a4,8(a5)
    1138:	fa9778e3          	bgeu	a4,s1,10e8 <malloc+0x70>
    if(p == freep)
    113c:	00093703          	ld	a4,0(s2)
    1140:	853e                	mv	a0,a5
    1142:	fef719e3          	bne	a4,a5,1134 <malloc+0xbc>
  p = sbrk(nu * sizeof(Header));
    1146:	8552                	mv	a0,s4
    1148:	ae5ff0ef          	jal	ra,c2c <sbrk>
  if(p == (char*)-1)
    114c:	fd551ce3          	bne	a0,s5,1124 <malloc+0xac>
        return 0;
    1150:	4501                	li	a0,0
    1152:	bf65                	j	110a <malloc+0x92>
