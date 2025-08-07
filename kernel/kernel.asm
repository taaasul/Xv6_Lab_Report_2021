
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00008117          	auipc	sp,0x8
    80000004:	95013103          	ld	sp,-1712(sp) # 80007950 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	ra,80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	0x14d,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffddb1f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	da678793          	addi	a5,a5,-602 # 80000e26 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	ra,8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	fc26                	sd	s1,56(sp)
    800000d8:	f84a                	sd	s2,48(sp)
    800000da:	f44e                	sd	s3,40(sp)
    800000dc:	f052                	sd	s4,32(sp)
    800000de:	ec56                	sd	s5,24(sp)
    800000e0:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000e2:	04c05263          	blez	a2,80000126 <consolewrite+0x56>
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	190020ef          	jal	ra,8000228a <either_copyin>
    800000fe:	01550a63          	beq	a0,s5,80000112 <consolewrite+0x42>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	7e8000ef          	jal	ra,800008ee <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
  }

  return i;
}
    80000112:	854a                	mv	a0,s2
    80000114:	60a6                	ld	ra,72(sp)
    80000116:	6406                	ld	s0,64(sp)
    80000118:	74e2                	ld	s1,56(sp)
    8000011a:	7942                	ld	s2,48(sp)
    8000011c:	79a2                	ld	s3,40(sp)
    8000011e:	7a02                	ld	s4,32(sp)
    80000120:	6ae2                	ld	s5,24(sp)
    80000122:	6161                	addi	sp,sp,80
    80000124:	8082                	ret
  for(i = 0; i < n; i++){
    80000126:	4901                	li	s2,0
    80000128:	b7ed                	j	80000112 <consolewrite+0x42>

000000008000012a <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000012a:	7119                	addi	sp,sp,-128
    8000012c:	fc86                	sd	ra,120(sp)
    8000012e:	f8a2                	sd	s0,112(sp)
    80000130:	f4a6                	sd	s1,104(sp)
    80000132:	f0ca                	sd	s2,96(sp)
    80000134:	ecce                	sd	s3,88(sp)
    80000136:	e8d2                	sd	s4,80(sp)
    80000138:	e4d6                	sd	s5,72(sp)
    8000013a:	e0da                	sd	s6,64(sp)
    8000013c:	fc5e                	sd	s7,56(sp)
    8000013e:	f862                	sd	s8,48(sp)
    80000140:	f466                	sd	s9,40(sp)
    80000142:	f06a                	sd	s10,32(sp)
    80000144:	ec6e                	sd	s11,24(sp)
    80000146:	0100                	addi	s0,sp,128
    80000148:	8b2a                	mv	s6,a0
    8000014a:	8aae                	mv	s5,a1
    8000014c:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000014e:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80000152:	00010517          	auipc	a0,0x10
    80000156:	85e50513          	addi	a0,a0,-1954 # 8000f9b0 <cons>
    8000015a:	24f000ef          	jal	ra,80000ba8 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000015e:	00010497          	auipc	s1,0x10
    80000162:	85248493          	addi	s1,s1,-1966 # 8000f9b0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000166:	89a6                	mv	s3,s1
    80000168:	00010917          	auipc	s2,0x10
    8000016c:	8e090913          	addi	s2,s2,-1824 # 8000fa48 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80000170:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000172:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80000174:	4da9                	li	s11,10
  while(n > 0){
    80000176:	07405363          	blez	s4,800001dc <consoleread+0xb2>
    while(cons.r == cons.w){
    8000017a:	0984a783          	lw	a5,152(s1)
    8000017e:	09c4a703          	lw	a4,156(s1)
    80000182:	02f71163          	bne	a4,a5,800001a4 <consoleread+0x7a>
      if(killed(myproc())){
    80000186:	796010ef          	jal	ra,8000191c <myproc>
    8000018a:	793010ef          	jal	ra,8000211c <killed>
    8000018e:	e125                	bnez	a0,800001ee <consoleread+0xc4>
      sleep(&cons.r, &cons.lock);
    80000190:	85ce                	mv	a1,s3
    80000192:	854a                	mv	a0,s2
    80000194:	551010ef          	jal	ra,80001ee4 <sleep>
    while(cons.r == cons.w){
    80000198:	0984a783          	lw	a5,152(s1)
    8000019c:	09c4a703          	lw	a4,156(s1)
    800001a0:	fef703e3          	beq	a4,a5,80000186 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a4:	0017871b          	addiw	a4,a5,1
    800001a8:	08e4ac23          	sw	a4,152(s1)
    800001ac:	07f7f713          	andi	a4,a5,127
    800001b0:	9726                	add	a4,a4,s1
    800001b2:	01874703          	lbu	a4,24(a4)
    800001b6:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    800001ba:	079c0063          	beq	s8,s9,8000021a <consoleread+0xf0>
    cbuf = c;
    800001be:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c2:	4685                	li	a3,1
    800001c4:	f8f40613          	addi	a2,s0,-113
    800001c8:	85d6                	mv	a1,s5
    800001ca:	855a                	mv	a0,s6
    800001cc:	074020ef          	jal	ra,80002240 <either_copyout>
    800001d0:	01a50663          	beq	a0,s10,800001dc <consoleread+0xb2>
    dst++;
    800001d4:	0a85                	addi	s5,s5,1
    --n;
    800001d6:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    800001d8:	f9bc1fe3          	bne	s8,s11,80000176 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800001dc:	0000f517          	auipc	a0,0xf
    800001e0:	7d450513          	addi	a0,a0,2004 # 8000f9b0 <cons>
    800001e4:	25d000ef          	jal	ra,80000c40 <release>

  return target - n;
    800001e8:	414b853b          	subw	a0,s7,s4
    800001ec:	a801                	j	800001fc <consoleread+0xd2>
        release(&cons.lock);
    800001ee:	0000f517          	auipc	a0,0xf
    800001f2:	7c250513          	addi	a0,a0,1986 # 8000f9b0 <cons>
    800001f6:	24b000ef          	jal	ra,80000c40 <release>
        return -1;
    800001fa:	557d                	li	a0,-1
}
    800001fc:	70e6                	ld	ra,120(sp)
    800001fe:	7446                	ld	s0,112(sp)
    80000200:	74a6                	ld	s1,104(sp)
    80000202:	7906                	ld	s2,96(sp)
    80000204:	69e6                	ld	s3,88(sp)
    80000206:	6a46                	ld	s4,80(sp)
    80000208:	6aa6                	ld	s5,72(sp)
    8000020a:	6b06                	ld	s6,64(sp)
    8000020c:	7be2                	ld	s7,56(sp)
    8000020e:	7c42                	ld	s8,48(sp)
    80000210:	7ca2                	ld	s9,40(sp)
    80000212:	7d02                	ld	s10,32(sp)
    80000214:	6de2                	ld	s11,24(sp)
    80000216:	6109                	addi	sp,sp,128
    80000218:	8082                	ret
      if(n < target){
    8000021a:	000a071b          	sext.w	a4,s4
    8000021e:	fb777fe3          	bgeu	a4,s7,800001dc <consoleread+0xb2>
        cons.r--;
    80000222:	00010717          	auipc	a4,0x10
    80000226:	82f72323          	sw	a5,-2010(a4) # 8000fa48 <cons+0x98>
    8000022a:	bf4d                	j	800001dc <consoleread+0xb2>

000000008000022c <consputc>:
{
    8000022c:	1141                	addi	sp,sp,-16
    8000022e:	e406                	sd	ra,8(sp)
    80000230:	e022                	sd	s0,0(sp)
    80000232:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000234:	10000793          	li	a5,256
    80000238:	00f50863          	beq	a0,a5,80000248 <consputc+0x1c>
    uartputc_sync(c);
    8000023c:	5d4000ef          	jal	ra,80000810 <uartputc_sync>
}
    80000240:	60a2                	ld	ra,8(sp)
    80000242:	6402                	ld	s0,0(sp)
    80000244:	0141                	addi	sp,sp,16
    80000246:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000248:	4521                	li	a0,8
    8000024a:	5c6000ef          	jal	ra,80000810 <uartputc_sync>
    8000024e:	02000513          	li	a0,32
    80000252:	5be000ef          	jal	ra,80000810 <uartputc_sync>
    80000256:	4521                	li	a0,8
    80000258:	5b8000ef          	jal	ra,80000810 <uartputc_sync>
    8000025c:	b7d5                	j	80000240 <consputc+0x14>

000000008000025e <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000025e:	1101                	addi	sp,sp,-32
    80000260:	ec06                	sd	ra,24(sp)
    80000262:	e822                	sd	s0,16(sp)
    80000264:	e426                	sd	s1,8(sp)
    80000266:	e04a                	sd	s2,0(sp)
    80000268:	1000                	addi	s0,sp,32
    8000026a:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000026c:	0000f517          	auipc	a0,0xf
    80000270:	74450513          	addi	a0,a0,1860 # 8000f9b0 <cons>
    80000274:	135000ef          	jal	ra,80000ba8 <acquire>

  switch(c){
    80000278:	47d5                	li	a5,21
    8000027a:	0af48063          	beq	s1,a5,8000031a <consoleintr+0xbc>
    8000027e:	0297c663          	blt	a5,s1,800002aa <consoleintr+0x4c>
    80000282:	47a1                	li	a5,8
    80000284:	0cf48f63          	beq	s1,a5,80000362 <consoleintr+0x104>
    80000288:	47c1                	li	a5,16
    8000028a:	10f49063          	bne	s1,a5,8000038a <consoleintr+0x12c>
  case C('P'):  // Print process list.
    procdump();
    8000028e:	046020ef          	jal	ra,800022d4 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000292:	0000f517          	auipc	a0,0xf
    80000296:	71e50513          	addi	a0,a0,1822 # 8000f9b0 <cons>
    8000029a:	1a7000ef          	jal	ra,80000c40 <release>
}
    8000029e:	60e2                	ld	ra,24(sp)
    800002a0:	6442                	ld	s0,16(sp)
    800002a2:	64a2                	ld	s1,8(sp)
    800002a4:	6902                	ld	s2,0(sp)
    800002a6:	6105                	addi	sp,sp,32
    800002a8:	8082                	ret
  switch(c){
    800002aa:	07f00793          	li	a5,127
    800002ae:	0af48a63          	beq	s1,a5,80000362 <consoleintr+0x104>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002b2:	0000f717          	auipc	a4,0xf
    800002b6:	6fe70713          	addi	a4,a4,1790 # 8000f9b0 <cons>
    800002ba:	0a072783          	lw	a5,160(a4)
    800002be:	09872703          	lw	a4,152(a4)
    800002c2:	9f99                	subw	a5,a5,a4
    800002c4:	07f00713          	li	a4,127
    800002c8:	fcf765e3          	bltu	a4,a5,80000292 <consoleintr+0x34>
      c = (c == '\r') ? '\n' : c;
    800002cc:	47b5                	li	a5,13
    800002ce:	0cf48163          	beq	s1,a5,80000390 <consoleintr+0x132>
      consputc(c);
    800002d2:	8526                	mv	a0,s1
    800002d4:	f59ff0ef          	jal	ra,8000022c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002d8:	0000f797          	auipc	a5,0xf
    800002dc:	6d878793          	addi	a5,a5,1752 # 8000f9b0 <cons>
    800002e0:	0a07a683          	lw	a3,160(a5)
    800002e4:	0016871b          	addiw	a4,a3,1
    800002e8:	0007061b          	sext.w	a2,a4
    800002ec:	0ae7a023          	sw	a4,160(a5)
    800002f0:	07f6f693          	andi	a3,a3,127
    800002f4:	97b6                	add	a5,a5,a3
    800002f6:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800002fa:	47a9                	li	a5,10
    800002fc:	0af48f63          	beq	s1,a5,800003ba <consoleintr+0x15c>
    80000300:	4791                	li	a5,4
    80000302:	0af48c63          	beq	s1,a5,800003ba <consoleintr+0x15c>
    80000306:	0000f797          	auipc	a5,0xf
    8000030a:	7427a783          	lw	a5,1858(a5) # 8000fa48 <cons+0x98>
    8000030e:	9f1d                	subw	a4,a4,a5
    80000310:	08000793          	li	a5,128
    80000314:	f6f71fe3          	bne	a4,a5,80000292 <consoleintr+0x34>
    80000318:	a04d                	j	800003ba <consoleintr+0x15c>
    while(cons.e != cons.w &&
    8000031a:	0000f717          	auipc	a4,0xf
    8000031e:	69670713          	addi	a4,a4,1686 # 8000f9b0 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000032a:	0000f497          	auipc	s1,0xf
    8000032e:	68648493          	addi	s1,s1,1670 # 8000f9b0 <cons>
    while(cons.e != cons.w &&
    80000332:	4929                	li	s2,10
    80000334:	f4f70fe3          	beq	a4,a5,80000292 <consoleintr+0x34>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000338:	37fd                	addiw	a5,a5,-1
    8000033a:	07f7f713          	andi	a4,a5,127
    8000033e:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000340:	01874703          	lbu	a4,24(a4)
    80000344:	f52707e3          	beq	a4,s2,80000292 <consoleintr+0x34>
      cons.e--;
    80000348:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000034c:	10000513          	li	a0,256
    80000350:	eddff0ef          	jal	ra,8000022c <consputc>
    while(cons.e != cons.w &&
    80000354:	0a04a783          	lw	a5,160(s1)
    80000358:	09c4a703          	lw	a4,156(s1)
    8000035c:	fcf71ee3          	bne	a4,a5,80000338 <consoleintr+0xda>
    80000360:	bf0d                	j	80000292 <consoleintr+0x34>
    if(cons.e != cons.w){
    80000362:	0000f717          	auipc	a4,0xf
    80000366:	64e70713          	addi	a4,a4,1614 # 8000f9b0 <cons>
    8000036a:	0a072783          	lw	a5,160(a4)
    8000036e:	09c72703          	lw	a4,156(a4)
    80000372:	f2f700e3          	beq	a4,a5,80000292 <consoleintr+0x34>
      cons.e--;
    80000376:	37fd                	addiw	a5,a5,-1
    80000378:	0000f717          	auipc	a4,0xf
    8000037c:	6cf72c23          	sw	a5,1752(a4) # 8000fa50 <cons+0xa0>
      consputc(BACKSPACE);
    80000380:	10000513          	li	a0,256
    80000384:	ea9ff0ef          	jal	ra,8000022c <consputc>
    80000388:	b729                	j	80000292 <consoleintr+0x34>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000038a:	f00484e3          	beqz	s1,80000292 <consoleintr+0x34>
    8000038e:	b715                	j	800002b2 <consoleintr+0x54>
      consputc(c);
    80000390:	4529                	li	a0,10
    80000392:	e9bff0ef          	jal	ra,8000022c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000396:	0000f797          	auipc	a5,0xf
    8000039a:	61a78793          	addi	a5,a5,1562 # 8000f9b0 <cons>
    8000039e:	0a07a703          	lw	a4,160(a5)
    800003a2:	0017069b          	addiw	a3,a4,1
    800003a6:	0006861b          	sext.w	a2,a3
    800003aa:	0ad7a023          	sw	a3,160(a5)
    800003ae:	07f77713          	andi	a4,a4,127
    800003b2:	97ba                	add	a5,a5,a4
    800003b4:	4729                	li	a4,10
    800003b6:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003ba:	0000f797          	auipc	a5,0xf
    800003be:	68c7a923          	sw	a2,1682(a5) # 8000fa4c <cons+0x9c>
        wakeup(&cons.r);
    800003c2:	0000f517          	auipc	a0,0xf
    800003c6:	68650513          	addi	a0,a0,1670 # 8000fa48 <cons+0x98>
    800003ca:	367010ef          	jal	ra,80001f30 <wakeup>
    800003ce:	b5d1                	j	80000292 <consoleintr+0x34>

00000000800003d0 <consoleinit>:

void
consoleinit(void)
{
    800003d0:	1141                	addi	sp,sp,-16
    800003d2:	e406                	sd	ra,8(sp)
    800003d4:	e022                	sd	s0,0(sp)
    800003d6:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003d8:	00007597          	auipc	a1,0x7
    800003dc:	c3858593          	addi	a1,a1,-968 # 80007010 <etext+0x10>
    800003e0:	0000f517          	auipc	a0,0xf
    800003e4:	5d050513          	addi	a0,a0,1488 # 8000f9b0 <cons>
    800003e8:	740000ef          	jal	ra,80000b28 <initlock>

  uartinit();
    800003ec:	3d8000ef          	jal	ra,800007c4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    800003f0:	0001f797          	auipc	a5,0x1f
    800003f4:	75878793          	addi	a5,a5,1880 # 8001fb48 <devsw>
    800003f8:	00000717          	auipc	a4,0x0
    800003fc:	d3270713          	addi	a4,a4,-718 # 8000012a <consoleread>
    80000400:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000402:	00000717          	auipc	a4,0x0
    80000406:	cce70713          	addi	a4,a4,-818 # 800000d0 <consolewrite>
    8000040a:	ef98                	sd	a4,24(a5)
}
    8000040c:	60a2                	ld	ra,8(sp)
    8000040e:	6402                	ld	s0,0(sp)
    80000410:	0141                	addi	sp,sp,16
    80000412:	8082                	ret

0000000080000414 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000414:	7139                	addi	sp,sp,-64
    80000416:	fc06                	sd	ra,56(sp)
    80000418:	f822                	sd	s0,48(sp)
    8000041a:	f426                	sd	s1,40(sp)
    8000041c:	f04a                	sd	s2,32(sp)
    8000041e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000420:	c219                	beqz	a2,80000426 <printint+0x12>
    80000422:	06054f63          	bltz	a0,800004a0 <printint+0x8c>
    x = -xx;
  else
    x = xx;
    80000426:	4881                	li	a7,0
    80000428:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000042c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000042e:	00007617          	auipc	a2,0x7
    80000432:	c0a60613          	addi	a2,a2,-1014 # 80007038 <digits>
    80000436:	883e                	mv	a6,a5
    80000438:	2785                	addiw	a5,a5,1
    8000043a:	02b57733          	remu	a4,a0,a1
    8000043e:	9732                	add	a4,a4,a2
    80000440:	00074703          	lbu	a4,0(a4)
    80000444:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000448:	872a                	mv	a4,a0
    8000044a:	02b55533          	divu	a0,a0,a1
    8000044e:	0685                	addi	a3,a3,1
    80000450:	feb773e3          	bgeu	a4,a1,80000436 <printint+0x22>

  if(sign)
    80000454:	00088b63          	beqz	a7,8000046a <printint+0x56>
    buf[i++] = '-';
    80000458:	fe040713          	addi	a4,s0,-32
    8000045c:	97ba                	add	a5,a5,a4
    8000045e:	02d00713          	li	a4,45
    80000462:	fee78423          	sb	a4,-24(a5)
    80000466:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    8000046a:	02f05563          	blez	a5,80000494 <printint+0x80>
    8000046e:	fc840713          	addi	a4,s0,-56
    80000472:	00f704b3          	add	s1,a4,a5
    80000476:	fff70913          	addi	s2,a4,-1
    8000047a:	993e                	add	s2,s2,a5
    8000047c:	37fd                	addiw	a5,a5,-1
    8000047e:	1782                	slli	a5,a5,0x20
    80000480:	9381                	srli	a5,a5,0x20
    80000482:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    80000486:	fff4c503          	lbu	a0,-1(s1)
    8000048a:	da3ff0ef          	jal	ra,8000022c <consputc>
  while(--i >= 0)
    8000048e:	14fd                	addi	s1,s1,-1
    80000490:	ff249be3          	bne	s1,s2,80000486 <printint+0x72>
}
    80000494:	70e2                	ld	ra,56(sp)
    80000496:	7442                	ld	s0,48(sp)
    80000498:	74a2                	ld	s1,40(sp)
    8000049a:	7902                	ld	s2,32(sp)
    8000049c:	6121                	addi	sp,sp,64
    8000049e:	8082                	ret
    x = -xx;
    800004a0:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004a4:	4885                	li	a7,1
    x = -xx;
    800004a6:	b749                	j	80000428 <printint+0x14>

00000000800004a8 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004a8:	7155                	addi	sp,sp,-208
    800004aa:	e506                	sd	ra,136(sp)
    800004ac:	e122                	sd	s0,128(sp)
    800004ae:	fca6                	sd	s1,120(sp)
    800004b0:	f8ca                	sd	s2,112(sp)
    800004b2:	f4ce                	sd	s3,104(sp)
    800004b4:	f0d2                	sd	s4,96(sp)
    800004b6:	ecd6                	sd	s5,88(sp)
    800004b8:	e8da                	sd	s6,80(sp)
    800004ba:	e4de                	sd	s7,72(sp)
    800004bc:	e0e2                	sd	s8,64(sp)
    800004be:	fc66                	sd	s9,56(sp)
    800004c0:	f86a                	sd	s10,48(sp)
    800004c2:	f46e                	sd	s11,40(sp)
    800004c4:	0900                	addi	s0,sp,144
    800004c6:	8a2a                	mv	s4,a0
    800004c8:	e40c                	sd	a1,8(s0)
    800004ca:	e810                	sd	a2,16(s0)
    800004cc:	ec14                	sd	a3,24(s0)
    800004ce:	f018                	sd	a4,32(s0)
    800004d0:	f41c                	sd	a5,40(s0)
    800004d2:	03043823          	sd	a6,48(s0)
    800004d6:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004da:	0000f797          	auipc	a5,0xf
    800004de:	5967a783          	lw	a5,1430(a5) # 8000fa70 <pr+0x18>
    800004e2:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004e6:	eb9d                	bnez	a5,8000051c <printf+0x74>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004e8:	00840793          	addi	a5,s0,8
    800004ec:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f0:	00054503          	lbu	a0,0(a0)
    800004f4:	24050463          	beqz	a0,8000073c <printf+0x294>
    800004f8:	4981                	li	s3,0
    if(cx != '%'){
    800004fa:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    800004fe:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000502:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000506:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    8000050a:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000050e:	07000d93          	li	s11,112
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000512:	00007b97          	auipc	s7,0x7
    80000516:	b26b8b93          	addi	s7,s7,-1242 # 80007038 <digits>
    8000051a:	a081                	j	8000055a <printf+0xb2>
    acquire(&pr.lock);
    8000051c:	0000f517          	auipc	a0,0xf
    80000520:	53c50513          	addi	a0,a0,1340 # 8000fa58 <pr>
    80000524:	684000ef          	jal	ra,80000ba8 <acquire>
  va_start(ap, fmt);
    80000528:	00840793          	addi	a5,s0,8
    8000052c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000530:	000a4503          	lbu	a0,0(s4)
    80000534:	f171                	bnez	a0,800004f8 <printf+0x50>
#endif
  }
  va_end(ap);

  if(locking)
    release(&pr.lock);
    80000536:	0000f517          	auipc	a0,0xf
    8000053a:	52250513          	addi	a0,a0,1314 # 8000fa58 <pr>
    8000053e:	702000ef          	jal	ra,80000c40 <release>
    80000542:	aaed                	j	8000073c <printf+0x294>
      consputc(cx);
    80000544:	ce9ff0ef          	jal	ra,8000022c <consputc>
      continue;
    80000548:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054a:	0014899b          	addiw	s3,s1,1
    8000054e:	013a07b3          	add	a5,s4,s3
    80000552:	0007c503          	lbu	a0,0(a5)
    80000556:	1c050f63          	beqz	a0,80000734 <printf+0x28c>
    if(cx != '%'){
    8000055a:	ff5515e3          	bne	a0,s5,80000544 <printf+0x9c>
    i++;
    8000055e:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000562:	009a07b3          	add	a5,s4,s1
    80000566:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056a:	1c090563          	beqz	s2,80000734 <printf+0x28c>
    8000056e:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000572:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000574:	c789                	beqz	a5,8000057e <printf+0xd6>
    80000576:	009a0733          	add	a4,s4,s1
    8000057a:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    8000057e:	03690463          	beq	s2,s6,800005a6 <printf+0xfe>
    } else if(c0 == 'l' && c1 == 'd'){
    80000582:	03890e63          	beq	s2,s8,800005be <printf+0x116>
    } else if(c0 == 'u'){
    80000586:	0b990d63          	beq	s2,s9,80000640 <printf+0x198>
    } else if(c0 == 'x'){
    8000058a:	11a90363          	beq	s2,s10,80000690 <printf+0x1e8>
    } else if(c0 == 'p'){
    8000058e:	13b90b63          	beq	s2,s11,800006c4 <printf+0x21c>
    } else if(c0 == 's'){
    80000592:	07300793          	li	a5,115
    80000596:	16f90363          	beq	s2,a5,800006fc <printf+0x254>
    } else if(c0 == '%'){
    8000059a:	03591c63          	bne	s2,s5,800005d2 <printf+0x12a>
      consputc('%');
    8000059e:	8556                	mv	a0,s5
    800005a0:	c8dff0ef          	jal	ra,8000022c <consputc>
    800005a4:	b75d                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, int), 10, 1);
    800005a6:	f8843783          	ld	a5,-120(s0)
    800005aa:	00878713          	addi	a4,a5,8
    800005ae:	f8e43423          	sd	a4,-120(s0)
    800005b2:	4605                	li	a2,1
    800005b4:	45a9                	li	a1,10
    800005b6:	4388                	lw	a0,0(a5)
    800005b8:	e5dff0ef          	jal	ra,80000414 <printint>
    800005bc:	b779                	j	8000054a <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'd'){
    800005be:	03678163          	beq	a5,s6,800005e0 <printf+0x138>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005c2:	03878d63          	beq	a5,s8,800005fc <printf+0x154>
    } else if(c0 == 'l' && c1 == 'u'){
    800005c6:	09978963          	beq	a5,s9,80000658 <printf+0x1b0>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    800005ca:	03878b63          	beq	a5,s8,80000600 <printf+0x158>
    } else if(c0 == 'l' && c1 == 'x'){
    800005ce:	0da78d63          	beq	a5,s10,800006a8 <printf+0x200>
      consputc('%');
    800005d2:	8556                	mv	a0,s5
    800005d4:	c59ff0ef          	jal	ra,8000022c <consputc>
      consputc(c0);
    800005d8:	854a                	mv	a0,s2
    800005da:	c53ff0ef          	jal	ra,8000022c <consputc>
    800005de:	b7b5                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    800005e0:	f8843783          	ld	a5,-120(s0)
    800005e4:	00878713          	addi	a4,a5,8
    800005e8:	f8e43423          	sd	a4,-120(s0)
    800005ec:	4605                	li	a2,1
    800005ee:	45a9                	li	a1,10
    800005f0:	6388                	ld	a0,0(a5)
    800005f2:	e23ff0ef          	jal	ra,80000414 <printint>
      i += 1;
    800005f6:	0029849b          	addiw	s1,s3,2
    800005fa:	bf81                	j	8000054a <printf+0xa2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005fc:	03668463          	beq	a3,s6,80000624 <printf+0x17c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000600:	07968a63          	beq	a3,s9,80000674 <printf+0x1cc>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000604:	fda697e3          	bne	a3,s10,800005d2 <printf+0x12a>
      printint(va_arg(ap, uint64), 16, 0);
    80000608:	f8843783          	ld	a5,-120(s0)
    8000060c:	00878713          	addi	a4,a5,8
    80000610:	f8e43423          	sd	a4,-120(s0)
    80000614:	4601                	li	a2,0
    80000616:	45c1                	li	a1,16
    80000618:	6388                	ld	a0,0(a5)
    8000061a:	dfbff0ef          	jal	ra,80000414 <printint>
      i += 2;
    8000061e:	0039849b          	addiw	s1,s3,3
    80000622:	b725                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 1);
    80000624:	f8843783          	ld	a5,-120(s0)
    80000628:	00878713          	addi	a4,a5,8
    8000062c:	f8e43423          	sd	a4,-120(s0)
    80000630:	4605                	li	a2,1
    80000632:	45a9                	li	a1,10
    80000634:	6388                	ld	a0,0(a5)
    80000636:	ddfff0ef          	jal	ra,80000414 <printint>
      i += 2;
    8000063a:	0039849b          	addiw	s1,s3,3
    8000063e:	b731                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, int), 10, 0);
    80000640:	f8843783          	ld	a5,-120(s0)
    80000644:	00878713          	addi	a4,a5,8
    80000648:	f8e43423          	sd	a4,-120(s0)
    8000064c:	4601                	li	a2,0
    8000064e:	45a9                	li	a1,10
    80000650:	4388                	lw	a0,0(a5)
    80000652:	dc3ff0ef          	jal	ra,80000414 <printint>
    80000656:	bdd5                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4601                	li	a2,0
    80000666:	45a9                	li	a1,10
    80000668:	6388                	ld	a0,0(a5)
    8000066a:	dabff0ef          	jal	ra,80000414 <printint>
      i += 1;
    8000066e:	0029849b          	addiw	s1,s3,2
    80000672:	bde1                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, uint64), 10, 0);
    80000674:	f8843783          	ld	a5,-120(s0)
    80000678:	00878713          	addi	a4,a5,8
    8000067c:	f8e43423          	sd	a4,-120(s0)
    80000680:	4601                	li	a2,0
    80000682:	45a9                	li	a1,10
    80000684:	6388                	ld	a0,0(a5)
    80000686:	d8fff0ef          	jal	ra,80000414 <printint>
      i += 2;
    8000068a:	0039849b          	addiw	s1,s3,3
    8000068e:	bd75                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, int), 16, 0);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4601                	li	a2,0
    8000069e:	45c1                	li	a1,16
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	d73ff0ef          	jal	ra,80000414 <printint>
    800006a6:	b555                	j	8000054a <printf+0xa2>
      printint(va_arg(ap, uint64), 16, 0);
    800006a8:	f8843783          	ld	a5,-120(s0)
    800006ac:	00878713          	addi	a4,a5,8
    800006b0:	f8e43423          	sd	a4,-120(s0)
    800006b4:	4601                	li	a2,0
    800006b6:	45c1                	li	a1,16
    800006b8:	6388                	ld	a0,0(a5)
    800006ba:	d5bff0ef          	jal	ra,80000414 <printint>
      i += 1;
    800006be:	0029849b          	addiw	s1,s3,2
    800006c2:	b561                	j	8000054a <printf+0xa2>
      printptr(va_arg(ap, uint64));
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006d4:	03000513          	li	a0,48
    800006d8:	b55ff0ef          	jal	ra,8000022c <consputc>
  consputc('x');
    800006dc:	856a                	mv	a0,s10
    800006de:	b4fff0ef          	jal	ra,8000022c <consputc>
    800006e2:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006e4:	03c9d793          	srli	a5,s3,0x3c
    800006e8:	97de                	add	a5,a5,s7
    800006ea:	0007c503          	lbu	a0,0(a5)
    800006ee:	b3fff0ef          	jal	ra,8000022c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006f2:	0992                	slli	s3,s3,0x4
    800006f4:	397d                	addiw	s2,s2,-1
    800006f6:	fe0917e3          	bnez	s2,800006e4 <printf+0x23c>
    800006fa:	bd81                	j	8000054a <printf+0xa2>
      if((s = va_arg(ap, char*)) == 0)
    800006fc:	f8843783          	ld	a5,-120(s0)
    80000700:	00878713          	addi	a4,a5,8
    80000704:	f8e43423          	sd	a4,-120(s0)
    80000708:	0007b903          	ld	s2,0(a5)
    8000070c:	00090d63          	beqz	s2,80000726 <printf+0x27e>
      for(; *s; s++)
    80000710:	00094503          	lbu	a0,0(s2)
    80000714:	e2050be3          	beqz	a0,8000054a <printf+0xa2>
        consputc(*s);
    80000718:	b15ff0ef          	jal	ra,8000022c <consputc>
      for(; *s; s++)
    8000071c:	0905                	addi	s2,s2,1
    8000071e:	00094503          	lbu	a0,0(s2)
    80000722:	f97d                	bnez	a0,80000718 <printf+0x270>
    80000724:	b51d                	j	8000054a <printf+0xa2>
        s = "(null)";
    80000726:	00007917          	auipc	s2,0x7
    8000072a:	8f290913          	addi	s2,s2,-1806 # 80007018 <etext+0x18>
      for(; *s; s++)
    8000072e:	02800513          	li	a0,40
    80000732:	b7dd                	j	80000718 <printf+0x270>
  if(locking)
    80000734:	f7843783          	ld	a5,-136(s0)
    80000738:	de079fe3          	bnez	a5,80000536 <printf+0x8e>

  return 0;
}
    8000073c:	4501                	li	a0,0
    8000073e:	60aa                	ld	ra,136(sp)
    80000740:	640a                	ld	s0,128(sp)
    80000742:	74e6                	ld	s1,120(sp)
    80000744:	7946                	ld	s2,112(sp)
    80000746:	79a6                	ld	s3,104(sp)
    80000748:	7a06                	ld	s4,96(sp)
    8000074a:	6ae6                	ld	s5,88(sp)
    8000074c:	6b46                	ld	s6,80(sp)
    8000074e:	6ba6                	ld	s7,72(sp)
    80000750:	6c06                	ld	s8,64(sp)
    80000752:	7ce2                	ld	s9,56(sp)
    80000754:	7d42                	ld	s10,48(sp)
    80000756:	7da2                	ld	s11,40(sp)
    80000758:	6169                	addi	sp,sp,208
    8000075a:	8082                	ret

000000008000075c <panic>:

void
panic(char *s)
{
    8000075c:	1101                	addi	sp,sp,-32
    8000075e:	ec06                	sd	ra,24(sp)
    80000760:	e822                	sd	s0,16(sp)
    80000762:	e426                	sd	s1,8(sp)
    80000764:	1000                	addi	s0,sp,32
    80000766:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000768:	0000f797          	auipc	a5,0xf
    8000076c:	3007a423          	sw	zero,776(a5) # 8000fa70 <pr+0x18>
  printf("panic: ");
    80000770:	00007517          	auipc	a0,0x7
    80000774:	8b050513          	addi	a0,a0,-1872 # 80007020 <etext+0x20>
    80000778:	d31ff0ef          	jal	ra,800004a8 <printf>
  printf("%s\n", s);
    8000077c:	85a6                	mv	a1,s1
    8000077e:	00007517          	auipc	a0,0x7
    80000782:	8aa50513          	addi	a0,a0,-1878 # 80007028 <etext+0x28>
    80000786:	d23ff0ef          	jal	ra,800004a8 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000078a:	4785                	li	a5,1
    8000078c:	00007717          	auipc	a4,0x7
    80000790:	1ef72223          	sw	a5,484(a4) # 80007970 <panicked>
  for(;;)
    80000794:	a001                	j	80000794 <panic+0x38>

0000000080000796 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000796:	1101                	addi	sp,sp,-32
    80000798:	ec06                	sd	ra,24(sp)
    8000079a:	e822                	sd	s0,16(sp)
    8000079c:	e426                	sd	s1,8(sp)
    8000079e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007a0:	0000f497          	auipc	s1,0xf
    800007a4:	2b848493          	addi	s1,s1,696 # 8000fa58 <pr>
    800007a8:	00007597          	auipc	a1,0x7
    800007ac:	88858593          	addi	a1,a1,-1912 # 80007030 <etext+0x30>
    800007b0:	8526                	mv	a0,s1
    800007b2:	376000ef          	jal	ra,80000b28 <initlock>
  pr.locking = 1;
    800007b6:	4785                	li	a5,1
    800007b8:	cc9c                	sw	a5,24(s1)
}
    800007ba:	60e2                	ld	ra,24(sp)
    800007bc:	6442                	ld	s0,16(sp)
    800007be:	64a2                	ld	s1,8(sp)
    800007c0:	6105                	addi	sp,sp,32
    800007c2:	8082                	ret

00000000800007c4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007c4:	1141                	addi	sp,sp,-16
    800007c6:	e406                	sd	ra,8(sp)
    800007c8:	e022                	sd	s0,0(sp)
    800007ca:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007cc:	100007b7          	lui	a5,0x10000
    800007d0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007d4:	f8000713          	li	a4,-128
    800007d8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007dc:	470d                	li	a4,3
    800007de:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007e2:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007e6:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007ea:	469d                	li	a3,7
    800007ec:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007f0:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007f4:	00007597          	auipc	a1,0x7
    800007f8:	85c58593          	addi	a1,a1,-1956 # 80007050 <digits+0x18>
    800007fc:	0000f517          	auipc	a0,0xf
    80000800:	27c50513          	addi	a0,a0,636 # 8000fa78 <uart_tx_lock>
    80000804:	324000ef          	jal	ra,80000b28 <initlock>
}
    80000808:	60a2                	ld	ra,8(sp)
    8000080a:	6402                	ld	s0,0(sp)
    8000080c:	0141                	addi	sp,sp,16
    8000080e:	8082                	ret

0000000080000810 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000810:	1101                	addi	sp,sp,-32
    80000812:	ec06                	sd	ra,24(sp)
    80000814:	e822                	sd	s0,16(sp)
    80000816:	e426                	sd	s1,8(sp)
    80000818:	1000                	addi	s0,sp,32
    8000081a:	84aa                	mv	s1,a0
  push_off();
    8000081c:	34c000ef          	jal	ra,80000b68 <push_off>

  if(panicked){
    80000820:	00007797          	auipc	a5,0x7
    80000824:	1507a783          	lw	a5,336(a5) # 80007970 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000828:	10000737          	lui	a4,0x10000
  if(panicked){
    8000082c:	c391                	beqz	a5,80000830 <uartputc_sync+0x20>
    for(;;)
    8000082e:	a001                	j	8000082e <uartputc_sync+0x1e>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000830:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000834:	0ff7f793          	andi	a5,a5,255
    80000838:	0207f793          	andi	a5,a5,32
    8000083c:	dbf5                	beqz	a5,80000830 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000083e:	0ff4f793          	andi	a5,s1,255
    80000842:	10000737          	lui	a4,0x10000
    80000846:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000084a:	3a2000ef          	jal	ra,80000bec <pop_off>
}
    8000084e:	60e2                	ld	ra,24(sp)
    80000850:	6442                	ld	s0,16(sp)
    80000852:	64a2                	ld	s1,8(sp)
    80000854:	6105                	addi	sp,sp,32
    80000856:	8082                	ret

0000000080000858 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000858:	00007717          	auipc	a4,0x7
    8000085c:	12073703          	ld	a4,288(a4) # 80007978 <uart_tx_r>
    80000860:	00007797          	auipc	a5,0x7
    80000864:	1207b783          	ld	a5,288(a5) # 80007980 <uart_tx_w>
    80000868:	06e78e63          	beq	a5,a4,800008e4 <uartstart+0x8c>
{
    8000086c:	7139                	addi	sp,sp,-64
    8000086e:	fc06                	sd	ra,56(sp)
    80000870:	f822                	sd	s0,48(sp)
    80000872:	f426                	sd	s1,40(sp)
    80000874:	f04a                	sd	s2,32(sp)
    80000876:	ec4e                	sd	s3,24(sp)
    80000878:	e852                	sd	s4,16(sp)
    8000087a:	e456                	sd	s5,8(sp)
    8000087c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000882:	0000fa17          	auipc	s4,0xf
    80000886:	1f6a0a13          	addi	s4,s4,502 # 8000fa78 <uart_tx_lock>
    uart_tx_r += 1;
    8000088a:	00007497          	auipc	s1,0x7
    8000088e:	0ee48493          	addi	s1,s1,238 # 80007978 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000892:	00007997          	auipc	s3,0x7
    80000896:	0ee98993          	addi	s3,s3,238 # 80007980 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000089a:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000089e:	0ff7f793          	andi	a5,a5,255
    800008a2:	0207f793          	andi	a5,a5,32
    800008a6:	c795                	beqz	a5,800008d2 <uartstart+0x7a>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008a8:	01f77793          	andi	a5,a4,31
    800008ac:	97d2                	add	a5,a5,s4
    800008ae:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800008b2:	0705                	addi	a4,a4,1
    800008b4:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008b6:	8526                	mv	a0,s1
    800008b8:	678010ef          	jal	ra,80001f30 <wakeup>
    
    WriteReg(THR, c);
    800008bc:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008c0:	6098                	ld	a4,0(s1)
    800008c2:	0009b783          	ld	a5,0(s3)
    800008c6:	fce79ae3          	bne	a5,a4,8000089a <uartstart+0x42>
      ReadReg(ISR);
    800008ca:	100007b7          	lui	a5,0x10000
    800008ce:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
  }
}
    800008d2:	70e2                	ld	ra,56(sp)
    800008d4:	7442                	ld	s0,48(sp)
    800008d6:	74a2                	ld	s1,40(sp)
    800008d8:	7902                	ld	s2,32(sp)
    800008da:	69e2                	ld	s3,24(sp)
    800008dc:	6a42                	ld	s4,16(sp)
    800008de:	6aa2                	ld	s5,8(sp)
    800008e0:	6121                	addi	sp,sp,64
    800008e2:	8082                	ret
      ReadReg(ISR);
    800008e4:	100007b7          	lui	a5,0x10000
    800008e8:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>
      return;
    800008ec:	8082                	ret

00000000800008ee <uartputc>:
{
    800008ee:	7179                	addi	sp,sp,-48
    800008f0:	f406                	sd	ra,40(sp)
    800008f2:	f022                	sd	s0,32(sp)
    800008f4:	ec26                	sd	s1,24(sp)
    800008f6:	e84a                	sd	s2,16(sp)
    800008f8:	e44e                	sd	s3,8(sp)
    800008fa:	e052                	sd	s4,0(sp)
    800008fc:	1800                	addi	s0,sp,48
    800008fe:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80000900:	0000f517          	auipc	a0,0xf
    80000904:	17850513          	addi	a0,a0,376 # 8000fa78 <uart_tx_lock>
    80000908:	2a0000ef          	jal	ra,80000ba8 <acquire>
  if(panicked){
    8000090c:	00007797          	auipc	a5,0x7
    80000910:	0647a783          	lw	a5,100(a5) # 80007970 <panicked>
    80000914:	efbd                	bnez	a5,80000992 <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000916:	00007797          	auipc	a5,0x7
    8000091a:	06a7b783          	ld	a5,106(a5) # 80007980 <uart_tx_w>
    8000091e:	00007717          	auipc	a4,0x7
    80000922:	05a73703          	ld	a4,90(a4) # 80007978 <uart_tx_r>
    80000926:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092a:	0000fa17          	auipc	s4,0xf
    8000092e:	14ea0a13          	addi	s4,s4,334 # 8000fa78 <uart_tx_lock>
    80000932:	00007497          	auipc	s1,0x7
    80000936:	04648493          	addi	s1,s1,70 # 80007978 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000093a:	00007917          	auipc	s2,0x7
    8000093e:	04690913          	addi	s2,s2,70 # 80007980 <uart_tx_w>
    80000942:	00f71d63          	bne	a4,a5,8000095c <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000946:	85d2                	mv	a1,s4
    80000948:	8526                	mv	a0,s1
    8000094a:	59a010ef          	jal	ra,80001ee4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000094e:	00093783          	ld	a5,0(s2)
    80000952:	6098                	ld	a4,0(s1)
    80000954:	02070713          	addi	a4,a4,32
    80000958:	fef707e3          	beq	a4,a5,80000946 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    8000095c:	0000f497          	auipc	s1,0xf
    80000960:	11c48493          	addi	s1,s1,284 # 8000fa78 <uart_tx_lock>
    80000964:	01f7f713          	andi	a4,a5,31
    80000968:	9726                	add	a4,a4,s1
    8000096a:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    8000096e:	0785                	addi	a5,a5,1
    80000970:	00007717          	auipc	a4,0x7
    80000974:	00f73823          	sd	a5,16(a4) # 80007980 <uart_tx_w>
  uartstart();
    80000978:	ee1ff0ef          	jal	ra,80000858 <uartstart>
  release(&uart_tx_lock);
    8000097c:	8526                	mv	a0,s1
    8000097e:	2c2000ef          	jal	ra,80000c40 <release>
}
    80000982:	70a2                	ld	ra,40(sp)
    80000984:	7402                	ld	s0,32(sp)
    80000986:	64e2                	ld	s1,24(sp)
    80000988:	6942                	ld	s2,16(sp)
    8000098a:	69a2                	ld	s3,8(sp)
    8000098c:	6a02                	ld	s4,0(sp)
    8000098e:	6145                	addi	sp,sp,48
    80000990:	8082                	ret
    for(;;)
    80000992:	a001                	j	80000992 <uartputc+0xa4>

0000000080000994 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000994:	1141                	addi	sp,sp,-16
    80000996:	e422                	sd	s0,8(sp)
    80000998:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000099a:	100007b7          	lui	a5,0x10000
    8000099e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800009a2:	8b85                	andi	a5,a5,1
    800009a4:	cb91                	beqz	a5,800009b8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800009a6:	100007b7          	lui	a5,0x10000
    800009aa:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800009ae:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800009b2:	6422                	ld	s0,8(sp)
    800009b4:	0141                	addi	sp,sp,16
    800009b6:	8082                	ret
    return -1;
    800009b8:	557d                	li	a0,-1
    800009ba:	bfe5                	j	800009b2 <uartgetc+0x1e>

00000000800009bc <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009bc:	1101                	addi	sp,sp,-32
    800009be:	ec06                	sd	ra,24(sp)
    800009c0:	e822                	sd	s0,16(sp)
    800009c2:	e426                	sd	s1,8(sp)
    800009c4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009c6:	54fd                	li	s1,-1
    int c = uartgetc();
    800009c8:	fcdff0ef          	jal	ra,80000994 <uartgetc>
    if(c == -1)
    800009cc:	00950563          	beq	a0,s1,800009d6 <uartintr+0x1a>
      break;
    consoleintr(c);
    800009d0:	88fff0ef          	jal	ra,8000025e <consoleintr>
  while(1){
    800009d4:	bfd5                	j	800009c8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009d6:	0000f497          	auipc	s1,0xf
    800009da:	0a248493          	addi	s1,s1,162 # 8000fa78 <uart_tx_lock>
    800009de:	8526                	mv	a0,s1
    800009e0:	1c8000ef          	jal	ra,80000ba8 <acquire>
  uartstart();
    800009e4:	e75ff0ef          	jal	ra,80000858 <uartstart>
  release(&uart_tx_lock);
    800009e8:	8526                	mv	a0,s1
    800009ea:	256000ef          	jal	ra,80000c40 <release>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret

00000000800009f8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009f8:	1101                	addi	sp,sp,-32
    800009fa:	ec06                	sd	ra,24(sp)
    800009fc:	e822                	sd	s0,16(sp)
    800009fe:	e426                	sd	s1,8(sp)
    80000a00:	e04a                	sd	s2,0(sp)
    80000a02:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a04:	03451793          	slli	a5,a0,0x34
    80000a08:	e7a9                	bnez	a5,80000a52 <kfree+0x5a>
    80000a0a:	84aa                	mv	s1,a0
    80000a0c:	00020797          	auipc	a5,0x20
    80000a10:	2d478793          	addi	a5,a5,724 # 80020ce0 <end>
    80000a14:	02f56f63          	bltu	a0,a5,80000a52 <kfree+0x5a>
    80000a18:	47c5                	li	a5,17
    80000a1a:	07ee                	slli	a5,a5,0x1b
    80000a1c:	02f57b63          	bgeu	a0,a5,80000a52 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a20:	6605                	lui	a2,0x1
    80000a22:	4585                	li	a1,1
    80000a24:	258000ef          	jal	ra,80000c7c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a28:	0000f917          	auipc	s2,0xf
    80000a2c:	08890913          	addi	s2,s2,136 # 8000fab0 <kmem>
    80000a30:	854a                	mv	a0,s2
    80000a32:	176000ef          	jal	ra,80000ba8 <acquire>
  r->next = kmem.freelist;
    80000a36:	01893783          	ld	a5,24(s2)
    80000a3a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a3c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a40:	854a                	mv	a0,s2
    80000a42:	1fe000ef          	jal	ra,80000c40 <release>
}
    80000a46:	60e2                	ld	ra,24(sp)
    80000a48:	6442                	ld	s0,16(sp)
    80000a4a:	64a2                	ld	s1,8(sp)
    80000a4c:	6902                	ld	s2,0(sp)
    80000a4e:	6105                	addi	sp,sp,32
    80000a50:	8082                	ret
    panic("kfree");
    80000a52:	00006517          	auipc	a0,0x6
    80000a56:	60650513          	addi	a0,a0,1542 # 80007058 <digits+0x20>
    80000a5a:	d03ff0ef          	jal	ra,8000075c <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	94aa                	add	s1,s1,a0
    80000a76:	757d                	lui	a0,0xfffff
    80000a78:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7a:	94be                	add	s1,s1,a5
    80000a7c:	0095ec63          	bltu	a1,s1,80000a94 <freerange+0x36>
    80000a80:	892e                	mv	s2,a1
    kfree(p);
    80000a82:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a84:	6985                	lui	s3,0x1
    kfree(p);
    80000a86:	01448533          	add	a0,s1,s4
    80000a8a:	f6fff0ef          	jal	ra,800009f8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a8e:	94ce                	add	s1,s1,s3
    80000a90:	fe997be3          	bgeu	s2,s1,80000a86 <freerange+0x28>
}
    80000a94:	70a2                	ld	ra,40(sp)
    80000a96:	7402                	ld	s0,32(sp)
    80000a98:	64e2                	ld	s1,24(sp)
    80000a9a:	6942                	ld	s2,16(sp)
    80000a9c:	69a2                	ld	s3,8(sp)
    80000a9e:	6a02                	ld	s4,0(sp)
    80000aa0:	6145                	addi	sp,sp,48
    80000aa2:	8082                	ret

0000000080000aa4 <kinit>:
{
    80000aa4:	1141                	addi	sp,sp,-16
    80000aa6:	e406                	sd	ra,8(sp)
    80000aa8:	e022                	sd	s0,0(sp)
    80000aaa:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aac:	00006597          	auipc	a1,0x6
    80000ab0:	5b458593          	addi	a1,a1,1460 # 80007060 <digits+0x28>
    80000ab4:	0000f517          	auipc	a0,0xf
    80000ab8:	ffc50513          	addi	a0,a0,-4 # 8000fab0 <kmem>
    80000abc:	06c000ef          	jal	ra,80000b28 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac0:	45c5                	li	a1,17
    80000ac2:	05ee                	slli	a1,a1,0x1b
    80000ac4:	00020517          	auipc	a0,0x20
    80000ac8:	21c50513          	addi	a0,a0,540 # 80020ce0 <end>
    80000acc:	f93ff0ef          	jal	ra,80000a5e <freerange>
}
    80000ad0:	60a2                	ld	ra,8(sp)
    80000ad2:	6402                	ld	s0,0(sp)
    80000ad4:	0141                	addi	sp,sp,16
    80000ad6:	8082                	ret

0000000080000ad8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ad8:	1101                	addi	sp,sp,-32
    80000ada:	ec06                	sd	ra,24(sp)
    80000adc:	e822                	sd	s0,16(sp)
    80000ade:	e426                	sd	s1,8(sp)
    80000ae0:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ae2:	0000f497          	auipc	s1,0xf
    80000ae6:	fce48493          	addi	s1,s1,-50 # 8000fab0 <kmem>
    80000aea:	8526                	mv	a0,s1
    80000aec:	0bc000ef          	jal	ra,80000ba8 <acquire>
  r = kmem.freelist;
    80000af0:	6c84                	ld	s1,24(s1)
  if(r)
    80000af2:	c485                	beqz	s1,80000b1a <kalloc+0x42>
    kmem.freelist = r->next;
    80000af4:	609c                	ld	a5,0(s1)
    80000af6:	0000f517          	auipc	a0,0xf
    80000afa:	fba50513          	addi	a0,a0,-70 # 8000fab0 <kmem>
    80000afe:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b00:	140000ef          	jal	ra,80000c40 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b04:	6605                	lui	a2,0x1
    80000b06:	4595                	li	a1,5
    80000b08:	8526                	mv	a0,s1
    80000b0a:	172000ef          	jal	ra,80000c7c <memset>
  return (void*)r;
}
    80000b0e:	8526                	mv	a0,s1
    80000b10:	60e2                	ld	ra,24(sp)
    80000b12:	6442                	ld	s0,16(sp)
    80000b14:	64a2                	ld	s1,8(sp)
    80000b16:	6105                	addi	sp,sp,32
    80000b18:	8082                	ret
  release(&kmem.lock);
    80000b1a:	0000f517          	auipc	a0,0xf
    80000b1e:	f9650513          	addi	a0,a0,-106 # 8000fab0 <kmem>
    80000b22:	11e000ef          	jal	ra,80000c40 <release>
  if(r)
    80000b26:	b7e5                	j	80000b0e <kalloc+0x36>

0000000080000b28 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b28:	1141                	addi	sp,sp,-16
    80000b2a:	e422                	sd	s0,8(sp)
    80000b2c:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b2e:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b30:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b34:	00053823          	sd	zero,16(a0)
}
    80000b38:	6422                	ld	s0,8(sp)
    80000b3a:	0141                	addi	sp,sp,16
    80000b3c:	8082                	ret

0000000080000b3e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b3e:	411c                	lw	a5,0(a0)
    80000b40:	e399                	bnez	a5,80000b46 <holding+0x8>
    80000b42:	4501                	li	a0,0
  return r;
}
    80000b44:	8082                	ret
{
    80000b46:	1101                	addi	sp,sp,-32
    80000b48:	ec06                	sd	ra,24(sp)
    80000b4a:	e822                	sd	s0,16(sp)
    80000b4c:	e426                	sd	s1,8(sp)
    80000b4e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b50:	6904                	ld	s1,16(a0)
    80000b52:	5af000ef          	jal	ra,80001900 <mycpu>
    80000b56:	40a48533          	sub	a0,s1,a0
    80000b5a:	00153513          	seqz	a0,a0
}
    80000b5e:	60e2                	ld	ra,24(sp)
    80000b60:	6442                	ld	s0,16(sp)
    80000b62:	64a2                	ld	s1,8(sp)
    80000b64:	6105                	addi	sp,sp,32
    80000b66:	8082                	ret

0000000080000b68 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b68:	1101                	addi	sp,sp,-32
    80000b6a:	ec06                	sd	ra,24(sp)
    80000b6c:	e822                	sd	s0,16(sp)
    80000b6e:	e426                	sd	s1,8(sp)
    80000b70:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b72:	100024f3          	csrr	s1,sstatus
    80000b76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b7a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b7c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b80:	581000ef          	jal	ra,80001900 <mycpu>
    80000b84:	5d3c                	lw	a5,120(a0)
    80000b86:	cb99                	beqz	a5,80000b9c <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b88:	579000ef          	jal	ra,80001900 <mycpu>
    80000b8c:	5d3c                	lw	a5,120(a0)
    80000b8e:	2785                	addiw	a5,a5,1
    80000b90:	dd3c                	sw	a5,120(a0)
}
    80000b92:	60e2                	ld	ra,24(sp)
    80000b94:	6442                	ld	s0,16(sp)
    80000b96:	64a2                	ld	s1,8(sp)
    80000b98:	6105                	addi	sp,sp,32
    80000b9a:	8082                	ret
    mycpu()->intena = old;
    80000b9c:	565000ef          	jal	ra,80001900 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000ba0:	8085                	srli	s1,s1,0x1
    80000ba2:	8885                	andi	s1,s1,1
    80000ba4:	dd64                	sw	s1,124(a0)
    80000ba6:	b7cd                	j	80000b88 <push_off+0x20>

0000000080000ba8 <acquire>:
{
    80000ba8:	1101                	addi	sp,sp,-32
    80000baa:	ec06                	sd	ra,24(sp)
    80000bac:	e822                	sd	s0,16(sp)
    80000bae:	e426                	sd	s1,8(sp)
    80000bb0:	1000                	addi	s0,sp,32
    80000bb2:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bb4:	fb5ff0ef          	jal	ra,80000b68 <push_off>
  if(holding(lk))
    80000bb8:	8526                	mv	a0,s1
    80000bba:	f85ff0ef          	jal	ra,80000b3e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bbe:	4705                	li	a4,1
  if(holding(lk))
    80000bc0:	e105                	bnez	a0,80000be0 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bc2:	87ba                	mv	a5,a4
    80000bc4:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bc8:	2781                	sext.w	a5,a5
    80000bca:	ffe5                	bnez	a5,80000bc2 <acquire+0x1a>
  __sync_synchronize();
    80000bcc:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000bd0:	531000ef          	jal	ra,80001900 <mycpu>
    80000bd4:	e888                	sd	a0,16(s1)
}
    80000bd6:	60e2                	ld	ra,24(sp)
    80000bd8:	6442                	ld	s0,16(sp)
    80000bda:	64a2                	ld	s1,8(sp)
    80000bdc:	6105                	addi	sp,sp,32
    80000bde:	8082                	ret
    panic("acquire");
    80000be0:	00006517          	auipc	a0,0x6
    80000be4:	48850513          	addi	a0,a0,1160 # 80007068 <digits+0x30>
    80000be8:	b75ff0ef          	jal	ra,8000075c <panic>

0000000080000bec <pop_off>:

void
pop_off(void)
{
    80000bec:	1141                	addi	sp,sp,-16
    80000bee:	e406                	sd	ra,8(sp)
    80000bf0:	e022                	sd	s0,0(sp)
    80000bf2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bf4:	50d000ef          	jal	ra,80001900 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bf8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000bfc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000bfe:	e78d                	bnez	a5,80000c28 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c00:	5d3c                	lw	a5,120(a0)
    80000c02:	02f05963          	blez	a5,80000c34 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c06:	37fd                	addiw	a5,a5,-1
    80000c08:	0007871b          	sext.w	a4,a5
    80000c0c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c0e:	eb09                	bnez	a4,80000c20 <pop_off+0x34>
    80000c10:	5d7c                	lw	a5,124(a0)
    80000c12:	c799                	beqz	a5,80000c20 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c14:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c18:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c1c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c20:	60a2                	ld	ra,8(sp)
    80000c22:	6402                	ld	s0,0(sp)
    80000c24:	0141                	addi	sp,sp,16
    80000c26:	8082                	ret
    panic("pop_off - interruptible");
    80000c28:	00006517          	auipc	a0,0x6
    80000c2c:	44850513          	addi	a0,a0,1096 # 80007070 <digits+0x38>
    80000c30:	b2dff0ef          	jal	ra,8000075c <panic>
    panic("pop_off");
    80000c34:	00006517          	auipc	a0,0x6
    80000c38:	45450513          	addi	a0,a0,1108 # 80007088 <digits+0x50>
    80000c3c:	b21ff0ef          	jal	ra,8000075c <panic>

0000000080000c40 <release>:
{
    80000c40:	1101                	addi	sp,sp,-32
    80000c42:	ec06                	sd	ra,24(sp)
    80000c44:	e822                	sd	s0,16(sp)
    80000c46:	e426                	sd	s1,8(sp)
    80000c48:	1000                	addi	s0,sp,32
    80000c4a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c4c:	ef3ff0ef          	jal	ra,80000b3e <holding>
    80000c50:	c105                	beqz	a0,80000c70 <release+0x30>
  lk->cpu = 0;
    80000c52:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000c56:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000c5a:	0f50000f          	fence	iorw,ow
    80000c5e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000c62:	f8bff0ef          	jal	ra,80000bec <pop_off>
}
    80000c66:	60e2                	ld	ra,24(sp)
    80000c68:	6442                	ld	s0,16(sp)
    80000c6a:	64a2                	ld	s1,8(sp)
    80000c6c:	6105                	addi	sp,sp,32
    80000c6e:	8082                	ret
    panic("release");
    80000c70:	00006517          	auipc	a0,0x6
    80000c74:	42050513          	addi	a0,a0,1056 # 80007090 <digits+0x58>
    80000c78:	ae5ff0ef          	jal	ra,8000075c <panic>

0000000080000c7c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000c7c:	1141                	addi	sp,sp,-16
    80000c7e:	e422                	sd	s0,8(sp)
    80000c80:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000c82:	ce09                	beqz	a2,80000c9c <memset+0x20>
    80000c84:	87aa                	mv	a5,a0
    80000c86:	fff6071b          	addiw	a4,a2,-1
    80000c8a:	1702                	slli	a4,a4,0x20
    80000c8c:	9301                	srli	a4,a4,0x20
    80000c8e:	0705                	addi	a4,a4,1
    80000c90:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000c92:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000c96:	0785                	addi	a5,a5,1
    80000c98:	fee79de3          	bne	a5,a4,80000c92 <memset+0x16>
  }
  return dst;
}
    80000c9c:	6422                	ld	s0,8(sp)
    80000c9e:	0141                	addi	sp,sp,16
    80000ca0:	8082                	ret

0000000080000ca2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000ca2:	1141                	addi	sp,sp,-16
    80000ca4:	e422                	sd	s0,8(sp)
    80000ca6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000ca8:	ca05                	beqz	a2,80000cd8 <memcmp+0x36>
    80000caa:	fff6069b          	addiw	a3,a2,-1
    80000cae:	1682                	slli	a3,a3,0x20
    80000cb0:	9281                	srli	a3,a3,0x20
    80000cb2:	0685                	addi	a3,a3,1
    80000cb4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cb6:	00054783          	lbu	a5,0(a0)
    80000cba:	0005c703          	lbu	a4,0(a1)
    80000cbe:	00e79863          	bne	a5,a4,80000cce <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000cc2:	0505                	addi	a0,a0,1
    80000cc4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000cc6:	fed518e3          	bne	a0,a3,80000cb6 <memcmp+0x14>
  }

  return 0;
    80000cca:	4501                	li	a0,0
    80000ccc:	a019                	j	80000cd2 <memcmp+0x30>
      return *s1 - *s2;
    80000cce:	40e7853b          	subw	a0,a5,a4
}
    80000cd2:	6422                	ld	s0,8(sp)
    80000cd4:	0141                	addi	sp,sp,16
    80000cd6:	8082                	ret
  return 0;
    80000cd8:	4501                	li	a0,0
    80000cda:	bfe5                	j	80000cd2 <memcmp+0x30>

0000000080000cdc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000cdc:	1141                	addi	sp,sp,-16
    80000cde:	e422                	sd	s0,8(sp)
    80000ce0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000ce2:	ca0d                	beqz	a2,80000d14 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000ce4:	00a5f963          	bgeu	a1,a0,80000cf6 <memmove+0x1a>
    80000ce8:	02061693          	slli	a3,a2,0x20
    80000cec:	9281                	srli	a3,a3,0x20
    80000cee:	00d58733          	add	a4,a1,a3
    80000cf2:	02e56463          	bltu	a0,a4,80000d1a <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000cf6:	fff6079b          	addiw	a5,a2,-1
    80000cfa:	1782                	slli	a5,a5,0x20
    80000cfc:	9381                	srli	a5,a5,0x20
    80000cfe:	0785                	addi	a5,a5,1
    80000d00:	97ae                	add	a5,a5,a1
    80000d02:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d04:	0585                	addi	a1,a1,1
    80000d06:	0705                	addi	a4,a4,1
    80000d08:	fff5c683          	lbu	a3,-1(a1)
    80000d0c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d10:	fef59ae3          	bne	a1,a5,80000d04 <memmove+0x28>

  return dst;
}
    80000d14:	6422                	ld	s0,8(sp)
    80000d16:	0141                	addi	sp,sp,16
    80000d18:	8082                	ret
    d += n;
    80000d1a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d1c:	fff6079b          	addiw	a5,a2,-1
    80000d20:	1782                	slli	a5,a5,0x20
    80000d22:	9381                	srli	a5,a5,0x20
    80000d24:	fff7c793          	not	a5,a5
    80000d28:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d2a:	177d                	addi	a4,a4,-1
    80000d2c:	16fd                	addi	a3,a3,-1
    80000d2e:	00074603          	lbu	a2,0(a4)
    80000d32:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d36:	fef71ae3          	bne	a4,a5,80000d2a <memmove+0x4e>
    80000d3a:	bfe9                	j	80000d14 <memmove+0x38>

0000000080000d3c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d3c:	1141                	addi	sp,sp,-16
    80000d3e:	e406                	sd	ra,8(sp)
    80000d40:	e022                	sd	s0,0(sp)
    80000d42:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d44:	f99ff0ef          	jal	ra,80000cdc <memmove>
}
    80000d48:	60a2                	ld	ra,8(sp)
    80000d4a:	6402                	ld	s0,0(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret

0000000080000d50 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d50:	1141                	addi	sp,sp,-16
    80000d52:	e422                	sd	s0,8(sp)
    80000d54:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d56:	ce11                	beqz	a2,80000d72 <strncmp+0x22>
    80000d58:	00054783          	lbu	a5,0(a0)
    80000d5c:	cf89                	beqz	a5,80000d76 <strncmp+0x26>
    80000d5e:	0005c703          	lbu	a4,0(a1)
    80000d62:	00f71a63          	bne	a4,a5,80000d76 <strncmp+0x26>
    n--, p++, q++;
    80000d66:	367d                	addiw	a2,a2,-1
    80000d68:	0505                	addi	a0,a0,1
    80000d6a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000d6c:	f675                	bnez	a2,80000d58 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000d6e:	4501                	li	a0,0
    80000d70:	a809                	j	80000d82 <strncmp+0x32>
    80000d72:	4501                	li	a0,0
    80000d74:	a039                	j	80000d82 <strncmp+0x32>
  if(n == 0)
    80000d76:	ca09                	beqz	a2,80000d88 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000d78:	00054503          	lbu	a0,0(a0)
    80000d7c:	0005c783          	lbu	a5,0(a1)
    80000d80:	9d1d                	subw	a0,a0,a5
}
    80000d82:	6422                	ld	s0,8(sp)
    80000d84:	0141                	addi	sp,sp,16
    80000d86:	8082                	ret
    return 0;
    80000d88:	4501                	li	a0,0
    80000d8a:	bfe5                	j	80000d82 <strncmp+0x32>

0000000080000d8c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000d8c:	1141                	addi	sp,sp,-16
    80000d8e:	e422                	sd	s0,8(sp)
    80000d90:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000d92:	872a                	mv	a4,a0
    80000d94:	8832                	mv	a6,a2
    80000d96:	367d                	addiw	a2,a2,-1
    80000d98:	01005963          	blez	a6,80000daa <strncpy+0x1e>
    80000d9c:	0705                	addi	a4,a4,1
    80000d9e:	0005c783          	lbu	a5,0(a1)
    80000da2:	fef70fa3          	sb	a5,-1(a4)
    80000da6:	0585                	addi	a1,a1,1
    80000da8:	f7f5                	bnez	a5,80000d94 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000daa:	00c05d63          	blez	a2,80000dc4 <strncpy+0x38>
    80000dae:	86ba                	mv	a3,a4
    *s++ = 0;
    80000db0:	0685                	addi	a3,a3,1
    80000db2:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000db6:	fff6c793          	not	a5,a3
    80000dba:	9fb9                	addw	a5,a5,a4
    80000dbc:	010787bb          	addw	a5,a5,a6
    80000dc0:	fef048e3          	bgtz	a5,80000db0 <strncpy+0x24>
  return os;
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000dd0:	02c05363          	blez	a2,80000df6 <safestrcpy+0x2c>
    80000dd4:	fff6069b          	addiw	a3,a2,-1
    80000dd8:	1682                	slli	a3,a3,0x20
    80000dda:	9281                	srli	a3,a3,0x20
    80000ddc:	96ae                	add	a3,a3,a1
    80000dde:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000de0:	00d58963          	beq	a1,a3,80000df2 <safestrcpy+0x28>
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	0785                	addi	a5,a5,1
    80000de8:	fff5c703          	lbu	a4,-1(a1)
    80000dec:	fee78fa3          	sb	a4,-1(a5)
    80000df0:	fb65                	bnez	a4,80000de0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000df2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000df6:	6422                	ld	s0,8(sp)
    80000df8:	0141                	addi	sp,sp,16
    80000dfa:	8082                	ret

0000000080000dfc <strlen>:

int
strlen(const char *s)
{
    80000dfc:	1141                	addi	sp,sp,-16
    80000dfe:	e422                	sd	s0,8(sp)
    80000e00:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e02:	00054783          	lbu	a5,0(a0)
    80000e06:	cf91                	beqz	a5,80000e22 <strlen+0x26>
    80000e08:	0505                	addi	a0,a0,1
    80000e0a:	87aa                	mv	a5,a0
    80000e0c:	4685                	li	a3,1
    80000e0e:	9e89                	subw	a3,a3,a0
    80000e10:	00f6853b          	addw	a0,a3,a5
    80000e14:	0785                	addi	a5,a5,1
    80000e16:	fff7c703          	lbu	a4,-1(a5)
    80000e1a:	fb7d                	bnez	a4,80000e10 <strlen+0x14>
    ;
  return n;
}
    80000e1c:	6422                	ld	s0,8(sp)
    80000e1e:	0141                	addi	sp,sp,16
    80000e20:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e22:	4501                	li	a0,0
    80000e24:	bfe5                	j	80000e1c <strlen+0x20>

0000000080000e26 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e26:	1141                	addi	sp,sp,-16
    80000e28:	e406                	sd	ra,8(sp)
    80000e2a:	e022                	sd	s0,0(sp)
    80000e2c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e2e:	2c3000ef          	jal	ra,800018f0 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e32:	00007717          	auipc	a4,0x7
    80000e36:	b5670713          	addi	a4,a4,-1194 # 80007988 <started>
  if(cpuid() == 0){
    80000e3a:	c51d                	beqz	a0,80000e68 <main+0x42>
    while(started == 0)
    80000e3c:	431c                	lw	a5,0(a4)
    80000e3e:	2781                	sext.w	a5,a5
    80000e40:	dff5                	beqz	a5,80000e3c <main+0x16>
      ;
    __sync_synchronize();
    80000e42:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e46:	2ab000ef          	jal	ra,800018f0 <cpuid>
    80000e4a:	85aa                	mv	a1,a0
    80000e4c:	00006517          	auipc	a0,0x6
    80000e50:	26450513          	addi	a0,a0,612 # 800070b0 <digits+0x78>
    80000e54:	e54ff0ef          	jal	ra,800004a8 <printf>
    kvminithart();    // turn on paging
    80000e58:	080000ef          	jal	ra,80000ed8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e5c:	5a8010ef          	jal	ra,80002404 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e60:	444040ef          	jal	ra,800052a4 <plicinithart>
  }

  scheduler();        
    80000e64:	6e7000ef          	jal	ra,80001d4a <scheduler>
    consoleinit();
    80000e68:	d68ff0ef          	jal	ra,800003d0 <consoleinit>
    printfinit();
    80000e6c:	92bff0ef          	jal	ra,80000796 <printfinit>
    printf("\n");
    80000e70:	00006517          	auipc	a0,0x6
    80000e74:	25050513          	addi	a0,a0,592 # 800070c0 <digits+0x88>
    80000e78:	e30ff0ef          	jal	ra,800004a8 <printf>
    printf("xv6 kernel is booting\n");
    80000e7c:	00006517          	auipc	a0,0x6
    80000e80:	21c50513          	addi	a0,a0,540 # 80007098 <digits+0x60>
    80000e84:	e24ff0ef          	jal	ra,800004a8 <printf>
    printf("\n");
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	23850513          	addi	a0,a0,568 # 800070c0 <digits+0x88>
    80000e90:	e18ff0ef          	jal	ra,800004a8 <printf>
    kinit();         // physical page allocator
    80000e94:	c11ff0ef          	jal	ra,80000aa4 <kinit>
    kvminit();       // create kernel page table
    80000e98:	2ca000ef          	jal	ra,80001162 <kvminit>
    kvminithart();   // turn on paging
    80000e9c:	03c000ef          	jal	ra,80000ed8 <kvminithart>
    procinit();      // process table
    80000ea0:	1a9000ef          	jal	ra,80001848 <procinit>
    trapinit();      // trap vectors
    80000ea4:	53c010ef          	jal	ra,800023e0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ea8:	55c010ef          	jal	ra,80002404 <trapinithart>
    plicinit();      // set up interrupt controller
    80000eac:	3e2040ef          	jal	ra,8000528e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eb0:	3f4040ef          	jal	ra,800052a4 <plicinithart>
    binit();         // buffer cache
    80000eb4:	45b010ef          	jal	ra,80002b0e <binit>
    iinit();         // inode table
    80000eb8:	23a020ef          	jal	ra,800030f2 <iinit>
    fileinit();      // file table
    80000ebc:	7d5020ef          	jal	ra,80003e90 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ec0:	4d4040ef          	jal	ra,80005394 <virtio_disk_init>
    userinit();      // first user process
    80000ec4:	4c1000ef          	jal	ra,80001b84 <userinit>
    __sync_synchronize();
    80000ec8:	0ff0000f          	fence
    started = 1;
    80000ecc:	4785                	li	a5,1
    80000ece:	00007717          	auipc	a4,0x7
    80000ed2:	aaf72d23          	sw	a5,-1350(a4) # 80007988 <started>
    80000ed6:	b779                	j	80000e64 <main+0x3e>

0000000080000ed8 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000ed8:	1141                	addi	sp,sp,-16
    80000eda:	e422                	sd	s0,8(sp)
    80000edc:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000ede:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ee2:	00007797          	auipc	a5,0x7
    80000ee6:	aae7b783          	ld	a5,-1362(a5) # 80007990 <kernel_pagetable>
    80000eea:	83b1                	srli	a5,a5,0xc
    80000eec:	577d                	li	a4,-1
    80000eee:	177e                	slli	a4,a4,0x3f
    80000ef0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000ef2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000ef6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret

0000000080000f00 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f00:	7139                	addi	sp,sp,-64
    80000f02:	fc06                	sd	ra,56(sp)
    80000f04:	f822                	sd	s0,48(sp)
    80000f06:	f426                	sd	s1,40(sp)
    80000f08:	f04a                	sd	s2,32(sp)
    80000f0a:	ec4e                	sd	s3,24(sp)
    80000f0c:	e852                	sd	s4,16(sp)
    80000f0e:	e456                	sd	s5,8(sp)
    80000f10:	e05a                	sd	s6,0(sp)
    80000f12:	0080                	addi	s0,sp,64
    80000f14:	84aa                	mv	s1,a0
    80000f16:	89ae                	mv	s3,a1
    80000f18:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f1a:	57fd                	li	a5,-1
    80000f1c:	83e9                	srli	a5,a5,0x1a
    80000f1e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f20:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f22:	02b7fc63          	bgeu	a5,a1,80000f5a <walk+0x5a>
    panic("walk");
    80000f26:	00006517          	auipc	a0,0x6
    80000f2a:	1a250513          	addi	a0,a0,418 # 800070c8 <digits+0x90>
    80000f2e:	82fff0ef          	jal	ra,8000075c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f32:	060a8263          	beqz	s5,80000f96 <walk+0x96>
    80000f36:	ba3ff0ef          	jal	ra,80000ad8 <kalloc>
    80000f3a:	84aa                	mv	s1,a0
    80000f3c:	c139                	beqz	a0,80000f82 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f3e:	6605                	lui	a2,0x1
    80000f40:	4581                	li	a1,0
    80000f42:	d3bff0ef          	jal	ra,80000c7c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f46:	00c4d793          	srli	a5,s1,0xc
    80000f4a:	07aa                	slli	a5,a5,0xa
    80000f4c:	0017e793          	ori	a5,a5,1
    80000f50:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f54:	3a5d                	addiw	s4,s4,-9
    80000f56:	036a0063          	beq	s4,s6,80000f76 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f5a:	0149d933          	srl	s2,s3,s4
    80000f5e:	1ff97913          	andi	s2,s2,511
    80000f62:	090e                	slli	s2,s2,0x3
    80000f64:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000f66:	00093483          	ld	s1,0(s2)
    80000f6a:	0014f793          	andi	a5,s1,1
    80000f6e:	d3f1                	beqz	a5,80000f32 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f70:	80a9                	srli	s1,s1,0xa
    80000f72:	04b2                	slli	s1,s1,0xc
    80000f74:	b7c5                	j	80000f54 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f76:	00c9d513          	srli	a0,s3,0xc
    80000f7a:	1ff57513          	andi	a0,a0,511
    80000f7e:	050e                	slli	a0,a0,0x3
    80000f80:	9526                	add	a0,a0,s1
}
    80000f82:	70e2                	ld	ra,56(sp)
    80000f84:	7442                	ld	s0,48(sp)
    80000f86:	74a2                	ld	s1,40(sp)
    80000f88:	7902                	ld	s2,32(sp)
    80000f8a:	69e2                	ld	s3,24(sp)
    80000f8c:	6a42                	ld	s4,16(sp)
    80000f8e:	6aa2                	ld	s5,8(sp)
    80000f90:	6b02                	ld	s6,0(sp)
    80000f92:	6121                	addi	sp,sp,64
    80000f94:	8082                	ret
        return 0;
    80000f96:	4501                	li	a0,0
    80000f98:	b7ed                	j	80000f82 <walk+0x82>

0000000080000f9a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000f9a:	57fd                	li	a5,-1
    80000f9c:	83e9                	srli	a5,a5,0x1a
    80000f9e:	00b7f463          	bgeu	a5,a1,80000fa6 <walkaddr+0xc>
    return 0;
    80000fa2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fa4:	8082                	ret
{
    80000fa6:	1141                	addi	sp,sp,-16
    80000fa8:	e406                	sd	ra,8(sp)
    80000faa:	e022                	sd	s0,0(sp)
    80000fac:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fae:	4601                	li	a2,0
    80000fb0:	f51ff0ef          	jal	ra,80000f00 <walk>
  if(pte == 0)
    80000fb4:	c105                	beqz	a0,80000fd4 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000fb6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000fb8:	0117f693          	andi	a3,a5,17
    80000fbc:	4745                	li	a4,17
    return 0;
    80000fbe:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000fc0:	00e68663          	beq	a3,a4,80000fcc <walkaddr+0x32>
}
    80000fc4:	60a2                	ld	ra,8(sp)
    80000fc6:	6402                	ld	s0,0(sp)
    80000fc8:	0141                	addi	sp,sp,16
    80000fca:	8082                	ret
  pa = PTE2PA(*pte);
    80000fcc:	00a7d513          	srli	a0,a5,0xa
    80000fd0:	0532                	slli	a0,a0,0xc
  return pa;
    80000fd2:	bfcd                	j	80000fc4 <walkaddr+0x2a>
    return 0;
    80000fd4:	4501                	li	a0,0
    80000fd6:	b7fd                	j	80000fc4 <walkaddr+0x2a>

0000000080000fd8 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fd8:	715d                	addi	sp,sp,-80
    80000fda:	e486                	sd	ra,72(sp)
    80000fdc:	e0a2                	sd	s0,64(sp)
    80000fde:	fc26                	sd	s1,56(sp)
    80000fe0:	f84a                	sd	s2,48(sp)
    80000fe2:	f44e                	sd	s3,40(sp)
    80000fe4:	f052                	sd	s4,32(sp)
    80000fe6:	ec56                	sd	s5,24(sp)
    80000fe8:	e85a                	sd	s6,16(sp)
    80000fea:	e45e                	sd	s7,8(sp)
    80000fec:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000fee:	03459793          	slli	a5,a1,0x34
    80000ff2:	e385                	bnez	a5,80001012 <mappages+0x3a>
    80000ff4:	8aaa                	mv	s5,a0
    80000ff6:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80000ff8:	03461793          	slli	a5,a2,0x34
    80000ffc:	e38d                	bnez	a5,8000101e <mappages+0x46>
    panic("mappages: size not aligned");

  if(size == 0)
    80000ffe:	c615                	beqz	a2,8000102a <mappages+0x52>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001000:	79fd                	lui	s3,0xfffff
    80001002:	964e                	add	a2,a2,s3
    80001004:	00b609b3          	add	s3,a2,a1
  a = va;
    80001008:	892e                	mv	s2,a1
    8000100a:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000100e:	6b85                	lui	s7,0x1
    80001010:	a815                	j	80001044 <mappages+0x6c>
    panic("mappages: va not aligned");
    80001012:	00006517          	auipc	a0,0x6
    80001016:	0be50513          	addi	a0,a0,190 # 800070d0 <digits+0x98>
    8000101a:	f42ff0ef          	jal	ra,8000075c <panic>
    panic("mappages: size not aligned");
    8000101e:	00006517          	auipc	a0,0x6
    80001022:	0d250513          	addi	a0,a0,210 # 800070f0 <digits+0xb8>
    80001026:	f36ff0ef          	jal	ra,8000075c <panic>
    panic("mappages: size");
    8000102a:	00006517          	auipc	a0,0x6
    8000102e:	0e650513          	addi	a0,a0,230 # 80007110 <digits+0xd8>
    80001032:	f2aff0ef          	jal	ra,8000075c <panic>
      panic("mappages: remap");
    80001036:	00006517          	auipc	a0,0x6
    8000103a:	0ea50513          	addi	a0,a0,234 # 80007120 <digits+0xe8>
    8000103e:	f1eff0ef          	jal	ra,8000075c <panic>
    a += PGSIZE;
    80001042:	995e                	add	s2,s2,s7
  for(;;){
    80001044:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    80001048:	4605                	li	a2,1
    8000104a:	85ca                	mv	a1,s2
    8000104c:	8556                	mv	a0,s5
    8000104e:	eb3ff0ef          	jal	ra,80000f00 <walk>
    80001052:	cd19                	beqz	a0,80001070 <mappages+0x98>
    if(*pte & PTE_V)
    80001054:	611c                	ld	a5,0(a0)
    80001056:	8b85                	andi	a5,a5,1
    80001058:	fff9                	bnez	a5,80001036 <mappages+0x5e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000105a:	80b1                	srli	s1,s1,0xc
    8000105c:	04aa                	slli	s1,s1,0xa
    8000105e:	0164e4b3          	or	s1,s1,s6
    80001062:	0014e493          	ori	s1,s1,1
    80001066:	e104                	sd	s1,0(a0)
    if(a == last)
    80001068:	fd391de3          	bne	s2,s3,80001042 <mappages+0x6a>
    pa += PGSIZE;
  }
  return 0;
    8000106c:	4501                	li	a0,0
    8000106e:	a011                	j	80001072 <mappages+0x9a>
      return -1;
    80001070:	557d                	li	a0,-1
}
    80001072:	60a6                	ld	ra,72(sp)
    80001074:	6406                	ld	s0,64(sp)
    80001076:	74e2                	ld	s1,56(sp)
    80001078:	7942                	ld	s2,48(sp)
    8000107a:	79a2                	ld	s3,40(sp)
    8000107c:	7a02                	ld	s4,32(sp)
    8000107e:	6ae2                	ld	s5,24(sp)
    80001080:	6b42                	ld	s6,16(sp)
    80001082:	6ba2                	ld	s7,8(sp)
    80001084:	6161                	addi	sp,sp,80
    80001086:	8082                	ret

0000000080001088 <kvmmap>:
{
    80001088:	1141                	addi	sp,sp,-16
    8000108a:	e406                	sd	ra,8(sp)
    8000108c:	e022                	sd	s0,0(sp)
    8000108e:	0800                	addi	s0,sp,16
    80001090:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001092:	86b2                	mv	a3,a2
    80001094:	863e                	mv	a2,a5
    80001096:	f43ff0ef          	jal	ra,80000fd8 <mappages>
    8000109a:	e509                	bnez	a0,800010a4 <kvmmap+0x1c>
}
    8000109c:	60a2                	ld	ra,8(sp)
    8000109e:	6402                	ld	s0,0(sp)
    800010a0:	0141                	addi	sp,sp,16
    800010a2:	8082                	ret
    panic("kvmmap");
    800010a4:	00006517          	auipc	a0,0x6
    800010a8:	08c50513          	addi	a0,a0,140 # 80007130 <digits+0xf8>
    800010ac:	eb0ff0ef          	jal	ra,8000075c <panic>

00000000800010b0 <kvmmake>:
{
    800010b0:	1101                	addi	sp,sp,-32
    800010b2:	ec06                	sd	ra,24(sp)
    800010b4:	e822                	sd	s0,16(sp)
    800010b6:	e426                	sd	s1,8(sp)
    800010b8:	e04a                	sd	s2,0(sp)
    800010ba:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010bc:	a1dff0ef          	jal	ra,80000ad8 <kalloc>
    800010c0:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010c2:	6605                	lui	a2,0x1
    800010c4:	4581                	li	a1,0
    800010c6:	bb7ff0ef          	jal	ra,80000c7c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800010ca:	4719                	li	a4,6
    800010cc:	6685                	lui	a3,0x1
    800010ce:	10000637          	lui	a2,0x10000
    800010d2:	100005b7          	lui	a1,0x10000
    800010d6:	8526                	mv	a0,s1
    800010d8:	fb1ff0ef          	jal	ra,80001088 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010dc:	4719                	li	a4,6
    800010de:	6685                	lui	a3,0x1
    800010e0:	10001637          	lui	a2,0x10001
    800010e4:	100015b7          	lui	a1,0x10001
    800010e8:	8526                	mv	a0,s1
    800010ea:	f9fff0ef          	jal	ra,80001088 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010ee:	4719                	li	a4,6
    800010f0:	040006b7          	lui	a3,0x4000
    800010f4:	0c000637          	lui	a2,0xc000
    800010f8:	0c0005b7          	lui	a1,0xc000
    800010fc:	8526                	mv	a0,s1
    800010fe:	f8bff0ef          	jal	ra,80001088 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001102:	00006917          	auipc	s2,0x6
    80001106:	efe90913          	addi	s2,s2,-258 # 80007000 <etext>
    8000110a:	4729                	li	a4,10
    8000110c:	80006697          	auipc	a3,0x80006
    80001110:	ef468693          	addi	a3,a3,-268 # 7000 <_entry-0x7fff9000>
    80001114:	4605                	li	a2,1
    80001116:	067e                	slli	a2,a2,0x1f
    80001118:	85b2                	mv	a1,a2
    8000111a:	8526                	mv	a0,s1
    8000111c:	f6dff0ef          	jal	ra,80001088 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001120:	4719                	li	a4,6
    80001122:	46c5                	li	a3,17
    80001124:	06ee                	slli	a3,a3,0x1b
    80001126:	412686b3          	sub	a3,a3,s2
    8000112a:	864a                	mv	a2,s2
    8000112c:	85ca                	mv	a1,s2
    8000112e:	8526                	mv	a0,s1
    80001130:	f59ff0ef          	jal	ra,80001088 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001134:	4729                	li	a4,10
    80001136:	6685                	lui	a3,0x1
    80001138:	00005617          	auipc	a2,0x5
    8000113c:	ec860613          	addi	a2,a2,-312 # 80006000 <_trampoline>
    80001140:	040005b7          	lui	a1,0x4000
    80001144:	15fd                	addi	a1,a1,-1
    80001146:	05b2                	slli	a1,a1,0xc
    80001148:	8526                	mv	a0,s1
    8000114a:	f3fff0ef          	jal	ra,80001088 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000114e:	8526                	mv	a0,s1
    80001150:	66e000ef          	jal	ra,800017be <proc_mapstacks>
}
    80001154:	8526                	mv	a0,s1
    80001156:	60e2                	ld	ra,24(sp)
    80001158:	6442                	ld	s0,16(sp)
    8000115a:	64a2                	ld	s1,8(sp)
    8000115c:	6902                	ld	s2,0(sp)
    8000115e:	6105                	addi	sp,sp,32
    80001160:	8082                	ret

0000000080001162 <kvminit>:
{
    80001162:	1141                	addi	sp,sp,-16
    80001164:	e406                	sd	ra,8(sp)
    80001166:	e022                	sd	s0,0(sp)
    80001168:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000116a:	f47ff0ef          	jal	ra,800010b0 <kvmmake>
    8000116e:	00007797          	auipc	a5,0x7
    80001172:	82a7b123          	sd	a0,-2014(a5) # 80007990 <kernel_pagetable>
}
    80001176:	60a2                	ld	ra,8(sp)
    80001178:	6402                	ld	s0,0(sp)
    8000117a:	0141                	addi	sp,sp,16
    8000117c:	8082                	ret

000000008000117e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000117e:	715d                	addi	sp,sp,-80
    80001180:	e486                	sd	ra,72(sp)
    80001182:	e0a2                	sd	s0,64(sp)
    80001184:	fc26                	sd	s1,56(sp)
    80001186:	f84a                	sd	s2,48(sp)
    80001188:	f44e                	sd	s3,40(sp)
    8000118a:	f052                	sd	s4,32(sp)
    8000118c:	ec56                	sd	s5,24(sp)
    8000118e:	e85a                	sd	s6,16(sp)
    80001190:	e45e                	sd	s7,8(sp)
    80001192:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001194:	03459793          	slli	a5,a1,0x34
    80001198:	e795                	bnez	a5,800011c4 <uvmunmap+0x46>
    8000119a:	8a2a                	mv	s4,a0
    8000119c:	892e                	mv	s2,a1
    8000119e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011a0:	0632                	slli	a2,a2,0xc
    800011a2:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011a6:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011a8:	6b05                	lui	s6,0x1
    800011aa:	0535ee63          	bltu	a1,s3,80001206 <uvmunmap+0x88>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800011ae:	60a6                	ld	ra,72(sp)
    800011b0:	6406                	ld	s0,64(sp)
    800011b2:	74e2                	ld	s1,56(sp)
    800011b4:	7942                	ld	s2,48(sp)
    800011b6:	79a2                	ld	s3,40(sp)
    800011b8:	7a02                	ld	s4,32(sp)
    800011ba:	6ae2                	ld	s5,24(sp)
    800011bc:	6b42                	ld	s6,16(sp)
    800011be:	6ba2                	ld	s7,8(sp)
    800011c0:	6161                	addi	sp,sp,80
    800011c2:	8082                	ret
    panic("uvmunmap: not aligned");
    800011c4:	00006517          	auipc	a0,0x6
    800011c8:	f7450513          	addi	a0,a0,-140 # 80007138 <digits+0x100>
    800011cc:	d90ff0ef          	jal	ra,8000075c <panic>
      panic("uvmunmap: walk");
    800011d0:	00006517          	auipc	a0,0x6
    800011d4:	f8050513          	addi	a0,a0,-128 # 80007150 <digits+0x118>
    800011d8:	d84ff0ef          	jal	ra,8000075c <panic>
      panic("uvmunmap: not mapped");
    800011dc:	00006517          	auipc	a0,0x6
    800011e0:	f8450513          	addi	a0,a0,-124 # 80007160 <digits+0x128>
    800011e4:	d78ff0ef          	jal	ra,8000075c <panic>
      panic("uvmunmap: not a leaf");
    800011e8:	00006517          	auipc	a0,0x6
    800011ec:	f9050513          	addi	a0,a0,-112 # 80007178 <digits+0x140>
    800011f0:	d6cff0ef          	jal	ra,8000075c <panic>
      uint64 pa = PTE2PA(*pte);
    800011f4:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800011f6:	0532                	slli	a0,a0,0xc
    800011f8:	801ff0ef          	jal	ra,800009f8 <kfree>
    *pte = 0;
    800011fc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001200:	995a                	add	s2,s2,s6
    80001202:	fb3976e3          	bgeu	s2,s3,800011ae <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001206:	4601                	li	a2,0
    80001208:	85ca                	mv	a1,s2
    8000120a:	8552                	mv	a0,s4
    8000120c:	cf5ff0ef          	jal	ra,80000f00 <walk>
    80001210:	84aa                	mv	s1,a0
    80001212:	dd5d                	beqz	a0,800011d0 <uvmunmap+0x52>
    if((*pte & PTE_V) == 0)
    80001214:	6108                	ld	a0,0(a0)
    80001216:	00157793          	andi	a5,a0,1
    8000121a:	d3e9                	beqz	a5,800011dc <uvmunmap+0x5e>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000121c:	3ff57793          	andi	a5,a0,1023
    80001220:	fd7784e3          	beq	a5,s7,800011e8 <uvmunmap+0x6a>
    if(do_free){
    80001224:	fc0a8ce3          	beqz	s5,800011fc <uvmunmap+0x7e>
    80001228:	b7f1                	j	800011f4 <uvmunmap+0x76>

000000008000122a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000122a:	1101                	addi	sp,sp,-32
    8000122c:	ec06                	sd	ra,24(sp)
    8000122e:	e822                	sd	s0,16(sp)
    80001230:	e426                	sd	s1,8(sp)
    80001232:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001234:	8a5ff0ef          	jal	ra,80000ad8 <kalloc>
    80001238:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000123a:	c509                	beqz	a0,80001244 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000123c:	6605                	lui	a2,0x1
    8000123e:	4581                	li	a1,0
    80001240:	a3dff0ef          	jal	ra,80000c7c <memset>
  return pagetable;
}
    80001244:	8526                	mv	a0,s1
    80001246:	60e2                	ld	ra,24(sp)
    80001248:	6442                	ld	s0,16(sp)
    8000124a:	64a2                	ld	s1,8(sp)
    8000124c:	6105                	addi	sp,sp,32
    8000124e:	8082                	ret

0000000080001250 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001250:	7179                	addi	sp,sp,-48
    80001252:	f406                	sd	ra,40(sp)
    80001254:	f022                	sd	s0,32(sp)
    80001256:	ec26                	sd	s1,24(sp)
    80001258:	e84a                	sd	s2,16(sp)
    8000125a:	e44e                	sd	s3,8(sp)
    8000125c:	e052                	sd	s4,0(sp)
    8000125e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001260:	6785                	lui	a5,0x1
    80001262:	04f67063          	bgeu	a2,a5,800012a2 <uvmfirst+0x52>
    80001266:	8a2a                	mv	s4,a0
    80001268:	89ae                	mv	s3,a1
    8000126a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000126c:	86dff0ef          	jal	ra,80000ad8 <kalloc>
    80001270:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001272:	6605                	lui	a2,0x1
    80001274:	4581                	li	a1,0
    80001276:	a07ff0ef          	jal	ra,80000c7c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000127a:	4779                	li	a4,30
    8000127c:	86ca                	mv	a3,s2
    8000127e:	6605                	lui	a2,0x1
    80001280:	4581                	li	a1,0
    80001282:	8552                	mv	a0,s4
    80001284:	d55ff0ef          	jal	ra,80000fd8 <mappages>
  memmove(mem, src, sz);
    80001288:	8626                	mv	a2,s1
    8000128a:	85ce                	mv	a1,s3
    8000128c:	854a                	mv	a0,s2
    8000128e:	a4fff0ef          	jal	ra,80000cdc <memmove>
}
    80001292:	70a2                	ld	ra,40(sp)
    80001294:	7402                	ld	s0,32(sp)
    80001296:	64e2                	ld	s1,24(sp)
    80001298:	6942                	ld	s2,16(sp)
    8000129a:	69a2                	ld	s3,8(sp)
    8000129c:	6a02                	ld	s4,0(sp)
    8000129e:	6145                	addi	sp,sp,48
    800012a0:	8082                	ret
    panic("uvmfirst: more than a page");
    800012a2:	00006517          	auipc	a0,0x6
    800012a6:	eee50513          	addi	a0,a0,-274 # 80007190 <digits+0x158>
    800012aa:	cb2ff0ef          	jal	ra,8000075c <panic>

00000000800012ae <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012ae:	1101                	addi	sp,sp,-32
    800012b0:	ec06                	sd	ra,24(sp)
    800012b2:	e822                	sd	s0,16(sp)
    800012b4:	e426                	sd	s1,8(sp)
    800012b6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012b8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012ba:	00b67d63          	bgeu	a2,a1,800012d4 <uvmdealloc+0x26>
    800012be:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800012c0:	6785                	lui	a5,0x1
    800012c2:	17fd                	addi	a5,a5,-1
    800012c4:	00f60733          	add	a4,a2,a5
    800012c8:	767d                	lui	a2,0xfffff
    800012ca:	8f71                	and	a4,a4,a2
    800012cc:	97ae                	add	a5,a5,a1
    800012ce:	8ff1                	and	a5,a5,a2
    800012d0:	00f76863          	bltu	a4,a5,800012e0 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800012d4:	8526                	mv	a0,s1
    800012d6:	60e2                	ld	ra,24(sp)
    800012d8:	6442                	ld	s0,16(sp)
    800012da:	64a2                	ld	s1,8(sp)
    800012dc:	6105                	addi	sp,sp,32
    800012de:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800012e0:	8f99                	sub	a5,a5,a4
    800012e2:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800012e4:	4685                	li	a3,1
    800012e6:	0007861b          	sext.w	a2,a5
    800012ea:	85ba                	mv	a1,a4
    800012ec:	e93ff0ef          	jal	ra,8000117e <uvmunmap>
    800012f0:	b7d5                	j	800012d4 <uvmdealloc+0x26>

00000000800012f2 <uvmalloc>:
  if(newsz < oldsz)
    800012f2:	08b66963          	bltu	a2,a1,80001384 <uvmalloc+0x92>
{
    800012f6:	7139                	addi	sp,sp,-64
    800012f8:	fc06                	sd	ra,56(sp)
    800012fa:	f822                	sd	s0,48(sp)
    800012fc:	f426                	sd	s1,40(sp)
    800012fe:	f04a                	sd	s2,32(sp)
    80001300:	ec4e                	sd	s3,24(sp)
    80001302:	e852                	sd	s4,16(sp)
    80001304:	e456                	sd	s5,8(sp)
    80001306:	e05a                	sd	s6,0(sp)
    80001308:	0080                	addi	s0,sp,64
    8000130a:	8aaa                	mv	s5,a0
    8000130c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000130e:	6985                	lui	s3,0x1
    80001310:	19fd                	addi	s3,s3,-1
    80001312:	95ce                	add	a1,a1,s3
    80001314:	79fd                	lui	s3,0xfffff
    80001316:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000131a:	06c9f763          	bgeu	s3,a2,80001388 <uvmalloc+0x96>
    8000131e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001320:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001324:	fb4ff0ef          	jal	ra,80000ad8 <kalloc>
    80001328:	84aa                	mv	s1,a0
    if(mem == 0){
    8000132a:	c11d                	beqz	a0,80001350 <uvmalloc+0x5e>
    memset(mem, 0, PGSIZE);
    8000132c:	6605                	lui	a2,0x1
    8000132e:	4581                	li	a1,0
    80001330:	94dff0ef          	jal	ra,80000c7c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001334:	875a                	mv	a4,s6
    80001336:	86a6                	mv	a3,s1
    80001338:	6605                	lui	a2,0x1
    8000133a:	85ca                	mv	a1,s2
    8000133c:	8556                	mv	a0,s5
    8000133e:	c9bff0ef          	jal	ra,80000fd8 <mappages>
    80001342:	e51d                	bnez	a0,80001370 <uvmalloc+0x7e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001344:	6785                	lui	a5,0x1
    80001346:	993e                	add	s2,s2,a5
    80001348:	fd496ee3          	bltu	s2,s4,80001324 <uvmalloc+0x32>
  return newsz;
    8000134c:	8552                	mv	a0,s4
    8000134e:	a039                	j	8000135c <uvmalloc+0x6a>
      uvmdealloc(pagetable, a, oldsz);
    80001350:	864e                	mv	a2,s3
    80001352:	85ca                	mv	a1,s2
    80001354:	8556                	mv	a0,s5
    80001356:	f59ff0ef          	jal	ra,800012ae <uvmdealloc>
      return 0;
    8000135a:	4501                	li	a0,0
}
    8000135c:	70e2                	ld	ra,56(sp)
    8000135e:	7442                	ld	s0,48(sp)
    80001360:	74a2                	ld	s1,40(sp)
    80001362:	7902                	ld	s2,32(sp)
    80001364:	69e2                	ld	s3,24(sp)
    80001366:	6a42                	ld	s4,16(sp)
    80001368:	6aa2                	ld	s5,8(sp)
    8000136a:	6b02                	ld	s6,0(sp)
    8000136c:	6121                	addi	sp,sp,64
    8000136e:	8082                	ret
      kfree(mem);
    80001370:	8526                	mv	a0,s1
    80001372:	e86ff0ef          	jal	ra,800009f8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001376:	864e                	mv	a2,s3
    80001378:	85ca                	mv	a1,s2
    8000137a:	8556                	mv	a0,s5
    8000137c:	f33ff0ef          	jal	ra,800012ae <uvmdealloc>
      return 0;
    80001380:	4501                	li	a0,0
    80001382:	bfe9                	j	8000135c <uvmalloc+0x6a>
    return oldsz;
    80001384:	852e                	mv	a0,a1
}
    80001386:	8082                	ret
  return newsz;
    80001388:	8532                	mv	a0,a2
    8000138a:	bfc9                	j	8000135c <uvmalloc+0x6a>

000000008000138c <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000138c:	7179                	addi	sp,sp,-48
    8000138e:	f406                	sd	ra,40(sp)
    80001390:	f022                	sd	s0,32(sp)
    80001392:	ec26                	sd	s1,24(sp)
    80001394:	e84a                	sd	s2,16(sp)
    80001396:	e44e                	sd	s3,8(sp)
    80001398:	e052                	sd	s4,0(sp)
    8000139a:	1800                	addi	s0,sp,48
    8000139c:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000139e:	84aa                	mv	s1,a0
    800013a0:	6905                	lui	s2,0x1
    800013a2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013a4:	4985                	li	s3,1
    800013a6:	a811                	j	800013ba <freewalk+0x2e>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800013a8:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800013aa:	0532                	slli	a0,a0,0xc
    800013ac:	fe1ff0ef          	jal	ra,8000138c <freewalk>
      pagetable[i] = 0;
    800013b0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800013b4:	04a1                	addi	s1,s1,8
    800013b6:	01248f63          	beq	s1,s2,800013d4 <freewalk+0x48>
    pte_t pte = pagetable[i];
    800013ba:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013bc:	00f57793          	andi	a5,a0,15
    800013c0:	ff3784e3          	beq	a5,s3,800013a8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800013c4:	8905                	andi	a0,a0,1
    800013c6:	d57d                	beqz	a0,800013b4 <freewalk+0x28>
      panic("freewalk: leaf");
    800013c8:	00006517          	auipc	a0,0x6
    800013cc:	de850513          	addi	a0,a0,-536 # 800071b0 <digits+0x178>
    800013d0:	b8cff0ef          	jal	ra,8000075c <panic>
    }
  }
  kfree((void*)pagetable);
    800013d4:	8552                	mv	a0,s4
    800013d6:	e22ff0ef          	jal	ra,800009f8 <kfree>
}
    800013da:	70a2                	ld	ra,40(sp)
    800013dc:	7402                	ld	s0,32(sp)
    800013de:	64e2                	ld	s1,24(sp)
    800013e0:	6942                	ld	s2,16(sp)
    800013e2:	69a2                	ld	s3,8(sp)
    800013e4:	6a02                	ld	s4,0(sp)
    800013e6:	6145                	addi	sp,sp,48
    800013e8:	8082                	ret

00000000800013ea <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800013ea:	1101                	addi	sp,sp,-32
    800013ec:	ec06                	sd	ra,24(sp)
    800013ee:	e822                	sd	s0,16(sp)
    800013f0:	e426                	sd	s1,8(sp)
    800013f2:	1000                	addi	s0,sp,32
    800013f4:	84aa                	mv	s1,a0
  if(sz > 0)
    800013f6:	e989                	bnez	a1,80001408 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800013f8:	8526                	mv	a0,s1
    800013fa:	f93ff0ef          	jal	ra,8000138c <freewalk>
}
    800013fe:	60e2                	ld	ra,24(sp)
    80001400:	6442                	ld	s0,16(sp)
    80001402:	64a2                	ld	s1,8(sp)
    80001404:	6105                	addi	sp,sp,32
    80001406:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001408:	6605                	lui	a2,0x1
    8000140a:	167d                	addi	a2,a2,-1
    8000140c:	962e                	add	a2,a2,a1
    8000140e:	4685                	li	a3,1
    80001410:	8231                	srli	a2,a2,0xc
    80001412:	4581                	li	a1,0
    80001414:	d6bff0ef          	jal	ra,8000117e <uvmunmap>
    80001418:	b7c5                	j	800013f8 <uvmfree+0xe>

000000008000141a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000141a:	c65d                	beqz	a2,800014c8 <uvmcopy+0xae>
{
    8000141c:	715d                	addi	sp,sp,-80
    8000141e:	e486                	sd	ra,72(sp)
    80001420:	e0a2                	sd	s0,64(sp)
    80001422:	fc26                	sd	s1,56(sp)
    80001424:	f84a                	sd	s2,48(sp)
    80001426:	f44e                	sd	s3,40(sp)
    80001428:	f052                	sd	s4,32(sp)
    8000142a:	ec56                	sd	s5,24(sp)
    8000142c:	e85a                	sd	s6,16(sp)
    8000142e:	e45e                	sd	s7,8(sp)
    80001430:	0880                	addi	s0,sp,80
    80001432:	8b2a                	mv	s6,a0
    80001434:	8aae                	mv	s5,a1
    80001436:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001438:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000143a:	4601                	li	a2,0
    8000143c:	85ce                	mv	a1,s3
    8000143e:	855a                	mv	a0,s6
    80001440:	ac1ff0ef          	jal	ra,80000f00 <walk>
    80001444:	c121                	beqz	a0,80001484 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001446:	6118                	ld	a4,0(a0)
    80001448:	00177793          	andi	a5,a4,1
    8000144c:	c3b1                	beqz	a5,80001490 <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000144e:	00a75593          	srli	a1,a4,0xa
    80001452:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001456:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000145a:	e7eff0ef          	jal	ra,80000ad8 <kalloc>
    8000145e:	892a                	mv	s2,a0
    80001460:	c129                	beqz	a0,800014a2 <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001462:	6605                	lui	a2,0x1
    80001464:	85de                	mv	a1,s7
    80001466:	877ff0ef          	jal	ra,80000cdc <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000146a:	8726                	mv	a4,s1
    8000146c:	86ca                	mv	a3,s2
    8000146e:	6605                	lui	a2,0x1
    80001470:	85ce                	mv	a1,s3
    80001472:	8556                	mv	a0,s5
    80001474:	b65ff0ef          	jal	ra,80000fd8 <mappages>
    80001478:	e115                	bnez	a0,8000149c <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    8000147a:	6785                	lui	a5,0x1
    8000147c:	99be                	add	s3,s3,a5
    8000147e:	fb49eee3          	bltu	s3,s4,8000143a <uvmcopy+0x20>
    80001482:	a805                	j	800014b2 <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    80001484:	00006517          	auipc	a0,0x6
    80001488:	d3c50513          	addi	a0,a0,-708 # 800071c0 <digits+0x188>
    8000148c:	ad0ff0ef          	jal	ra,8000075c <panic>
      panic("uvmcopy: page not present");
    80001490:	00006517          	auipc	a0,0x6
    80001494:	d5050513          	addi	a0,a0,-688 # 800071e0 <digits+0x1a8>
    80001498:	ac4ff0ef          	jal	ra,8000075c <panic>
      kfree(mem);
    8000149c:	854a                	mv	a0,s2
    8000149e:	d5aff0ef          	jal	ra,800009f8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014a2:	4685                	li	a3,1
    800014a4:	00c9d613          	srli	a2,s3,0xc
    800014a8:	4581                	li	a1,0
    800014aa:	8556                	mv	a0,s5
    800014ac:	cd3ff0ef          	jal	ra,8000117e <uvmunmap>
  return -1;
    800014b0:	557d                	li	a0,-1
}
    800014b2:	60a6                	ld	ra,72(sp)
    800014b4:	6406                	ld	s0,64(sp)
    800014b6:	74e2                	ld	s1,56(sp)
    800014b8:	7942                	ld	s2,48(sp)
    800014ba:	79a2                	ld	s3,40(sp)
    800014bc:	7a02                	ld	s4,32(sp)
    800014be:	6ae2                	ld	s5,24(sp)
    800014c0:	6b42                	ld	s6,16(sp)
    800014c2:	6ba2                	ld	s7,8(sp)
    800014c4:	6161                	addi	sp,sp,80
    800014c6:	8082                	ret
  return 0;
    800014c8:	4501                	li	a0,0
}
    800014ca:	8082                	ret

00000000800014cc <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800014cc:	1141                	addi	sp,sp,-16
    800014ce:	e406                	sd	ra,8(sp)
    800014d0:	e022                	sd	s0,0(sp)
    800014d2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800014d4:	4601                	li	a2,0
    800014d6:	a2bff0ef          	jal	ra,80000f00 <walk>
  if(pte == 0)
    800014da:	c901                	beqz	a0,800014ea <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800014dc:	611c                	ld	a5,0(a0)
    800014de:	9bbd                	andi	a5,a5,-17
    800014e0:	e11c                	sd	a5,0(a0)
}
    800014e2:	60a2                	ld	ra,8(sp)
    800014e4:	6402                	ld	s0,0(sp)
    800014e6:	0141                	addi	sp,sp,16
    800014e8:	8082                	ret
    panic("uvmclear");
    800014ea:	00006517          	auipc	a0,0x6
    800014ee:	d1650513          	addi	a0,a0,-746 # 80007200 <digits+0x1c8>
    800014f2:	a6aff0ef          	jal	ra,8000075c <panic>

00000000800014f6 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    800014f6:	c6c9                	beqz	a3,80001580 <copyout+0x8a>
{
    800014f8:	711d                	addi	sp,sp,-96
    800014fa:	ec86                	sd	ra,88(sp)
    800014fc:	e8a2                	sd	s0,80(sp)
    800014fe:	e4a6                	sd	s1,72(sp)
    80001500:	e0ca                	sd	s2,64(sp)
    80001502:	fc4e                	sd	s3,56(sp)
    80001504:	f852                	sd	s4,48(sp)
    80001506:	f456                	sd	s5,40(sp)
    80001508:	f05a                	sd	s6,32(sp)
    8000150a:	ec5e                	sd	s7,24(sp)
    8000150c:	e862                	sd	s8,16(sp)
    8000150e:	e466                	sd	s9,8(sp)
    80001510:	e06a                	sd	s10,0(sp)
    80001512:	1080                	addi	s0,sp,96
    80001514:	8baa                	mv	s7,a0
    80001516:	8aae                	mv	s5,a1
    80001518:	8b32                	mv	s6,a2
    8000151a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000151c:	74fd                	lui	s1,0xfffff
    8000151e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001520:	57fd                	li	a5,-1
    80001522:	83e9                	srli	a5,a5,0x1a
    80001524:	0697e063          	bltu	a5,s1,80001584 <copyout+0x8e>
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001528:	4cd5                	li	s9,21
    8000152a:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    8000152c:	8c3e                	mv	s8,a5
    8000152e:	a025                	j	80001556 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    80001530:	83a9                	srli	a5,a5,0xa
    80001532:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001534:	409a8533          	sub	a0,s5,s1
    80001538:	0009061b          	sext.w	a2,s2
    8000153c:	85da                	mv	a1,s6
    8000153e:	953e                	add	a0,a0,a5
    80001540:	f9cff0ef          	jal	ra,80000cdc <memmove>

    len -= n;
    80001544:	412989b3          	sub	s3,s3,s2
    src += n;
    80001548:	9b4a                	add	s6,s6,s2
  while(len > 0){
    8000154a:	02098963          	beqz	s3,8000157c <copyout+0x86>
    if(va0 >= MAXVA)
    8000154e:	034c6d63          	bltu	s8,s4,80001588 <copyout+0x92>
    va0 = PGROUNDDOWN(dstva);
    80001552:	84d2                	mv	s1,s4
    dstva = va0 + PGSIZE;
    80001554:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    80001556:	4601                	li	a2,0
    80001558:	85a6                	mv	a1,s1
    8000155a:	855e                	mv	a0,s7
    8000155c:	9a5ff0ef          	jal	ra,80000f00 <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001560:	c515                	beqz	a0,8000158c <copyout+0x96>
    80001562:	611c                	ld	a5,0(a0)
    80001564:	0157f713          	andi	a4,a5,21
    80001568:	05971163          	bne	a4,s9,800015aa <copyout+0xb4>
    n = PGSIZE - (dstva - va0);
    8000156c:	01a48a33          	add	s4,s1,s10
    80001570:	415a0933          	sub	s2,s4,s5
    if(n > len)
    80001574:	fb29fee3          	bgeu	s3,s2,80001530 <copyout+0x3a>
    80001578:	894e                	mv	s2,s3
    8000157a:	bf5d                	j	80001530 <copyout+0x3a>
  }
  return 0;
    8000157c:	4501                	li	a0,0
    8000157e:	a801                	j	8000158e <copyout+0x98>
    80001580:	4501                	li	a0,0
}
    80001582:	8082                	ret
      return -1;
    80001584:	557d                	li	a0,-1
    80001586:	a021                	j	8000158e <copyout+0x98>
    80001588:	557d                	li	a0,-1
    8000158a:	a011                	j	8000158e <copyout+0x98>
      return -1;
    8000158c:	557d                	li	a0,-1
}
    8000158e:	60e6                	ld	ra,88(sp)
    80001590:	6446                	ld	s0,80(sp)
    80001592:	64a6                	ld	s1,72(sp)
    80001594:	6906                	ld	s2,64(sp)
    80001596:	79e2                	ld	s3,56(sp)
    80001598:	7a42                	ld	s4,48(sp)
    8000159a:	7aa2                	ld	s5,40(sp)
    8000159c:	7b02                	ld	s6,32(sp)
    8000159e:	6be2                	ld	s7,24(sp)
    800015a0:	6c42                	ld	s8,16(sp)
    800015a2:	6ca2                	ld	s9,8(sp)
    800015a4:	6d02                	ld	s10,0(sp)
    800015a6:	6125                	addi	sp,sp,96
    800015a8:	8082                	ret
      return -1;
    800015aa:	557d                	li	a0,-1
    800015ac:	b7cd                	j	8000158e <copyout+0x98>

00000000800015ae <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800015ae:	c2bd                	beqz	a3,80001614 <copyin+0x66>
{
    800015b0:	715d                	addi	sp,sp,-80
    800015b2:	e486                	sd	ra,72(sp)
    800015b4:	e0a2                	sd	s0,64(sp)
    800015b6:	fc26                	sd	s1,56(sp)
    800015b8:	f84a                	sd	s2,48(sp)
    800015ba:	f44e                	sd	s3,40(sp)
    800015bc:	f052                	sd	s4,32(sp)
    800015be:	ec56                	sd	s5,24(sp)
    800015c0:	e85a                	sd	s6,16(sp)
    800015c2:	e45e                	sd	s7,8(sp)
    800015c4:	e062                	sd	s8,0(sp)
    800015c6:	0880                	addi	s0,sp,80
    800015c8:	8b2a                	mv	s6,a0
    800015ca:	8a2e                	mv	s4,a1
    800015cc:	8c32                	mv	s8,a2
    800015ce:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800015d0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800015d2:	6a85                	lui	s5,0x1
    800015d4:	a005                	j	800015f4 <copyin+0x46>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015d6:	9562                	add	a0,a0,s8
    800015d8:	0004861b          	sext.w	a2,s1
    800015dc:	412505b3          	sub	a1,a0,s2
    800015e0:	8552                	mv	a0,s4
    800015e2:	efaff0ef          	jal	ra,80000cdc <memmove>

    len -= n;
    800015e6:	409989b3          	sub	s3,s3,s1
    dst += n;
    800015ea:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800015ec:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800015f0:	02098063          	beqz	s3,80001610 <copyin+0x62>
    va0 = PGROUNDDOWN(srcva);
    800015f4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800015f8:	85ca                	mv	a1,s2
    800015fa:	855a                	mv	a0,s6
    800015fc:	99fff0ef          	jal	ra,80000f9a <walkaddr>
    if(pa0 == 0)
    80001600:	cd01                	beqz	a0,80001618 <copyin+0x6a>
    n = PGSIZE - (srcva - va0);
    80001602:	418904b3          	sub	s1,s2,s8
    80001606:	94d6                	add	s1,s1,s5
    if(n > len)
    80001608:	fc99f7e3          	bgeu	s3,s1,800015d6 <copyin+0x28>
    8000160c:	84ce                	mv	s1,s3
    8000160e:	b7e1                	j	800015d6 <copyin+0x28>
  }
  return 0;
    80001610:	4501                	li	a0,0
    80001612:	a021                	j	8000161a <copyin+0x6c>
    80001614:	4501                	li	a0,0
}
    80001616:	8082                	ret
      return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6c02                	ld	s8,0(sp)
    8000162e:	6161                	addi	sp,sp,80
    80001630:	8082                	ret

0000000080001632 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001632:	c2d5                	beqz	a3,800016d6 <copyinstr+0xa4>
{
    80001634:	715d                	addi	sp,sp,-80
    80001636:	e486                	sd	ra,72(sp)
    80001638:	e0a2                	sd	s0,64(sp)
    8000163a:	fc26                	sd	s1,56(sp)
    8000163c:	f84a                	sd	s2,48(sp)
    8000163e:	f44e                	sd	s3,40(sp)
    80001640:	f052                	sd	s4,32(sp)
    80001642:	ec56                	sd	s5,24(sp)
    80001644:	e85a                	sd	s6,16(sp)
    80001646:	e45e                	sd	s7,8(sp)
    80001648:	0880                	addi	s0,sp,80
    8000164a:	8a2a                	mv	s4,a0
    8000164c:	8b2e                	mv	s6,a1
    8000164e:	8bb2                	mv	s7,a2
    80001650:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001652:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001654:	6985                	lui	s3,0x1
    80001656:	a035                	j	80001682 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001658:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000165c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000165e:	0017b793          	seqz	a5,a5
    80001662:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001666:	60a6                	ld	ra,72(sp)
    80001668:	6406                	ld	s0,64(sp)
    8000166a:	74e2                	ld	s1,56(sp)
    8000166c:	7942                	ld	s2,48(sp)
    8000166e:	79a2                	ld	s3,40(sp)
    80001670:	7a02                	ld	s4,32(sp)
    80001672:	6ae2                	ld	s5,24(sp)
    80001674:	6b42                	ld	s6,16(sp)
    80001676:	6ba2                	ld	s7,8(sp)
    80001678:	6161                	addi	sp,sp,80
    8000167a:	8082                	ret
    srcva = va0 + PGSIZE;
    8000167c:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001680:	c4b9                	beqz	s1,800016ce <copyinstr+0x9c>
    va0 = PGROUNDDOWN(srcva);
    80001682:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001686:	85ca                	mv	a1,s2
    80001688:	8552                	mv	a0,s4
    8000168a:	911ff0ef          	jal	ra,80000f9a <walkaddr>
    if(pa0 == 0)
    8000168e:	c131                	beqz	a0,800016d2 <copyinstr+0xa0>
    n = PGSIZE - (srcva - va0);
    80001690:	41790833          	sub	a6,s2,s7
    80001694:	984e                	add	a6,a6,s3
    if(n > max)
    80001696:	0104f363          	bgeu	s1,a6,8000169c <copyinstr+0x6a>
    8000169a:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000169c:	955e                	add	a0,a0,s7
    8000169e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800016a2:	fc080de3          	beqz	a6,8000167c <copyinstr+0x4a>
    800016a6:	985a                	add	a6,a6,s6
    800016a8:	87da                	mv	a5,s6
      if(*p == '\0'){
    800016aa:	41650633          	sub	a2,a0,s6
    800016ae:	14fd                	addi	s1,s1,-1
    800016b0:	9b26                	add	s6,s6,s1
    800016b2:	00f60733          	add	a4,a2,a5
    800016b6:	00074703          	lbu	a4,0(a4)
    800016ba:	df59                	beqz	a4,80001658 <copyinstr+0x26>
        *dst = *p;
    800016bc:	00e78023          	sb	a4,0(a5)
      --max;
    800016c0:	40fb04b3          	sub	s1,s6,a5
      dst++;
    800016c4:	0785                	addi	a5,a5,1
    while(n > 0){
    800016c6:	ff0796e3          	bne	a5,a6,800016b2 <copyinstr+0x80>
      dst++;
    800016ca:	8b42                	mv	s6,a6
    800016cc:	bf45                	j	8000167c <copyinstr+0x4a>
    800016ce:	4781                	li	a5,0
    800016d0:	b779                	j	8000165e <copyinstr+0x2c>
      return -1;
    800016d2:	557d                	li	a0,-1
    800016d4:	bf49                	j	80001666 <copyinstr+0x34>
  int got_null = 0;
    800016d6:	4781                	li	a5,0
  if(got_null){
    800016d8:	0017b793          	seqz	a5,a5
    800016dc:	40f00533          	neg	a0,a5
}
    800016e0:	8082                	ret

00000000800016e2 <vmprint>:

void vmprint(pagetable_t pagetable) {
    800016e2:	7159                	addi	sp,sp,-112
    800016e4:	f486                	sd	ra,104(sp)
    800016e6:	f0a2                	sd	s0,96(sp)
    800016e8:	eca6                	sd	s1,88(sp)
    800016ea:	e8ca                	sd	s2,80(sp)
    800016ec:	e4ce                	sd	s3,72(sp)
    800016ee:	e0d2                	sd	s4,64(sp)
    800016f0:	fc56                	sd	s5,56(sp)
    800016f2:	f85a                	sd	s6,48(sp)
    800016f4:	f45e                	sd	s7,40(sp)
    800016f6:	f062                	sd	s8,32(sp)
    800016f8:	ec66                	sd	s9,24(sp)
    800016fa:	e86a                	sd	s10,16(sp)
    800016fc:	e46e                	sd	s11,8(sp)
    800016fe:	1880                	addi	s0,sp,112
    80001700:	8baa                	mv	s7,a0
  printf("page table %p\n", (void*)pagetable);
    80001702:	85aa                	mv	a1,a0
    80001704:	00006517          	auipc	a0,0x6
    80001708:	b0c50513          	addi	a0,a0,-1268 # 80007210 <digits+0x1d8>
    8000170c:	d9dfe0ef          	jal	ra,800004a8 <printf>

  const int PAGE_SIZE = 512;  // 每级页表的大小
  // 遍历顶级页目录
  for (int i = 0; i < PAGE_SIZE; ++i) {
    80001710:	4c01                	li	s8,0
    pte_t top_pte = pagetable[i];
    if (top_pte & PTE_V) {  // 检查有效位
      printf("..%d: pte %lx pa %lx\n", i, top_pte, PTE2PA(top_pte));
    80001712:	00006d97          	auipc	s11,0x6
    80001716:	b0ed8d93          	addi	s11,s11,-1266 # 80007220 <digits+0x1e8>
      pagetable_t mid_table = (pagetable_t)PTE2PA(top_pte);
      // 遍历中间级页目录
      for (int j = 0; j < PAGE_SIZE; ++j) {
        pte_t mid_pte = mid_table[j];
        if (mid_pte & PTE_V) {  // 检查有效位
          printf(".. ..%d: pte %lx pa %lx\n", j, mid_pte, PTE2PA(mid_pte));
    8000171a:	00006d17          	auipc	s10,0x6
    8000171e:	b1ed0d13          	addi	s10,s10,-1250 # 80007238 <digits+0x200>

          pagetable_t bot_table = (pagetable_t)PTE2PA(mid_pte);
          // 遍历最低级页目录
          for (int k = 0; k < PAGE_SIZE; ++k) {
    80001722:	20000993          	li	s3,512
    80001726:	4c81                	li	s9,0
            pte_t bot_pte = bot_table[k];
            if (bot_pte & PTE_V) {  // 检查有效位
              printf(".. .. ..%d: pte %lx pa %lx\n", k, bot_pte, PTE2PA(bot_pte));
    80001728:	00006a17          	auipc	s4,0x6
    8000172c:	b30a0a13          	addi	s4,s4,-1232 # 80007258 <digits+0x220>
    80001730:	a889                	j	80001782 <vmprint+0xa0>
    80001732:	00a65693          	srli	a3,a2,0xa
    80001736:	06b2                	slli	a3,a3,0xc
    80001738:	85a6                	mv	a1,s1
    8000173a:	8552                	mv	a0,s4
    8000173c:	d6dfe0ef          	jal	ra,800004a8 <printf>
          for (int k = 0; k < PAGE_SIZE; ++k) {
    80001740:	2485                	addiw	s1,s1,1
    80001742:	0921                	addi	s2,s2,8
    80001744:	01348863          	beq	s1,s3,80001754 <vmprint+0x72>
            pte_t bot_pte = bot_table[k];
    80001748:	00093603          	ld	a2,0(s2) # 1000 <_entry-0x7ffff000>
            if (bot_pte & PTE_V) {  // 检查有效位
    8000174c:	00167793          	andi	a5,a2,1
    80001750:	dbe5                	beqz	a5,80001740 <vmprint+0x5e>
    80001752:	b7c5                	j	80001732 <vmprint+0x50>
      for (int j = 0; j < PAGE_SIZE; ++j) {
    80001754:	2a85                	addiw	s5,s5,1
    80001756:	0b21                	addi	s6,s6,8
    80001758:	033a8163          	beq	s5,s3,8000177a <vmprint+0x98>
        pte_t mid_pte = mid_table[j];
    8000175c:	000b3603          	ld	a2,0(s6) # 1000 <_entry-0x7ffff000>
        if (mid_pte & PTE_V) {  // 检查有效位
    80001760:	00167793          	andi	a5,a2,1
    80001764:	dbe5                	beqz	a5,80001754 <vmprint+0x72>
          printf(".. ..%d: pte %lx pa %lx\n", j, mid_pte, PTE2PA(mid_pte));
    80001766:	00a65913          	srli	s2,a2,0xa
    8000176a:	0932                	slli	s2,s2,0xc
    8000176c:	86ca                	mv	a3,s2
    8000176e:	85d6                	mv	a1,s5
    80001770:	856a                	mv	a0,s10
    80001772:	d37fe0ef          	jal	ra,800004a8 <printf>
          for (int k = 0; k < PAGE_SIZE; ++k) {
    80001776:	84e6                	mv	s1,s9
    80001778:	bfc1                	j	80001748 <vmprint+0x66>
  for (int i = 0; i < PAGE_SIZE; ++i) {
    8000177a:	2c05                	addiw	s8,s8,1
    8000177c:	0ba1                	addi	s7,s7,8
    8000177e:	033c0163          	beq	s8,s3,800017a0 <vmprint+0xbe>
    pte_t top_pte = pagetable[i];
    80001782:	000bb603          	ld	a2,0(s7) # fffffffffffff000 <end+0xffffffff7ffde320>
    if (top_pte & PTE_V) {  // 检查有效位
    80001786:	00167793          	andi	a5,a2,1
    8000178a:	dbe5                	beqz	a5,8000177a <vmprint+0x98>
      printf("..%d: pte %lx pa %lx\n", i, top_pte, PTE2PA(top_pte));
    8000178c:	00a65b13          	srli	s6,a2,0xa
    80001790:	0b32                	slli	s6,s6,0xc
    80001792:	86da                	mv	a3,s6
    80001794:	85e2                	mv	a1,s8
    80001796:	856e                	mv	a0,s11
    80001798:	d11fe0ef          	jal	ra,800004a8 <printf>
      for (int j = 0; j < PAGE_SIZE; ++j) {
    8000179c:	4a81                	li	s5,0
    8000179e:	bf7d                	j	8000175c <vmprint+0x7a>
          }
        }
      }
    }
  }
}
    800017a0:	70a6                	ld	ra,104(sp)
    800017a2:	7406                	ld	s0,96(sp)
    800017a4:	64e6                	ld	s1,88(sp)
    800017a6:	6946                	ld	s2,80(sp)
    800017a8:	69a6                	ld	s3,72(sp)
    800017aa:	6a06                	ld	s4,64(sp)
    800017ac:	7ae2                	ld	s5,56(sp)
    800017ae:	7b42                	ld	s6,48(sp)
    800017b0:	7ba2                	ld	s7,40(sp)
    800017b2:	7c02                	ld	s8,32(sp)
    800017b4:	6ce2                	ld	s9,24(sp)
    800017b6:	6d42                	ld	s10,16(sp)
    800017b8:	6da2                	ld	s11,8(sp)
    800017ba:	6165                	addi	sp,sp,112
    800017bc:	8082                	ret

00000000800017be <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    800017be:	7139                	addi	sp,sp,-64
    800017c0:	fc06                	sd	ra,56(sp)
    800017c2:	f822                	sd	s0,48(sp)
    800017c4:	f426                	sd	s1,40(sp)
    800017c6:	f04a                	sd	s2,32(sp)
    800017c8:	ec4e                	sd	s3,24(sp)
    800017ca:	e852                	sd	s4,16(sp)
    800017cc:	e456                	sd	s5,8(sp)
    800017ce:	e05a                	sd	s6,0(sp)
    800017d0:	0080                	addi	s0,sp,64
    800017d2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d4:	0000e497          	auipc	s1,0xe
    800017d8:	72c48493          	addi	s1,s1,1836 # 8000ff00 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    800017dc:	8b26                	mv	s6,s1
    800017de:	00006a97          	auipc	s5,0x6
    800017e2:	822a8a93          	addi	s5,s5,-2014 # 80007000 <etext>
    800017e6:	04000937          	lui	s2,0x4000
    800017ea:	197d                	addi	s2,s2,-1
    800017ec:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017ee:	00014a17          	auipc	s4,0x14
    800017f2:	112a0a13          	addi	s4,s4,274 # 80015900 <tickslock>
    char *pa = kalloc();
    800017f6:	ae2ff0ef          	jal	ra,80000ad8 <kalloc>
    800017fa:	862a                	mv	a2,a0
    if(pa == 0)
    800017fc:	c121                	beqz	a0,8000183c <proc_mapstacks+0x7e>
    uint64 va = KSTACK((int) (p - proc));
    800017fe:	416485b3          	sub	a1,s1,s6
    80001802:	858d                	srai	a1,a1,0x3
    80001804:	000ab783          	ld	a5,0(s5)
    80001808:	02f585b3          	mul	a1,a1,a5
    8000180c:	2585                	addiw	a1,a1,1
    8000180e:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001812:	4719                	li	a4,6
    80001814:	6685                	lui	a3,0x1
    80001816:	40b905b3          	sub	a1,s2,a1
    8000181a:	854e                	mv	a0,s3
    8000181c:	86dff0ef          	jal	ra,80001088 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001820:	16848493          	addi	s1,s1,360
    80001824:	fd4499e3          	bne	s1,s4,800017f6 <proc_mapstacks+0x38>
  }
}
    80001828:	70e2                	ld	ra,56(sp)
    8000182a:	7442                	ld	s0,48(sp)
    8000182c:	74a2                	ld	s1,40(sp)
    8000182e:	7902                	ld	s2,32(sp)
    80001830:	69e2                	ld	s3,24(sp)
    80001832:	6a42                	ld	s4,16(sp)
    80001834:	6aa2                	ld	s5,8(sp)
    80001836:	6b02                	ld	s6,0(sp)
    80001838:	6121                	addi	sp,sp,64
    8000183a:	8082                	ret
      panic("kalloc");
    8000183c:	00006517          	auipc	a0,0x6
    80001840:	a3c50513          	addi	a0,a0,-1476 # 80007278 <digits+0x240>
    80001844:	f19fe0ef          	jal	ra,8000075c <panic>

0000000080001848 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001848:	7139                	addi	sp,sp,-64
    8000184a:	fc06                	sd	ra,56(sp)
    8000184c:	f822                	sd	s0,48(sp)
    8000184e:	f426                	sd	s1,40(sp)
    80001850:	f04a                	sd	s2,32(sp)
    80001852:	ec4e                	sd	s3,24(sp)
    80001854:	e852                	sd	s4,16(sp)
    80001856:	e456                	sd	s5,8(sp)
    80001858:	e05a                	sd	s6,0(sp)
    8000185a:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000185c:	00006597          	auipc	a1,0x6
    80001860:	a2458593          	addi	a1,a1,-1500 # 80007280 <digits+0x248>
    80001864:	0000e517          	auipc	a0,0xe
    80001868:	26c50513          	addi	a0,a0,620 # 8000fad0 <pid_lock>
    8000186c:	abcff0ef          	jal	ra,80000b28 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001870:	00006597          	auipc	a1,0x6
    80001874:	a1858593          	addi	a1,a1,-1512 # 80007288 <digits+0x250>
    80001878:	0000e517          	auipc	a0,0xe
    8000187c:	27050513          	addi	a0,a0,624 # 8000fae8 <wait_lock>
    80001880:	aa8ff0ef          	jal	ra,80000b28 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001884:	0000e497          	auipc	s1,0xe
    80001888:	67c48493          	addi	s1,s1,1660 # 8000ff00 <proc>
      initlock(&p->lock, "proc");
    8000188c:	00006b17          	auipc	s6,0x6
    80001890:	a0cb0b13          	addi	s6,s6,-1524 # 80007298 <digits+0x260>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001894:	8aa6                	mv	s5,s1
    80001896:	00005a17          	auipc	s4,0x5
    8000189a:	76aa0a13          	addi	s4,s4,1898 # 80007000 <etext>
    8000189e:	04000937          	lui	s2,0x4000
    800018a2:	197d                	addi	s2,s2,-1
    800018a4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a6:	00014997          	auipc	s3,0x14
    800018aa:	05a98993          	addi	s3,s3,90 # 80015900 <tickslock>
      initlock(&p->lock, "proc");
    800018ae:	85da                	mv	a1,s6
    800018b0:	8526                	mv	a0,s1
    800018b2:	a76ff0ef          	jal	ra,80000b28 <initlock>
      p->state = UNUSED;
    800018b6:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800018ba:	415487b3          	sub	a5,s1,s5
    800018be:	878d                	srai	a5,a5,0x3
    800018c0:	000a3703          	ld	a4,0(s4)
    800018c4:	02e787b3          	mul	a5,a5,a4
    800018c8:	2785                	addiw	a5,a5,1
    800018ca:	00d7979b          	slliw	a5,a5,0xd
    800018ce:	40f907b3          	sub	a5,s2,a5
    800018d2:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d4:	16848493          	addi	s1,s1,360
    800018d8:	fd349be3          	bne	s1,s3,800018ae <procinit+0x66>
  }
}
    800018dc:	70e2                	ld	ra,56(sp)
    800018de:	7442                	ld	s0,48(sp)
    800018e0:	74a2                	ld	s1,40(sp)
    800018e2:	7902                	ld	s2,32(sp)
    800018e4:	69e2                	ld	s3,24(sp)
    800018e6:	6a42                	ld	s4,16(sp)
    800018e8:	6aa2                	ld	s5,8(sp)
    800018ea:	6b02                	ld	s6,0(sp)
    800018ec:	6121                	addi	sp,sp,64
    800018ee:	8082                	ret

00000000800018f0 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018f0:	1141                	addi	sp,sp,-16
    800018f2:	e422                	sd	s0,8(sp)
    800018f4:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018f6:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018f8:	2501                	sext.w	a0,a0
    800018fa:	6422                	ld	s0,8(sp)
    800018fc:	0141                	addi	sp,sp,16
    800018fe:	8082                	ret

0000000080001900 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001900:	1141                	addi	sp,sp,-16
    80001902:	e422                	sd	s0,8(sp)
    80001904:	0800                	addi	s0,sp,16
    80001906:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001908:	2781                	sext.w	a5,a5
    8000190a:	079e                	slli	a5,a5,0x7
  return c;
}
    8000190c:	0000e517          	auipc	a0,0xe
    80001910:	1f450513          	addi	a0,a0,500 # 8000fb00 <cpus>
    80001914:	953e                	add	a0,a0,a5
    80001916:	6422                	ld	s0,8(sp)
    80001918:	0141                	addi	sp,sp,16
    8000191a:	8082                	ret

000000008000191c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000191c:	1101                	addi	sp,sp,-32
    8000191e:	ec06                	sd	ra,24(sp)
    80001920:	e822                	sd	s0,16(sp)
    80001922:	e426                	sd	s1,8(sp)
    80001924:	1000                	addi	s0,sp,32
  push_off();
    80001926:	a42ff0ef          	jal	ra,80000b68 <push_off>
    8000192a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000192c:	2781                	sext.w	a5,a5
    8000192e:	079e                	slli	a5,a5,0x7
    80001930:	0000e717          	auipc	a4,0xe
    80001934:	1a070713          	addi	a4,a4,416 # 8000fad0 <pid_lock>
    80001938:	97ba                	add	a5,a5,a4
    8000193a:	7b84                	ld	s1,48(a5)
  pop_off();
    8000193c:	ab0ff0ef          	jal	ra,80000bec <pop_off>
  return p;
}
    80001940:	8526                	mv	a0,s1
    80001942:	60e2                	ld	ra,24(sp)
    80001944:	6442                	ld	s0,16(sp)
    80001946:	64a2                	ld	s1,8(sp)
    80001948:	6105                	addi	sp,sp,32
    8000194a:	8082                	ret

000000008000194c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    8000194c:	1141                	addi	sp,sp,-16
    8000194e:	e406                	sd	ra,8(sp)
    80001950:	e022                	sd	s0,0(sp)
    80001952:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001954:	fc9ff0ef          	jal	ra,8000191c <myproc>
    80001958:	ae8ff0ef          	jal	ra,80000c40 <release>

  if (first) {
    8000195c:	00006797          	auipc	a5,0x6
    80001960:	fa47a783          	lw	a5,-92(a5) # 80007900 <first.2197>
    80001964:	e799                	bnez	a5,80001972 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    80001966:	2b7000ef          	jal	ra,8000241c <usertrapret>
}
    8000196a:	60a2                	ld	ra,8(sp)
    8000196c:	6402                	ld	s0,0(sp)
    8000196e:	0141                	addi	sp,sp,16
    80001970:	8082                	ret
    fsinit(ROOTDEV);
    80001972:	4505                	li	a0,1
    80001974:	712010ef          	jal	ra,80003086 <fsinit>
    first = 0;
    80001978:	00006797          	auipc	a5,0x6
    8000197c:	f807a423          	sw	zero,-120(a5) # 80007900 <first.2197>
    __sync_synchronize();
    80001980:	0ff0000f          	fence
    80001984:	b7cd                	j	80001966 <forkret+0x1a>

0000000080001986 <allocpid>:
{
    80001986:	1101                	addi	sp,sp,-32
    80001988:	ec06                	sd	ra,24(sp)
    8000198a:	e822                	sd	s0,16(sp)
    8000198c:	e426                	sd	s1,8(sp)
    8000198e:	e04a                	sd	s2,0(sp)
    80001990:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001992:	0000e917          	auipc	s2,0xe
    80001996:	13e90913          	addi	s2,s2,318 # 8000fad0 <pid_lock>
    8000199a:	854a                	mv	a0,s2
    8000199c:	a0cff0ef          	jal	ra,80000ba8 <acquire>
  pid = nextpid;
    800019a0:	00006797          	auipc	a5,0x6
    800019a4:	f6478793          	addi	a5,a5,-156 # 80007904 <nextpid>
    800019a8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800019aa:	0014871b          	addiw	a4,s1,1
    800019ae:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019b0:	854a                	mv	a0,s2
    800019b2:	a8eff0ef          	jal	ra,80000c40 <release>
}
    800019b6:	8526                	mv	a0,s1
    800019b8:	60e2                	ld	ra,24(sp)
    800019ba:	6442                	ld	s0,16(sp)
    800019bc:	64a2                	ld	s1,8(sp)
    800019be:	6902                	ld	s2,0(sp)
    800019c0:	6105                	addi	sp,sp,32
    800019c2:	8082                	ret

00000000800019c4 <proc_pagetable>:
{
    800019c4:	1101                	addi	sp,sp,-32
    800019c6:	ec06                	sd	ra,24(sp)
    800019c8:	e822                	sd	s0,16(sp)
    800019ca:	e426                	sd	s1,8(sp)
    800019cc:	e04a                	sd	s2,0(sp)
    800019ce:	1000                	addi	s0,sp,32
    800019d0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019d2:	859ff0ef          	jal	ra,8000122a <uvmcreate>
    800019d6:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800019d8:	cd05                	beqz	a0,80001a10 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800019da:	4729                	li	a4,10
    800019dc:	00004697          	auipc	a3,0x4
    800019e0:	62468693          	addi	a3,a3,1572 # 80006000 <_trampoline>
    800019e4:	6605                	lui	a2,0x1
    800019e6:	040005b7          	lui	a1,0x4000
    800019ea:	15fd                	addi	a1,a1,-1
    800019ec:	05b2                	slli	a1,a1,0xc
    800019ee:	deaff0ef          	jal	ra,80000fd8 <mappages>
    800019f2:	02054663          	bltz	a0,80001a1e <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019f6:	4719                	li	a4,6
    800019f8:	05893683          	ld	a3,88(s2)
    800019fc:	6605                	lui	a2,0x1
    800019fe:	020005b7          	lui	a1,0x2000
    80001a02:	15fd                	addi	a1,a1,-1
    80001a04:	05b6                	slli	a1,a1,0xd
    80001a06:	8526                	mv	a0,s1
    80001a08:	dd0ff0ef          	jal	ra,80000fd8 <mappages>
    80001a0c:	00054f63          	bltz	a0,80001a2a <proc_pagetable+0x66>
}
    80001a10:	8526                	mv	a0,s1
    80001a12:	60e2                	ld	ra,24(sp)
    80001a14:	6442                	ld	s0,16(sp)
    80001a16:	64a2                	ld	s1,8(sp)
    80001a18:	6902                	ld	s2,0(sp)
    80001a1a:	6105                	addi	sp,sp,32
    80001a1c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a1e:	4581                	li	a1,0
    80001a20:	8526                	mv	a0,s1
    80001a22:	9c9ff0ef          	jal	ra,800013ea <uvmfree>
    return 0;
    80001a26:	4481                	li	s1,0
    80001a28:	b7e5                	j	80001a10 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a2a:	4681                	li	a3,0
    80001a2c:	4605                	li	a2,1
    80001a2e:	040005b7          	lui	a1,0x4000
    80001a32:	15fd                	addi	a1,a1,-1
    80001a34:	05b2                	slli	a1,a1,0xc
    80001a36:	8526                	mv	a0,s1
    80001a38:	f46ff0ef          	jal	ra,8000117e <uvmunmap>
    uvmfree(pagetable, 0);
    80001a3c:	4581                	li	a1,0
    80001a3e:	8526                	mv	a0,s1
    80001a40:	9abff0ef          	jal	ra,800013ea <uvmfree>
    return 0;
    80001a44:	4481                	li	s1,0
    80001a46:	b7e9                	j	80001a10 <proc_pagetable+0x4c>

0000000080001a48 <proc_freepagetable>:
{
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	e04a                	sd	s2,0(sp)
    80001a52:	1000                	addi	s0,sp,32
    80001a54:	84aa                	mv	s1,a0
    80001a56:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a58:	4681                	li	a3,0
    80001a5a:	4605                	li	a2,1
    80001a5c:	040005b7          	lui	a1,0x4000
    80001a60:	15fd                	addi	a1,a1,-1
    80001a62:	05b2                	slli	a1,a1,0xc
    80001a64:	f1aff0ef          	jal	ra,8000117e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a68:	4681                	li	a3,0
    80001a6a:	4605                	li	a2,1
    80001a6c:	020005b7          	lui	a1,0x2000
    80001a70:	15fd                	addi	a1,a1,-1
    80001a72:	05b6                	slli	a1,a1,0xd
    80001a74:	8526                	mv	a0,s1
    80001a76:	f08ff0ef          	jal	ra,8000117e <uvmunmap>
  uvmfree(pagetable, sz);
    80001a7a:	85ca                	mv	a1,s2
    80001a7c:	8526                	mv	a0,s1
    80001a7e:	96dff0ef          	jal	ra,800013ea <uvmfree>
}
    80001a82:	60e2                	ld	ra,24(sp)
    80001a84:	6442                	ld	s0,16(sp)
    80001a86:	64a2                	ld	s1,8(sp)
    80001a88:	6902                	ld	s2,0(sp)
    80001a8a:	6105                	addi	sp,sp,32
    80001a8c:	8082                	ret

0000000080001a8e <freeproc>:
{
    80001a8e:	1101                	addi	sp,sp,-32
    80001a90:	ec06                	sd	ra,24(sp)
    80001a92:	e822                	sd	s0,16(sp)
    80001a94:	e426                	sd	s1,8(sp)
    80001a96:	1000                	addi	s0,sp,32
    80001a98:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a9a:	6d28                	ld	a0,88(a0)
    80001a9c:	c119                	beqz	a0,80001aa2 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a9e:	f5bfe0ef          	jal	ra,800009f8 <kfree>
  p->trapframe = 0;
    80001aa2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001aa6:	68a8                	ld	a0,80(s1)
    80001aa8:	c501                	beqz	a0,80001ab0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001aaa:	64ac                	ld	a1,72(s1)
    80001aac:	f9dff0ef          	jal	ra,80001a48 <proc_freepagetable>
  p->pagetable = 0;
    80001ab0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001ab4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001ab8:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001abc:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ac0:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ac4:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ac8:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001acc:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ad0:	0004ac23          	sw	zero,24(s1)
}
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6105                	addi	sp,sp,32
    80001adc:	8082                	ret

0000000080001ade <allocproc>:
{
    80001ade:	1101                	addi	sp,sp,-32
    80001ae0:	ec06                	sd	ra,24(sp)
    80001ae2:	e822                	sd	s0,16(sp)
    80001ae4:	e426                	sd	s1,8(sp)
    80001ae6:	e04a                	sd	s2,0(sp)
    80001ae8:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aea:	0000e497          	auipc	s1,0xe
    80001aee:	41648493          	addi	s1,s1,1046 # 8000ff00 <proc>
    80001af2:	00014917          	auipc	s2,0x14
    80001af6:	e0e90913          	addi	s2,s2,-498 # 80015900 <tickslock>
    acquire(&p->lock);
    80001afa:	8526                	mv	a0,s1
    80001afc:	8acff0ef          	jal	ra,80000ba8 <acquire>
    if(p->state == UNUSED) {
    80001b00:	4c9c                	lw	a5,24(s1)
    80001b02:	cb91                	beqz	a5,80001b16 <allocproc+0x38>
      release(&p->lock);
    80001b04:	8526                	mv	a0,s1
    80001b06:	93aff0ef          	jal	ra,80000c40 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b0a:	16848493          	addi	s1,s1,360
    80001b0e:	ff2496e3          	bne	s1,s2,80001afa <allocproc+0x1c>
  return 0;
    80001b12:	4481                	li	s1,0
    80001b14:	a089                	j	80001b56 <allocproc+0x78>
  p->pid = allocpid();
    80001b16:	e71ff0ef          	jal	ra,80001986 <allocpid>
    80001b1a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b1c:	4785                	li	a5,1
    80001b1e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001b20:	fb9fe0ef          	jal	ra,80000ad8 <kalloc>
    80001b24:	892a                	mv	s2,a0
    80001b26:	eca8                	sd	a0,88(s1)
    80001b28:	cd15                	beqz	a0,80001b64 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	e99ff0ef          	jal	ra,800019c4 <proc_pagetable>
    80001b30:	892a                	mv	s2,a0
    80001b32:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b34:	c121                	beqz	a0,80001b74 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b36:	07000613          	li	a2,112
    80001b3a:	4581                	li	a1,0
    80001b3c:	06048513          	addi	a0,s1,96
    80001b40:	93cff0ef          	jal	ra,80000c7c <memset>
  p->context.ra = (uint64)forkret;
    80001b44:	00000797          	auipc	a5,0x0
    80001b48:	e0878793          	addi	a5,a5,-504 # 8000194c <forkret>
    80001b4c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b4e:	60bc                	ld	a5,64(s1)
    80001b50:	6705                	lui	a4,0x1
    80001b52:	97ba                	add	a5,a5,a4
    80001b54:	f4bc                	sd	a5,104(s1)
}
    80001b56:	8526                	mv	a0,s1
    80001b58:	60e2                	ld	ra,24(sp)
    80001b5a:	6442                	ld	s0,16(sp)
    80001b5c:	64a2                	ld	s1,8(sp)
    80001b5e:	6902                	ld	s2,0(sp)
    80001b60:	6105                	addi	sp,sp,32
    80001b62:	8082                	ret
    freeproc(p);
    80001b64:	8526                	mv	a0,s1
    80001b66:	f29ff0ef          	jal	ra,80001a8e <freeproc>
    release(&p->lock);
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	8d4ff0ef          	jal	ra,80000c40 <release>
    return 0;
    80001b70:	84ca                	mv	s1,s2
    80001b72:	b7d5                	j	80001b56 <allocproc+0x78>
    freeproc(p);
    80001b74:	8526                	mv	a0,s1
    80001b76:	f19ff0ef          	jal	ra,80001a8e <freeproc>
    release(&p->lock);
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	8c4ff0ef          	jal	ra,80000c40 <release>
    return 0;
    80001b80:	84ca                	mv	s1,s2
    80001b82:	bfd1                	j	80001b56 <allocproc+0x78>

0000000080001b84 <userinit>:
{
    80001b84:	1101                	addi	sp,sp,-32
    80001b86:	ec06                	sd	ra,24(sp)
    80001b88:	e822                	sd	s0,16(sp)
    80001b8a:	e426                	sd	s1,8(sp)
    80001b8c:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b8e:	f51ff0ef          	jal	ra,80001ade <allocproc>
    80001b92:	84aa                	mv	s1,a0
  initproc = p;
    80001b94:	00006797          	auipc	a5,0x6
    80001b98:	e0a7b223          	sd	a0,-508(a5) # 80007998 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b9c:	03400613          	li	a2,52
    80001ba0:	00006597          	auipc	a1,0x6
    80001ba4:	d7058593          	addi	a1,a1,-656 # 80007910 <initcode>
    80001ba8:	6928                	ld	a0,80(a0)
    80001baa:	ea6ff0ef          	jal	ra,80001250 <uvmfirst>
  p->sz = PGSIZE;
    80001bae:	6785                	lui	a5,0x1
    80001bb0:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001bb2:	6cb8                	ld	a4,88(s1)
    80001bb4:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001bb8:	6cb8                	ld	a4,88(s1)
    80001bba:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001bbc:	4641                	li	a2,16
    80001bbe:	00005597          	auipc	a1,0x5
    80001bc2:	6e258593          	addi	a1,a1,1762 # 800072a0 <digits+0x268>
    80001bc6:	15848513          	addi	a0,s1,344
    80001bca:	a00ff0ef          	jal	ra,80000dca <safestrcpy>
  p->cwd = namei("/");
    80001bce:	00005517          	auipc	a0,0x5
    80001bd2:	6e250513          	addi	a0,a0,1762 # 800072b0 <digits+0x278>
    80001bd6:	58f010ef          	jal	ra,80003964 <namei>
    80001bda:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bde:	478d                	li	a5,3
    80001be0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001be2:	8526                	mv	a0,s1
    80001be4:	85cff0ef          	jal	ra,80000c40 <release>
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6105                	addi	sp,sp,32
    80001bf0:	8082                	ret

0000000080001bf2 <growproc>:
{
    80001bf2:	1101                	addi	sp,sp,-32
    80001bf4:	ec06                	sd	ra,24(sp)
    80001bf6:	e822                	sd	s0,16(sp)
    80001bf8:	e426                	sd	s1,8(sp)
    80001bfa:	e04a                	sd	s2,0(sp)
    80001bfc:	1000                	addi	s0,sp,32
    80001bfe:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001c00:	d1dff0ef          	jal	ra,8000191c <myproc>
    80001c04:	84aa                	mv	s1,a0
  sz = p->sz;
    80001c06:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001c08:	01204c63          	bgtz	s2,80001c20 <growproc+0x2e>
  } else if(n < 0){
    80001c0c:	02094463          	bltz	s2,80001c34 <growproc+0x42>
  p->sz = sz;
    80001c10:	e4ac                	sd	a1,72(s1)
  return 0;
    80001c12:	4501                	li	a0,0
}
    80001c14:	60e2                	ld	ra,24(sp)
    80001c16:	6442                	ld	s0,16(sp)
    80001c18:	64a2                	ld	s1,8(sp)
    80001c1a:	6902                	ld	s2,0(sp)
    80001c1c:	6105                	addi	sp,sp,32
    80001c1e:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c20:	4691                	li	a3,4
    80001c22:	00b90633          	add	a2,s2,a1
    80001c26:	6928                	ld	a0,80(a0)
    80001c28:	ecaff0ef          	jal	ra,800012f2 <uvmalloc>
    80001c2c:	85aa                	mv	a1,a0
    80001c2e:	f16d                	bnez	a0,80001c10 <growproc+0x1e>
      return -1;
    80001c30:	557d                	li	a0,-1
    80001c32:	b7cd                	j	80001c14 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c34:	00b90633          	add	a2,s2,a1
    80001c38:	6928                	ld	a0,80(a0)
    80001c3a:	e74ff0ef          	jal	ra,800012ae <uvmdealloc>
    80001c3e:	85aa                	mv	a1,a0
    80001c40:	bfc1                	j	80001c10 <growproc+0x1e>

0000000080001c42 <fork>:
{
    80001c42:	7179                	addi	sp,sp,-48
    80001c44:	f406                	sd	ra,40(sp)
    80001c46:	f022                	sd	s0,32(sp)
    80001c48:	ec26                	sd	s1,24(sp)
    80001c4a:	e84a                	sd	s2,16(sp)
    80001c4c:	e44e                	sd	s3,8(sp)
    80001c4e:	e052                	sd	s4,0(sp)
    80001c50:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001c52:	ccbff0ef          	jal	ra,8000191c <myproc>
    80001c56:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    80001c58:	e87ff0ef          	jal	ra,80001ade <allocproc>
    80001c5c:	0e050563          	beqz	a0,80001d46 <fork+0x104>
    80001c60:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c62:	04893603          	ld	a2,72(s2)
    80001c66:	692c                	ld	a1,80(a0)
    80001c68:	05093503          	ld	a0,80(s2)
    80001c6c:	faeff0ef          	jal	ra,8000141a <uvmcopy>
    80001c70:	04054663          	bltz	a0,80001cbc <fork+0x7a>
  np->sz = p->sz;
    80001c74:	04893783          	ld	a5,72(s2)
    80001c78:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c7c:	05893683          	ld	a3,88(s2)
    80001c80:	87b6                	mv	a5,a3
    80001c82:	0589b703          	ld	a4,88(s3)
    80001c86:	12068693          	addi	a3,a3,288
    80001c8a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c8e:	6788                	ld	a0,8(a5)
    80001c90:	6b8c                	ld	a1,16(a5)
    80001c92:	6f90                	ld	a2,24(a5)
    80001c94:	01073023          	sd	a6,0(a4)
    80001c98:	e708                	sd	a0,8(a4)
    80001c9a:	eb0c                	sd	a1,16(a4)
    80001c9c:	ef10                	sd	a2,24(a4)
    80001c9e:	02078793          	addi	a5,a5,32
    80001ca2:	02070713          	addi	a4,a4,32
    80001ca6:	fed792e3          	bne	a5,a3,80001c8a <fork+0x48>
  np->trapframe->a0 = 0;
    80001caa:	0589b783          	ld	a5,88(s3)
    80001cae:	0607b823          	sd	zero,112(a5)
    80001cb2:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001cb6:	15000a13          	li	s4,336
    80001cba:	a00d                	j	80001cdc <fork+0x9a>
    freeproc(np);
    80001cbc:	854e                	mv	a0,s3
    80001cbe:	dd1ff0ef          	jal	ra,80001a8e <freeproc>
    release(&np->lock);
    80001cc2:	854e                	mv	a0,s3
    80001cc4:	f7dfe0ef          	jal	ra,80000c40 <release>
    return -1;
    80001cc8:	5a7d                	li	s4,-1
    80001cca:	a0ad                	j	80001d34 <fork+0xf2>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ccc:	246020ef          	jal	ra,80003f12 <filedup>
    80001cd0:	009987b3          	add	a5,s3,s1
    80001cd4:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001cd6:	04a1                	addi	s1,s1,8
    80001cd8:	01448763          	beq	s1,s4,80001ce6 <fork+0xa4>
    if(p->ofile[i])
    80001cdc:	009907b3          	add	a5,s2,s1
    80001ce0:	6388                	ld	a0,0(a5)
    80001ce2:	f56d                	bnez	a0,80001ccc <fork+0x8a>
    80001ce4:	bfcd                	j	80001cd6 <fork+0x94>
  np->cwd = idup(p->cwd);
    80001ce6:	15093503          	ld	a0,336(s2)
    80001cea:	592010ef          	jal	ra,8000327c <idup>
    80001cee:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cf2:	4641                	li	a2,16
    80001cf4:	15890593          	addi	a1,s2,344
    80001cf8:	15898513          	addi	a0,s3,344
    80001cfc:	8ceff0ef          	jal	ra,80000dca <safestrcpy>
  pid = np->pid;
    80001d00:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    80001d04:	854e                	mv	a0,s3
    80001d06:	f3bfe0ef          	jal	ra,80000c40 <release>
  acquire(&wait_lock);
    80001d0a:	0000e497          	auipc	s1,0xe
    80001d0e:	dde48493          	addi	s1,s1,-546 # 8000fae8 <wait_lock>
    80001d12:	8526                	mv	a0,s1
    80001d14:	e95fe0ef          	jal	ra,80000ba8 <acquire>
  np->parent = p;
    80001d18:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	f23fe0ef          	jal	ra,80000c40 <release>
  acquire(&np->lock);
    80001d22:	854e                	mv	a0,s3
    80001d24:	e85fe0ef          	jal	ra,80000ba8 <acquire>
  np->state = RUNNABLE;
    80001d28:	478d                	li	a5,3
    80001d2a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d2e:	854e                	mv	a0,s3
    80001d30:	f11fe0ef          	jal	ra,80000c40 <release>
}
    80001d34:	8552                	mv	a0,s4
    80001d36:	70a2                	ld	ra,40(sp)
    80001d38:	7402                	ld	s0,32(sp)
    80001d3a:	64e2                	ld	s1,24(sp)
    80001d3c:	6942                	ld	s2,16(sp)
    80001d3e:	69a2                	ld	s3,8(sp)
    80001d40:	6a02                	ld	s4,0(sp)
    80001d42:	6145                	addi	sp,sp,48
    80001d44:	8082                	ret
    return -1;
    80001d46:	5a7d                	li	s4,-1
    80001d48:	b7f5                	j	80001d34 <fork+0xf2>

0000000080001d4a <scheduler>:
{
    80001d4a:	715d                	addi	sp,sp,-80
    80001d4c:	e486                	sd	ra,72(sp)
    80001d4e:	e0a2                	sd	s0,64(sp)
    80001d50:	fc26                	sd	s1,56(sp)
    80001d52:	f84a                	sd	s2,48(sp)
    80001d54:	f44e                	sd	s3,40(sp)
    80001d56:	f052                	sd	s4,32(sp)
    80001d58:	ec56                	sd	s5,24(sp)
    80001d5a:	e85a                	sd	s6,16(sp)
    80001d5c:	e45e                	sd	s7,8(sp)
    80001d5e:	e062                	sd	s8,0(sp)
    80001d60:	0880                	addi	s0,sp,80
    80001d62:	8792                	mv	a5,tp
  int id = r_tp();
    80001d64:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d66:	00779b13          	slli	s6,a5,0x7
    80001d6a:	0000e717          	auipc	a4,0xe
    80001d6e:	d6670713          	addi	a4,a4,-666 # 8000fad0 <pid_lock>
    80001d72:	975a                	add	a4,a4,s6
    80001d74:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d78:	0000e717          	auipc	a4,0xe
    80001d7c:	d9070713          	addi	a4,a4,-624 # 8000fb08 <cpus+0x8>
    80001d80:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d82:	4c11                	li	s8,4
        c->proc = p;
    80001d84:	079e                	slli	a5,a5,0x7
    80001d86:	0000ea17          	auipc	s4,0xe
    80001d8a:	d4aa0a13          	addi	s4,s4,-694 # 8000fad0 <pid_lock>
    80001d8e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d90:	00014997          	auipc	s3,0x14
    80001d94:	b7098993          	addi	s3,s3,-1168 # 80015900 <tickslock>
        found = 1;
    80001d98:	4b85                	li	s7,1
    80001d9a:	a0a9                	j	80001de4 <scheduler+0x9a>
        p->state = RUNNING;
    80001d9c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001da0:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001da4:	06048593          	addi	a1,s1,96
    80001da8:	855a                	mv	a0,s6
    80001daa:	5cc000ef          	jal	ra,80002376 <swtch>
        c->proc = 0;
    80001dae:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001db2:	8ade                	mv	s5,s7
      release(&p->lock);
    80001db4:	8526                	mv	a0,s1
    80001db6:	e8bfe0ef          	jal	ra,80000c40 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dba:	16848493          	addi	s1,s1,360
    80001dbe:	01348963          	beq	s1,s3,80001dd0 <scheduler+0x86>
      acquire(&p->lock);
    80001dc2:	8526                	mv	a0,s1
    80001dc4:	de5fe0ef          	jal	ra,80000ba8 <acquire>
      if(p->state == RUNNABLE) {
    80001dc8:	4c9c                	lw	a5,24(s1)
    80001dca:	ff2795e3          	bne	a5,s2,80001db4 <scheduler+0x6a>
    80001dce:	b7f9                	j	80001d9c <scheduler+0x52>
    if(found == 0) {
    80001dd0:	000a9a63          	bnez	s5,80001de4 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001dd4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dd8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ddc:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001de0:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001de8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dec:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001df0:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001df2:	0000e497          	auipc	s1,0xe
    80001df6:	10e48493          	addi	s1,s1,270 # 8000ff00 <proc>
      if(p->state == RUNNABLE) {
    80001dfa:	490d                	li	s2,3
    80001dfc:	b7d9                	j	80001dc2 <scheduler+0x78>

0000000080001dfe <sched>:
{
    80001dfe:	7179                	addi	sp,sp,-48
    80001e00:	f406                	sd	ra,40(sp)
    80001e02:	f022                	sd	s0,32(sp)
    80001e04:	ec26                	sd	s1,24(sp)
    80001e06:	e84a                	sd	s2,16(sp)
    80001e08:	e44e                	sd	s3,8(sp)
    80001e0a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e0c:	b11ff0ef          	jal	ra,8000191c <myproc>
    80001e10:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e12:	d2dfe0ef          	jal	ra,80000b3e <holding>
    80001e16:	c92d                	beqz	a0,80001e88 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e18:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e1a:	2781                	sext.w	a5,a5
    80001e1c:	079e                	slli	a5,a5,0x7
    80001e1e:	0000e717          	auipc	a4,0xe
    80001e22:	cb270713          	addi	a4,a4,-846 # 8000fad0 <pid_lock>
    80001e26:	97ba                	add	a5,a5,a4
    80001e28:	0a87a703          	lw	a4,168(a5)
    80001e2c:	4785                	li	a5,1
    80001e2e:	06f71363          	bne	a4,a5,80001e94 <sched+0x96>
  if(p->state == RUNNING)
    80001e32:	4c98                	lw	a4,24(s1)
    80001e34:	4791                	li	a5,4
    80001e36:	06f70563          	beq	a4,a5,80001ea0 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e40:	e7b5                	bnez	a5,80001eac <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e42:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e44:	0000e917          	auipc	s2,0xe
    80001e48:	c8c90913          	addi	s2,s2,-884 # 8000fad0 <pid_lock>
    80001e4c:	2781                	sext.w	a5,a5
    80001e4e:	079e                	slli	a5,a5,0x7
    80001e50:	97ca                	add	a5,a5,s2
    80001e52:	0ac7a983          	lw	s3,172(a5)
    80001e56:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e58:	2781                	sext.w	a5,a5
    80001e5a:	079e                	slli	a5,a5,0x7
    80001e5c:	0000e597          	auipc	a1,0xe
    80001e60:	cac58593          	addi	a1,a1,-852 # 8000fb08 <cpus+0x8>
    80001e64:	95be                	add	a1,a1,a5
    80001e66:	06048513          	addi	a0,s1,96
    80001e6a:	50c000ef          	jal	ra,80002376 <swtch>
    80001e6e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e70:	2781                	sext.w	a5,a5
    80001e72:	079e                	slli	a5,a5,0x7
    80001e74:	97ca                	add	a5,a5,s2
    80001e76:	0b37a623          	sw	s3,172(a5)
}
    80001e7a:	70a2                	ld	ra,40(sp)
    80001e7c:	7402                	ld	s0,32(sp)
    80001e7e:	64e2                	ld	s1,24(sp)
    80001e80:	6942                	ld	s2,16(sp)
    80001e82:	69a2                	ld	s3,8(sp)
    80001e84:	6145                	addi	sp,sp,48
    80001e86:	8082                	ret
    panic("sched p->lock");
    80001e88:	00005517          	auipc	a0,0x5
    80001e8c:	43050513          	addi	a0,a0,1072 # 800072b8 <digits+0x280>
    80001e90:	8cdfe0ef          	jal	ra,8000075c <panic>
    panic("sched locks");
    80001e94:	00005517          	auipc	a0,0x5
    80001e98:	43450513          	addi	a0,a0,1076 # 800072c8 <digits+0x290>
    80001e9c:	8c1fe0ef          	jal	ra,8000075c <panic>
    panic("sched running");
    80001ea0:	00005517          	auipc	a0,0x5
    80001ea4:	43850513          	addi	a0,a0,1080 # 800072d8 <digits+0x2a0>
    80001ea8:	8b5fe0ef          	jal	ra,8000075c <panic>
    panic("sched interruptible");
    80001eac:	00005517          	auipc	a0,0x5
    80001eb0:	43c50513          	addi	a0,a0,1084 # 800072e8 <digits+0x2b0>
    80001eb4:	8a9fe0ef          	jal	ra,8000075c <panic>

0000000080001eb8 <yield>:
{
    80001eb8:	1101                	addi	sp,sp,-32
    80001eba:	ec06                	sd	ra,24(sp)
    80001ebc:	e822                	sd	s0,16(sp)
    80001ebe:	e426                	sd	s1,8(sp)
    80001ec0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001ec2:	a5bff0ef          	jal	ra,8000191c <myproc>
    80001ec6:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001ec8:	ce1fe0ef          	jal	ra,80000ba8 <acquire>
  p->state = RUNNABLE;
    80001ecc:	478d                	li	a5,3
    80001ece:	cc9c                	sw	a5,24(s1)
  sched();
    80001ed0:	f2fff0ef          	jal	ra,80001dfe <sched>
  release(&p->lock);
    80001ed4:	8526                	mv	a0,s1
    80001ed6:	d6bfe0ef          	jal	ra,80000c40 <release>
}
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6105                	addi	sp,sp,32
    80001ee2:	8082                	ret

0000000080001ee4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001ee4:	7179                	addi	sp,sp,-48
    80001ee6:	f406                	sd	ra,40(sp)
    80001ee8:	f022                	sd	s0,32(sp)
    80001eea:	ec26                	sd	s1,24(sp)
    80001eec:	e84a                	sd	s2,16(sp)
    80001eee:	e44e                	sd	s3,8(sp)
    80001ef0:	1800                	addi	s0,sp,48
    80001ef2:	89aa                	mv	s3,a0
    80001ef4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ef6:	a27ff0ef          	jal	ra,8000191c <myproc>
    80001efa:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001efc:	cadfe0ef          	jal	ra,80000ba8 <acquire>
  release(lk);
    80001f00:	854a                	mv	a0,s2
    80001f02:	d3ffe0ef          	jal	ra,80000c40 <release>

  // Go to sleep.
  p->chan = chan;
    80001f06:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f0a:	4789                	li	a5,2
    80001f0c:	cc9c                	sw	a5,24(s1)

  sched();
    80001f0e:	ef1ff0ef          	jal	ra,80001dfe <sched>

  // Tidy up.
  p->chan = 0;
    80001f12:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f16:	8526                	mv	a0,s1
    80001f18:	d29fe0ef          	jal	ra,80000c40 <release>
  acquire(lk);
    80001f1c:	854a                	mv	a0,s2
    80001f1e:	c8bfe0ef          	jal	ra,80000ba8 <acquire>
}
    80001f22:	70a2                	ld	ra,40(sp)
    80001f24:	7402                	ld	s0,32(sp)
    80001f26:	64e2                	ld	s1,24(sp)
    80001f28:	6942                	ld	s2,16(sp)
    80001f2a:	69a2                	ld	s3,8(sp)
    80001f2c:	6145                	addi	sp,sp,48
    80001f2e:	8082                	ret

0000000080001f30 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f30:	7139                	addi	sp,sp,-64
    80001f32:	fc06                	sd	ra,56(sp)
    80001f34:	f822                	sd	s0,48(sp)
    80001f36:	f426                	sd	s1,40(sp)
    80001f38:	f04a                	sd	s2,32(sp)
    80001f3a:	ec4e                	sd	s3,24(sp)
    80001f3c:	e852                	sd	s4,16(sp)
    80001f3e:	e456                	sd	s5,8(sp)
    80001f40:	0080                	addi	s0,sp,64
    80001f42:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f44:	0000e497          	auipc	s1,0xe
    80001f48:	fbc48493          	addi	s1,s1,-68 # 8000ff00 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f4c:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f4e:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f50:	00014917          	auipc	s2,0x14
    80001f54:	9b090913          	addi	s2,s2,-1616 # 80015900 <tickslock>
    80001f58:	a811                	j	80001f6c <wakeup+0x3c>
        p->state = RUNNABLE;
    80001f5a:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80001f5e:	8526                	mv	a0,s1
    80001f60:	ce1fe0ef          	jal	ra,80000c40 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f64:	16848493          	addi	s1,s1,360
    80001f68:	03248063          	beq	s1,s2,80001f88 <wakeup+0x58>
    if(p != myproc()){
    80001f6c:	9b1ff0ef          	jal	ra,8000191c <myproc>
    80001f70:	fea48ae3          	beq	s1,a0,80001f64 <wakeup+0x34>
      acquire(&p->lock);
    80001f74:	8526                	mv	a0,s1
    80001f76:	c33fe0ef          	jal	ra,80000ba8 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f7a:	4c9c                	lw	a5,24(s1)
    80001f7c:	ff3791e3          	bne	a5,s3,80001f5e <wakeup+0x2e>
    80001f80:	709c                	ld	a5,32(s1)
    80001f82:	fd479ee3          	bne	a5,s4,80001f5e <wakeup+0x2e>
    80001f86:	bfd1                	j	80001f5a <wakeup+0x2a>
    }
  }
}
    80001f88:	70e2                	ld	ra,56(sp)
    80001f8a:	7442                	ld	s0,48(sp)
    80001f8c:	74a2                	ld	s1,40(sp)
    80001f8e:	7902                	ld	s2,32(sp)
    80001f90:	69e2                	ld	s3,24(sp)
    80001f92:	6a42                	ld	s4,16(sp)
    80001f94:	6aa2                	ld	s5,8(sp)
    80001f96:	6121                	addi	sp,sp,64
    80001f98:	8082                	ret

0000000080001f9a <reparent>:
{
    80001f9a:	7179                	addi	sp,sp,-48
    80001f9c:	f406                	sd	ra,40(sp)
    80001f9e:	f022                	sd	s0,32(sp)
    80001fa0:	ec26                	sd	s1,24(sp)
    80001fa2:	e84a                	sd	s2,16(sp)
    80001fa4:	e44e                	sd	s3,8(sp)
    80001fa6:	e052                	sd	s4,0(sp)
    80001fa8:	1800                	addi	s0,sp,48
    80001faa:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fac:	0000e497          	auipc	s1,0xe
    80001fb0:	f5448493          	addi	s1,s1,-172 # 8000ff00 <proc>
      pp->parent = initproc;
    80001fb4:	00006a17          	auipc	s4,0x6
    80001fb8:	9e4a0a13          	addi	s4,s4,-1564 # 80007998 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001fbc:	00014997          	auipc	s3,0x14
    80001fc0:	94498993          	addi	s3,s3,-1724 # 80015900 <tickslock>
    80001fc4:	a029                	j	80001fce <reparent+0x34>
    80001fc6:	16848493          	addi	s1,s1,360
    80001fca:	01348b63          	beq	s1,s3,80001fe0 <reparent+0x46>
    if(pp->parent == p){
    80001fce:	7c9c                	ld	a5,56(s1)
    80001fd0:	ff279be3          	bne	a5,s2,80001fc6 <reparent+0x2c>
      pp->parent = initproc;
    80001fd4:	000a3503          	ld	a0,0(s4)
    80001fd8:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fda:	f57ff0ef          	jal	ra,80001f30 <wakeup>
    80001fde:	b7e5                	j	80001fc6 <reparent+0x2c>
}
    80001fe0:	70a2                	ld	ra,40(sp)
    80001fe2:	7402                	ld	s0,32(sp)
    80001fe4:	64e2                	ld	s1,24(sp)
    80001fe6:	6942                	ld	s2,16(sp)
    80001fe8:	69a2                	ld	s3,8(sp)
    80001fea:	6a02                	ld	s4,0(sp)
    80001fec:	6145                	addi	sp,sp,48
    80001fee:	8082                	ret

0000000080001ff0 <exit>:
{
    80001ff0:	7179                	addi	sp,sp,-48
    80001ff2:	f406                	sd	ra,40(sp)
    80001ff4:	f022                	sd	s0,32(sp)
    80001ff6:	ec26                	sd	s1,24(sp)
    80001ff8:	e84a                	sd	s2,16(sp)
    80001ffa:	e44e                	sd	s3,8(sp)
    80001ffc:	e052                	sd	s4,0(sp)
    80001ffe:	1800                	addi	s0,sp,48
    80002000:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002002:	91bff0ef          	jal	ra,8000191c <myproc>
    80002006:	89aa                	mv	s3,a0
  if(p == initproc)
    80002008:	00006797          	auipc	a5,0x6
    8000200c:	9907b783          	ld	a5,-1648(a5) # 80007998 <initproc>
    80002010:	0d050493          	addi	s1,a0,208
    80002014:	15050913          	addi	s2,a0,336
    80002018:	00a79f63          	bne	a5,a0,80002036 <exit+0x46>
    panic("init exiting");
    8000201c:	00005517          	auipc	a0,0x5
    80002020:	2e450513          	addi	a0,a0,740 # 80007300 <digits+0x2c8>
    80002024:	f38fe0ef          	jal	ra,8000075c <panic>
      fileclose(f);
    80002028:	731010ef          	jal	ra,80003f58 <fileclose>
      p->ofile[fd] = 0;
    8000202c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002030:	04a1                	addi	s1,s1,8
    80002032:	01248563          	beq	s1,s2,8000203c <exit+0x4c>
    if(p->ofile[fd]){
    80002036:	6088                	ld	a0,0(s1)
    80002038:	f965                	bnez	a0,80002028 <exit+0x38>
    8000203a:	bfdd                	j	80002030 <exit+0x40>
  begin_op();
    8000203c:	301010ef          	jal	ra,80003b3c <begin_op>
  iput(p->cwd);
    80002040:	1509b503          	ld	a0,336(s3)
    80002044:	3ec010ef          	jal	ra,80003430 <iput>
  end_op();
    80002048:	365010ef          	jal	ra,80003bac <end_op>
  p->cwd = 0;
    8000204c:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002050:	0000e497          	auipc	s1,0xe
    80002054:	a9848493          	addi	s1,s1,-1384 # 8000fae8 <wait_lock>
    80002058:	8526                	mv	a0,s1
    8000205a:	b4ffe0ef          	jal	ra,80000ba8 <acquire>
  reparent(p);
    8000205e:	854e                	mv	a0,s3
    80002060:	f3bff0ef          	jal	ra,80001f9a <reparent>
  wakeup(p->parent);
    80002064:	0389b503          	ld	a0,56(s3)
    80002068:	ec9ff0ef          	jal	ra,80001f30 <wakeup>
  acquire(&p->lock);
    8000206c:	854e                	mv	a0,s3
    8000206e:	b3bfe0ef          	jal	ra,80000ba8 <acquire>
  p->xstate = status;
    80002072:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002076:	4795                	li	a5,5
    80002078:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000207c:	8526                	mv	a0,s1
    8000207e:	bc3fe0ef          	jal	ra,80000c40 <release>
  sched();
    80002082:	d7dff0ef          	jal	ra,80001dfe <sched>
  panic("zombie exit");
    80002086:	00005517          	auipc	a0,0x5
    8000208a:	28a50513          	addi	a0,a0,650 # 80007310 <digits+0x2d8>
    8000208e:	ecefe0ef          	jal	ra,8000075c <panic>

0000000080002092 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002092:	7179                	addi	sp,sp,-48
    80002094:	f406                	sd	ra,40(sp)
    80002096:	f022                	sd	s0,32(sp)
    80002098:	ec26                	sd	s1,24(sp)
    8000209a:	e84a                	sd	s2,16(sp)
    8000209c:	e44e                	sd	s3,8(sp)
    8000209e:	1800                	addi	s0,sp,48
    800020a0:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020a2:	0000e497          	auipc	s1,0xe
    800020a6:	e5e48493          	addi	s1,s1,-418 # 8000ff00 <proc>
    800020aa:	00014997          	auipc	s3,0x14
    800020ae:	85698993          	addi	s3,s3,-1962 # 80015900 <tickslock>
    acquire(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	af5fe0ef          	jal	ra,80000ba8 <acquire>
    if(p->pid == pid){
    800020b8:	589c                	lw	a5,48(s1)
    800020ba:	01278b63          	beq	a5,s2,800020d0 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020be:	8526                	mv	a0,s1
    800020c0:	b81fe0ef          	jal	ra,80000c40 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020c4:	16848493          	addi	s1,s1,360
    800020c8:	ff3495e3          	bne	s1,s3,800020b2 <kill+0x20>
  }
  return -1;
    800020cc:	557d                	li	a0,-1
    800020ce:	a819                	j	800020e4 <kill+0x52>
      p->killed = 1;
    800020d0:	4785                	li	a5,1
    800020d2:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020d4:	4c98                	lw	a4,24(s1)
    800020d6:	4789                	li	a5,2
    800020d8:	00f70d63          	beq	a4,a5,800020f2 <kill+0x60>
      release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	b63fe0ef          	jal	ra,80000c40 <release>
      return 0;
    800020e2:	4501                	li	a0,0
}
    800020e4:	70a2                	ld	ra,40(sp)
    800020e6:	7402                	ld	s0,32(sp)
    800020e8:	64e2                	ld	s1,24(sp)
    800020ea:	6942                	ld	s2,16(sp)
    800020ec:	69a2                	ld	s3,8(sp)
    800020ee:	6145                	addi	sp,sp,48
    800020f0:	8082                	ret
        p->state = RUNNABLE;
    800020f2:	478d                	li	a5,3
    800020f4:	cc9c                	sw	a5,24(s1)
    800020f6:	b7dd                	j	800020dc <kill+0x4a>

00000000800020f8 <setkilled>:

void
setkilled(struct proc *p)
{
    800020f8:	1101                	addi	sp,sp,-32
    800020fa:	ec06                	sd	ra,24(sp)
    800020fc:	e822                	sd	s0,16(sp)
    800020fe:	e426                	sd	s1,8(sp)
    80002100:	1000                	addi	s0,sp,32
    80002102:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002104:	aa5fe0ef          	jal	ra,80000ba8 <acquire>
  p->killed = 1;
    80002108:	4785                	li	a5,1
    8000210a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000210c:	8526                	mv	a0,s1
    8000210e:	b33fe0ef          	jal	ra,80000c40 <release>
}
    80002112:	60e2                	ld	ra,24(sp)
    80002114:	6442                	ld	s0,16(sp)
    80002116:	64a2                	ld	s1,8(sp)
    80002118:	6105                	addi	sp,sp,32
    8000211a:	8082                	ret

000000008000211c <killed>:

int
killed(struct proc *p)
{
    8000211c:	1101                	addi	sp,sp,-32
    8000211e:	ec06                	sd	ra,24(sp)
    80002120:	e822                	sd	s0,16(sp)
    80002122:	e426                	sd	s1,8(sp)
    80002124:	e04a                	sd	s2,0(sp)
    80002126:	1000                	addi	s0,sp,32
    80002128:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000212a:	a7ffe0ef          	jal	ra,80000ba8 <acquire>
  k = p->killed;
    8000212e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002132:	8526                	mv	a0,s1
    80002134:	b0dfe0ef          	jal	ra,80000c40 <release>
  return k;
}
    80002138:	854a                	mv	a0,s2
    8000213a:	60e2                	ld	ra,24(sp)
    8000213c:	6442                	ld	s0,16(sp)
    8000213e:	64a2                	ld	s1,8(sp)
    80002140:	6902                	ld	s2,0(sp)
    80002142:	6105                	addi	sp,sp,32
    80002144:	8082                	ret

0000000080002146 <wait>:
{
    80002146:	715d                	addi	sp,sp,-80
    80002148:	e486                	sd	ra,72(sp)
    8000214a:	e0a2                	sd	s0,64(sp)
    8000214c:	fc26                	sd	s1,56(sp)
    8000214e:	f84a                	sd	s2,48(sp)
    80002150:	f44e                	sd	s3,40(sp)
    80002152:	f052                	sd	s4,32(sp)
    80002154:	ec56                	sd	s5,24(sp)
    80002156:	e85a                	sd	s6,16(sp)
    80002158:	e45e                	sd	s7,8(sp)
    8000215a:	e062                	sd	s8,0(sp)
    8000215c:	0880                	addi	s0,sp,80
    8000215e:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002160:	fbcff0ef          	jal	ra,8000191c <myproc>
    80002164:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002166:	0000e517          	auipc	a0,0xe
    8000216a:	98250513          	addi	a0,a0,-1662 # 8000fae8 <wait_lock>
    8000216e:	a3bfe0ef          	jal	ra,80000ba8 <acquire>
    havekids = 0;
    80002172:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002174:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002176:	00013997          	auipc	s3,0x13
    8000217a:	78a98993          	addi	s3,s3,1930 # 80015900 <tickslock>
        havekids = 1;
    8000217e:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002180:	0000ec17          	auipc	s8,0xe
    80002184:	968c0c13          	addi	s8,s8,-1688 # 8000fae8 <wait_lock>
    havekids = 0;
    80002188:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218a:	0000e497          	auipc	s1,0xe
    8000218e:	d7648493          	addi	s1,s1,-650 # 8000ff00 <proc>
    80002192:	a899                	j	800021e8 <wait+0xa2>
          pid = pp->pid;
    80002194:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002198:	000b0c63          	beqz	s6,800021b0 <wait+0x6a>
    8000219c:	4691                	li	a3,4
    8000219e:	02c48613          	addi	a2,s1,44
    800021a2:	85da                	mv	a1,s6
    800021a4:	05093503          	ld	a0,80(s2)
    800021a8:	b4eff0ef          	jal	ra,800014f6 <copyout>
    800021ac:	00054f63          	bltz	a0,800021ca <wait+0x84>
          freeproc(pp);
    800021b0:	8526                	mv	a0,s1
    800021b2:	8ddff0ef          	jal	ra,80001a8e <freeproc>
          release(&pp->lock);
    800021b6:	8526                	mv	a0,s1
    800021b8:	a89fe0ef          	jal	ra,80000c40 <release>
          release(&wait_lock);
    800021bc:	0000e517          	auipc	a0,0xe
    800021c0:	92c50513          	addi	a0,a0,-1748 # 8000fae8 <wait_lock>
    800021c4:	a7dfe0ef          	jal	ra,80000c40 <release>
          return pid;
    800021c8:	a891                	j	8000221c <wait+0xd6>
            release(&pp->lock);
    800021ca:	8526                	mv	a0,s1
    800021cc:	a75fe0ef          	jal	ra,80000c40 <release>
            release(&wait_lock);
    800021d0:	0000e517          	auipc	a0,0xe
    800021d4:	91850513          	addi	a0,a0,-1768 # 8000fae8 <wait_lock>
    800021d8:	a69fe0ef          	jal	ra,80000c40 <release>
            return -1;
    800021dc:	59fd                	li	s3,-1
    800021de:	a83d                	j	8000221c <wait+0xd6>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e0:	16848493          	addi	s1,s1,360
    800021e4:	03348063          	beq	s1,s3,80002204 <wait+0xbe>
      if(pp->parent == p){
    800021e8:	7c9c                	ld	a5,56(s1)
    800021ea:	ff279be3          	bne	a5,s2,800021e0 <wait+0x9a>
        acquire(&pp->lock);
    800021ee:	8526                	mv	a0,s1
    800021f0:	9b9fe0ef          	jal	ra,80000ba8 <acquire>
        if(pp->state == ZOMBIE){
    800021f4:	4c9c                	lw	a5,24(s1)
    800021f6:	f9478fe3          	beq	a5,s4,80002194 <wait+0x4e>
        release(&pp->lock);
    800021fa:	8526                	mv	a0,s1
    800021fc:	a45fe0ef          	jal	ra,80000c40 <release>
        havekids = 1;
    80002200:	8756                	mv	a4,s5
    80002202:	bff9                	j	800021e0 <wait+0x9a>
    if(!havekids || killed(p)){
    80002204:	c709                	beqz	a4,8000220e <wait+0xc8>
    80002206:	854a                	mv	a0,s2
    80002208:	f15ff0ef          	jal	ra,8000211c <killed>
    8000220c:	c50d                	beqz	a0,80002236 <wait+0xf0>
      release(&wait_lock);
    8000220e:	0000e517          	auipc	a0,0xe
    80002212:	8da50513          	addi	a0,a0,-1830 # 8000fae8 <wait_lock>
    80002216:	a2bfe0ef          	jal	ra,80000c40 <release>
      return -1;
    8000221a:	59fd                	li	s3,-1
}
    8000221c:	854e                	mv	a0,s3
    8000221e:	60a6                	ld	ra,72(sp)
    80002220:	6406                	ld	s0,64(sp)
    80002222:	74e2                	ld	s1,56(sp)
    80002224:	7942                	ld	s2,48(sp)
    80002226:	79a2                	ld	s3,40(sp)
    80002228:	7a02                	ld	s4,32(sp)
    8000222a:	6ae2                	ld	s5,24(sp)
    8000222c:	6b42                	ld	s6,16(sp)
    8000222e:	6ba2                	ld	s7,8(sp)
    80002230:	6c02                	ld	s8,0(sp)
    80002232:	6161                	addi	sp,sp,80
    80002234:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002236:	85e2                	mv	a1,s8
    80002238:	854a                	mv	a0,s2
    8000223a:	cabff0ef          	jal	ra,80001ee4 <sleep>
    havekids = 0;
    8000223e:	b7a9                	j	80002188 <wait+0x42>

0000000080002240 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002240:	7179                	addi	sp,sp,-48
    80002242:	f406                	sd	ra,40(sp)
    80002244:	f022                	sd	s0,32(sp)
    80002246:	ec26                	sd	s1,24(sp)
    80002248:	e84a                	sd	s2,16(sp)
    8000224a:	e44e                	sd	s3,8(sp)
    8000224c:	e052                	sd	s4,0(sp)
    8000224e:	1800                	addi	s0,sp,48
    80002250:	84aa                	mv	s1,a0
    80002252:	892e                	mv	s2,a1
    80002254:	89b2                	mv	s3,a2
    80002256:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002258:	ec4ff0ef          	jal	ra,8000191c <myproc>
  if(user_dst){
    8000225c:	cc99                	beqz	s1,8000227a <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000225e:	86d2                	mv	a3,s4
    80002260:	864e                	mv	a2,s3
    80002262:	85ca                	mv	a1,s2
    80002264:	6928                	ld	a0,80(a0)
    80002266:	a90ff0ef          	jal	ra,800014f6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000226a:	70a2                	ld	ra,40(sp)
    8000226c:	7402                	ld	s0,32(sp)
    8000226e:	64e2                	ld	s1,24(sp)
    80002270:	6942                	ld	s2,16(sp)
    80002272:	69a2                	ld	s3,8(sp)
    80002274:	6a02                	ld	s4,0(sp)
    80002276:	6145                	addi	sp,sp,48
    80002278:	8082                	ret
    memmove((char *)dst, src, len);
    8000227a:	000a061b          	sext.w	a2,s4
    8000227e:	85ce                	mv	a1,s3
    80002280:	854a                	mv	a0,s2
    80002282:	a5bfe0ef          	jal	ra,80000cdc <memmove>
    return 0;
    80002286:	8526                	mv	a0,s1
    80002288:	b7cd                	j	8000226a <either_copyout+0x2a>

000000008000228a <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000228a:	7179                	addi	sp,sp,-48
    8000228c:	f406                	sd	ra,40(sp)
    8000228e:	f022                	sd	s0,32(sp)
    80002290:	ec26                	sd	s1,24(sp)
    80002292:	e84a                	sd	s2,16(sp)
    80002294:	e44e                	sd	s3,8(sp)
    80002296:	e052                	sd	s4,0(sp)
    80002298:	1800                	addi	s0,sp,48
    8000229a:	892a                	mv	s2,a0
    8000229c:	84ae                	mv	s1,a1
    8000229e:	89b2                	mv	s3,a2
    800022a0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a2:	e7aff0ef          	jal	ra,8000191c <myproc>
  if(user_src){
    800022a6:	cc99                	beqz	s1,800022c4 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022a8:	86d2                	mv	a3,s4
    800022aa:	864e                	mv	a2,s3
    800022ac:	85ca                	mv	a1,s2
    800022ae:	6928                	ld	a0,80(a0)
    800022b0:	afeff0ef          	jal	ra,800015ae <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022b4:	70a2                	ld	ra,40(sp)
    800022b6:	7402                	ld	s0,32(sp)
    800022b8:	64e2                	ld	s1,24(sp)
    800022ba:	6942                	ld	s2,16(sp)
    800022bc:	69a2                	ld	s3,8(sp)
    800022be:	6a02                	ld	s4,0(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret
    memmove(dst, (char*)src, len);
    800022c4:	000a061b          	sext.w	a2,s4
    800022c8:	85ce                	mv	a1,s3
    800022ca:	854a                	mv	a0,s2
    800022cc:	a11fe0ef          	jal	ra,80000cdc <memmove>
    return 0;
    800022d0:	8526                	mv	a0,s1
    800022d2:	b7cd                	j	800022b4 <either_copyin+0x2a>

00000000800022d4 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022d4:	715d                	addi	sp,sp,-80
    800022d6:	e486                	sd	ra,72(sp)
    800022d8:	e0a2                	sd	s0,64(sp)
    800022da:	fc26                	sd	s1,56(sp)
    800022dc:	f84a                	sd	s2,48(sp)
    800022de:	f44e                	sd	s3,40(sp)
    800022e0:	f052                	sd	s4,32(sp)
    800022e2:	ec56                	sd	s5,24(sp)
    800022e4:	e85a                	sd	s6,16(sp)
    800022e6:	e45e                	sd	s7,8(sp)
    800022e8:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022ea:	00005517          	auipc	a0,0x5
    800022ee:	dd650513          	addi	a0,a0,-554 # 800070c0 <digits+0x88>
    800022f2:	9b6fe0ef          	jal	ra,800004a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800022f6:	0000e497          	auipc	s1,0xe
    800022fa:	d6248493          	addi	s1,s1,-670 # 80010058 <proc+0x158>
    800022fe:	00013917          	auipc	s2,0x13
    80002302:	75a90913          	addi	s2,s2,1882 # 80015a58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002306:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002308:	00005997          	auipc	s3,0x5
    8000230c:	01898993          	addi	s3,s3,24 # 80007320 <digits+0x2e8>
    printf("%d %s %s", p->pid, state, p->name);
    80002310:	00005a97          	auipc	s5,0x5
    80002314:	018a8a93          	addi	s5,s5,24 # 80007328 <digits+0x2f0>
    printf("\n");
    80002318:	00005a17          	auipc	s4,0x5
    8000231c:	da8a0a13          	addi	s4,s4,-600 # 800070c0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002320:	00005b97          	auipc	s7,0x5
    80002324:	048b8b93          	addi	s7,s7,72 # 80007368 <states.2241>
    80002328:	a829                	j	80002342 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000232a:	ed86a583          	lw	a1,-296(a3)
    8000232e:	8556                	mv	a0,s5
    80002330:	978fe0ef          	jal	ra,800004a8 <printf>
    printf("\n");
    80002334:	8552                	mv	a0,s4
    80002336:	972fe0ef          	jal	ra,800004a8 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000233a:	16848493          	addi	s1,s1,360
    8000233e:	03248163          	beq	s1,s2,80002360 <procdump+0x8c>
    if(p->state == UNUSED)
    80002342:	86a6                	mv	a3,s1
    80002344:	ec04a783          	lw	a5,-320(s1)
    80002348:	dbed                	beqz	a5,8000233a <procdump+0x66>
      state = "???";
    8000234a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000234c:	fcfb6fe3          	bltu	s6,a5,8000232a <procdump+0x56>
    80002350:	1782                	slli	a5,a5,0x20
    80002352:	9381                	srli	a5,a5,0x20
    80002354:	078e                	slli	a5,a5,0x3
    80002356:	97de                	add	a5,a5,s7
    80002358:	6390                	ld	a2,0(a5)
    8000235a:	fa61                	bnez	a2,8000232a <procdump+0x56>
      state = "???";
    8000235c:	864e                	mv	a2,s3
    8000235e:	b7f1                	j	8000232a <procdump+0x56>
  }
}
    80002360:	60a6                	ld	ra,72(sp)
    80002362:	6406                	ld	s0,64(sp)
    80002364:	74e2                	ld	s1,56(sp)
    80002366:	7942                	ld	s2,48(sp)
    80002368:	79a2                	ld	s3,40(sp)
    8000236a:	7a02                	ld	s4,32(sp)
    8000236c:	6ae2                	ld	s5,24(sp)
    8000236e:	6b42                	ld	s6,16(sp)
    80002370:	6ba2                	ld	s7,8(sp)
    80002372:	6161                	addi	sp,sp,80
    80002374:	8082                	ret

0000000080002376 <swtch>:
    80002376:	00153023          	sd	ra,0(a0)
    8000237a:	00253423          	sd	sp,8(a0)
    8000237e:	e900                	sd	s0,16(a0)
    80002380:	ed04                	sd	s1,24(a0)
    80002382:	03253023          	sd	s2,32(a0)
    80002386:	03353423          	sd	s3,40(a0)
    8000238a:	03453823          	sd	s4,48(a0)
    8000238e:	03553c23          	sd	s5,56(a0)
    80002392:	05653023          	sd	s6,64(a0)
    80002396:	05753423          	sd	s7,72(a0)
    8000239a:	05853823          	sd	s8,80(a0)
    8000239e:	05953c23          	sd	s9,88(a0)
    800023a2:	07a53023          	sd	s10,96(a0)
    800023a6:	07b53423          	sd	s11,104(a0)
    800023aa:	0005b083          	ld	ra,0(a1)
    800023ae:	0085b103          	ld	sp,8(a1)
    800023b2:	6980                	ld	s0,16(a1)
    800023b4:	6d84                	ld	s1,24(a1)
    800023b6:	0205b903          	ld	s2,32(a1)
    800023ba:	0285b983          	ld	s3,40(a1)
    800023be:	0305ba03          	ld	s4,48(a1)
    800023c2:	0385ba83          	ld	s5,56(a1)
    800023c6:	0405bb03          	ld	s6,64(a1)
    800023ca:	0485bb83          	ld	s7,72(a1)
    800023ce:	0505bc03          	ld	s8,80(a1)
    800023d2:	0585bc83          	ld	s9,88(a1)
    800023d6:	0605bd03          	ld	s10,96(a1)
    800023da:	0685bd83          	ld	s11,104(a1)
    800023de:	8082                	ret

00000000800023e0 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023e0:	1141                	addi	sp,sp,-16
    800023e2:	e406                	sd	ra,8(sp)
    800023e4:	e022                	sd	s0,0(sp)
    800023e6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023e8:	00005597          	auipc	a1,0x5
    800023ec:	fb058593          	addi	a1,a1,-80 # 80007398 <states.2241+0x30>
    800023f0:	00013517          	auipc	a0,0x13
    800023f4:	51050513          	addi	a0,a0,1296 # 80015900 <tickslock>
    800023f8:	f30fe0ef          	jal	ra,80000b28 <initlock>
}
    800023fc:	60a2                	ld	ra,8(sp)
    800023fe:	6402                	ld	s0,0(sp)
    80002400:	0141                	addi	sp,sp,16
    80002402:	8082                	ret

0000000080002404 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002404:	1141                	addi	sp,sp,-16
    80002406:	e422                	sd	s0,8(sp)
    80002408:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000240a:	00003797          	auipc	a5,0x3
    8000240e:	e2678793          	addi	a5,a5,-474 # 80005230 <kernelvec>
    80002412:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002416:	6422                	ld	s0,8(sp)
    80002418:	0141                	addi	sp,sp,16
    8000241a:	8082                	ret

000000008000241c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000241c:	1141                	addi	sp,sp,-16
    8000241e:	e406                	sd	ra,8(sp)
    80002420:	e022                	sd	s0,0(sp)
    80002422:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002424:	cf8ff0ef          	jal	ra,8000191c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002428:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000242c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000242e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002432:	00004617          	auipc	a2,0x4
    80002436:	bce60613          	addi	a2,a2,-1074 # 80006000 <_trampoline>
    8000243a:	00004697          	auipc	a3,0x4
    8000243e:	bc668693          	addi	a3,a3,-1082 # 80006000 <_trampoline>
    80002442:	8e91                	sub	a3,a3,a2
    80002444:	040007b7          	lui	a5,0x4000
    80002448:	17fd                	addi	a5,a5,-1
    8000244a:	07b2                	slli	a5,a5,0xc
    8000244c:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000244e:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002452:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002454:	180026f3          	csrr	a3,satp
    80002458:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000245a:	6d38                	ld	a4,88(a0)
    8000245c:	6134                	ld	a3,64(a0)
    8000245e:	6585                	lui	a1,0x1
    80002460:	96ae                	add	a3,a3,a1
    80002462:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002464:	6d38                	ld	a4,88(a0)
    80002466:	00000697          	auipc	a3,0x0
    8000246a:	10c68693          	addi	a3,a3,268 # 80002572 <usertrap>
    8000246e:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002470:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002472:	8692                	mv	a3,tp
    80002474:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002476:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000247a:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000247e:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002482:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002486:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002488:	6f18                	ld	a4,24(a4)
    8000248a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000248e:	6928                	ld	a0,80(a0)
    80002490:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002492:	00004717          	auipc	a4,0x4
    80002496:	c0a70713          	addi	a4,a4,-1014 # 8000609c <userret>
    8000249a:	8f11                	sub	a4,a4,a2
    8000249c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000249e:	577d                	li	a4,-1
    800024a0:	177e                	slli	a4,a4,0x3f
    800024a2:	8d59                	or	a0,a0,a4
    800024a4:	9782                	jalr	a5
}
    800024a6:	60a2                	ld	ra,8(sp)
    800024a8:	6402                	ld	s0,0(sp)
    800024aa:	0141                	addi	sp,sp,16
    800024ac:	8082                	ret

00000000800024ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024ae:	1101                	addi	sp,sp,-32
    800024b0:	ec06                	sd	ra,24(sp)
    800024b2:	e822                	sd	s0,16(sp)
    800024b4:	e426                	sd	s1,8(sp)
    800024b6:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800024b8:	c38ff0ef          	jal	ra,800018f0 <cpuid>
    800024bc:	cd19                	beqz	a0,800024da <clockintr+0x2c>
  asm volatile("csrr %0, time" : "=r" (x) );
    800024be:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024c2:	000f4737          	lui	a4,0xf4
    800024c6:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024ca:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800024cc:	14d79073          	csrw	0x14d,a5
}
    800024d0:	60e2                	ld	ra,24(sp)
    800024d2:	6442                	ld	s0,16(sp)
    800024d4:	64a2                	ld	s1,8(sp)
    800024d6:	6105                	addi	sp,sp,32
    800024d8:	8082                	ret
    acquire(&tickslock);
    800024da:	00013497          	auipc	s1,0x13
    800024de:	42648493          	addi	s1,s1,1062 # 80015900 <tickslock>
    800024e2:	8526                	mv	a0,s1
    800024e4:	ec4fe0ef          	jal	ra,80000ba8 <acquire>
    ticks++;
    800024e8:	00005517          	auipc	a0,0x5
    800024ec:	4b850513          	addi	a0,a0,1208 # 800079a0 <ticks>
    800024f0:	411c                	lw	a5,0(a0)
    800024f2:	2785                	addiw	a5,a5,1
    800024f4:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024f6:	a3bff0ef          	jal	ra,80001f30 <wakeup>
    release(&tickslock);
    800024fa:	8526                	mv	a0,s1
    800024fc:	f44fe0ef          	jal	ra,80000c40 <release>
    80002500:	bf7d                	j	800024be <clockintr+0x10>

0000000080002502 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002502:	1101                	addi	sp,sp,-32
    80002504:	ec06                	sd	ra,24(sp)
    80002506:	e822                	sd	s0,16(sp)
    80002508:	e426                	sd	s1,8(sp)
    8000250a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000250c:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002510:	57fd                	li	a5,-1
    80002512:	17fe                	slli	a5,a5,0x3f
    80002514:	07a5                	addi	a5,a5,9
    80002516:	00f70d63          	beq	a4,a5,80002530 <devintr+0x2e>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000251a:	57fd                	li	a5,-1
    8000251c:	17fe                	slli	a5,a5,0x3f
    8000251e:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002520:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002522:	04f70463          	beq	a4,a5,8000256a <devintr+0x68>
  }
}
    80002526:	60e2                	ld	ra,24(sp)
    80002528:	6442                	ld	s0,16(sp)
    8000252a:	64a2                	ld	s1,8(sp)
    8000252c:	6105                	addi	sp,sp,32
    8000252e:	8082                	ret
    int irq = plic_claim();
    80002530:	5a9020ef          	jal	ra,800052d8 <plic_claim>
    80002534:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002536:	47a9                	li	a5,10
    80002538:	02f50363          	beq	a0,a5,8000255e <devintr+0x5c>
    } else if(irq == VIRTIO0_IRQ){
    8000253c:	4785                	li	a5,1
    8000253e:	02f50363          	beq	a0,a5,80002564 <devintr+0x62>
    return 1;
    80002542:	4505                	li	a0,1
    } else if(irq){
    80002544:	d0ed                	beqz	s1,80002526 <devintr+0x24>
      printf("unexpected interrupt irq=%d\n", irq);
    80002546:	85a6                	mv	a1,s1
    80002548:	00005517          	auipc	a0,0x5
    8000254c:	e5850513          	addi	a0,a0,-424 # 800073a0 <states.2241+0x38>
    80002550:	f59fd0ef          	jal	ra,800004a8 <printf>
      plic_complete(irq);
    80002554:	8526                	mv	a0,s1
    80002556:	5a3020ef          	jal	ra,800052f8 <plic_complete>
    return 1;
    8000255a:	4505                	li	a0,1
    8000255c:	b7e9                	j	80002526 <devintr+0x24>
      uartintr();
    8000255e:	c5efe0ef          	jal	ra,800009bc <uartintr>
    80002562:	bfcd                	j	80002554 <devintr+0x52>
      virtio_disk_intr();
    80002564:	25a030ef          	jal	ra,800057be <virtio_disk_intr>
    80002568:	b7f5                	j	80002554 <devintr+0x52>
    clockintr();
    8000256a:	f45ff0ef          	jal	ra,800024ae <clockintr>
    return 2;
    8000256e:	4509                	li	a0,2
    80002570:	bf5d                	j	80002526 <devintr+0x24>

0000000080002572 <usertrap>:
{
    80002572:	1101                	addi	sp,sp,-32
    80002574:	ec06                	sd	ra,24(sp)
    80002576:	e822                	sd	s0,16(sp)
    80002578:	e426                	sd	s1,8(sp)
    8000257a:	e04a                	sd	s2,0(sp)
    8000257c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000257e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002582:	1007f793          	andi	a5,a5,256
    80002586:	ef85                	bnez	a5,800025be <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002588:	00003797          	auipc	a5,0x3
    8000258c:	ca878793          	addi	a5,a5,-856 # 80005230 <kernelvec>
    80002590:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002594:	b88ff0ef          	jal	ra,8000191c <myproc>
    80002598:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000259a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000259c:	14102773          	csrr	a4,sepc
    800025a0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025a2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025a6:	47a1                	li	a5,8
    800025a8:	02f70163          	beq	a4,a5,800025ca <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025ac:	f57ff0ef          	jal	ra,80002502 <devintr>
    800025b0:	892a                	mv	s2,a0
    800025b2:	c135                	beqz	a0,80002616 <usertrap+0xa4>
  if(killed(p))
    800025b4:	8526                	mv	a0,s1
    800025b6:	b67ff0ef          	jal	ra,8000211c <killed>
    800025ba:	cd1d                	beqz	a0,800025f8 <usertrap+0x86>
    800025bc:	a81d                	j	800025f2 <usertrap+0x80>
    panic("usertrap: not from user mode");
    800025be:	00005517          	auipc	a0,0x5
    800025c2:	e0250513          	addi	a0,a0,-510 # 800073c0 <states.2241+0x58>
    800025c6:	996fe0ef          	jal	ra,8000075c <panic>
    if(killed(p))
    800025ca:	b53ff0ef          	jal	ra,8000211c <killed>
    800025ce:	e121                	bnez	a0,8000260e <usertrap+0x9c>
    p->trapframe->epc += 4;
    800025d0:	6cb8                	ld	a4,88(s1)
    800025d2:	6f1c                	ld	a5,24(a4)
    800025d4:	0791                	addi	a5,a5,4
    800025d6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025d8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025dc:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025e0:	10079073          	csrw	sstatus,a5
    syscall();
    800025e4:	248000ef          	jal	ra,8000282c <syscall>
  if(killed(p))
    800025e8:	8526                	mv	a0,s1
    800025ea:	b33ff0ef          	jal	ra,8000211c <killed>
    800025ee:	c901                	beqz	a0,800025fe <usertrap+0x8c>
    800025f0:	4901                	li	s2,0
    exit(-1);
    800025f2:	557d                	li	a0,-1
    800025f4:	9fdff0ef          	jal	ra,80001ff0 <exit>
  if(which_dev == 2)
    800025f8:	4789                	li	a5,2
    800025fa:	04f90563          	beq	s2,a5,80002644 <usertrap+0xd2>
  usertrapret();
    800025fe:	e1fff0ef          	jal	ra,8000241c <usertrapret>
}
    80002602:	60e2                	ld	ra,24(sp)
    80002604:	6442                	ld	s0,16(sp)
    80002606:	64a2                	ld	s1,8(sp)
    80002608:	6902                	ld	s2,0(sp)
    8000260a:	6105                	addi	sp,sp,32
    8000260c:	8082                	ret
      exit(-1);
    8000260e:	557d                	li	a0,-1
    80002610:	9e1ff0ef          	jal	ra,80001ff0 <exit>
    80002614:	bf75                	j	800025d0 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002616:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000261a:	5890                	lw	a2,48(s1)
    8000261c:	00005517          	auipc	a0,0x5
    80002620:	dc450513          	addi	a0,a0,-572 # 800073e0 <states.2241+0x78>
    80002624:	e85fd0ef          	jal	ra,800004a8 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002628:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000262c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002630:	00005517          	auipc	a0,0x5
    80002634:	de050513          	addi	a0,a0,-544 # 80007410 <states.2241+0xa8>
    80002638:	e71fd0ef          	jal	ra,800004a8 <printf>
    setkilled(p);
    8000263c:	8526                	mv	a0,s1
    8000263e:	abbff0ef          	jal	ra,800020f8 <setkilled>
    80002642:	b75d                	j	800025e8 <usertrap+0x76>
    yield();
    80002644:	875ff0ef          	jal	ra,80001eb8 <yield>
    80002648:	bf5d                	j	800025fe <usertrap+0x8c>

000000008000264a <kerneltrap>:
{
    8000264a:	7179                	addi	sp,sp,-48
    8000264c:	f406                	sd	ra,40(sp)
    8000264e:	f022                	sd	s0,32(sp)
    80002650:	ec26                	sd	s1,24(sp)
    80002652:	e84a                	sd	s2,16(sp)
    80002654:	e44e                	sd	s3,8(sp)
    80002656:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002658:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000265c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002660:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002664:	1004f793          	andi	a5,s1,256
    80002668:	c795                	beqz	a5,80002694 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000266e:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002670:	eb85                	bnez	a5,800026a0 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002672:	e91ff0ef          	jal	ra,80002502 <devintr>
    80002676:	c91d                	beqz	a0,800026ac <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002678:	4789                	li	a5,2
    8000267a:	04f50a63          	beq	a0,a5,800026ce <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000267e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002682:	10049073          	csrw	sstatus,s1
}
    80002686:	70a2                	ld	ra,40(sp)
    80002688:	7402                	ld	s0,32(sp)
    8000268a:	64e2                	ld	s1,24(sp)
    8000268c:	6942                	ld	s2,16(sp)
    8000268e:	69a2                	ld	s3,8(sp)
    80002690:	6145                	addi	sp,sp,48
    80002692:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002694:	00005517          	auipc	a0,0x5
    80002698:	da450513          	addi	a0,a0,-604 # 80007438 <states.2241+0xd0>
    8000269c:	8c0fe0ef          	jal	ra,8000075c <panic>
    panic("kerneltrap: interrupts enabled");
    800026a0:	00005517          	auipc	a0,0x5
    800026a4:	dc050513          	addi	a0,a0,-576 # 80007460 <states.2241+0xf8>
    800026a8:	8b4fe0ef          	jal	ra,8000075c <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026ac:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026b0:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    800026b4:	85ce                	mv	a1,s3
    800026b6:	00005517          	auipc	a0,0x5
    800026ba:	dca50513          	addi	a0,a0,-566 # 80007480 <states.2241+0x118>
    800026be:	debfd0ef          	jal	ra,800004a8 <printf>
    panic("kerneltrap");
    800026c2:	00005517          	auipc	a0,0x5
    800026c6:	de650513          	addi	a0,a0,-538 # 800074a8 <states.2241+0x140>
    800026ca:	892fe0ef          	jal	ra,8000075c <panic>
  if(which_dev == 2 && myproc() != 0)
    800026ce:	a4eff0ef          	jal	ra,8000191c <myproc>
    800026d2:	d555                	beqz	a0,8000267e <kerneltrap+0x34>
    yield();
    800026d4:	fe4ff0ef          	jal	ra,80001eb8 <yield>
    800026d8:	b75d                	j	8000267e <kerneltrap+0x34>

00000000800026da <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026da:	1101                	addi	sp,sp,-32
    800026dc:	ec06                	sd	ra,24(sp)
    800026de:	e822                	sd	s0,16(sp)
    800026e0:	e426                	sd	s1,8(sp)
    800026e2:	1000                	addi	s0,sp,32
    800026e4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800026e6:	a36ff0ef          	jal	ra,8000191c <myproc>
  switch (n) {
    800026ea:	4795                	li	a5,5
    800026ec:	0497e163          	bltu	a5,s1,8000272e <argraw+0x54>
    800026f0:	048a                	slli	s1,s1,0x2
    800026f2:	00005717          	auipc	a4,0x5
    800026f6:	dee70713          	addi	a4,a4,-530 # 800074e0 <states.2241+0x178>
    800026fa:	94ba                	add	s1,s1,a4
    800026fc:	409c                	lw	a5,0(s1)
    800026fe:	97ba                	add	a5,a5,a4
    80002700:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002702:	6d3c                	ld	a5,88(a0)
    80002704:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002706:	60e2                	ld	ra,24(sp)
    80002708:	6442                	ld	s0,16(sp)
    8000270a:	64a2                	ld	s1,8(sp)
    8000270c:	6105                	addi	sp,sp,32
    8000270e:	8082                	ret
    return p->trapframe->a1;
    80002710:	6d3c                	ld	a5,88(a0)
    80002712:	7fa8                	ld	a0,120(a5)
    80002714:	bfcd                	j	80002706 <argraw+0x2c>
    return p->trapframe->a2;
    80002716:	6d3c                	ld	a5,88(a0)
    80002718:	63c8                	ld	a0,128(a5)
    8000271a:	b7f5                	j	80002706 <argraw+0x2c>
    return p->trapframe->a3;
    8000271c:	6d3c                	ld	a5,88(a0)
    8000271e:	67c8                	ld	a0,136(a5)
    80002720:	b7dd                	j	80002706 <argraw+0x2c>
    return p->trapframe->a4;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	6bc8                	ld	a0,144(a5)
    80002726:	b7c5                	j	80002706 <argraw+0x2c>
    return p->trapframe->a5;
    80002728:	6d3c                	ld	a5,88(a0)
    8000272a:	6fc8                	ld	a0,152(a5)
    8000272c:	bfe9                	j	80002706 <argraw+0x2c>
  panic("argraw");
    8000272e:	00005517          	auipc	a0,0x5
    80002732:	d8a50513          	addi	a0,a0,-630 # 800074b8 <states.2241+0x150>
    80002736:	826fe0ef          	jal	ra,8000075c <panic>

000000008000273a <fetchaddr>:
{
    8000273a:	1101                	addi	sp,sp,-32
    8000273c:	ec06                	sd	ra,24(sp)
    8000273e:	e822                	sd	s0,16(sp)
    80002740:	e426                	sd	s1,8(sp)
    80002742:	e04a                	sd	s2,0(sp)
    80002744:	1000                	addi	s0,sp,32
    80002746:	84aa                	mv	s1,a0
    80002748:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000274a:	9d2ff0ef          	jal	ra,8000191c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000274e:	653c                	ld	a5,72(a0)
    80002750:	02f4f663          	bgeu	s1,a5,8000277c <fetchaddr+0x42>
    80002754:	00848713          	addi	a4,s1,8
    80002758:	02e7e463          	bltu	a5,a4,80002780 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000275c:	46a1                	li	a3,8
    8000275e:	8626                	mv	a2,s1
    80002760:	85ca                	mv	a1,s2
    80002762:	6928                	ld	a0,80(a0)
    80002764:	e4bfe0ef          	jal	ra,800015ae <copyin>
    80002768:	00a03533          	snez	a0,a0
    8000276c:	40a00533          	neg	a0,a0
}
    80002770:	60e2                	ld	ra,24(sp)
    80002772:	6442                	ld	s0,16(sp)
    80002774:	64a2                	ld	s1,8(sp)
    80002776:	6902                	ld	s2,0(sp)
    80002778:	6105                	addi	sp,sp,32
    8000277a:	8082                	ret
    return -1;
    8000277c:	557d                	li	a0,-1
    8000277e:	bfcd                	j	80002770 <fetchaddr+0x36>
    80002780:	557d                	li	a0,-1
    80002782:	b7fd                	j	80002770 <fetchaddr+0x36>

0000000080002784 <fetchstr>:
{
    80002784:	7179                	addi	sp,sp,-48
    80002786:	f406                	sd	ra,40(sp)
    80002788:	f022                	sd	s0,32(sp)
    8000278a:	ec26                	sd	s1,24(sp)
    8000278c:	e84a                	sd	s2,16(sp)
    8000278e:	e44e                	sd	s3,8(sp)
    80002790:	1800                	addi	s0,sp,48
    80002792:	892a                	mv	s2,a0
    80002794:	84ae                	mv	s1,a1
    80002796:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002798:	984ff0ef          	jal	ra,8000191c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000279c:	86ce                	mv	a3,s3
    8000279e:	864a                	mv	a2,s2
    800027a0:	85a6                	mv	a1,s1
    800027a2:	6928                	ld	a0,80(a0)
    800027a4:	e8ffe0ef          	jal	ra,80001632 <copyinstr>
    800027a8:	00054c63          	bltz	a0,800027c0 <fetchstr+0x3c>
  return strlen(buf);
    800027ac:	8526                	mv	a0,s1
    800027ae:	e4efe0ef          	jal	ra,80000dfc <strlen>
}
    800027b2:	70a2                	ld	ra,40(sp)
    800027b4:	7402                	ld	s0,32(sp)
    800027b6:	64e2                	ld	s1,24(sp)
    800027b8:	6942                	ld	s2,16(sp)
    800027ba:	69a2                	ld	s3,8(sp)
    800027bc:	6145                	addi	sp,sp,48
    800027be:	8082                	ret
    return -1;
    800027c0:	557d                	li	a0,-1
    800027c2:	bfc5                	j	800027b2 <fetchstr+0x2e>

00000000800027c4 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027c4:	1101                	addi	sp,sp,-32
    800027c6:	ec06                	sd	ra,24(sp)
    800027c8:	e822                	sd	s0,16(sp)
    800027ca:	e426                	sd	s1,8(sp)
    800027cc:	1000                	addi	s0,sp,32
    800027ce:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027d0:	f0bff0ef          	jal	ra,800026da <argraw>
    800027d4:	c088                	sw	a0,0(s1)
}
    800027d6:	60e2                	ld	ra,24(sp)
    800027d8:	6442                	ld	s0,16(sp)
    800027da:	64a2                	ld	s1,8(sp)
    800027dc:	6105                	addi	sp,sp,32
    800027de:	8082                	ret

00000000800027e0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800027e0:	1101                	addi	sp,sp,-32
    800027e2:	ec06                	sd	ra,24(sp)
    800027e4:	e822                	sd	s0,16(sp)
    800027e6:	e426                	sd	s1,8(sp)
    800027e8:	1000                	addi	s0,sp,32
    800027ea:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027ec:	eefff0ef          	jal	ra,800026da <argraw>
    800027f0:	e088                	sd	a0,0(s1)
}
    800027f2:	60e2                	ld	ra,24(sp)
    800027f4:	6442                	ld	s0,16(sp)
    800027f6:	64a2                	ld	s1,8(sp)
    800027f8:	6105                	addi	sp,sp,32
    800027fa:	8082                	ret

00000000800027fc <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800027fc:	7179                	addi	sp,sp,-48
    800027fe:	f406                	sd	ra,40(sp)
    80002800:	f022                	sd	s0,32(sp)
    80002802:	ec26                	sd	s1,24(sp)
    80002804:	e84a                	sd	s2,16(sp)
    80002806:	1800                	addi	s0,sp,48
    80002808:	84ae                	mv	s1,a1
    8000280a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000280c:	fd840593          	addi	a1,s0,-40
    80002810:	fd1ff0ef          	jal	ra,800027e0 <argaddr>
  return fetchstr(addr, buf, max);
    80002814:	864a                	mv	a2,s2
    80002816:	85a6                	mv	a1,s1
    80002818:	fd843503          	ld	a0,-40(s0)
    8000281c:	f69ff0ef          	jal	ra,80002784 <fetchstr>
}
    80002820:	70a2                	ld	ra,40(sp)
    80002822:	7402                	ld	s0,32(sp)
    80002824:	64e2                	ld	s1,24(sp)
    80002826:	6942                	ld	s2,16(sp)
    80002828:	6145                	addi	sp,sp,48
    8000282a:	8082                	ret

000000008000282c <syscall>:

};

void
syscall(void)
{
    8000282c:	1101                	addi	sp,sp,-32
    8000282e:	ec06                	sd	ra,24(sp)
    80002830:	e822                	sd	s0,16(sp)
    80002832:	e426                	sd	s1,8(sp)
    80002834:	e04a                	sd	s2,0(sp)
    80002836:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002838:	8e4ff0ef          	jal	ra,8000191c <myproc>
    8000283c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000283e:	05853903          	ld	s2,88(a0)
    80002842:	0a893783          	ld	a5,168(s2)
    80002846:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000284a:	37fd                	addiw	a5,a5,-1
    8000284c:	4759                	li	a4,22
    8000284e:	00f76f63          	bltu	a4,a5,8000286c <syscall+0x40>
    80002852:	00369713          	slli	a4,a3,0x3
    80002856:	00005797          	auipc	a5,0x5
    8000285a:	ca278793          	addi	a5,a5,-862 # 800074f8 <syscalls>
    8000285e:	97ba                	add	a5,a5,a4
    80002860:	639c                	ld	a5,0(a5)
    80002862:	c789                	beqz	a5,8000286c <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002864:	9782                	jalr	a5
    80002866:	06a93823          	sd	a0,112(s2)
    8000286a:	a829                	j	80002884 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000286c:	15848613          	addi	a2,s1,344
    80002870:	588c                	lw	a1,48(s1)
    80002872:	00005517          	auipc	a0,0x5
    80002876:	c4e50513          	addi	a0,a0,-946 # 800074c0 <states.2241+0x158>
    8000287a:	c2ffd0ef          	jal	ra,800004a8 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000287e:	6cbc                	ld	a5,88(s1)
    80002880:	577d                	li	a4,-1
    80002882:	fbb8                	sd	a4,112(a5)
  }
}
    80002884:	60e2                	ld	ra,24(sp)
    80002886:	6442                	ld	s0,16(sp)
    80002888:	64a2                	ld	s1,8(sp)
    8000288a:	6902                	ld	s2,0(sp)
    8000288c:	6105                	addi	sp,sp,32
    8000288e:	8082                	ret

0000000080002890 <sys_ugetpid>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_ugetpid(void)
{
    80002890:	1141                	addi	sp,sp,-16
    80002892:	e406                	sd	ra,8(sp)
    80002894:	e022                	sd	s0,0(sp)
    80002896:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002898:	884ff0ef          	jal	ra,8000191c <myproc>
}
    8000289c:	5908                	lw	a0,48(a0)
    8000289e:	60a2                	ld	ra,8(sp)
    800028a0:	6402                	ld	s0,0(sp)
    800028a2:	0141                	addi	sp,sp,16
    800028a4:	8082                	ret

00000000800028a6 <sys_pgaccess>:

uint64
sys_pgaccess(void)
{
    800028a6:	711d                	addi	sp,sp,-96
    800028a8:	ec86                	sd	ra,88(sp)
    800028aa:	e8a2                	sd	s0,80(sp)
    800028ac:	e4a6                	sd	s1,72(sp)
    800028ae:	e0ca                	sd	s2,64(sp)
    800028b0:	fc4e                	sd	s3,56(sp)
    800028b2:	f852                	sd	s4,48(sp)
    800028b4:	f456                	sd	s5,40(sp)
    800028b6:	1080                	addi	s0,sp,96
    uint64 base;
    int len;
    uint64 mask_addr;
    argaddr(0, &base);
    800028b8:	fb840593          	addi	a1,s0,-72
    800028bc:	4501                	li	a0,0
    800028be:	f23ff0ef          	jal	ra,800027e0 <argaddr>
    argint(1, &len);
    800028c2:	fb440593          	addi	a1,s0,-76
    800028c6:	4505                	li	a0,1
    800028c8:	efdff0ef          	jal	ra,800027c4 <argint>
    argaddr(2, &mask_addr);
    800028cc:	fa840593          	addi	a1,s0,-88
    800028d0:	4509                	li	a0,2
    800028d2:	f0fff0ef          	jal	ra,800027e0 <argaddr>
    if(len < 0 || len > 64)
    800028d6:	fb442703          	lw	a4,-76(s0)
    800028da:	04000793          	li	a5,64
        return -1;   
    800028de:	557d                	li	a0,-1
    if(len < 0 || len > 64)
    800028e0:	06e7ef63          	bltu	a5,a4,8000295e <sys_pgaccess+0xb8>
    struct proc *p = myproc();
    800028e4:	838ff0ef          	jal	ra,8000191c <myproc>
    pagetable_t pagetable = p->pagetable;
    800028e8:	05053903          	ld	s2,80(a0)
    uint64 mask = 0;
    800028ec:	fa043023          	sd	zero,-96(s0)
    for(int i = 0; i < len; i++) {
    800028f0:	fb442783          	lw	a5,-76(s0)
    800028f4:	04f05c63          	blez	a5,8000294c <sys_pgaccess+0xa6>
    800028f8:	4481                	li	s1,0
        pte_t *pte = walk(pagetable, va, 0);
        if(pte == 0)
            continue;
        if((*pte & PTE_V) == 0)
            continue;
        if(*pte & PTE_A) {
    800028fa:	04100993          	li	s3,65
            mask |= (1L << i);
    800028fe:	4a05                	li	s4,1
    80002900:	a801                	j	80002910 <sys_pgaccess+0x6a>
    for(int i = 0; i < len; i++) {
    80002902:	0485                	addi	s1,s1,1
    80002904:	fb442703          	lw	a4,-76(s0)
    80002908:	0004879b          	sext.w	a5,s1
    8000290c:	04e7d063          	bge	a5,a4,8000294c <sys_pgaccess+0xa6>
    80002910:	00048a9b          	sext.w	s5,s1
        uint64 va = base + i * PGSIZE;
    80002914:	00c49593          	slli	a1,s1,0xc
        pte_t *pte = walk(pagetable, va, 0);
    80002918:	4601                	li	a2,0
    8000291a:	fb843783          	ld	a5,-72(s0)
    8000291e:	95be                	add	a1,a1,a5
    80002920:	854a                	mv	a0,s2
    80002922:	ddefe0ef          	jal	ra,80000f00 <walk>
        if(pte == 0)
    80002926:	dd71                	beqz	a0,80002902 <sys_pgaccess+0x5c>
        if(*pte & PTE_A) {
    80002928:	611c                	ld	a5,0(a0)
    8000292a:	0417f793          	andi	a5,a5,65
    8000292e:	fd379ae3          	bne	a5,s3,80002902 <sys_pgaccess+0x5c>
            mask |= (1L << i);
    80002932:	015a1ab3          	sll	s5,s4,s5
    80002936:	fa043783          	ld	a5,-96(s0)
    8000293a:	0157eab3          	or	s5,a5,s5
    8000293e:	fb543023          	sd	s5,-96(s0)
            *pte &= ~PTE_A;
    80002942:	611c                	ld	a5,0(a0)
    80002944:	fbf7f793          	andi	a5,a5,-65
    80002948:	e11c                	sd	a5,0(a0)
    8000294a:	bf65                	j	80002902 <sys_pgaccess+0x5c>
        }
    }
    if(copyout(pagetable, mask_addr, (char*)&mask, sizeof(mask)) < 0)
    8000294c:	46a1                	li	a3,8
    8000294e:	fa040613          	addi	a2,s0,-96
    80002952:	fa843583          	ld	a1,-88(s0)
    80002956:	854a                	mv	a0,s2
    80002958:	b9ffe0ef          	jal	ra,800014f6 <copyout>
    8000295c:	957d                	srai	a0,a0,0x3f
        return -1;
    return 0;
}
    8000295e:	60e6                	ld	ra,88(sp)
    80002960:	6446                	ld	s0,80(sp)
    80002962:	64a6                	ld	s1,72(sp)
    80002964:	6906                	ld	s2,64(sp)
    80002966:	79e2                	ld	s3,56(sp)
    80002968:	7a42                	ld	s4,48(sp)
    8000296a:	7aa2                	ld	s5,40(sp)
    8000296c:	6125                	addi	sp,sp,96
    8000296e:	8082                	ret

0000000080002970 <sys_exit>:

uint64
sys_exit(void)
{
    80002970:	1101                	addi	sp,sp,-32
    80002972:	ec06                	sd	ra,24(sp)
    80002974:	e822                	sd	s0,16(sp)
    80002976:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002978:	fec40593          	addi	a1,s0,-20
    8000297c:	4501                	li	a0,0
    8000297e:	e47ff0ef          	jal	ra,800027c4 <argint>
  exit(n);
    80002982:	fec42503          	lw	a0,-20(s0)
    80002986:	e6aff0ef          	jal	ra,80001ff0 <exit>
  return 0;  // not reached
}
    8000298a:	4501                	li	a0,0
    8000298c:	60e2                	ld	ra,24(sp)
    8000298e:	6442                	ld	s0,16(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret

0000000080002994 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002994:	1141                	addi	sp,sp,-16
    80002996:	e406                	sd	ra,8(sp)
    80002998:	e022                	sd	s0,0(sp)
    8000299a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000299c:	f81fe0ef          	jal	ra,8000191c <myproc>
}
    800029a0:	5908                	lw	a0,48(a0)
    800029a2:	60a2                	ld	ra,8(sp)
    800029a4:	6402                	ld	s0,0(sp)
    800029a6:	0141                	addi	sp,sp,16
    800029a8:	8082                	ret

00000000800029aa <sys_fork>:

uint64
sys_fork(void)
{
    800029aa:	1141                	addi	sp,sp,-16
    800029ac:	e406                	sd	ra,8(sp)
    800029ae:	e022                	sd	s0,0(sp)
    800029b0:	0800                	addi	s0,sp,16
  return fork();
    800029b2:	a90ff0ef          	jal	ra,80001c42 <fork>
}
    800029b6:	60a2                	ld	ra,8(sp)
    800029b8:	6402                	ld	s0,0(sp)
    800029ba:	0141                	addi	sp,sp,16
    800029bc:	8082                	ret

00000000800029be <sys_wait>:

uint64
sys_wait(void)
{
    800029be:	1101                	addi	sp,sp,-32
    800029c0:	ec06                	sd	ra,24(sp)
    800029c2:	e822                	sd	s0,16(sp)
    800029c4:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029c6:	fe840593          	addi	a1,s0,-24
    800029ca:	4501                	li	a0,0
    800029cc:	e15ff0ef          	jal	ra,800027e0 <argaddr>
  return wait(p);
    800029d0:	fe843503          	ld	a0,-24(s0)
    800029d4:	f72ff0ef          	jal	ra,80002146 <wait>
}
    800029d8:	60e2                	ld	ra,24(sp)
    800029da:	6442                	ld	s0,16(sp)
    800029dc:	6105                	addi	sp,sp,32
    800029de:	8082                	ret

00000000800029e0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029e0:	7179                	addi	sp,sp,-48
    800029e2:	f406                	sd	ra,40(sp)
    800029e4:	f022                	sd	s0,32(sp)
    800029e6:	ec26                	sd	s1,24(sp)
    800029e8:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    800029ea:	fdc40593          	addi	a1,s0,-36
    800029ee:	4501                	li	a0,0
    800029f0:	dd5ff0ef          	jal	ra,800027c4 <argint>
  addr = myproc()->sz;
    800029f4:	f29fe0ef          	jal	ra,8000191c <myproc>
    800029f8:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    800029fa:	fdc42503          	lw	a0,-36(s0)
    800029fe:	9f4ff0ef          	jal	ra,80001bf2 <growproc>
    80002a02:	00054863          	bltz	a0,80002a12 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002a06:	8526                	mv	a0,s1
    80002a08:	70a2                	ld	ra,40(sp)
    80002a0a:	7402                	ld	s0,32(sp)
    80002a0c:	64e2                	ld	s1,24(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    return -1;
    80002a12:	54fd                	li	s1,-1
    80002a14:	bfcd                	j	80002a06 <sys_sbrk+0x26>

0000000080002a16 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002a16:	7139                	addi	sp,sp,-64
    80002a18:	fc06                	sd	ra,56(sp)
    80002a1a:	f822                	sd	s0,48(sp)
    80002a1c:	f426                	sd	s1,40(sp)
    80002a1e:	f04a                	sd	s2,32(sp)
    80002a20:	ec4e                	sd	s3,24(sp)
    80002a22:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a24:	fcc40593          	addi	a1,s0,-52
    80002a28:	4501                	li	a0,0
    80002a2a:	d9bff0ef          	jal	ra,800027c4 <argint>
  if(n < 0)
    80002a2e:	fcc42783          	lw	a5,-52(s0)
    80002a32:	0607c563          	bltz	a5,80002a9c <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002a36:	00013517          	auipc	a0,0x13
    80002a3a:	eca50513          	addi	a0,a0,-310 # 80015900 <tickslock>
    80002a3e:	96afe0ef          	jal	ra,80000ba8 <acquire>
  ticks0 = ticks;
    80002a42:	00005917          	auipc	s2,0x5
    80002a46:	f5e92903          	lw	s2,-162(s2) # 800079a0 <ticks>
  while(ticks - ticks0 < n){
    80002a4a:	fcc42783          	lw	a5,-52(s0)
    80002a4e:	cb8d                	beqz	a5,80002a80 <sys_sleep+0x6a>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a50:	00013997          	auipc	s3,0x13
    80002a54:	eb098993          	addi	s3,s3,-336 # 80015900 <tickslock>
    80002a58:	00005497          	auipc	s1,0x5
    80002a5c:	f4848493          	addi	s1,s1,-184 # 800079a0 <ticks>
    if(killed(myproc())){
    80002a60:	ebdfe0ef          	jal	ra,8000191c <myproc>
    80002a64:	eb8ff0ef          	jal	ra,8000211c <killed>
    80002a68:	ed0d                	bnez	a0,80002aa2 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002a6a:	85ce                	mv	a1,s3
    80002a6c:	8526                	mv	a0,s1
    80002a6e:	c76ff0ef          	jal	ra,80001ee4 <sleep>
  while(ticks - ticks0 < n){
    80002a72:	409c                	lw	a5,0(s1)
    80002a74:	412787bb          	subw	a5,a5,s2
    80002a78:	fcc42703          	lw	a4,-52(s0)
    80002a7c:	fee7e2e3          	bltu	a5,a4,80002a60 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002a80:	00013517          	auipc	a0,0x13
    80002a84:	e8050513          	addi	a0,a0,-384 # 80015900 <tickslock>
    80002a88:	9b8fe0ef          	jal	ra,80000c40 <release>
  return 0;
    80002a8c:	4501                	li	a0,0
}
    80002a8e:	70e2                	ld	ra,56(sp)
    80002a90:	7442                	ld	s0,48(sp)
    80002a92:	74a2                	ld	s1,40(sp)
    80002a94:	7902                	ld	s2,32(sp)
    80002a96:	69e2                	ld	s3,24(sp)
    80002a98:	6121                	addi	sp,sp,64
    80002a9a:	8082                	ret
    n = 0;
    80002a9c:	fc042623          	sw	zero,-52(s0)
    80002aa0:	bf59                	j	80002a36 <sys_sleep+0x20>
      release(&tickslock);
    80002aa2:	00013517          	auipc	a0,0x13
    80002aa6:	e5e50513          	addi	a0,a0,-418 # 80015900 <tickslock>
    80002aaa:	996fe0ef          	jal	ra,80000c40 <release>
      return -1;
    80002aae:	557d                	li	a0,-1
    80002ab0:	bff9                	j	80002a8e <sys_sleep+0x78>

0000000080002ab2 <sys_kill>:

uint64
sys_kill(void)
{
    80002ab2:	1101                	addi	sp,sp,-32
    80002ab4:	ec06                	sd	ra,24(sp)
    80002ab6:	e822                	sd	s0,16(sp)
    80002ab8:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002aba:	fec40593          	addi	a1,s0,-20
    80002abe:	4501                	li	a0,0
    80002ac0:	d05ff0ef          	jal	ra,800027c4 <argint>
  return kill(pid);
    80002ac4:	fec42503          	lw	a0,-20(s0)
    80002ac8:	dcaff0ef          	jal	ra,80002092 <kill>
}
    80002acc:	60e2                	ld	ra,24(sp)
    80002ace:	6442                	ld	s0,16(sp)
    80002ad0:	6105                	addi	sp,sp,32
    80002ad2:	8082                	ret

0000000080002ad4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ad4:	1101                	addi	sp,sp,-32
    80002ad6:	ec06                	sd	ra,24(sp)
    80002ad8:	e822                	sd	s0,16(sp)
    80002ada:	e426                	sd	s1,8(sp)
    80002adc:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ade:	00013517          	auipc	a0,0x13
    80002ae2:	e2250513          	addi	a0,a0,-478 # 80015900 <tickslock>
    80002ae6:	8c2fe0ef          	jal	ra,80000ba8 <acquire>
  xticks = ticks;
    80002aea:	00005497          	auipc	s1,0x5
    80002aee:	eb64a483          	lw	s1,-330(s1) # 800079a0 <ticks>
  release(&tickslock);
    80002af2:	00013517          	auipc	a0,0x13
    80002af6:	e0e50513          	addi	a0,a0,-498 # 80015900 <tickslock>
    80002afa:	946fe0ef          	jal	ra,80000c40 <release>
  return xticks;
}
    80002afe:	02049513          	slli	a0,s1,0x20
    80002b02:	9101                	srli	a0,a0,0x20
    80002b04:	60e2                	ld	ra,24(sp)
    80002b06:	6442                	ld	s0,16(sp)
    80002b08:	64a2                	ld	s1,8(sp)
    80002b0a:	6105                	addi	sp,sp,32
    80002b0c:	8082                	ret

0000000080002b0e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b0e:	7179                	addi	sp,sp,-48
    80002b10:	f406                	sd	ra,40(sp)
    80002b12:	f022                	sd	s0,32(sp)
    80002b14:	ec26                	sd	s1,24(sp)
    80002b16:	e84a                	sd	s2,16(sp)
    80002b18:	e44e                	sd	s3,8(sp)
    80002b1a:	e052                	sd	s4,0(sp)
    80002b1c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b1e:	00005597          	auipc	a1,0x5
    80002b22:	a9a58593          	addi	a1,a1,-1382 # 800075b8 <syscalls+0xc0>
    80002b26:	00013517          	auipc	a0,0x13
    80002b2a:	df250513          	addi	a0,a0,-526 # 80015918 <bcache>
    80002b2e:	ffbfd0ef          	jal	ra,80000b28 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b32:	0001b797          	auipc	a5,0x1b
    80002b36:	de678793          	addi	a5,a5,-538 # 8001d918 <bcache+0x8000>
    80002b3a:	0001b717          	auipc	a4,0x1b
    80002b3e:	04670713          	addi	a4,a4,70 # 8001db80 <bcache+0x8268>
    80002b42:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b46:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b4a:	00013497          	auipc	s1,0x13
    80002b4e:	de648493          	addi	s1,s1,-538 # 80015930 <bcache+0x18>
    b->next = bcache.head.next;
    80002b52:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b54:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b56:	00005a17          	auipc	s4,0x5
    80002b5a:	a6aa0a13          	addi	s4,s4,-1430 # 800075c0 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002b5e:	2b893783          	ld	a5,696(s2)
    80002b62:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b64:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b68:	85d2                	mv	a1,s4
    80002b6a:	01048513          	addi	a0,s1,16
    80002b6e:	224010ef          	jal	ra,80003d92 <initsleeplock>
    bcache.head.next->prev = b;
    80002b72:	2b893783          	ld	a5,696(s2)
    80002b76:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b78:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b7c:	45848493          	addi	s1,s1,1112
    80002b80:	fd349fe3          	bne	s1,s3,80002b5e <binit+0x50>
  }
}
    80002b84:	70a2                	ld	ra,40(sp)
    80002b86:	7402                	ld	s0,32(sp)
    80002b88:	64e2                	ld	s1,24(sp)
    80002b8a:	6942                	ld	s2,16(sp)
    80002b8c:	69a2                	ld	s3,8(sp)
    80002b8e:	6a02                	ld	s4,0(sp)
    80002b90:	6145                	addi	sp,sp,48
    80002b92:	8082                	ret

0000000080002b94 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b94:	7179                	addi	sp,sp,-48
    80002b96:	f406                	sd	ra,40(sp)
    80002b98:	f022                	sd	s0,32(sp)
    80002b9a:	ec26                	sd	s1,24(sp)
    80002b9c:	e84a                	sd	s2,16(sp)
    80002b9e:	e44e                	sd	s3,8(sp)
    80002ba0:	1800                	addi	s0,sp,48
    80002ba2:	89aa                	mv	s3,a0
    80002ba4:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002ba6:	00013517          	auipc	a0,0x13
    80002baa:	d7250513          	addi	a0,a0,-654 # 80015918 <bcache>
    80002bae:	ffbfd0ef          	jal	ra,80000ba8 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bb2:	0001b497          	auipc	s1,0x1b
    80002bb6:	01e4b483          	ld	s1,30(s1) # 8001dbd0 <bcache+0x82b8>
    80002bba:	0001b797          	auipc	a5,0x1b
    80002bbe:	fc678793          	addi	a5,a5,-58 # 8001db80 <bcache+0x8268>
    80002bc2:	02f48b63          	beq	s1,a5,80002bf8 <bread+0x64>
    80002bc6:	873e                	mv	a4,a5
    80002bc8:	a021                	j	80002bd0 <bread+0x3c>
    80002bca:	68a4                	ld	s1,80(s1)
    80002bcc:	02e48663          	beq	s1,a4,80002bf8 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002bd0:	449c                	lw	a5,8(s1)
    80002bd2:	ff379ce3          	bne	a5,s3,80002bca <bread+0x36>
    80002bd6:	44dc                	lw	a5,12(s1)
    80002bd8:	ff2799e3          	bne	a5,s2,80002bca <bread+0x36>
      b->refcnt++;
    80002bdc:	40bc                	lw	a5,64(s1)
    80002bde:	2785                	addiw	a5,a5,1
    80002be0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002be2:	00013517          	auipc	a0,0x13
    80002be6:	d3650513          	addi	a0,a0,-714 # 80015918 <bcache>
    80002bea:	856fe0ef          	jal	ra,80000c40 <release>
      acquiresleep(&b->lock);
    80002bee:	01048513          	addi	a0,s1,16
    80002bf2:	1d6010ef          	jal	ra,80003dc8 <acquiresleep>
      return b;
    80002bf6:	a889                	j	80002c48 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bf8:	0001b497          	auipc	s1,0x1b
    80002bfc:	fd04b483          	ld	s1,-48(s1) # 8001dbc8 <bcache+0x82b0>
    80002c00:	0001b797          	auipc	a5,0x1b
    80002c04:	f8078793          	addi	a5,a5,-128 # 8001db80 <bcache+0x8268>
    80002c08:	00f48863          	beq	s1,a5,80002c18 <bread+0x84>
    80002c0c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c0e:	40bc                	lw	a5,64(s1)
    80002c10:	cb91                	beqz	a5,80002c24 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c12:	64a4                	ld	s1,72(s1)
    80002c14:	fee49de3          	bne	s1,a4,80002c0e <bread+0x7a>
  panic("bget: no buffers");
    80002c18:	00005517          	auipc	a0,0x5
    80002c1c:	9b050513          	addi	a0,a0,-1616 # 800075c8 <syscalls+0xd0>
    80002c20:	b3dfd0ef          	jal	ra,8000075c <panic>
      b->dev = dev;
    80002c24:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002c28:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002c2c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c30:	4785                	li	a5,1
    80002c32:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c34:	00013517          	auipc	a0,0x13
    80002c38:	ce450513          	addi	a0,a0,-796 # 80015918 <bcache>
    80002c3c:	804fe0ef          	jal	ra,80000c40 <release>
      acquiresleep(&b->lock);
    80002c40:	01048513          	addi	a0,s1,16
    80002c44:	184010ef          	jal	ra,80003dc8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c48:	409c                	lw	a5,0(s1)
    80002c4a:	cb89                	beqz	a5,80002c5c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c4c:	8526                	mv	a0,s1
    80002c4e:	70a2                	ld	ra,40(sp)
    80002c50:	7402                	ld	s0,32(sp)
    80002c52:	64e2                	ld	s1,24(sp)
    80002c54:	6942                	ld	s2,16(sp)
    80002c56:	69a2                	ld	s3,8(sp)
    80002c58:	6145                	addi	sp,sp,48
    80002c5a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c5c:	4581                	li	a1,0
    80002c5e:	8526                	mv	a0,s1
    80002c60:	0f1020ef          	jal	ra,80005550 <virtio_disk_rw>
    b->valid = 1;
    80002c64:	4785                	li	a5,1
    80002c66:	c09c                	sw	a5,0(s1)
  return b;
    80002c68:	b7d5                	j	80002c4c <bread+0xb8>

0000000080002c6a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c6a:	1101                	addi	sp,sp,-32
    80002c6c:	ec06                	sd	ra,24(sp)
    80002c6e:	e822                	sd	s0,16(sp)
    80002c70:	e426                	sd	s1,8(sp)
    80002c72:	1000                	addi	s0,sp,32
    80002c74:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c76:	0541                	addi	a0,a0,16
    80002c78:	1ce010ef          	jal	ra,80003e46 <holdingsleep>
    80002c7c:	c911                	beqz	a0,80002c90 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c7e:	4585                	li	a1,1
    80002c80:	8526                	mv	a0,s1
    80002c82:	0cf020ef          	jal	ra,80005550 <virtio_disk_rw>
}
    80002c86:	60e2                	ld	ra,24(sp)
    80002c88:	6442                	ld	s0,16(sp)
    80002c8a:	64a2                	ld	s1,8(sp)
    80002c8c:	6105                	addi	sp,sp,32
    80002c8e:	8082                	ret
    panic("bwrite");
    80002c90:	00005517          	auipc	a0,0x5
    80002c94:	95050513          	addi	a0,a0,-1712 # 800075e0 <syscalls+0xe8>
    80002c98:	ac5fd0ef          	jal	ra,8000075c <panic>

0000000080002c9c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c9c:	1101                	addi	sp,sp,-32
    80002c9e:	ec06                	sd	ra,24(sp)
    80002ca0:	e822                	sd	s0,16(sp)
    80002ca2:	e426                	sd	s1,8(sp)
    80002ca4:	e04a                	sd	s2,0(sp)
    80002ca6:	1000                	addi	s0,sp,32
    80002ca8:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002caa:	01050913          	addi	s2,a0,16
    80002cae:	854a                	mv	a0,s2
    80002cb0:	196010ef          	jal	ra,80003e46 <holdingsleep>
    80002cb4:	c13d                	beqz	a0,80002d1a <brelse+0x7e>
    panic("brelse");

  releasesleep(&b->lock);
    80002cb6:	854a                	mv	a0,s2
    80002cb8:	156010ef          	jal	ra,80003e0e <releasesleep>

  acquire(&bcache.lock);
    80002cbc:	00013517          	auipc	a0,0x13
    80002cc0:	c5c50513          	addi	a0,a0,-932 # 80015918 <bcache>
    80002cc4:	ee5fd0ef          	jal	ra,80000ba8 <acquire>
  b->refcnt--;
    80002cc8:	40bc                	lw	a5,64(s1)
    80002cca:	37fd                	addiw	a5,a5,-1
    80002ccc:	0007871b          	sext.w	a4,a5
    80002cd0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002cd2:	eb05                	bnez	a4,80002d02 <brelse+0x66>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002cd4:	68bc                	ld	a5,80(s1)
    80002cd6:	64b8                	ld	a4,72(s1)
    80002cd8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002cda:	64bc                	ld	a5,72(s1)
    80002cdc:	68b8                	ld	a4,80(s1)
    80002cde:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ce0:	0001b797          	auipc	a5,0x1b
    80002ce4:	c3878793          	addi	a5,a5,-968 # 8001d918 <bcache+0x8000>
    80002ce8:	2b87b703          	ld	a4,696(a5)
    80002cec:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cee:	0001b717          	auipc	a4,0x1b
    80002cf2:	e9270713          	addi	a4,a4,-366 # 8001db80 <bcache+0x8268>
    80002cf6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cf8:	2b87b703          	ld	a4,696(a5)
    80002cfc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cfe:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002d02:	00013517          	auipc	a0,0x13
    80002d06:	c1650513          	addi	a0,a0,-1002 # 80015918 <bcache>
    80002d0a:	f37fd0ef          	jal	ra,80000c40 <release>
}
    80002d0e:	60e2                	ld	ra,24(sp)
    80002d10:	6442                	ld	s0,16(sp)
    80002d12:	64a2                	ld	s1,8(sp)
    80002d14:	6902                	ld	s2,0(sp)
    80002d16:	6105                	addi	sp,sp,32
    80002d18:	8082                	ret
    panic("brelse");
    80002d1a:	00005517          	auipc	a0,0x5
    80002d1e:	8ce50513          	addi	a0,a0,-1842 # 800075e8 <syscalls+0xf0>
    80002d22:	a3bfd0ef          	jal	ra,8000075c <panic>

0000000080002d26 <bpin>:

void
bpin(struct buf *b) {
    80002d26:	1101                	addi	sp,sp,-32
    80002d28:	ec06                	sd	ra,24(sp)
    80002d2a:	e822                	sd	s0,16(sp)
    80002d2c:	e426                	sd	s1,8(sp)
    80002d2e:	1000                	addi	s0,sp,32
    80002d30:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d32:	00013517          	auipc	a0,0x13
    80002d36:	be650513          	addi	a0,a0,-1050 # 80015918 <bcache>
    80002d3a:	e6ffd0ef          	jal	ra,80000ba8 <acquire>
  b->refcnt++;
    80002d3e:	40bc                	lw	a5,64(s1)
    80002d40:	2785                	addiw	a5,a5,1
    80002d42:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d44:	00013517          	auipc	a0,0x13
    80002d48:	bd450513          	addi	a0,a0,-1068 # 80015918 <bcache>
    80002d4c:	ef5fd0ef          	jal	ra,80000c40 <release>
}
    80002d50:	60e2                	ld	ra,24(sp)
    80002d52:	6442                	ld	s0,16(sp)
    80002d54:	64a2                	ld	s1,8(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret

0000000080002d5a <bunpin>:

void
bunpin(struct buf *b) {
    80002d5a:	1101                	addi	sp,sp,-32
    80002d5c:	ec06                	sd	ra,24(sp)
    80002d5e:	e822                	sd	s0,16(sp)
    80002d60:	e426                	sd	s1,8(sp)
    80002d62:	1000                	addi	s0,sp,32
    80002d64:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d66:	00013517          	auipc	a0,0x13
    80002d6a:	bb250513          	addi	a0,a0,-1102 # 80015918 <bcache>
    80002d6e:	e3bfd0ef          	jal	ra,80000ba8 <acquire>
  b->refcnt--;
    80002d72:	40bc                	lw	a5,64(s1)
    80002d74:	37fd                	addiw	a5,a5,-1
    80002d76:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d78:	00013517          	auipc	a0,0x13
    80002d7c:	ba050513          	addi	a0,a0,-1120 # 80015918 <bcache>
    80002d80:	ec1fd0ef          	jal	ra,80000c40 <release>
}
    80002d84:	60e2                	ld	ra,24(sp)
    80002d86:	6442                	ld	s0,16(sp)
    80002d88:	64a2                	ld	s1,8(sp)
    80002d8a:	6105                	addi	sp,sp,32
    80002d8c:	8082                	ret

0000000080002d8e <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d8e:	1101                	addi	sp,sp,-32
    80002d90:	ec06                	sd	ra,24(sp)
    80002d92:	e822                	sd	s0,16(sp)
    80002d94:	e426                	sd	s1,8(sp)
    80002d96:	e04a                	sd	s2,0(sp)
    80002d98:	1000                	addi	s0,sp,32
    80002d9a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d9c:	00d5d59b          	srliw	a1,a1,0xd
    80002da0:	0001b797          	auipc	a5,0x1b
    80002da4:	2547a783          	lw	a5,596(a5) # 8001dff4 <sb+0x1c>
    80002da8:	9dbd                	addw	a1,a1,a5
    80002daa:	debff0ef          	jal	ra,80002b94 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002dae:	0074f713          	andi	a4,s1,7
    80002db2:	4785                	li	a5,1
    80002db4:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002db8:	14ce                	slli	s1,s1,0x33
    80002dba:	90d9                	srli	s1,s1,0x36
    80002dbc:	00950733          	add	a4,a0,s1
    80002dc0:	05874703          	lbu	a4,88(a4)
    80002dc4:	00e7f6b3          	and	a3,a5,a4
    80002dc8:	c29d                	beqz	a3,80002dee <bfree+0x60>
    80002dca:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002dcc:	94aa                	add	s1,s1,a0
    80002dce:	fff7c793          	not	a5,a5
    80002dd2:	8ff9                	and	a5,a5,a4
    80002dd4:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    80002dd8:	6e9000ef          	jal	ra,80003cc0 <log_write>
  brelse(bp);
    80002ddc:	854a                	mv	a0,s2
    80002dde:	ebfff0ef          	jal	ra,80002c9c <brelse>
}
    80002de2:	60e2                	ld	ra,24(sp)
    80002de4:	6442                	ld	s0,16(sp)
    80002de6:	64a2                	ld	s1,8(sp)
    80002de8:	6902                	ld	s2,0(sp)
    80002dea:	6105                	addi	sp,sp,32
    80002dec:	8082                	ret
    panic("freeing free block");
    80002dee:	00005517          	auipc	a0,0x5
    80002df2:	80250513          	addi	a0,a0,-2046 # 800075f0 <syscalls+0xf8>
    80002df6:	967fd0ef          	jal	ra,8000075c <panic>

0000000080002dfa <balloc>:
{
    80002dfa:	711d                	addi	sp,sp,-96
    80002dfc:	ec86                	sd	ra,88(sp)
    80002dfe:	e8a2                	sd	s0,80(sp)
    80002e00:	e4a6                	sd	s1,72(sp)
    80002e02:	e0ca                	sd	s2,64(sp)
    80002e04:	fc4e                	sd	s3,56(sp)
    80002e06:	f852                	sd	s4,48(sp)
    80002e08:	f456                	sd	s5,40(sp)
    80002e0a:	f05a                	sd	s6,32(sp)
    80002e0c:	ec5e                	sd	s7,24(sp)
    80002e0e:	e862                	sd	s8,16(sp)
    80002e10:	e466                	sd	s9,8(sp)
    80002e12:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002e14:	0001b797          	auipc	a5,0x1b
    80002e18:	1c87a783          	lw	a5,456(a5) # 8001dfdc <sb+0x4>
    80002e1c:	0e078163          	beqz	a5,80002efe <balloc+0x104>
    80002e20:	8baa                	mv	s7,a0
    80002e22:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e24:	0001bb17          	auipc	s6,0x1b
    80002e28:	1b4b0b13          	addi	s6,s6,436 # 8001dfd8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e2c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002e2e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e30:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e32:	6c89                	lui	s9,0x2
    80002e34:	a0b5                	j	80002ea0 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e36:	974a                	add	a4,a4,s2
    80002e38:	8fd5                	or	a5,a5,a3
    80002e3a:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    80002e3e:	854a                	mv	a0,s2
    80002e40:	681000ef          	jal	ra,80003cc0 <log_write>
        brelse(bp);
    80002e44:	854a                	mv	a0,s2
    80002e46:	e57ff0ef          	jal	ra,80002c9c <brelse>
  bp = bread(dev, bno);
    80002e4a:	85a6                	mv	a1,s1
    80002e4c:	855e                	mv	a0,s7
    80002e4e:	d47ff0ef          	jal	ra,80002b94 <bread>
    80002e52:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e54:	40000613          	li	a2,1024
    80002e58:	4581                	li	a1,0
    80002e5a:	05850513          	addi	a0,a0,88
    80002e5e:	e1ffd0ef          	jal	ra,80000c7c <memset>
  log_write(bp);
    80002e62:	854a                	mv	a0,s2
    80002e64:	65d000ef          	jal	ra,80003cc0 <log_write>
  brelse(bp);
    80002e68:	854a                	mv	a0,s2
    80002e6a:	e33ff0ef          	jal	ra,80002c9c <brelse>
}
    80002e6e:	8526                	mv	a0,s1
    80002e70:	60e6                	ld	ra,88(sp)
    80002e72:	6446                	ld	s0,80(sp)
    80002e74:	64a6                	ld	s1,72(sp)
    80002e76:	6906                	ld	s2,64(sp)
    80002e78:	79e2                	ld	s3,56(sp)
    80002e7a:	7a42                	ld	s4,48(sp)
    80002e7c:	7aa2                	ld	s5,40(sp)
    80002e7e:	7b02                	ld	s6,32(sp)
    80002e80:	6be2                	ld	s7,24(sp)
    80002e82:	6c42                	ld	s8,16(sp)
    80002e84:	6ca2                	ld	s9,8(sp)
    80002e86:	6125                	addi	sp,sp,96
    80002e88:	8082                	ret
    brelse(bp);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	e11ff0ef          	jal	ra,80002c9c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e90:	015c87bb          	addw	a5,s9,s5
    80002e94:	00078a9b          	sext.w	s5,a5
    80002e98:	004b2703          	lw	a4,4(s6)
    80002e9c:	06eaf163          	bgeu	s5,a4,80002efe <balloc+0x104>
    bp = bread(dev, BBLOCK(b, sb));
    80002ea0:	41fad79b          	sraiw	a5,s5,0x1f
    80002ea4:	0137d79b          	srliw	a5,a5,0x13
    80002ea8:	015787bb          	addw	a5,a5,s5
    80002eac:	40d7d79b          	sraiw	a5,a5,0xd
    80002eb0:	01cb2583          	lw	a1,28(s6)
    80002eb4:	9dbd                	addw	a1,a1,a5
    80002eb6:	855e                	mv	a0,s7
    80002eb8:	cddff0ef          	jal	ra,80002b94 <bread>
    80002ebc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ebe:	004b2503          	lw	a0,4(s6)
    80002ec2:	000a849b          	sext.w	s1,s5
    80002ec6:	8662                	mv	a2,s8
    80002ec8:	fca4f1e3          	bgeu	s1,a0,80002e8a <balloc+0x90>
      m = 1 << (bi % 8);
    80002ecc:	41f6579b          	sraiw	a5,a2,0x1f
    80002ed0:	01d7d69b          	srliw	a3,a5,0x1d
    80002ed4:	00c6873b          	addw	a4,a3,a2
    80002ed8:	00777793          	andi	a5,a4,7
    80002edc:	9f95                	subw	a5,a5,a3
    80002ede:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002ee2:	4037571b          	sraiw	a4,a4,0x3
    80002ee6:	00e906b3          	add	a3,s2,a4
    80002eea:	0586c683          	lbu	a3,88(a3)
    80002eee:	00d7f5b3          	and	a1,a5,a3
    80002ef2:	d1b1                	beqz	a1,80002e36 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002ef4:	2605                	addiw	a2,a2,1
    80002ef6:	2485                	addiw	s1,s1,1
    80002ef8:	fd4618e3          	bne	a2,s4,80002ec8 <balloc+0xce>
    80002efc:	b779                	j	80002e8a <balloc+0x90>
  printf("balloc: out of blocks\n");
    80002efe:	00004517          	auipc	a0,0x4
    80002f02:	70a50513          	addi	a0,a0,1802 # 80007608 <syscalls+0x110>
    80002f06:	da2fd0ef          	jal	ra,800004a8 <printf>
  return 0;
    80002f0a:	4481                	li	s1,0
    80002f0c:	b78d                	j	80002e6e <balloc+0x74>

0000000080002f0e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f0e:	7179                	addi	sp,sp,-48
    80002f10:	f406                	sd	ra,40(sp)
    80002f12:	f022                	sd	s0,32(sp)
    80002f14:	ec26                	sd	s1,24(sp)
    80002f16:	e84a                	sd	s2,16(sp)
    80002f18:	e44e                	sd	s3,8(sp)
    80002f1a:	e052                	sd	s4,0(sp)
    80002f1c:	1800                	addi	s0,sp,48
    80002f1e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f20:	47ad                	li	a5,11
    80002f22:	02b7e563          	bltu	a5,a1,80002f4c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002f26:	02059493          	slli	s1,a1,0x20
    80002f2a:	9081                	srli	s1,s1,0x20
    80002f2c:	048a                	slli	s1,s1,0x2
    80002f2e:	94aa                	add	s1,s1,a0
    80002f30:	0504a903          	lw	s2,80(s1)
    80002f34:	06091663          	bnez	s2,80002fa0 <bmap+0x92>
      addr = balloc(ip->dev);
    80002f38:	4108                	lw	a0,0(a0)
    80002f3a:	ec1ff0ef          	jal	ra,80002dfa <balloc>
    80002f3e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f42:	04090f63          	beqz	s2,80002fa0 <bmap+0x92>
        return 0;
      ip->addrs[bn] = addr;
    80002f46:	0524a823          	sw	s2,80(s1)
    80002f4a:	a899                	j	80002fa0 <bmap+0x92>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f4c:	ff45849b          	addiw	s1,a1,-12
    80002f50:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f54:	0ff00793          	li	a5,255
    80002f58:	06e7eb63          	bltu	a5,a4,80002fce <bmap+0xc0>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f5c:	08052903          	lw	s2,128(a0)
    80002f60:	00091b63          	bnez	s2,80002f76 <bmap+0x68>
      addr = balloc(ip->dev);
    80002f64:	4108                	lw	a0,0(a0)
    80002f66:	e95ff0ef          	jal	ra,80002dfa <balloc>
    80002f6a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f6e:	02090963          	beqz	s2,80002fa0 <bmap+0x92>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f72:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002f76:	85ca                	mv	a1,s2
    80002f78:	0009a503          	lw	a0,0(s3)
    80002f7c:	c19ff0ef          	jal	ra,80002b94 <bread>
    80002f80:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f82:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f86:	02049593          	slli	a1,s1,0x20
    80002f8a:	9181                	srli	a1,a1,0x20
    80002f8c:	058a                	slli	a1,a1,0x2
    80002f8e:	00b784b3          	add	s1,a5,a1
    80002f92:	0004a903          	lw	s2,0(s1)
    80002f96:	00090e63          	beqz	s2,80002fb2 <bmap+0xa4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f9a:	8552                	mv	a0,s4
    80002f9c:	d01ff0ef          	jal	ra,80002c9c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002fa0:	854a                	mv	a0,s2
    80002fa2:	70a2                	ld	ra,40(sp)
    80002fa4:	7402                	ld	s0,32(sp)
    80002fa6:	64e2                	ld	s1,24(sp)
    80002fa8:	6942                	ld	s2,16(sp)
    80002faa:	69a2                	ld	s3,8(sp)
    80002fac:	6a02                	ld	s4,0(sp)
    80002fae:	6145                	addi	sp,sp,48
    80002fb0:	8082                	ret
      addr = balloc(ip->dev);
    80002fb2:	0009a503          	lw	a0,0(s3)
    80002fb6:	e45ff0ef          	jal	ra,80002dfa <balloc>
    80002fba:	0005091b          	sext.w	s2,a0
      if(addr){
    80002fbe:	fc090ee3          	beqz	s2,80002f9a <bmap+0x8c>
        a[bn] = addr;
    80002fc2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002fc6:	8552                	mv	a0,s4
    80002fc8:	4f9000ef          	jal	ra,80003cc0 <log_write>
    80002fcc:	b7f9                	j	80002f9a <bmap+0x8c>
  panic("bmap: out of range");
    80002fce:	00004517          	auipc	a0,0x4
    80002fd2:	65250513          	addi	a0,a0,1618 # 80007620 <syscalls+0x128>
    80002fd6:	f86fd0ef          	jal	ra,8000075c <panic>

0000000080002fda <iget>:
{
    80002fda:	7179                	addi	sp,sp,-48
    80002fdc:	f406                	sd	ra,40(sp)
    80002fde:	f022                	sd	s0,32(sp)
    80002fe0:	ec26                	sd	s1,24(sp)
    80002fe2:	e84a                	sd	s2,16(sp)
    80002fe4:	e44e                	sd	s3,8(sp)
    80002fe6:	e052                	sd	s4,0(sp)
    80002fe8:	1800                	addi	s0,sp,48
    80002fea:	89aa                	mv	s3,a0
    80002fec:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fee:	0001b517          	auipc	a0,0x1b
    80002ff2:	00a50513          	addi	a0,a0,10 # 8001dff8 <itable>
    80002ff6:	bb3fd0ef          	jal	ra,80000ba8 <acquire>
  empty = 0;
    80002ffa:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002ffc:	0001b497          	auipc	s1,0x1b
    80003000:	01448493          	addi	s1,s1,20 # 8001e010 <itable+0x18>
    80003004:	0001d697          	auipc	a3,0x1d
    80003008:	a9c68693          	addi	a3,a3,-1380 # 8001faa0 <log>
    8000300c:	a039                	j	8000301a <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000300e:	02090963          	beqz	s2,80003040 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003012:	08848493          	addi	s1,s1,136
    80003016:	02d48863          	beq	s1,a3,80003046 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000301a:	449c                	lw	a5,8(s1)
    8000301c:	fef059e3          	blez	a5,8000300e <iget+0x34>
    80003020:	4098                	lw	a4,0(s1)
    80003022:	ff3716e3          	bne	a4,s3,8000300e <iget+0x34>
    80003026:	40d8                	lw	a4,4(s1)
    80003028:	ff4713e3          	bne	a4,s4,8000300e <iget+0x34>
      ip->ref++;
    8000302c:	2785                	addiw	a5,a5,1
    8000302e:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003030:	0001b517          	auipc	a0,0x1b
    80003034:	fc850513          	addi	a0,a0,-56 # 8001dff8 <itable>
    80003038:	c09fd0ef          	jal	ra,80000c40 <release>
      return ip;
    8000303c:	8926                	mv	s2,s1
    8000303e:	a02d                	j	80003068 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003040:	fbe9                	bnez	a5,80003012 <iget+0x38>
    80003042:	8926                	mv	s2,s1
    80003044:	b7f9                	j	80003012 <iget+0x38>
  if(empty == 0)
    80003046:	02090a63          	beqz	s2,8000307a <iget+0xa0>
  ip->dev = dev;
    8000304a:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000304e:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003052:	4785                	li	a5,1
    80003054:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003058:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000305c:	0001b517          	auipc	a0,0x1b
    80003060:	f9c50513          	addi	a0,a0,-100 # 8001dff8 <itable>
    80003064:	bddfd0ef          	jal	ra,80000c40 <release>
}
    80003068:	854a                	mv	a0,s2
    8000306a:	70a2                	ld	ra,40(sp)
    8000306c:	7402                	ld	s0,32(sp)
    8000306e:	64e2                	ld	s1,24(sp)
    80003070:	6942                	ld	s2,16(sp)
    80003072:	69a2                	ld	s3,8(sp)
    80003074:	6a02                	ld	s4,0(sp)
    80003076:	6145                	addi	sp,sp,48
    80003078:	8082                	ret
    panic("iget: no inodes");
    8000307a:	00004517          	auipc	a0,0x4
    8000307e:	5be50513          	addi	a0,a0,1470 # 80007638 <syscalls+0x140>
    80003082:	edafd0ef          	jal	ra,8000075c <panic>

0000000080003086 <fsinit>:
fsinit(int dev) {
    80003086:	7179                	addi	sp,sp,-48
    80003088:	f406                	sd	ra,40(sp)
    8000308a:	f022                	sd	s0,32(sp)
    8000308c:	ec26                	sd	s1,24(sp)
    8000308e:	e84a                	sd	s2,16(sp)
    80003090:	e44e                	sd	s3,8(sp)
    80003092:	1800                	addi	s0,sp,48
    80003094:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003096:	4585                	li	a1,1
    80003098:	afdff0ef          	jal	ra,80002b94 <bread>
    8000309c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000309e:	0001b997          	auipc	s3,0x1b
    800030a2:	f3a98993          	addi	s3,s3,-198 # 8001dfd8 <sb>
    800030a6:	02000613          	li	a2,32
    800030aa:	05850593          	addi	a1,a0,88
    800030ae:	854e                	mv	a0,s3
    800030b0:	c2dfd0ef          	jal	ra,80000cdc <memmove>
  brelse(bp);
    800030b4:	8526                	mv	a0,s1
    800030b6:	be7ff0ef          	jal	ra,80002c9c <brelse>
  if(sb.magic != FSMAGIC)
    800030ba:	0009a703          	lw	a4,0(s3)
    800030be:	102037b7          	lui	a5,0x10203
    800030c2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030c6:	02f71063          	bne	a4,a5,800030e6 <fsinit+0x60>
  initlog(dev, &sb);
    800030ca:	0001b597          	auipc	a1,0x1b
    800030ce:	f0e58593          	addi	a1,a1,-242 # 8001dfd8 <sb>
    800030d2:	854a                	mv	a0,s2
    800030d4:	1d9000ef          	jal	ra,80003aac <initlog>
}
    800030d8:	70a2                	ld	ra,40(sp)
    800030da:	7402                	ld	s0,32(sp)
    800030dc:	64e2                	ld	s1,24(sp)
    800030de:	6942                	ld	s2,16(sp)
    800030e0:	69a2                	ld	s3,8(sp)
    800030e2:	6145                	addi	sp,sp,48
    800030e4:	8082                	ret
    panic("invalid file system");
    800030e6:	00004517          	auipc	a0,0x4
    800030ea:	56250513          	addi	a0,a0,1378 # 80007648 <syscalls+0x150>
    800030ee:	e6efd0ef          	jal	ra,8000075c <panic>

00000000800030f2 <iinit>:
{
    800030f2:	7179                	addi	sp,sp,-48
    800030f4:	f406                	sd	ra,40(sp)
    800030f6:	f022                	sd	s0,32(sp)
    800030f8:	ec26                	sd	s1,24(sp)
    800030fa:	e84a                	sd	s2,16(sp)
    800030fc:	e44e                	sd	s3,8(sp)
    800030fe:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003100:	00004597          	auipc	a1,0x4
    80003104:	56058593          	addi	a1,a1,1376 # 80007660 <syscalls+0x168>
    80003108:	0001b517          	auipc	a0,0x1b
    8000310c:	ef050513          	addi	a0,a0,-272 # 8001dff8 <itable>
    80003110:	a19fd0ef          	jal	ra,80000b28 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003114:	0001b497          	auipc	s1,0x1b
    80003118:	f0c48493          	addi	s1,s1,-244 # 8001e020 <itable+0x28>
    8000311c:	0001d997          	auipc	s3,0x1d
    80003120:	99498993          	addi	s3,s3,-1644 # 8001fab0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003124:	00004917          	auipc	s2,0x4
    80003128:	54490913          	addi	s2,s2,1348 # 80007668 <syscalls+0x170>
    8000312c:	85ca                	mv	a1,s2
    8000312e:	8526                	mv	a0,s1
    80003130:	463000ef          	jal	ra,80003d92 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003134:	08848493          	addi	s1,s1,136
    80003138:	ff349ae3          	bne	s1,s3,8000312c <iinit+0x3a>
}
    8000313c:	70a2                	ld	ra,40(sp)
    8000313e:	7402                	ld	s0,32(sp)
    80003140:	64e2                	ld	s1,24(sp)
    80003142:	6942                	ld	s2,16(sp)
    80003144:	69a2                	ld	s3,8(sp)
    80003146:	6145                	addi	sp,sp,48
    80003148:	8082                	ret

000000008000314a <ialloc>:
{
    8000314a:	715d                	addi	sp,sp,-80
    8000314c:	e486                	sd	ra,72(sp)
    8000314e:	e0a2                	sd	s0,64(sp)
    80003150:	fc26                	sd	s1,56(sp)
    80003152:	f84a                	sd	s2,48(sp)
    80003154:	f44e                	sd	s3,40(sp)
    80003156:	f052                	sd	s4,32(sp)
    80003158:	ec56                	sd	s5,24(sp)
    8000315a:	e85a                	sd	s6,16(sp)
    8000315c:	e45e                	sd	s7,8(sp)
    8000315e:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003160:	0001b717          	auipc	a4,0x1b
    80003164:	e8472703          	lw	a4,-380(a4) # 8001dfe4 <sb+0xc>
    80003168:	4785                	li	a5,1
    8000316a:	04e7f663          	bgeu	a5,a4,800031b6 <ialloc+0x6c>
    8000316e:	8aaa                	mv	s5,a0
    80003170:	8bae                	mv	s7,a1
    80003172:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003174:	0001ba17          	auipc	s4,0x1b
    80003178:	e64a0a13          	addi	s4,s4,-412 # 8001dfd8 <sb>
    8000317c:	00048b1b          	sext.w	s6,s1
    80003180:	0044d593          	srli	a1,s1,0x4
    80003184:	018a2783          	lw	a5,24(s4)
    80003188:	9dbd                	addw	a1,a1,a5
    8000318a:	8556                	mv	a0,s5
    8000318c:	a09ff0ef          	jal	ra,80002b94 <bread>
    80003190:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003192:	05850993          	addi	s3,a0,88
    80003196:	00f4f793          	andi	a5,s1,15
    8000319a:	079a                	slli	a5,a5,0x6
    8000319c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000319e:	00099783          	lh	a5,0(s3)
    800031a2:	cf85                	beqz	a5,800031da <ialloc+0x90>
    brelse(bp);
    800031a4:	af9ff0ef          	jal	ra,80002c9c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800031a8:	0485                	addi	s1,s1,1
    800031aa:	00ca2703          	lw	a4,12(s4)
    800031ae:	0004879b          	sext.w	a5,s1
    800031b2:	fce7e5e3          	bltu	a5,a4,8000317c <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800031b6:	00004517          	auipc	a0,0x4
    800031ba:	4ba50513          	addi	a0,a0,1210 # 80007670 <syscalls+0x178>
    800031be:	aeafd0ef          	jal	ra,800004a8 <printf>
  return 0;
    800031c2:	4501                	li	a0,0
}
    800031c4:	60a6                	ld	ra,72(sp)
    800031c6:	6406                	ld	s0,64(sp)
    800031c8:	74e2                	ld	s1,56(sp)
    800031ca:	7942                	ld	s2,48(sp)
    800031cc:	79a2                	ld	s3,40(sp)
    800031ce:	7a02                	ld	s4,32(sp)
    800031d0:	6ae2                	ld	s5,24(sp)
    800031d2:	6b42                	ld	s6,16(sp)
    800031d4:	6ba2                	ld	s7,8(sp)
    800031d6:	6161                	addi	sp,sp,80
    800031d8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031da:	04000613          	li	a2,64
    800031de:	4581                	li	a1,0
    800031e0:	854e                	mv	a0,s3
    800031e2:	a9bfd0ef          	jal	ra,80000c7c <memset>
      dip->type = type;
    800031e6:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031ea:	854a                	mv	a0,s2
    800031ec:	2d5000ef          	jal	ra,80003cc0 <log_write>
      brelse(bp);
    800031f0:	854a                	mv	a0,s2
    800031f2:	aabff0ef          	jal	ra,80002c9c <brelse>
      return iget(dev, inum);
    800031f6:	85da                	mv	a1,s6
    800031f8:	8556                	mv	a0,s5
    800031fa:	de1ff0ef          	jal	ra,80002fda <iget>
    800031fe:	b7d9                	j	800031c4 <ialloc+0x7a>

0000000080003200 <iupdate>:
{
    80003200:	1101                	addi	sp,sp,-32
    80003202:	ec06                	sd	ra,24(sp)
    80003204:	e822                	sd	s0,16(sp)
    80003206:	e426                	sd	s1,8(sp)
    80003208:	e04a                	sd	s2,0(sp)
    8000320a:	1000                	addi	s0,sp,32
    8000320c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000320e:	415c                	lw	a5,4(a0)
    80003210:	0047d79b          	srliw	a5,a5,0x4
    80003214:	0001b597          	auipc	a1,0x1b
    80003218:	ddc5a583          	lw	a1,-548(a1) # 8001dff0 <sb+0x18>
    8000321c:	9dbd                	addw	a1,a1,a5
    8000321e:	4108                	lw	a0,0(a0)
    80003220:	975ff0ef          	jal	ra,80002b94 <bread>
    80003224:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003226:	05850793          	addi	a5,a0,88
    8000322a:	40c8                	lw	a0,4(s1)
    8000322c:	893d                	andi	a0,a0,15
    8000322e:	051a                	slli	a0,a0,0x6
    80003230:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80003232:	04449703          	lh	a4,68(s1)
    80003236:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    8000323a:	04649703          	lh	a4,70(s1)
    8000323e:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80003242:	04849703          	lh	a4,72(s1)
    80003246:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    8000324a:	04a49703          	lh	a4,74(s1)
    8000324e:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80003252:	44f8                	lw	a4,76(s1)
    80003254:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003256:	03400613          	li	a2,52
    8000325a:	05048593          	addi	a1,s1,80
    8000325e:	0531                	addi	a0,a0,12
    80003260:	a7dfd0ef          	jal	ra,80000cdc <memmove>
  log_write(bp);
    80003264:	854a                	mv	a0,s2
    80003266:	25b000ef          	jal	ra,80003cc0 <log_write>
  brelse(bp);
    8000326a:	854a                	mv	a0,s2
    8000326c:	a31ff0ef          	jal	ra,80002c9c <brelse>
}
    80003270:	60e2                	ld	ra,24(sp)
    80003272:	6442                	ld	s0,16(sp)
    80003274:	64a2                	ld	s1,8(sp)
    80003276:	6902                	ld	s2,0(sp)
    80003278:	6105                	addi	sp,sp,32
    8000327a:	8082                	ret

000000008000327c <idup>:
{
    8000327c:	1101                	addi	sp,sp,-32
    8000327e:	ec06                	sd	ra,24(sp)
    80003280:	e822                	sd	s0,16(sp)
    80003282:	e426                	sd	s1,8(sp)
    80003284:	1000                	addi	s0,sp,32
    80003286:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003288:	0001b517          	auipc	a0,0x1b
    8000328c:	d7050513          	addi	a0,a0,-656 # 8001dff8 <itable>
    80003290:	919fd0ef          	jal	ra,80000ba8 <acquire>
  ip->ref++;
    80003294:	449c                	lw	a5,8(s1)
    80003296:	2785                	addiw	a5,a5,1
    80003298:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000329a:	0001b517          	auipc	a0,0x1b
    8000329e:	d5e50513          	addi	a0,a0,-674 # 8001dff8 <itable>
    800032a2:	99ffd0ef          	jal	ra,80000c40 <release>
}
    800032a6:	8526                	mv	a0,s1
    800032a8:	60e2                	ld	ra,24(sp)
    800032aa:	6442                	ld	s0,16(sp)
    800032ac:	64a2                	ld	s1,8(sp)
    800032ae:	6105                	addi	sp,sp,32
    800032b0:	8082                	ret

00000000800032b2 <ilock>:
{
    800032b2:	1101                	addi	sp,sp,-32
    800032b4:	ec06                	sd	ra,24(sp)
    800032b6:	e822                	sd	s0,16(sp)
    800032b8:	e426                	sd	s1,8(sp)
    800032ba:	e04a                	sd	s2,0(sp)
    800032bc:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800032be:	c105                	beqz	a0,800032de <ilock+0x2c>
    800032c0:	84aa                	mv	s1,a0
    800032c2:	451c                	lw	a5,8(a0)
    800032c4:	00f05d63          	blez	a5,800032de <ilock+0x2c>
  acquiresleep(&ip->lock);
    800032c8:	0541                	addi	a0,a0,16
    800032ca:	2ff000ef          	jal	ra,80003dc8 <acquiresleep>
  if(ip->valid == 0){
    800032ce:	40bc                	lw	a5,64(s1)
    800032d0:	cf89                	beqz	a5,800032ea <ilock+0x38>
}
    800032d2:	60e2                	ld	ra,24(sp)
    800032d4:	6442                	ld	s0,16(sp)
    800032d6:	64a2                	ld	s1,8(sp)
    800032d8:	6902                	ld	s2,0(sp)
    800032da:	6105                	addi	sp,sp,32
    800032dc:	8082                	ret
    panic("ilock");
    800032de:	00004517          	auipc	a0,0x4
    800032e2:	3aa50513          	addi	a0,a0,938 # 80007688 <syscalls+0x190>
    800032e6:	c76fd0ef          	jal	ra,8000075c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032ea:	40dc                	lw	a5,4(s1)
    800032ec:	0047d79b          	srliw	a5,a5,0x4
    800032f0:	0001b597          	auipc	a1,0x1b
    800032f4:	d005a583          	lw	a1,-768(a1) # 8001dff0 <sb+0x18>
    800032f8:	9dbd                	addw	a1,a1,a5
    800032fa:	4088                	lw	a0,0(s1)
    800032fc:	899ff0ef          	jal	ra,80002b94 <bread>
    80003300:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003302:	05850593          	addi	a1,a0,88
    80003306:	40dc                	lw	a5,4(s1)
    80003308:	8bbd                	andi	a5,a5,15
    8000330a:	079a                	slli	a5,a5,0x6
    8000330c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000330e:	00059783          	lh	a5,0(a1)
    80003312:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003316:	00259783          	lh	a5,2(a1)
    8000331a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000331e:	00459783          	lh	a5,4(a1)
    80003322:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003326:	00659783          	lh	a5,6(a1)
    8000332a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000332e:	459c                	lw	a5,8(a1)
    80003330:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003332:	03400613          	li	a2,52
    80003336:	05b1                	addi	a1,a1,12
    80003338:	05048513          	addi	a0,s1,80
    8000333c:	9a1fd0ef          	jal	ra,80000cdc <memmove>
    brelse(bp);
    80003340:	854a                	mv	a0,s2
    80003342:	95bff0ef          	jal	ra,80002c9c <brelse>
    ip->valid = 1;
    80003346:	4785                	li	a5,1
    80003348:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000334a:	04449783          	lh	a5,68(s1)
    8000334e:	f3d1                	bnez	a5,800032d2 <ilock+0x20>
      panic("ilock: no type");
    80003350:	00004517          	auipc	a0,0x4
    80003354:	34050513          	addi	a0,a0,832 # 80007690 <syscalls+0x198>
    80003358:	c04fd0ef          	jal	ra,8000075c <panic>

000000008000335c <iunlock>:
{
    8000335c:	1101                	addi	sp,sp,-32
    8000335e:	ec06                	sd	ra,24(sp)
    80003360:	e822                	sd	s0,16(sp)
    80003362:	e426                	sd	s1,8(sp)
    80003364:	e04a                	sd	s2,0(sp)
    80003366:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003368:	c505                	beqz	a0,80003390 <iunlock+0x34>
    8000336a:	84aa                	mv	s1,a0
    8000336c:	01050913          	addi	s2,a0,16
    80003370:	854a                	mv	a0,s2
    80003372:	2d5000ef          	jal	ra,80003e46 <holdingsleep>
    80003376:	cd09                	beqz	a0,80003390 <iunlock+0x34>
    80003378:	449c                	lw	a5,8(s1)
    8000337a:	00f05b63          	blez	a5,80003390 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000337e:	854a                	mv	a0,s2
    80003380:	28f000ef          	jal	ra,80003e0e <releasesleep>
}
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	64a2                	ld	s1,8(sp)
    8000338a:	6902                	ld	s2,0(sp)
    8000338c:	6105                	addi	sp,sp,32
    8000338e:	8082                	ret
    panic("iunlock");
    80003390:	00004517          	auipc	a0,0x4
    80003394:	31050513          	addi	a0,a0,784 # 800076a0 <syscalls+0x1a8>
    80003398:	bc4fd0ef          	jal	ra,8000075c <panic>

000000008000339c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000339c:	7179                	addi	sp,sp,-48
    8000339e:	f406                	sd	ra,40(sp)
    800033a0:	f022                	sd	s0,32(sp)
    800033a2:	ec26                	sd	s1,24(sp)
    800033a4:	e84a                	sd	s2,16(sp)
    800033a6:	e44e                	sd	s3,8(sp)
    800033a8:	e052                	sd	s4,0(sp)
    800033aa:	1800                	addi	s0,sp,48
    800033ac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800033ae:	05050493          	addi	s1,a0,80
    800033b2:	08050913          	addi	s2,a0,128
    800033b6:	a021                	j	800033be <itrunc+0x22>
    800033b8:	0491                	addi	s1,s1,4
    800033ba:	01248b63          	beq	s1,s2,800033d0 <itrunc+0x34>
    if(ip->addrs[i]){
    800033be:	408c                	lw	a1,0(s1)
    800033c0:	dde5                	beqz	a1,800033b8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800033c2:	0009a503          	lw	a0,0(s3)
    800033c6:	9c9ff0ef          	jal	ra,80002d8e <bfree>
      ip->addrs[i] = 0;
    800033ca:	0004a023          	sw	zero,0(s1)
    800033ce:	b7ed                	j	800033b8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033d0:	0809a583          	lw	a1,128(s3)
    800033d4:	ed91                	bnez	a1,800033f0 <itrunc+0x54>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033d6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033da:	854e                	mv	a0,s3
    800033dc:	e25ff0ef          	jal	ra,80003200 <iupdate>
}
    800033e0:	70a2                	ld	ra,40(sp)
    800033e2:	7402                	ld	s0,32(sp)
    800033e4:	64e2                	ld	s1,24(sp)
    800033e6:	6942                	ld	s2,16(sp)
    800033e8:	69a2                	ld	s3,8(sp)
    800033ea:	6a02                	ld	s4,0(sp)
    800033ec:	6145                	addi	sp,sp,48
    800033ee:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033f0:	0009a503          	lw	a0,0(s3)
    800033f4:	fa0ff0ef          	jal	ra,80002b94 <bread>
    800033f8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033fa:	05850493          	addi	s1,a0,88
    800033fe:	45850913          	addi	s2,a0,1112
    80003402:	a801                	j	80003412 <itrunc+0x76>
        bfree(ip->dev, a[j]);
    80003404:	0009a503          	lw	a0,0(s3)
    80003408:	987ff0ef          	jal	ra,80002d8e <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000340c:	0491                	addi	s1,s1,4
    8000340e:	01248563          	beq	s1,s2,80003418 <itrunc+0x7c>
      if(a[j])
    80003412:	408c                	lw	a1,0(s1)
    80003414:	dde5                	beqz	a1,8000340c <itrunc+0x70>
    80003416:	b7fd                	j	80003404 <itrunc+0x68>
    brelse(bp);
    80003418:	8552                	mv	a0,s4
    8000341a:	883ff0ef          	jal	ra,80002c9c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000341e:	0809a583          	lw	a1,128(s3)
    80003422:	0009a503          	lw	a0,0(s3)
    80003426:	969ff0ef          	jal	ra,80002d8e <bfree>
    ip->addrs[NDIRECT] = 0;
    8000342a:	0809a023          	sw	zero,128(s3)
    8000342e:	b765                	j	800033d6 <itrunc+0x3a>

0000000080003430 <iput>:
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	e04a                	sd	s2,0(sp)
    8000343a:	1000                	addi	s0,sp,32
    8000343c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000343e:	0001b517          	auipc	a0,0x1b
    80003442:	bba50513          	addi	a0,a0,-1094 # 8001dff8 <itable>
    80003446:	f62fd0ef          	jal	ra,80000ba8 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000344a:	4498                	lw	a4,8(s1)
    8000344c:	4785                	li	a5,1
    8000344e:	02f70163          	beq	a4,a5,80003470 <iput+0x40>
  ip->ref--;
    80003452:	449c                	lw	a5,8(s1)
    80003454:	37fd                	addiw	a5,a5,-1
    80003456:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003458:	0001b517          	auipc	a0,0x1b
    8000345c:	ba050513          	addi	a0,a0,-1120 # 8001dff8 <itable>
    80003460:	fe0fd0ef          	jal	ra,80000c40 <release>
}
    80003464:	60e2                	ld	ra,24(sp)
    80003466:	6442                	ld	s0,16(sp)
    80003468:	64a2                	ld	s1,8(sp)
    8000346a:	6902                	ld	s2,0(sp)
    8000346c:	6105                	addi	sp,sp,32
    8000346e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003470:	40bc                	lw	a5,64(s1)
    80003472:	d3e5                	beqz	a5,80003452 <iput+0x22>
    80003474:	04a49783          	lh	a5,74(s1)
    80003478:	ffe9                	bnez	a5,80003452 <iput+0x22>
    acquiresleep(&ip->lock);
    8000347a:	01048913          	addi	s2,s1,16
    8000347e:	854a                	mv	a0,s2
    80003480:	149000ef          	jal	ra,80003dc8 <acquiresleep>
    release(&itable.lock);
    80003484:	0001b517          	auipc	a0,0x1b
    80003488:	b7450513          	addi	a0,a0,-1164 # 8001dff8 <itable>
    8000348c:	fb4fd0ef          	jal	ra,80000c40 <release>
    itrunc(ip);
    80003490:	8526                	mv	a0,s1
    80003492:	f0bff0ef          	jal	ra,8000339c <itrunc>
    ip->type = 0;
    80003496:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000349a:	8526                	mv	a0,s1
    8000349c:	d65ff0ef          	jal	ra,80003200 <iupdate>
    ip->valid = 0;
    800034a0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800034a4:	854a                	mv	a0,s2
    800034a6:	169000ef          	jal	ra,80003e0e <releasesleep>
    acquire(&itable.lock);
    800034aa:	0001b517          	auipc	a0,0x1b
    800034ae:	b4e50513          	addi	a0,a0,-1202 # 8001dff8 <itable>
    800034b2:	ef6fd0ef          	jal	ra,80000ba8 <acquire>
    800034b6:	bf71                	j	80003452 <iput+0x22>

00000000800034b8 <iunlockput>:
{
    800034b8:	1101                	addi	sp,sp,-32
    800034ba:	ec06                	sd	ra,24(sp)
    800034bc:	e822                	sd	s0,16(sp)
    800034be:	e426                	sd	s1,8(sp)
    800034c0:	1000                	addi	s0,sp,32
    800034c2:	84aa                	mv	s1,a0
  iunlock(ip);
    800034c4:	e99ff0ef          	jal	ra,8000335c <iunlock>
  iput(ip);
    800034c8:	8526                	mv	a0,s1
    800034ca:	f67ff0ef          	jal	ra,80003430 <iput>
}
    800034ce:	60e2                	ld	ra,24(sp)
    800034d0:	6442                	ld	s0,16(sp)
    800034d2:	64a2                	ld	s1,8(sp)
    800034d4:	6105                	addi	sp,sp,32
    800034d6:	8082                	ret

00000000800034d8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800034d8:	1141                	addi	sp,sp,-16
    800034da:	e422                	sd	s0,8(sp)
    800034dc:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800034de:	411c                	lw	a5,0(a0)
    800034e0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800034e2:	415c                	lw	a5,4(a0)
    800034e4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800034e6:	04451783          	lh	a5,68(a0)
    800034ea:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800034ee:	04a51783          	lh	a5,74(a0)
    800034f2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800034f6:	04c56783          	lwu	a5,76(a0)
    800034fa:	e99c                	sd	a5,16(a1)
}
    800034fc:	6422                	ld	s0,8(sp)
    800034fe:	0141                	addi	sp,sp,16
    80003500:	8082                	ret

0000000080003502 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003502:	457c                	lw	a5,76(a0)
    80003504:	0cd7ef63          	bltu	a5,a3,800035e2 <readi+0xe0>
{
    80003508:	7159                	addi	sp,sp,-112
    8000350a:	f486                	sd	ra,104(sp)
    8000350c:	f0a2                	sd	s0,96(sp)
    8000350e:	eca6                	sd	s1,88(sp)
    80003510:	e8ca                	sd	s2,80(sp)
    80003512:	e4ce                	sd	s3,72(sp)
    80003514:	e0d2                	sd	s4,64(sp)
    80003516:	fc56                	sd	s5,56(sp)
    80003518:	f85a                	sd	s6,48(sp)
    8000351a:	f45e                	sd	s7,40(sp)
    8000351c:	f062                	sd	s8,32(sp)
    8000351e:	ec66                	sd	s9,24(sp)
    80003520:	e86a                	sd	s10,16(sp)
    80003522:	e46e                	sd	s11,8(sp)
    80003524:	1880                	addi	s0,sp,112
    80003526:	8b2a                	mv	s6,a0
    80003528:	8bae                	mv	s7,a1
    8000352a:	8a32                	mv	s4,a2
    8000352c:	84b6                	mv	s1,a3
    8000352e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003530:	9f35                	addw	a4,a4,a3
    return 0;
    80003532:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003534:	08d76663          	bltu	a4,a3,800035c0 <readi+0xbe>
  if(off + n > ip->size)
    80003538:	00e7f463          	bgeu	a5,a4,80003540 <readi+0x3e>
    n = ip->size - off;
    8000353c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003540:	080a8f63          	beqz	s5,800035de <readi+0xdc>
    80003544:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003546:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000354a:	5c7d                	li	s8,-1
    8000354c:	a80d                	j	8000357e <readi+0x7c>
    8000354e:	020d1d93          	slli	s11,s10,0x20
    80003552:	020ddd93          	srli	s11,s11,0x20
    80003556:	05890613          	addi	a2,s2,88
    8000355a:	86ee                	mv	a3,s11
    8000355c:	963a                	add	a2,a2,a4
    8000355e:	85d2                	mv	a1,s4
    80003560:	855e                	mv	a0,s7
    80003562:	cdffe0ef          	jal	ra,80002240 <either_copyout>
    80003566:	05850763          	beq	a0,s8,800035b4 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000356a:	854a                	mv	a0,s2
    8000356c:	f30ff0ef          	jal	ra,80002c9c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003570:	013d09bb          	addw	s3,s10,s3
    80003574:	009d04bb          	addw	s1,s10,s1
    80003578:	9a6e                	add	s4,s4,s11
    8000357a:	0559f163          	bgeu	s3,s5,800035bc <readi+0xba>
    uint addr = bmap(ip, off/BSIZE);
    8000357e:	00a4d59b          	srliw	a1,s1,0xa
    80003582:	855a                	mv	a0,s6
    80003584:	98bff0ef          	jal	ra,80002f0e <bmap>
    80003588:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000358c:	c985                	beqz	a1,800035bc <readi+0xba>
    bp = bread(ip->dev, addr);
    8000358e:	000b2503          	lw	a0,0(s6)
    80003592:	e02ff0ef          	jal	ra,80002b94 <bread>
    80003596:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003598:	3ff4f713          	andi	a4,s1,1023
    8000359c:	40ec87bb          	subw	a5,s9,a4
    800035a0:	413a86bb          	subw	a3,s5,s3
    800035a4:	8d3e                	mv	s10,a5
    800035a6:	2781                	sext.w	a5,a5
    800035a8:	0006861b          	sext.w	a2,a3
    800035ac:	faf671e3          	bgeu	a2,a5,8000354e <readi+0x4c>
    800035b0:	8d36                	mv	s10,a3
    800035b2:	bf71                	j	8000354e <readi+0x4c>
      brelse(bp);
    800035b4:	854a                	mv	a0,s2
    800035b6:	ee6ff0ef          	jal	ra,80002c9c <brelse>
      tot = -1;
    800035ba:	59fd                	li	s3,-1
  }
  return tot;
    800035bc:	0009851b          	sext.w	a0,s3
}
    800035c0:	70a6                	ld	ra,104(sp)
    800035c2:	7406                	ld	s0,96(sp)
    800035c4:	64e6                	ld	s1,88(sp)
    800035c6:	6946                	ld	s2,80(sp)
    800035c8:	69a6                	ld	s3,72(sp)
    800035ca:	6a06                	ld	s4,64(sp)
    800035cc:	7ae2                	ld	s5,56(sp)
    800035ce:	7b42                	ld	s6,48(sp)
    800035d0:	7ba2                	ld	s7,40(sp)
    800035d2:	7c02                	ld	s8,32(sp)
    800035d4:	6ce2                	ld	s9,24(sp)
    800035d6:	6d42                	ld	s10,16(sp)
    800035d8:	6da2                	ld	s11,8(sp)
    800035da:	6165                	addi	sp,sp,112
    800035dc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035de:	89d6                	mv	s3,s5
    800035e0:	bff1                	j	800035bc <readi+0xba>
    return 0;
    800035e2:	4501                	li	a0,0
}
    800035e4:	8082                	ret

00000000800035e6 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035e6:	457c                	lw	a5,76(a0)
    800035e8:	0ed7ea63          	bltu	a5,a3,800036dc <writei+0xf6>
{
    800035ec:	7159                	addi	sp,sp,-112
    800035ee:	f486                	sd	ra,104(sp)
    800035f0:	f0a2                	sd	s0,96(sp)
    800035f2:	eca6                	sd	s1,88(sp)
    800035f4:	e8ca                	sd	s2,80(sp)
    800035f6:	e4ce                	sd	s3,72(sp)
    800035f8:	e0d2                	sd	s4,64(sp)
    800035fa:	fc56                	sd	s5,56(sp)
    800035fc:	f85a                	sd	s6,48(sp)
    800035fe:	f45e                	sd	s7,40(sp)
    80003600:	f062                	sd	s8,32(sp)
    80003602:	ec66                	sd	s9,24(sp)
    80003604:	e86a                	sd	s10,16(sp)
    80003606:	e46e                	sd	s11,8(sp)
    80003608:	1880                	addi	s0,sp,112
    8000360a:	8aaa                	mv	s5,a0
    8000360c:	8bae                	mv	s7,a1
    8000360e:	8a32                	mv	s4,a2
    80003610:	8936                	mv	s2,a3
    80003612:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003614:	00e687bb          	addw	a5,a3,a4
    80003618:	0cd7e463          	bltu	a5,a3,800036e0 <writei+0xfa>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000361c:	00043737          	lui	a4,0x43
    80003620:	0cf76263          	bltu	a4,a5,800036e4 <writei+0xfe>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003624:	0a0b0a63          	beqz	s6,800036d8 <writei+0xf2>
    80003628:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000362a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000362e:	5c7d                	li	s8,-1
    80003630:	a825                	j	80003668 <writei+0x82>
    80003632:	020d1d93          	slli	s11,s10,0x20
    80003636:	020ddd93          	srli	s11,s11,0x20
    8000363a:	05848513          	addi	a0,s1,88
    8000363e:	86ee                	mv	a3,s11
    80003640:	8652                	mv	a2,s4
    80003642:	85de                	mv	a1,s7
    80003644:	953a                	add	a0,a0,a4
    80003646:	c45fe0ef          	jal	ra,8000228a <either_copyin>
    8000364a:	05850a63          	beq	a0,s8,8000369e <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000364e:	8526                	mv	a0,s1
    80003650:	670000ef          	jal	ra,80003cc0 <log_write>
    brelse(bp);
    80003654:	8526                	mv	a0,s1
    80003656:	e46ff0ef          	jal	ra,80002c9c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000365a:	013d09bb          	addw	s3,s10,s3
    8000365e:	012d093b          	addw	s2,s10,s2
    80003662:	9a6e                	add	s4,s4,s11
    80003664:	0569f063          	bgeu	s3,s6,800036a4 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003668:	00a9559b          	srliw	a1,s2,0xa
    8000366c:	8556                	mv	a0,s5
    8000366e:	8a1ff0ef          	jal	ra,80002f0e <bmap>
    80003672:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003676:	c59d                	beqz	a1,800036a4 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003678:	000aa503          	lw	a0,0(s5)
    8000367c:	d18ff0ef          	jal	ra,80002b94 <bread>
    80003680:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003682:	3ff97713          	andi	a4,s2,1023
    80003686:	40ec87bb          	subw	a5,s9,a4
    8000368a:	413b06bb          	subw	a3,s6,s3
    8000368e:	8d3e                	mv	s10,a5
    80003690:	2781                	sext.w	a5,a5
    80003692:	0006861b          	sext.w	a2,a3
    80003696:	f8f67ee3          	bgeu	a2,a5,80003632 <writei+0x4c>
    8000369a:	8d36                	mv	s10,a3
    8000369c:	bf59                	j	80003632 <writei+0x4c>
      brelse(bp);
    8000369e:	8526                	mv	a0,s1
    800036a0:	dfcff0ef          	jal	ra,80002c9c <brelse>
  }

  if(off > ip->size)
    800036a4:	04caa783          	lw	a5,76(s5)
    800036a8:	0127f463          	bgeu	a5,s2,800036b0 <writei+0xca>
    ip->size = off;
    800036ac:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800036b0:	8556                	mv	a0,s5
    800036b2:	b4fff0ef          	jal	ra,80003200 <iupdate>

  return tot;
    800036b6:	0009851b          	sext.w	a0,s3
}
    800036ba:	70a6                	ld	ra,104(sp)
    800036bc:	7406                	ld	s0,96(sp)
    800036be:	64e6                	ld	s1,88(sp)
    800036c0:	6946                	ld	s2,80(sp)
    800036c2:	69a6                	ld	s3,72(sp)
    800036c4:	6a06                	ld	s4,64(sp)
    800036c6:	7ae2                	ld	s5,56(sp)
    800036c8:	7b42                	ld	s6,48(sp)
    800036ca:	7ba2                	ld	s7,40(sp)
    800036cc:	7c02                	ld	s8,32(sp)
    800036ce:	6ce2                	ld	s9,24(sp)
    800036d0:	6d42                	ld	s10,16(sp)
    800036d2:	6da2                	ld	s11,8(sp)
    800036d4:	6165                	addi	sp,sp,112
    800036d6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036d8:	89da                	mv	s3,s6
    800036da:	bfd9                	j	800036b0 <writei+0xca>
    return -1;
    800036dc:	557d                	li	a0,-1
}
    800036de:	8082                	ret
    return -1;
    800036e0:	557d                	li	a0,-1
    800036e2:	bfe1                	j	800036ba <writei+0xd4>
    return -1;
    800036e4:	557d                	li	a0,-1
    800036e6:	bfd1                	j	800036ba <writei+0xd4>

00000000800036e8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800036e8:	1141                	addi	sp,sp,-16
    800036ea:	e406                	sd	ra,8(sp)
    800036ec:	e022                	sd	s0,0(sp)
    800036ee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800036f0:	4639                	li	a2,14
    800036f2:	e5efd0ef          	jal	ra,80000d50 <strncmp>
}
    800036f6:	60a2                	ld	ra,8(sp)
    800036f8:	6402                	ld	s0,0(sp)
    800036fa:	0141                	addi	sp,sp,16
    800036fc:	8082                	ret

00000000800036fe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800036fe:	7139                	addi	sp,sp,-64
    80003700:	fc06                	sd	ra,56(sp)
    80003702:	f822                	sd	s0,48(sp)
    80003704:	f426                	sd	s1,40(sp)
    80003706:	f04a                	sd	s2,32(sp)
    80003708:	ec4e                	sd	s3,24(sp)
    8000370a:	e852                	sd	s4,16(sp)
    8000370c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000370e:	04451703          	lh	a4,68(a0)
    80003712:	4785                	li	a5,1
    80003714:	00f71a63          	bne	a4,a5,80003728 <dirlookup+0x2a>
    80003718:	892a                	mv	s2,a0
    8000371a:	89ae                	mv	s3,a1
    8000371c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000371e:	457c                	lw	a5,76(a0)
    80003720:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003722:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003724:	e39d                	bnez	a5,8000374a <dirlookup+0x4c>
    80003726:	a095                	j	8000378a <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003728:	00004517          	auipc	a0,0x4
    8000372c:	f8050513          	addi	a0,a0,-128 # 800076a8 <syscalls+0x1b0>
    80003730:	82cfd0ef          	jal	ra,8000075c <panic>
      panic("dirlookup read");
    80003734:	00004517          	auipc	a0,0x4
    80003738:	f8c50513          	addi	a0,a0,-116 # 800076c0 <syscalls+0x1c8>
    8000373c:	820fd0ef          	jal	ra,8000075c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003740:	24c1                	addiw	s1,s1,16
    80003742:	04c92783          	lw	a5,76(s2)
    80003746:	04f4f163          	bgeu	s1,a5,80003788 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000374a:	4741                	li	a4,16
    8000374c:	86a6                	mv	a3,s1
    8000374e:	fc040613          	addi	a2,s0,-64
    80003752:	4581                	li	a1,0
    80003754:	854a                	mv	a0,s2
    80003756:	dadff0ef          	jal	ra,80003502 <readi>
    8000375a:	47c1                	li	a5,16
    8000375c:	fcf51ce3          	bne	a0,a5,80003734 <dirlookup+0x36>
    if(de.inum == 0)
    80003760:	fc045783          	lhu	a5,-64(s0)
    80003764:	dff1                	beqz	a5,80003740 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003766:	fc240593          	addi	a1,s0,-62
    8000376a:	854e                	mv	a0,s3
    8000376c:	f7dff0ef          	jal	ra,800036e8 <namecmp>
    80003770:	f961                	bnez	a0,80003740 <dirlookup+0x42>
      if(poff)
    80003772:	000a0463          	beqz	s4,8000377a <dirlookup+0x7c>
        *poff = off;
    80003776:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000377a:	fc045583          	lhu	a1,-64(s0)
    8000377e:	00092503          	lw	a0,0(s2)
    80003782:	859ff0ef          	jal	ra,80002fda <iget>
    80003786:	a011                	j	8000378a <dirlookup+0x8c>
  return 0;
    80003788:	4501                	li	a0,0
}
    8000378a:	70e2                	ld	ra,56(sp)
    8000378c:	7442                	ld	s0,48(sp)
    8000378e:	74a2                	ld	s1,40(sp)
    80003790:	7902                	ld	s2,32(sp)
    80003792:	69e2                	ld	s3,24(sp)
    80003794:	6a42                	ld	s4,16(sp)
    80003796:	6121                	addi	sp,sp,64
    80003798:	8082                	ret

000000008000379a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000379a:	711d                	addi	sp,sp,-96
    8000379c:	ec86                	sd	ra,88(sp)
    8000379e:	e8a2                	sd	s0,80(sp)
    800037a0:	e4a6                	sd	s1,72(sp)
    800037a2:	e0ca                	sd	s2,64(sp)
    800037a4:	fc4e                	sd	s3,56(sp)
    800037a6:	f852                	sd	s4,48(sp)
    800037a8:	f456                	sd	s5,40(sp)
    800037aa:	f05a                	sd	s6,32(sp)
    800037ac:	ec5e                	sd	s7,24(sp)
    800037ae:	e862                	sd	s8,16(sp)
    800037b0:	e466                	sd	s9,8(sp)
    800037b2:	1080                	addi	s0,sp,96
    800037b4:	84aa                	mv	s1,a0
    800037b6:	8b2e                	mv	s6,a1
    800037b8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800037ba:	00054703          	lbu	a4,0(a0)
    800037be:	02f00793          	li	a5,47
    800037c2:	00f70f63          	beq	a4,a5,800037e0 <namex+0x46>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800037c6:	956fe0ef          	jal	ra,8000191c <myproc>
    800037ca:	15053503          	ld	a0,336(a0)
    800037ce:	aafff0ef          	jal	ra,8000327c <idup>
    800037d2:	89aa                	mv	s3,a0
  while(*path == '/')
    800037d4:	02f00913          	li	s2,47
  len = path - s;
    800037d8:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    800037da:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800037dc:	4c05                	li	s8,1
    800037de:	a861                	j	80003876 <namex+0xdc>
    ip = iget(ROOTDEV, ROOTINO);
    800037e0:	4585                	li	a1,1
    800037e2:	4505                	li	a0,1
    800037e4:	ff6ff0ef          	jal	ra,80002fda <iget>
    800037e8:	89aa                	mv	s3,a0
    800037ea:	b7ed                	j	800037d4 <namex+0x3a>
      iunlockput(ip);
    800037ec:	854e                	mv	a0,s3
    800037ee:	ccbff0ef          	jal	ra,800034b8 <iunlockput>
      return 0;
    800037f2:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800037f4:	854e                	mv	a0,s3
    800037f6:	60e6                	ld	ra,88(sp)
    800037f8:	6446                	ld	s0,80(sp)
    800037fa:	64a6                	ld	s1,72(sp)
    800037fc:	6906                	ld	s2,64(sp)
    800037fe:	79e2                	ld	s3,56(sp)
    80003800:	7a42                	ld	s4,48(sp)
    80003802:	7aa2                	ld	s5,40(sp)
    80003804:	7b02                	ld	s6,32(sp)
    80003806:	6be2                	ld	s7,24(sp)
    80003808:	6c42                	ld	s8,16(sp)
    8000380a:	6ca2                	ld	s9,8(sp)
    8000380c:	6125                	addi	sp,sp,96
    8000380e:	8082                	ret
      iunlock(ip);
    80003810:	854e                	mv	a0,s3
    80003812:	b4bff0ef          	jal	ra,8000335c <iunlock>
      return ip;
    80003816:	bff9                	j	800037f4 <namex+0x5a>
      iunlockput(ip);
    80003818:	854e                	mv	a0,s3
    8000381a:	c9fff0ef          	jal	ra,800034b8 <iunlockput>
      return 0;
    8000381e:	89d2                	mv	s3,s4
    80003820:	bfd1                	j	800037f4 <namex+0x5a>
  len = path - s;
    80003822:	40b48633          	sub	a2,s1,a1
    80003826:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    8000382a:	074cdc63          	bge	s9,s4,800038a2 <namex+0x108>
    memmove(name, s, DIRSIZ);
    8000382e:	4639                	li	a2,14
    80003830:	8556                	mv	a0,s5
    80003832:	caafd0ef          	jal	ra,80000cdc <memmove>
  while(*path == '/')
    80003836:	0004c783          	lbu	a5,0(s1)
    8000383a:	01279763          	bne	a5,s2,80003848 <namex+0xae>
    path++;
    8000383e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003840:	0004c783          	lbu	a5,0(s1)
    80003844:	ff278de3          	beq	a5,s2,8000383e <namex+0xa4>
    ilock(ip);
    80003848:	854e                	mv	a0,s3
    8000384a:	a69ff0ef          	jal	ra,800032b2 <ilock>
    if(ip->type != T_DIR){
    8000384e:	04499783          	lh	a5,68(s3)
    80003852:	f9879de3          	bne	a5,s8,800037ec <namex+0x52>
    if(nameiparent && *path == '\0'){
    80003856:	000b0563          	beqz	s6,80003860 <namex+0xc6>
    8000385a:	0004c783          	lbu	a5,0(s1)
    8000385e:	dbcd                	beqz	a5,80003810 <namex+0x76>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003860:	865e                	mv	a2,s7
    80003862:	85d6                	mv	a1,s5
    80003864:	854e                	mv	a0,s3
    80003866:	e99ff0ef          	jal	ra,800036fe <dirlookup>
    8000386a:	8a2a                	mv	s4,a0
    8000386c:	d555                	beqz	a0,80003818 <namex+0x7e>
    iunlockput(ip);
    8000386e:	854e                	mv	a0,s3
    80003870:	c49ff0ef          	jal	ra,800034b8 <iunlockput>
    ip = next;
    80003874:	89d2                	mv	s3,s4
  while(*path == '/')
    80003876:	0004c783          	lbu	a5,0(s1)
    8000387a:	05279363          	bne	a5,s2,800038c0 <namex+0x126>
    path++;
    8000387e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003880:	0004c783          	lbu	a5,0(s1)
    80003884:	ff278de3          	beq	a5,s2,8000387e <namex+0xe4>
  if(*path == 0)
    80003888:	c78d                	beqz	a5,800038b2 <namex+0x118>
    path++;
    8000388a:	85a6                	mv	a1,s1
  len = path - s;
    8000388c:	8a5e                	mv	s4,s7
    8000388e:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003890:	01278963          	beq	a5,s2,800038a2 <namex+0x108>
    80003894:	d7d9                	beqz	a5,80003822 <namex+0x88>
    path++;
    80003896:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003898:	0004c783          	lbu	a5,0(s1)
    8000389c:	ff279ce3          	bne	a5,s2,80003894 <namex+0xfa>
    800038a0:	b749                	j	80003822 <namex+0x88>
    memmove(name, s, len);
    800038a2:	2601                	sext.w	a2,a2
    800038a4:	8556                	mv	a0,s5
    800038a6:	c36fd0ef          	jal	ra,80000cdc <memmove>
    name[len] = 0;
    800038aa:	9a56                	add	s4,s4,s5
    800038ac:	000a0023          	sb	zero,0(s4)
    800038b0:	b759                	j	80003836 <namex+0x9c>
  if(nameiparent){
    800038b2:	f40b01e3          	beqz	s6,800037f4 <namex+0x5a>
    iput(ip);
    800038b6:	854e                	mv	a0,s3
    800038b8:	b79ff0ef          	jal	ra,80003430 <iput>
    return 0;
    800038bc:	4981                	li	s3,0
    800038be:	bf1d                	j	800037f4 <namex+0x5a>
  if(*path == 0)
    800038c0:	dbed                	beqz	a5,800038b2 <namex+0x118>
  while(*path != '/' && *path != 0)
    800038c2:	0004c783          	lbu	a5,0(s1)
    800038c6:	85a6                	mv	a1,s1
    800038c8:	b7f1                	j	80003894 <namex+0xfa>

00000000800038ca <dirlink>:
{
    800038ca:	7139                	addi	sp,sp,-64
    800038cc:	fc06                	sd	ra,56(sp)
    800038ce:	f822                	sd	s0,48(sp)
    800038d0:	f426                	sd	s1,40(sp)
    800038d2:	f04a                	sd	s2,32(sp)
    800038d4:	ec4e                	sd	s3,24(sp)
    800038d6:	e852                	sd	s4,16(sp)
    800038d8:	0080                	addi	s0,sp,64
    800038da:	892a                	mv	s2,a0
    800038dc:	8a2e                	mv	s4,a1
    800038de:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800038e0:	4601                	li	a2,0
    800038e2:	e1dff0ef          	jal	ra,800036fe <dirlookup>
    800038e6:	e52d                	bnez	a0,80003950 <dirlink+0x86>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038e8:	04c92483          	lw	s1,76(s2)
    800038ec:	c48d                	beqz	s1,80003916 <dirlink+0x4c>
    800038ee:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038f0:	4741                	li	a4,16
    800038f2:	86a6                	mv	a3,s1
    800038f4:	fc040613          	addi	a2,s0,-64
    800038f8:	4581                	li	a1,0
    800038fa:	854a                	mv	a0,s2
    800038fc:	c07ff0ef          	jal	ra,80003502 <readi>
    80003900:	47c1                	li	a5,16
    80003902:	04f51b63          	bne	a0,a5,80003958 <dirlink+0x8e>
    if(de.inum == 0)
    80003906:	fc045783          	lhu	a5,-64(s0)
    8000390a:	c791                	beqz	a5,80003916 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000390c:	24c1                	addiw	s1,s1,16
    8000390e:	04c92783          	lw	a5,76(s2)
    80003912:	fcf4efe3          	bltu	s1,a5,800038f0 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003916:	4639                	li	a2,14
    80003918:	85d2                	mv	a1,s4
    8000391a:	fc240513          	addi	a0,s0,-62
    8000391e:	c6efd0ef          	jal	ra,80000d8c <strncpy>
  de.inum = inum;
    80003922:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003926:	4741                	li	a4,16
    80003928:	86a6                	mv	a3,s1
    8000392a:	fc040613          	addi	a2,s0,-64
    8000392e:	4581                	li	a1,0
    80003930:	854a                	mv	a0,s2
    80003932:	cb5ff0ef          	jal	ra,800035e6 <writei>
    80003936:	1541                	addi	a0,a0,-16
    80003938:	00a03533          	snez	a0,a0
    8000393c:	40a00533          	neg	a0,a0
}
    80003940:	70e2                	ld	ra,56(sp)
    80003942:	7442                	ld	s0,48(sp)
    80003944:	74a2                	ld	s1,40(sp)
    80003946:	7902                	ld	s2,32(sp)
    80003948:	69e2                	ld	s3,24(sp)
    8000394a:	6a42                	ld	s4,16(sp)
    8000394c:	6121                	addi	sp,sp,64
    8000394e:	8082                	ret
    iput(ip);
    80003950:	ae1ff0ef          	jal	ra,80003430 <iput>
    return -1;
    80003954:	557d                	li	a0,-1
    80003956:	b7ed                	j	80003940 <dirlink+0x76>
      panic("dirlink read");
    80003958:	00004517          	auipc	a0,0x4
    8000395c:	d7850513          	addi	a0,a0,-648 # 800076d0 <syscalls+0x1d8>
    80003960:	dfdfc0ef          	jal	ra,8000075c <panic>

0000000080003964 <namei>:

struct inode*
namei(char *path)
{
    80003964:	1101                	addi	sp,sp,-32
    80003966:	ec06                	sd	ra,24(sp)
    80003968:	e822                	sd	s0,16(sp)
    8000396a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000396c:	fe040613          	addi	a2,s0,-32
    80003970:	4581                	li	a1,0
    80003972:	e29ff0ef          	jal	ra,8000379a <namex>
}
    80003976:	60e2                	ld	ra,24(sp)
    80003978:	6442                	ld	s0,16(sp)
    8000397a:	6105                	addi	sp,sp,32
    8000397c:	8082                	ret

000000008000397e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000397e:	1141                	addi	sp,sp,-16
    80003980:	e406                	sd	ra,8(sp)
    80003982:	e022                	sd	s0,0(sp)
    80003984:	0800                	addi	s0,sp,16
    80003986:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003988:	4585                	li	a1,1
    8000398a:	e11ff0ef          	jal	ra,8000379a <namex>
}
    8000398e:	60a2                	ld	ra,8(sp)
    80003990:	6402                	ld	s0,0(sp)
    80003992:	0141                	addi	sp,sp,16
    80003994:	8082                	ret

0000000080003996 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003996:	1101                	addi	sp,sp,-32
    80003998:	ec06                	sd	ra,24(sp)
    8000399a:	e822                	sd	s0,16(sp)
    8000399c:	e426                	sd	s1,8(sp)
    8000399e:	e04a                	sd	s2,0(sp)
    800039a0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800039a2:	0001c917          	auipc	s2,0x1c
    800039a6:	0fe90913          	addi	s2,s2,254 # 8001faa0 <log>
    800039aa:	01892583          	lw	a1,24(s2)
    800039ae:	02892503          	lw	a0,40(s2)
    800039b2:	9e2ff0ef          	jal	ra,80002b94 <bread>
    800039b6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800039b8:	02c92683          	lw	a3,44(s2)
    800039bc:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800039be:	02d05763          	blez	a3,800039ec <write_head+0x56>
    800039c2:	0001c797          	auipc	a5,0x1c
    800039c6:	10e78793          	addi	a5,a5,270 # 8001fad0 <log+0x30>
    800039ca:	05c50713          	addi	a4,a0,92
    800039ce:	36fd                	addiw	a3,a3,-1
    800039d0:	1682                	slli	a3,a3,0x20
    800039d2:	9281                	srli	a3,a3,0x20
    800039d4:	068a                	slli	a3,a3,0x2
    800039d6:	0001c617          	auipc	a2,0x1c
    800039da:	0fe60613          	addi	a2,a2,254 # 8001fad4 <log+0x34>
    800039de:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800039e0:	4390                	lw	a2,0(a5)
    800039e2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800039e4:	0791                	addi	a5,a5,4
    800039e6:	0711                	addi	a4,a4,4
    800039e8:	fed79ce3          	bne	a5,a3,800039e0 <write_head+0x4a>
  }
  bwrite(buf);
    800039ec:	8526                	mv	a0,s1
    800039ee:	a7cff0ef          	jal	ra,80002c6a <bwrite>
  brelse(buf);
    800039f2:	8526                	mv	a0,s1
    800039f4:	aa8ff0ef          	jal	ra,80002c9c <brelse>
}
    800039f8:	60e2                	ld	ra,24(sp)
    800039fa:	6442                	ld	s0,16(sp)
    800039fc:	64a2                	ld	s1,8(sp)
    800039fe:	6902                	ld	s2,0(sp)
    80003a00:	6105                	addi	sp,sp,32
    80003a02:	8082                	ret

0000000080003a04 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a04:	0001c797          	auipc	a5,0x1c
    80003a08:	0c87a783          	lw	a5,200(a5) # 8001facc <log+0x2c>
    80003a0c:	08f05f63          	blez	a5,80003aaa <install_trans+0xa6>
{
    80003a10:	7139                	addi	sp,sp,-64
    80003a12:	fc06                	sd	ra,56(sp)
    80003a14:	f822                	sd	s0,48(sp)
    80003a16:	f426                	sd	s1,40(sp)
    80003a18:	f04a                	sd	s2,32(sp)
    80003a1a:	ec4e                	sd	s3,24(sp)
    80003a1c:	e852                	sd	s4,16(sp)
    80003a1e:	e456                	sd	s5,8(sp)
    80003a20:	e05a                	sd	s6,0(sp)
    80003a22:	0080                	addi	s0,sp,64
    80003a24:	8b2a                	mv	s6,a0
    80003a26:	0001ca97          	auipc	s5,0x1c
    80003a2a:	0aaa8a93          	addi	s5,s5,170 # 8001fad0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a2e:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a30:	0001c997          	auipc	s3,0x1c
    80003a34:	07098993          	addi	s3,s3,112 # 8001faa0 <log>
    80003a38:	a005                	j	80003a58 <install_trans+0x54>
      bunpin(dbuf);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	b1eff0ef          	jal	ra,80002d5a <bunpin>
    brelse(lbuf);
    80003a40:	854a                	mv	a0,s2
    80003a42:	a5aff0ef          	jal	ra,80002c9c <brelse>
    brelse(dbuf);
    80003a46:	8526                	mv	a0,s1
    80003a48:	a54ff0ef          	jal	ra,80002c9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a4c:	2a05                	addiw	s4,s4,1
    80003a4e:	0a91                	addi	s5,s5,4
    80003a50:	02c9a783          	lw	a5,44(s3)
    80003a54:	04fa5163          	bge	s4,a5,80003a96 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a58:	0189a583          	lw	a1,24(s3)
    80003a5c:	014585bb          	addw	a1,a1,s4
    80003a60:	2585                	addiw	a1,a1,1
    80003a62:	0289a503          	lw	a0,40(s3)
    80003a66:	92eff0ef          	jal	ra,80002b94 <bread>
    80003a6a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a6c:	000aa583          	lw	a1,0(s5)
    80003a70:	0289a503          	lw	a0,40(s3)
    80003a74:	920ff0ef          	jal	ra,80002b94 <bread>
    80003a78:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a7a:	40000613          	li	a2,1024
    80003a7e:	05890593          	addi	a1,s2,88
    80003a82:	05850513          	addi	a0,a0,88
    80003a86:	a56fd0ef          	jal	ra,80000cdc <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a8a:	8526                	mv	a0,s1
    80003a8c:	9deff0ef          	jal	ra,80002c6a <bwrite>
    if(recovering == 0)
    80003a90:	fa0b18e3          	bnez	s6,80003a40 <install_trans+0x3c>
    80003a94:	b75d                	j	80003a3a <install_trans+0x36>
}
    80003a96:	70e2                	ld	ra,56(sp)
    80003a98:	7442                	ld	s0,48(sp)
    80003a9a:	74a2                	ld	s1,40(sp)
    80003a9c:	7902                	ld	s2,32(sp)
    80003a9e:	69e2                	ld	s3,24(sp)
    80003aa0:	6a42                	ld	s4,16(sp)
    80003aa2:	6aa2                	ld	s5,8(sp)
    80003aa4:	6b02                	ld	s6,0(sp)
    80003aa6:	6121                	addi	sp,sp,64
    80003aa8:	8082                	ret
    80003aaa:	8082                	ret

0000000080003aac <initlog>:
{
    80003aac:	7179                	addi	sp,sp,-48
    80003aae:	f406                	sd	ra,40(sp)
    80003ab0:	f022                	sd	s0,32(sp)
    80003ab2:	ec26                	sd	s1,24(sp)
    80003ab4:	e84a                	sd	s2,16(sp)
    80003ab6:	e44e                	sd	s3,8(sp)
    80003ab8:	1800                	addi	s0,sp,48
    80003aba:	892a                	mv	s2,a0
    80003abc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003abe:	0001c497          	auipc	s1,0x1c
    80003ac2:	fe248493          	addi	s1,s1,-30 # 8001faa0 <log>
    80003ac6:	00004597          	auipc	a1,0x4
    80003aca:	c1a58593          	addi	a1,a1,-998 # 800076e0 <syscalls+0x1e8>
    80003ace:	8526                	mv	a0,s1
    80003ad0:	858fd0ef          	jal	ra,80000b28 <initlock>
  log.start = sb->logstart;
    80003ad4:	0149a583          	lw	a1,20(s3)
    80003ad8:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ada:	0109a783          	lw	a5,16(s3)
    80003ade:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ae0:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	8aeff0ef          	jal	ra,80002b94 <bread>
  log.lh.n = lh->n;
    80003aea:	4d3c                	lw	a5,88(a0)
    80003aec:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003aee:	02f05563          	blez	a5,80003b18 <initlog+0x6c>
    80003af2:	05c50713          	addi	a4,a0,92
    80003af6:	0001c697          	auipc	a3,0x1c
    80003afa:	fda68693          	addi	a3,a3,-38 # 8001fad0 <log+0x30>
    80003afe:	37fd                	addiw	a5,a5,-1
    80003b00:	1782                	slli	a5,a5,0x20
    80003b02:	9381                	srli	a5,a5,0x20
    80003b04:	078a                	slli	a5,a5,0x2
    80003b06:	06050613          	addi	a2,a0,96
    80003b0a:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003b0c:	4310                	lw	a2,0(a4)
    80003b0e:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003b10:	0711                	addi	a4,a4,4
    80003b12:	0691                	addi	a3,a3,4
    80003b14:	fef71ce3          	bne	a4,a5,80003b0c <initlog+0x60>
  brelse(buf);
    80003b18:	984ff0ef          	jal	ra,80002c9c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b1c:	4505                	li	a0,1
    80003b1e:	ee7ff0ef          	jal	ra,80003a04 <install_trans>
  log.lh.n = 0;
    80003b22:	0001c797          	auipc	a5,0x1c
    80003b26:	fa07a523          	sw	zero,-86(a5) # 8001facc <log+0x2c>
  write_head(); // clear the log
    80003b2a:	e6dff0ef          	jal	ra,80003996 <write_head>
}
    80003b2e:	70a2                	ld	ra,40(sp)
    80003b30:	7402                	ld	s0,32(sp)
    80003b32:	64e2                	ld	s1,24(sp)
    80003b34:	6942                	ld	s2,16(sp)
    80003b36:	69a2                	ld	s3,8(sp)
    80003b38:	6145                	addi	sp,sp,48
    80003b3a:	8082                	ret

0000000080003b3c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b3c:	1101                	addi	sp,sp,-32
    80003b3e:	ec06                	sd	ra,24(sp)
    80003b40:	e822                	sd	s0,16(sp)
    80003b42:	e426                	sd	s1,8(sp)
    80003b44:	e04a                	sd	s2,0(sp)
    80003b46:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b48:	0001c517          	auipc	a0,0x1c
    80003b4c:	f5850513          	addi	a0,a0,-168 # 8001faa0 <log>
    80003b50:	858fd0ef          	jal	ra,80000ba8 <acquire>
  while(1){
    if(log.committing){
    80003b54:	0001c497          	auipc	s1,0x1c
    80003b58:	f4c48493          	addi	s1,s1,-180 # 8001faa0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b5c:	4979                	li	s2,30
    80003b5e:	a029                	j	80003b68 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b60:	85a6                	mv	a1,s1
    80003b62:	8526                	mv	a0,s1
    80003b64:	b80fe0ef          	jal	ra,80001ee4 <sleep>
    if(log.committing){
    80003b68:	50dc                	lw	a5,36(s1)
    80003b6a:	fbfd                	bnez	a5,80003b60 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b6c:	509c                	lw	a5,32(s1)
    80003b6e:	0017871b          	addiw	a4,a5,1
    80003b72:	0007069b          	sext.w	a3,a4
    80003b76:	0027179b          	slliw	a5,a4,0x2
    80003b7a:	9fb9                	addw	a5,a5,a4
    80003b7c:	0017979b          	slliw	a5,a5,0x1
    80003b80:	54d8                	lw	a4,44(s1)
    80003b82:	9fb9                	addw	a5,a5,a4
    80003b84:	00f95763          	bge	s2,a5,80003b92 <begin_op+0x56>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b88:	85a6                	mv	a1,s1
    80003b8a:	8526                	mv	a0,s1
    80003b8c:	b58fe0ef          	jal	ra,80001ee4 <sleep>
    80003b90:	bfe1                	j	80003b68 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b92:	0001c517          	auipc	a0,0x1c
    80003b96:	f0e50513          	addi	a0,a0,-242 # 8001faa0 <log>
    80003b9a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80003b9c:	8a4fd0ef          	jal	ra,80000c40 <release>
      break;
    }
  }
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6902                	ld	s2,0(sp)
    80003ba8:	6105                	addi	sp,sp,32
    80003baa:	8082                	ret

0000000080003bac <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003bac:	7139                	addi	sp,sp,-64
    80003bae:	fc06                	sd	ra,56(sp)
    80003bb0:	f822                	sd	s0,48(sp)
    80003bb2:	f426                	sd	s1,40(sp)
    80003bb4:	f04a                	sd	s2,32(sp)
    80003bb6:	ec4e                	sd	s3,24(sp)
    80003bb8:	e852                	sd	s4,16(sp)
    80003bba:	e456                	sd	s5,8(sp)
    80003bbc:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003bbe:	0001c497          	auipc	s1,0x1c
    80003bc2:	ee248493          	addi	s1,s1,-286 # 8001faa0 <log>
    80003bc6:	8526                	mv	a0,s1
    80003bc8:	fe1fc0ef          	jal	ra,80000ba8 <acquire>
  log.outstanding -= 1;
    80003bcc:	509c                	lw	a5,32(s1)
    80003bce:	37fd                	addiw	a5,a5,-1
    80003bd0:	0007891b          	sext.w	s2,a5
    80003bd4:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003bd6:	50dc                	lw	a5,36(s1)
    80003bd8:	e7b9                	bnez	a5,80003c26 <end_op+0x7a>
    panic("log.committing");
  if(log.outstanding == 0){
    80003bda:	04091c63          	bnez	s2,80003c32 <end_op+0x86>
    do_commit = 1;
    log.committing = 1;
    80003bde:	0001c497          	auipc	s1,0x1c
    80003be2:	ec248493          	addi	s1,s1,-318 # 8001faa0 <log>
    80003be6:	4785                	li	a5,1
    80003be8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003bea:	8526                	mv	a0,s1
    80003bec:	854fd0ef          	jal	ra,80000c40 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003bf0:	54dc                	lw	a5,44(s1)
    80003bf2:	04f04b63          	bgtz	a5,80003c48 <end_op+0x9c>
    acquire(&log.lock);
    80003bf6:	0001c497          	auipc	s1,0x1c
    80003bfa:	eaa48493          	addi	s1,s1,-342 # 8001faa0 <log>
    80003bfe:	8526                	mv	a0,s1
    80003c00:	fa9fc0ef          	jal	ra,80000ba8 <acquire>
    log.committing = 0;
    80003c04:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003c08:	8526                	mv	a0,s1
    80003c0a:	b26fe0ef          	jal	ra,80001f30 <wakeup>
    release(&log.lock);
    80003c0e:	8526                	mv	a0,s1
    80003c10:	830fd0ef          	jal	ra,80000c40 <release>
}
    80003c14:	70e2                	ld	ra,56(sp)
    80003c16:	7442                	ld	s0,48(sp)
    80003c18:	74a2                	ld	s1,40(sp)
    80003c1a:	7902                	ld	s2,32(sp)
    80003c1c:	69e2                	ld	s3,24(sp)
    80003c1e:	6a42                	ld	s4,16(sp)
    80003c20:	6aa2                	ld	s5,8(sp)
    80003c22:	6121                	addi	sp,sp,64
    80003c24:	8082                	ret
    panic("log.committing");
    80003c26:	00004517          	auipc	a0,0x4
    80003c2a:	ac250513          	addi	a0,a0,-1342 # 800076e8 <syscalls+0x1f0>
    80003c2e:	b2ffc0ef          	jal	ra,8000075c <panic>
    wakeup(&log);
    80003c32:	0001c497          	auipc	s1,0x1c
    80003c36:	e6e48493          	addi	s1,s1,-402 # 8001faa0 <log>
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	af4fe0ef          	jal	ra,80001f30 <wakeup>
  release(&log.lock);
    80003c40:	8526                	mv	a0,s1
    80003c42:	ffffc0ef          	jal	ra,80000c40 <release>
  if(do_commit){
    80003c46:	b7f9                	j	80003c14 <end_op+0x68>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c48:	0001ca97          	auipc	s5,0x1c
    80003c4c:	e88a8a93          	addi	s5,s5,-376 # 8001fad0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c50:	0001ca17          	auipc	s4,0x1c
    80003c54:	e50a0a13          	addi	s4,s4,-432 # 8001faa0 <log>
    80003c58:	018a2583          	lw	a1,24(s4)
    80003c5c:	012585bb          	addw	a1,a1,s2
    80003c60:	2585                	addiw	a1,a1,1
    80003c62:	028a2503          	lw	a0,40(s4)
    80003c66:	f2ffe0ef          	jal	ra,80002b94 <bread>
    80003c6a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c6c:	000aa583          	lw	a1,0(s5)
    80003c70:	028a2503          	lw	a0,40(s4)
    80003c74:	f21fe0ef          	jal	ra,80002b94 <bread>
    80003c78:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c7a:	40000613          	li	a2,1024
    80003c7e:	05850593          	addi	a1,a0,88
    80003c82:	05848513          	addi	a0,s1,88
    80003c86:	856fd0ef          	jal	ra,80000cdc <memmove>
    bwrite(to);  // write the log
    80003c8a:	8526                	mv	a0,s1
    80003c8c:	fdffe0ef          	jal	ra,80002c6a <bwrite>
    brelse(from);
    80003c90:	854e                	mv	a0,s3
    80003c92:	80aff0ef          	jal	ra,80002c9c <brelse>
    brelse(to);
    80003c96:	8526                	mv	a0,s1
    80003c98:	804ff0ef          	jal	ra,80002c9c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c9c:	2905                	addiw	s2,s2,1
    80003c9e:	0a91                	addi	s5,s5,4
    80003ca0:	02ca2783          	lw	a5,44(s4)
    80003ca4:	faf94ae3          	blt	s2,a5,80003c58 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003ca8:	cefff0ef          	jal	ra,80003996 <write_head>
    install_trans(0); // Now install writes to home locations
    80003cac:	4501                	li	a0,0
    80003cae:	d57ff0ef          	jal	ra,80003a04 <install_trans>
    log.lh.n = 0;
    80003cb2:	0001c797          	auipc	a5,0x1c
    80003cb6:	e007ad23          	sw	zero,-486(a5) # 8001facc <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003cba:	cddff0ef          	jal	ra,80003996 <write_head>
    80003cbe:	bf25                	j	80003bf6 <end_op+0x4a>

0000000080003cc0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003cc0:	1101                	addi	sp,sp,-32
    80003cc2:	ec06                	sd	ra,24(sp)
    80003cc4:	e822                	sd	s0,16(sp)
    80003cc6:	e426                	sd	s1,8(sp)
    80003cc8:	e04a                	sd	s2,0(sp)
    80003cca:	1000                	addi	s0,sp,32
    80003ccc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003cce:	0001c917          	auipc	s2,0x1c
    80003cd2:	dd290913          	addi	s2,s2,-558 # 8001faa0 <log>
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	ed1fc0ef          	jal	ra,80000ba8 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003cdc:	02c92603          	lw	a2,44(s2)
    80003ce0:	47f5                	li	a5,29
    80003ce2:	06c7c363          	blt	a5,a2,80003d48 <log_write+0x88>
    80003ce6:	0001c797          	auipc	a5,0x1c
    80003cea:	dd67a783          	lw	a5,-554(a5) # 8001fabc <log+0x1c>
    80003cee:	37fd                	addiw	a5,a5,-1
    80003cf0:	04f65c63          	bge	a2,a5,80003d48 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003cf4:	0001c797          	auipc	a5,0x1c
    80003cf8:	dcc7a783          	lw	a5,-564(a5) # 8001fac0 <log+0x20>
    80003cfc:	04f05c63          	blez	a5,80003d54 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003d00:	4781                	li	a5,0
    80003d02:	04c05f63          	blez	a2,80003d60 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d06:	44cc                	lw	a1,12(s1)
    80003d08:	0001c717          	auipc	a4,0x1c
    80003d0c:	dc870713          	addi	a4,a4,-568 # 8001fad0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003d10:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d12:	4314                	lw	a3,0(a4)
    80003d14:	04b68663          	beq	a3,a1,80003d60 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d18:	2785                	addiw	a5,a5,1
    80003d1a:	0711                	addi	a4,a4,4
    80003d1c:	fef61be3          	bne	a2,a5,80003d12 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d20:	0621                	addi	a2,a2,8
    80003d22:	060a                	slli	a2,a2,0x2
    80003d24:	0001c797          	auipc	a5,0x1c
    80003d28:	d7c78793          	addi	a5,a5,-644 # 8001faa0 <log>
    80003d2c:	963e                	add	a2,a2,a5
    80003d2e:	44dc                	lw	a5,12(s1)
    80003d30:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d32:	8526                	mv	a0,s1
    80003d34:	ff3fe0ef          	jal	ra,80002d26 <bpin>
    log.lh.n++;
    80003d38:	0001c717          	auipc	a4,0x1c
    80003d3c:	d6870713          	addi	a4,a4,-664 # 8001faa0 <log>
    80003d40:	575c                	lw	a5,44(a4)
    80003d42:	2785                	addiw	a5,a5,1
    80003d44:	d75c                	sw	a5,44(a4)
    80003d46:	a815                	j	80003d7a <log_write+0xba>
    panic("too big a transaction");
    80003d48:	00004517          	auipc	a0,0x4
    80003d4c:	9b050513          	addi	a0,a0,-1616 # 800076f8 <syscalls+0x200>
    80003d50:	a0dfc0ef          	jal	ra,8000075c <panic>
    panic("log_write outside of trans");
    80003d54:	00004517          	auipc	a0,0x4
    80003d58:	9bc50513          	addi	a0,a0,-1604 # 80007710 <syscalls+0x218>
    80003d5c:	a01fc0ef          	jal	ra,8000075c <panic>
  log.lh.block[i] = b->blockno;
    80003d60:	00878713          	addi	a4,a5,8
    80003d64:	00271693          	slli	a3,a4,0x2
    80003d68:	0001c717          	auipc	a4,0x1c
    80003d6c:	d3870713          	addi	a4,a4,-712 # 8001faa0 <log>
    80003d70:	9736                	add	a4,a4,a3
    80003d72:	44d4                	lw	a3,12(s1)
    80003d74:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d76:	faf60ee3          	beq	a2,a5,80003d32 <log_write+0x72>
  }
  release(&log.lock);
    80003d7a:	0001c517          	auipc	a0,0x1c
    80003d7e:	d2650513          	addi	a0,a0,-730 # 8001faa0 <log>
    80003d82:	ebffc0ef          	jal	ra,80000c40 <release>
}
    80003d86:	60e2                	ld	ra,24(sp)
    80003d88:	6442                	ld	s0,16(sp)
    80003d8a:	64a2                	ld	s1,8(sp)
    80003d8c:	6902                	ld	s2,0(sp)
    80003d8e:	6105                	addi	sp,sp,32
    80003d90:	8082                	ret

0000000080003d92 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d92:	1101                	addi	sp,sp,-32
    80003d94:	ec06                	sd	ra,24(sp)
    80003d96:	e822                	sd	s0,16(sp)
    80003d98:	e426                	sd	s1,8(sp)
    80003d9a:	e04a                	sd	s2,0(sp)
    80003d9c:	1000                	addi	s0,sp,32
    80003d9e:	84aa                	mv	s1,a0
    80003da0:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003da2:	00004597          	auipc	a1,0x4
    80003da6:	98e58593          	addi	a1,a1,-1650 # 80007730 <syscalls+0x238>
    80003daa:	0521                	addi	a0,a0,8
    80003dac:	d7dfc0ef          	jal	ra,80000b28 <initlock>
  lk->name = name;
    80003db0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003db4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003db8:	0204a423          	sw	zero,40(s1)
}
    80003dbc:	60e2                	ld	ra,24(sp)
    80003dbe:	6442                	ld	s0,16(sp)
    80003dc0:	64a2                	ld	s1,8(sp)
    80003dc2:	6902                	ld	s2,0(sp)
    80003dc4:	6105                	addi	sp,sp,32
    80003dc6:	8082                	ret

0000000080003dc8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	e426                	sd	s1,8(sp)
    80003dd0:	e04a                	sd	s2,0(sp)
    80003dd2:	1000                	addi	s0,sp,32
    80003dd4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dd6:	00850913          	addi	s2,a0,8
    80003dda:	854a                	mv	a0,s2
    80003ddc:	dcdfc0ef          	jal	ra,80000ba8 <acquire>
  while (lk->locked) {
    80003de0:	409c                	lw	a5,0(s1)
    80003de2:	c799                	beqz	a5,80003df0 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003de4:	85ca                	mv	a1,s2
    80003de6:	8526                	mv	a0,s1
    80003de8:	8fcfe0ef          	jal	ra,80001ee4 <sleep>
  while (lk->locked) {
    80003dec:	409c                	lw	a5,0(s1)
    80003dee:	fbfd                	bnez	a5,80003de4 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003df0:	4785                	li	a5,1
    80003df2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003df4:	b29fd0ef          	jal	ra,8000191c <myproc>
    80003df8:	591c                	lw	a5,48(a0)
    80003dfa:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003dfc:	854a                	mv	a0,s2
    80003dfe:	e43fc0ef          	jal	ra,80000c40 <release>
}
    80003e02:	60e2                	ld	ra,24(sp)
    80003e04:	6442                	ld	s0,16(sp)
    80003e06:	64a2                	ld	s1,8(sp)
    80003e08:	6902                	ld	s2,0(sp)
    80003e0a:	6105                	addi	sp,sp,32
    80003e0c:	8082                	ret

0000000080003e0e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003e0e:	1101                	addi	sp,sp,-32
    80003e10:	ec06                	sd	ra,24(sp)
    80003e12:	e822                	sd	s0,16(sp)
    80003e14:	e426                	sd	s1,8(sp)
    80003e16:	e04a                	sd	s2,0(sp)
    80003e18:	1000                	addi	s0,sp,32
    80003e1a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e1c:	00850913          	addi	s2,a0,8
    80003e20:	854a                	mv	a0,s2
    80003e22:	d87fc0ef          	jal	ra,80000ba8 <acquire>
  lk->locked = 0;
    80003e26:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e2a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e2e:	8526                	mv	a0,s1
    80003e30:	900fe0ef          	jal	ra,80001f30 <wakeup>
  release(&lk->lk);
    80003e34:	854a                	mv	a0,s2
    80003e36:	e0bfc0ef          	jal	ra,80000c40 <release>
}
    80003e3a:	60e2                	ld	ra,24(sp)
    80003e3c:	6442                	ld	s0,16(sp)
    80003e3e:	64a2                	ld	s1,8(sp)
    80003e40:	6902                	ld	s2,0(sp)
    80003e42:	6105                	addi	sp,sp,32
    80003e44:	8082                	ret

0000000080003e46 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e46:	7179                	addi	sp,sp,-48
    80003e48:	f406                	sd	ra,40(sp)
    80003e4a:	f022                	sd	s0,32(sp)
    80003e4c:	ec26                	sd	s1,24(sp)
    80003e4e:	e84a                	sd	s2,16(sp)
    80003e50:	e44e                	sd	s3,8(sp)
    80003e52:	1800                	addi	s0,sp,48
    80003e54:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e56:	00850913          	addi	s2,a0,8
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	d4dfc0ef          	jal	ra,80000ba8 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e60:	409c                	lw	a5,0(s1)
    80003e62:	ef89                	bnez	a5,80003e7c <holdingsleep+0x36>
    80003e64:	4481                	li	s1,0
  release(&lk->lk);
    80003e66:	854a                	mv	a0,s2
    80003e68:	dd9fc0ef          	jal	ra,80000c40 <release>
  return r;
}
    80003e6c:	8526                	mv	a0,s1
    80003e6e:	70a2                	ld	ra,40(sp)
    80003e70:	7402                	ld	s0,32(sp)
    80003e72:	64e2                	ld	s1,24(sp)
    80003e74:	6942                	ld	s2,16(sp)
    80003e76:	69a2                	ld	s3,8(sp)
    80003e78:	6145                	addi	sp,sp,48
    80003e7a:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e7c:	0284a983          	lw	s3,40(s1)
    80003e80:	a9dfd0ef          	jal	ra,8000191c <myproc>
    80003e84:	5904                	lw	s1,48(a0)
    80003e86:	413484b3          	sub	s1,s1,s3
    80003e8a:	0014b493          	seqz	s1,s1
    80003e8e:	bfe1                	j	80003e66 <holdingsleep+0x20>

0000000080003e90 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e90:	1141                	addi	sp,sp,-16
    80003e92:	e406                	sd	ra,8(sp)
    80003e94:	e022                	sd	s0,0(sp)
    80003e96:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e98:	00004597          	auipc	a1,0x4
    80003e9c:	8a858593          	addi	a1,a1,-1880 # 80007740 <syscalls+0x248>
    80003ea0:	0001c517          	auipc	a0,0x1c
    80003ea4:	d4850513          	addi	a0,a0,-696 # 8001fbe8 <ftable>
    80003ea8:	c81fc0ef          	jal	ra,80000b28 <initlock>
}
    80003eac:	60a2                	ld	ra,8(sp)
    80003eae:	6402                	ld	s0,0(sp)
    80003eb0:	0141                	addi	sp,sp,16
    80003eb2:	8082                	ret

0000000080003eb4 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003eb4:	1101                	addi	sp,sp,-32
    80003eb6:	ec06                	sd	ra,24(sp)
    80003eb8:	e822                	sd	s0,16(sp)
    80003eba:	e426                	sd	s1,8(sp)
    80003ebc:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003ebe:	0001c517          	auipc	a0,0x1c
    80003ec2:	d2a50513          	addi	a0,a0,-726 # 8001fbe8 <ftable>
    80003ec6:	ce3fc0ef          	jal	ra,80000ba8 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003eca:	0001c497          	auipc	s1,0x1c
    80003ece:	d3648493          	addi	s1,s1,-714 # 8001fc00 <ftable+0x18>
    80003ed2:	0001d717          	auipc	a4,0x1d
    80003ed6:	cce70713          	addi	a4,a4,-818 # 80020ba0 <disk>
    if(f->ref == 0){
    80003eda:	40dc                	lw	a5,4(s1)
    80003edc:	cf89                	beqz	a5,80003ef6 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ede:	02848493          	addi	s1,s1,40
    80003ee2:	fee49ce3          	bne	s1,a4,80003eda <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003ee6:	0001c517          	auipc	a0,0x1c
    80003eea:	d0250513          	addi	a0,a0,-766 # 8001fbe8 <ftable>
    80003eee:	d53fc0ef          	jal	ra,80000c40 <release>
  return 0;
    80003ef2:	4481                	li	s1,0
    80003ef4:	a809                	j	80003f06 <filealloc+0x52>
      f->ref = 1;
    80003ef6:	4785                	li	a5,1
    80003ef8:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003efa:	0001c517          	auipc	a0,0x1c
    80003efe:	cee50513          	addi	a0,a0,-786 # 8001fbe8 <ftable>
    80003f02:	d3ffc0ef          	jal	ra,80000c40 <release>
}
    80003f06:	8526                	mv	a0,s1
    80003f08:	60e2                	ld	ra,24(sp)
    80003f0a:	6442                	ld	s0,16(sp)
    80003f0c:	64a2                	ld	s1,8(sp)
    80003f0e:	6105                	addi	sp,sp,32
    80003f10:	8082                	ret

0000000080003f12 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003f12:	1101                	addi	sp,sp,-32
    80003f14:	ec06                	sd	ra,24(sp)
    80003f16:	e822                	sd	s0,16(sp)
    80003f18:	e426                	sd	s1,8(sp)
    80003f1a:	1000                	addi	s0,sp,32
    80003f1c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f1e:	0001c517          	auipc	a0,0x1c
    80003f22:	cca50513          	addi	a0,a0,-822 # 8001fbe8 <ftable>
    80003f26:	c83fc0ef          	jal	ra,80000ba8 <acquire>
  if(f->ref < 1)
    80003f2a:	40dc                	lw	a5,4(s1)
    80003f2c:	02f05063          	blez	a5,80003f4c <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f30:	2785                	addiw	a5,a5,1
    80003f32:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f34:	0001c517          	auipc	a0,0x1c
    80003f38:	cb450513          	addi	a0,a0,-844 # 8001fbe8 <ftable>
    80003f3c:	d05fc0ef          	jal	ra,80000c40 <release>
  return f;
}
    80003f40:	8526                	mv	a0,s1
    80003f42:	60e2                	ld	ra,24(sp)
    80003f44:	6442                	ld	s0,16(sp)
    80003f46:	64a2                	ld	s1,8(sp)
    80003f48:	6105                	addi	sp,sp,32
    80003f4a:	8082                	ret
    panic("filedup");
    80003f4c:	00003517          	auipc	a0,0x3
    80003f50:	7fc50513          	addi	a0,a0,2044 # 80007748 <syscalls+0x250>
    80003f54:	809fc0ef          	jal	ra,8000075c <panic>

0000000080003f58 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f58:	7139                	addi	sp,sp,-64
    80003f5a:	fc06                	sd	ra,56(sp)
    80003f5c:	f822                	sd	s0,48(sp)
    80003f5e:	f426                	sd	s1,40(sp)
    80003f60:	f04a                	sd	s2,32(sp)
    80003f62:	ec4e                	sd	s3,24(sp)
    80003f64:	e852                	sd	s4,16(sp)
    80003f66:	e456                	sd	s5,8(sp)
    80003f68:	0080                	addi	s0,sp,64
    80003f6a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f6c:	0001c517          	auipc	a0,0x1c
    80003f70:	c7c50513          	addi	a0,a0,-900 # 8001fbe8 <ftable>
    80003f74:	c35fc0ef          	jal	ra,80000ba8 <acquire>
  if(f->ref < 1)
    80003f78:	40dc                	lw	a5,4(s1)
    80003f7a:	04f05963          	blez	a5,80003fcc <fileclose+0x74>
    panic("fileclose");
  if(--f->ref > 0){
    80003f7e:	37fd                	addiw	a5,a5,-1
    80003f80:	0007871b          	sext.w	a4,a5
    80003f84:	c0dc                	sw	a5,4(s1)
    80003f86:	04e04963          	bgtz	a4,80003fd8 <fileclose+0x80>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f8a:	0004a903          	lw	s2,0(s1)
    80003f8e:	0094ca83          	lbu	s5,9(s1)
    80003f92:	0104ba03          	ld	s4,16(s1)
    80003f96:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f9a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f9e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003fa2:	0001c517          	auipc	a0,0x1c
    80003fa6:	c4650513          	addi	a0,a0,-954 # 8001fbe8 <ftable>
    80003faa:	c97fc0ef          	jal	ra,80000c40 <release>

  if(ff.type == FD_PIPE){
    80003fae:	4785                	li	a5,1
    80003fb0:	04f90363          	beq	s2,a5,80003ff6 <fileclose+0x9e>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003fb4:	3979                	addiw	s2,s2,-2
    80003fb6:	4785                	li	a5,1
    80003fb8:	0327e663          	bltu	a5,s2,80003fe4 <fileclose+0x8c>
    begin_op();
    80003fbc:	b81ff0ef          	jal	ra,80003b3c <begin_op>
    iput(ff.ip);
    80003fc0:	854e                	mv	a0,s3
    80003fc2:	c6eff0ef          	jal	ra,80003430 <iput>
    end_op();
    80003fc6:	be7ff0ef          	jal	ra,80003bac <end_op>
    80003fca:	a829                	j	80003fe4 <fileclose+0x8c>
    panic("fileclose");
    80003fcc:	00003517          	auipc	a0,0x3
    80003fd0:	78450513          	addi	a0,a0,1924 # 80007750 <syscalls+0x258>
    80003fd4:	f88fc0ef          	jal	ra,8000075c <panic>
    release(&ftable.lock);
    80003fd8:	0001c517          	auipc	a0,0x1c
    80003fdc:	c1050513          	addi	a0,a0,-1008 # 8001fbe8 <ftable>
    80003fe0:	c61fc0ef          	jal	ra,80000c40 <release>
  }
}
    80003fe4:	70e2                	ld	ra,56(sp)
    80003fe6:	7442                	ld	s0,48(sp)
    80003fe8:	74a2                	ld	s1,40(sp)
    80003fea:	7902                	ld	s2,32(sp)
    80003fec:	69e2                	ld	s3,24(sp)
    80003fee:	6a42                	ld	s4,16(sp)
    80003ff0:	6aa2                	ld	s5,8(sp)
    80003ff2:	6121                	addi	sp,sp,64
    80003ff4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003ff6:	85d6                	mv	a1,s5
    80003ff8:	8552                	mv	a0,s4
    80003ffa:	2ec000ef          	jal	ra,800042e6 <pipeclose>
    80003ffe:	b7dd                	j	80003fe4 <fileclose+0x8c>

0000000080004000 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004000:	715d                	addi	sp,sp,-80
    80004002:	e486                	sd	ra,72(sp)
    80004004:	e0a2                	sd	s0,64(sp)
    80004006:	fc26                	sd	s1,56(sp)
    80004008:	f84a                	sd	s2,48(sp)
    8000400a:	f44e                	sd	s3,40(sp)
    8000400c:	0880                	addi	s0,sp,80
    8000400e:	84aa                	mv	s1,a0
    80004010:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004012:	90bfd0ef          	jal	ra,8000191c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004016:	409c                	lw	a5,0(s1)
    80004018:	37f9                	addiw	a5,a5,-2
    8000401a:	4705                	li	a4,1
    8000401c:	02f76f63          	bltu	a4,a5,8000405a <filestat+0x5a>
    80004020:	892a                	mv	s2,a0
    ilock(f->ip);
    80004022:	6c88                	ld	a0,24(s1)
    80004024:	a8eff0ef          	jal	ra,800032b2 <ilock>
    stati(f->ip, &st);
    80004028:	fb840593          	addi	a1,s0,-72
    8000402c:	6c88                	ld	a0,24(s1)
    8000402e:	caaff0ef          	jal	ra,800034d8 <stati>
    iunlock(f->ip);
    80004032:	6c88                	ld	a0,24(s1)
    80004034:	b28ff0ef          	jal	ra,8000335c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004038:	46e1                	li	a3,24
    8000403a:	fb840613          	addi	a2,s0,-72
    8000403e:	85ce                	mv	a1,s3
    80004040:	05093503          	ld	a0,80(s2)
    80004044:	cb2fd0ef          	jal	ra,800014f6 <copyout>
    80004048:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000404c:	60a6                	ld	ra,72(sp)
    8000404e:	6406                	ld	s0,64(sp)
    80004050:	74e2                	ld	s1,56(sp)
    80004052:	7942                	ld	s2,48(sp)
    80004054:	79a2                	ld	s3,40(sp)
    80004056:	6161                	addi	sp,sp,80
    80004058:	8082                	ret
  return -1;
    8000405a:	557d                	li	a0,-1
    8000405c:	bfc5                	j	8000404c <filestat+0x4c>

000000008000405e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000405e:	7179                	addi	sp,sp,-48
    80004060:	f406                	sd	ra,40(sp)
    80004062:	f022                	sd	s0,32(sp)
    80004064:	ec26                	sd	s1,24(sp)
    80004066:	e84a                	sd	s2,16(sp)
    80004068:	e44e                	sd	s3,8(sp)
    8000406a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000406c:	00854783          	lbu	a5,8(a0)
    80004070:	cbc1                	beqz	a5,80004100 <fileread+0xa2>
    80004072:	84aa                	mv	s1,a0
    80004074:	89ae                	mv	s3,a1
    80004076:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004078:	411c                	lw	a5,0(a0)
    8000407a:	4705                	li	a4,1
    8000407c:	04e78363          	beq	a5,a4,800040c2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004080:	470d                	li	a4,3
    80004082:	04e78563          	beq	a5,a4,800040cc <fileread+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004086:	4709                	li	a4,2
    80004088:	06e79663          	bne	a5,a4,800040f4 <fileread+0x96>
    ilock(f->ip);
    8000408c:	6d08                	ld	a0,24(a0)
    8000408e:	a24ff0ef          	jal	ra,800032b2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004092:	874a                	mv	a4,s2
    80004094:	5094                	lw	a3,32(s1)
    80004096:	864e                	mv	a2,s3
    80004098:	4585                	li	a1,1
    8000409a:	6c88                	ld	a0,24(s1)
    8000409c:	c66ff0ef          	jal	ra,80003502 <readi>
    800040a0:	892a                	mv	s2,a0
    800040a2:	00a05563          	blez	a0,800040ac <fileread+0x4e>
      f->off += r;
    800040a6:	509c                	lw	a5,32(s1)
    800040a8:	9fa9                	addw	a5,a5,a0
    800040aa:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800040ac:	6c88                	ld	a0,24(s1)
    800040ae:	aaeff0ef          	jal	ra,8000335c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800040b2:	854a                	mv	a0,s2
    800040b4:	70a2                	ld	ra,40(sp)
    800040b6:	7402                	ld	s0,32(sp)
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	6942                	ld	s2,16(sp)
    800040bc:	69a2                	ld	s3,8(sp)
    800040be:	6145                	addi	sp,sp,48
    800040c0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800040c2:	6908                	ld	a0,16(a0)
    800040c4:	356000ef          	jal	ra,8000441a <piperead>
    800040c8:	892a                	mv	s2,a0
    800040ca:	b7e5                	j	800040b2 <fileread+0x54>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800040cc:	02451783          	lh	a5,36(a0)
    800040d0:	03079693          	slli	a3,a5,0x30
    800040d4:	92c1                	srli	a3,a3,0x30
    800040d6:	4725                	li	a4,9
    800040d8:	02d76663          	bltu	a4,a3,80004104 <fileread+0xa6>
    800040dc:	0792                	slli	a5,a5,0x4
    800040de:	0001c717          	auipc	a4,0x1c
    800040e2:	a6a70713          	addi	a4,a4,-1430 # 8001fb48 <devsw>
    800040e6:	97ba                	add	a5,a5,a4
    800040e8:	639c                	ld	a5,0(a5)
    800040ea:	cf99                	beqz	a5,80004108 <fileread+0xaa>
    r = devsw[f->major].read(1, addr, n);
    800040ec:	4505                	li	a0,1
    800040ee:	9782                	jalr	a5
    800040f0:	892a                	mv	s2,a0
    800040f2:	b7c1                	j	800040b2 <fileread+0x54>
    panic("fileread");
    800040f4:	00003517          	auipc	a0,0x3
    800040f8:	66c50513          	addi	a0,a0,1644 # 80007760 <syscalls+0x268>
    800040fc:	e60fc0ef          	jal	ra,8000075c <panic>
    return -1;
    80004100:	597d                	li	s2,-1
    80004102:	bf45                	j	800040b2 <fileread+0x54>
      return -1;
    80004104:	597d                	li	s2,-1
    80004106:	b775                	j	800040b2 <fileread+0x54>
    80004108:	597d                	li	s2,-1
    8000410a:	b765                	j	800040b2 <fileread+0x54>

000000008000410c <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    8000410c:	715d                	addi	sp,sp,-80
    8000410e:	e486                	sd	ra,72(sp)
    80004110:	e0a2                	sd	s0,64(sp)
    80004112:	fc26                	sd	s1,56(sp)
    80004114:	f84a                	sd	s2,48(sp)
    80004116:	f44e                	sd	s3,40(sp)
    80004118:	f052                	sd	s4,32(sp)
    8000411a:	ec56                	sd	s5,24(sp)
    8000411c:	e85a                	sd	s6,16(sp)
    8000411e:	e45e                	sd	s7,8(sp)
    80004120:	e062                	sd	s8,0(sp)
    80004122:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004124:	00954783          	lbu	a5,9(a0)
    80004128:	0e078863          	beqz	a5,80004218 <filewrite+0x10c>
    8000412c:	892a                	mv	s2,a0
    8000412e:	8aae                	mv	s5,a1
    80004130:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004132:	411c                	lw	a5,0(a0)
    80004134:	4705                	li	a4,1
    80004136:	02e78263          	beq	a5,a4,8000415a <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000413a:	470d                	li	a4,3
    8000413c:	02e78463          	beq	a5,a4,80004164 <filewrite+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004140:	4709                	li	a4,2
    80004142:	0ce79563          	bne	a5,a4,8000420c <filewrite+0x100>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004146:	0ac05163          	blez	a2,800041e8 <filewrite+0xdc>
    int i = 0;
    8000414a:	4981                	li	s3,0
    8000414c:	6b05                	lui	s6,0x1
    8000414e:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80004152:	6b85                	lui	s7,0x1
    80004154:	c00b8b9b          	addiw	s7,s7,-1024
    80004158:	a041                	j	800041d8 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    8000415a:	6908                	ld	a0,16(a0)
    8000415c:	1e2000ef          	jal	ra,8000433e <pipewrite>
    80004160:	8a2a                	mv	s4,a0
    80004162:	a071                	j	800041ee <filewrite+0xe2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004164:	02451783          	lh	a5,36(a0)
    80004168:	03079693          	slli	a3,a5,0x30
    8000416c:	92c1                	srli	a3,a3,0x30
    8000416e:	4725                	li	a4,9
    80004170:	0ad76663          	bltu	a4,a3,8000421c <filewrite+0x110>
    80004174:	0792                	slli	a5,a5,0x4
    80004176:	0001c717          	auipc	a4,0x1c
    8000417a:	9d270713          	addi	a4,a4,-1582 # 8001fb48 <devsw>
    8000417e:	97ba                	add	a5,a5,a4
    80004180:	679c                	ld	a5,8(a5)
    80004182:	cfd9                	beqz	a5,80004220 <filewrite+0x114>
    ret = devsw[f->major].write(1, addr, n);
    80004184:	4505                	li	a0,1
    80004186:	9782                	jalr	a5
    80004188:	8a2a                	mv	s4,a0
    8000418a:	a095                	j	800041ee <filewrite+0xe2>
    8000418c:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004190:	9adff0ef          	jal	ra,80003b3c <begin_op>
      ilock(f->ip);
    80004194:	01893503          	ld	a0,24(s2)
    80004198:	91aff0ef          	jal	ra,800032b2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000419c:	8762                	mv	a4,s8
    8000419e:	02092683          	lw	a3,32(s2)
    800041a2:	01598633          	add	a2,s3,s5
    800041a6:	4585                	li	a1,1
    800041a8:	01893503          	ld	a0,24(s2)
    800041ac:	c3aff0ef          	jal	ra,800035e6 <writei>
    800041b0:	84aa                	mv	s1,a0
    800041b2:	00a05763          	blez	a0,800041c0 <filewrite+0xb4>
        f->off += r;
    800041b6:	02092783          	lw	a5,32(s2)
    800041ba:	9fa9                	addw	a5,a5,a0
    800041bc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800041c0:	01893503          	ld	a0,24(s2)
    800041c4:	998ff0ef          	jal	ra,8000335c <iunlock>
      end_op();
    800041c8:	9e5ff0ef          	jal	ra,80003bac <end_op>

      if(r != n1){
    800041cc:	009c1f63          	bne	s8,s1,800041ea <filewrite+0xde>
        // error from writei
        break;
      }
      i += r;
    800041d0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800041d4:	0149db63          	bge	s3,s4,800041ea <filewrite+0xde>
      int n1 = n - i;
    800041d8:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    800041dc:	84be                	mv	s1,a5
    800041de:	2781                	sext.w	a5,a5
    800041e0:	fafb56e3          	bge	s6,a5,8000418c <filewrite+0x80>
    800041e4:	84de                	mv	s1,s7
    800041e6:	b75d                	j	8000418c <filewrite+0x80>
    int i = 0;
    800041e8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    800041ea:	013a1f63          	bne	s4,s3,80004208 <filewrite+0xfc>
  } else {
    panic("filewrite");
  }

  return ret;
}
    800041ee:	8552                	mv	a0,s4
    800041f0:	60a6                	ld	ra,72(sp)
    800041f2:	6406                	ld	s0,64(sp)
    800041f4:	74e2                	ld	s1,56(sp)
    800041f6:	7942                	ld	s2,48(sp)
    800041f8:	79a2                	ld	s3,40(sp)
    800041fa:	7a02                	ld	s4,32(sp)
    800041fc:	6ae2                	ld	s5,24(sp)
    800041fe:	6b42                	ld	s6,16(sp)
    80004200:	6ba2                	ld	s7,8(sp)
    80004202:	6c02                	ld	s8,0(sp)
    80004204:	6161                	addi	sp,sp,80
    80004206:	8082                	ret
    ret = (i == n ? n : -1);
    80004208:	5a7d                	li	s4,-1
    8000420a:	b7d5                	j	800041ee <filewrite+0xe2>
    panic("filewrite");
    8000420c:	00003517          	auipc	a0,0x3
    80004210:	56450513          	addi	a0,a0,1380 # 80007770 <syscalls+0x278>
    80004214:	d48fc0ef          	jal	ra,8000075c <panic>
    return -1;
    80004218:	5a7d                	li	s4,-1
    8000421a:	bfd1                	j	800041ee <filewrite+0xe2>
      return -1;
    8000421c:	5a7d                	li	s4,-1
    8000421e:	bfc1                	j	800041ee <filewrite+0xe2>
    80004220:	5a7d                	li	s4,-1
    80004222:	b7f1                	j	800041ee <filewrite+0xe2>

0000000080004224 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004224:	7179                	addi	sp,sp,-48
    80004226:	f406                	sd	ra,40(sp)
    80004228:	f022                	sd	s0,32(sp)
    8000422a:	ec26                	sd	s1,24(sp)
    8000422c:	e84a                	sd	s2,16(sp)
    8000422e:	e44e                	sd	s3,8(sp)
    80004230:	e052                	sd	s4,0(sp)
    80004232:	1800                	addi	s0,sp,48
    80004234:	84aa                	mv	s1,a0
    80004236:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004238:	0005b023          	sd	zero,0(a1)
    8000423c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004240:	c75ff0ef          	jal	ra,80003eb4 <filealloc>
    80004244:	e088                	sd	a0,0(s1)
    80004246:	cd35                	beqz	a0,800042c2 <pipealloc+0x9e>
    80004248:	c6dff0ef          	jal	ra,80003eb4 <filealloc>
    8000424c:	00aa3023          	sd	a0,0(s4)
    80004250:	c52d                	beqz	a0,800042ba <pipealloc+0x96>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004252:	887fc0ef          	jal	ra,80000ad8 <kalloc>
    80004256:	892a                	mv	s2,a0
    80004258:	cd31                	beqz	a0,800042b4 <pipealloc+0x90>
    goto bad;
  pi->readopen = 1;
    8000425a:	4985                	li	s3,1
    8000425c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004260:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004264:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004268:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000426c:	00003597          	auipc	a1,0x3
    80004270:	51458593          	addi	a1,a1,1300 # 80007780 <syscalls+0x288>
    80004274:	8b5fc0ef          	jal	ra,80000b28 <initlock>
  (*f0)->type = FD_PIPE;
    80004278:	609c                	ld	a5,0(s1)
    8000427a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000427e:	609c                	ld	a5,0(s1)
    80004280:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004284:	609c                	ld	a5,0(s1)
    80004286:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000428a:	609c                	ld	a5,0(s1)
    8000428c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004290:	000a3783          	ld	a5,0(s4)
    80004294:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004298:	000a3783          	ld	a5,0(s4)
    8000429c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800042a0:	000a3783          	ld	a5,0(s4)
    800042a4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800042a8:	000a3783          	ld	a5,0(s4)
    800042ac:	0127b823          	sd	s2,16(a5)
  return 0;
    800042b0:	4501                	li	a0,0
    800042b2:	a005                	j	800042d2 <pipealloc+0xae>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800042b4:	6088                	ld	a0,0(s1)
    800042b6:	e501                	bnez	a0,800042be <pipealloc+0x9a>
    800042b8:	a029                	j	800042c2 <pipealloc+0x9e>
    800042ba:	6088                	ld	a0,0(s1)
    800042bc:	c11d                	beqz	a0,800042e2 <pipealloc+0xbe>
    fileclose(*f0);
    800042be:	c9bff0ef          	jal	ra,80003f58 <fileclose>
  if(*f1)
    800042c2:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042c6:	557d                	li	a0,-1
  if(*f1)
    800042c8:	c789                	beqz	a5,800042d2 <pipealloc+0xae>
    fileclose(*f1);
    800042ca:	853e                	mv	a0,a5
    800042cc:	c8dff0ef          	jal	ra,80003f58 <fileclose>
  return -1;
    800042d0:	557d                	li	a0,-1
}
    800042d2:	70a2                	ld	ra,40(sp)
    800042d4:	7402                	ld	s0,32(sp)
    800042d6:	64e2                	ld	s1,24(sp)
    800042d8:	6942                	ld	s2,16(sp)
    800042da:	69a2                	ld	s3,8(sp)
    800042dc:	6a02                	ld	s4,0(sp)
    800042de:	6145                	addi	sp,sp,48
    800042e0:	8082                	ret
  return -1;
    800042e2:	557d                	li	a0,-1
    800042e4:	b7fd                	j	800042d2 <pipealloc+0xae>

00000000800042e6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800042e6:	1101                	addi	sp,sp,-32
    800042e8:	ec06                	sd	ra,24(sp)
    800042ea:	e822                	sd	s0,16(sp)
    800042ec:	e426                	sd	s1,8(sp)
    800042ee:	e04a                	sd	s2,0(sp)
    800042f0:	1000                	addi	s0,sp,32
    800042f2:	84aa                	mv	s1,a0
    800042f4:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800042f6:	8b3fc0ef          	jal	ra,80000ba8 <acquire>
  if(writable){
    800042fa:	02090763          	beqz	s2,80004328 <pipeclose+0x42>
    pi->writeopen = 0;
    800042fe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004302:	21848513          	addi	a0,s1,536
    80004306:	c2bfd0ef          	jal	ra,80001f30 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000430a:	2204b783          	ld	a5,544(s1)
    8000430e:	e785                	bnez	a5,80004336 <pipeclose+0x50>
    release(&pi->lock);
    80004310:	8526                	mv	a0,s1
    80004312:	92ffc0ef          	jal	ra,80000c40 <release>
    kfree((char*)pi);
    80004316:	8526                	mv	a0,s1
    80004318:	ee0fc0ef          	jal	ra,800009f8 <kfree>
  } else
    release(&pi->lock);
}
    8000431c:	60e2                	ld	ra,24(sp)
    8000431e:	6442                	ld	s0,16(sp)
    80004320:	64a2                	ld	s1,8(sp)
    80004322:	6902                	ld	s2,0(sp)
    80004324:	6105                	addi	sp,sp,32
    80004326:	8082                	ret
    pi->readopen = 0;
    80004328:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000432c:	21c48513          	addi	a0,s1,540
    80004330:	c01fd0ef          	jal	ra,80001f30 <wakeup>
    80004334:	bfd9                	j	8000430a <pipeclose+0x24>
    release(&pi->lock);
    80004336:	8526                	mv	a0,s1
    80004338:	909fc0ef          	jal	ra,80000c40 <release>
}
    8000433c:	b7c5                	j	8000431c <pipeclose+0x36>

000000008000433e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000433e:	7159                	addi	sp,sp,-112
    80004340:	f486                	sd	ra,104(sp)
    80004342:	f0a2                	sd	s0,96(sp)
    80004344:	eca6                	sd	s1,88(sp)
    80004346:	e8ca                	sd	s2,80(sp)
    80004348:	e4ce                	sd	s3,72(sp)
    8000434a:	e0d2                	sd	s4,64(sp)
    8000434c:	fc56                	sd	s5,56(sp)
    8000434e:	f85a                	sd	s6,48(sp)
    80004350:	f45e                	sd	s7,40(sp)
    80004352:	f062                	sd	s8,32(sp)
    80004354:	ec66                	sd	s9,24(sp)
    80004356:	1880                	addi	s0,sp,112
    80004358:	84aa                	mv	s1,a0
    8000435a:	8aae                	mv	s5,a1
    8000435c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000435e:	dbefd0ef          	jal	ra,8000191c <myproc>
    80004362:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004364:	8526                	mv	a0,s1
    80004366:	843fc0ef          	jal	ra,80000ba8 <acquire>
  while(i < n){
    8000436a:	0b405663          	blez	s4,80004416 <pipewrite+0xd8>
    8000436e:	8ba6                	mv	s7,s1
  int i = 0;
    80004370:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004372:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004374:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004378:	21c48c13          	addi	s8,s1,540
    8000437c:	a899                	j	800043d2 <pipewrite+0x94>
      release(&pi->lock);
    8000437e:	8526                	mv	a0,s1
    80004380:	8c1fc0ef          	jal	ra,80000c40 <release>
      return -1;
    80004384:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004386:	854a                	mv	a0,s2
    80004388:	70a6                	ld	ra,104(sp)
    8000438a:	7406                	ld	s0,96(sp)
    8000438c:	64e6                	ld	s1,88(sp)
    8000438e:	6946                	ld	s2,80(sp)
    80004390:	69a6                	ld	s3,72(sp)
    80004392:	6a06                	ld	s4,64(sp)
    80004394:	7ae2                	ld	s5,56(sp)
    80004396:	7b42                	ld	s6,48(sp)
    80004398:	7ba2                	ld	s7,40(sp)
    8000439a:	7c02                	ld	s8,32(sp)
    8000439c:	6ce2                	ld	s9,24(sp)
    8000439e:	6165                	addi	sp,sp,112
    800043a0:	8082                	ret
      wakeup(&pi->nread);
    800043a2:	8566                	mv	a0,s9
    800043a4:	b8dfd0ef          	jal	ra,80001f30 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800043a8:	85de                	mv	a1,s7
    800043aa:	8562                	mv	a0,s8
    800043ac:	b39fd0ef          	jal	ra,80001ee4 <sleep>
    800043b0:	a839                	j	800043ce <pipewrite+0x90>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800043b2:	21c4a783          	lw	a5,540(s1)
    800043b6:	0017871b          	addiw	a4,a5,1
    800043ba:	20e4ae23          	sw	a4,540(s1)
    800043be:	1ff7f793          	andi	a5,a5,511
    800043c2:	97a6                	add	a5,a5,s1
    800043c4:	f9f44703          	lbu	a4,-97(s0)
    800043c8:	00e78c23          	sb	a4,24(a5)
      i++;
    800043cc:	2905                	addiw	s2,s2,1
  while(i < n){
    800043ce:	03495c63          	bge	s2,s4,80004406 <pipewrite+0xc8>
    if(pi->readopen == 0 || killed(pr)){
    800043d2:	2204a783          	lw	a5,544(s1)
    800043d6:	d7c5                	beqz	a5,8000437e <pipewrite+0x40>
    800043d8:	854e                	mv	a0,s3
    800043da:	d43fd0ef          	jal	ra,8000211c <killed>
    800043de:	f145                	bnez	a0,8000437e <pipewrite+0x40>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043e0:	2184a783          	lw	a5,536(s1)
    800043e4:	21c4a703          	lw	a4,540(s1)
    800043e8:	2007879b          	addiw	a5,a5,512
    800043ec:	faf70be3          	beq	a4,a5,800043a2 <pipewrite+0x64>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043f0:	4685                	li	a3,1
    800043f2:	01590633          	add	a2,s2,s5
    800043f6:	f9f40593          	addi	a1,s0,-97
    800043fa:	0509b503          	ld	a0,80(s3)
    800043fe:	9b0fd0ef          	jal	ra,800015ae <copyin>
    80004402:	fb6518e3          	bne	a0,s6,800043b2 <pipewrite+0x74>
  wakeup(&pi->nread);
    80004406:	21848513          	addi	a0,s1,536
    8000440a:	b27fd0ef          	jal	ra,80001f30 <wakeup>
  release(&pi->lock);
    8000440e:	8526                	mv	a0,s1
    80004410:	831fc0ef          	jal	ra,80000c40 <release>
  return i;
    80004414:	bf8d                	j	80004386 <pipewrite+0x48>
  int i = 0;
    80004416:	4901                	li	s2,0
    80004418:	b7fd                	j	80004406 <pipewrite+0xc8>

000000008000441a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000441a:	715d                	addi	sp,sp,-80
    8000441c:	e486                	sd	ra,72(sp)
    8000441e:	e0a2                	sd	s0,64(sp)
    80004420:	fc26                	sd	s1,56(sp)
    80004422:	f84a                	sd	s2,48(sp)
    80004424:	f44e                	sd	s3,40(sp)
    80004426:	f052                	sd	s4,32(sp)
    80004428:	ec56                	sd	s5,24(sp)
    8000442a:	e85a                	sd	s6,16(sp)
    8000442c:	0880                	addi	s0,sp,80
    8000442e:	84aa                	mv	s1,a0
    80004430:	892e                	mv	s2,a1
    80004432:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004434:	ce8fd0ef          	jal	ra,8000191c <myproc>
    80004438:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000443a:	8b26                	mv	s6,s1
    8000443c:	8526                	mv	a0,s1
    8000443e:	f6afc0ef          	jal	ra,80000ba8 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004442:	2184a703          	lw	a4,536(s1)
    80004446:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000444a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000444e:	02f71363          	bne	a4,a5,80004474 <piperead+0x5a>
    80004452:	2244a783          	lw	a5,548(s1)
    80004456:	cf99                	beqz	a5,80004474 <piperead+0x5a>
    if(killed(pr)){
    80004458:	8552                	mv	a0,s4
    8000445a:	cc3fd0ef          	jal	ra,8000211c <killed>
    8000445e:	e141                	bnez	a0,800044de <piperead+0xc4>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004460:	85da                	mv	a1,s6
    80004462:	854e                	mv	a0,s3
    80004464:	a81fd0ef          	jal	ra,80001ee4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004468:	2184a703          	lw	a4,536(s1)
    8000446c:	21c4a783          	lw	a5,540(s1)
    80004470:	fef701e3          	beq	a4,a5,80004452 <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004474:	07505a63          	blez	s5,800044e8 <piperead+0xce>
    80004478:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000447a:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    8000447c:	2184a783          	lw	a5,536(s1)
    80004480:	21c4a703          	lw	a4,540(s1)
    80004484:	02f70b63          	beq	a4,a5,800044ba <piperead+0xa0>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004488:	0017871b          	addiw	a4,a5,1
    8000448c:	20e4ac23          	sw	a4,536(s1)
    80004490:	1ff7f793          	andi	a5,a5,511
    80004494:	97a6                	add	a5,a5,s1
    80004496:	0187c783          	lbu	a5,24(a5)
    8000449a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000449e:	4685                	li	a3,1
    800044a0:	fbf40613          	addi	a2,s0,-65
    800044a4:	85ca                	mv	a1,s2
    800044a6:	050a3503          	ld	a0,80(s4)
    800044aa:	84cfd0ef          	jal	ra,800014f6 <copyout>
    800044ae:	01650663          	beq	a0,s6,800044ba <piperead+0xa0>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044b2:	2985                	addiw	s3,s3,1
    800044b4:	0905                	addi	s2,s2,1
    800044b6:	fd3a93e3          	bne	s5,s3,8000447c <piperead+0x62>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800044ba:	21c48513          	addi	a0,s1,540
    800044be:	a73fd0ef          	jal	ra,80001f30 <wakeup>
  release(&pi->lock);
    800044c2:	8526                	mv	a0,s1
    800044c4:	f7cfc0ef          	jal	ra,80000c40 <release>
  return i;
}
    800044c8:	854e                	mv	a0,s3
    800044ca:	60a6                	ld	ra,72(sp)
    800044cc:	6406                	ld	s0,64(sp)
    800044ce:	74e2                	ld	s1,56(sp)
    800044d0:	7942                	ld	s2,48(sp)
    800044d2:	79a2                	ld	s3,40(sp)
    800044d4:	7a02                	ld	s4,32(sp)
    800044d6:	6ae2                	ld	s5,24(sp)
    800044d8:	6b42                	ld	s6,16(sp)
    800044da:	6161                	addi	sp,sp,80
    800044dc:	8082                	ret
      release(&pi->lock);
    800044de:	8526                	mv	a0,s1
    800044e0:	f60fc0ef          	jal	ra,80000c40 <release>
      return -1;
    800044e4:	59fd                	li	s3,-1
    800044e6:	b7cd                	j	800044c8 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044e8:	4981                	li	s3,0
    800044ea:	bfc1                	j	800044ba <piperead+0xa0>

00000000800044ec <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800044ec:	1141                	addi	sp,sp,-16
    800044ee:	e422                	sd	s0,8(sp)
    800044f0:	0800                	addi	s0,sp,16
    800044f2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800044f4:	8905                	andi	a0,a0,1
    800044f6:	c111                	beqz	a0,800044fa <flags2perm+0xe>
      perm = PTE_X;
    800044f8:	4521                	li	a0,8
    if(flags & 0x2)
    800044fa:	8b89                	andi	a5,a5,2
    800044fc:	c399                	beqz	a5,80004502 <flags2perm+0x16>
      perm |= PTE_W;
    800044fe:	00456513          	ori	a0,a0,4
    return perm;
}
    80004502:	6422                	ld	s0,8(sp)
    80004504:	0141                	addi	sp,sp,16
    80004506:	8082                	ret

0000000080004508 <exec>:

int
exec(char *path, char **argv)
{
    80004508:	df010113          	addi	sp,sp,-528
    8000450c:	20113423          	sd	ra,520(sp)
    80004510:	20813023          	sd	s0,512(sp)
    80004514:	ffa6                	sd	s1,504(sp)
    80004516:	fbca                	sd	s2,496(sp)
    80004518:	f7ce                	sd	s3,488(sp)
    8000451a:	f3d2                	sd	s4,480(sp)
    8000451c:	efd6                	sd	s5,472(sp)
    8000451e:	ebda                	sd	s6,464(sp)
    80004520:	e7de                	sd	s7,456(sp)
    80004522:	e3e2                	sd	s8,448(sp)
    80004524:	ff66                	sd	s9,440(sp)
    80004526:	fb6a                	sd	s10,432(sp)
    80004528:	f76e                	sd	s11,424(sp)
    8000452a:	0c00                	addi	s0,sp,528
    8000452c:	84aa                	mv	s1,a0
    8000452e:	dea43c23          	sd	a0,-520(s0)
    80004532:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004536:	be6fd0ef          	jal	ra,8000191c <myproc>
    8000453a:	892a                	mv	s2,a0

  begin_op();
    8000453c:	e00ff0ef          	jal	ra,80003b3c <begin_op>

  if((ip = namei(path)) == 0){
    80004540:	8526                	mv	a0,s1
    80004542:	c22ff0ef          	jal	ra,80003964 <namei>
    80004546:	c12d                	beqz	a0,800045a8 <exec+0xa0>
    80004548:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000454a:	d69fe0ef          	jal	ra,800032b2 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000454e:	04000713          	li	a4,64
    80004552:	4681                	li	a3,0
    80004554:	e5040613          	addi	a2,s0,-432
    80004558:	4581                	li	a1,0
    8000455a:	8526                	mv	a0,s1
    8000455c:	fa7fe0ef          	jal	ra,80003502 <readi>
    80004560:	04000793          	li	a5,64
    80004564:	00f51a63          	bne	a0,a5,80004578 <exec+0x70>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004568:	e5042703          	lw	a4,-432(s0)
    8000456c:	464c47b7          	lui	a5,0x464c4
    80004570:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004574:	02f70e63          	beq	a4,a5,800045b0 <exec+0xa8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004578:	8526                	mv	a0,s1
    8000457a:	f3ffe0ef          	jal	ra,800034b8 <iunlockput>
    end_op();
    8000457e:	e2eff0ef          	jal	ra,80003bac <end_op>
  }
  return -1;
    80004582:	557d                	li	a0,-1
}
    80004584:	20813083          	ld	ra,520(sp)
    80004588:	20013403          	ld	s0,512(sp)
    8000458c:	74fe                	ld	s1,504(sp)
    8000458e:	795e                	ld	s2,496(sp)
    80004590:	79be                	ld	s3,488(sp)
    80004592:	7a1e                	ld	s4,480(sp)
    80004594:	6afe                	ld	s5,472(sp)
    80004596:	6b5e                	ld	s6,464(sp)
    80004598:	6bbe                	ld	s7,456(sp)
    8000459a:	6c1e                	ld	s8,448(sp)
    8000459c:	7cfa                	ld	s9,440(sp)
    8000459e:	7d5a                	ld	s10,432(sp)
    800045a0:	7dba                	ld	s11,424(sp)
    800045a2:	21010113          	addi	sp,sp,528
    800045a6:	8082                	ret
    end_op();
    800045a8:	e04ff0ef          	jal	ra,80003bac <end_op>
    return -1;
    800045ac:	557d                	li	a0,-1
    800045ae:	bfd9                	j	80004584 <exec+0x7c>
  if((pagetable = proc_pagetable(p)) == 0)
    800045b0:	854a                	mv	a0,s2
    800045b2:	c12fd0ef          	jal	ra,800019c4 <proc_pagetable>
    800045b6:	8baa                	mv	s7,a0
    800045b8:	d161                	beqz	a0,80004578 <exec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045ba:	e7042983          	lw	s3,-400(s0)
    800045be:	e8845783          	lhu	a5,-376(s0)
    800045c2:	cfb9                	beqz	a5,80004620 <exec+0x118>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045c4:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045c6:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    800045c8:	6c85                	lui	s9,0x1
    800045ca:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045ce:	def43823          	sd	a5,-528(s0)
    800045d2:	ac31                	j	800047ee <exec+0x2e6>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800045d4:	00003517          	auipc	a0,0x3
    800045d8:	1b450513          	addi	a0,a0,436 # 80007788 <syscalls+0x290>
    800045dc:	980fc0ef          	jal	ra,8000075c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800045e0:	8756                	mv	a4,s5
    800045e2:	012d86bb          	addw	a3,s11,s2
    800045e6:	4581                	li	a1,0
    800045e8:	8526                	mv	a0,s1
    800045ea:	f19fe0ef          	jal	ra,80003502 <readi>
    800045ee:	2501                	sext.w	a0,a0
    800045f0:	1aaa9563          	bne	s5,a0,8000479a <exec+0x292>
  for(i = 0; i < sz; i += PGSIZE){
    800045f4:	6785                	lui	a5,0x1
    800045f6:	0127893b          	addw	s2,a5,s2
    800045fa:	77fd                	lui	a5,0xfffff
    800045fc:	01478a3b          	addw	s4,a5,s4
    80004600:	1d897e63          	bgeu	s2,s8,800047dc <exec+0x2d4>
    pa = walkaddr(pagetable, va + i);
    80004604:	02091593          	slli	a1,s2,0x20
    80004608:	9181                	srli	a1,a1,0x20
    8000460a:	95ea                	add	a1,a1,s10
    8000460c:	855e                	mv	a0,s7
    8000460e:	98dfc0ef          	jal	ra,80000f9a <walkaddr>
    80004612:	862a                	mv	a2,a0
    if(pa == 0)
    80004614:	d161                	beqz	a0,800045d4 <exec+0xcc>
      n = PGSIZE;
    80004616:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    80004618:	fd9a74e3          	bgeu	s4,s9,800045e0 <exec+0xd8>
      n = sz - i;
    8000461c:	8ad2                	mv	s5,s4
    8000461e:	b7c9                	j	800045e0 <exec+0xd8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004620:	4a01                	li	s4,0
  iunlockput(ip);
    80004622:	8526                	mv	a0,s1
    80004624:	e95fe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004628:	d84ff0ef          	jal	ra,80003bac <end_op>
  p = myproc();
    8000462c:	af0fd0ef          	jal	ra,8000191c <myproc>
    80004630:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004632:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004636:	6785                	lui	a5,0x1
    80004638:	17fd                	addi	a5,a5,-1
    8000463a:	9a3e                	add	s4,s4,a5
    8000463c:	757d                	lui	a0,0xfffff
    8000463e:	00aa77b3          	and	a5,s4,a0
    80004642:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004646:	4691                	li	a3,4
    80004648:	6609                	lui	a2,0x2
    8000464a:	963e                	add	a2,a2,a5
    8000464c:	85be                	mv	a1,a5
    8000464e:	855e                	mv	a0,s7
    80004650:	ca3fc0ef          	jal	ra,800012f2 <uvmalloc>
    80004654:	8b2a                	mv	s6,a0
  ip = 0;
    80004656:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004658:	14050163          	beqz	a0,8000479a <exec+0x292>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000465c:	75f9                	lui	a1,0xffffe
    8000465e:	95aa                	add	a1,a1,a0
    80004660:	855e                	mv	a0,s7
    80004662:	e6bfc0ef          	jal	ra,800014cc <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004666:	7c7d                	lui	s8,0xfffff
    80004668:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000466a:	e0043783          	ld	a5,-512(s0)
    8000466e:	6388                	ld	a0,0(a5)
    80004670:	c125                	beqz	a0,800046d0 <exec+0x1c8>
    80004672:	e9040993          	addi	s3,s0,-368
    80004676:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000467a:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000467c:	f80fc0ef          	jal	ra,80000dfc <strlen>
    80004680:	2505                	addiw	a0,a0,1
    80004682:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004686:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    8000468a:	13896d63          	bltu	s2,s8,800047c4 <exec+0x2bc>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000468e:	e0043d83          	ld	s11,-512(s0)
    80004692:	000dba03          	ld	s4,0(s11)
    80004696:	8552                	mv	a0,s4
    80004698:	f64fc0ef          	jal	ra,80000dfc <strlen>
    8000469c:	0015069b          	addiw	a3,a0,1
    800046a0:	8652                	mv	a2,s4
    800046a2:	85ca                	mv	a1,s2
    800046a4:	855e                	mv	a0,s7
    800046a6:	e51fc0ef          	jal	ra,800014f6 <copyout>
    800046aa:	12054163          	bltz	a0,800047cc <exec+0x2c4>
    ustack[argc] = sp;
    800046ae:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800046b2:	0485                	addi	s1,s1,1
    800046b4:	008d8793          	addi	a5,s11,8
    800046b8:	e0f43023          	sd	a5,-512(s0)
    800046bc:	008db503          	ld	a0,8(s11)
    800046c0:	c911                	beqz	a0,800046d4 <exec+0x1cc>
    if(argc >= MAXARG)
    800046c2:	09a1                	addi	s3,s3,8
    800046c4:	fb3c9ce3          	bne	s9,s3,8000467c <exec+0x174>
  sz = sz1;
    800046c8:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800046cc:	4481                	li	s1,0
    800046ce:	a0f1                	j	8000479a <exec+0x292>
  sp = sz;
    800046d0:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800046d2:	4481                	li	s1,0
  ustack[argc] = 0;
    800046d4:	00349793          	slli	a5,s1,0x3
    800046d8:	f9040713          	addi	a4,s0,-112
    800046dc:	97ba                	add	a5,a5,a4
    800046de:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800046e2:	00148693          	addi	a3,s1,1
    800046e6:	068e                	slli	a3,a3,0x3
    800046e8:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800046ec:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800046f0:	01897663          	bgeu	s2,s8,800046fc <exec+0x1f4>
  sz = sz1;
    800046f4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800046f8:	4481                	li	s1,0
    800046fa:	a045                	j	8000479a <exec+0x292>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800046fc:	e9040613          	addi	a2,s0,-368
    80004700:	85ca                	mv	a1,s2
    80004702:	855e                	mv	a0,s7
    80004704:	df3fc0ef          	jal	ra,800014f6 <copyout>
    80004708:	0c054663          	bltz	a0,800047d4 <exec+0x2cc>
  p->trapframe->a1 = sp;
    8000470c:	058ab783          	ld	a5,88(s5)
    80004710:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004714:	df843783          	ld	a5,-520(s0)
    80004718:	0007c703          	lbu	a4,0(a5)
    8000471c:	cf11                	beqz	a4,80004738 <exec+0x230>
    8000471e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004720:	02f00693          	li	a3,47
    80004724:	a039                	j	80004732 <exec+0x22a>
      last = s+1;
    80004726:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000472a:	0785                	addi	a5,a5,1
    8000472c:	fff7c703          	lbu	a4,-1(a5)
    80004730:	c701                	beqz	a4,80004738 <exec+0x230>
    if(*s == '/')
    80004732:	fed71ce3          	bne	a4,a3,8000472a <exec+0x222>
    80004736:	bfc5                	j	80004726 <exec+0x21e>
  safestrcpy(p->name, last, sizeof(p->name));
    80004738:	4641                	li	a2,16
    8000473a:	df843583          	ld	a1,-520(s0)
    8000473e:	158a8513          	addi	a0,s5,344
    80004742:	e88fc0ef          	jal	ra,80000dca <safestrcpy>
  oldpagetable = p->pagetable;
    80004746:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000474a:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    8000474e:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004752:	058ab783          	ld	a5,88(s5)
    80004756:	e6843703          	ld	a4,-408(s0)
    8000475a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000475c:	058ab783          	ld	a5,88(s5)
    80004760:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004764:	85ea                	mv	a1,s10
    80004766:	ae2fd0ef          	jal	ra,80001a48 <proc_freepagetable>
  if (p->pid == 1) {
    8000476a:	030aa703          	lw	a4,48(s5)
    8000476e:	4785                	li	a5,1
    80004770:	00f70563          	beq	a4,a5,8000477a <exec+0x272>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004774:	0004851b          	sext.w	a0,s1
    80004778:	b531                	j	80004584 <exec+0x7c>
    vmprint(p->pagetable);
    8000477a:	050ab503          	ld	a0,80(s5)
    8000477e:	f65fc0ef          	jal	ra,800016e2 <vmprint>
  if (p->pid == 1) {
    80004782:	030aa703          	lw	a4,48(s5)
    80004786:	4785                	li	a5,1
    80004788:	fef716e3          	bne	a4,a5,80004774 <exec+0x26c>
    vmprint(p->pagetable);
    8000478c:	050ab503          	ld	a0,80(s5)
    80004790:	f53fc0ef          	jal	ra,800016e2 <vmprint>
    80004794:	b7c5                	j	80004774 <exec+0x26c>
    80004796:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000479a:	e0843583          	ld	a1,-504(s0)
    8000479e:	855e                	mv	a0,s7
    800047a0:	aa8fd0ef          	jal	ra,80001a48 <proc_freepagetable>
  if(ip){
    800047a4:	dc049ae3          	bnez	s1,80004578 <exec+0x70>
  return -1;
    800047a8:	557d                	li	a0,-1
    800047aa:	bbe9                	j	80004584 <exec+0x7c>
    800047ac:	e1443423          	sd	s4,-504(s0)
    800047b0:	b7ed                	j	8000479a <exec+0x292>
    800047b2:	e1443423          	sd	s4,-504(s0)
    800047b6:	b7d5                	j	8000479a <exec+0x292>
    800047b8:	e1443423          	sd	s4,-504(s0)
    800047bc:	bff9                	j	8000479a <exec+0x292>
    800047be:	e1443423          	sd	s4,-504(s0)
    800047c2:	bfe1                	j	8000479a <exec+0x292>
  sz = sz1;
    800047c4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800047c8:	4481                	li	s1,0
    800047ca:	bfc1                	j	8000479a <exec+0x292>
  sz = sz1;
    800047cc:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800047d0:	4481                	li	s1,0
    800047d2:	b7e1                	j	8000479a <exec+0x292>
  sz = sz1;
    800047d4:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800047d8:	4481                	li	s1,0
    800047da:	b7c1                	j	8000479a <exec+0x292>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800047dc:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047e0:	2b05                	addiw	s6,s6,1
    800047e2:	0389899b          	addiw	s3,s3,56
    800047e6:	e8845783          	lhu	a5,-376(s0)
    800047ea:	e2fb5ce3          	bge	s6,a5,80004622 <exec+0x11a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047ee:	2981                	sext.w	s3,s3
    800047f0:	03800713          	li	a4,56
    800047f4:	86ce                	mv	a3,s3
    800047f6:	e1840613          	addi	a2,s0,-488
    800047fa:	4581                	li	a1,0
    800047fc:	8526                	mv	a0,s1
    800047fe:	d05fe0ef          	jal	ra,80003502 <readi>
    80004802:	03800793          	li	a5,56
    80004806:	f8f518e3          	bne	a0,a5,80004796 <exec+0x28e>
    if(ph.type != ELF_PROG_LOAD)
    8000480a:	e1842783          	lw	a5,-488(s0)
    8000480e:	4705                	li	a4,1
    80004810:	fce798e3          	bne	a5,a4,800047e0 <exec+0x2d8>
    if(ph.memsz < ph.filesz)
    80004814:	e4043903          	ld	s2,-448(s0)
    80004818:	e3843783          	ld	a5,-456(s0)
    8000481c:	f8f968e3          	bltu	s2,a5,800047ac <exec+0x2a4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004820:	e2843783          	ld	a5,-472(s0)
    80004824:	993e                	add	s2,s2,a5
    80004826:	f8f966e3          	bltu	s2,a5,800047b2 <exec+0x2aa>
    if(ph.vaddr % PGSIZE != 0)
    8000482a:	df043703          	ld	a4,-528(s0)
    8000482e:	8ff9                	and	a5,a5,a4
    80004830:	f7c1                	bnez	a5,800047b8 <exec+0x2b0>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004832:	e1c42503          	lw	a0,-484(s0)
    80004836:	cb7ff0ef          	jal	ra,800044ec <flags2perm>
    8000483a:	86aa                	mv	a3,a0
    8000483c:	864a                	mv	a2,s2
    8000483e:	85d2                	mv	a1,s4
    80004840:	855e                	mv	a0,s7
    80004842:	ab1fc0ef          	jal	ra,800012f2 <uvmalloc>
    80004846:	e0a43423          	sd	a0,-504(s0)
    8000484a:	d935                	beqz	a0,800047be <exec+0x2b6>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000484c:	e2843d03          	ld	s10,-472(s0)
    80004850:	e2042d83          	lw	s11,-480(s0)
    80004854:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004858:	f80c02e3          	beqz	s8,800047dc <exec+0x2d4>
    8000485c:	8a62                	mv	s4,s8
    8000485e:	4901                	li	s2,0
    80004860:	b355                	j	80004604 <exec+0xfc>

0000000080004862 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004862:	7179                	addi	sp,sp,-48
    80004864:	f406                	sd	ra,40(sp)
    80004866:	f022                	sd	s0,32(sp)
    80004868:	ec26                	sd	s1,24(sp)
    8000486a:	e84a                	sd	s2,16(sp)
    8000486c:	1800                	addi	s0,sp,48
    8000486e:	892e                	mv	s2,a1
    80004870:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004872:	fdc40593          	addi	a1,s0,-36
    80004876:	f4ffd0ef          	jal	ra,800027c4 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000487a:	fdc42703          	lw	a4,-36(s0)
    8000487e:	47bd                	li	a5,15
    80004880:	02e7e963          	bltu	a5,a4,800048b2 <argfd+0x50>
    80004884:	898fd0ef          	jal	ra,8000191c <myproc>
    80004888:	fdc42703          	lw	a4,-36(s0)
    8000488c:	01a70793          	addi	a5,a4,26
    80004890:	078e                	slli	a5,a5,0x3
    80004892:	953e                	add	a0,a0,a5
    80004894:	611c                	ld	a5,0(a0)
    80004896:	c385                	beqz	a5,800048b6 <argfd+0x54>
    return -1;
  if(pfd)
    80004898:	00090463          	beqz	s2,800048a0 <argfd+0x3e>
    *pfd = fd;
    8000489c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048a0:	4501                	li	a0,0
  if(pf)
    800048a2:	c091                	beqz	s1,800048a6 <argfd+0x44>
    *pf = f;
    800048a4:	e09c                	sd	a5,0(s1)
}
    800048a6:	70a2                	ld	ra,40(sp)
    800048a8:	7402                	ld	s0,32(sp)
    800048aa:	64e2                	ld	s1,24(sp)
    800048ac:	6942                	ld	s2,16(sp)
    800048ae:	6145                	addi	sp,sp,48
    800048b0:	8082                	ret
    return -1;
    800048b2:	557d                	li	a0,-1
    800048b4:	bfcd                	j	800048a6 <argfd+0x44>
    800048b6:	557d                	li	a0,-1
    800048b8:	b7fd                	j	800048a6 <argfd+0x44>

00000000800048ba <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800048ba:	1101                	addi	sp,sp,-32
    800048bc:	ec06                	sd	ra,24(sp)
    800048be:	e822                	sd	s0,16(sp)
    800048c0:	e426                	sd	s1,8(sp)
    800048c2:	1000                	addi	s0,sp,32
    800048c4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800048c6:	856fd0ef          	jal	ra,8000191c <myproc>
    800048ca:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800048cc:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7ffde3f0>
    800048d0:	4501                	li	a0,0
    800048d2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800048d4:	6398                	ld	a4,0(a5)
    800048d6:	cb19                	beqz	a4,800048ec <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800048d8:	2505                	addiw	a0,a0,1
    800048da:	07a1                	addi	a5,a5,8
    800048dc:	fed51ce3          	bne	a0,a3,800048d4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800048e0:	557d                	li	a0,-1
}
    800048e2:	60e2                	ld	ra,24(sp)
    800048e4:	6442                	ld	s0,16(sp)
    800048e6:	64a2                	ld	s1,8(sp)
    800048e8:	6105                	addi	sp,sp,32
    800048ea:	8082                	ret
      p->ofile[fd] = f;
    800048ec:	01a50793          	addi	a5,a0,26
    800048f0:	078e                	slli	a5,a5,0x3
    800048f2:	963e                	add	a2,a2,a5
    800048f4:	e204                	sd	s1,0(a2)
      return fd;
    800048f6:	b7f5                	j	800048e2 <fdalloc+0x28>

00000000800048f8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800048f8:	715d                	addi	sp,sp,-80
    800048fa:	e486                	sd	ra,72(sp)
    800048fc:	e0a2                	sd	s0,64(sp)
    800048fe:	fc26                	sd	s1,56(sp)
    80004900:	f84a                	sd	s2,48(sp)
    80004902:	f44e                	sd	s3,40(sp)
    80004904:	f052                	sd	s4,32(sp)
    80004906:	ec56                	sd	s5,24(sp)
    80004908:	e85a                	sd	s6,16(sp)
    8000490a:	0880                	addi	s0,sp,80
    8000490c:	8b2e                	mv	s6,a1
    8000490e:	89b2                	mv	s3,a2
    80004910:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004912:	fb040593          	addi	a1,s0,-80
    80004916:	868ff0ef          	jal	ra,8000397e <nameiparent>
    8000491a:	84aa                	mv	s1,a0
    8000491c:	10050c63          	beqz	a0,80004a34 <create+0x13c>
    return 0;

  ilock(dp);
    80004920:	993fe0ef          	jal	ra,800032b2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004924:	4601                	li	a2,0
    80004926:	fb040593          	addi	a1,s0,-80
    8000492a:	8526                	mv	a0,s1
    8000492c:	dd3fe0ef          	jal	ra,800036fe <dirlookup>
    80004930:	8aaa                	mv	s5,a0
    80004932:	c521                	beqz	a0,8000497a <create+0x82>
    iunlockput(dp);
    80004934:	8526                	mv	a0,s1
    80004936:	b83fe0ef          	jal	ra,800034b8 <iunlockput>
    ilock(ip);
    8000493a:	8556                	mv	a0,s5
    8000493c:	977fe0ef          	jal	ra,800032b2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004940:	000b059b          	sext.w	a1,s6
    80004944:	4789                	li	a5,2
    80004946:	02f59563          	bne	a1,a5,80004970 <create+0x78>
    8000494a:	044ad783          	lhu	a5,68(s5)
    8000494e:	37f9                	addiw	a5,a5,-2
    80004950:	17c2                	slli	a5,a5,0x30
    80004952:	93c1                	srli	a5,a5,0x30
    80004954:	4705                	li	a4,1
    80004956:	00f76d63          	bltu	a4,a5,80004970 <create+0x78>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000495a:	8556                	mv	a0,s5
    8000495c:	60a6                	ld	ra,72(sp)
    8000495e:	6406                	ld	s0,64(sp)
    80004960:	74e2                	ld	s1,56(sp)
    80004962:	7942                	ld	s2,48(sp)
    80004964:	79a2                	ld	s3,40(sp)
    80004966:	7a02                	ld	s4,32(sp)
    80004968:	6ae2                	ld	s5,24(sp)
    8000496a:	6b42                	ld	s6,16(sp)
    8000496c:	6161                	addi	sp,sp,80
    8000496e:	8082                	ret
    iunlockput(ip);
    80004970:	8556                	mv	a0,s5
    80004972:	b47fe0ef          	jal	ra,800034b8 <iunlockput>
    return 0;
    80004976:	4a81                	li	s5,0
    80004978:	b7cd                	j	8000495a <create+0x62>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000497a:	85da                	mv	a1,s6
    8000497c:	4088                	lw	a0,0(s1)
    8000497e:	fccfe0ef          	jal	ra,8000314a <ialloc>
    80004982:	8a2a                	mv	s4,a0
    80004984:	c121                	beqz	a0,800049c4 <create+0xcc>
  ilock(ip);
    80004986:	92dfe0ef          	jal	ra,800032b2 <ilock>
  ip->major = major;
    8000498a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000498e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004992:	4785                	li	a5,1
    80004994:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80004998:	8552                	mv	a0,s4
    8000499a:	867fe0ef          	jal	ra,80003200 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000499e:	000b059b          	sext.w	a1,s6
    800049a2:	4785                	li	a5,1
    800049a4:	02f58563          	beq	a1,a5,800049ce <create+0xd6>
  if(dirlink(dp, name, ip->inum) < 0)
    800049a8:	004a2603          	lw	a2,4(s4)
    800049ac:	fb040593          	addi	a1,s0,-80
    800049b0:	8526                	mv	a0,s1
    800049b2:	f19fe0ef          	jal	ra,800038ca <dirlink>
    800049b6:	06054363          	bltz	a0,80004a1c <create+0x124>
  iunlockput(dp);
    800049ba:	8526                	mv	a0,s1
    800049bc:	afdfe0ef          	jal	ra,800034b8 <iunlockput>
  return ip;
    800049c0:	8ad2                	mv	s5,s4
    800049c2:	bf61                	j	8000495a <create+0x62>
    iunlockput(dp);
    800049c4:	8526                	mv	a0,s1
    800049c6:	af3fe0ef          	jal	ra,800034b8 <iunlockput>
    return 0;
    800049ca:	8ad2                	mv	s5,s4
    800049cc:	b779                	j	8000495a <create+0x62>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800049ce:	004a2603          	lw	a2,4(s4)
    800049d2:	00003597          	auipc	a1,0x3
    800049d6:	dd658593          	addi	a1,a1,-554 # 800077a8 <syscalls+0x2b0>
    800049da:	8552                	mv	a0,s4
    800049dc:	eeffe0ef          	jal	ra,800038ca <dirlink>
    800049e0:	02054e63          	bltz	a0,80004a1c <create+0x124>
    800049e4:	40d0                	lw	a2,4(s1)
    800049e6:	00003597          	auipc	a1,0x3
    800049ea:	dca58593          	addi	a1,a1,-566 # 800077b0 <syscalls+0x2b8>
    800049ee:	8552                	mv	a0,s4
    800049f0:	edbfe0ef          	jal	ra,800038ca <dirlink>
    800049f4:	02054463          	bltz	a0,80004a1c <create+0x124>
  if(dirlink(dp, name, ip->inum) < 0)
    800049f8:	004a2603          	lw	a2,4(s4)
    800049fc:	fb040593          	addi	a1,s0,-80
    80004a00:	8526                	mv	a0,s1
    80004a02:	ec9fe0ef          	jal	ra,800038ca <dirlink>
    80004a06:	00054b63          	bltz	a0,80004a1c <create+0x124>
    dp->nlink++;  // for ".."
    80004a0a:	04a4d783          	lhu	a5,74(s1)
    80004a0e:	2785                	addiw	a5,a5,1
    80004a10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a14:	8526                	mv	a0,s1
    80004a16:	feafe0ef          	jal	ra,80003200 <iupdate>
    80004a1a:	b745                	j	800049ba <create+0xc2>
  ip->nlink = 0;
    80004a1c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a20:	8552                	mv	a0,s4
    80004a22:	fdefe0ef          	jal	ra,80003200 <iupdate>
  iunlockput(ip);
    80004a26:	8552                	mv	a0,s4
    80004a28:	a91fe0ef          	jal	ra,800034b8 <iunlockput>
  iunlockput(dp);
    80004a2c:	8526                	mv	a0,s1
    80004a2e:	a8bfe0ef          	jal	ra,800034b8 <iunlockput>
  return 0;
    80004a32:	b725                	j	8000495a <create+0x62>
    return 0;
    80004a34:	8aaa                	mv	s5,a0
    80004a36:	b715                	j	8000495a <create+0x62>

0000000080004a38 <sys_dup>:
{
    80004a38:	7179                	addi	sp,sp,-48
    80004a3a:	f406                	sd	ra,40(sp)
    80004a3c:	f022                	sd	s0,32(sp)
    80004a3e:	ec26                	sd	s1,24(sp)
    80004a40:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a42:	fd840613          	addi	a2,s0,-40
    80004a46:	4581                	li	a1,0
    80004a48:	4501                	li	a0,0
    80004a4a:	e19ff0ef          	jal	ra,80004862 <argfd>
    return -1;
    80004a4e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a50:	00054f63          	bltz	a0,80004a6e <sys_dup+0x36>
  if((fd=fdalloc(f)) < 0)
    80004a54:	fd843503          	ld	a0,-40(s0)
    80004a58:	e63ff0ef          	jal	ra,800048ba <fdalloc>
    80004a5c:	84aa                	mv	s1,a0
    return -1;
    80004a5e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004a60:	00054763          	bltz	a0,80004a6e <sys_dup+0x36>
  filedup(f);
    80004a64:	fd843503          	ld	a0,-40(s0)
    80004a68:	caaff0ef          	jal	ra,80003f12 <filedup>
  return fd;
    80004a6c:	87a6                	mv	a5,s1
}
    80004a6e:	853e                	mv	a0,a5
    80004a70:	70a2                	ld	ra,40(sp)
    80004a72:	7402                	ld	s0,32(sp)
    80004a74:	64e2                	ld	s1,24(sp)
    80004a76:	6145                	addi	sp,sp,48
    80004a78:	8082                	ret

0000000080004a7a <sys_read>:
{
    80004a7a:	7179                	addi	sp,sp,-48
    80004a7c:	f406                	sd	ra,40(sp)
    80004a7e:	f022                	sd	s0,32(sp)
    80004a80:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a82:	fd840593          	addi	a1,s0,-40
    80004a86:	4505                	li	a0,1
    80004a88:	d59fd0ef          	jal	ra,800027e0 <argaddr>
  argint(2, &n);
    80004a8c:	fe440593          	addi	a1,s0,-28
    80004a90:	4509                	li	a0,2
    80004a92:	d33fd0ef          	jal	ra,800027c4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a96:	fe840613          	addi	a2,s0,-24
    80004a9a:	4581                	li	a1,0
    80004a9c:	4501                	li	a0,0
    80004a9e:	dc5ff0ef          	jal	ra,80004862 <argfd>
    80004aa2:	87aa                	mv	a5,a0
    return -1;
    80004aa4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004aa6:	0007ca63          	bltz	a5,80004aba <sys_read+0x40>
  return fileread(f, p, n);
    80004aaa:	fe442603          	lw	a2,-28(s0)
    80004aae:	fd843583          	ld	a1,-40(s0)
    80004ab2:	fe843503          	ld	a0,-24(s0)
    80004ab6:	da8ff0ef          	jal	ra,8000405e <fileread>
}
    80004aba:	70a2                	ld	ra,40(sp)
    80004abc:	7402                	ld	s0,32(sp)
    80004abe:	6145                	addi	sp,sp,48
    80004ac0:	8082                	ret

0000000080004ac2 <sys_write>:
{
    80004ac2:	7179                	addi	sp,sp,-48
    80004ac4:	f406                	sd	ra,40(sp)
    80004ac6:	f022                	sd	s0,32(sp)
    80004ac8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004aca:	fd840593          	addi	a1,s0,-40
    80004ace:	4505                	li	a0,1
    80004ad0:	d11fd0ef          	jal	ra,800027e0 <argaddr>
  argint(2, &n);
    80004ad4:	fe440593          	addi	a1,s0,-28
    80004ad8:	4509                	li	a0,2
    80004ada:	cebfd0ef          	jal	ra,800027c4 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ade:	fe840613          	addi	a2,s0,-24
    80004ae2:	4581                	li	a1,0
    80004ae4:	4501                	li	a0,0
    80004ae6:	d7dff0ef          	jal	ra,80004862 <argfd>
    80004aea:	87aa                	mv	a5,a0
    return -1;
    80004aec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004aee:	0007ca63          	bltz	a5,80004b02 <sys_write+0x40>
  return filewrite(f, p, n);
    80004af2:	fe442603          	lw	a2,-28(s0)
    80004af6:	fd843583          	ld	a1,-40(s0)
    80004afa:	fe843503          	ld	a0,-24(s0)
    80004afe:	e0eff0ef          	jal	ra,8000410c <filewrite>
}
    80004b02:	70a2                	ld	ra,40(sp)
    80004b04:	7402                	ld	s0,32(sp)
    80004b06:	6145                	addi	sp,sp,48
    80004b08:	8082                	ret

0000000080004b0a <sys_close>:
{
    80004b0a:	1101                	addi	sp,sp,-32
    80004b0c:	ec06                	sd	ra,24(sp)
    80004b0e:	e822                	sd	s0,16(sp)
    80004b10:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b12:	fe040613          	addi	a2,s0,-32
    80004b16:	fec40593          	addi	a1,s0,-20
    80004b1a:	4501                	li	a0,0
    80004b1c:	d47ff0ef          	jal	ra,80004862 <argfd>
    return -1;
    80004b20:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b22:	02054063          	bltz	a0,80004b42 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b26:	df7fc0ef          	jal	ra,8000191c <myproc>
    80004b2a:	fec42783          	lw	a5,-20(s0)
    80004b2e:	07e9                	addi	a5,a5,26
    80004b30:	078e                	slli	a5,a5,0x3
    80004b32:	97aa                	add	a5,a5,a0
    80004b34:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004b38:	fe043503          	ld	a0,-32(s0)
    80004b3c:	c1cff0ef          	jal	ra,80003f58 <fileclose>
  return 0;
    80004b40:	4781                	li	a5,0
}
    80004b42:	853e                	mv	a0,a5
    80004b44:	60e2                	ld	ra,24(sp)
    80004b46:	6442                	ld	s0,16(sp)
    80004b48:	6105                	addi	sp,sp,32
    80004b4a:	8082                	ret

0000000080004b4c <sys_fstat>:
{
    80004b4c:	1101                	addi	sp,sp,-32
    80004b4e:	ec06                	sd	ra,24(sp)
    80004b50:	e822                	sd	s0,16(sp)
    80004b52:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004b54:	fe040593          	addi	a1,s0,-32
    80004b58:	4505                	li	a0,1
    80004b5a:	c87fd0ef          	jal	ra,800027e0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004b5e:	fe840613          	addi	a2,s0,-24
    80004b62:	4581                	li	a1,0
    80004b64:	4501                	li	a0,0
    80004b66:	cfdff0ef          	jal	ra,80004862 <argfd>
    80004b6a:	87aa                	mv	a5,a0
    return -1;
    80004b6c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b6e:	0007c863          	bltz	a5,80004b7e <sys_fstat+0x32>
  return filestat(f, st);
    80004b72:	fe043583          	ld	a1,-32(s0)
    80004b76:	fe843503          	ld	a0,-24(s0)
    80004b7a:	c86ff0ef          	jal	ra,80004000 <filestat>
}
    80004b7e:	60e2                	ld	ra,24(sp)
    80004b80:	6442                	ld	s0,16(sp)
    80004b82:	6105                	addi	sp,sp,32
    80004b84:	8082                	ret

0000000080004b86 <sys_link>:
{
    80004b86:	7169                	addi	sp,sp,-304
    80004b88:	f606                	sd	ra,296(sp)
    80004b8a:	f222                	sd	s0,288(sp)
    80004b8c:	ee26                	sd	s1,280(sp)
    80004b8e:	ea4a                	sd	s2,272(sp)
    80004b90:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b92:	08000613          	li	a2,128
    80004b96:	ed040593          	addi	a1,s0,-304
    80004b9a:	4501                	li	a0,0
    80004b9c:	c61fd0ef          	jal	ra,800027fc <argstr>
    return -1;
    80004ba0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ba2:	0c054663          	bltz	a0,80004c6e <sys_link+0xe8>
    80004ba6:	08000613          	li	a2,128
    80004baa:	f5040593          	addi	a1,s0,-176
    80004bae:	4505                	li	a0,1
    80004bb0:	c4dfd0ef          	jal	ra,800027fc <argstr>
    return -1;
    80004bb4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bb6:	0a054c63          	bltz	a0,80004c6e <sys_link+0xe8>
  begin_op();
    80004bba:	f83fe0ef          	jal	ra,80003b3c <begin_op>
  if((ip = namei(old)) == 0){
    80004bbe:	ed040513          	addi	a0,s0,-304
    80004bc2:	da3fe0ef          	jal	ra,80003964 <namei>
    80004bc6:	84aa                	mv	s1,a0
    80004bc8:	c525                	beqz	a0,80004c30 <sys_link+0xaa>
  ilock(ip);
    80004bca:	ee8fe0ef          	jal	ra,800032b2 <ilock>
  if(ip->type == T_DIR){
    80004bce:	04449703          	lh	a4,68(s1)
    80004bd2:	4785                	li	a5,1
    80004bd4:	06f70263          	beq	a4,a5,80004c38 <sys_link+0xb2>
  ip->nlink++;
    80004bd8:	04a4d783          	lhu	a5,74(s1)
    80004bdc:	2785                	addiw	a5,a5,1
    80004bde:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004be2:	8526                	mv	a0,s1
    80004be4:	e1cfe0ef          	jal	ra,80003200 <iupdate>
  iunlock(ip);
    80004be8:	8526                	mv	a0,s1
    80004bea:	f72fe0ef          	jal	ra,8000335c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004bee:	fd040593          	addi	a1,s0,-48
    80004bf2:	f5040513          	addi	a0,s0,-176
    80004bf6:	d89fe0ef          	jal	ra,8000397e <nameiparent>
    80004bfa:	892a                	mv	s2,a0
    80004bfc:	c921                	beqz	a0,80004c4c <sys_link+0xc6>
  ilock(dp);
    80004bfe:	eb4fe0ef          	jal	ra,800032b2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c02:	00092703          	lw	a4,0(s2)
    80004c06:	409c                	lw	a5,0(s1)
    80004c08:	02f71f63          	bne	a4,a5,80004c46 <sys_link+0xc0>
    80004c0c:	40d0                	lw	a2,4(s1)
    80004c0e:	fd040593          	addi	a1,s0,-48
    80004c12:	854a                	mv	a0,s2
    80004c14:	cb7fe0ef          	jal	ra,800038ca <dirlink>
    80004c18:	02054763          	bltz	a0,80004c46 <sys_link+0xc0>
  iunlockput(dp);
    80004c1c:	854a                	mv	a0,s2
    80004c1e:	89bfe0ef          	jal	ra,800034b8 <iunlockput>
  iput(ip);
    80004c22:	8526                	mv	a0,s1
    80004c24:	80dfe0ef          	jal	ra,80003430 <iput>
  end_op();
    80004c28:	f85fe0ef          	jal	ra,80003bac <end_op>
  return 0;
    80004c2c:	4781                	li	a5,0
    80004c2e:	a081                	j	80004c6e <sys_link+0xe8>
    end_op();
    80004c30:	f7dfe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004c34:	57fd                	li	a5,-1
    80004c36:	a825                	j	80004c6e <sys_link+0xe8>
    iunlockput(ip);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	87ffe0ef          	jal	ra,800034b8 <iunlockput>
    end_op();
    80004c3e:	f6ffe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004c42:	57fd                	li	a5,-1
    80004c44:	a02d                	j	80004c6e <sys_link+0xe8>
    iunlockput(dp);
    80004c46:	854a                	mv	a0,s2
    80004c48:	871fe0ef          	jal	ra,800034b8 <iunlockput>
  ilock(ip);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	e64fe0ef          	jal	ra,800032b2 <ilock>
  ip->nlink--;
    80004c52:	04a4d783          	lhu	a5,74(s1)
    80004c56:	37fd                	addiw	a5,a5,-1
    80004c58:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c5c:	8526                	mv	a0,s1
    80004c5e:	da2fe0ef          	jal	ra,80003200 <iupdate>
  iunlockput(ip);
    80004c62:	8526                	mv	a0,s1
    80004c64:	855fe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004c68:	f45fe0ef          	jal	ra,80003bac <end_op>
  return -1;
    80004c6c:	57fd                	li	a5,-1
}
    80004c6e:	853e                	mv	a0,a5
    80004c70:	70b2                	ld	ra,296(sp)
    80004c72:	7412                	ld	s0,288(sp)
    80004c74:	64f2                	ld	s1,280(sp)
    80004c76:	6952                	ld	s2,272(sp)
    80004c78:	6155                	addi	sp,sp,304
    80004c7a:	8082                	ret

0000000080004c7c <sys_unlink>:
{
    80004c7c:	7151                	addi	sp,sp,-240
    80004c7e:	f586                	sd	ra,232(sp)
    80004c80:	f1a2                	sd	s0,224(sp)
    80004c82:	eda6                	sd	s1,216(sp)
    80004c84:	e9ca                	sd	s2,208(sp)
    80004c86:	e5ce                	sd	s3,200(sp)
    80004c88:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c8a:	08000613          	li	a2,128
    80004c8e:	f3040593          	addi	a1,s0,-208
    80004c92:	4501                	li	a0,0
    80004c94:	b69fd0ef          	jal	ra,800027fc <argstr>
    80004c98:	12054b63          	bltz	a0,80004dce <sys_unlink+0x152>
  begin_op();
    80004c9c:	ea1fe0ef          	jal	ra,80003b3c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ca0:	fb040593          	addi	a1,s0,-80
    80004ca4:	f3040513          	addi	a0,s0,-208
    80004ca8:	cd7fe0ef          	jal	ra,8000397e <nameiparent>
    80004cac:	84aa                	mv	s1,a0
    80004cae:	c54d                	beqz	a0,80004d58 <sys_unlink+0xdc>
  ilock(dp);
    80004cb0:	e02fe0ef          	jal	ra,800032b2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004cb4:	00003597          	auipc	a1,0x3
    80004cb8:	af458593          	addi	a1,a1,-1292 # 800077a8 <syscalls+0x2b0>
    80004cbc:	fb040513          	addi	a0,s0,-80
    80004cc0:	a29fe0ef          	jal	ra,800036e8 <namecmp>
    80004cc4:	10050a63          	beqz	a0,80004dd8 <sys_unlink+0x15c>
    80004cc8:	00003597          	auipc	a1,0x3
    80004ccc:	ae858593          	addi	a1,a1,-1304 # 800077b0 <syscalls+0x2b8>
    80004cd0:	fb040513          	addi	a0,s0,-80
    80004cd4:	a15fe0ef          	jal	ra,800036e8 <namecmp>
    80004cd8:	10050063          	beqz	a0,80004dd8 <sys_unlink+0x15c>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004cdc:	f2c40613          	addi	a2,s0,-212
    80004ce0:	fb040593          	addi	a1,s0,-80
    80004ce4:	8526                	mv	a0,s1
    80004ce6:	a19fe0ef          	jal	ra,800036fe <dirlookup>
    80004cea:	892a                	mv	s2,a0
    80004cec:	0e050663          	beqz	a0,80004dd8 <sys_unlink+0x15c>
  ilock(ip);
    80004cf0:	dc2fe0ef          	jal	ra,800032b2 <ilock>
  if(ip->nlink < 1)
    80004cf4:	04a91783          	lh	a5,74(s2)
    80004cf8:	06f05463          	blez	a5,80004d60 <sys_unlink+0xe4>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004cfc:	04491703          	lh	a4,68(s2)
    80004d00:	4785                	li	a5,1
    80004d02:	06f70563          	beq	a4,a5,80004d6c <sys_unlink+0xf0>
  memset(&de, 0, sizeof(de));
    80004d06:	4641                	li	a2,16
    80004d08:	4581                	li	a1,0
    80004d0a:	fc040513          	addi	a0,s0,-64
    80004d0e:	f6ffb0ef          	jal	ra,80000c7c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d12:	4741                	li	a4,16
    80004d14:	f2c42683          	lw	a3,-212(s0)
    80004d18:	fc040613          	addi	a2,s0,-64
    80004d1c:	4581                	li	a1,0
    80004d1e:	8526                	mv	a0,s1
    80004d20:	8c7fe0ef          	jal	ra,800035e6 <writei>
    80004d24:	47c1                	li	a5,16
    80004d26:	08f51563          	bne	a0,a5,80004db0 <sys_unlink+0x134>
  if(ip->type == T_DIR){
    80004d2a:	04491703          	lh	a4,68(s2)
    80004d2e:	4785                	li	a5,1
    80004d30:	08f70663          	beq	a4,a5,80004dbc <sys_unlink+0x140>
  iunlockput(dp);
    80004d34:	8526                	mv	a0,s1
    80004d36:	f82fe0ef          	jal	ra,800034b8 <iunlockput>
  ip->nlink--;
    80004d3a:	04a95783          	lhu	a5,74(s2)
    80004d3e:	37fd                	addiw	a5,a5,-1
    80004d40:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d44:	854a                	mv	a0,s2
    80004d46:	cbafe0ef          	jal	ra,80003200 <iupdate>
  iunlockput(ip);
    80004d4a:	854a                	mv	a0,s2
    80004d4c:	f6cfe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004d50:	e5dfe0ef          	jal	ra,80003bac <end_op>
  return 0;
    80004d54:	4501                	li	a0,0
    80004d56:	a079                	j	80004de4 <sys_unlink+0x168>
    end_op();
    80004d58:	e55fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004d5c:	557d                	li	a0,-1
    80004d5e:	a059                	j	80004de4 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004d60:	00003517          	auipc	a0,0x3
    80004d64:	a5850513          	addi	a0,a0,-1448 # 800077b8 <syscalls+0x2c0>
    80004d68:	9f5fb0ef          	jal	ra,8000075c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d6c:	04c92703          	lw	a4,76(s2)
    80004d70:	02000793          	li	a5,32
    80004d74:	f8e7f9e3          	bgeu	a5,a4,80004d06 <sys_unlink+0x8a>
    80004d78:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d7c:	4741                	li	a4,16
    80004d7e:	86ce                	mv	a3,s3
    80004d80:	f1840613          	addi	a2,s0,-232
    80004d84:	4581                	li	a1,0
    80004d86:	854a                	mv	a0,s2
    80004d88:	f7afe0ef          	jal	ra,80003502 <readi>
    80004d8c:	47c1                	li	a5,16
    80004d8e:	00f51b63          	bne	a0,a5,80004da4 <sys_unlink+0x128>
    if(de.inum != 0)
    80004d92:	f1845783          	lhu	a5,-232(s0)
    80004d96:	ef95                	bnez	a5,80004dd2 <sys_unlink+0x156>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d98:	29c1                	addiw	s3,s3,16
    80004d9a:	04c92783          	lw	a5,76(s2)
    80004d9e:	fcf9efe3          	bltu	s3,a5,80004d7c <sys_unlink+0x100>
    80004da2:	b795                	j	80004d06 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004da4:	00003517          	auipc	a0,0x3
    80004da8:	a2c50513          	addi	a0,a0,-1492 # 800077d0 <syscalls+0x2d8>
    80004dac:	9b1fb0ef          	jal	ra,8000075c <panic>
    panic("unlink: writei");
    80004db0:	00003517          	auipc	a0,0x3
    80004db4:	a3850513          	addi	a0,a0,-1480 # 800077e8 <syscalls+0x2f0>
    80004db8:	9a5fb0ef          	jal	ra,8000075c <panic>
    dp->nlink--;
    80004dbc:	04a4d783          	lhu	a5,74(s1)
    80004dc0:	37fd                	addiw	a5,a5,-1
    80004dc2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dc6:	8526                	mv	a0,s1
    80004dc8:	c38fe0ef          	jal	ra,80003200 <iupdate>
    80004dcc:	b7a5                	j	80004d34 <sys_unlink+0xb8>
    return -1;
    80004dce:	557d                	li	a0,-1
    80004dd0:	a811                	j	80004de4 <sys_unlink+0x168>
    iunlockput(ip);
    80004dd2:	854a                	mv	a0,s2
    80004dd4:	ee4fe0ef          	jal	ra,800034b8 <iunlockput>
  iunlockput(dp);
    80004dd8:	8526                	mv	a0,s1
    80004dda:	edefe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004dde:	dcffe0ef          	jal	ra,80003bac <end_op>
  return -1;
    80004de2:	557d                	li	a0,-1
}
    80004de4:	70ae                	ld	ra,232(sp)
    80004de6:	740e                	ld	s0,224(sp)
    80004de8:	64ee                	ld	s1,216(sp)
    80004dea:	694e                	ld	s2,208(sp)
    80004dec:	69ae                	ld	s3,200(sp)
    80004dee:	616d                	addi	sp,sp,240
    80004df0:	8082                	ret

0000000080004df2 <sys_open>:

uint64
sys_open(void)
{
    80004df2:	7131                	addi	sp,sp,-192
    80004df4:	fd06                	sd	ra,184(sp)
    80004df6:	f922                	sd	s0,176(sp)
    80004df8:	f526                	sd	s1,168(sp)
    80004dfa:	f14a                	sd	s2,160(sp)
    80004dfc:	ed4e                	sd	s3,152(sp)
    80004dfe:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e00:	f4c40593          	addi	a1,s0,-180
    80004e04:	4505                	li	a0,1
    80004e06:	9bffd0ef          	jal	ra,800027c4 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e0a:	08000613          	li	a2,128
    80004e0e:	f5040593          	addi	a1,s0,-176
    80004e12:	4501                	li	a0,0
    80004e14:	9e9fd0ef          	jal	ra,800027fc <argstr>
    80004e18:	87aa                	mv	a5,a0
    return -1;
    80004e1a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e1c:	0807cd63          	bltz	a5,80004eb6 <sys_open+0xc4>

  begin_op();
    80004e20:	d1dfe0ef          	jal	ra,80003b3c <begin_op>

  if(omode & O_CREATE){
    80004e24:	f4c42783          	lw	a5,-180(s0)
    80004e28:	2007f793          	andi	a5,a5,512
    80004e2c:	c3c5                	beqz	a5,80004ecc <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e2e:	4681                	li	a3,0
    80004e30:	4601                	li	a2,0
    80004e32:	4589                	li	a1,2
    80004e34:	f5040513          	addi	a0,s0,-176
    80004e38:	ac1ff0ef          	jal	ra,800048f8 <create>
    80004e3c:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e3e:	c159                	beqz	a0,80004ec4 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e40:	04449703          	lh	a4,68(s1)
    80004e44:	478d                	li	a5,3
    80004e46:	00f71763          	bne	a4,a5,80004e54 <sys_open+0x62>
    80004e4a:	0464d703          	lhu	a4,70(s1)
    80004e4e:	47a5                	li	a5,9
    80004e50:	0ae7e963          	bltu	a5,a4,80004f02 <sys_open+0x110>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e54:	860ff0ef          	jal	ra,80003eb4 <filealloc>
    80004e58:	89aa                	mv	s3,a0
    80004e5a:	0c050963          	beqz	a0,80004f2c <sys_open+0x13a>
    80004e5e:	a5dff0ef          	jal	ra,800048ba <fdalloc>
    80004e62:	892a                	mv	s2,a0
    80004e64:	0c054163          	bltz	a0,80004f26 <sys_open+0x134>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004e68:	04449703          	lh	a4,68(s1)
    80004e6c:	478d                	li	a5,3
    80004e6e:	0af70163          	beq	a4,a5,80004f10 <sys_open+0x11e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004e72:	4789                	li	a5,2
    80004e74:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004e78:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004e7c:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004e80:	f4c42783          	lw	a5,-180(s0)
    80004e84:	0017c713          	xori	a4,a5,1
    80004e88:	8b05                	andi	a4,a4,1
    80004e8a:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004e8e:	0037f713          	andi	a4,a5,3
    80004e92:	00e03733          	snez	a4,a4
    80004e96:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e9a:	4007f793          	andi	a5,a5,1024
    80004e9e:	c791                	beqz	a5,80004eaa <sys_open+0xb8>
    80004ea0:	04449703          	lh	a4,68(s1)
    80004ea4:	4789                	li	a5,2
    80004ea6:	06f70c63          	beq	a4,a5,80004f1e <sys_open+0x12c>
    itrunc(ip);
  }

  iunlock(ip);
    80004eaa:	8526                	mv	a0,s1
    80004eac:	cb0fe0ef          	jal	ra,8000335c <iunlock>
  end_op();
    80004eb0:	cfdfe0ef          	jal	ra,80003bac <end_op>

  return fd;
    80004eb4:	854a                	mv	a0,s2
}
    80004eb6:	70ea                	ld	ra,184(sp)
    80004eb8:	744a                	ld	s0,176(sp)
    80004eba:	74aa                	ld	s1,168(sp)
    80004ebc:	790a                	ld	s2,160(sp)
    80004ebe:	69ea                	ld	s3,152(sp)
    80004ec0:	6129                	addi	sp,sp,192
    80004ec2:	8082                	ret
      end_op();
    80004ec4:	ce9fe0ef          	jal	ra,80003bac <end_op>
      return -1;
    80004ec8:	557d                	li	a0,-1
    80004eca:	b7f5                	j	80004eb6 <sys_open+0xc4>
    if((ip = namei(path)) == 0){
    80004ecc:	f5040513          	addi	a0,s0,-176
    80004ed0:	a95fe0ef          	jal	ra,80003964 <namei>
    80004ed4:	84aa                	mv	s1,a0
    80004ed6:	c115                	beqz	a0,80004efa <sys_open+0x108>
    ilock(ip);
    80004ed8:	bdafe0ef          	jal	ra,800032b2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004edc:	04449703          	lh	a4,68(s1)
    80004ee0:	4785                	li	a5,1
    80004ee2:	f4f71fe3          	bne	a4,a5,80004e40 <sys_open+0x4e>
    80004ee6:	f4c42783          	lw	a5,-180(s0)
    80004eea:	d7ad                	beqz	a5,80004e54 <sys_open+0x62>
      iunlockput(ip);
    80004eec:	8526                	mv	a0,s1
    80004eee:	dcafe0ef          	jal	ra,800034b8 <iunlockput>
      end_op();
    80004ef2:	cbbfe0ef          	jal	ra,80003bac <end_op>
      return -1;
    80004ef6:	557d                	li	a0,-1
    80004ef8:	bf7d                	j	80004eb6 <sys_open+0xc4>
      end_op();
    80004efa:	cb3fe0ef          	jal	ra,80003bac <end_op>
      return -1;
    80004efe:	557d                	li	a0,-1
    80004f00:	bf5d                	j	80004eb6 <sys_open+0xc4>
    iunlockput(ip);
    80004f02:	8526                	mv	a0,s1
    80004f04:	db4fe0ef          	jal	ra,800034b8 <iunlockput>
    end_op();
    80004f08:	ca5fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004f0c:	557d                	li	a0,-1
    80004f0e:	b765                	j	80004eb6 <sys_open+0xc4>
    f->type = FD_DEVICE;
    80004f10:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004f14:	04649783          	lh	a5,70(s1)
    80004f18:	02f99223          	sh	a5,36(s3)
    80004f1c:	b785                	j	80004e7c <sys_open+0x8a>
    itrunc(ip);
    80004f1e:	8526                	mv	a0,s1
    80004f20:	c7cfe0ef          	jal	ra,8000339c <itrunc>
    80004f24:	b759                	j	80004eaa <sys_open+0xb8>
      fileclose(f);
    80004f26:	854e                	mv	a0,s3
    80004f28:	830ff0ef          	jal	ra,80003f58 <fileclose>
    iunlockput(ip);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	d8afe0ef          	jal	ra,800034b8 <iunlockput>
    end_op();
    80004f32:	c7bfe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004f36:	557d                	li	a0,-1
    80004f38:	bfbd                	j	80004eb6 <sys_open+0xc4>

0000000080004f3a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004f3a:	7175                	addi	sp,sp,-144
    80004f3c:	e506                	sd	ra,136(sp)
    80004f3e:	e122                	sd	s0,128(sp)
    80004f40:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004f42:	bfbfe0ef          	jal	ra,80003b3c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004f46:	08000613          	li	a2,128
    80004f4a:	f7040593          	addi	a1,s0,-144
    80004f4e:	4501                	li	a0,0
    80004f50:	8adfd0ef          	jal	ra,800027fc <argstr>
    80004f54:	02054363          	bltz	a0,80004f7a <sys_mkdir+0x40>
    80004f58:	4681                	li	a3,0
    80004f5a:	4601                	li	a2,0
    80004f5c:	4585                	li	a1,1
    80004f5e:	f7040513          	addi	a0,s0,-144
    80004f62:	997ff0ef          	jal	ra,800048f8 <create>
    80004f66:	c911                	beqz	a0,80004f7a <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f68:	d50fe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004f6c:	c41fe0ef          	jal	ra,80003bac <end_op>
  return 0;
    80004f70:	4501                	li	a0,0
}
    80004f72:	60aa                	ld	ra,136(sp)
    80004f74:	640a                	ld	s0,128(sp)
    80004f76:	6149                	addi	sp,sp,144
    80004f78:	8082                	ret
    end_op();
    80004f7a:	c33fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004f7e:	557d                	li	a0,-1
    80004f80:	bfcd                	j	80004f72 <sys_mkdir+0x38>

0000000080004f82 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f82:	7135                	addi	sp,sp,-160
    80004f84:	ed06                	sd	ra,152(sp)
    80004f86:	e922                	sd	s0,144(sp)
    80004f88:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f8a:	bb3fe0ef          	jal	ra,80003b3c <begin_op>
  argint(1, &major);
    80004f8e:	f6c40593          	addi	a1,s0,-148
    80004f92:	4505                	li	a0,1
    80004f94:	831fd0ef          	jal	ra,800027c4 <argint>
  argint(2, &minor);
    80004f98:	f6840593          	addi	a1,s0,-152
    80004f9c:	4509                	li	a0,2
    80004f9e:	827fd0ef          	jal	ra,800027c4 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fa2:	08000613          	li	a2,128
    80004fa6:	f7040593          	addi	a1,s0,-144
    80004faa:	4501                	li	a0,0
    80004fac:	851fd0ef          	jal	ra,800027fc <argstr>
    80004fb0:	02054563          	bltz	a0,80004fda <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004fb4:	f6841683          	lh	a3,-152(s0)
    80004fb8:	f6c41603          	lh	a2,-148(s0)
    80004fbc:	458d                	li	a1,3
    80004fbe:	f7040513          	addi	a0,s0,-144
    80004fc2:	937ff0ef          	jal	ra,800048f8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004fc6:	c911                	beqz	a0,80004fda <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fc8:	cf0fe0ef          	jal	ra,800034b8 <iunlockput>
  end_op();
    80004fcc:	be1fe0ef          	jal	ra,80003bac <end_op>
  return 0;
    80004fd0:	4501                	li	a0,0
}
    80004fd2:	60ea                	ld	ra,152(sp)
    80004fd4:	644a                	ld	s0,144(sp)
    80004fd6:	610d                	addi	sp,sp,160
    80004fd8:	8082                	ret
    end_op();
    80004fda:	bd3fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    80004fde:	557d                	li	a0,-1
    80004fe0:	bfcd                	j	80004fd2 <sys_mknod+0x50>

0000000080004fe2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fe2:	7135                	addi	sp,sp,-160
    80004fe4:	ed06                	sd	ra,152(sp)
    80004fe6:	e922                	sd	s0,144(sp)
    80004fe8:	e526                	sd	s1,136(sp)
    80004fea:	e14a                	sd	s2,128(sp)
    80004fec:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fee:	92ffc0ef          	jal	ra,8000191c <myproc>
    80004ff2:	892a                	mv	s2,a0
  
  begin_op();
    80004ff4:	b49fe0ef          	jal	ra,80003b3c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004ff8:	08000613          	li	a2,128
    80004ffc:	f6040593          	addi	a1,s0,-160
    80005000:	4501                	li	a0,0
    80005002:	ffafd0ef          	jal	ra,800027fc <argstr>
    80005006:	04054163          	bltz	a0,80005048 <sys_chdir+0x66>
    8000500a:	f6040513          	addi	a0,s0,-160
    8000500e:	957fe0ef          	jal	ra,80003964 <namei>
    80005012:	84aa                	mv	s1,a0
    80005014:	c915                	beqz	a0,80005048 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005016:	a9cfe0ef          	jal	ra,800032b2 <ilock>
  if(ip->type != T_DIR){
    8000501a:	04449703          	lh	a4,68(s1)
    8000501e:	4785                	li	a5,1
    80005020:	02f71863          	bne	a4,a5,80005050 <sys_chdir+0x6e>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005024:	8526                	mv	a0,s1
    80005026:	b36fe0ef          	jal	ra,8000335c <iunlock>
  iput(p->cwd);
    8000502a:	15093503          	ld	a0,336(s2)
    8000502e:	c02fe0ef          	jal	ra,80003430 <iput>
  end_op();
    80005032:	b7bfe0ef          	jal	ra,80003bac <end_op>
  p->cwd = ip;
    80005036:	14993823          	sd	s1,336(s2)
  return 0;
    8000503a:	4501                	li	a0,0
}
    8000503c:	60ea                	ld	ra,152(sp)
    8000503e:	644a                	ld	s0,144(sp)
    80005040:	64aa                	ld	s1,136(sp)
    80005042:	690a                	ld	s2,128(sp)
    80005044:	610d                	addi	sp,sp,160
    80005046:	8082                	ret
    end_op();
    80005048:	b65fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    8000504c:	557d                	li	a0,-1
    8000504e:	b7fd                	j	8000503c <sys_chdir+0x5a>
    iunlockput(ip);
    80005050:	8526                	mv	a0,s1
    80005052:	c66fe0ef          	jal	ra,800034b8 <iunlockput>
    end_op();
    80005056:	b57fe0ef          	jal	ra,80003bac <end_op>
    return -1;
    8000505a:	557d                	li	a0,-1
    8000505c:	b7c5                	j	8000503c <sys_chdir+0x5a>

000000008000505e <sys_exec>:

uint64
sys_exec(void)
{
    8000505e:	7145                	addi	sp,sp,-464
    80005060:	e786                	sd	ra,456(sp)
    80005062:	e3a2                	sd	s0,448(sp)
    80005064:	ff26                	sd	s1,440(sp)
    80005066:	fb4a                	sd	s2,432(sp)
    80005068:	f74e                	sd	s3,424(sp)
    8000506a:	f352                	sd	s4,416(sp)
    8000506c:	ef56                	sd	s5,408(sp)
    8000506e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005070:	e3840593          	addi	a1,s0,-456
    80005074:	4505                	li	a0,1
    80005076:	f6afd0ef          	jal	ra,800027e0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000507a:	08000613          	li	a2,128
    8000507e:	f4040593          	addi	a1,s0,-192
    80005082:	4501                	li	a0,0
    80005084:	f78fd0ef          	jal	ra,800027fc <argstr>
    80005088:	87aa                	mv	a5,a0
    return -1;
    8000508a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000508c:	0a07c463          	bltz	a5,80005134 <sys_exec+0xd6>
  }
  memset(argv, 0, sizeof(argv));
    80005090:	10000613          	li	a2,256
    80005094:	4581                	li	a1,0
    80005096:	e4040513          	addi	a0,s0,-448
    8000509a:	be3fb0ef          	jal	ra,80000c7c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000509e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800050a2:	89a6                	mv	s3,s1
    800050a4:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050a6:	02000a13          	li	s4,32
    800050aa:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050ae:	00391513          	slli	a0,s2,0x3
    800050b2:	e3040593          	addi	a1,s0,-464
    800050b6:	e3843783          	ld	a5,-456(s0)
    800050ba:	953e                	add	a0,a0,a5
    800050bc:	e7efd0ef          	jal	ra,8000273a <fetchaddr>
    800050c0:	02054663          	bltz	a0,800050ec <sys_exec+0x8e>
      goto bad;
    }
    if(uarg == 0){
    800050c4:	e3043783          	ld	a5,-464(s0)
    800050c8:	cf8d                	beqz	a5,80005102 <sys_exec+0xa4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050ca:	a0ffb0ef          	jal	ra,80000ad8 <kalloc>
    800050ce:	85aa                	mv	a1,a0
    800050d0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800050d4:	cd01                	beqz	a0,800050ec <sys_exec+0x8e>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800050d6:	6605                	lui	a2,0x1
    800050d8:	e3043503          	ld	a0,-464(s0)
    800050dc:	ea8fd0ef          	jal	ra,80002784 <fetchstr>
    800050e0:	00054663          	bltz	a0,800050ec <sys_exec+0x8e>
    if(i >= NELEM(argv)){
    800050e4:	0905                	addi	s2,s2,1
    800050e6:	09a1                	addi	s3,s3,8
    800050e8:	fd4911e3          	bne	s2,s4,800050aa <sys_exec+0x4c>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050ec:	10048913          	addi	s2,s1,256
    800050f0:	6088                	ld	a0,0(s1)
    800050f2:	c121                	beqz	a0,80005132 <sys_exec+0xd4>
    kfree(argv[i]);
    800050f4:	905fb0ef          	jal	ra,800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800050f8:	04a1                	addi	s1,s1,8
    800050fa:	ff249be3          	bne	s1,s2,800050f0 <sys_exec+0x92>
  return -1;
    800050fe:	557d                	li	a0,-1
    80005100:	a815                	j	80005134 <sys_exec+0xd6>
      argv[i] = 0;
    80005102:	0a8e                	slli	s5,s5,0x3
    80005104:	fc040793          	addi	a5,s0,-64
    80005108:	9abe                	add	s5,s5,a5
    8000510a:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    8000510e:	e4040593          	addi	a1,s0,-448
    80005112:	f4040513          	addi	a0,s0,-192
    80005116:	bf2ff0ef          	jal	ra,80004508 <exec>
    8000511a:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000511c:	10048993          	addi	s3,s1,256
    80005120:	6088                	ld	a0,0(s1)
    80005122:	c511                	beqz	a0,8000512e <sys_exec+0xd0>
    kfree(argv[i]);
    80005124:	8d5fb0ef          	jal	ra,800009f8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005128:	04a1                	addi	s1,s1,8
    8000512a:	ff349be3          	bne	s1,s3,80005120 <sys_exec+0xc2>
  return ret;
    8000512e:	854a                	mv	a0,s2
    80005130:	a011                	j	80005134 <sys_exec+0xd6>
  return -1;
    80005132:	557d                	li	a0,-1
}
    80005134:	60be                	ld	ra,456(sp)
    80005136:	641e                	ld	s0,448(sp)
    80005138:	74fa                	ld	s1,440(sp)
    8000513a:	795a                	ld	s2,432(sp)
    8000513c:	79ba                	ld	s3,424(sp)
    8000513e:	7a1a                	ld	s4,416(sp)
    80005140:	6afa                	ld	s5,408(sp)
    80005142:	6179                	addi	sp,sp,464
    80005144:	8082                	ret

0000000080005146 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005146:	7139                	addi	sp,sp,-64
    80005148:	fc06                	sd	ra,56(sp)
    8000514a:	f822                	sd	s0,48(sp)
    8000514c:	f426                	sd	s1,40(sp)
    8000514e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005150:	fccfc0ef          	jal	ra,8000191c <myproc>
    80005154:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005156:	fd840593          	addi	a1,s0,-40
    8000515a:	4501                	li	a0,0
    8000515c:	e84fd0ef          	jal	ra,800027e0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005160:	fc840593          	addi	a1,s0,-56
    80005164:	fd040513          	addi	a0,s0,-48
    80005168:	8bcff0ef          	jal	ra,80004224 <pipealloc>
    return -1;
    8000516c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000516e:	0a054463          	bltz	a0,80005216 <sys_pipe+0xd0>
  fd0 = -1;
    80005172:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005176:	fd043503          	ld	a0,-48(s0)
    8000517a:	f40ff0ef          	jal	ra,800048ba <fdalloc>
    8000517e:	fca42223          	sw	a0,-60(s0)
    80005182:	08054163          	bltz	a0,80005204 <sys_pipe+0xbe>
    80005186:	fc843503          	ld	a0,-56(s0)
    8000518a:	f30ff0ef          	jal	ra,800048ba <fdalloc>
    8000518e:	fca42023          	sw	a0,-64(s0)
    80005192:	06054063          	bltz	a0,800051f2 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005196:	4691                	li	a3,4
    80005198:	fc440613          	addi	a2,s0,-60
    8000519c:	fd843583          	ld	a1,-40(s0)
    800051a0:	68a8                	ld	a0,80(s1)
    800051a2:	b54fc0ef          	jal	ra,800014f6 <copyout>
    800051a6:	00054e63          	bltz	a0,800051c2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051aa:	4691                	li	a3,4
    800051ac:	fc040613          	addi	a2,s0,-64
    800051b0:	fd843583          	ld	a1,-40(s0)
    800051b4:	0591                	addi	a1,a1,4
    800051b6:	68a8                	ld	a0,80(s1)
    800051b8:	b3efc0ef          	jal	ra,800014f6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800051bc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051be:	04055c63          	bgez	a0,80005216 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800051c2:	fc442783          	lw	a5,-60(s0)
    800051c6:	07e9                	addi	a5,a5,26
    800051c8:	078e                	slli	a5,a5,0x3
    800051ca:	97a6                	add	a5,a5,s1
    800051cc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800051d0:	fc042503          	lw	a0,-64(s0)
    800051d4:	0569                	addi	a0,a0,26
    800051d6:	050e                	slli	a0,a0,0x3
    800051d8:	94aa                	add	s1,s1,a0
    800051da:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800051de:	fd043503          	ld	a0,-48(s0)
    800051e2:	d77fe0ef          	jal	ra,80003f58 <fileclose>
    fileclose(wf);
    800051e6:	fc843503          	ld	a0,-56(s0)
    800051ea:	d6ffe0ef          	jal	ra,80003f58 <fileclose>
    return -1;
    800051ee:	57fd                	li	a5,-1
    800051f0:	a01d                	j	80005216 <sys_pipe+0xd0>
    if(fd0 >= 0)
    800051f2:	fc442783          	lw	a5,-60(s0)
    800051f6:	0007c763          	bltz	a5,80005204 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    800051fa:	07e9                	addi	a5,a5,26
    800051fc:	078e                	slli	a5,a5,0x3
    800051fe:	94be                	add	s1,s1,a5
    80005200:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005204:	fd043503          	ld	a0,-48(s0)
    80005208:	d51fe0ef          	jal	ra,80003f58 <fileclose>
    fileclose(wf);
    8000520c:	fc843503          	ld	a0,-56(s0)
    80005210:	d49fe0ef          	jal	ra,80003f58 <fileclose>
    return -1;
    80005214:	57fd                	li	a5,-1
}
    80005216:	853e                	mv	a0,a5
    80005218:	70e2                	ld	ra,56(sp)
    8000521a:	7442                	ld	s0,48(sp)
    8000521c:	74a2                	ld	s1,40(sp)
    8000521e:	6121                	addi	sp,sp,64
    80005220:	8082                	ret
	...

0000000080005230 <kernelvec>:
    80005230:	7111                	addi	sp,sp,-256
    80005232:	e006                	sd	ra,0(sp)
    80005234:	e40a                	sd	sp,8(sp)
    80005236:	e80e                	sd	gp,16(sp)
    80005238:	ec12                	sd	tp,24(sp)
    8000523a:	f016                	sd	t0,32(sp)
    8000523c:	f41a                	sd	t1,40(sp)
    8000523e:	f81e                	sd	t2,48(sp)
    80005240:	e4aa                	sd	a0,72(sp)
    80005242:	e8ae                	sd	a1,80(sp)
    80005244:	ecb2                	sd	a2,88(sp)
    80005246:	f0b6                	sd	a3,96(sp)
    80005248:	f4ba                	sd	a4,104(sp)
    8000524a:	f8be                	sd	a5,112(sp)
    8000524c:	fcc2                	sd	a6,120(sp)
    8000524e:	e146                	sd	a7,128(sp)
    80005250:	edf2                	sd	t3,216(sp)
    80005252:	f1f6                	sd	t4,224(sp)
    80005254:	f5fa                	sd	t5,232(sp)
    80005256:	f9fe                	sd	t6,240(sp)
    80005258:	bf2fd0ef          	jal	ra,8000264a <kerneltrap>
    8000525c:	6082                	ld	ra,0(sp)
    8000525e:	6122                	ld	sp,8(sp)
    80005260:	61c2                	ld	gp,16(sp)
    80005262:	7282                	ld	t0,32(sp)
    80005264:	7322                	ld	t1,40(sp)
    80005266:	73c2                	ld	t2,48(sp)
    80005268:	6526                	ld	a0,72(sp)
    8000526a:	65c6                	ld	a1,80(sp)
    8000526c:	6666                	ld	a2,88(sp)
    8000526e:	7686                	ld	a3,96(sp)
    80005270:	7726                	ld	a4,104(sp)
    80005272:	77c6                	ld	a5,112(sp)
    80005274:	7866                	ld	a6,120(sp)
    80005276:	688a                	ld	a7,128(sp)
    80005278:	6e6e                	ld	t3,216(sp)
    8000527a:	7e8e                	ld	t4,224(sp)
    8000527c:	7f2e                	ld	t5,232(sp)
    8000527e:	7fce                	ld	t6,240(sp)
    80005280:	6111                	addi	sp,sp,256
    80005282:	10200073          	sret
	...

000000008000528e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000528e:	1141                	addi	sp,sp,-16
    80005290:	e422                	sd	s0,8(sp)
    80005292:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005294:	0c0007b7          	lui	a5,0xc000
    80005298:	4705                	li	a4,1
    8000529a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000529c:	c3d8                	sw	a4,4(a5)
}
    8000529e:	6422                	ld	s0,8(sp)
    800052a0:	0141                	addi	sp,sp,16
    800052a2:	8082                	ret

00000000800052a4 <plicinithart>:

void
plicinithart(void)
{
    800052a4:	1141                	addi	sp,sp,-16
    800052a6:	e406                	sd	ra,8(sp)
    800052a8:	e022                	sd	s0,0(sp)
    800052aa:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052ac:	e44fc0ef          	jal	ra,800018f0 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800052b0:	0085171b          	slliw	a4,a0,0x8
    800052b4:	0c0027b7          	lui	a5,0xc002
    800052b8:	97ba                	add	a5,a5,a4
    800052ba:	40200713          	li	a4,1026
    800052be:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800052c2:	00d5151b          	slliw	a0,a0,0xd
    800052c6:	0c2017b7          	lui	a5,0xc201
    800052ca:	953e                	add	a0,a0,a5
    800052cc:	00052023          	sw	zero,0(a0)
}
    800052d0:	60a2                	ld	ra,8(sp)
    800052d2:	6402                	ld	s0,0(sp)
    800052d4:	0141                	addi	sp,sp,16
    800052d6:	8082                	ret

00000000800052d8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800052d8:	1141                	addi	sp,sp,-16
    800052da:	e406                	sd	ra,8(sp)
    800052dc:	e022                	sd	s0,0(sp)
    800052de:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052e0:	e10fc0ef          	jal	ra,800018f0 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800052e4:	00d5179b          	slliw	a5,a0,0xd
    800052e8:	0c201537          	lui	a0,0xc201
    800052ec:	953e                	add	a0,a0,a5
  return irq;
}
    800052ee:	4148                	lw	a0,4(a0)
    800052f0:	60a2                	ld	ra,8(sp)
    800052f2:	6402                	ld	s0,0(sp)
    800052f4:	0141                	addi	sp,sp,16
    800052f6:	8082                	ret

00000000800052f8 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800052f8:	1101                	addi	sp,sp,-32
    800052fa:	ec06                	sd	ra,24(sp)
    800052fc:	e822                	sd	s0,16(sp)
    800052fe:	e426                	sd	s1,8(sp)
    80005300:	1000                	addi	s0,sp,32
    80005302:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005304:	decfc0ef          	jal	ra,800018f0 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005308:	00d5151b          	slliw	a0,a0,0xd
    8000530c:	0c2017b7          	lui	a5,0xc201
    80005310:	97aa                	add	a5,a5,a0
    80005312:	c3c4                	sw	s1,4(a5)
}
    80005314:	60e2                	ld	ra,24(sp)
    80005316:	6442                	ld	s0,16(sp)
    80005318:	64a2                	ld	s1,8(sp)
    8000531a:	6105                	addi	sp,sp,32
    8000531c:	8082                	ret

000000008000531e <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    8000531e:	1141                	addi	sp,sp,-16
    80005320:	e406                	sd	ra,8(sp)
    80005322:	e022                	sd	s0,0(sp)
    80005324:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005326:	479d                	li	a5,7
    80005328:	04a7ca63          	blt	a5,a0,8000537c <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    8000532c:	0001c797          	auipc	a5,0x1c
    80005330:	87478793          	addi	a5,a5,-1932 # 80020ba0 <disk>
    80005334:	97aa                	add	a5,a5,a0
    80005336:	0187c783          	lbu	a5,24(a5)
    8000533a:	e7b9                	bnez	a5,80005388 <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    8000533c:	00451613          	slli	a2,a0,0x4
    80005340:	0001c797          	auipc	a5,0x1c
    80005344:	86078793          	addi	a5,a5,-1952 # 80020ba0 <disk>
    80005348:	6394                	ld	a3,0(a5)
    8000534a:	96b2                	add	a3,a3,a2
    8000534c:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005350:	6398                	ld	a4,0(a5)
    80005352:	9732                	add	a4,a4,a2
    80005354:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005358:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    8000535c:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005360:	953e                	add	a0,a0,a5
    80005362:	4785                	li	a5,1
    80005364:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    80005368:	0001c517          	auipc	a0,0x1c
    8000536c:	85050513          	addi	a0,a0,-1968 # 80020bb8 <disk+0x18>
    80005370:	bc1fc0ef          	jal	ra,80001f30 <wakeup>
}
    80005374:	60a2                	ld	ra,8(sp)
    80005376:	6402                	ld	s0,0(sp)
    80005378:	0141                	addi	sp,sp,16
    8000537a:	8082                	ret
    panic("free_desc 1");
    8000537c:	00002517          	auipc	a0,0x2
    80005380:	47c50513          	addi	a0,a0,1148 # 800077f8 <syscalls+0x300>
    80005384:	bd8fb0ef          	jal	ra,8000075c <panic>
    panic("free_desc 2");
    80005388:	00002517          	auipc	a0,0x2
    8000538c:	48050513          	addi	a0,a0,1152 # 80007808 <syscalls+0x310>
    80005390:	bccfb0ef          	jal	ra,8000075c <panic>

0000000080005394 <virtio_disk_init>:
{
    80005394:	1101                	addi	sp,sp,-32
    80005396:	ec06                	sd	ra,24(sp)
    80005398:	e822                	sd	s0,16(sp)
    8000539a:	e426                	sd	s1,8(sp)
    8000539c:	e04a                	sd	s2,0(sp)
    8000539e:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800053a0:	00002597          	auipc	a1,0x2
    800053a4:	47858593          	addi	a1,a1,1144 # 80007818 <syscalls+0x320>
    800053a8:	0001c517          	auipc	a0,0x1c
    800053ac:	92050513          	addi	a0,a0,-1760 # 80020cc8 <disk+0x128>
    800053b0:	f78fb0ef          	jal	ra,80000b28 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053b4:	100017b7          	lui	a5,0x10001
    800053b8:	4398                	lw	a4,0(a5)
    800053ba:	2701                	sext.w	a4,a4
    800053bc:	747277b7          	lui	a5,0x74727
    800053c0:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800053c4:	14f71263          	bne	a4,a5,80005508 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053c8:	100017b7          	lui	a5,0x10001
    800053cc:	43dc                	lw	a5,4(a5)
    800053ce:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800053d0:	4709                	li	a4,2
    800053d2:	12e79b63          	bne	a5,a4,80005508 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053d6:	100017b7          	lui	a5,0x10001
    800053da:	479c                	lw	a5,8(a5)
    800053dc:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800053de:	12e79563          	bne	a5,a4,80005508 <virtio_disk_init+0x174>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800053e2:	100017b7          	lui	a5,0x10001
    800053e6:	47d8                	lw	a4,12(a5)
    800053e8:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800053ea:	554d47b7          	lui	a5,0x554d4
    800053ee:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800053f2:	10f71b63          	bne	a4,a5,80005508 <virtio_disk_init+0x174>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053f6:	100017b7          	lui	a5,0x10001
    800053fa:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800053fe:	4705                	li	a4,1
    80005400:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005402:	470d                	li	a4,3
    80005404:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005406:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005408:	c7ffe737          	lui	a4,0xc7ffe
    8000540c:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdda7f>
    80005410:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005412:	2701                	sext.w	a4,a4
    80005414:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005416:	472d                	li	a4,11
    80005418:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    8000541a:	0707a903          	lw	s2,112(a5)
    8000541e:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005420:	00897793          	andi	a5,s2,8
    80005424:	0e078863          	beqz	a5,80005514 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005428:	100017b7          	lui	a5,0x10001
    8000542c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005430:	43fc                	lw	a5,68(a5)
    80005432:	2781                	sext.w	a5,a5
    80005434:	0e079663          	bnez	a5,80005520 <virtio_disk_init+0x18c>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005438:	100017b7          	lui	a5,0x10001
    8000543c:	5bdc                	lw	a5,52(a5)
    8000543e:	2781                	sext.w	a5,a5
  if(max == 0)
    80005440:	0e078663          	beqz	a5,8000552c <virtio_disk_init+0x198>
  if(max < NUM)
    80005444:	471d                	li	a4,7
    80005446:	0ef77963          	bgeu	a4,a5,80005538 <virtio_disk_init+0x1a4>
  disk.desc = kalloc();
    8000544a:	e8efb0ef          	jal	ra,80000ad8 <kalloc>
    8000544e:	0001b497          	auipc	s1,0x1b
    80005452:	75248493          	addi	s1,s1,1874 # 80020ba0 <disk>
    80005456:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005458:	e80fb0ef          	jal	ra,80000ad8 <kalloc>
    8000545c:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000545e:	e7afb0ef          	jal	ra,80000ad8 <kalloc>
    80005462:	87aa                	mv	a5,a0
    80005464:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005466:	6088                	ld	a0,0(s1)
    80005468:	cd71                	beqz	a0,80005544 <virtio_disk_init+0x1b0>
    8000546a:	0001b717          	auipc	a4,0x1b
    8000546e:	73e73703          	ld	a4,1854(a4) # 80020ba8 <disk+0x8>
    80005472:	cb69                	beqz	a4,80005544 <virtio_disk_init+0x1b0>
    80005474:	cbe1                	beqz	a5,80005544 <virtio_disk_init+0x1b0>
  memset(disk.desc, 0, PGSIZE);
    80005476:	6605                	lui	a2,0x1
    80005478:	4581                	li	a1,0
    8000547a:	803fb0ef          	jal	ra,80000c7c <memset>
  memset(disk.avail, 0, PGSIZE);
    8000547e:	0001b497          	auipc	s1,0x1b
    80005482:	72248493          	addi	s1,s1,1826 # 80020ba0 <disk>
    80005486:	6605                	lui	a2,0x1
    80005488:	4581                	li	a1,0
    8000548a:	6488                	ld	a0,8(s1)
    8000548c:	ff0fb0ef          	jal	ra,80000c7c <memset>
  memset(disk.used, 0, PGSIZE);
    80005490:	6605                	lui	a2,0x1
    80005492:	4581                	li	a1,0
    80005494:	6888                	ld	a0,16(s1)
    80005496:	fe6fb0ef          	jal	ra,80000c7c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000549a:	100017b7          	lui	a5,0x10001
    8000549e:	4721                	li	a4,8
    800054a0:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800054a2:	4098                	lw	a4,0(s1)
    800054a4:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800054a8:	40d8                	lw	a4,4(s1)
    800054aa:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800054ae:	6498                	ld	a4,8(s1)
    800054b0:	0007069b          	sext.w	a3,a4
    800054b4:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800054b8:	9701                	srai	a4,a4,0x20
    800054ba:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800054be:	6898                	ld	a4,16(s1)
    800054c0:	0007069b          	sext.w	a3,a4
    800054c4:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800054c8:	9701                	srai	a4,a4,0x20
    800054ca:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800054ce:	4685                	li	a3,1
    800054d0:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    800054d2:	4705                	li	a4,1
    800054d4:	00d48c23          	sb	a3,24(s1)
    800054d8:	00e48ca3          	sb	a4,25(s1)
    800054dc:	00e48d23          	sb	a4,26(s1)
    800054e0:	00e48da3          	sb	a4,27(s1)
    800054e4:	00e48e23          	sb	a4,28(s1)
    800054e8:	00e48ea3          	sb	a4,29(s1)
    800054ec:	00e48f23          	sb	a4,30(s1)
    800054f0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800054f4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800054f8:	0727a823          	sw	s2,112(a5)
}
    800054fc:	60e2                	ld	ra,24(sp)
    800054fe:	6442                	ld	s0,16(sp)
    80005500:	64a2                	ld	s1,8(sp)
    80005502:	6902                	ld	s2,0(sp)
    80005504:	6105                	addi	sp,sp,32
    80005506:	8082                	ret
    panic("could not find virtio disk");
    80005508:	00002517          	auipc	a0,0x2
    8000550c:	32050513          	addi	a0,a0,800 # 80007828 <syscalls+0x330>
    80005510:	a4cfb0ef          	jal	ra,8000075c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005514:	00002517          	auipc	a0,0x2
    80005518:	33450513          	addi	a0,a0,820 # 80007848 <syscalls+0x350>
    8000551c:	a40fb0ef          	jal	ra,8000075c <panic>
    panic("virtio disk should not be ready");
    80005520:	00002517          	auipc	a0,0x2
    80005524:	34850513          	addi	a0,a0,840 # 80007868 <syscalls+0x370>
    80005528:	a34fb0ef          	jal	ra,8000075c <panic>
    panic("virtio disk has no queue 0");
    8000552c:	00002517          	auipc	a0,0x2
    80005530:	35c50513          	addi	a0,a0,860 # 80007888 <syscalls+0x390>
    80005534:	a28fb0ef          	jal	ra,8000075c <panic>
    panic("virtio disk max queue too short");
    80005538:	00002517          	auipc	a0,0x2
    8000553c:	37050513          	addi	a0,a0,880 # 800078a8 <syscalls+0x3b0>
    80005540:	a1cfb0ef          	jal	ra,8000075c <panic>
    panic("virtio disk kalloc");
    80005544:	00002517          	auipc	a0,0x2
    80005548:	38450513          	addi	a0,a0,900 # 800078c8 <syscalls+0x3d0>
    8000554c:	a10fb0ef          	jal	ra,8000075c <panic>

0000000080005550 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005550:	7159                	addi	sp,sp,-112
    80005552:	f486                	sd	ra,104(sp)
    80005554:	f0a2                	sd	s0,96(sp)
    80005556:	eca6                	sd	s1,88(sp)
    80005558:	e8ca                	sd	s2,80(sp)
    8000555a:	e4ce                	sd	s3,72(sp)
    8000555c:	e0d2                	sd	s4,64(sp)
    8000555e:	fc56                	sd	s5,56(sp)
    80005560:	f85a                	sd	s6,48(sp)
    80005562:	f45e                	sd	s7,40(sp)
    80005564:	f062                	sd	s8,32(sp)
    80005566:	ec66                	sd	s9,24(sp)
    80005568:	e86a                	sd	s10,16(sp)
    8000556a:	1880                	addi	s0,sp,112
    8000556c:	892a                	mv	s2,a0
    8000556e:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005570:	00c52c83          	lw	s9,12(a0)
    80005574:	001c9c9b          	slliw	s9,s9,0x1
    80005578:	1c82                	slli	s9,s9,0x20
    8000557a:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000557e:	0001b517          	auipc	a0,0x1b
    80005582:	74a50513          	addi	a0,a0,1866 # 80020cc8 <disk+0x128>
    80005586:	e22fb0ef          	jal	ra,80000ba8 <acquire>
  for(int i = 0; i < 3; i++){
    8000558a:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000558c:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000558e:	0001bb17          	auipc	s6,0x1b
    80005592:	612b0b13          	addi	s6,s6,1554 # 80020ba0 <disk>
  for(int i = 0; i < 3; i++){
    80005596:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005598:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000559a:	0001bc17          	auipc	s8,0x1b
    8000559e:	72ec0c13          	addi	s8,s8,1838 # 80020cc8 <disk+0x128>
    800055a2:	a0b5                	j	8000560e <virtio_disk_rw+0xbe>
      disk.free[i] = 0;
    800055a4:	00fb06b3          	add	a3,s6,a5
    800055a8:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    800055ac:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    800055ae:	0207c563          	bltz	a5,800055d8 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    800055b2:	2485                	addiw	s1,s1,1
    800055b4:	0711                	addi	a4,a4,4
    800055b6:	1d548c63          	beq	s1,s5,8000578e <virtio_disk_rw+0x23e>
    idx[i] = alloc_desc();
    800055ba:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    800055bc:	0001b697          	auipc	a3,0x1b
    800055c0:	5e468693          	addi	a3,a3,1508 # 80020ba0 <disk>
    800055c4:	87d2                	mv	a5,s4
    if(disk.free[i]){
    800055c6:	0186c583          	lbu	a1,24(a3)
    800055ca:	fde9                	bnez	a1,800055a4 <virtio_disk_rw+0x54>
  for(int i = 0; i < NUM; i++){
    800055cc:	2785                	addiw	a5,a5,1
    800055ce:	0685                	addi	a3,a3,1
    800055d0:	ff779be3          	bne	a5,s7,800055c6 <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    800055d4:	57fd                	li	a5,-1
    800055d6:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800055d8:	02905463          	blez	s1,80005600 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    800055dc:	f9042503          	lw	a0,-112(s0)
    800055e0:	d3fff0ef          	jal	ra,8000531e <free_desc>
      for(int j = 0; j < i; j++)
    800055e4:	4785                	li	a5,1
    800055e6:	0097dd63          	bge	a5,s1,80005600 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    800055ea:	f9442503          	lw	a0,-108(s0)
    800055ee:	d31ff0ef          	jal	ra,8000531e <free_desc>
      for(int j = 0; j < i; j++)
    800055f2:	4789                	li	a5,2
    800055f4:	0097d663          	bge	a5,s1,80005600 <virtio_disk_rw+0xb0>
        free_desc(idx[j]);
    800055f8:	f9842503          	lw	a0,-104(s0)
    800055fc:	d23ff0ef          	jal	ra,8000531e <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005600:	85e2                	mv	a1,s8
    80005602:	0001b517          	auipc	a0,0x1b
    80005606:	5b650513          	addi	a0,a0,1462 # 80020bb8 <disk+0x18>
    8000560a:	8dbfc0ef          	jal	ra,80001ee4 <sleep>
  for(int i = 0; i < 3; i++){
    8000560e:	f9040713          	addi	a4,s0,-112
    80005612:	84ce                	mv	s1,s3
    80005614:	b75d                	j	800055ba <virtio_disk_rw+0x6a>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005616:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    8000561a:	00479693          	slli	a3,a5,0x4
    8000561e:	0001b797          	auipc	a5,0x1b
    80005622:	58278793          	addi	a5,a5,1410 # 80020ba0 <disk>
    80005626:	97b6                	add	a5,a5,a3
    80005628:	4685                	li	a3,1
    8000562a:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    8000562c:	0001b597          	auipc	a1,0x1b
    80005630:	57458593          	addi	a1,a1,1396 # 80020ba0 <disk>
    80005634:	00a60793          	addi	a5,a2,10
    80005638:	0792                	slli	a5,a5,0x4
    8000563a:	97ae                	add	a5,a5,a1
    8000563c:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    80005640:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005644:	f6070693          	addi	a3,a4,-160
    80005648:	619c                	ld	a5,0(a1)
    8000564a:	97b6                	add	a5,a5,a3
    8000564c:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000564e:	6188                	ld	a0,0(a1)
    80005650:	96aa                	add	a3,a3,a0
    80005652:	47c1                	li	a5,16
    80005654:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005656:	4785                	li	a5,1
    80005658:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    8000565c:	f9442783          	lw	a5,-108(s0)
    80005660:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005664:	0792                	slli	a5,a5,0x4
    80005666:	953e                	add	a0,a0,a5
    80005668:	05890693          	addi	a3,s2,88
    8000566c:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000566e:	6188                	ld	a0,0(a1)
    80005670:	97aa                	add	a5,a5,a0
    80005672:	40000693          	li	a3,1024
    80005676:	c794                	sw	a3,8(a5)
  if(write)
    80005678:	100d0763          	beqz	s10,80005786 <virtio_disk_rw+0x236>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    8000567c:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005680:	00c7d683          	lhu	a3,12(a5)
    80005684:	0016e693          	ori	a3,a3,1
    80005688:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    8000568c:	f9842583          	lw	a1,-104(s0)
    80005690:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005694:	0001b697          	auipc	a3,0x1b
    80005698:	50c68693          	addi	a3,a3,1292 # 80020ba0 <disk>
    8000569c:	00260793          	addi	a5,a2,2
    800056a0:	0792                	slli	a5,a5,0x4
    800056a2:	97b6                	add	a5,a5,a3
    800056a4:	587d                	li	a6,-1
    800056a6:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800056aa:	0592                	slli	a1,a1,0x4
    800056ac:	952e                	add	a0,a0,a1
    800056ae:	f9070713          	addi	a4,a4,-112
    800056b2:	9736                	add	a4,a4,a3
    800056b4:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    800056b6:	6298                	ld	a4,0(a3)
    800056b8:	972e                	add	a4,a4,a1
    800056ba:	4585                	li	a1,1
    800056bc:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800056be:	4509                	li	a0,2
    800056c0:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800056c4:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800056c8:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800056cc:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800056d0:	6698                	ld	a4,8(a3)
    800056d2:	00275783          	lhu	a5,2(a4)
    800056d6:	8b9d                	andi	a5,a5,7
    800056d8:	0786                	slli	a5,a5,0x1
    800056da:	97ba                	add	a5,a5,a4
    800056dc:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800056e0:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800056e4:	6698                	ld	a4,8(a3)
    800056e6:	00275783          	lhu	a5,2(a4)
    800056ea:	2785                	addiw	a5,a5,1
    800056ec:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800056f0:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800056f4:	100017b7          	lui	a5,0x10001
    800056f8:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800056fc:	00492703          	lw	a4,4(s2)
    80005700:	4785                	li	a5,1
    80005702:	00f71f63          	bne	a4,a5,80005720 <virtio_disk_rw+0x1d0>
    sleep(b, &disk.vdisk_lock);
    80005706:	0001b997          	auipc	s3,0x1b
    8000570a:	5c298993          	addi	s3,s3,1474 # 80020cc8 <disk+0x128>
  while(b->disk == 1) {
    8000570e:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005710:	85ce                	mv	a1,s3
    80005712:	854a                	mv	a0,s2
    80005714:	fd0fc0ef          	jal	ra,80001ee4 <sleep>
  while(b->disk == 1) {
    80005718:	00492783          	lw	a5,4(s2)
    8000571c:	fe978ae3          	beq	a5,s1,80005710 <virtio_disk_rw+0x1c0>
  }

  disk.info[idx[0]].b = 0;
    80005720:	f9042903          	lw	s2,-112(s0)
    80005724:	00290793          	addi	a5,s2,2
    80005728:	00479713          	slli	a4,a5,0x4
    8000572c:	0001b797          	auipc	a5,0x1b
    80005730:	47478793          	addi	a5,a5,1140 # 80020ba0 <disk>
    80005734:	97ba                	add	a5,a5,a4
    80005736:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000573a:	0001b997          	auipc	s3,0x1b
    8000573e:	46698993          	addi	s3,s3,1126 # 80020ba0 <disk>
    80005742:	00491713          	slli	a4,s2,0x4
    80005746:	0009b783          	ld	a5,0(s3)
    8000574a:	97ba                	add	a5,a5,a4
    8000574c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005750:	854a                	mv	a0,s2
    80005752:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005756:	bc9ff0ef          	jal	ra,8000531e <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000575a:	8885                	andi	s1,s1,1
    8000575c:	f0fd                	bnez	s1,80005742 <virtio_disk_rw+0x1f2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000575e:	0001b517          	auipc	a0,0x1b
    80005762:	56a50513          	addi	a0,a0,1386 # 80020cc8 <disk+0x128>
    80005766:	cdafb0ef          	jal	ra,80000c40 <release>
}
    8000576a:	70a6                	ld	ra,104(sp)
    8000576c:	7406                	ld	s0,96(sp)
    8000576e:	64e6                	ld	s1,88(sp)
    80005770:	6946                	ld	s2,80(sp)
    80005772:	69a6                	ld	s3,72(sp)
    80005774:	6a06                	ld	s4,64(sp)
    80005776:	7ae2                	ld	s5,56(sp)
    80005778:	7b42                	ld	s6,48(sp)
    8000577a:	7ba2                	ld	s7,40(sp)
    8000577c:	7c02                	ld	s8,32(sp)
    8000577e:	6ce2                	ld	s9,24(sp)
    80005780:	6d42                	ld	s10,16(sp)
    80005782:	6165                	addi	sp,sp,112
    80005784:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80005786:	4689                	li	a3,2
    80005788:	00d79623          	sh	a3,12(a5)
    8000578c:	bdd5                	j	80005680 <virtio_disk_rw+0x130>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000578e:	f9042603          	lw	a2,-112(s0)
    80005792:	00a60713          	addi	a4,a2,10
    80005796:	0712                	slli	a4,a4,0x4
    80005798:	0001b517          	auipc	a0,0x1b
    8000579c:	41050513          	addi	a0,a0,1040 # 80020ba8 <disk+0x8>
    800057a0:	953a                	add	a0,a0,a4
  if(write)
    800057a2:	e60d1ae3          	bnez	s10,80005616 <virtio_disk_rw+0xc6>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800057a6:	00a60793          	addi	a5,a2,10
    800057aa:	00479693          	slli	a3,a5,0x4
    800057ae:	0001b797          	auipc	a5,0x1b
    800057b2:	3f278793          	addi	a5,a5,1010 # 80020ba0 <disk>
    800057b6:	97b6                	add	a5,a5,a3
    800057b8:	0007a423          	sw	zero,8(a5)
    800057bc:	bd85                	j	8000562c <virtio_disk_rw+0xdc>

00000000800057be <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800057be:	1101                	addi	sp,sp,-32
    800057c0:	ec06                	sd	ra,24(sp)
    800057c2:	e822                	sd	s0,16(sp)
    800057c4:	e426                	sd	s1,8(sp)
    800057c6:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800057c8:	0001b497          	auipc	s1,0x1b
    800057cc:	3d848493          	addi	s1,s1,984 # 80020ba0 <disk>
    800057d0:	0001b517          	auipc	a0,0x1b
    800057d4:	4f850513          	addi	a0,a0,1272 # 80020cc8 <disk+0x128>
    800057d8:	bd0fb0ef          	jal	ra,80000ba8 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800057dc:	10001737          	lui	a4,0x10001
    800057e0:	533c                	lw	a5,96(a4)
    800057e2:	8b8d                	andi	a5,a5,3
    800057e4:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800057e6:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800057ea:	689c                	ld	a5,16(s1)
    800057ec:	0204d703          	lhu	a4,32(s1)
    800057f0:	0027d783          	lhu	a5,2(a5)
    800057f4:	04f70663          	beq	a4,a5,80005840 <virtio_disk_intr+0x82>
    __sync_synchronize();
    800057f8:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800057fc:	6898                	ld	a4,16(s1)
    800057fe:	0204d783          	lhu	a5,32(s1)
    80005802:	8b9d                	andi	a5,a5,7
    80005804:	078e                	slli	a5,a5,0x3
    80005806:	97ba                	add	a5,a5,a4
    80005808:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    8000580a:	00278713          	addi	a4,a5,2
    8000580e:	0712                	slli	a4,a4,0x4
    80005810:	9726                	add	a4,a4,s1
    80005812:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005816:	e321                	bnez	a4,80005856 <virtio_disk_intr+0x98>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005818:	0789                	addi	a5,a5,2
    8000581a:	0792                	slli	a5,a5,0x4
    8000581c:	97a6                	add	a5,a5,s1
    8000581e:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005820:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005824:	f0cfc0ef          	jal	ra,80001f30 <wakeup>

    disk.used_idx += 1;
    80005828:	0204d783          	lhu	a5,32(s1)
    8000582c:	2785                	addiw	a5,a5,1
    8000582e:	17c2                	slli	a5,a5,0x30
    80005830:	93c1                	srli	a5,a5,0x30
    80005832:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005836:	6898                	ld	a4,16(s1)
    80005838:	00275703          	lhu	a4,2(a4)
    8000583c:	faf71ee3          	bne	a4,a5,800057f8 <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    80005840:	0001b517          	auipc	a0,0x1b
    80005844:	48850513          	addi	a0,a0,1160 # 80020cc8 <disk+0x128>
    80005848:	bf8fb0ef          	jal	ra,80000c40 <release>
}
    8000584c:	60e2                	ld	ra,24(sp)
    8000584e:	6442                	ld	s0,16(sp)
    80005850:	64a2                	ld	s1,8(sp)
    80005852:	6105                	addi	sp,sp,32
    80005854:	8082                	ret
      panic("virtio_disk_intr status");
    80005856:	00002517          	auipc	a0,0x2
    8000585a:	08a50513          	addi	a0,a0,138 # 800078e0 <syscalls+0x3e8>
    8000585e:	efffa0ef          	jal	ra,8000075c <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
