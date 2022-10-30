
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba 60 39 2a 00       	mov    $0x2a3960,%edx
  100041:	b8 36 9a 11 00       	mov    $0x119a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  10005d:	e8 fa 64 00 00       	call   10655c <memset>

    cons_init();                // init the console
  100062:	e8 79 15 00 00       	call   1015e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 60 6d 10 00 	movl   $0x106d60,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 7c 6d 10 00 	movl   $0x106d7c,(%esp)
  10007c:	e8 16 02 00 00       	call   100297 <cprintf>

    print_kerninfo();
  100081:	e8 b7 08 00 00       	call   10093d <print_kerninfo>

    grade_backtrace();
  100086:	e8 8e 00 00 00       	call   100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 a4 30 00 00       	call   103134 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 af 16 00 00       	call   101744 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 2d 18 00 00       	call   1018c7 <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 f4 0c 00 00       	call   100d93 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 d3 17 00 00       	call   101877 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  1000a4:	e8 60 01 00 00       	call   100209 <lab1_switch_test>

    /* do nothing */
    while (1);
  1000a9:	eb fe                	jmp    1000a9 <kern_init+0x73>

001000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000ab:	55                   	push   %ebp
  1000ac:	89 e5                	mov    %esp,%ebp
  1000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b8:	00 
  1000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000c0:	00 
  1000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c8:	e8 b4 0c 00 00       	call   100d81 <mon_backtrace>
}
  1000cd:	90                   	nop
  1000ce:	c9                   	leave  
  1000cf:	c3                   	ret    

001000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000d0:	55                   	push   %ebp
  1000d1:	89 e5                	mov    %esp,%ebp
  1000d3:	53                   	push   %ebx
  1000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000da:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000e0:	8b 45 08             	mov    0x8(%ebp),%eax
  1000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ef:	89 04 24             	mov    %eax,(%esp)
  1000f2:	e8 b4 ff ff ff       	call   1000ab <grade_backtrace2>
}
  1000f7:	90                   	nop
  1000f8:	83 c4 14             	add    $0x14,%esp
  1000fb:	5b                   	pop    %ebx
  1000fc:	5d                   	pop    %ebp
  1000fd:	c3                   	ret    

001000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fe:	55                   	push   %ebp
  1000ff:	89 e5                	mov    %esp,%ebp
  100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100104:	8b 45 10             	mov    0x10(%ebp),%eax
  100107:	89 44 24 04          	mov    %eax,0x4(%esp)
  10010b:	8b 45 08             	mov    0x8(%ebp),%eax
  10010e:	89 04 24             	mov    %eax,(%esp)
  100111:	e8 ba ff ff ff       	call   1000d0 <grade_backtrace1>
}
  100116:	90                   	nop
  100117:	c9                   	leave  
  100118:	c3                   	ret    

00100119 <grade_backtrace>:

void
grade_backtrace(void) {
  100119:	55                   	push   %ebp
  10011a:	89 e5                	mov    %esp,%ebp
  10011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011f:	b8 36 00 10 00       	mov    $0x100036,%eax
  100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  10012b:	ff 
  10012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100137:	e8 c2 ff ff ff       	call   1000fe <grade_backtrace0>
}
  10013c:	90                   	nop
  10013d:	c9                   	leave  
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 81 6d 10 00 	movl   $0x106d81,(%esp)
  10016e:	e8 24 01 00 00       	call   100297 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 8f 6d 10 00 	movl   $0x106d8f,(%esp)
  10018d:	e8 05 01 00 00       	call   100297 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 9d 6d 10 00 	movl   $0x106d9d,(%esp)
  1001ac:	e8 e6 00 00 00       	call   100297 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 ab 6d 10 00 	movl   $0x106dab,(%esp)
  1001cb:	e8 c7 00 00 00       	call   100297 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 b9 6d 10 00 	movl   $0x106db9,(%esp)
  1001ea:	e8 a8 00 00 00       	call   100297 <cprintf>
    round ++;
  1001ef:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  1001fa:	90                   	nop
  1001fb:	c9                   	leave  
  1001fc:	c3                   	ret    

001001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001fd:	55                   	push   %ebp
  1001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100200:	90                   	nop
  100201:	5d                   	pop    %ebp
  100202:	c3                   	ret    

00100203 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100203:	55                   	push   %ebp
  100204:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100206:	90                   	nop
  100207:	5d                   	pop    %ebp
  100208:	c3                   	ret    

00100209 <lab1_switch_test>:

static void
lab1_switch_test(void) {
  100209:	55                   	push   %ebp
  10020a:	89 e5                	mov    %esp,%ebp
  10020c:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  10020f:	e8 2b ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100214:	c7 04 24 c8 6d 10 00 	movl   $0x106dc8,(%esp)
  10021b:	e8 77 00 00 00       	call   100297 <cprintf>
    lab1_switch_to_user();
  100220:	e8 d8 ff ff ff       	call   1001fd <lab1_switch_to_user>
    lab1_print_cur_status();
  100225:	e8 15 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022a:	c7 04 24 e8 6d 10 00 	movl   $0x106de8,(%esp)
  100231:	e8 61 00 00 00       	call   100297 <cprintf>
    lab1_switch_to_kernel();
  100236:	e8 c8 ff ff ff       	call   100203 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023b:	e8 ff fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100240:	90                   	nop
  100241:	c9                   	leave  
  100242:	c3                   	ret    

00100243 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100243:	55                   	push   %ebp
  100244:	89 e5                	mov    %esp,%ebp
  100246:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100249:	8b 45 08             	mov    0x8(%ebp),%eax
  10024c:	89 04 24             	mov    %eax,(%esp)
  10024f:	e8 b9 13 00 00       	call   10160d <cons_putc>
    (*cnt) ++;
  100254:	8b 45 0c             	mov    0xc(%ebp),%eax
  100257:	8b 00                	mov    (%eax),%eax
  100259:	8d 50 01             	lea    0x1(%eax),%edx
  10025c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025f:	89 10                	mov    %edx,(%eax)
}
  100261:	90                   	nop
  100262:	c9                   	leave  
  100263:	c3                   	ret    

00100264 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100264:	55                   	push   %ebp
  100265:	89 e5                	mov    %esp,%ebp
  100267:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10026a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100271:	8b 45 0c             	mov    0xc(%ebp),%eax
  100274:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100278:	8b 45 08             	mov    0x8(%ebp),%eax
  10027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10027f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100282:	89 44 24 04          	mov    %eax,0x4(%esp)
  100286:	c7 04 24 43 02 10 00 	movl   $0x100243,(%esp)
  10028d:	e8 1d 66 00 00       	call   1068af <vprintfmt>
    return cnt;
  100292:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100295:	c9                   	leave  
  100296:	c3                   	ret    

00100297 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100297:	55                   	push   %ebp
  100298:	89 e5                	mov    %esp,%ebp
  10029a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10029d:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1002ad:	89 04 24             	mov    %eax,(%esp)
  1002b0:	e8 af ff ff ff       	call   100264 <vcprintf>
  1002b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002bb:	c9                   	leave  
  1002bc:	c3                   	ret    

001002bd <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002bd:	55                   	push   %ebp
  1002be:	89 e5                	mov    %esp,%ebp
  1002c0:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  1002c6:	89 04 24             	mov    %eax,(%esp)
  1002c9:	e8 3f 13 00 00       	call   10160d <cons_putc>
}
  1002ce:	90                   	nop
  1002cf:	c9                   	leave  
  1002d0:	c3                   	ret    

001002d1 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002d1:	55                   	push   %ebp
  1002d2:	89 e5                	mov    %esp,%ebp
  1002d4:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002de:	eb 13                	jmp    1002f3 <cputs+0x22>
        cputch(c, &cnt);
  1002e0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002e4:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002e7:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002eb:	89 04 24             	mov    %eax,(%esp)
  1002ee:	e8 50 ff ff ff       	call   100243 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1002f6:	8d 50 01             	lea    0x1(%eax),%edx
  1002f9:	89 55 08             	mov    %edx,0x8(%ebp)
  1002fc:	0f b6 00             	movzbl (%eax),%eax
  1002ff:	88 45 f7             	mov    %al,-0x9(%ebp)
  100302:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  100306:	75 d8                	jne    1002e0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  100308:	8d 45 f0             	lea    -0x10(%ebp),%eax
  10030b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10030f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  100316:	e8 28 ff ff ff       	call   100243 <cputch>
    return cnt;
  10031b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10031e:	c9                   	leave  
  10031f:	c3                   	ret    

00100320 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  100320:	55                   	push   %ebp
  100321:	89 e5                	mov    %esp,%ebp
  100323:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  100326:	e8 1f 13 00 00       	call   10164a <cons_getc>
  10032b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10032e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100332:	74 f2                	je     100326 <getchar+0x6>
        /* do nothing */;
    return c;
  100334:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100337:	c9                   	leave  
  100338:	c3                   	ret    

00100339 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100339:	55                   	push   %ebp
  10033a:	89 e5                	mov    %esp,%ebp
  10033c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10033f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100343:	74 13                	je     100358 <readline+0x1f>
        cprintf("%s", prompt);
  100345:	8b 45 08             	mov    0x8(%ebp),%eax
  100348:	89 44 24 04          	mov    %eax,0x4(%esp)
  10034c:	c7 04 24 07 6e 10 00 	movl   $0x106e07,(%esp)
  100353:	e8 3f ff ff ff       	call   100297 <cprintf>
    }
    int i = 0, c;
  100358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10035f:	e8 bc ff ff ff       	call   100320 <getchar>
  100364:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10036b:	79 07                	jns    100374 <readline+0x3b>
            return NULL;
  10036d:	b8 00 00 00 00       	mov    $0x0,%eax
  100372:	eb 78                	jmp    1003ec <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100374:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100378:	7e 28                	jle    1003a2 <readline+0x69>
  10037a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100381:	7f 1f                	jg     1003a2 <readline+0x69>
            cputchar(c);
  100383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100386:	89 04 24             	mov    %eax,(%esp)
  100389:	e8 2f ff ff ff       	call   1002bd <cputchar>
            buf[i ++] = c;
  10038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100391:	8d 50 01             	lea    0x1(%eax),%edx
  100394:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100397:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10039a:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1003a0:	eb 45                	jmp    1003e7 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1003a2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003a6:	75 16                	jne    1003be <readline+0x85>
  1003a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003ac:	7e 10                	jle    1003be <readline+0x85>
            cputchar(c);
  1003ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003b1:	89 04 24             	mov    %eax,(%esp)
  1003b4:	e8 04 ff ff ff       	call   1002bd <cputchar>
            i --;
  1003b9:	ff 4d f4             	decl   -0xc(%ebp)
  1003bc:	eb 29                	jmp    1003e7 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003be:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003c2:	74 06                	je     1003ca <readline+0x91>
  1003c4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003c8:	75 95                	jne    10035f <readline+0x26>
            cputchar(c);
  1003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003cd:	89 04 24             	mov    %eax,(%esp)
  1003d0:	e8 e8 fe ff ff       	call   1002bd <cputchar>
            buf[i] = '\0';
  1003d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003d8:	05 20 c0 11 00       	add    $0x11c020,%eax
  1003dd:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003e0:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  1003e5:	eb 05                	jmp    1003ec <readline+0xb3>
        }
    }
  1003e7:	e9 73 ff ff ff       	jmp    10035f <readline+0x26>
}
  1003ec:	c9                   	leave  
  1003ed:	c3                   	ret    

001003ee <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003ee:	55                   	push   %ebp
  1003ef:	89 e5                	mov    %esp,%ebp
  1003f1:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003f4:	a1 20 c4 11 00       	mov    0x11c420,%eax
  1003f9:	85 c0                	test   %eax,%eax
  1003fb:	75 5b                	jne    100458 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003fd:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100404:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100407:	8d 45 14             	lea    0x14(%ebp),%eax
  10040a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  10040d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100410:	89 44 24 08          	mov    %eax,0x8(%esp)
  100414:	8b 45 08             	mov    0x8(%ebp),%eax
  100417:	89 44 24 04          	mov    %eax,0x4(%esp)
  10041b:	c7 04 24 0a 6e 10 00 	movl   $0x106e0a,(%esp)
  100422:	e8 70 fe ff ff       	call   100297 <cprintf>
    vcprintf(fmt, ap);
  100427:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10042a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10042e:	8b 45 10             	mov    0x10(%ebp),%eax
  100431:	89 04 24             	mov    %eax,(%esp)
  100434:	e8 2b fe ff ff       	call   100264 <vcprintf>
    cprintf("\n");
  100439:	c7 04 24 26 6e 10 00 	movl   $0x106e26,(%esp)
  100440:	e8 52 fe ff ff       	call   100297 <cprintf>
    
    cprintf("stack trackback:\n");
  100445:	c7 04 24 28 6e 10 00 	movl   $0x106e28,(%esp)
  10044c:	e8 46 fe ff ff       	call   100297 <cprintf>
    print_stackframe();
  100451:	e8 32 06 00 00       	call   100a88 <print_stackframe>
  100456:	eb 01                	jmp    100459 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  100458:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  100459:	e8 20 14 00 00       	call   10187e <intr_disable>
    while (1) {
        kmonitor(NULL);
  10045e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100465:	e8 4a 08 00 00       	call   100cb4 <kmonitor>
    }
  10046a:	eb f2                	jmp    10045e <__panic+0x70>

0010046c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  10046c:	55                   	push   %ebp
  10046d:	89 e5                	mov    %esp,%ebp
  10046f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100472:	8d 45 14             	lea    0x14(%ebp),%eax
  100475:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100478:	8b 45 0c             	mov    0xc(%ebp),%eax
  10047b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10047f:	8b 45 08             	mov    0x8(%ebp),%eax
  100482:	89 44 24 04          	mov    %eax,0x4(%esp)
  100486:	c7 04 24 3a 6e 10 00 	movl   $0x106e3a,(%esp)
  10048d:	e8 05 fe ff ff       	call   100297 <cprintf>
    vcprintf(fmt, ap);
  100492:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100495:	89 44 24 04          	mov    %eax,0x4(%esp)
  100499:	8b 45 10             	mov    0x10(%ebp),%eax
  10049c:	89 04 24             	mov    %eax,(%esp)
  10049f:	e8 c0 fd ff ff       	call   100264 <vcprintf>
    cprintf("\n");
  1004a4:	c7 04 24 26 6e 10 00 	movl   $0x106e26,(%esp)
  1004ab:	e8 e7 fd ff ff       	call   100297 <cprintf>
    va_end(ap);
}
  1004b0:	90                   	nop
  1004b1:	c9                   	leave  
  1004b2:	c3                   	ret    

001004b3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004b3:	55                   	push   %ebp
  1004b4:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004b6:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  1004bb:	5d                   	pop    %ebp
  1004bc:	c3                   	ret    

001004bd <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004bd:	55                   	push   %ebp
  1004be:	89 e5                	mov    %esp,%ebp
  1004c0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004c6:	8b 00                	mov    (%eax),%eax
  1004c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004cb:	8b 45 10             	mov    0x10(%ebp),%eax
  1004ce:	8b 00                	mov    (%eax),%eax
  1004d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004da:	e9 ca 00 00 00       	jmp    1005a9 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004df:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004e5:	01 d0                	add    %edx,%eax
  1004e7:	89 c2                	mov    %eax,%edx
  1004e9:	c1 ea 1f             	shr    $0x1f,%edx
  1004ec:	01 d0                	add    %edx,%eax
  1004ee:	d1 f8                	sar    %eax
  1004f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004f9:	eb 03                	jmp    1004fe <stab_binsearch+0x41>
            m --;
  1004fb:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100501:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100504:	7c 1f                	jl     100525 <stab_binsearch+0x68>
  100506:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100509:	89 d0                	mov    %edx,%eax
  10050b:	01 c0                	add    %eax,%eax
  10050d:	01 d0                	add    %edx,%eax
  10050f:	c1 e0 02             	shl    $0x2,%eax
  100512:	89 c2                	mov    %eax,%edx
  100514:	8b 45 08             	mov    0x8(%ebp),%eax
  100517:	01 d0                	add    %edx,%eax
  100519:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10051d:	0f b6 c0             	movzbl %al,%eax
  100520:	3b 45 14             	cmp    0x14(%ebp),%eax
  100523:	75 d6                	jne    1004fb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  100525:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100528:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10052b:	7d 09                	jge    100536 <stab_binsearch+0x79>
            l = true_m + 1;
  10052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100530:	40                   	inc    %eax
  100531:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100534:	eb 73                	jmp    1005a9 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  100536:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  10053d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100540:	89 d0                	mov    %edx,%eax
  100542:	01 c0                	add    %eax,%eax
  100544:	01 d0                	add    %edx,%eax
  100546:	c1 e0 02             	shl    $0x2,%eax
  100549:	89 c2                	mov    %eax,%edx
  10054b:	8b 45 08             	mov    0x8(%ebp),%eax
  10054e:	01 d0                	add    %edx,%eax
  100550:	8b 40 08             	mov    0x8(%eax),%eax
  100553:	3b 45 18             	cmp    0x18(%ebp),%eax
  100556:	73 11                	jae    100569 <stab_binsearch+0xac>
            *region_left = m;
  100558:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10055e:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100560:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100563:	40                   	inc    %eax
  100564:	89 45 fc             	mov    %eax,-0x4(%ebp)
  100567:	eb 40                	jmp    1005a9 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  100569:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10056c:	89 d0                	mov    %edx,%eax
  10056e:	01 c0                	add    %eax,%eax
  100570:	01 d0                	add    %edx,%eax
  100572:	c1 e0 02             	shl    $0x2,%eax
  100575:	89 c2                	mov    %eax,%edx
  100577:	8b 45 08             	mov    0x8(%ebp),%eax
  10057a:	01 d0                	add    %edx,%eax
  10057c:	8b 40 08             	mov    0x8(%eax),%eax
  10057f:	3b 45 18             	cmp    0x18(%ebp),%eax
  100582:	76 14                	jbe    100598 <stab_binsearch+0xdb>
            *region_right = m - 1;
  100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100587:	8d 50 ff             	lea    -0x1(%eax),%edx
  10058a:	8b 45 10             	mov    0x10(%ebp),%eax
  10058d:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  10058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100592:	48                   	dec    %eax
  100593:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100596:	eb 11                	jmp    1005a9 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  100598:	8b 45 0c             	mov    0xc(%ebp),%eax
  10059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10059e:	89 10                	mov    %edx,(%eax)
            l = m;
  1005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005a6:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1005a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005af:	0f 8e 2a ff ff ff    	jle    1004df <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1005b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005b9:	75 0f                	jne    1005ca <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005be:	8b 00                	mov    (%eax),%eax
  1005c0:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005c3:	8b 45 10             	mov    0x10(%ebp),%eax
  1005c6:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005c8:	eb 3e                	jmp    100608 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005ca:	8b 45 10             	mov    0x10(%ebp),%eax
  1005cd:	8b 00                	mov    (%eax),%eax
  1005cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005d2:	eb 03                	jmp    1005d7 <stab_binsearch+0x11a>
  1005d4:	ff 4d fc             	decl   -0x4(%ebp)
  1005d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005da:	8b 00                	mov    (%eax),%eax
  1005dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005df:	7d 1f                	jge    100600 <stab_binsearch+0x143>
  1005e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005e4:	89 d0                	mov    %edx,%eax
  1005e6:	01 c0                	add    %eax,%eax
  1005e8:	01 d0                	add    %edx,%eax
  1005ea:	c1 e0 02             	shl    $0x2,%eax
  1005ed:	89 c2                	mov    %eax,%edx
  1005ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f2:	01 d0                	add    %edx,%eax
  1005f4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005f8:	0f b6 c0             	movzbl %al,%eax
  1005fb:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005fe:	75 d4                	jne    1005d4 <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  100600:	8b 45 0c             	mov    0xc(%ebp),%eax
  100603:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100606:	89 10                	mov    %edx,(%eax)
    }
}
  100608:	90                   	nop
  100609:	c9                   	leave  
  10060a:	c3                   	ret    

0010060b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  10060b:	55                   	push   %ebp
  10060c:	89 e5                	mov    %esp,%ebp
  10060e:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100611:	8b 45 0c             	mov    0xc(%ebp),%eax
  100614:	c7 00 58 6e 10 00    	movl   $0x106e58,(%eax)
    info->eip_line = 0;
  10061a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  100624:	8b 45 0c             	mov    0xc(%ebp),%eax
  100627:	c7 40 08 58 6e 10 00 	movl   $0x106e58,0x8(%eax)
    info->eip_fn_namelen = 9;
  10062e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100631:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  100638:	8b 45 0c             	mov    0xc(%ebp),%eax
  10063b:	8b 55 08             	mov    0x8(%ebp),%edx
  10063e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100641:	8b 45 0c             	mov    0xc(%ebp),%eax
  100644:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  10064b:	c7 45 f4 54 82 10 00 	movl   $0x108254,-0xc(%ebp)
    stab_end = __STAB_END__;
  100652:	c7 45 f0 dc 41 11 00 	movl   $0x1141dc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  100659:	c7 45 ec dd 41 11 00 	movl   $0x1141dd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100660:	c7 45 e8 0d 6f 11 00 	movl   $0x116f0d,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  100667:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10066a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10066d:	76 0b                	jbe    10067a <debuginfo_eip+0x6f>
  10066f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100672:	48                   	dec    %eax
  100673:	0f b6 00             	movzbl (%eax),%eax
  100676:	84 c0                	test   %al,%al
  100678:	74 0a                	je     100684 <debuginfo_eip+0x79>
        return -1;
  10067a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10067f:	e9 b7 02 00 00       	jmp    10093b <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100684:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  10068b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100691:	29 c2                	sub    %eax,%edx
  100693:	89 d0                	mov    %edx,%eax
  100695:	c1 f8 02             	sar    $0x2,%eax
  100698:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  10069e:	48                   	dec    %eax
  10069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1006a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006a9:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006b0:	00 
  1006b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006c2:	89 04 24             	mov    %eax,(%esp)
  1006c5:	e8 f3 fd ff ff       	call   1004bd <stab_binsearch>
    if (lfile == 0)
  1006ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006cd:	85 c0                	test   %eax,%eax
  1006cf:	75 0a                	jne    1006db <debuginfo_eip+0xd0>
        return -1;
  1006d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006d6:	e9 60 02 00 00       	jmp    10093b <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006de:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006e7:	8b 45 08             	mov    0x8(%ebp),%eax
  1006ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006ee:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006f5:	00 
  1006f6:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100700:	89 44 24 04          	mov    %eax,0x4(%esp)
  100704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100707:	89 04 24             	mov    %eax,(%esp)
  10070a:	e8 ae fd ff ff       	call   1004bd <stab_binsearch>

    if (lfun <= rfun) {
  10070f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100712:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100715:	39 c2                	cmp    %eax,%edx
  100717:	7f 7c                	jg     100795 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  100719:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10071c:	89 c2                	mov    %eax,%edx
  10071e:	89 d0                	mov    %edx,%eax
  100720:	01 c0                	add    %eax,%eax
  100722:	01 d0                	add    %edx,%eax
  100724:	c1 e0 02             	shl    $0x2,%eax
  100727:	89 c2                	mov    %eax,%edx
  100729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072c:	01 d0                	add    %edx,%eax
  10072e:	8b 00                	mov    (%eax),%eax
  100730:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100733:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100736:	29 d1                	sub    %edx,%ecx
  100738:	89 ca                	mov    %ecx,%edx
  10073a:	39 d0                	cmp    %edx,%eax
  10073c:	73 22                	jae    100760 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100741:	89 c2                	mov    %eax,%edx
  100743:	89 d0                	mov    %edx,%eax
  100745:	01 c0                	add    %eax,%eax
  100747:	01 d0                	add    %edx,%eax
  100749:	c1 e0 02             	shl    $0x2,%eax
  10074c:	89 c2                	mov    %eax,%edx
  10074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100751:	01 d0                	add    %edx,%eax
  100753:	8b 10                	mov    (%eax),%edx
  100755:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100758:	01 c2                	add    %eax,%edx
  10075a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075d:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100760:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100763:	89 c2                	mov    %eax,%edx
  100765:	89 d0                	mov    %edx,%eax
  100767:	01 c0                	add    %eax,%eax
  100769:	01 d0                	add    %edx,%eax
  10076b:	c1 e0 02             	shl    $0x2,%eax
  10076e:	89 c2                	mov    %eax,%edx
  100770:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100773:	01 d0                	add    %edx,%eax
  100775:	8b 50 08             	mov    0x8(%eax),%edx
  100778:	8b 45 0c             	mov    0xc(%ebp),%eax
  10077b:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  10077e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100781:	8b 40 10             	mov    0x10(%eax),%eax
  100784:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  100787:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10078a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  10078d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100790:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100793:	eb 15                	jmp    1007aa <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  100795:	8b 45 0c             	mov    0xc(%ebp),%eax
  100798:	8b 55 08             	mov    0x8(%ebp),%edx
  10079b:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  10079e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007ad:	8b 40 08             	mov    0x8(%eax),%eax
  1007b0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007b7:	00 
  1007b8:	89 04 24             	mov    %eax,(%esp)
  1007bb:	e8 18 5c 00 00       	call   1063d8 <strfind>
  1007c0:	89 c2                	mov    %eax,%edx
  1007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007c5:	8b 40 08             	mov    0x8(%eax),%eax
  1007c8:	29 c2                	sub    %eax,%edx
  1007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007cd:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1007d3:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007d7:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007de:	00 
  1007df:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007e6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f0:	89 04 24             	mov    %eax,(%esp)
  1007f3:	e8 c5 fc ff ff       	call   1004bd <stab_binsearch>
    if (lline <= rline) {
  1007f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007fe:	39 c2                	cmp    %eax,%edx
  100800:	7f 23                	jg     100825 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  100802:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100805:	89 c2                	mov    %eax,%edx
  100807:	89 d0                	mov    %edx,%eax
  100809:	01 c0                	add    %eax,%eax
  10080b:	01 d0                	add    %edx,%eax
  10080d:	c1 e0 02             	shl    $0x2,%eax
  100810:	89 c2                	mov    %eax,%edx
  100812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100815:	01 d0                	add    %edx,%eax
  100817:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  10081b:	89 c2                	mov    %eax,%edx
  10081d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100820:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100823:	eb 11                	jmp    100836 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  100825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10082a:	e9 0c 01 00 00       	jmp    10093b <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10082f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100832:	48                   	dec    %eax
  100833:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100836:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10083c:	39 c2                	cmp    %eax,%edx
  10083e:	7c 56                	jl     100896 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100840:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100843:	89 c2                	mov    %eax,%edx
  100845:	89 d0                	mov    %edx,%eax
  100847:	01 c0                	add    %eax,%eax
  100849:	01 d0                	add    %edx,%eax
  10084b:	c1 e0 02             	shl    $0x2,%eax
  10084e:	89 c2                	mov    %eax,%edx
  100850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100853:	01 d0                	add    %edx,%eax
  100855:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100859:	3c 84                	cmp    $0x84,%al
  10085b:	74 39                	je     100896 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10085d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100860:	89 c2                	mov    %eax,%edx
  100862:	89 d0                	mov    %edx,%eax
  100864:	01 c0                	add    %eax,%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	c1 e0 02             	shl    $0x2,%eax
  10086b:	89 c2                	mov    %eax,%edx
  10086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100870:	01 d0                	add    %edx,%eax
  100872:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100876:	3c 64                	cmp    $0x64,%al
  100878:	75 b5                	jne    10082f <debuginfo_eip+0x224>
  10087a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10087d:	89 c2                	mov    %eax,%edx
  10087f:	89 d0                	mov    %edx,%eax
  100881:	01 c0                	add    %eax,%eax
  100883:	01 d0                	add    %edx,%eax
  100885:	c1 e0 02             	shl    $0x2,%eax
  100888:	89 c2                	mov    %eax,%edx
  10088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10088d:	01 d0                	add    %edx,%eax
  10088f:	8b 40 08             	mov    0x8(%eax),%eax
  100892:	85 c0                	test   %eax,%eax
  100894:	74 99                	je     10082f <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  100896:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100899:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10089c:	39 c2                	cmp    %eax,%edx
  10089e:	7c 46                	jl     1008e6 <debuginfo_eip+0x2db>
  1008a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008a3:	89 c2                	mov    %eax,%edx
  1008a5:	89 d0                	mov    %edx,%eax
  1008a7:	01 c0                	add    %eax,%eax
  1008a9:	01 d0                	add    %edx,%eax
  1008ab:	c1 e0 02             	shl    $0x2,%eax
  1008ae:	89 c2                	mov    %eax,%edx
  1008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008b3:	01 d0                	add    %edx,%eax
  1008b5:	8b 00                	mov    (%eax),%eax
  1008b7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008bd:	29 d1                	sub    %edx,%ecx
  1008bf:	89 ca                	mov    %ecx,%edx
  1008c1:	39 d0                	cmp    %edx,%eax
  1008c3:	73 21                	jae    1008e6 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008c8:	89 c2                	mov    %eax,%edx
  1008ca:	89 d0                	mov    %edx,%eax
  1008cc:	01 c0                	add    %eax,%eax
  1008ce:	01 d0                	add    %edx,%eax
  1008d0:	c1 e0 02             	shl    $0x2,%eax
  1008d3:	89 c2                	mov    %eax,%edx
  1008d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008d8:	01 d0                	add    %edx,%eax
  1008da:	8b 10                	mov    (%eax),%edx
  1008dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008df:	01 c2                	add    %eax,%edx
  1008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008e4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008ec:	39 c2                	cmp    %eax,%edx
  1008ee:	7d 46                	jge    100936 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008f3:	40                   	inc    %eax
  1008f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008f7:	eb 16                	jmp    10090f <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008fc:	8b 40 14             	mov    0x14(%eax),%eax
  1008ff:	8d 50 01             	lea    0x1(%eax),%edx
  100902:	8b 45 0c             	mov    0xc(%ebp),%eax
  100905:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  100908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10090b:	40                   	inc    %eax
  10090c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10090f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100912:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  100915:	39 c2                	cmp    %eax,%edx
  100917:	7d 1d                	jge    100936 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100919:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10091c:	89 c2                	mov    %eax,%edx
  10091e:	89 d0                	mov    %edx,%eax
  100920:	01 c0                	add    %eax,%eax
  100922:	01 d0                	add    %edx,%eax
  100924:	c1 e0 02             	shl    $0x2,%eax
  100927:	89 c2                	mov    %eax,%edx
  100929:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10092c:	01 d0                	add    %edx,%eax
  10092e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100932:	3c a0                	cmp    $0xa0,%al
  100934:	74 c3                	je     1008f9 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  100936:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10093b:	c9                   	leave  
  10093c:	c3                   	ret    

0010093d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  10093d:	55                   	push   %ebp
  10093e:	89 e5                	mov    %esp,%ebp
  100940:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100943:	c7 04 24 62 6e 10 00 	movl   $0x106e62,(%esp)
  10094a:	e8 48 f9 ff ff       	call   100297 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10094f:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100956:	00 
  100957:	c7 04 24 7b 6e 10 00 	movl   $0x106e7b,(%esp)
  10095e:	e8 34 f9 ff ff       	call   100297 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100963:	c7 44 24 04 56 6d 10 	movl   $0x106d56,0x4(%esp)
  10096a:	00 
  10096b:	c7 04 24 93 6e 10 00 	movl   $0x106e93,(%esp)
  100972:	e8 20 f9 ff ff       	call   100297 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  100977:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  10097e:	00 
  10097f:	c7 04 24 ab 6e 10 00 	movl   $0x106eab,(%esp)
  100986:	e8 0c f9 ff ff       	call   100297 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  10098b:	c7 44 24 04 60 39 2a 	movl   $0x2a3960,0x4(%esp)
  100992:	00 
  100993:	c7 04 24 c3 6e 10 00 	movl   $0x106ec3,(%esp)
  10099a:	e8 f8 f8 ff ff       	call   100297 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  10099f:	b8 60 39 2a 00       	mov    $0x2a3960,%eax
  1009a4:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009aa:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009af:	29 c2                	sub    %eax,%edx
  1009b1:	89 d0                	mov    %edx,%eax
  1009b3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b9:	85 c0                	test   %eax,%eax
  1009bb:	0f 48 c2             	cmovs  %edx,%eax
  1009be:	c1 f8 0a             	sar    $0xa,%eax
  1009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009c5:	c7 04 24 dc 6e 10 00 	movl   $0x106edc,(%esp)
  1009cc:	e8 c6 f8 ff ff       	call   100297 <cprintf>
}
  1009d1:	90                   	nop
  1009d2:	c9                   	leave  
  1009d3:	c3                   	ret    

001009d4 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009d4:	55                   	push   %ebp
  1009d5:	89 e5                	mov    %esp,%ebp
  1009d7:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1009e7:	89 04 24             	mov    %eax,(%esp)
  1009ea:	e8 1c fc ff ff       	call   10060b <debuginfo_eip>
  1009ef:	85 c0                	test   %eax,%eax
  1009f1:	74 15                	je     100a08 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fa:	c7 04 24 06 6f 10 00 	movl   $0x106f06,(%esp)
  100a01:	e8 91 f8 ff ff       	call   100297 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a06:	eb 6c                	jmp    100a74 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a0f:	eb 1b                	jmp    100a2c <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a17:	01 d0                	add    %edx,%eax
  100a19:	0f b6 00             	movzbl (%eax),%eax
  100a1c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a25:	01 ca                	add    %ecx,%edx
  100a27:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a29:	ff 45 f4             	incl   -0xc(%ebp)
  100a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a32:	7f dd                	jg     100a11 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a34:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a3d:	01 d0                	add    %edx,%eax
  100a3f:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a45:	8b 55 08             	mov    0x8(%ebp),%edx
  100a48:	89 d1                	mov    %edx,%ecx
  100a4a:	29 c1                	sub    %eax,%ecx
  100a4c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a52:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a56:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a5c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a60:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a64:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a68:	c7 04 24 22 6f 10 00 	movl   $0x106f22,(%esp)
  100a6f:	e8 23 f8 ff ff       	call   100297 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a74:	90                   	nop
  100a75:	c9                   	leave  
  100a76:	c3                   	ret    

00100a77 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a77:	55                   	push   %ebp
  100a78:	89 e5                	mov    %esp,%ebp
  100a7a:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a7d:	8b 45 04             	mov    0x4(%ebp),%eax
  100a80:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a83:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a86:	c9                   	leave  
  100a87:	c3                   	ret    

00100a88 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a88:	55                   	push   %ebp
  100a89:	89 e5                	mov    %esp,%ebp
  100a8b:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a8e:	89 e8                	mov    %ebp,%eax
  100a90:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
  100a93:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
  100a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100a99:	e8 d9 ff ff ff       	call   100a77 <read_eip>
  100a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100aa1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aa8:	e9 84 00 00 00       	jmp    100b31 <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
  100aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
  100ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100abb:	c7 04 24 34 6f 10 00 	movl   $0x106f34,(%esp)
  100ac2:	e8 d0 f7 ff ff       	call   100297 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
  100ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aca:	83 c0 08             	add    $0x8,%eax
  100acd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
  100ad0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  100ad7:	eb 24                	jmp    100afd <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
  100ad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100adc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ae3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ae6:	01 d0                	add    %edx,%eax
  100ae8:	8b 00                	mov    (%eax),%eax
  100aea:	89 44 24 04          	mov    %eax,0x4(%esp)
  100aee:	c7 04 24 50 6f 10 00 	movl   $0x106f50,(%esp)
  100af5:	e8 9d f7 ff ff       	call   100297 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
  100afa:	ff 45 e8             	incl   -0x18(%ebp)
  100afd:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
  100b01:	7e d6                	jle    100ad9 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
  100b03:	c7 04 24 58 6f 10 00 	movl   $0x106f58,(%esp)
  100b0a:	e8 88 f7 ff ff       	call   100297 <cprintf>
        print_debuginfo(eip - 1);
  100b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b12:	48                   	dec    %eax
  100b13:	89 04 24             	mov    %eax,(%esp)
  100b16:	e8 b9 fe ff ff       	call   1009d4 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
  100b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b1e:	83 c0 04             	add    $0x4,%eax
  100b21:	8b 00                	mov    (%eax),%eax
  100b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
  100b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b29:	8b 00                	mov    (%eax),%eax
  100b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
  100b2e:	ff 45 ec             	incl   -0x14(%ebp)
  100b31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b35:	74 0a                	je     100b41 <print_stackframe+0xb9>
  100b37:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b3b:	0f 8e 6c ff ff ff    	jle    100aad <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
  100b41:	90                   	nop
  100b42:	c9                   	leave  
  100b43:	c3                   	ret    

00100b44 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b44:	55                   	push   %ebp
  100b45:	89 e5                	mov    %esp,%ebp
  100b47:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b51:	eb 0c                	jmp    100b5f <parse+0x1b>
            *buf ++ = '\0';
  100b53:	8b 45 08             	mov    0x8(%ebp),%eax
  100b56:	8d 50 01             	lea    0x1(%eax),%edx
  100b59:	89 55 08             	mov    %edx,0x8(%ebp)
  100b5c:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  100b62:	0f b6 00             	movzbl (%eax),%eax
  100b65:	84 c0                	test   %al,%al
  100b67:	74 1d                	je     100b86 <parse+0x42>
  100b69:	8b 45 08             	mov    0x8(%ebp),%eax
  100b6c:	0f b6 00             	movzbl (%eax),%eax
  100b6f:	0f be c0             	movsbl %al,%eax
  100b72:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b76:	c7 04 24 dc 6f 10 00 	movl   $0x106fdc,(%esp)
  100b7d:	e8 24 58 00 00       	call   1063a6 <strchr>
  100b82:	85 c0                	test   %eax,%eax
  100b84:	75 cd                	jne    100b53 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b86:	8b 45 08             	mov    0x8(%ebp),%eax
  100b89:	0f b6 00             	movzbl (%eax),%eax
  100b8c:	84 c0                	test   %al,%al
  100b8e:	74 69                	je     100bf9 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b90:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b94:	75 14                	jne    100baa <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b96:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b9d:	00 
  100b9e:	c7 04 24 e1 6f 10 00 	movl   $0x106fe1,(%esp)
  100ba5:	e8 ed f6 ff ff       	call   100297 <cprintf>
        }
        argv[argc ++] = buf;
  100baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bad:	8d 50 01             	lea    0x1(%eax),%edx
  100bb0:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bba:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bbd:	01 c2                	add    %eax,%edx
  100bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc2:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc4:	eb 03                	jmp    100bc9 <parse+0x85>
            buf ++;
  100bc6:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bcc:	0f b6 00             	movzbl (%eax),%eax
  100bcf:	84 c0                	test   %al,%al
  100bd1:	0f 84 7a ff ff ff    	je     100b51 <parse+0xd>
  100bd7:	8b 45 08             	mov    0x8(%ebp),%eax
  100bda:	0f b6 00             	movzbl (%eax),%eax
  100bdd:	0f be c0             	movsbl %al,%eax
  100be0:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be4:	c7 04 24 dc 6f 10 00 	movl   $0x106fdc,(%esp)
  100beb:	e8 b6 57 00 00       	call   1063a6 <strchr>
  100bf0:	85 c0                	test   %eax,%eax
  100bf2:	74 d2                	je     100bc6 <parse+0x82>
            buf ++;
        }
    }
  100bf4:	e9 58 ff ff ff       	jmp    100b51 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100bf9:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100bfd:	c9                   	leave  
  100bfe:	c3                   	ret    

00100bff <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100bff:	55                   	push   %ebp
  100c00:	89 e5                	mov    %esp,%ebp
  100c02:	53                   	push   %ebx
  100c03:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c06:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100c10:	89 04 24             	mov    %eax,(%esp)
  100c13:	e8 2c ff ff ff       	call   100b44 <parse>
  100c18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c1f:	75 0a                	jne    100c2b <runcmd+0x2c>
        return 0;
  100c21:	b8 00 00 00 00       	mov    $0x0,%eax
  100c26:	e9 83 00 00 00       	jmp    100cae <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c32:	eb 5a                	jmp    100c8e <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c34:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c3a:	89 d0                	mov    %edx,%eax
  100c3c:	01 c0                	add    %eax,%eax
  100c3e:	01 d0                	add    %edx,%eax
  100c40:	c1 e0 02             	shl    $0x2,%eax
  100c43:	05 00 90 11 00       	add    $0x119000,%eax
  100c48:	8b 00                	mov    (%eax),%eax
  100c4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c4e:	89 04 24             	mov    %eax,(%esp)
  100c51:	e8 b3 56 00 00       	call   106309 <strcmp>
  100c56:	85 c0                	test   %eax,%eax
  100c58:	75 31                	jne    100c8b <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c5d:	89 d0                	mov    %edx,%eax
  100c5f:	01 c0                	add    %eax,%eax
  100c61:	01 d0                	add    %edx,%eax
  100c63:	c1 e0 02             	shl    $0x2,%eax
  100c66:	05 08 90 11 00       	add    $0x119008,%eax
  100c6b:	8b 10                	mov    (%eax),%edx
  100c6d:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c70:	83 c0 04             	add    $0x4,%eax
  100c73:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c76:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c7c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c80:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c84:	89 1c 24             	mov    %ebx,(%esp)
  100c87:	ff d2                	call   *%edx
  100c89:	eb 23                	jmp    100cae <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c8b:	ff 45 f4             	incl   -0xc(%ebp)
  100c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c91:	83 f8 02             	cmp    $0x2,%eax
  100c94:	76 9e                	jbe    100c34 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c96:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c99:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9d:	c7 04 24 ff 6f 10 00 	movl   $0x106fff,(%esp)
  100ca4:	e8 ee f5 ff ff       	call   100297 <cprintf>
    return 0;
  100ca9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cae:	83 c4 64             	add    $0x64,%esp
  100cb1:	5b                   	pop    %ebx
  100cb2:	5d                   	pop    %ebp
  100cb3:	c3                   	ret    

00100cb4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cb4:	55                   	push   %ebp
  100cb5:	89 e5                	mov    %esp,%ebp
  100cb7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cba:	c7 04 24 18 70 10 00 	movl   $0x107018,(%esp)
  100cc1:	e8 d1 f5 ff ff       	call   100297 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cc6:	c7 04 24 40 70 10 00 	movl   $0x107040,(%esp)
  100ccd:	e8 c5 f5 ff ff       	call   100297 <cprintf>

    if (tf != NULL) {
  100cd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cd6:	74 0b                	je     100ce3 <kmonitor+0x2f>
        print_trapframe(tf);
  100cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  100cdb:	89 04 24             	mov    %eax,(%esp)
  100cde:	e8 1e 0d 00 00       	call   101a01 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100ce3:	c7 04 24 65 70 10 00 	movl   $0x107065,(%esp)
  100cea:	e8 4a f6 ff ff       	call   100339 <readline>
  100cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100cf6:	74 eb                	je     100ce3 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  100cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d02:	89 04 24             	mov    %eax,(%esp)
  100d05:	e8 f5 fe ff ff       	call   100bff <runcmd>
  100d0a:	85 c0                	test   %eax,%eax
  100d0c:	78 02                	js     100d10 <kmonitor+0x5c>
                break;
            }
        }
    }
  100d0e:	eb d3                	jmp    100ce3 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100d10:	90                   	nop
            }
        }
    }
}
  100d11:	90                   	nop
  100d12:	c9                   	leave  
  100d13:	c3                   	ret    

00100d14 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d14:	55                   	push   %ebp
  100d15:	89 e5                	mov    %esp,%ebp
  100d17:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d21:	eb 3d                	jmp    100d60 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d26:	89 d0                	mov    %edx,%eax
  100d28:	01 c0                	add    %eax,%eax
  100d2a:	01 d0                	add    %edx,%eax
  100d2c:	c1 e0 02             	shl    $0x2,%eax
  100d2f:	05 04 90 11 00       	add    $0x119004,%eax
  100d34:	8b 08                	mov    (%eax),%ecx
  100d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d39:	89 d0                	mov    %edx,%eax
  100d3b:	01 c0                	add    %eax,%eax
  100d3d:	01 d0                	add    %edx,%eax
  100d3f:	c1 e0 02             	shl    $0x2,%eax
  100d42:	05 00 90 11 00       	add    $0x119000,%eax
  100d47:	8b 00                	mov    (%eax),%eax
  100d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d51:	c7 04 24 69 70 10 00 	movl   $0x107069,(%esp)
  100d58:	e8 3a f5 ff ff       	call   100297 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d5d:	ff 45 f4             	incl   -0xc(%ebp)
  100d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d63:	83 f8 02             	cmp    $0x2,%eax
  100d66:	76 bb                	jbe    100d23 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d6d:	c9                   	leave  
  100d6e:	c3                   	ret    

00100d6f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d6f:	55                   	push   %ebp
  100d70:	89 e5                	mov    %esp,%ebp
  100d72:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d75:	e8 c3 fb ff ff       	call   10093d <print_kerninfo>
    return 0;
  100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d7f:	c9                   	leave  
  100d80:	c3                   	ret    

00100d81 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d81:	55                   	push   %ebp
  100d82:	89 e5                	mov    %esp,%ebp
  100d84:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d87:	e8 fc fc ff ff       	call   100a88 <print_stackframe>
    return 0;
  100d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d91:	c9                   	leave  
  100d92:	c3                   	ret    

00100d93 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d93:	55                   	push   %ebp
  100d94:	89 e5                	mov    %esp,%ebp
  100d96:	83 ec 28             	sub    $0x28,%esp
  100d99:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d9f:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100da3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100da7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dab:	ee                   	out    %al,(%dx)
  100dac:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100db2:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100db6:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100dbd:	ee                   	out    %al,(%dx)
  100dbe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dc4:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100dc8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100dcc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dd0:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dd1:	c7 05 0c cf 11 00 00 	movl   $0x0,0x11cf0c
  100dd8:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100ddb:	c7 04 24 72 70 10 00 	movl   $0x107072,(%esp)
  100de2:	e8 b0 f4 ff ff       	call   100297 <cprintf>
    pic_enable(IRQ_TIMER);
  100de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dee:	e8 1e 09 00 00       	call   101711 <pic_enable>
}
  100df3:	90                   	nop
  100df4:	c9                   	leave  
  100df5:	c3                   	ret    

00100df6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100df6:	55                   	push   %ebp
  100df7:	89 e5                	mov    %esp,%ebp
  100df9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100dfc:	9c                   	pushf  
  100dfd:	58                   	pop    %eax
  100dfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e04:	25 00 02 00 00       	and    $0x200,%eax
  100e09:	85 c0                	test   %eax,%eax
  100e0b:	74 0c                	je     100e19 <__intr_save+0x23>
        intr_disable();
  100e0d:	e8 6c 0a 00 00       	call   10187e <intr_disable>
        return 1;
  100e12:	b8 01 00 00 00       	mov    $0x1,%eax
  100e17:	eb 05                	jmp    100e1e <__intr_save+0x28>
    }
    return 0;
  100e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e1e:	c9                   	leave  
  100e1f:	c3                   	ret    

00100e20 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e20:	55                   	push   %ebp
  100e21:	89 e5                	mov    %esp,%ebp
  100e23:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e2a:	74 05                	je     100e31 <__intr_restore+0x11>
        intr_enable();
  100e2c:	e8 46 0a 00 00       	call   101877 <intr_enable>
    }
}
  100e31:	90                   	nop
  100e32:	c9                   	leave  
  100e33:	c3                   	ret    

00100e34 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e34:	55                   	push   %ebp
  100e35:	89 e5                	mov    %esp,%ebp
  100e37:	83 ec 10             	sub    $0x10,%esp
  100e3a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e40:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e44:	89 c2                	mov    %eax,%edx
  100e46:	ec                   	in     (%dx),%al
  100e47:	88 45 f4             	mov    %al,-0xc(%ebp)
  100e4a:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e53:	89 c2                	mov    %eax,%edx
  100e55:	ec                   	in     (%dx),%al
  100e56:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e59:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e5f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e63:	89 c2                	mov    %eax,%edx
  100e65:	ec                   	in     (%dx),%al
  100e66:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e69:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e72:	89 c2                	mov    %eax,%edx
  100e74:	ec                   	in     (%dx),%al
  100e75:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e78:	90                   	nop
  100e79:	c9                   	leave  
  100e7a:	c3                   	ret    

00100e7b <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e7b:	55                   	push   %ebp
  100e7c:	89 e5                	mov    %esp,%ebp
  100e7e:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e81:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e8b:	0f b7 00             	movzwl (%eax),%eax
  100e8e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e95:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e9d:	0f b7 00             	movzwl (%eax),%eax
  100ea0:	0f b7 c0             	movzwl %ax,%eax
  100ea3:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ea8:	74 12                	je     100ebc <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100eaa:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100eb1:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100eb8:	b4 03 
  100eba:	eb 13                	jmp    100ecf <cga_init+0x54>
    } else {
        *cp = was;
  100ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebf:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ec3:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ec6:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100ecd:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100ecf:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100ed6:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100eda:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ede:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100ee2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100ee5:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100ee6:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100eed:	40                   	inc    %eax
  100eee:	0f b7 c0             	movzwl %ax,%eax
  100ef1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100ef5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ef9:	89 c2                	mov    %eax,%edx
  100efb:	ec                   	in     (%dx),%al
  100efc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100eff:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100f03:	0f b6 c0             	movzbl %al,%eax
  100f06:	c1 e0 08             	shl    $0x8,%eax
  100f09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f0c:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f13:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100f17:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f1b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100f1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f22:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f23:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f2a:	40                   	inc    %eax
  100f2b:	0f b7 c0             	movzwl %ax,%eax
  100f2e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f32:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f36:	89 c2                	mov    %eax,%edx
  100f38:	ec                   	in     (%dx),%al
  100f39:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f3c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f40:	0f b6 c0             	movzbl %al,%eax
  100f43:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f49:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f51:	0f b7 c0             	movzwl %ax,%eax
  100f54:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100f5a:	90                   	nop
  100f5b:	c9                   	leave  
  100f5c:	c3                   	ret    

00100f5d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f5d:	55                   	push   %ebp
  100f5e:	89 e5                	mov    %esp,%ebp
  100f60:	83 ec 38             	sub    $0x38,%esp
  100f63:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f69:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f6d:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f71:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f75:	ee                   	out    %al,(%dx)
  100f76:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f7c:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f80:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100f87:	ee                   	out    %al,(%dx)
  100f88:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f8e:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f92:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f96:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f9a:	ee                   	out    %al,(%dx)
  100f9b:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100fa1:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fa5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fa9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100fac:	ee                   	out    %al,(%dx)
  100fad:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100fb3:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100fb7:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100fbb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fbf:	ee                   	out    %al,(%dx)
  100fc0:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100fc6:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100fca:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100fce:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100fd1:	ee                   	out    %al,(%dx)
  100fd2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100fd8:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100fdc:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100fe0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100fe4:	ee                   	out    %al,(%dx)
  100fe5:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100feb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100fee:	89 c2                	mov    %eax,%edx
  100ff0:	ec                   	in     (%dx),%al
  100ff1:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100ff4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100ff8:	3c ff                	cmp    $0xff,%al
  100ffa:	0f 95 c0             	setne  %al
  100ffd:	0f b6 c0             	movzbl %al,%eax
  101000:	a3 48 c4 11 00       	mov    %eax,0x11c448
  101005:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10100b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  10100f:	89 c2                	mov    %eax,%edx
  101011:	ec                   	in     (%dx),%al
  101012:	88 45 e2             	mov    %al,-0x1e(%ebp)
  101015:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  10101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10101e:	89 c2                	mov    %eax,%edx
  101020:	ec                   	in     (%dx),%al
  101021:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101024:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101029:	85 c0                	test   %eax,%eax
  10102b:	74 0c                	je     101039 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  10102d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101034:	e8 d8 06 00 00       	call   101711 <pic_enable>
    }
}
  101039:	90                   	nop
  10103a:	c9                   	leave  
  10103b:	c3                   	ret    

0010103c <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  10103c:	55                   	push   %ebp
  10103d:	89 e5                	mov    %esp,%ebp
  10103f:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101042:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101049:	eb 08                	jmp    101053 <lpt_putc_sub+0x17>
        delay();
  10104b:	e8 e4 fd ff ff       	call   100e34 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101050:	ff 45 fc             	incl   -0x4(%ebp)
  101053:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101059:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10105c:	89 c2                	mov    %eax,%edx
  10105e:	ec                   	in     (%dx),%al
  10105f:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  101062:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101066:	84 c0                	test   %al,%al
  101068:	78 09                	js     101073 <lpt_putc_sub+0x37>
  10106a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101071:	7e d8                	jle    10104b <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101073:	8b 45 08             	mov    0x8(%ebp),%eax
  101076:	0f b6 c0             	movzbl %al,%eax
  101079:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10107f:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101082:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101086:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101089:	ee                   	out    %al,(%dx)
  10108a:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  101090:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101094:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101098:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10109c:	ee                   	out    %al,(%dx)
  10109d:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  1010a3:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  1010a7:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1010ab:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1010af:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010b0:	90                   	nop
  1010b1:	c9                   	leave  
  1010b2:	c3                   	ret    

001010b3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010b3:	55                   	push   %ebp
  1010b4:	89 e5                	mov    %esp,%ebp
  1010b6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010b9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010bd:	74 0d                	je     1010cc <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1010c2:	89 04 24             	mov    %eax,(%esp)
  1010c5:	e8 72 ff ff ff       	call   10103c <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010ca:	eb 24                	jmp    1010f0 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  1010cc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010d3:	e8 64 ff ff ff       	call   10103c <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010df:	e8 58 ff ff ff       	call   10103c <lpt_putc_sub>
        lpt_putc_sub('\b');
  1010e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010eb:	e8 4c ff ff ff       	call   10103c <lpt_putc_sub>
    }
}
  1010f0:	90                   	nop
  1010f1:	c9                   	leave  
  1010f2:	c3                   	ret    

001010f3 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010f3:	55                   	push   %ebp
  1010f4:	89 e5                	mov    %esp,%ebp
  1010f6:	53                   	push   %ebx
  1010f7:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1010fd:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101102:	85 c0                	test   %eax,%eax
  101104:	75 07                	jne    10110d <cga_putc+0x1a>
        c |= 0x0700;
  101106:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	0f b6 c0             	movzbl %al,%eax
  101113:	83 f8 0a             	cmp    $0xa,%eax
  101116:	74 54                	je     10116c <cga_putc+0x79>
  101118:	83 f8 0d             	cmp    $0xd,%eax
  10111b:	74 62                	je     10117f <cga_putc+0x8c>
  10111d:	83 f8 08             	cmp    $0x8,%eax
  101120:	0f 85 93 00 00 00    	jne    1011b9 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  101126:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10112d:	85 c0                	test   %eax,%eax
  10112f:	0f 84 ae 00 00 00    	je     1011e3 <cga_putc+0xf0>
            crt_pos --;
  101135:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10113c:	48                   	dec    %eax
  10113d:	0f b7 c0             	movzwl %ax,%eax
  101140:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101146:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10114b:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  101152:	01 d2                	add    %edx,%edx
  101154:	01 c2                	add    %eax,%edx
  101156:	8b 45 08             	mov    0x8(%ebp),%eax
  101159:	98                   	cwtl   
  10115a:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10115f:	98                   	cwtl   
  101160:	83 c8 20             	or     $0x20,%eax
  101163:	98                   	cwtl   
  101164:	0f b7 c0             	movzwl %ax,%eax
  101167:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  10116a:	eb 77                	jmp    1011e3 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  10116c:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101173:	83 c0 50             	add    $0x50,%eax
  101176:	0f b7 c0             	movzwl %ax,%eax
  101179:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10117f:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  101186:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  10118d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101192:	89 c8                	mov    %ecx,%eax
  101194:	f7 e2                	mul    %edx
  101196:	c1 ea 06             	shr    $0x6,%edx
  101199:	89 d0                	mov    %edx,%eax
  10119b:	c1 e0 02             	shl    $0x2,%eax
  10119e:	01 d0                	add    %edx,%eax
  1011a0:	c1 e0 04             	shl    $0x4,%eax
  1011a3:	29 c1                	sub    %eax,%ecx
  1011a5:	89 c8                	mov    %ecx,%eax
  1011a7:	0f b7 c0             	movzwl %ax,%eax
  1011aa:	29 c3                	sub    %eax,%ebx
  1011ac:	89 d8                	mov    %ebx,%eax
  1011ae:	0f b7 c0             	movzwl %ax,%eax
  1011b1:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  1011b7:	eb 2b                	jmp    1011e4 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011b9:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011bf:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011c6:	8d 50 01             	lea    0x1(%eax),%edx
  1011c9:	0f b7 d2             	movzwl %dx,%edx
  1011cc:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  1011d3:	01 c0                	add    %eax,%eax
  1011d5:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1011db:	0f b7 c0             	movzwl %ax,%eax
  1011de:	66 89 02             	mov    %ax,(%edx)
        break;
  1011e1:	eb 01                	jmp    1011e4 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  1011e3:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  1011e4:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011eb:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  1011f0:	76 5d                	jbe    10124f <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011f2:	a1 40 c4 11 00       	mov    0x11c440,%eax
  1011f7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011fd:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101202:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101209:	00 
  10120a:	89 54 24 04          	mov    %edx,0x4(%esp)
  10120e:	89 04 24             	mov    %eax,(%esp)
  101211:	e8 86 53 00 00       	call   10659c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101216:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10121d:	eb 14                	jmp    101233 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  10121f:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101224:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101227:	01 d2                	add    %edx,%edx
  101229:	01 d0                	add    %edx,%eax
  10122b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101230:	ff 45 f4             	incl   -0xc(%ebp)
  101233:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  10123a:	7e e3                	jle    10121f <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  10123c:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101243:	83 e8 50             	sub    $0x50,%eax
  101246:	0f b7 c0             	movzwl %ax,%eax
  101249:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10124f:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  101256:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  10125a:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  10125e:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  101262:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101266:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101267:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  10126e:	c1 e8 08             	shr    $0x8,%eax
  101271:	0f b7 c0             	movzwl %ax,%eax
  101274:	0f b6 c0             	movzbl %al,%eax
  101277:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  10127e:	42                   	inc    %edx
  10127f:	0f b7 d2             	movzwl %dx,%edx
  101282:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101286:	88 45 e9             	mov    %al,-0x17(%ebp)
  101289:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10128d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101290:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  101291:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  101298:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10129c:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  1012a0:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  1012a4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012a8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012a9:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012b0:	0f b6 c0             	movzbl %al,%eax
  1012b3:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  1012ba:	42                   	inc    %edx
  1012bb:	0f b7 d2             	movzwl %dx,%edx
  1012be:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  1012c2:	88 45 eb             	mov    %al,-0x15(%ebp)
  1012c5:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1012c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1012cc:	ee                   	out    %al,(%dx)
}
  1012cd:	90                   	nop
  1012ce:	83 c4 24             	add    $0x24,%esp
  1012d1:	5b                   	pop    %ebx
  1012d2:	5d                   	pop    %ebp
  1012d3:	c3                   	ret    

001012d4 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012d4:	55                   	push   %ebp
  1012d5:	89 e5                	mov    %esp,%ebp
  1012d7:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012e1:	eb 08                	jmp    1012eb <serial_putc_sub+0x17>
        delay();
  1012e3:	e8 4c fb ff ff       	call   100e34 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012e8:	ff 45 fc             	incl   -0x4(%ebp)
  1012eb:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1012f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1012f4:	89 c2                	mov    %eax,%edx
  1012f6:	ec                   	in     (%dx),%al
  1012f7:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1012fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1012fe:	0f b6 c0             	movzbl %al,%eax
  101301:	83 e0 20             	and    $0x20,%eax
  101304:	85 c0                	test   %eax,%eax
  101306:	75 09                	jne    101311 <serial_putc_sub+0x3d>
  101308:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10130f:	7e d2                	jle    1012e3 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  101311:	8b 45 08             	mov    0x8(%ebp),%eax
  101314:	0f b6 c0             	movzbl %al,%eax
  101317:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  10131d:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101320:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  101324:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101328:	ee                   	out    %al,(%dx)
}
  101329:	90                   	nop
  10132a:	c9                   	leave  
  10132b:	c3                   	ret    

0010132c <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  10132c:	55                   	push   %ebp
  10132d:	89 e5                	mov    %esp,%ebp
  10132f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101332:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101336:	74 0d                	je     101345 <serial_putc+0x19>
        serial_putc_sub(c);
  101338:	8b 45 08             	mov    0x8(%ebp),%eax
  10133b:	89 04 24             	mov    %eax,(%esp)
  10133e:	e8 91 ff ff ff       	call   1012d4 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101343:	eb 24                	jmp    101369 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  101345:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  10134c:	e8 83 ff ff ff       	call   1012d4 <serial_putc_sub>
        serial_putc_sub(' ');
  101351:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101358:	e8 77 ff ff ff       	call   1012d4 <serial_putc_sub>
        serial_putc_sub('\b');
  10135d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101364:	e8 6b ff ff ff       	call   1012d4 <serial_putc_sub>
    }
}
  101369:	90                   	nop
  10136a:	c9                   	leave  
  10136b:	c3                   	ret    

0010136c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10136c:	55                   	push   %ebp
  10136d:	89 e5                	mov    %esp,%ebp
  10136f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101372:	eb 33                	jmp    1013a7 <cons_intr+0x3b>
        if (c != 0) {
  101374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101378:	74 2d                	je     1013a7 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  10137a:	a1 64 c6 11 00       	mov    0x11c664,%eax
  10137f:	8d 50 01             	lea    0x1(%eax),%edx
  101382:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  101388:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10138b:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  101391:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101396:	3d 00 02 00 00       	cmp    $0x200,%eax
  10139b:	75 0a                	jne    1013a7 <cons_intr+0x3b>
                cons.wpos = 0;
  10139d:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  1013a4:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1013aa:	ff d0                	call   *%eax
  1013ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013af:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013b3:	75 bf                	jne    101374 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013b5:	90                   	nop
  1013b6:	c9                   	leave  
  1013b7:	c3                   	ret    

001013b8 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013b8:	55                   	push   %ebp
  1013b9:	89 e5                	mov    %esp,%ebp
  1013bb:	83 ec 10             	sub    $0x10,%esp
  1013be:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1013c7:	89 c2                	mov    %eax,%edx
  1013c9:	ec                   	in     (%dx),%al
  1013ca:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1013cd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013d1:	0f b6 c0             	movzbl %al,%eax
  1013d4:	83 e0 01             	and    $0x1,%eax
  1013d7:	85 c0                	test   %eax,%eax
  1013d9:	75 07                	jne    1013e2 <serial_proc_data+0x2a>
        return -1;
  1013db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013e0:	eb 2a                	jmp    10140c <serial_proc_data+0x54>
  1013e2:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1013ec:	89 c2                	mov    %eax,%edx
  1013ee:	ec                   	in     (%dx),%al
  1013ef:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  1013f2:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013f6:	0f b6 c0             	movzbl %al,%eax
  1013f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013fc:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  101400:	75 07                	jne    101409 <serial_proc_data+0x51>
        c = '\b';
  101402:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101409:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10140c:	c9                   	leave  
  10140d:	c3                   	ret    

0010140e <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10140e:	55                   	push   %ebp
  10140f:	89 e5                	mov    %esp,%ebp
  101411:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101414:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101419:	85 c0                	test   %eax,%eax
  10141b:	74 0c                	je     101429 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10141d:	c7 04 24 b8 13 10 00 	movl   $0x1013b8,(%esp)
  101424:	e8 43 ff ff ff       	call   10136c <cons_intr>
    }
}
  101429:	90                   	nop
  10142a:	c9                   	leave  
  10142b:	c3                   	ret    

0010142c <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10142c:	55                   	push   %ebp
  10142d:	89 e5                	mov    %esp,%ebp
  10142f:	83 ec 28             	sub    $0x28,%esp
  101432:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101438:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10143b:	89 c2                	mov    %eax,%edx
  10143d:	ec                   	in     (%dx),%al
  10143e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  101441:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101445:	0f b6 c0             	movzbl %al,%eax
  101448:	83 e0 01             	and    $0x1,%eax
  10144b:	85 c0                	test   %eax,%eax
  10144d:	75 0a                	jne    101459 <kbd_proc_data+0x2d>
        return -1;
  10144f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101454:	e9 56 01 00 00       	jmp    1015af <kbd_proc_data+0x183>
  101459:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101462:	89 c2                	mov    %eax,%edx
  101464:	ec                   	in     (%dx),%al
  101465:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  101468:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  10146c:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10146f:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101473:	75 17                	jne    10148c <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101475:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10147a:	83 c8 40             	or     $0x40,%eax
  10147d:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  101482:	b8 00 00 00 00       	mov    $0x0,%eax
  101487:	e9 23 01 00 00       	jmp    1015af <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  10148c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101490:	84 c0                	test   %al,%al
  101492:	79 45                	jns    1014d9 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101494:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101499:	83 e0 40             	and    $0x40,%eax
  10149c:	85 c0                	test   %eax,%eax
  10149e:	75 08                	jne    1014a8 <kbd_proc_data+0x7c>
  1014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a4:	24 7f                	and    $0x7f,%al
  1014a6:	eb 04                	jmp    1014ac <kbd_proc_data+0x80>
  1014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ac:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014af:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014b3:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  1014ba:	0c 40                	or     $0x40,%al
  1014bc:	0f b6 c0             	movzbl %al,%eax
  1014bf:	f7 d0                	not    %eax
  1014c1:	89 c2                	mov    %eax,%edx
  1014c3:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014c8:	21 d0                	and    %edx,%eax
  1014ca:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1014cf:	b8 00 00 00 00       	mov    $0x0,%eax
  1014d4:	e9 d6 00 00 00       	jmp    1015af <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014d9:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014de:	83 e0 40             	and    $0x40,%eax
  1014e1:	85 c0                	test   %eax,%eax
  1014e3:	74 11                	je     1014f6 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  1014e5:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  1014e9:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014ee:	83 e0 bf             	and    $0xffffffbf,%eax
  1014f1:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  1014f6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014fa:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101501:	0f b6 d0             	movzbl %al,%edx
  101504:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101509:	09 d0                	or     %edx,%eax
  10150b:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  101510:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101514:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  10151b:	0f b6 d0             	movzbl %al,%edx
  10151e:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101523:	31 d0                	xor    %edx,%eax
  101525:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  10152a:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10152f:	83 e0 03             	and    $0x3,%eax
  101532:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  101539:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10153d:	01 d0                	add    %edx,%eax
  10153f:	0f b6 00             	movzbl (%eax),%eax
  101542:	0f b6 c0             	movzbl %al,%eax
  101545:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101548:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10154d:	83 e0 08             	and    $0x8,%eax
  101550:	85 c0                	test   %eax,%eax
  101552:	74 22                	je     101576 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101554:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101558:	7e 0c                	jle    101566 <kbd_proc_data+0x13a>
  10155a:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10155e:	7f 06                	jg     101566 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  101560:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101564:	eb 10                	jmp    101576 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101566:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  10156a:	7e 0a                	jle    101576 <kbd_proc_data+0x14a>
  10156c:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  101570:	7f 04                	jg     101576 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101572:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101576:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10157b:	f7 d0                	not    %eax
  10157d:	83 e0 06             	and    $0x6,%eax
  101580:	85 c0                	test   %eax,%eax
  101582:	75 28                	jne    1015ac <kbd_proc_data+0x180>
  101584:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  10158b:	75 1f                	jne    1015ac <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  10158d:	c7 04 24 8d 70 10 00 	movl   $0x10708d,(%esp)
  101594:	e8 fe ec ff ff       	call   100297 <cprintf>
  101599:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  10159f:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015a3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1015a7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1015ab:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015af:	c9                   	leave  
  1015b0:	c3                   	ret    

001015b1 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015b1:	55                   	push   %ebp
  1015b2:	89 e5                	mov    %esp,%ebp
  1015b4:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015b7:	c7 04 24 2c 14 10 00 	movl   $0x10142c,(%esp)
  1015be:	e8 a9 fd ff ff       	call   10136c <cons_intr>
}
  1015c3:	90                   	nop
  1015c4:	c9                   	leave  
  1015c5:	c3                   	ret    

001015c6 <kbd_init>:

static void
kbd_init(void) {
  1015c6:	55                   	push   %ebp
  1015c7:	89 e5                	mov    %esp,%ebp
  1015c9:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015cc:	e8 e0 ff ff ff       	call   1015b1 <kbd_intr>
    pic_enable(IRQ_KBD);
  1015d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015d8:	e8 34 01 00 00       	call   101711 <pic_enable>
}
  1015dd:	90                   	nop
  1015de:	c9                   	leave  
  1015df:	c3                   	ret    

001015e0 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015e0:	55                   	push   %ebp
  1015e1:	89 e5                	mov    %esp,%ebp
  1015e3:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  1015e6:	e8 90 f8 ff ff       	call   100e7b <cga_init>
    serial_init();
  1015eb:	e8 6d f9 ff ff       	call   100f5d <serial_init>
    kbd_init();
  1015f0:	e8 d1 ff ff ff       	call   1015c6 <kbd_init>
    if (!serial_exists) {
  1015f5:	a1 48 c4 11 00       	mov    0x11c448,%eax
  1015fa:	85 c0                	test   %eax,%eax
  1015fc:	75 0c                	jne    10160a <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015fe:	c7 04 24 99 70 10 00 	movl   $0x107099,(%esp)
  101605:	e8 8d ec ff ff       	call   100297 <cprintf>
    }
}
  10160a:	90                   	nop
  10160b:	c9                   	leave  
  10160c:	c3                   	ret    

0010160d <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10160d:	55                   	push   %ebp
  10160e:	89 e5                	mov    %esp,%ebp
  101610:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101613:	e8 de f7 ff ff       	call   100df6 <__intr_save>
  101618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  10161b:	8b 45 08             	mov    0x8(%ebp),%eax
  10161e:	89 04 24             	mov    %eax,(%esp)
  101621:	e8 8d fa ff ff       	call   1010b3 <lpt_putc>
        cga_putc(c);
  101626:	8b 45 08             	mov    0x8(%ebp),%eax
  101629:	89 04 24             	mov    %eax,(%esp)
  10162c:	e8 c2 fa ff ff       	call   1010f3 <cga_putc>
        serial_putc(c);
  101631:	8b 45 08             	mov    0x8(%ebp),%eax
  101634:	89 04 24             	mov    %eax,(%esp)
  101637:	e8 f0 fc ff ff       	call   10132c <serial_putc>
    }
    local_intr_restore(intr_flag);
  10163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10163f:	89 04 24             	mov    %eax,(%esp)
  101642:	e8 d9 f7 ff ff       	call   100e20 <__intr_restore>
}
  101647:	90                   	nop
  101648:	c9                   	leave  
  101649:	c3                   	ret    

0010164a <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  10164a:	55                   	push   %ebp
  10164b:	89 e5                	mov    %esp,%ebp
  10164d:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  101650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101657:	e8 9a f7 ff ff       	call   100df6 <__intr_save>
  10165c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  10165f:	e8 aa fd ff ff       	call   10140e <serial_intr>
        kbd_intr();
  101664:	e8 48 ff ff ff       	call   1015b1 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101669:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  10166f:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101674:	39 c2                	cmp    %eax,%edx
  101676:	74 31                	je     1016a9 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101678:	a1 60 c6 11 00       	mov    0x11c660,%eax
  10167d:	8d 50 01             	lea    0x1(%eax),%edx
  101680:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  101686:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  10168d:	0f b6 c0             	movzbl %al,%eax
  101690:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101693:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101698:	3d 00 02 00 00       	cmp    $0x200,%eax
  10169d:	75 0a                	jne    1016a9 <cons_getc+0x5f>
                cons.rpos = 0;
  10169f:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  1016a6:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016ac:	89 04 24             	mov    %eax,(%esp)
  1016af:	e8 6c f7 ff ff       	call   100e20 <__intr_restore>
    return c;
  1016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016b7:	c9                   	leave  
  1016b8:	c3                   	ret    

001016b9 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016b9:	55                   	push   %ebp
  1016ba:	89 e5                	mov    %esp,%ebp
  1016bc:	83 ec 14             	sub    $0x14,%esp
  1016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1016c2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016c9:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  1016cf:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  1016d4:	85 c0                	test   %eax,%eax
  1016d6:	74 36                	je     10170e <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  1016d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016db:	0f b6 c0             	movzbl %al,%eax
  1016de:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e4:	88 45 fa             	mov    %al,-0x6(%ebp)
  1016e7:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  1016eb:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016ef:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  1016f0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  1016f4:	c1 e8 08             	shr    $0x8,%eax
  1016f7:	0f b7 c0             	movzwl %ax,%eax
  1016fa:	0f b6 c0             	movzbl %al,%eax
  1016fd:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101703:	88 45 fb             	mov    %al,-0x5(%ebp)
  101706:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  10170a:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10170d:	ee                   	out    %al,(%dx)
    }
}
  10170e:	90                   	nop
  10170f:	c9                   	leave  
  101710:	c3                   	ret    

00101711 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101711:	55                   	push   %ebp
  101712:	89 e5                	mov    %esp,%ebp
  101714:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101717:	8b 45 08             	mov    0x8(%ebp),%eax
  10171a:	ba 01 00 00 00       	mov    $0x1,%edx
  10171f:	88 c1                	mov    %al,%cl
  101721:	d3 e2                	shl    %cl,%edx
  101723:	89 d0                	mov    %edx,%eax
  101725:	98                   	cwtl   
  101726:	f7 d0                	not    %eax
  101728:	0f bf d0             	movswl %ax,%edx
  10172b:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101732:	98                   	cwtl   
  101733:	21 d0                	and    %edx,%eax
  101735:	98                   	cwtl   
  101736:	0f b7 c0             	movzwl %ax,%eax
  101739:	89 04 24             	mov    %eax,(%esp)
  10173c:	e8 78 ff ff ff       	call   1016b9 <pic_setmask>
}
  101741:	90                   	nop
  101742:	c9                   	leave  
  101743:	c3                   	ret    

00101744 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101744:	55                   	push   %ebp
  101745:	89 e5                	mov    %esp,%ebp
  101747:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
  10174a:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  101751:	00 00 00 
  101754:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10175a:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  10175e:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  101762:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101766:	ee                   	out    %al,(%dx)
  101767:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  10176d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  101771:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  101775:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101778:	ee                   	out    %al,(%dx)
  101779:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  10177f:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  101783:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  101787:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10178b:	ee                   	out    %al,(%dx)
  10178c:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  101792:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  101796:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  10179a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10179d:	ee                   	out    %al,(%dx)
  10179e:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  1017a4:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  1017a8:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  1017ac:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017b0:	ee                   	out    %al,(%dx)
  1017b1:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  1017b7:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  1017bb:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1017c2:	ee                   	out    %al,(%dx)
  1017c3:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  1017c9:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  1017cd:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1017d1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017d5:	ee                   	out    %al,(%dx)
  1017d6:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  1017dc:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  1017e0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  1017e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1017e7:	ee                   	out    %al,(%dx)
  1017e8:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1017ee:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  1017f2:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  1017f6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1017fa:	ee                   	out    %al,(%dx)
  1017fb:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  101801:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101805:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101809:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10180c:	ee                   	out    %al,(%dx)
  10180d:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101813:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101817:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  10181b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10181f:	ee                   	out    %al,(%dx)
  101820:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101826:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  10182a:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10182e:	8b 55 e8             	mov    -0x18(%ebp),%edx
  101831:	ee                   	out    %al,(%dx)
  101832:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101838:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  10183c:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  101840:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101844:	ee                   	out    %al,(%dx)
  101845:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  10184b:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  10184f:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101853:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101856:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101857:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10185e:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101863:	74 0f                	je     101874 <pic_init+0x130>
        pic_setmask(irq_mask);
  101865:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  10186c:	89 04 24             	mov    %eax,(%esp)
  10186f:	e8 45 fe ff ff       	call   1016b9 <pic_setmask>
    }
}
  101874:	90                   	nop
  101875:	c9                   	leave  
  101876:	c3                   	ret    

00101877 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101877:	55                   	push   %ebp
  101878:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  10187a:	fb                   	sti    
    sti();
}
  10187b:	90                   	nop
  10187c:	5d                   	pop    %ebp
  10187d:	c3                   	ret    

0010187e <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10187e:	55                   	push   %ebp
  10187f:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  101881:	fa                   	cli    
    cli();
}
  101882:	90                   	nop
  101883:	5d                   	pop    %ebp
  101884:	c3                   	ret    

00101885 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  101885:	55                   	push   %ebp
  101886:	89 e5                	mov    %esp,%ebp
  101888:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10188b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101892:	00 
  101893:	c7 04 24 c0 70 10 00 	movl   $0x1070c0,(%esp)
  10189a:	e8 f8 e9 ff ff       	call   100297 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  10189f:	c7 04 24 ca 70 10 00 	movl   $0x1070ca,(%esp)
  1018a6:	e8 ec e9 ff ff       	call   100297 <cprintf>
    panic("EOT: kernel seems ok.");
  1018ab:	c7 44 24 08 d8 70 10 	movl   $0x1070d8,0x8(%esp)
  1018b2:	00 
  1018b3:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  1018ba:	00 
  1018bb:	c7 04 24 ee 70 10 00 	movl   $0x1070ee,(%esp)
  1018c2:	e8 27 eb ff ff       	call   1003ee <__panic>

001018c7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018c7:	55                   	push   %ebp
  1018c8:	89 e5                	mov    %esp,%ebp
  1018ca:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  1018cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018d4:	e9 c4 00 00 00       	jmp    10199d <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  1018d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018dc:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  1018e3:	0f b7 d0             	movzwl %ax,%edx
  1018e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e9:	66 89 14 c5 80 c6 11 	mov    %dx,0x11c680(,%eax,8)
  1018f0:	00 
  1018f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f4:	66 c7 04 c5 82 c6 11 	movw   $0x8,0x11c682(,%eax,8)
  1018fb:	00 08 00 
  1018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101901:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  101908:	00 
  101909:	80 e2 e0             	and    $0xe0,%dl
  10190c:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  101913:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101916:	0f b6 14 c5 84 c6 11 	movzbl 0x11c684(,%eax,8),%edx
  10191d:	00 
  10191e:	80 e2 1f             	and    $0x1f,%dl
  101921:	88 14 c5 84 c6 11 00 	mov    %dl,0x11c684(,%eax,8)
  101928:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10192b:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101932:	00 
  101933:	80 e2 f0             	and    $0xf0,%dl
  101936:	80 ca 0e             	or     $0xe,%dl
  101939:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101940:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101943:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  10194a:	00 
  10194b:	80 e2 ef             	and    $0xef,%dl
  10194e:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  101955:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101958:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  10195f:	00 
  101960:	80 e2 9f             	and    $0x9f,%dl
  101963:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  10196a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196d:	0f b6 14 c5 85 c6 11 	movzbl 0x11c685(,%eax,8),%edx
  101974:	00 
  101975:	80 ca 80             	or     $0x80,%dl
  101978:	88 14 c5 85 c6 11 00 	mov    %dl,0x11c685(,%eax,8)
  10197f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101982:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101989:	c1 e8 10             	shr    $0x10,%eax
  10198c:	0f b7 d0             	movzwl %ax,%edx
  10198f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101992:	66 89 14 c5 86 c6 11 	mov    %dx,0x11c686(,%eax,8)
  101999:	00 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10199a:	ff 45 fc             	incl   -0x4(%ebp)
  10199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  1019a5:	0f 86 2e ff ff ff    	jbe    1018d9 <idt_init+0x12>
  1019ab:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  1019b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1019b5:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
  1019b8:	90                   	nop
  1019b9:	c9                   	leave  
  1019ba:	c3                   	ret    

001019bb <trapname>:

static const char *
trapname(int trapno) {
  1019bb:	55                   	push   %ebp
  1019bc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  1019be:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c1:	83 f8 13             	cmp    $0x13,%eax
  1019c4:	77 0c                	ja     1019d2 <trapname+0x17>
        return excnames[trapno];
  1019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  1019c9:	8b 04 85 40 74 10 00 	mov    0x107440(,%eax,4),%eax
  1019d0:	eb 18                	jmp    1019ea <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  1019d2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  1019d6:	7e 0d                	jle    1019e5 <trapname+0x2a>
  1019d8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  1019dc:	7f 07                	jg     1019e5 <trapname+0x2a>
        return "Hardware Interrupt";
  1019de:	b8 ff 70 10 00       	mov    $0x1070ff,%eax
  1019e3:	eb 05                	jmp    1019ea <trapname+0x2f>
    }
    return "(unknown trap)";
  1019e5:	b8 12 71 10 00       	mov    $0x107112,%eax
}
  1019ea:	5d                   	pop    %ebp
  1019eb:	c3                   	ret    

001019ec <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  1019ec:	55                   	push   %ebp
  1019ed:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  1019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  1019f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1019f6:	83 f8 08             	cmp    $0x8,%eax
  1019f9:	0f 94 c0             	sete   %al
  1019fc:	0f b6 c0             	movzbl %al,%eax
}
  1019ff:	5d                   	pop    %ebp
  101a00:	c3                   	ret    

00101a01 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101a01:	55                   	push   %ebp
  101a02:	89 e5                	mov    %esp,%ebp
  101a04:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101a07:	8b 45 08             	mov    0x8(%ebp),%eax
  101a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a0e:	c7 04 24 53 71 10 00 	movl   $0x107153,(%esp)
  101a15:	e8 7d e8 ff ff       	call   100297 <cprintf>
    print_regs(&tf->tf_regs);
  101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a1d:	89 04 24             	mov    %eax,(%esp)
  101a20:	e8 91 01 00 00       	call   101bb6 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101a25:	8b 45 08             	mov    0x8(%ebp),%eax
  101a28:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a30:	c7 04 24 64 71 10 00 	movl   $0x107164,(%esp)
  101a37:	e8 5b e8 ff ff       	call   100297 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  101a3f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101a43:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a47:	c7 04 24 77 71 10 00 	movl   $0x107177,(%esp)
  101a4e:	e8 44 e8 ff ff       	call   100297 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101a53:	8b 45 08             	mov    0x8(%ebp),%eax
  101a56:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a5e:	c7 04 24 8a 71 10 00 	movl   $0x10718a,(%esp)
  101a65:	e8 2d e8 ff ff       	call   100297 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  101a6d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101a71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a75:	c7 04 24 9d 71 10 00 	movl   $0x10719d,(%esp)
  101a7c:	e8 16 e8 ff ff       	call   100297 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101a81:	8b 45 08             	mov    0x8(%ebp),%eax
  101a84:	8b 40 30             	mov    0x30(%eax),%eax
  101a87:	89 04 24             	mov    %eax,(%esp)
  101a8a:	e8 2c ff ff ff       	call   1019bb <trapname>
  101a8f:	89 c2                	mov    %eax,%edx
  101a91:	8b 45 08             	mov    0x8(%ebp),%eax
  101a94:	8b 40 30             	mov    0x30(%eax),%eax
  101a97:	89 54 24 08          	mov    %edx,0x8(%esp)
  101a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101a9f:	c7 04 24 b0 71 10 00 	movl   $0x1071b0,(%esp)
  101aa6:	e8 ec e7 ff ff       	call   100297 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101aab:	8b 45 08             	mov    0x8(%ebp),%eax
  101aae:	8b 40 34             	mov    0x34(%eax),%eax
  101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ab5:	c7 04 24 c2 71 10 00 	movl   $0x1071c2,(%esp)
  101abc:	e8 d6 e7 ff ff       	call   100297 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac4:	8b 40 38             	mov    0x38(%eax),%eax
  101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101acb:	c7 04 24 d1 71 10 00 	movl   $0x1071d1,(%esp)
  101ad2:	e8 c0 e7 ff ff       	call   100297 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  101ada:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ae2:	c7 04 24 e0 71 10 00 	movl   $0x1071e0,(%esp)
  101ae9:	e8 a9 e7 ff ff       	call   100297 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101aee:	8b 45 08             	mov    0x8(%ebp),%eax
  101af1:	8b 40 40             	mov    0x40(%eax),%eax
  101af4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101af8:	c7 04 24 f3 71 10 00 	movl   $0x1071f3,(%esp)
  101aff:	e8 93 e7 ff ff       	call   100297 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101b0b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101b12:	eb 3d                	jmp    101b51 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101b14:	8b 45 08             	mov    0x8(%ebp),%eax
  101b17:	8b 50 40             	mov    0x40(%eax),%edx
  101b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101b1d:	21 d0                	and    %edx,%eax
  101b1f:	85 c0                	test   %eax,%eax
  101b21:	74 28                	je     101b4b <print_trapframe+0x14a>
  101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b26:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101b2d:	85 c0                	test   %eax,%eax
  101b2f:	74 1a                	je     101b4b <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b34:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b3f:	c7 04 24 02 72 10 00 	movl   $0x107202,(%esp)
  101b46:	e8 4c e7 ff ff       	call   100297 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101b4b:	ff 45 f4             	incl   -0xc(%ebp)
  101b4e:	d1 65 f0             	shll   -0x10(%ebp)
  101b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101b54:	83 f8 17             	cmp    $0x17,%eax
  101b57:	76 bb                	jbe    101b14 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101b59:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5c:	8b 40 40             	mov    0x40(%eax),%eax
  101b5f:	25 00 30 00 00       	and    $0x3000,%eax
  101b64:	c1 e8 0c             	shr    $0xc,%eax
  101b67:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b6b:	c7 04 24 06 72 10 00 	movl   $0x107206,(%esp)
  101b72:	e8 20 e7 ff ff       	call   100297 <cprintf>

    if (!trap_in_kernel(tf)) {
  101b77:	8b 45 08             	mov    0x8(%ebp),%eax
  101b7a:	89 04 24             	mov    %eax,(%esp)
  101b7d:	e8 6a fe ff ff       	call   1019ec <trap_in_kernel>
  101b82:	85 c0                	test   %eax,%eax
  101b84:	75 2d                	jne    101bb3 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101b86:	8b 45 08             	mov    0x8(%ebp),%eax
  101b89:	8b 40 44             	mov    0x44(%eax),%eax
  101b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b90:	c7 04 24 0f 72 10 00 	movl   $0x10720f,(%esp)
  101b97:	e8 fb e6 ff ff       	call   100297 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b9f:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba7:	c7 04 24 1e 72 10 00 	movl   $0x10721e,(%esp)
  101bae:	e8 e4 e6 ff ff       	call   100297 <cprintf>
    }
}
  101bb3:	90                   	nop
  101bb4:	c9                   	leave  
  101bb5:	c3                   	ret    

00101bb6 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101bb6:	55                   	push   %ebp
  101bb7:	89 e5                	mov    %esp,%ebp
  101bb9:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bbf:	8b 00                	mov    (%eax),%eax
  101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bc5:	c7 04 24 31 72 10 00 	movl   $0x107231,(%esp)
  101bcc:	e8 c6 e6 ff ff       	call   100297 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd4:	8b 40 04             	mov    0x4(%eax),%eax
  101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bdb:	c7 04 24 40 72 10 00 	movl   $0x107240,(%esp)
  101be2:	e8 b0 e6 ff ff       	call   100297 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101be7:	8b 45 08             	mov    0x8(%ebp),%eax
  101bea:	8b 40 08             	mov    0x8(%eax),%eax
  101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf1:	c7 04 24 4f 72 10 00 	movl   $0x10724f,(%esp)
  101bf8:	e8 9a e6 ff ff       	call   100297 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  101c00:	8b 40 0c             	mov    0xc(%eax),%eax
  101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c07:	c7 04 24 5e 72 10 00 	movl   $0x10725e,(%esp)
  101c0e:	e8 84 e6 ff ff       	call   100297 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101c13:	8b 45 08             	mov    0x8(%ebp),%eax
  101c16:	8b 40 10             	mov    0x10(%eax),%eax
  101c19:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c1d:	c7 04 24 6d 72 10 00 	movl   $0x10726d,(%esp)
  101c24:	e8 6e e6 ff ff       	call   100297 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101c29:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2c:	8b 40 14             	mov    0x14(%eax),%eax
  101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c33:	c7 04 24 7c 72 10 00 	movl   $0x10727c,(%esp)
  101c3a:	e8 58 e6 ff ff       	call   100297 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
  101c42:	8b 40 18             	mov    0x18(%eax),%eax
  101c45:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c49:	c7 04 24 8b 72 10 00 	movl   $0x10728b,(%esp)
  101c50:	e8 42 e6 ff ff       	call   100297 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101c55:	8b 45 08             	mov    0x8(%ebp),%eax
  101c58:	8b 40 1c             	mov    0x1c(%eax),%eax
  101c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5f:	c7 04 24 9a 72 10 00 	movl   $0x10729a,(%esp)
  101c66:	e8 2c e6 ff ff       	call   100297 <cprintf>
}
  101c6b:	90                   	nop
  101c6c:	c9                   	leave  
  101c6d:	c3                   	ret    

00101c6e <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101c6e:	55                   	push   %ebp
  101c6f:	89 e5                	mov    %esp,%ebp
  101c71:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
  101c74:	8b 45 08             	mov    0x8(%ebp),%eax
  101c77:	8b 40 30             	mov    0x30(%eax),%eax
  101c7a:	83 f8 2f             	cmp    $0x2f,%eax
  101c7d:	77 21                	ja     101ca0 <trap_dispatch+0x32>
  101c7f:	83 f8 2e             	cmp    $0x2e,%eax
  101c82:	0f 83 0c 01 00 00    	jae    101d94 <trap_dispatch+0x126>
  101c88:	83 f8 21             	cmp    $0x21,%eax
  101c8b:	0f 84 8c 00 00 00    	je     101d1d <trap_dispatch+0xaf>
  101c91:	83 f8 24             	cmp    $0x24,%eax
  101c94:	74 61                	je     101cf7 <trap_dispatch+0x89>
  101c96:	83 f8 20             	cmp    $0x20,%eax
  101c99:	74 16                	je     101cb1 <trap_dispatch+0x43>
  101c9b:	e9 bf 00 00 00       	jmp    101d5f <trap_dispatch+0xf1>
  101ca0:	83 e8 78             	sub    $0x78,%eax
  101ca3:	83 f8 01             	cmp    $0x1,%eax
  101ca6:	0f 87 b3 00 00 00    	ja     101d5f <trap_dispatch+0xf1>
  101cac:	e9 92 00 00 00       	jmp    101d43 <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101cb1:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  101cb6:	40                   	inc    %eax
  101cb7:	a3 0c cf 11 00       	mov    %eax,0x11cf0c
        if (ticks % TICK_NUM == 0) {
  101cbc:	8b 0d 0c cf 11 00    	mov    0x11cf0c,%ecx
  101cc2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101cc7:	89 c8                	mov    %ecx,%eax
  101cc9:	f7 e2                	mul    %edx
  101ccb:	c1 ea 05             	shr    $0x5,%edx
  101cce:	89 d0                	mov    %edx,%eax
  101cd0:	c1 e0 02             	shl    $0x2,%eax
  101cd3:	01 d0                	add    %edx,%eax
  101cd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101cdc:	01 d0                	add    %edx,%eax
  101cde:	c1 e0 02             	shl    $0x2,%eax
  101ce1:	29 c1                	sub    %eax,%ecx
  101ce3:	89 ca                	mov    %ecx,%edx
  101ce5:	85 d2                	test   %edx,%edx
  101ce7:	0f 85 aa 00 00 00    	jne    101d97 <trap_dispatch+0x129>
            print_ticks();
  101ced:	e8 93 fb ff ff       	call   101885 <print_ticks>
        }
        break;
  101cf2:	e9 a0 00 00 00       	jmp    101d97 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101cf7:	e8 4e f9 ff ff       	call   10164a <cons_getc>
  101cfc:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101cff:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d03:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d07:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0f:	c7 04 24 a9 72 10 00 	movl   $0x1072a9,(%esp)
  101d16:	e8 7c e5 ff ff       	call   100297 <cprintf>
        break;
  101d1b:	eb 7b                	jmp    101d98 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101d1d:	e8 28 f9 ff ff       	call   10164a <cons_getc>
  101d22:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101d25:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101d29:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101d2d:	89 54 24 08          	mov    %edx,0x8(%esp)
  101d31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d35:	c7 04 24 bb 72 10 00 	movl   $0x1072bb,(%esp)
  101d3c:	e8 56 e5 ff ff       	call   100297 <cprintf>
        break;
  101d41:	eb 55                	jmp    101d98 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
  101d43:	c7 44 24 08 ca 72 10 	movl   $0x1072ca,0x8(%esp)
  101d4a:	00 
  101d4b:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
  101d52:	00 
  101d53:	c7 04 24 ee 70 10 00 	movl   $0x1070ee,(%esp)
  101d5a:	e8 8f e6 ff ff       	call   1003ee <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  101d62:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101d66:	83 e0 03             	and    $0x3,%eax
  101d69:	85 c0                	test   %eax,%eax
  101d6b:	75 2b                	jne    101d98 <trap_dispatch+0x12a>
            print_trapframe(tf);
  101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
  101d70:	89 04 24             	mov    %eax,(%esp)
  101d73:	e8 89 fc ff ff       	call   101a01 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101d78:	c7 44 24 08 da 72 10 	movl   $0x1072da,0x8(%esp)
  101d7f:	00 
  101d80:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
  101d87:	00 
  101d88:	c7 04 24 ee 70 10 00 	movl   $0x1070ee,(%esp)
  101d8f:	e8 5a e6 ff ff       	call   1003ee <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  101d94:	90                   	nop
  101d95:	eb 01                	jmp    101d98 <trap_dispatch+0x12a>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
  101d97:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  101d98:	90                   	nop
  101d99:	c9                   	leave  
  101d9a:	c3                   	ret    

00101d9b <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101d9b:	55                   	push   %ebp
  101d9c:	89 e5                	mov    %esp,%ebp
  101d9e:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101da1:	8b 45 08             	mov    0x8(%ebp),%eax
  101da4:	89 04 24             	mov    %eax,(%esp)
  101da7:	e8 c2 fe ff ff       	call   101c6e <trap_dispatch>
}
  101dac:	90                   	nop
  101dad:	c9                   	leave  
  101dae:	c3                   	ret    

00101daf <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  101daf:	6a 00                	push   $0x0
  pushl $0
  101db1:	6a 00                	push   $0x0
  jmp __alltraps
  101db3:	e9 69 0a 00 00       	jmp    102821 <__alltraps>

00101db8 <vector1>:
.globl vector1
vector1:
  pushl $0
  101db8:	6a 00                	push   $0x0
  pushl $1
  101dba:	6a 01                	push   $0x1
  jmp __alltraps
  101dbc:	e9 60 0a 00 00       	jmp    102821 <__alltraps>

00101dc1 <vector2>:
.globl vector2
vector2:
  pushl $0
  101dc1:	6a 00                	push   $0x0
  pushl $2
  101dc3:	6a 02                	push   $0x2
  jmp __alltraps
  101dc5:	e9 57 0a 00 00       	jmp    102821 <__alltraps>

00101dca <vector3>:
.globl vector3
vector3:
  pushl $0
  101dca:	6a 00                	push   $0x0
  pushl $3
  101dcc:	6a 03                	push   $0x3
  jmp __alltraps
  101dce:	e9 4e 0a 00 00       	jmp    102821 <__alltraps>

00101dd3 <vector4>:
.globl vector4
vector4:
  pushl $0
  101dd3:	6a 00                	push   $0x0
  pushl $4
  101dd5:	6a 04                	push   $0x4
  jmp __alltraps
  101dd7:	e9 45 0a 00 00       	jmp    102821 <__alltraps>

00101ddc <vector5>:
.globl vector5
vector5:
  pushl $0
  101ddc:	6a 00                	push   $0x0
  pushl $5
  101dde:	6a 05                	push   $0x5
  jmp __alltraps
  101de0:	e9 3c 0a 00 00       	jmp    102821 <__alltraps>

00101de5 <vector6>:
.globl vector6
vector6:
  pushl $0
  101de5:	6a 00                	push   $0x0
  pushl $6
  101de7:	6a 06                	push   $0x6
  jmp __alltraps
  101de9:	e9 33 0a 00 00       	jmp    102821 <__alltraps>

00101dee <vector7>:
.globl vector7
vector7:
  pushl $0
  101dee:	6a 00                	push   $0x0
  pushl $7
  101df0:	6a 07                	push   $0x7
  jmp __alltraps
  101df2:	e9 2a 0a 00 00       	jmp    102821 <__alltraps>

00101df7 <vector8>:
.globl vector8
vector8:
  pushl $8
  101df7:	6a 08                	push   $0x8
  jmp __alltraps
  101df9:	e9 23 0a 00 00       	jmp    102821 <__alltraps>

00101dfe <vector9>:
.globl vector9
vector9:
  pushl $0
  101dfe:	6a 00                	push   $0x0
  pushl $9
  101e00:	6a 09                	push   $0x9
  jmp __alltraps
  101e02:	e9 1a 0a 00 00       	jmp    102821 <__alltraps>

00101e07 <vector10>:
.globl vector10
vector10:
  pushl $10
  101e07:	6a 0a                	push   $0xa
  jmp __alltraps
  101e09:	e9 13 0a 00 00       	jmp    102821 <__alltraps>

00101e0e <vector11>:
.globl vector11
vector11:
  pushl $11
  101e0e:	6a 0b                	push   $0xb
  jmp __alltraps
  101e10:	e9 0c 0a 00 00       	jmp    102821 <__alltraps>

00101e15 <vector12>:
.globl vector12
vector12:
  pushl $12
  101e15:	6a 0c                	push   $0xc
  jmp __alltraps
  101e17:	e9 05 0a 00 00       	jmp    102821 <__alltraps>

00101e1c <vector13>:
.globl vector13
vector13:
  pushl $13
  101e1c:	6a 0d                	push   $0xd
  jmp __alltraps
  101e1e:	e9 fe 09 00 00       	jmp    102821 <__alltraps>

00101e23 <vector14>:
.globl vector14
vector14:
  pushl $14
  101e23:	6a 0e                	push   $0xe
  jmp __alltraps
  101e25:	e9 f7 09 00 00       	jmp    102821 <__alltraps>

00101e2a <vector15>:
.globl vector15
vector15:
  pushl $0
  101e2a:	6a 00                	push   $0x0
  pushl $15
  101e2c:	6a 0f                	push   $0xf
  jmp __alltraps
  101e2e:	e9 ee 09 00 00       	jmp    102821 <__alltraps>

00101e33 <vector16>:
.globl vector16
vector16:
  pushl $0
  101e33:	6a 00                	push   $0x0
  pushl $16
  101e35:	6a 10                	push   $0x10
  jmp __alltraps
  101e37:	e9 e5 09 00 00       	jmp    102821 <__alltraps>

00101e3c <vector17>:
.globl vector17
vector17:
  pushl $17
  101e3c:	6a 11                	push   $0x11
  jmp __alltraps
  101e3e:	e9 de 09 00 00       	jmp    102821 <__alltraps>

00101e43 <vector18>:
.globl vector18
vector18:
  pushl $0
  101e43:	6a 00                	push   $0x0
  pushl $18
  101e45:	6a 12                	push   $0x12
  jmp __alltraps
  101e47:	e9 d5 09 00 00       	jmp    102821 <__alltraps>

00101e4c <vector19>:
.globl vector19
vector19:
  pushl $0
  101e4c:	6a 00                	push   $0x0
  pushl $19
  101e4e:	6a 13                	push   $0x13
  jmp __alltraps
  101e50:	e9 cc 09 00 00       	jmp    102821 <__alltraps>

00101e55 <vector20>:
.globl vector20
vector20:
  pushl $0
  101e55:	6a 00                	push   $0x0
  pushl $20
  101e57:	6a 14                	push   $0x14
  jmp __alltraps
  101e59:	e9 c3 09 00 00       	jmp    102821 <__alltraps>

00101e5e <vector21>:
.globl vector21
vector21:
  pushl $0
  101e5e:	6a 00                	push   $0x0
  pushl $21
  101e60:	6a 15                	push   $0x15
  jmp __alltraps
  101e62:	e9 ba 09 00 00       	jmp    102821 <__alltraps>

00101e67 <vector22>:
.globl vector22
vector22:
  pushl $0
  101e67:	6a 00                	push   $0x0
  pushl $22
  101e69:	6a 16                	push   $0x16
  jmp __alltraps
  101e6b:	e9 b1 09 00 00       	jmp    102821 <__alltraps>

00101e70 <vector23>:
.globl vector23
vector23:
  pushl $0
  101e70:	6a 00                	push   $0x0
  pushl $23
  101e72:	6a 17                	push   $0x17
  jmp __alltraps
  101e74:	e9 a8 09 00 00       	jmp    102821 <__alltraps>

00101e79 <vector24>:
.globl vector24
vector24:
  pushl $0
  101e79:	6a 00                	push   $0x0
  pushl $24
  101e7b:	6a 18                	push   $0x18
  jmp __alltraps
  101e7d:	e9 9f 09 00 00       	jmp    102821 <__alltraps>

00101e82 <vector25>:
.globl vector25
vector25:
  pushl $0
  101e82:	6a 00                	push   $0x0
  pushl $25
  101e84:	6a 19                	push   $0x19
  jmp __alltraps
  101e86:	e9 96 09 00 00       	jmp    102821 <__alltraps>

00101e8b <vector26>:
.globl vector26
vector26:
  pushl $0
  101e8b:	6a 00                	push   $0x0
  pushl $26
  101e8d:	6a 1a                	push   $0x1a
  jmp __alltraps
  101e8f:	e9 8d 09 00 00       	jmp    102821 <__alltraps>

00101e94 <vector27>:
.globl vector27
vector27:
  pushl $0
  101e94:	6a 00                	push   $0x0
  pushl $27
  101e96:	6a 1b                	push   $0x1b
  jmp __alltraps
  101e98:	e9 84 09 00 00       	jmp    102821 <__alltraps>

00101e9d <vector28>:
.globl vector28
vector28:
  pushl $0
  101e9d:	6a 00                	push   $0x0
  pushl $28
  101e9f:	6a 1c                	push   $0x1c
  jmp __alltraps
  101ea1:	e9 7b 09 00 00       	jmp    102821 <__alltraps>

00101ea6 <vector29>:
.globl vector29
vector29:
  pushl $0
  101ea6:	6a 00                	push   $0x0
  pushl $29
  101ea8:	6a 1d                	push   $0x1d
  jmp __alltraps
  101eaa:	e9 72 09 00 00       	jmp    102821 <__alltraps>

00101eaf <vector30>:
.globl vector30
vector30:
  pushl $0
  101eaf:	6a 00                	push   $0x0
  pushl $30
  101eb1:	6a 1e                	push   $0x1e
  jmp __alltraps
  101eb3:	e9 69 09 00 00       	jmp    102821 <__alltraps>

00101eb8 <vector31>:
.globl vector31
vector31:
  pushl $0
  101eb8:	6a 00                	push   $0x0
  pushl $31
  101eba:	6a 1f                	push   $0x1f
  jmp __alltraps
  101ebc:	e9 60 09 00 00       	jmp    102821 <__alltraps>

00101ec1 <vector32>:
.globl vector32
vector32:
  pushl $0
  101ec1:	6a 00                	push   $0x0
  pushl $32
  101ec3:	6a 20                	push   $0x20
  jmp __alltraps
  101ec5:	e9 57 09 00 00       	jmp    102821 <__alltraps>

00101eca <vector33>:
.globl vector33
vector33:
  pushl $0
  101eca:	6a 00                	push   $0x0
  pushl $33
  101ecc:	6a 21                	push   $0x21
  jmp __alltraps
  101ece:	e9 4e 09 00 00       	jmp    102821 <__alltraps>

00101ed3 <vector34>:
.globl vector34
vector34:
  pushl $0
  101ed3:	6a 00                	push   $0x0
  pushl $34
  101ed5:	6a 22                	push   $0x22
  jmp __alltraps
  101ed7:	e9 45 09 00 00       	jmp    102821 <__alltraps>

00101edc <vector35>:
.globl vector35
vector35:
  pushl $0
  101edc:	6a 00                	push   $0x0
  pushl $35
  101ede:	6a 23                	push   $0x23
  jmp __alltraps
  101ee0:	e9 3c 09 00 00       	jmp    102821 <__alltraps>

00101ee5 <vector36>:
.globl vector36
vector36:
  pushl $0
  101ee5:	6a 00                	push   $0x0
  pushl $36
  101ee7:	6a 24                	push   $0x24
  jmp __alltraps
  101ee9:	e9 33 09 00 00       	jmp    102821 <__alltraps>

00101eee <vector37>:
.globl vector37
vector37:
  pushl $0
  101eee:	6a 00                	push   $0x0
  pushl $37
  101ef0:	6a 25                	push   $0x25
  jmp __alltraps
  101ef2:	e9 2a 09 00 00       	jmp    102821 <__alltraps>

00101ef7 <vector38>:
.globl vector38
vector38:
  pushl $0
  101ef7:	6a 00                	push   $0x0
  pushl $38
  101ef9:	6a 26                	push   $0x26
  jmp __alltraps
  101efb:	e9 21 09 00 00       	jmp    102821 <__alltraps>

00101f00 <vector39>:
.globl vector39
vector39:
  pushl $0
  101f00:	6a 00                	push   $0x0
  pushl $39
  101f02:	6a 27                	push   $0x27
  jmp __alltraps
  101f04:	e9 18 09 00 00       	jmp    102821 <__alltraps>

00101f09 <vector40>:
.globl vector40
vector40:
  pushl $0
  101f09:	6a 00                	push   $0x0
  pushl $40
  101f0b:	6a 28                	push   $0x28
  jmp __alltraps
  101f0d:	e9 0f 09 00 00       	jmp    102821 <__alltraps>

00101f12 <vector41>:
.globl vector41
vector41:
  pushl $0
  101f12:	6a 00                	push   $0x0
  pushl $41
  101f14:	6a 29                	push   $0x29
  jmp __alltraps
  101f16:	e9 06 09 00 00       	jmp    102821 <__alltraps>

00101f1b <vector42>:
.globl vector42
vector42:
  pushl $0
  101f1b:	6a 00                	push   $0x0
  pushl $42
  101f1d:	6a 2a                	push   $0x2a
  jmp __alltraps
  101f1f:	e9 fd 08 00 00       	jmp    102821 <__alltraps>

00101f24 <vector43>:
.globl vector43
vector43:
  pushl $0
  101f24:	6a 00                	push   $0x0
  pushl $43
  101f26:	6a 2b                	push   $0x2b
  jmp __alltraps
  101f28:	e9 f4 08 00 00       	jmp    102821 <__alltraps>

00101f2d <vector44>:
.globl vector44
vector44:
  pushl $0
  101f2d:	6a 00                	push   $0x0
  pushl $44
  101f2f:	6a 2c                	push   $0x2c
  jmp __alltraps
  101f31:	e9 eb 08 00 00       	jmp    102821 <__alltraps>

00101f36 <vector45>:
.globl vector45
vector45:
  pushl $0
  101f36:	6a 00                	push   $0x0
  pushl $45
  101f38:	6a 2d                	push   $0x2d
  jmp __alltraps
  101f3a:	e9 e2 08 00 00       	jmp    102821 <__alltraps>

00101f3f <vector46>:
.globl vector46
vector46:
  pushl $0
  101f3f:	6a 00                	push   $0x0
  pushl $46
  101f41:	6a 2e                	push   $0x2e
  jmp __alltraps
  101f43:	e9 d9 08 00 00       	jmp    102821 <__alltraps>

00101f48 <vector47>:
.globl vector47
vector47:
  pushl $0
  101f48:	6a 00                	push   $0x0
  pushl $47
  101f4a:	6a 2f                	push   $0x2f
  jmp __alltraps
  101f4c:	e9 d0 08 00 00       	jmp    102821 <__alltraps>

00101f51 <vector48>:
.globl vector48
vector48:
  pushl $0
  101f51:	6a 00                	push   $0x0
  pushl $48
  101f53:	6a 30                	push   $0x30
  jmp __alltraps
  101f55:	e9 c7 08 00 00       	jmp    102821 <__alltraps>

00101f5a <vector49>:
.globl vector49
vector49:
  pushl $0
  101f5a:	6a 00                	push   $0x0
  pushl $49
  101f5c:	6a 31                	push   $0x31
  jmp __alltraps
  101f5e:	e9 be 08 00 00       	jmp    102821 <__alltraps>

00101f63 <vector50>:
.globl vector50
vector50:
  pushl $0
  101f63:	6a 00                	push   $0x0
  pushl $50
  101f65:	6a 32                	push   $0x32
  jmp __alltraps
  101f67:	e9 b5 08 00 00       	jmp    102821 <__alltraps>

00101f6c <vector51>:
.globl vector51
vector51:
  pushl $0
  101f6c:	6a 00                	push   $0x0
  pushl $51
  101f6e:	6a 33                	push   $0x33
  jmp __alltraps
  101f70:	e9 ac 08 00 00       	jmp    102821 <__alltraps>

00101f75 <vector52>:
.globl vector52
vector52:
  pushl $0
  101f75:	6a 00                	push   $0x0
  pushl $52
  101f77:	6a 34                	push   $0x34
  jmp __alltraps
  101f79:	e9 a3 08 00 00       	jmp    102821 <__alltraps>

00101f7e <vector53>:
.globl vector53
vector53:
  pushl $0
  101f7e:	6a 00                	push   $0x0
  pushl $53
  101f80:	6a 35                	push   $0x35
  jmp __alltraps
  101f82:	e9 9a 08 00 00       	jmp    102821 <__alltraps>

00101f87 <vector54>:
.globl vector54
vector54:
  pushl $0
  101f87:	6a 00                	push   $0x0
  pushl $54
  101f89:	6a 36                	push   $0x36
  jmp __alltraps
  101f8b:	e9 91 08 00 00       	jmp    102821 <__alltraps>

00101f90 <vector55>:
.globl vector55
vector55:
  pushl $0
  101f90:	6a 00                	push   $0x0
  pushl $55
  101f92:	6a 37                	push   $0x37
  jmp __alltraps
  101f94:	e9 88 08 00 00       	jmp    102821 <__alltraps>

00101f99 <vector56>:
.globl vector56
vector56:
  pushl $0
  101f99:	6a 00                	push   $0x0
  pushl $56
  101f9b:	6a 38                	push   $0x38
  jmp __alltraps
  101f9d:	e9 7f 08 00 00       	jmp    102821 <__alltraps>

00101fa2 <vector57>:
.globl vector57
vector57:
  pushl $0
  101fa2:	6a 00                	push   $0x0
  pushl $57
  101fa4:	6a 39                	push   $0x39
  jmp __alltraps
  101fa6:	e9 76 08 00 00       	jmp    102821 <__alltraps>

00101fab <vector58>:
.globl vector58
vector58:
  pushl $0
  101fab:	6a 00                	push   $0x0
  pushl $58
  101fad:	6a 3a                	push   $0x3a
  jmp __alltraps
  101faf:	e9 6d 08 00 00       	jmp    102821 <__alltraps>

00101fb4 <vector59>:
.globl vector59
vector59:
  pushl $0
  101fb4:	6a 00                	push   $0x0
  pushl $59
  101fb6:	6a 3b                	push   $0x3b
  jmp __alltraps
  101fb8:	e9 64 08 00 00       	jmp    102821 <__alltraps>

00101fbd <vector60>:
.globl vector60
vector60:
  pushl $0
  101fbd:	6a 00                	push   $0x0
  pushl $60
  101fbf:	6a 3c                	push   $0x3c
  jmp __alltraps
  101fc1:	e9 5b 08 00 00       	jmp    102821 <__alltraps>

00101fc6 <vector61>:
.globl vector61
vector61:
  pushl $0
  101fc6:	6a 00                	push   $0x0
  pushl $61
  101fc8:	6a 3d                	push   $0x3d
  jmp __alltraps
  101fca:	e9 52 08 00 00       	jmp    102821 <__alltraps>

00101fcf <vector62>:
.globl vector62
vector62:
  pushl $0
  101fcf:	6a 00                	push   $0x0
  pushl $62
  101fd1:	6a 3e                	push   $0x3e
  jmp __alltraps
  101fd3:	e9 49 08 00 00       	jmp    102821 <__alltraps>

00101fd8 <vector63>:
.globl vector63
vector63:
  pushl $0
  101fd8:	6a 00                	push   $0x0
  pushl $63
  101fda:	6a 3f                	push   $0x3f
  jmp __alltraps
  101fdc:	e9 40 08 00 00       	jmp    102821 <__alltraps>

00101fe1 <vector64>:
.globl vector64
vector64:
  pushl $0
  101fe1:	6a 00                	push   $0x0
  pushl $64
  101fe3:	6a 40                	push   $0x40
  jmp __alltraps
  101fe5:	e9 37 08 00 00       	jmp    102821 <__alltraps>

00101fea <vector65>:
.globl vector65
vector65:
  pushl $0
  101fea:	6a 00                	push   $0x0
  pushl $65
  101fec:	6a 41                	push   $0x41
  jmp __alltraps
  101fee:	e9 2e 08 00 00       	jmp    102821 <__alltraps>

00101ff3 <vector66>:
.globl vector66
vector66:
  pushl $0
  101ff3:	6a 00                	push   $0x0
  pushl $66
  101ff5:	6a 42                	push   $0x42
  jmp __alltraps
  101ff7:	e9 25 08 00 00       	jmp    102821 <__alltraps>

00101ffc <vector67>:
.globl vector67
vector67:
  pushl $0
  101ffc:	6a 00                	push   $0x0
  pushl $67
  101ffe:	6a 43                	push   $0x43
  jmp __alltraps
  102000:	e9 1c 08 00 00       	jmp    102821 <__alltraps>

00102005 <vector68>:
.globl vector68
vector68:
  pushl $0
  102005:	6a 00                	push   $0x0
  pushl $68
  102007:	6a 44                	push   $0x44
  jmp __alltraps
  102009:	e9 13 08 00 00       	jmp    102821 <__alltraps>

0010200e <vector69>:
.globl vector69
vector69:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $69
  102010:	6a 45                	push   $0x45
  jmp __alltraps
  102012:	e9 0a 08 00 00       	jmp    102821 <__alltraps>

00102017 <vector70>:
.globl vector70
vector70:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $70
  102019:	6a 46                	push   $0x46
  jmp __alltraps
  10201b:	e9 01 08 00 00       	jmp    102821 <__alltraps>

00102020 <vector71>:
.globl vector71
vector71:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $71
  102022:	6a 47                	push   $0x47
  jmp __alltraps
  102024:	e9 f8 07 00 00       	jmp    102821 <__alltraps>

00102029 <vector72>:
.globl vector72
vector72:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $72
  10202b:	6a 48                	push   $0x48
  jmp __alltraps
  10202d:	e9 ef 07 00 00       	jmp    102821 <__alltraps>

00102032 <vector73>:
.globl vector73
vector73:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $73
  102034:	6a 49                	push   $0x49
  jmp __alltraps
  102036:	e9 e6 07 00 00       	jmp    102821 <__alltraps>

0010203b <vector74>:
.globl vector74
vector74:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $74
  10203d:	6a 4a                	push   $0x4a
  jmp __alltraps
  10203f:	e9 dd 07 00 00       	jmp    102821 <__alltraps>

00102044 <vector75>:
.globl vector75
vector75:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $75
  102046:	6a 4b                	push   $0x4b
  jmp __alltraps
  102048:	e9 d4 07 00 00       	jmp    102821 <__alltraps>

0010204d <vector76>:
.globl vector76
vector76:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $76
  10204f:	6a 4c                	push   $0x4c
  jmp __alltraps
  102051:	e9 cb 07 00 00       	jmp    102821 <__alltraps>

00102056 <vector77>:
.globl vector77
vector77:
  pushl $0
  102056:	6a 00                	push   $0x0
  pushl $77
  102058:	6a 4d                	push   $0x4d
  jmp __alltraps
  10205a:	e9 c2 07 00 00       	jmp    102821 <__alltraps>

0010205f <vector78>:
.globl vector78
vector78:
  pushl $0
  10205f:	6a 00                	push   $0x0
  pushl $78
  102061:	6a 4e                	push   $0x4e
  jmp __alltraps
  102063:	e9 b9 07 00 00       	jmp    102821 <__alltraps>

00102068 <vector79>:
.globl vector79
vector79:
  pushl $0
  102068:	6a 00                	push   $0x0
  pushl $79
  10206a:	6a 4f                	push   $0x4f
  jmp __alltraps
  10206c:	e9 b0 07 00 00       	jmp    102821 <__alltraps>

00102071 <vector80>:
.globl vector80
vector80:
  pushl $0
  102071:	6a 00                	push   $0x0
  pushl $80
  102073:	6a 50                	push   $0x50
  jmp __alltraps
  102075:	e9 a7 07 00 00       	jmp    102821 <__alltraps>

0010207a <vector81>:
.globl vector81
vector81:
  pushl $0
  10207a:	6a 00                	push   $0x0
  pushl $81
  10207c:	6a 51                	push   $0x51
  jmp __alltraps
  10207e:	e9 9e 07 00 00       	jmp    102821 <__alltraps>

00102083 <vector82>:
.globl vector82
vector82:
  pushl $0
  102083:	6a 00                	push   $0x0
  pushl $82
  102085:	6a 52                	push   $0x52
  jmp __alltraps
  102087:	e9 95 07 00 00       	jmp    102821 <__alltraps>

0010208c <vector83>:
.globl vector83
vector83:
  pushl $0
  10208c:	6a 00                	push   $0x0
  pushl $83
  10208e:	6a 53                	push   $0x53
  jmp __alltraps
  102090:	e9 8c 07 00 00       	jmp    102821 <__alltraps>

00102095 <vector84>:
.globl vector84
vector84:
  pushl $0
  102095:	6a 00                	push   $0x0
  pushl $84
  102097:	6a 54                	push   $0x54
  jmp __alltraps
  102099:	e9 83 07 00 00       	jmp    102821 <__alltraps>

0010209e <vector85>:
.globl vector85
vector85:
  pushl $0
  10209e:	6a 00                	push   $0x0
  pushl $85
  1020a0:	6a 55                	push   $0x55
  jmp __alltraps
  1020a2:	e9 7a 07 00 00       	jmp    102821 <__alltraps>

001020a7 <vector86>:
.globl vector86
vector86:
  pushl $0
  1020a7:	6a 00                	push   $0x0
  pushl $86
  1020a9:	6a 56                	push   $0x56
  jmp __alltraps
  1020ab:	e9 71 07 00 00       	jmp    102821 <__alltraps>

001020b0 <vector87>:
.globl vector87
vector87:
  pushl $0
  1020b0:	6a 00                	push   $0x0
  pushl $87
  1020b2:	6a 57                	push   $0x57
  jmp __alltraps
  1020b4:	e9 68 07 00 00       	jmp    102821 <__alltraps>

001020b9 <vector88>:
.globl vector88
vector88:
  pushl $0
  1020b9:	6a 00                	push   $0x0
  pushl $88
  1020bb:	6a 58                	push   $0x58
  jmp __alltraps
  1020bd:	e9 5f 07 00 00       	jmp    102821 <__alltraps>

001020c2 <vector89>:
.globl vector89
vector89:
  pushl $0
  1020c2:	6a 00                	push   $0x0
  pushl $89
  1020c4:	6a 59                	push   $0x59
  jmp __alltraps
  1020c6:	e9 56 07 00 00       	jmp    102821 <__alltraps>

001020cb <vector90>:
.globl vector90
vector90:
  pushl $0
  1020cb:	6a 00                	push   $0x0
  pushl $90
  1020cd:	6a 5a                	push   $0x5a
  jmp __alltraps
  1020cf:	e9 4d 07 00 00       	jmp    102821 <__alltraps>

001020d4 <vector91>:
.globl vector91
vector91:
  pushl $0
  1020d4:	6a 00                	push   $0x0
  pushl $91
  1020d6:	6a 5b                	push   $0x5b
  jmp __alltraps
  1020d8:	e9 44 07 00 00       	jmp    102821 <__alltraps>

001020dd <vector92>:
.globl vector92
vector92:
  pushl $0
  1020dd:	6a 00                	push   $0x0
  pushl $92
  1020df:	6a 5c                	push   $0x5c
  jmp __alltraps
  1020e1:	e9 3b 07 00 00       	jmp    102821 <__alltraps>

001020e6 <vector93>:
.globl vector93
vector93:
  pushl $0
  1020e6:	6a 00                	push   $0x0
  pushl $93
  1020e8:	6a 5d                	push   $0x5d
  jmp __alltraps
  1020ea:	e9 32 07 00 00       	jmp    102821 <__alltraps>

001020ef <vector94>:
.globl vector94
vector94:
  pushl $0
  1020ef:	6a 00                	push   $0x0
  pushl $94
  1020f1:	6a 5e                	push   $0x5e
  jmp __alltraps
  1020f3:	e9 29 07 00 00       	jmp    102821 <__alltraps>

001020f8 <vector95>:
.globl vector95
vector95:
  pushl $0
  1020f8:	6a 00                	push   $0x0
  pushl $95
  1020fa:	6a 5f                	push   $0x5f
  jmp __alltraps
  1020fc:	e9 20 07 00 00       	jmp    102821 <__alltraps>

00102101 <vector96>:
.globl vector96
vector96:
  pushl $0
  102101:	6a 00                	push   $0x0
  pushl $96
  102103:	6a 60                	push   $0x60
  jmp __alltraps
  102105:	e9 17 07 00 00       	jmp    102821 <__alltraps>

0010210a <vector97>:
.globl vector97
vector97:
  pushl $0
  10210a:	6a 00                	push   $0x0
  pushl $97
  10210c:	6a 61                	push   $0x61
  jmp __alltraps
  10210e:	e9 0e 07 00 00       	jmp    102821 <__alltraps>

00102113 <vector98>:
.globl vector98
vector98:
  pushl $0
  102113:	6a 00                	push   $0x0
  pushl $98
  102115:	6a 62                	push   $0x62
  jmp __alltraps
  102117:	e9 05 07 00 00       	jmp    102821 <__alltraps>

0010211c <vector99>:
.globl vector99
vector99:
  pushl $0
  10211c:	6a 00                	push   $0x0
  pushl $99
  10211e:	6a 63                	push   $0x63
  jmp __alltraps
  102120:	e9 fc 06 00 00       	jmp    102821 <__alltraps>

00102125 <vector100>:
.globl vector100
vector100:
  pushl $0
  102125:	6a 00                	push   $0x0
  pushl $100
  102127:	6a 64                	push   $0x64
  jmp __alltraps
  102129:	e9 f3 06 00 00       	jmp    102821 <__alltraps>

0010212e <vector101>:
.globl vector101
vector101:
  pushl $0
  10212e:	6a 00                	push   $0x0
  pushl $101
  102130:	6a 65                	push   $0x65
  jmp __alltraps
  102132:	e9 ea 06 00 00       	jmp    102821 <__alltraps>

00102137 <vector102>:
.globl vector102
vector102:
  pushl $0
  102137:	6a 00                	push   $0x0
  pushl $102
  102139:	6a 66                	push   $0x66
  jmp __alltraps
  10213b:	e9 e1 06 00 00       	jmp    102821 <__alltraps>

00102140 <vector103>:
.globl vector103
vector103:
  pushl $0
  102140:	6a 00                	push   $0x0
  pushl $103
  102142:	6a 67                	push   $0x67
  jmp __alltraps
  102144:	e9 d8 06 00 00       	jmp    102821 <__alltraps>

00102149 <vector104>:
.globl vector104
vector104:
  pushl $0
  102149:	6a 00                	push   $0x0
  pushl $104
  10214b:	6a 68                	push   $0x68
  jmp __alltraps
  10214d:	e9 cf 06 00 00       	jmp    102821 <__alltraps>

00102152 <vector105>:
.globl vector105
vector105:
  pushl $0
  102152:	6a 00                	push   $0x0
  pushl $105
  102154:	6a 69                	push   $0x69
  jmp __alltraps
  102156:	e9 c6 06 00 00       	jmp    102821 <__alltraps>

0010215b <vector106>:
.globl vector106
vector106:
  pushl $0
  10215b:	6a 00                	push   $0x0
  pushl $106
  10215d:	6a 6a                	push   $0x6a
  jmp __alltraps
  10215f:	e9 bd 06 00 00       	jmp    102821 <__alltraps>

00102164 <vector107>:
.globl vector107
vector107:
  pushl $0
  102164:	6a 00                	push   $0x0
  pushl $107
  102166:	6a 6b                	push   $0x6b
  jmp __alltraps
  102168:	e9 b4 06 00 00       	jmp    102821 <__alltraps>

0010216d <vector108>:
.globl vector108
vector108:
  pushl $0
  10216d:	6a 00                	push   $0x0
  pushl $108
  10216f:	6a 6c                	push   $0x6c
  jmp __alltraps
  102171:	e9 ab 06 00 00       	jmp    102821 <__alltraps>

00102176 <vector109>:
.globl vector109
vector109:
  pushl $0
  102176:	6a 00                	push   $0x0
  pushl $109
  102178:	6a 6d                	push   $0x6d
  jmp __alltraps
  10217a:	e9 a2 06 00 00       	jmp    102821 <__alltraps>

0010217f <vector110>:
.globl vector110
vector110:
  pushl $0
  10217f:	6a 00                	push   $0x0
  pushl $110
  102181:	6a 6e                	push   $0x6e
  jmp __alltraps
  102183:	e9 99 06 00 00       	jmp    102821 <__alltraps>

00102188 <vector111>:
.globl vector111
vector111:
  pushl $0
  102188:	6a 00                	push   $0x0
  pushl $111
  10218a:	6a 6f                	push   $0x6f
  jmp __alltraps
  10218c:	e9 90 06 00 00       	jmp    102821 <__alltraps>

00102191 <vector112>:
.globl vector112
vector112:
  pushl $0
  102191:	6a 00                	push   $0x0
  pushl $112
  102193:	6a 70                	push   $0x70
  jmp __alltraps
  102195:	e9 87 06 00 00       	jmp    102821 <__alltraps>

0010219a <vector113>:
.globl vector113
vector113:
  pushl $0
  10219a:	6a 00                	push   $0x0
  pushl $113
  10219c:	6a 71                	push   $0x71
  jmp __alltraps
  10219e:	e9 7e 06 00 00       	jmp    102821 <__alltraps>

001021a3 <vector114>:
.globl vector114
vector114:
  pushl $0
  1021a3:	6a 00                	push   $0x0
  pushl $114
  1021a5:	6a 72                	push   $0x72
  jmp __alltraps
  1021a7:	e9 75 06 00 00       	jmp    102821 <__alltraps>

001021ac <vector115>:
.globl vector115
vector115:
  pushl $0
  1021ac:	6a 00                	push   $0x0
  pushl $115
  1021ae:	6a 73                	push   $0x73
  jmp __alltraps
  1021b0:	e9 6c 06 00 00       	jmp    102821 <__alltraps>

001021b5 <vector116>:
.globl vector116
vector116:
  pushl $0
  1021b5:	6a 00                	push   $0x0
  pushl $116
  1021b7:	6a 74                	push   $0x74
  jmp __alltraps
  1021b9:	e9 63 06 00 00       	jmp    102821 <__alltraps>

001021be <vector117>:
.globl vector117
vector117:
  pushl $0
  1021be:	6a 00                	push   $0x0
  pushl $117
  1021c0:	6a 75                	push   $0x75
  jmp __alltraps
  1021c2:	e9 5a 06 00 00       	jmp    102821 <__alltraps>

001021c7 <vector118>:
.globl vector118
vector118:
  pushl $0
  1021c7:	6a 00                	push   $0x0
  pushl $118
  1021c9:	6a 76                	push   $0x76
  jmp __alltraps
  1021cb:	e9 51 06 00 00       	jmp    102821 <__alltraps>

001021d0 <vector119>:
.globl vector119
vector119:
  pushl $0
  1021d0:	6a 00                	push   $0x0
  pushl $119
  1021d2:	6a 77                	push   $0x77
  jmp __alltraps
  1021d4:	e9 48 06 00 00       	jmp    102821 <__alltraps>

001021d9 <vector120>:
.globl vector120
vector120:
  pushl $0
  1021d9:	6a 00                	push   $0x0
  pushl $120
  1021db:	6a 78                	push   $0x78
  jmp __alltraps
  1021dd:	e9 3f 06 00 00       	jmp    102821 <__alltraps>

001021e2 <vector121>:
.globl vector121
vector121:
  pushl $0
  1021e2:	6a 00                	push   $0x0
  pushl $121
  1021e4:	6a 79                	push   $0x79
  jmp __alltraps
  1021e6:	e9 36 06 00 00       	jmp    102821 <__alltraps>

001021eb <vector122>:
.globl vector122
vector122:
  pushl $0
  1021eb:	6a 00                	push   $0x0
  pushl $122
  1021ed:	6a 7a                	push   $0x7a
  jmp __alltraps
  1021ef:	e9 2d 06 00 00       	jmp    102821 <__alltraps>

001021f4 <vector123>:
.globl vector123
vector123:
  pushl $0
  1021f4:	6a 00                	push   $0x0
  pushl $123
  1021f6:	6a 7b                	push   $0x7b
  jmp __alltraps
  1021f8:	e9 24 06 00 00       	jmp    102821 <__alltraps>

001021fd <vector124>:
.globl vector124
vector124:
  pushl $0
  1021fd:	6a 00                	push   $0x0
  pushl $124
  1021ff:	6a 7c                	push   $0x7c
  jmp __alltraps
  102201:	e9 1b 06 00 00       	jmp    102821 <__alltraps>

00102206 <vector125>:
.globl vector125
vector125:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $125
  102208:	6a 7d                	push   $0x7d
  jmp __alltraps
  10220a:	e9 12 06 00 00       	jmp    102821 <__alltraps>

0010220f <vector126>:
.globl vector126
vector126:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $126
  102211:	6a 7e                	push   $0x7e
  jmp __alltraps
  102213:	e9 09 06 00 00       	jmp    102821 <__alltraps>

00102218 <vector127>:
.globl vector127
vector127:
  pushl $0
  102218:	6a 00                	push   $0x0
  pushl $127
  10221a:	6a 7f                	push   $0x7f
  jmp __alltraps
  10221c:	e9 00 06 00 00       	jmp    102821 <__alltraps>

00102221 <vector128>:
.globl vector128
vector128:
  pushl $0
  102221:	6a 00                	push   $0x0
  pushl $128
  102223:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102228:	e9 f4 05 00 00       	jmp    102821 <__alltraps>

0010222d <vector129>:
.globl vector129
vector129:
  pushl $0
  10222d:	6a 00                	push   $0x0
  pushl $129
  10222f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102234:	e9 e8 05 00 00       	jmp    102821 <__alltraps>

00102239 <vector130>:
.globl vector130
vector130:
  pushl $0
  102239:	6a 00                	push   $0x0
  pushl $130
  10223b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102240:	e9 dc 05 00 00       	jmp    102821 <__alltraps>

00102245 <vector131>:
.globl vector131
vector131:
  pushl $0
  102245:	6a 00                	push   $0x0
  pushl $131
  102247:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  10224c:	e9 d0 05 00 00       	jmp    102821 <__alltraps>

00102251 <vector132>:
.globl vector132
vector132:
  pushl $0
  102251:	6a 00                	push   $0x0
  pushl $132
  102253:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102258:	e9 c4 05 00 00       	jmp    102821 <__alltraps>

0010225d <vector133>:
.globl vector133
vector133:
  pushl $0
  10225d:	6a 00                	push   $0x0
  pushl $133
  10225f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102264:	e9 b8 05 00 00       	jmp    102821 <__alltraps>

00102269 <vector134>:
.globl vector134
vector134:
  pushl $0
  102269:	6a 00                	push   $0x0
  pushl $134
  10226b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  102270:	e9 ac 05 00 00       	jmp    102821 <__alltraps>

00102275 <vector135>:
.globl vector135
vector135:
  pushl $0
  102275:	6a 00                	push   $0x0
  pushl $135
  102277:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  10227c:	e9 a0 05 00 00       	jmp    102821 <__alltraps>

00102281 <vector136>:
.globl vector136
vector136:
  pushl $0
  102281:	6a 00                	push   $0x0
  pushl $136
  102283:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102288:	e9 94 05 00 00       	jmp    102821 <__alltraps>

0010228d <vector137>:
.globl vector137
vector137:
  pushl $0
  10228d:	6a 00                	push   $0x0
  pushl $137
  10228f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102294:	e9 88 05 00 00       	jmp    102821 <__alltraps>

00102299 <vector138>:
.globl vector138
vector138:
  pushl $0
  102299:	6a 00                	push   $0x0
  pushl $138
  10229b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1022a0:	e9 7c 05 00 00       	jmp    102821 <__alltraps>

001022a5 <vector139>:
.globl vector139
vector139:
  pushl $0
  1022a5:	6a 00                	push   $0x0
  pushl $139
  1022a7:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1022ac:	e9 70 05 00 00       	jmp    102821 <__alltraps>

001022b1 <vector140>:
.globl vector140
vector140:
  pushl $0
  1022b1:	6a 00                	push   $0x0
  pushl $140
  1022b3:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1022b8:	e9 64 05 00 00       	jmp    102821 <__alltraps>

001022bd <vector141>:
.globl vector141
vector141:
  pushl $0
  1022bd:	6a 00                	push   $0x0
  pushl $141
  1022bf:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1022c4:	e9 58 05 00 00       	jmp    102821 <__alltraps>

001022c9 <vector142>:
.globl vector142
vector142:
  pushl $0
  1022c9:	6a 00                	push   $0x0
  pushl $142
  1022cb:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1022d0:	e9 4c 05 00 00       	jmp    102821 <__alltraps>

001022d5 <vector143>:
.globl vector143
vector143:
  pushl $0
  1022d5:	6a 00                	push   $0x0
  pushl $143
  1022d7:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1022dc:	e9 40 05 00 00       	jmp    102821 <__alltraps>

001022e1 <vector144>:
.globl vector144
vector144:
  pushl $0
  1022e1:	6a 00                	push   $0x0
  pushl $144
  1022e3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1022e8:	e9 34 05 00 00       	jmp    102821 <__alltraps>

001022ed <vector145>:
.globl vector145
vector145:
  pushl $0
  1022ed:	6a 00                	push   $0x0
  pushl $145
  1022ef:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1022f4:	e9 28 05 00 00       	jmp    102821 <__alltraps>

001022f9 <vector146>:
.globl vector146
vector146:
  pushl $0
  1022f9:	6a 00                	push   $0x0
  pushl $146
  1022fb:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102300:	e9 1c 05 00 00       	jmp    102821 <__alltraps>

00102305 <vector147>:
.globl vector147
vector147:
  pushl $0
  102305:	6a 00                	push   $0x0
  pushl $147
  102307:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10230c:	e9 10 05 00 00       	jmp    102821 <__alltraps>

00102311 <vector148>:
.globl vector148
vector148:
  pushl $0
  102311:	6a 00                	push   $0x0
  pushl $148
  102313:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102318:	e9 04 05 00 00       	jmp    102821 <__alltraps>

0010231d <vector149>:
.globl vector149
vector149:
  pushl $0
  10231d:	6a 00                	push   $0x0
  pushl $149
  10231f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102324:	e9 f8 04 00 00       	jmp    102821 <__alltraps>

00102329 <vector150>:
.globl vector150
vector150:
  pushl $0
  102329:	6a 00                	push   $0x0
  pushl $150
  10232b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102330:	e9 ec 04 00 00       	jmp    102821 <__alltraps>

00102335 <vector151>:
.globl vector151
vector151:
  pushl $0
  102335:	6a 00                	push   $0x0
  pushl $151
  102337:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10233c:	e9 e0 04 00 00       	jmp    102821 <__alltraps>

00102341 <vector152>:
.globl vector152
vector152:
  pushl $0
  102341:	6a 00                	push   $0x0
  pushl $152
  102343:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102348:	e9 d4 04 00 00       	jmp    102821 <__alltraps>

0010234d <vector153>:
.globl vector153
vector153:
  pushl $0
  10234d:	6a 00                	push   $0x0
  pushl $153
  10234f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102354:	e9 c8 04 00 00       	jmp    102821 <__alltraps>

00102359 <vector154>:
.globl vector154
vector154:
  pushl $0
  102359:	6a 00                	push   $0x0
  pushl $154
  10235b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102360:	e9 bc 04 00 00       	jmp    102821 <__alltraps>

00102365 <vector155>:
.globl vector155
vector155:
  pushl $0
  102365:	6a 00                	push   $0x0
  pushl $155
  102367:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  10236c:	e9 b0 04 00 00       	jmp    102821 <__alltraps>

00102371 <vector156>:
.globl vector156
vector156:
  pushl $0
  102371:	6a 00                	push   $0x0
  pushl $156
  102373:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102378:	e9 a4 04 00 00       	jmp    102821 <__alltraps>

0010237d <vector157>:
.globl vector157
vector157:
  pushl $0
  10237d:	6a 00                	push   $0x0
  pushl $157
  10237f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102384:	e9 98 04 00 00       	jmp    102821 <__alltraps>

00102389 <vector158>:
.globl vector158
vector158:
  pushl $0
  102389:	6a 00                	push   $0x0
  pushl $158
  10238b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  102390:	e9 8c 04 00 00       	jmp    102821 <__alltraps>

00102395 <vector159>:
.globl vector159
vector159:
  pushl $0
  102395:	6a 00                	push   $0x0
  pushl $159
  102397:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  10239c:	e9 80 04 00 00       	jmp    102821 <__alltraps>

001023a1 <vector160>:
.globl vector160
vector160:
  pushl $0
  1023a1:	6a 00                	push   $0x0
  pushl $160
  1023a3:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1023a8:	e9 74 04 00 00       	jmp    102821 <__alltraps>

001023ad <vector161>:
.globl vector161
vector161:
  pushl $0
  1023ad:	6a 00                	push   $0x0
  pushl $161
  1023af:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1023b4:	e9 68 04 00 00       	jmp    102821 <__alltraps>

001023b9 <vector162>:
.globl vector162
vector162:
  pushl $0
  1023b9:	6a 00                	push   $0x0
  pushl $162
  1023bb:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1023c0:	e9 5c 04 00 00       	jmp    102821 <__alltraps>

001023c5 <vector163>:
.globl vector163
vector163:
  pushl $0
  1023c5:	6a 00                	push   $0x0
  pushl $163
  1023c7:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1023cc:	e9 50 04 00 00       	jmp    102821 <__alltraps>

001023d1 <vector164>:
.globl vector164
vector164:
  pushl $0
  1023d1:	6a 00                	push   $0x0
  pushl $164
  1023d3:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1023d8:	e9 44 04 00 00       	jmp    102821 <__alltraps>

001023dd <vector165>:
.globl vector165
vector165:
  pushl $0
  1023dd:	6a 00                	push   $0x0
  pushl $165
  1023df:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1023e4:	e9 38 04 00 00       	jmp    102821 <__alltraps>

001023e9 <vector166>:
.globl vector166
vector166:
  pushl $0
  1023e9:	6a 00                	push   $0x0
  pushl $166
  1023eb:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1023f0:	e9 2c 04 00 00       	jmp    102821 <__alltraps>

001023f5 <vector167>:
.globl vector167
vector167:
  pushl $0
  1023f5:	6a 00                	push   $0x0
  pushl $167
  1023f7:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1023fc:	e9 20 04 00 00       	jmp    102821 <__alltraps>

00102401 <vector168>:
.globl vector168
vector168:
  pushl $0
  102401:	6a 00                	push   $0x0
  pushl $168
  102403:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102408:	e9 14 04 00 00       	jmp    102821 <__alltraps>

0010240d <vector169>:
.globl vector169
vector169:
  pushl $0
  10240d:	6a 00                	push   $0x0
  pushl $169
  10240f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102414:	e9 08 04 00 00       	jmp    102821 <__alltraps>

00102419 <vector170>:
.globl vector170
vector170:
  pushl $0
  102419:	6a 00                	push   $0x0
  pushl $170
  10241b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102420:	e9 fc 03 00 00       	jmp    102821 <__alltraps>

00102425 <vector171>:
.globl vector171
vector171:
  pushl $0
  102425:	6a 00                	push   $0x0
  pushl $171
  102427:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10242c:	e9 f0 03 00 00       	jmp    102821 <__alltraps>

00102431 <vector172>:
.globl vector172
vector172:
  pushl $0
  102431:	6a 00                	push   $0x0
  pushl $172
  102433:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102438:	e9 e4 03 00 00       	jmp    102821 <__alltraps>

0010243d <vector173>:
.globl vector173
vector173:
  pushl $0
  10243d:	6a 00                	push   $0x0
  pushl $173
  10243f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102444:	e9 d8 03 00 00       	jmp    102821 <__alltraps>

00102449 <vector174>:
.globl vector174
vector174:
  pushl $0
  102449:	6a 00                	push   $0x0
  pushl $174
  10244b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102450:	e9 cc 03 00 00       	jmp    102821 <__alltraps>

00102455 <vector175>:
.globl vector175
vector175:
  pushl $0
  102455:	6a 00                	push   $0x0
  pushl $175
  102457:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  10245c:	e9 c0 03 00 00       	jmp    102821 <__alltraps>

00102461 <vector176>:
.globl vector176
vector176:
  pushl $0
  102461:	6a 00                	push   $0x0
  pushl $176
  102463:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102468:	e9 b4 03 00 00       	jmp    102821 <__alltraps>

0010246d <vector177>:
.globl vector177
vector177:
  pushl $0
  10246d:	6a 00                	push   $0x0
  pushl $177
  10246f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102474:	e9 a8 03 00 00       	jmp    102821 <__alltraps>

00102479 <vector178>:
.globl vector178
vector178:
  pushl $0
  102479:	6a 00                	push   $0x0
  pushl $178
  10247b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  102480:	e9 9c 03 00 00       	jmp    102821 <__alltraps>

00102485 <vector179>:
.globl vector179
vector179:
  pushl $0
  102485:	6a 00                	push   $0x0
  pushl $179
  102487:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  10248c:	e9 90 03 00 00       	jmp    102821 <__alltraps>

00102491 <vector180>:
.globl vector180
vector180:
  pushl $0
  102491:	6a 00                	push   $0x0
  pushl $180
  102493:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102498:	e9 84 03 00 00       	jmp    102821 <__alltraps>

0010249d <vector181>:
.globl vector181
vector181:
  pushl $0
  10249d:	6a 00                	push   $0x0
  pushl $181
  10249f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1024a4:	e9 78 03 00 00       	jmp    102821 <__alltraps>

001024a9 <vector182>:
.globl vector182
vector182:
  pushl $0
  1024a9:	6a 00                	push   $0x0
  pushl $182
  1024ab:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1024b0:	e9 6c 03 00 00       	jmp    102821 <__alltraps>

001024b5 <vector183>:
.globl vector183
vector183:
  pushl $0
  1024b5:	6a 00                	push   $0x0
  pushl $183
  1024b7:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1024bc:	e9 60 03 00 00       	jmp    102821 <__alltraps>

001024c1 <vector184>:
.globl vector184
vector184:
  pushl $0
  1024c1:	6a 00                	push   $0x0
  pushl $184
  1024c3:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1024c8:	e9 54 03 00 00       	jmp    102821 <__alltraps>

001024cd <vector185>:
.globl vector185
vector185:
  pushl $0
  1024cd:	6a 00                	push   $0x0
  pushl $185
  1024cf:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1024d4:	e9 48 03 00 00       	jmp    102821 <__alltraps>

001024d9 <vector186>:
.globl vector186
vector186:
  pushl $0
  1024d9:	6a 00                	push   $0x0
  pushl $186
  1024db:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1024e0:	e9 3c 03 00 00       	jmp    102821 <__alltraps>

001024e5 <vector187>:
.globl vector187
vector187:
  pushl $0
  1024e5:	6a 00                	push   $0x0
  pushl $187
  1024e7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1024ec:	e9 30 03 00 00       	jmp    102821 <__alltraps>

001024f1 <vector188>:
.globl vector188
vector188:
  pushl $0
  1024f1:	6a 00                	push   $0x0
  pushl $188
  1024f3:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1024f8:	e9 24 03 00 00       	jmp    102821 <__alltraps>

001024fd <vector189>:
.globl vector189
vector189:
  pushl $0
  1024fd:	6a 00                	push   $0x0
  pushl $189
  1024ff:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102504:	e9 18 03 00 00       	jmp    102821 <__alltraps>

00102509 <vector190>:
.globl vector190
vector190:
  pushl $0
  102509:	6a 00                	push   $0x0
  pushl $190
  10250b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102510:	e9 0c 03 00 00       	jmp    102821 <__alltraps>

00102515 <vector191>:
.globl vector191
vector191:
  pushl $0
  102515:	6a 00                	push   $0x0
  pushl $191
  102517:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10251c:	e9 00 03 00 00       	jmp    102821 <__alltraps>

00102521 <vector192>:
.globl vector192
vector192:
  pushl $0
  102521:	6a 00                	push   $0x0
  pushl $192
  102523:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102528:	e9 f4 02 00 00       	jmp    102821 <__alltraps>

0010252d <vector193>:
.globl vector193
vector193:
  pushl $0
  10252d:	6a 00                	push   $0x0
  pushl $193
  10252f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102534:	e9 e8 02 00 00       	jmp    102821 <__alltraps>

00102539 <vector194>:
.globl vector194
vector194:
  pushl $0
  102539:	6a 00                	push   $0x0
  pushl $194
  10253b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102540:	e9 dc 02 00 00       	jmp    102821 <__alltraps>

00102545 <vector195>:
.globl vector195
vector195:
  pushl $0
  102545:	6a 00                	push   $0x0
  pushl $195
  102547:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  10254c:	e9 d0 02 00 00       	jmp    102821 <__alltraps>

00102551 <vector196>:
.globl vector196
vector196:
  pushl $0
  102551:	6a 00                	push   $0x0
  pushl $196
  102553:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102558:	e9 c4 02 00 00       	jmp    102821 <__alltraps>

0010255d <vector197>:
.globl vector197
vector197:
  pushl $0
  10255d:	6a 00                	push   $0x0
  pushl $197
  10255f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102564:	e9 b8 02 00 00       	jmp    102821 <__alltraps>

00102569 <vector198>:
.globl vector198
vector198:
  pushl $0
  102569:	6a 00                	push   $0x0
  pushl $198
  10256b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  102570:	e9 ac 02 00 00       	jmp    102821 <__alltraps>

00102575 <vector199>:
.globl vector199
vector199:
  pushl $0
  102575:	6a 00                	push   $0x0
  pushl $199
  102577:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  10257c:	e9 a0 02 00 00       	jmp    102821 <__alltraps>

00102581 <vector200>:
.globl vector200
vector200:
  pushl $0
  102581:	6a 00                	push   $0x0
  pushl $200
  102583:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102588:	e9 94 02 00 00       	jmp    102821 <__alltraps>

0010258d <vector201>:
.globl vector201
vector201:
  pushl $0
  10258d:	6a 00                	push   $0x0
  pushl $201
  10258f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102594:	e9 88 02 00 00       	jmp    102821 <__alltraps>

00102599 <vector202>:
.globl vector202
vector202:
  pushl $0
  102599:	6a 00                	push   $0x0
  pushl $202
  10259b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1025a0:	e9 7c 02 00 00       	jmp    102821 <__alltraps>

001025a5 <vector203>:
.globl vector203
vector203:
  pushl $0
  1025a5:	6a 00                	push   $0x0
  pushl $203
  1025a7:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1025ac:	e9 70 02 00 00       	jmp    102821 <__alltraps>

001025b1 <vector204>:
.globl vector204
vector204:
  pushl $0
  1025b1:	6a 00                	push   $0x0
  pushl $204
  1025b3:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1025b8:	e9 64 02 00 00       	jmp    102821 <__alltraps>

001025bd <vector205>:
.globl vector205
vector205:
  pushl $0
  1025bd:	6a 00                	push   $0x0
  pushl $205
  1025bf:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1025c4:	e9 58 02 00 00       	jmp    102821 <__alltraps>

001025c9 <vector206>:
.globl vector206
vector206:
  pushl $0
  1025c9:	6a 00                	push   $0x0
  pushl $206
  1025cb:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1025d0:	e9 4c 02 00 00       	jmp    102821 <__alltraps>

001025d5 <vector207>:
.globl vector207
vector207:
  pushl $0
  1025d5:	6a 00                	push   $0x0
  pushl $207
  1025d7:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1025dc:	e9 40 02 00 00       	jmp    102821 <__alltraps>

001025e1 <vector208>:
.globl vector208
vector208:
  pushl $0
  1025e1:	6a 00                	push   $0x0
  pushl $208
  1025e3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1025e8:	e9 34 02 00 00       	jmp    102821 <__alltraps>

001025ed <vector209>:
.globl vector209
vector209:
  pushl $0
  1025ed:	6a 00                	push   $0x0
  pushl $209
  1025ef:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1025f4:	e9 28 02 00 00       	jmp    102821 <__alltraps>

001025f9 <vector210>:
.globl vector210
vector210:
  pushl $0
  1025f9:	6a 00                	push   $0x0
  pushl $210
  1025fb:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102600:	e9 1c 02 00 00       	jmp    102821 <__alltraps>

00102605 <vector211>:
.globl vector211
vector211:
  pushl $0
  102605:	6a 00                	push   $0x0
  pushl $211
  102607:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10260c:	e9 10 02 00 00       	jmp    102821 <__alltraps>

00102611 <vector212>:
.globl vector212
vector212:
  pushl $0
  102611:	6a 00                	push   $0x0
  pushl $212
  102613:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102618:	e9 04 02 00 00       	jmp    102821 <__alltraps>

0010261d <vector213>:
.globl vector213
vector213:
  pushl $0
  10261d:	6a 00                	push   $0x0
  pushl $213
  10261f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102624:	e9 f8 01 00 00       	jmp    102821 <__alltraps>

00102629 <vector214>:
.globl vector214
vector214:
  pushl $0
  102629:	6a 00                	push   $0x0
  pushl $214
  10262b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102630:	e9 ec 01 00 00       	jmp    102821 <__alltraps>

00102635 <vector215>:
.globl vector215
vector215:
  pushl $0
  102635:	6a 00                	push   $0x0
  pushl $215
  102637:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10263c:	e9 e0 01 00 00       	jmp    102821 <__alltraps>

00102641 <vector216>:
.globl vector216
vector216:
  pushl $0
  102641:	6a 00                	push   $0x0
  pushl $216
  102643:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102648:	e9 d4 01 00 00       	jmp    102821 <__alltraps>

0010264d <vector217>:
.globl vector217
vector217:
  pushl $0
  10264d:	6a 00                	push   $0x0
  pushl $217
  10264f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102654:	e9 c8 01 00 00       	jmp    102821 <__alltraps>

00102659 <vector218>:
.globl vector218
vector218:
  pushl $0
  102659:	6a 00                	push   $0x0
  pushl $218
  10265b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102660:	e9 bc 01 00 00       	jmp    102821 <__alltraps>

00102665 <vector219>:
.globl vector219
vector219:
  pushl $0
  102665:	6a 00                	push   $0x0
  pushl $219
  102667:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  10266c:	e9 b0 01 00 00       	jmp    102821 <__alltraps>

00102671 <vector220>:
.globl vector220
vector220:
  pushl $0
  102671:	6a 00                	push   $0x0
  pushl $220
  102673:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102678:	e9 a4 01 00 00       	jmp    102821 <__alltraps>

0010267d <vector221>:
.globl vector221
vector221:
  pushl $0
  10267d:	6a 00                	push   $0x0
  pushl $221
  10267f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102684:	e9 98 01 00 00       	jmp    102821 <__alltraps>

00102689 <vector222>:
.globl vector222
vector222:
  pushl $0
  102689:	6a 00                	push   $0x0
  pushl $222
  10268b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102690:	e9 8c 01 00 00       	jmp    102821 <__alltraps>

00102695 <vector223>:
.globl vector223
vector223:
  pushl $0
  102695:	6a 00                	push   $0x0
  pushl $223
  102697:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  10269c:	e9 80 01 00 00       	jmp    102821 <__alltraps>

001026a1 <vector224>:
.globl vector224
vector224:
  pushl $0
  1026a1:	6a 00                	push   $0x0
  pushl $224
  1026a3:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1026a8:	e9 74 01 00 00       	jmp    102821 <__alltraps>

001026ad <vector225>:
.globl vector225
vector225:
  pushl $0
  1026ad:	6a 00                	push   $0x0
  pushl $225
  1026af:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1026b4:	e9 68 01 00 00       	jmp    102821 <__alltraps>

001026b9 <vector226>:
.globl vector226
vector226:
  pushl $0
  1026b9:	6a 00                	push   $0x0
  pushl $226
  1026bb:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1026c0:	e9 5c 01 00 00       	jmp    102821 <__alltraps>

001026c5 <vector227>:
.globl vector227
vector227:
  pushl $0
  1026c5:	6a 00                	push   $0x0
  pushl $227
  1026c7:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  1026cc:	e9 50 01 00 00       	jmp    102821 <__alltraps>

001026d1 <vector228>:
.globl vector228
vector228:
  pushl $0
  1026d1:	6a 00                	push   $0x0
  pushl $228
  1026d3:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  1026d8:	e9 44 01 00 00       	jmp    102821 <__alltraps>

001026dd <vector229>:
.globl vector229
vector229:
  pushl $0
  1026dd:	6a 00                	push   $0x0
  pushl $229
  1026df:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  1026e4:	e9 38 01 00 00       	jmp    102821 <__alltraps>

001026e9 <vector230>:
.globl vector230
vector230:
  pushl $0
  1026e9:	6a 00                	push   $0x0
  pushl $230
  1026eb:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  1026f0:	e9 2c 01 00 00       	jmp    102821 <__alltraps>

001026f5 <vector231>:
.globl vector231
vector231:
  pushl $0
  1026f5:	6a 00                	push   $0x0
  pushl $231
  1026f7:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  1026fc:	e9 20 01 00 00       	jmp    102821 <__alltraps>

00102701 <vector232>:
.globl vector232
vector232:
  pushl $0
  102701:	6a 00                	push   $0x0
  pushl $232
  102703:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102708:	e9 14 01 00 00       	jmp    102821 <__alltraps>

0010270d <vector233>:
.globl vector233
vector233:
  pushl $0
  10270d:	6a 00                	push   $0x0
  pushl $233
  10270f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102714:	e9 08 01 00 00       	jmp    102821 <__alltraps>

00102719 <vector234>:
.globl vector234
vector234:
  pushl $0
  102719:	6a 00                	push   $0x0
  pushl $234
  10271b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102720:	e9 fc 00 00 00       	jmp    102821 <__alltraps>

00102725 <vector235>:
.globl vector235
vector235:
  pushl $0
  102725:	6a 00                	push   $0x0
  pushl $235
  102727:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10272c:	e9 f0 00 00 00       	jmp    102821 <__alltraps>

00102731 <vector236>:
.globl vector236
vector236:
  pushl $0
  102731:	6a 00                	push   $0x0
  pushl $236
  102733:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102738:	e9 e4 00 00 00       	jmp    102821 <__alltraps>

0010273d <vector237>:
.globl vector237
vector237:
  pushl $0
  10273d:	6a 00                	push   $0x0
  pushl $237
  10273f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102744:	e9 d8 00 00 00       	jmp    102821 <__alltraps>

00102749 <vector238>:
.globl vector238
vector238:
  pushl $0
  102749:	6a 00                	push   $0x0
  pushl $238
  10274b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102750:	e9 cc 00 00 00       	jmp    102821 <__alltraps>

00102755 <vector239>:
.globl vector239
vector239:
  pushl $0
  102755:	6a 00                	push   $0x0
  pushl $239
  102757:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  10275c:	e9 c0 00 00 00       	jmp    102821 <__alltraps>

00102761 <vector240>:
.globl vector240
vector240:
  pushl $0
  102761:	6a 00                	push   $0x0
  pushl $240
  102763:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102768:	e9 b4 00 00 00       	jmp    102821 <__alltraps>

0010276d <vector241>:
.globl vector241
vector241:
  pushl $0
  10276d:	6a 00                	push   $0x0
  pushl $241
  10276f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102774:	e9 a8 00 00 00       	jmp    102821 <__alltraps>

00102779 <vector242>:
.globl vector242
vector242:
  pushl $0
  102779:	6a 00                	push   $0x0
  pushl $242
  10277b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102780:	e9 9c 00 00 00       	jmp    102821 <__alltraps>

00102785 <vector243>:
.globl vector243
vector243:
  pushl $0
  102785:	6a 00                	push   $0x0
  pushl $243
  102787:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  10278c:	e9 90 00 00 00       	jmp    102821 <__alltraps>

00102791 <vector244>:
.globl vector244
vector244:
  pushl $0
  102791:	6a 00                	push   $0x0
  pushl $244
  102793:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102798:	e9 84 00 00 00       	jmp    102821 <__alltraps>

0010279d <vector245>:
.globl vector245
vector245:
  pushl $0
  10279d:	6a 00                	push   $0x0
  pushl $245
  10279f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  1027a4:	e9 78 00 00 00       	jmp    102821 <__alltraps>

001027a9 <vector246>:
.globl vector246
vector246:
  pushl $0
  1027a9:	6a 00                	push   $0x0
  pushl $246
  1027ab:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  1027b0:	e9 6c 00 00 00       	jmp    102821 <__alltraps>

001027b5 <vector247>:
.globl vector247
vector247:
  pushl $0
  1027b5:	6a 00                	push   $0x0
  pushl $247
  1027b7:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  1027bc:	e9 60 00 00 00       	jmp    102821 <__alltraps>

001027c1 <vector248>:
.globl vector248
vector248:
  pushl $0
  1027c1:	6a 00                	push   $0x0
  pushl $248
  1027c3:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  1027c8:	e9 54 00 00 00       	jmp    102821 <__alltraps>

001027cd <vector249>:
.globl vector249
vector249:
  pushl $0
  1027cd:	6a 00                	push   $0x0
  pushl $249
  1027cf:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  1027d4:	e9 48 00 00 00       	jmp    102821 <__alltraps>

001027d9 <vector250>:
.globl vector250
vector250:
  pushl $0
  1027d9:	6a 00                	push   $0x0
  pushl $250
  1027db:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  1027e0:	e9 3c 00 00 00       	jmp    102821 <__alltraps>

001027e5 <vector251>:
.globl vector251
vector251:
  pushl $0
  1027e5:	6a 00                	push   $0x0
  pushl $251
  1027e7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  1027ec:	e9 30 00 00 00       	jmp    102821 <__alltraps>

001027f1 <vector252>:
.globl vector252
vector252:
  pushl $0
  1027f1:	6a 00                	push   $0x0
  pushl $252
  1027f3:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  1027f8:	e9 24 00 00 00       	jmp    102821 <__alltraps>

001027fd <vector253>:
.globl vector253
vector253:
  pushl $0
  1027fd:	6a 00                	push   $0x0
  pushl $253
  1027ff:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102804:	e9 18 00 00 00       	jmp    102821 <__alltraps>

00102809 <vector254>:
.globl vector254
vector254:
  pushl $0
  102809:	6a 00                	push   $0x0
  pushl $254
  10280b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102810:	e9 0c 00 00 00       	jmp    102821 <__alltraps>

00102815 <vector255>:
.globl vector255
vector255:
  pushl $0
  102815:	6a 00                	push   $0x0
  pushl $255
  102817:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  10281c:	e9 00 00 00 00       	jmp    102821 <__alltraps>

00102821 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102821:	1e                   	push   %ds
    pushl %es
  102822:	06                   	push   %es
    pushl %fs
  102823:	0f a0                	push   %fs
    pushl %gs
  102825:	0f a8                	push   %gs
    pushal
  102827:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102828:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  10282d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  10282f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102831:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102832:	e8 64 f5 ff ff       	call   101d9b <trap>

    # pop the pushed stack pointer
    popl %esp
  102837:	5c                   	pop    %esp

00102838 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102838:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102839:	0f a9                	pop    %gs
    popl %fs
  10283b:	0f a1                	pop    %fs
    popl %es
  10283d:	07                   	pop    %es
    popl %ds
  10283e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10283f:	83 c4 08             	add    $0x8,%esp
    iret
  102842:	cf                   	iret   

00102843 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102843:	55                   	push   %ebp
  102844:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102846:	8b 45 08             	mov    0x8(%ebp),%eax
  102849:	8b 15 18 cf 11 00    	mov    0x11cf18,%edx
  10284f:	29 d0                	sub    %edx,%eax
  102851:	c1 f8 02             	sar    $0x2,%eax
  102854:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10285a:	5d                   	pop    %ebp
  10285b:	c3                   	ret    

0010285c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  10285c:	55                   	push   %ebp
  10285d:	89 e5                	mov    %esp,%ebp
  10285f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102862:	8b 45 08             	mov    0x8(%ebp),%eax
  102865:	89 04 24             	mov    %eax,(%esp)
  102868:	e8 d6 ff ff ff       	call   102843 <page2ppn>
  10286d:	c1 e0 0c             	shl    $0xc,%eax
}
  102870:	c9                   	leave  
  102871:	c3                   	ret    

00102872 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102872:	55                   	push   %ebp
  102873:	89 e5                	mov    %esp,%ebp
  102875:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102878:	8b 45 08             	mov    0x8(%ebp),%eax
  10287b:	c1 e8 0c             	shr    $0xc,%eax
  10287e:	89 c2                	mov    %eax,%edx
  102880:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102885:	39 c2                	cmp    %eax,%edx
  102887:	72 1c                	jb     1028a5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102889:	c7 44 24 08 90 74 10 	movl   $0x107490,0x8(%esp)
  102890:	00 
  102891:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102898:	00 
  102899:	c7 04 24 af 74 10 00 	movl   $0x1074af,(%esp)
  1028a0:	e8 49 db ff ff       	call   1003ee <__panic>
    }
    return &pages[PPN(pa)];
  1028a5:	8b 0d 18 cf 11 00    	mov    0x11cf18,%ecx
  1028ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1028ae:	c1 e8 0c             	shr    $0xc,%eax
  1028b1:	89 c2                	mov    %eax,%edx
  1028b3:	89 d0                	mov    %edx,%eax
  1028b5:	c1 e0 02             	shl    $0x2,%eax
  1028b8:	01 d0                	add    %edx,%eax
  1028ba:	c1 e0 02             	shl    $0x2,%eax
  1028bd:	01 c8                	add    %ecx,%eax
}
  1028bf:	c9                   	leave  
  1028c0:	c3                   	ret    

001028c1 <page2kva>:

static inline void *
page2kva(struct Page *page) {
  1028c1:	55                   	push   %ebp
  1028c2:	89 e5                	mov    %esp,%ebp
  1028c4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  1028c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1028ca:	89 04 24             	mov    %eax,(%esp)
  1028cd:	e8 8a ff ff ff       	call   10285c <page2pa>
  1028d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1028d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028d8:	c1 e8 0c             	shr    $0xc,%eax
  1028db:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1028de:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  1028e3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  1028e6:	72 23                	jb     10290b <page2kva+0x4a>
  1028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1028eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1028ef:	c7 44 24 08 c0 74 10 	movl   $0x1074c0,0x8(%esp)
  1028f6:	00 
  1028f7:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
  1028fe:	00 
  1028ff:	c7 04 24 af 74 10 00 	movl   $0x1074af,(%esp)
  102906:	e8 e3 da ff ff       	call   1003ee <__panic>
  10290b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10290e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102913:	c9                   	leave  
  102914:	c3                   	ret    

00102915 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102915:	55                   	push   %ebp
  102916:	89 e5                	mov    %esp,%ebp
  102918:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  10291b:	8b 45 08             	mov    0x8(%ebp),%eax
  10291e:	83 e0 01             	and    $0x1,%eax
  102921:	85 c0                	test   %eax,%eax
  102923:	75 1c                	jne    102941 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102925:	c7 44 24 08 e4 74 10 	movl   $0x1074e4,0x8(%esp)
  10292c:	00 
  10292d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  102934:	00 
  102935:	c7 04 24 af 74 10 00 	movl   $0x1074af,(%esp)
  10293c:	e8 ad da ff ff       	call   1003ee <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102941:	8b 45 08             	mov    0x8(%ebp),%eax
  102944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102949:	89 04 24             	mov    %eax,(%esp)
  10294c:	e8 21 ff ff ff       	call   102872 <pa2page>
}
  102951:	c9                   	leave  
  102952:	c3                   	ret    

00102953 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102953:	55                   	push   %ebp
  102954:	89 e5                	mov    %esp,%ebp
  102956:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102959:	8b 45 08             	mov    0x8(%ebp),%eax
  10295c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102961:	89 04 24             	mov    %eax,(%esp)
  102964:	e8 09 ff ff ff       	call   102872 <pa2page>
}
  102969:	c9                   	leave  
  10296a:	c3                   	ret    

0010296b <page_ref>:

static inline int
page_ref(struct Page *page) {
  10296b:	55                   	push   %ebp
  10296c:	89 e5                	mov    %esp,%ebp
    return page->ref;
  10296e:	8b 45 08             	mov    0x8(%ebp),%eax
  102971:	8b 00                	mov    (%eax),%eax
}
  102973:	5d                   	pop    %ebp
  102974:	c3                   	ret    

00102975 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102975:	55                   	push   %ebp
  102976:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102978:	8b 45 08             	mov    0x8(%ebp),%eax
  10297b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10297e:	89 10                	mov    %edx,(%eax)
}
  102980:	90                   	nop
  102981:	5d                   	pop    %ebp
  102982:	c3                   	ret    

00102983 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102983:	55                   	push   %ebp
  102984:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102986:	8b 45 08             	mov    0x8(%ebp),%eax
  102989:	8b 00                	mov    (%eax),%eax
  10298b:	8d 50 01             	lea    0x1(%eax),%edx
  10298e:	8b 45 08             	mov    0x8(%ebp),%eax
  102991:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102993:	8b 45 08             	mov    0x8(%ebp),%eax
  102996:	8b 00                	mov    (%eax),%eax
}
  102998:	5d                   	pop    %ebp
  102999:	c3                   	ret    

0010299a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  10299a:	55                   	push   %ebp
  10299b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  10299d:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a0:	8b 00                	mov    (%eax),%eax
  1029a2:	8d 50 ff             	lea    -0x1(%eax),%edx
  1029a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1029a8:	89 10                	mov    %edx,(%eax)
    return page->ref;
  1029aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1029ad:	8b 00                	mov    (%eax),%eax
}
  1029af:	5d                   	pop    %ebp
  1029b0:	c3                   	ret    

001029b1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  1029b1:	55                   	push   %ebp
  1029b2:	89 e5                	mov    %esp,%ebp
  1029b4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  1029b7:	9c                   	pushf  
  1029b8:	58                   	pop    %eax
  1029b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  1029bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  1029bf:	25 00 02 00 00       	and    $0x200,%eax
  1029c4:	85 c0                	test   %eax,%eax
  1029c6:	74 0c                	je     1029d4 <__intr_save+0x23>
        intr_disable();
  1029c8:	e8 b1 ee ff ff       	call   10187e <intr_disable>
        return 1;
  1029cd:	b8 01 00 00 00       	mov    $0x1,%eax
  1029d2:	eb 05                	jmp    1029d9 <__intr_save+0x28>
    }
    return 0;
  1029d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1029d9:	c9                   	leave  
  1029da:	c3                   	ret    

001029db <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  1029db:	55                   	push   %ebp
  1029dc:	89 e5                	mov    %esp,%ebp
  1029de:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  1029e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1029e5:	74 05                	je     1029ec <__intr_restore+0x11>
        intr_enable();
  1029e7:	e8 8b ee ff ff       	call   101877 <intr_enable>
    }
}
  1029ec:	90                   	nop
  1029ed:	c9                   	leave  
  1029ee:	c3                   	ret    

001029ef <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  1029ef:	55                   	push   %ebp
  1029f0:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  1029f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1029f5:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  1029f8:	b8 23 00 00 00       	mov    $0x23,%eax
  1029fd:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  1029ff:	b8 23 00 00 00       	mov    $0x23,%eax
  102a04:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102a06:	b8 10 00 00 00       	mov    $0x10,%eax
  102a0b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102a0d:	b8 10 00 00 00       	mov    $0x10,%eax
  102a12:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102a14:	b8 10 00 00 00       	mov    $0x10,%eax
  102a19:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102a1b:	ea 22 2a 10 00 08 00 	ljmp   $0x8,$0x102a22
}
  102a22:	90                   	nop
  102a23:	5d                   	pop    %ebp
  102a24:	c3                   	ret    

00102a25 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102a25:	55                   	push   %ebp
  102a26:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102a28:	8b 45 08             	mov    0x8(%ebp),%eax
  102a2b:	a3 a4 ce 11 00       	mov    %eax,0x11cea4
}
  102a30:	90                   	nop
  102a31:	5d                   	pop    %ebp
  102a32:	c3                   	ret    

00102a33 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102a33:	55                   	push   %ebp
  102a34:	89 e5                	mov    %esp,%ebp
  102a36:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102a39:	b8 00 90 11 00       	mov    $0x119000,%eax
  102a3e:	89 04 24             	mov    %eax,(%esp)
  102a41:	e8 df ff ff ff       	call   102a25 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102a46:	66 c7 05 a8 ce 11 00 	movw   $0x10,0x11cea8
  102a4d:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102a4f:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  102a56:	68 00 
  102a58:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102a5d:	0f b7 c0             	movzwl %ax,%eax
  102a60:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  102a66:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102a6b:	c1 e8 10             	shr    $0x10,%eax
  102a6e:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  102a73:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102a7a:	24 f0                	and    $0xf0,%al
  102a7c:	0c 09                	or     $0x9,%al
  102a7e:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102a83:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102a8a:	24 ef                	and    $0xef,%al
  102a8c:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102a91:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102a98:	24 9f                	and    $0x9f,%al
  102a9a:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102a9f:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  102aa6:	0c 80                	or     $0x80,%al
  102aa8:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  102aad:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102ab4:	24 f0                	and    $0xf0,%al
  102ab6:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102abb:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102ac2:	24 ef                	and    $0xef,%al
  102ac4:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102ac9:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102ad0:	24 df                	and    $0xdf,%al
  102ad2:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102ad7:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102ade:	0c 40                	or     $0x40,%al
  102ae0:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102ae5:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  102aec:	24 7f                	and    $0x7f,%al
  102aee:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  102af3:	b8 a0 ce 11 00       	mov    $0x11cea0,%eax
  102af8:	c1 e8 18             	shr    $0x18,%eax
  102afb:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102b00:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  102b07:	e8 e3 fe ff ff       	call   1029ef <lgdt>
  102b0c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102b12:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102b16:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102b19:	90                   	nop
  102b1a:	c9                   	leave  
  102b1b:	c3                   	ret    

00102b1c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102b1c:	55                   	push   %ebp
  102b1d:	89 e5                	mov    %esp,%ebp
  102b1f:	83 ec 18             	sub    $0x18,%esp
    // pmm_manager = &default_pmm_manager;
    // cprintf("memory management: %s\n", pmm_manager->name);
    // pmm_manager->init();
    pmm_manager = &buddy_pmm_manager;
  102b22:	c7 05 10 cf 11 00 60 	movl   $0x107c60,0x11cf10
  102b29:	7c 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102b2c:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102b31:	8b 00                	mov    (%eax),%eax
  102b33:	89 44 24 04          	mov    %eax,0x4(%esp)
  102b37:	c7 04 24 10 75 10 00 	movl   $0x107510,(%esp)
  102b3e:	e8 54 d7 ff ff       	call   100297 <cprintf>
    pmm_manager->init();
  102b43:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102b48:	8b 40 04             	mov    0x4(%eax),%eax
  102b4b:	ff d0                	call   *%eax
}
  102b4d:	90                   	nop
  102b4e:	c9                   	leave  
  102b4f:	c3                   	ret    

00102b50 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102b50:	55                   	push   %ebp
  102b51:	89 e5                	mov    %esp,%ebp
  102b53:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102b56:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102b5b:	8b 40 08             	mov    0x8(%eax),%eax
  102b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  102b61:	89 54 24 04          	mov    %edx,0x4(%esp)
  102b65:	8b 55 08             	mov    0x8(%ebp),%edx
  102b68:	89 14 24             	mov    %edx,(%esp)
  102b6b:	ff d0                	call   *%eax
}
  102b6d:	90                   	nop
  102b6e:	c9                   	leave  
  102b6f:	c3                   	ret    

00102b70 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  102b70:	55                   	push   %ebp
  102b71:	89 e5                	mov    %esp,%ebp
  102b73:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  102b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  102b7d:	e8 2f fe ff ff       	call   1029b1 <__intr_save>
  102b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  102b85:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102b8a:	8b 40 0c             	mov    0xc(%eax),%eax
  102b8d:	8b 55 08             	mov    0x8(%ebp),%edx
  102b90:	89 14 24             	mov    %edx,(%esp)
  102b93:	ff d0                	call   *%eax
  102b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  102b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102b9b:	89 04 24             	mov    %eax,(%esp)
  102b9e:	e8 38 fe ff ff       	call   1029db <__intr_restore>
    return page;
  102ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102ba6:	c9                   	leave  
  102ba7:	c3                   	ret    

00102ba8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  102ba8:	55                   	push   %ebp
  102ba9:	89 e5                	mov    %esp,%ebp
  102bab:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  102bae:	e8 fe fd ff ff       	call   1029b1 <__intr_save>
  102bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  102bb6:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102bbb:	8b 40 10             	mov    0x10(%eax),%eax
  102bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
  102bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  102bc8:	89 14 24             	mov    %edx,(%esp)
  102bcb:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  102bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bd0:	89 04 24             	mov    %eax,(%esp)
  102bd3:	e8 03 fe ff ff       	call   1029db <__intr_restore>
}
  102bd8:	90                   	nop
  102bd9:	c9                   	leave  
  102bda:	c3                   	ret    

00102bdb <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  102bdb:	55                   	push   %ebp
  102bdc:	89 e5                	mov    %esp,%ebp
  102bde:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  102be1:	e8 cb fd ff ff       	call   1029b1 <__intr_save>
  102be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  102be9:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  102bee:	8b 40 14             	mov    0x14(%eax),%eax
  102bf1:	ff d0                	call   *%eax
  102bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  102bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102bf9:	89 04 24             	mov    %eax,(%esp)
  102bfc:	e8 da fd ff ff       	call   1029db <__intr_restore>
    return ret;
  102c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  102c04:	c9                   	leave  
  102c05:	c3                   	ret    

00102c06 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  102c06:	55                   	push   %ebp
  102c07:	89 e5                	mov    %esp,%ebp
  102c09:	57                   	push   %edi
  102c0a:	56                   	push   %esi
  102c0b:	53                   	push   %ebx
  102c0c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  102c12:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  102c19:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  102c20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  102c27:	c7 04 24 27 75 10 00 	movl   $0x107527,(%esp)
  102c2e:	e8 64 d6 ff ff       	call   100297 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102c33:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102c3a:	e9 22 01 00 00       	jmp    102d61 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102c3f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c42:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c45:	89 d0                	mov    %edx,%eax
  102c47:	c1 e0 02             	shl    $0x2,%eax
  102c4a:	01 d0                	add    %edx,%eax
  102c4c:	c1 e0 02             	shl    $0x2,%eax
  102c4f:	01 c8                	add    %ecx,%eax
  102c51:	8b 50 08             	mov    0x8(%eax),%edx
  102c54:	8b 40 04             	mov    0x4(%eax),%eax
  102c57:	89 45 b8             	mov    %eax,-0x48(%ebp)
  102c5a:	89 55 bc             	mov    %edx,-0x44(%ebp)
  102c5d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c60:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c63:	89 d0                	mov    %edx,%eax
  102c65:	c1 e0 02             	shl    $0x2,%eax
  102c68:	01 d0                	add    %edx,%eax
  102c6a:	c1 e0 02             	shl    $0x2,%eax
  102c6d:	01 c8                	add    %ecx,%eax
  102c6f:	8b 48 0c             	mov    0xc(%eax),%ecx
  102c72:	8b 58 10             	mov    0x10(%eax),%ebx
  102c75:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102c78:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102c7b:	01 c8                	add    %ecx,%eax
  102c7d:	11 da                	adc    %ebx,%edx
  102c7f:	89 45 b0             	mov    %eax,-0x50(%ebp)
  102c82:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  102c85:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102c88:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c8b:	89 d0                	mov    %edx,%eax
  102c8d:	c1 e0 02             	shl    $0x2,%eax
  102c90:	01 d0                	add    %edx,%eax
  102c92:	c1 e0 02             	shl    $0x2,%eax
  102c95:	01 c8                	add    %ecx,%eax
  102c97:	83 c0 14             	add    $0x14,%eax
  102c9a:	8b 00                	mov    (%eax),%eax
  102c9c:	89 45 84             	mov    %eax,-0x7c(%ebp)
  102c9f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102ca2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102ca5:	83 c0 ff             	add    $0xffffffff,%eax
  102ca8:	83 d2 ff             	adc    $0xffffffff,%edx
  102cab:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  102cb1:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  102cb7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102cba:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102cbd:	89 d0                	mov    %edx,%eax
  102cbf:	c1 e0 02             	shl    $0x2,%eax
  102cc2:	01 d0                	add    %edx,%eax
  102cc4:	c1 e0 02             	shl    $0x2,%eax
  102cc7:	01 c8                	add    %ecx,%eax
  102cc9:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ccc:	8b 58 10             	mov    0x10(%eax),%ebx
  102ccf:	8b 55 84             	mov    -0x7c(%ebp),%edx
  102cd2:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  102cd6:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  102cdc:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  102ce2:	89 44 24 14          	mov    %eax,0x14(%esp)
  102ce6:	89 54 24 18          	mov    %edx,0x18(%esp)
  102cea:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102ced:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102cf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102cf4:	89 54 24 10          	mov    %edx,0x10(%esp)
  102cf8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  102cfc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  102d00:	c7 04 24 34 75 10 00 	movl   $0x107534,(%esp)
  102d07:	e8 8b d5 ff ff       	call   100297 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  102d0c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102d0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d12:	89 d0                	mov    %edx,%eax
  102d14:	c1 e0 02             	shl    $0x2,%eax
  102d17:	01 d0                	add    %edx,%eax
  102d19:	c1 e0 02             	shl    $0x2,%eax
  102d1c:	01 c8                	add    %ecx,%eax
  102d1e:	83 c0 14             	add    $0x14,%eax
  102d21:	8b 00                	mov    (%eax),%eax
  102d23:	83 f8 01             	cmp    $0x1,%eax
  102d26:	75 36                	jne    102d5e <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
  102d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d2e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d31:	77 2b                	ja     102d5e <page_init+0x158>
  102d33:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  102d36:	72 05                	jb     102d3d <page_init+0x137>
  102d38:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  102d3b:	73 21                	jae    102d5e <page_init+0x158>
  102d3d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d41:	77 1b                	ja     102d5e <page_init+0x158>
  102d43:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  102d47:	72 09                	jb     102d52 <page_init+0x14c>
  102d49:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  102d50:	77 0c                	ja     102d5e <page_init+0x158>
                maxpa = end;
  102d52:	8b 45 b0             	mov    -0x50(%ebp),%eax
  102d55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102d58:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102d5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  102d5e:	ff 45 dc             	incl   -0x24(%ebp)
  102d61:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102d64:	8b 00                	mov    (%eax),%eax
  102d66:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102d69:	0f 8f d0 fe ff ff    	jg     102c3f <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  102d6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d73:	72 1d                	jb     102d92 <page_init+0x18c>
  102d75:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102d79:	77 09                	ja     102d84 <page_init+0x17e>
  102d7b:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  102d82:	76 0e                	jbe    102d92 <page_init+0x18c>
        maxpa = KMEMSIZE;
  102d84:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  102d8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  102d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  102d98:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102d9c:	c1 ea 0c             	shr    $0xc,%edx
  102d9f:	a3 80 ce 11 00       	mov    %eax,0x11ce80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  102da4:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  102dab:	b8 60 39 2a 00       	mov    $0x2a3960,%eax
  102db0:	8d 50 ff             	lea    -0x1(%eax),%edx
  102db3:	8b 45 ac             	mov    -0x54(%ebp),%eax
  102db6:	01 d0                	add    %edx,%eax
  102db8:	89 45 a8             	mov    %eax,-0x58(%ebp)
  102dbb:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102dbe:	ba 00 00 00 00       	mov    $0x0,%edx
  102dc3:	f7 75 ac             	divl   -0x54(%ebp)
  102dc6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  102dc9:	29 d0                	sub    %edx,%eax
  102dcb:	a3 18 cf 11 00       	mov    %eax,0x11cf18

    for (i = 0; i < npage; i ++) {
  102dd0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102dd7:	eb 2e                	jmp    102e07 <page_init+0x201>
        SetPageReserved(pages + i);
  102dd9:	8b 0d 18 cf 11 00    	mov    0x11cf18,%ecx
  102ddf:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102de2:	89 d0                	mov    %edx,%eax
  102de4:	c1 e0 02             	shl    $0x2,%eax
  102de7:	01 d0                	add    %edx,%eax
  102de9:	c1 e0 02             	shl    $0x2,%eax
  102dec:	01 c8                	add    %ecx,%eax
  102dee:	83 c0 04             	add    $0x4,%eax
  102df1:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  102df8:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dfb:	8b 45 8c             	mov    -0x74(%ebp),%eax
  102dfe:	8b 55 90             	mov    -0x70(%ebp),%edx
  102e01:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  102e04:	ff 45 dc             	incl   -0x24(%ebp)
  102e07:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e0a:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  102e0f:	39 c2                	cmp    %eax,%edx
  102e11:	72 c6                	jb     102dd9 <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  102e13:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  102e19:	89 d0                	mov    %edx,%eax
  102e1b:	c1 e0 02             	shl    $0x2,%eax
  102e1e:	01 d0                	add    %edx,%eax
  102e20:	c1 e0 02             	shl    $0x2,%eax
  102e23:	89 c2                	mov    %eax,%edx
  102e25:	a1 18 cf 11 00       	mov    0x11cf18,%eax
  102e2a:	01 d0                	add    %edx,%eax
  102e2c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  102e2f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  102e36:	77 23                	ja     102e5b <page_init+0x255>
  102e38:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102e3f:	c7 44 24 08 64 75 10 	movl   $0x107564,0x8(%esp)
  102e46:	00 
  102e47:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
  102e4e:	00 
  102e4f:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  102e56:	e8 93 d5 ff ff       	call   1003ee <__panic>
  102e5b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  102e5e:	05 00 00 00 40       	add    $0x40000000,%eax
  102e63:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  102e66:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  102e6d:	e9 61 01 00 00       	jmp    102fd3 <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  102e72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e75:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e78:	89 d0                	mov    %edx,%eax
  102e7a:	c1 e0 02             	shl    $0x2,%eax
  102e7d:	01 d0                	add    %edx,%eax
  102e7f:	c1 e0 02             	shl    $0x2,%eax
  102e82:	01 c8                	add    %ecx,%eax
  102e84:	8b 50 08             	mov    0x8(%eax),%edx
  102e87:	8b 40 04             	mov    0x4(%eax),%eax
  102e8a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102e8d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102e90:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102e93:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102e96:	89 d0                	mov    %edx,%eax
  102e98:	c1 e0 02             	shl    $0x2,%eax
  102e9b:	01 d0                	add    %edx,%eax
  102e9d:	c1 e0 02             	shl    $0x2,%eax
  102ea0:	01 c8                	add    %ecx,%eax
  102ea2:	8b 48 0c             	mov    0xc(%eax),%ecx
  102ea5:	8b 58 10             	mov    0x10(%eax),%ebx
  102ea8:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102eab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102eae:	01 c8                	add    %ecx,%eax
  102eb0:	11 da                	adc    %ebx,%edx
  102eb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102eb5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  102eb8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  102ebb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102ebe:	89 d0                	mov    %edx,%eax
  102ec0:	c1 e0 02             	shl    $0x2,%eax
  102ec3:	01 d0                	add    %edx,%eax
  102ec5:	c1 e0 02             	shl    $0x2,%eax
  102ec8:	01 c8                	add    %ecx,%eax
  102eca:	83 c0 14             	add    $0x14,%eax
  102ecd:	8b 00                	mov    (%eax),%eax
  102ecf:	83 f8 01             	cmp    $0x1,%eax
  102ed2:	0f 85 f8 00 00 00    	jne    102fd0 <page_init+0x3ca>
            if (begin < freemem) {
  102ed8:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102edb:	ba 00 00 00 00       	mov    $0x0,%edx
  102ee0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102ee3:	72 17                	jb     102efc <page_init+0x2f6>
  102ee5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  102ee8:	77 05                	ja     102eef <page_init+0x2e9>
  102eea:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  102eed:	76 0d                	jbe    102efc <page_init+0x2f6>
                begin = freemem;
  102eef:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102ef2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102ef5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  102efc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f00:	72 1d                	jb     102f1f <page_init+0x319>
  102f02:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  102f06:	77 09                	ja     102f11 <page_init+0x30b>
  102f08:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  102f0f:	76 0e                	jbe    102f1f <page_init+0x319>
                end = KMEMSIZE;
  102f11:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  102f18:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  102f1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f22:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f25:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f28:	0f 87 a2 00 00 00    	ja     102fd0 <page_init+0x3ca>
  102f2e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f31:	72 09                	jb     102f3c <page_init+0x336>
  102f33:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102f36:	0f 83 94 00 00 00    	jae    102fd0 <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
  102f3c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  102f43:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102f46:	8b 45 9c             	mov    -0x64(%ebp),%eax
  102f49:	01 d0                	add    %edx,%eax
  102f4b:	48                   	dec    %eax
  102f4c:	89 45 98             	mov    %eax,-0x68(%ebp)
  102f4f:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f52:	ba 00 00 00 00       	mov    $0x0,%edx
  102f57:	f7 75 9c             	divl   -0x64(%ebp)
  102f5a:	8b 45 98             	mov    -0x68(%ebp),%eax
  102f5d:	29 d0                	sub    %edx,%eax
  102f5f:	ba 00 00 00 00       	mov    $0x0,%edx
  102f64:	89 45 d0             	mov    %eax,-0x30(%ebp)
  102f67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  102f6a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f6d:	89 45 94             	mov    %eax,-0x6c(%ebp)
  102f70:	8b 45 94             	mov    -0x6c(%ebp),%eax
  102f73:	ba 00 00 00 00       	mov    $0x0,%edx
  102f78:	89 c3                	mov    %eax,%ebx
  102f7a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  102f80:	89 de                	mov    %ebx,%esi
  102f82:	89 d0                	mov    %edx,%eax
  102f84:	83 e0 00             	and    $0x0,%eax
  102f87:	89 c7                	mov    %eax,%edi
  102f89:	89 75 c8             	mov    %esi,-0x38(%ebp)
  102f8c:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  102f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102f92:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102f95:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f98:	77 36                	ja     102fd0 <page_init+0x3ca>
  102f9a:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  102f9d:	72 05                	jb     102fa4 <page_init+0x39e>
  102f9f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  102fa2:	73 2c                	jae    102fd0 <page_init+0x3ca>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  102fa4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102fa7:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102faa:	2b 45 d0             	sub    -0x30(%ebp),%eax
  102fad:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  102fb0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  102fb4:	c1 ea 0c             	shr    $0xc,%edx
  102fb7:	89 c3                	mov    %eax,%ebx
  102fb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102fbc:	89 04 24             	mov    %eax,(%esp)
  102fbf:	e8 ae f8 ff ff       	call   102872 <pa2page>
  102fc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  102fc8:	89 04 24             	mov    %eax,(%esp)
  102fcb:	e8 80 fb ff ff       	call   102b50 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  102fd0:	ff 45 dc             	incl   -0x24(%ebp)
  102fd3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102fd6:	8b 00                	mov    (%eax),%eax
  102fd8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  102fdb:	0f 8f 91 fe ff ff    	jg     102e72 <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  102fe1:	90                   	nop
  102fe2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  102fe8:	5b                   	pop    %ebx
  102fe9:	5e                   	pop    %esi
  102fea:	5f                   	pop    %edi
  102feb:	5d                   	pop    %ebp
  102fec:	c3                   	ret    

00102fed <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  102fed:	55                   	push   %ebp
  102fee:	89 e5                	mov    %esp,%ebp
  102ff0:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  102ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ff6:	33 45 14             	xor    0x14(%ebp),%eax
  102ff9:	25 ff 0f 00 00       	and    $0xfff,%eax
  102ffe:	85 c0                	test   %eax,%eax
  103000:	74 24                	je     103026 <boot_map_segment+0x39>
  103002:	c7 44 24 0c 96 75 10 	movl   $0x107596,0xc(%esp)
  103009:	00 
  10300a:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103011:	00 
  103012:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
  103019:	00 
  10301a:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103021:	e8 c8 d3 ff ff       	call   1003ee <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103026:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10302d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103030:	25 ff 0f 00 00       	and    $0xfff,%eax
  103035:	89 c2                	mov    %eax,%edx
  103037:	8b 45 10             	mov    0x10(%ebp),%eax
  10303a:	01 c2                	add    %eax,%edx
  10303c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10303f:	01 d0                	add    %edx,%eax
  103041:	48                   	dec    %eax
  103042:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103045:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103048:	ba 00 00 00 00       	mov    $0x0,%edx
  10304d:	f7 75 f0             	divl   -0x10(%ebp)
  103050:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103053:	29 d0                	sub    %edx,%eax
  103055:	c1 e8 0c             	shr    $0xc,%eax
  103058:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10305b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10305e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103061:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103064:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103069:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10306c:	8b 45 14             	mov    0x14(%ebp),%eax
  10306f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103075:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  10307a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10307d:	eb 68                	jmp    1030e7 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10307f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103086:	00 
  103087:	8b 45 0c             	mov    0xc(%ebp),%eax
  10308a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10308e:	8b 45 08             	mov    0x8(%ebp),%eax
  103091:	89 04 24             	mov    %eax,(%esp)
  103094:	e8 81 01 00 00       	call   10321a <get_pte>
  103099:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10309c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1030a0:	75 24                	jne    1030c6 <boot_map_segment+0xd9>
  1030a2:	c7 44 24 0c c2 75 10 	movl   $0x1075c2,0xc(%esp)
  1030a9:	00 
  1030aa:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1030b1:	00 
  1030b2:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  1030b9:	00 
  1030ba:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1030c1:	e8 28 d3 ff ff       	call   1003ee <__panic>
        *ptep = pa | PTE_P | perm;
  1030c6:	8b 45 14             	mov    0x14(%ebp),%eax
  1030c9:	0b 45 18             	or     0x18(%ebp),%eax
  1030cc:	83 c8 01             	or     $0x1,%eax
  1030cf:	89 c2                	mov    %eax,%edx
  1030d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1030d4:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1030d6:	ff 4d f4             	decl   -0xc(%ebp)
  1030d9:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1030e0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1030e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1030eb:	75 92                	jne    10307f <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1030ed:	90                   	nop
  1030ee:	c9                   	leave  
  1030ef:	c3                   	ret    

001030f0 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1030f0:	55                   	push   %ebp
  1030f1:	89 e5                	mov    %esp,%ebp
  1030f3:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1030f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1030fd:	e8 6e fa ff ff       	call   102b70 <alloc_pages>
  103102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  103105:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103109:	75 1c                	jne    103127 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  10310b:	c7 44 24 08 cf 75 10 	movl   $0x1075cf,0x8(%esp)
  103112:	00 
  103113:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  10311a:	00 
  10311b:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103122:	e8 c7 d2 ff ff       	call   1003ee <__panic>
    }
    return page2kva(p);
  103127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10312a:	89 04 24             	mov    %eax,(%esp)
  10312d:	e8 8f f7 ff ff       	call   1028c1 <page2kva>
}
  103132:	c9                   	leave  
  103133:	c3                   	ret    

00103134 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103134:	55                   	push   %ebp
  103135:	89 e5                	mov    %esp,%ebp
  103137:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  10313a:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10313f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103142:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103149:	77 23                	ja     10316e <pmm_init+0x3a>
  10314b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10314e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103152:	c7 44 24 08 64 75 10 	movl   $0x107564,0x8(%esp)
  103159:	00 
  10315a:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  103161:	00 
  103162:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103169:	e8 80 d2 ff ff       	call   1003ee <__panic>
  10316e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103171:	05 00 00 00 40       	add    $0x40000000,%eax
  103176:	a3 14 cf 11 00       	mov    %eax,0x11cf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10317b:	e8 9c f9 ff ff       	call   102b1c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  103180:	e8 81 fa ff ff       	call   102c06 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103185:	e8 de 03 00 00       	call   103568 <check_alloc_page>

    check_pgdir();
  10318a:	e8 f8 03 00 00       	call   103587 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10318f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103194:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  10319a:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10319f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1031a2:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1031a9:	77 23                	ja     1031ce <pmm_init+0x9a>
  1031ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1031b2:	c7 44 24 08 64 75 10 	movl   $0x107564,0x8(%esp)
  1031b9:	00 
  1031ba:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
  1031c1:	00 
  1031c2:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1031c9:	e8 20 d2 ff ff       	call   1003ee <__panic>
  1031ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1031d1:	05 00 00 00 40       	add    $0x40000000,%eax
  1031d6:	83 c8 03             	or     $0x3,%eax
  1031d9:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1031db:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1031e0:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1031e7:	00 
  1031e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1031ef:	00 
  1031f0:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1031f7:	38 
  1031f8:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1031ff:	c0 
  103200:	89 04 24             	mov    %eax,(%esp)
  103203:	e8 e5 fd ff ff       	call   102fed <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  103208:	e8 26 f8 ff ff       	call   102a33 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  10320d:	e8 11 0a 00 00       	call   103c23 <check_boot_pgdir>

    print_pgdir();
  103212:	e8 8a 0e 00 00       	call   1040a1 <print_pgdir>

}
  103217:	90                   	nop
  103218:	c9                   	leave  
  103219:	c3                   	ret    

0010321a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  10321a:	55                   	push   %ebp
  10321b:	89 e5                	mov    %esp,%ebp
  10321d:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    // 首先找到页目录项，尝试获得页表
    pde_t *pdep = &pgdir[PDX(la)];
  103220:	8b 45 0c             	mov    0xc(%ebp),%eax
  103223:	c1 e8 16             	shr    $0x16,%eax
  103226:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10322d:	8b 45 08             	mov    0x8(%ebp),%eax
  103230:	01 d0                	add    %edx,%eax
  103232:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 检查这个页目录项是否存在，存在则直接返回找到的页目录项
    if (!(*pdep & PTE_P)) {
  103235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103238:	8b 00                	mov    (%eax),%eax
  10323a:	83 e0 01             	and    $0x1,%eax
  10323d:	85 c0                	test   %eax,%eax
  10323f:	0f 85 af 00 00 00    	jne    1032f4 <get_pte+0xda>
        struct Page *page;
        // 页目录项不存在，且参数不要求创建新的页表，直接返回NULL
        if (!create || (page = alloc_page()) == NULL) {
  103245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  103249:	74 15                	je     103260 <get_pte+0x46>
  10324b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103252:	e8 19 f9 ff ff       	call   102b70 <alloc_pages>
  103257:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10325a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10325e:	75 0a                	jne    10326a <get_pte+0x50>
            return NULL;
  103260:	b8 00 00 00 00       	mov    $0x0,%eax
  103265:	e9 e7 00 00 00       	jmp    103351 <get_pte+0x137>
        }
        // 页目录项不存在，且参数要求创建新的页表
        // 设置物理页被引用一次
        set_page_ref(page, 1);
  10326a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103271:	00 
  103272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103275:	89 04 24             	mov    %eax,(%esp)
  103278:	e8 f8 f6 ff ff       	call   102975 <set_page_ref>
        // 获得物理页的线性物理地址
        uintptr_t pa = page2pa(page);
  10327d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103280:	89 04 24             	mov    %eax,(%esp)
  103283:	e8 d4 f5 ff ff       	call   10285c <page2pa>
  103288:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将物理地址转换成虚拟地址后，用memset函数清除页目录进行初始化
        memset(KADDR(pa), 0, PGSIZE);
  10328b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10328e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103291:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103294:	c1 e8 0c             	shr    $0xc,%eax
  103297:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10329a:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  10329f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  1032a2:	72 23                	jb     1032c7 <get_pte+0xad>
  1032a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1032ab:	c7 44 24 08 c0 74 10 	movl   $0x1074c0,0x8(%esp)
  1032b2:	00 
  1032b3:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
  1032ba:	00 
  1032bb:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1032c2:	e8 27 d1 ff ff       	call   1003ee <__panic>
  1032c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032ca:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1032cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1032d6:	00 
  1032d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1032de:	00 
  1032df:	89 04 24             	mov    %eax,(%esp)
  1032e2:	e8 75 32 00 00       	call   10655c <memset>
        // 设置页目录项的权限
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  1032e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1032ea:	83 c8 07             	or     $0x7,%eax
  1032ed:	89 c2                	mov    %eax,%edx
  1032ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f2:	89 10                	mov    %edx,(%eax)
    }
    // 返回虚拟地址la对应的页表项入口地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1032f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f7:	8b 00                	mov    (%eax),%eax
  1032f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1032fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103301:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103304:	c1 e8 0c             	shr    $0xc,%eax
  103307:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10330a:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  10330f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103312:	72 23                	jb     103337 <get_pte+0x11d>
  103314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103317:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10331b:	c7 44 24 08 c0 74 10 	movl   $0x1074c0,0x8(%esp)
  103322:	00 
  103323:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
  10332a:	00 
  10332b:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103332:	e8 b7 d0 ff ff       	call   1003ee <__panic>
  103337:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10333a:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10333f:	89 c2                	mov    %eax,%edx
  103341:	8b 45 0c             	mov    0xc(%ebp),%eax
  103344:	c1 e8 0c             	shr    $0xc,%eax
  103347:	25 ff 03 00 00       	and    $0x3ff,%eax
  10334c:	c1 e0 02             	shl    $0x2,%eax
  10334f:	01 d0                	add    %edx,%eax
}
  103351:	c9                   	leave  
  103352:	c3                   	ret    

00103353 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103353:	55                   	push   %ebp
  103354:	89 e5                	mov    %esp,%ebp
  103356:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103359:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103360:	00 
  103361:	8b 45 0c             	mov    0xc(%ebp),%eax
  103364:	89 44 24 04          	mov    %eax,0x4(%esp)
  103368:	8b 45 08             	mov    0x8(%ebp),%eax
  10336b:	89 04 24             	mov    %eax,(%esp)
  10336e:	e8 a7 fe ff ff       	call   10321a <get_pte>
  103373:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  103376:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10337a:	74 08                	je     103384 <get_page+0x31>
        *ptep_store = ptep;
  10337c:	8b 45 10             	mov    0x10(%ebp),%eax
  10337f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103382:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103384:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103388:	74 1b                	je     1033a5 <get_page+0x52>
  10338a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10338d:	8b 00                	mov    (%eax),%eax
  10338f:	83 e0 01             	and    $0x1,%eax
  103392:	85 c0                	test   %eax,%eax
  103394:	74 0f                	je     1033a5 <get_page+0x52>
        return pte2page(*ptep);
  103396:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103399:	8b 00                	mov    (%eax),%eax
  10339b:	89 04 24             	mov    %eax,(%esp)
  10339e:	e8 72 f5 ff ff       	call   102915 <pte2page>
  1033a3:	eb 05                	jmp    1033aa <get_page+0x57>
    }
    return NULL;
  1033a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1033aa:	c9                   	leave  
  1033ab:	c3                   	ret    

001033ac <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1033ac:	55                   	push   %ebp
  1033ad:	89 e5                	mov    %esp,%ebp
  1033af:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    // 检查这个页目录项是否存在
    if (*ptep & PTE_P) {
  1033b2:	8b 45 10             	mov    0x10(%ebp),%eax
  1033b5:	8b 00                	mov    (%eax),%eax
  1033b7:	83 e0 01             	and    $0x1,%eax
  1033ba:	85 c0                	test   %eax,%eax
  1033bc:	74 4d                	je     10340b <page_remove_pte+0x5f>
        // 找到这个页目录项对应的页
        struct Page *page = pte2page(*ptep);
  1033be:	8b 45 10             	mov    0x10(%ebp),%eax
  1033c1:	8b 00                	mov    (%eax),%eax
  1033c3:	89 04 24             	mov    %eax,(%esp)
  1033c6:	e8 4a f5 ff ff       	call   102915 <pte2page>
  1033cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 将这个页的引用数减一
        if (page_ref_dec(page) == 0) {
  1033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033d1:	89 04 24             	mov    %eax,(%esp)
  1033d4:	e8 c1 f5 ff ff       	call   10299a <page_ref_dec>
  1033d9:	85 c0                	test   %eax,%eax
  1033db:	75 13                	jne    1033f0 <page_remove_pte+0x44>
        // 如果这个页的引用数为0，那么释放此页
            free_page(page);
  1033dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033e4:	00 
  1033e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033e8:	89 04 24             	mov    %eax,(%esp)
  1033eb:	e8 b8 f7 ff ff       	call   102ba8 <free_pages>
        }
        // 清除页目录项
        *ptep = 0;
  1033f0:	8b 45 10             	mov    0x10(%ebp),%eax
  1033f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 当修改的页表正在使用时，那么无效
        tlb_invalidate(pgdir, la);
  1033f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  103400:	8b 45 08             	mov    0x8(%ebp),%eax
  103403:	89 04 24             	mov    %eax,(%esp)
  103406:	e8 01 01 00 00       	call   10350c <tlb_invalidate>
    }
}
  10340b:	90                   	nop
  10340c:	c9                   	leave  
  10340d:	c3                   	ret    

0010340e <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  10340e:	55                   	push   %ebp
  10340f:	89 e5                	mov    %esp,%ebp
  103411:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103414:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10341b:	00 
  10341c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10341f:	89 44 24 04          	mov    %eax,0x4(%esp)
  103423:	8b 45 08             	mov    0x8(%ebp),%eax
  103426:	89 04 24             	mov    %eax,(%esp)
  103429:	e8 ec fd ff ff       	call   10321a <get_pte>
  10342e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103435:	74 19                	je     103450 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  103437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10343a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10343e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103441:	89 44 24 04          	mov    %eax,0x4(%esp)
  103445:	8b 45 08             	mov    0x8(%ebp),%eax
  103448:	89 04 24             	mov    %eax,(%esp)
  10344b:	e8 5c ff ff ff       	call   1033ac <page_remove_pte>
    }
}
  103450:	90                   	nop
  103451:	c9                   	leave  
  103452:	c3                   	ret    

00103453 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103453:	55                   	push   %ebp
  103454:	89 e5                	mov    %esp,%ebp
  103456:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  103459:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103460:	00 
  103461:	8b 45 10             	mov    0x10(%ebp),%eax
  103464:	89 44 24 04          	mov    %eax,0x4(%esp)
  103468:	8b 45 08             	mov    0x8(%ebp),%eax
  10346b:	89 04 24             	mov    %eax,(%esp)
  10346e:	e8 a7 fd ff ff       	call   10321a <get_pte>
  103473:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  103476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10347a:	75 0a                	jne    103486 <page_insert+0x33>
        return -E_NO_MEM;
  10347c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103481:	e9 84 00 00 00       	jmp    10350a <page_insert+0xb7>
    }
    page_ref_inc(page);
  103486:	8b 45 0c             	mov    0xc(%ebp),%eax
  103489:	89 04 24             	mov    %eax,(%esp)
  10348c:	e8 f2 f4 ff ff       	call   102983 <page_ref_inc>
    if (*ptep & PTE_P) {
  103491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103494:	8b 00                	mov    (%eax),%eax
  103496:	83 e0 01             	and    $0x1,%eax
  103499:	85 c0                	test   %eax,%eax
  10349b:	74 3e                	je     1034db <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10349d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034a0:	8b 00                	mov    (%eax),%eax
  1034a2:	89 04 24             	mov    %eax,(%esp)
  1034a5:	e8 6b f4 ff ff       	call   102915 <pte2page>
  1034aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1034ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1034b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1034b3:	75 0d                	jne    1034c2 <page_insert+0x6f>
            page_ref_dec(page);
  1034b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034b8:	89 04 24             	mov    %eax,(%esp)
  1034bb:	e8 da f4 ff ff       	call   10299a <page_ref_dec>
  1034c0:	eb 19                	jmp    1034db <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1034c9:	8b 45 10             	mov    0x10(%ebp),%eax
  1034cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034d0:	8b 45 08             	mov    0x8(%ebp),%eax
  1034d3:	89 04 24             	mov    %eax,(%esp)
  1034d6:	e8 d1 fe ff ff       	call   1033ac <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1034db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034de:	89 04 24             	mov    %eax,(%esp)
  1034e1:	e8 76 f3 ff ff       	call   10285c <page2pa>
  1034e6:	0b 45 14             	or     0x14(%ebp),%eax
  1034e9:	83 c8 01             	or     $0x1,%eax
  1034ec:	89 c2                	mov    %eax,%edx
  1034ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1034f1:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1034f3:	8b 45 10             	mov    0x10(%ebp),%eax
  1034f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1034fa:	8b 45 08             	mov    0x8(%ebp),%eax
  1034fd:	89 04 24             	mov    %eax,(%esp)
  103500:	e8 07 00 00 00       	call   10350c <tlb_invalidate>
    return 0;
  103505:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10350a:	c9                   	leave  
  10350b:	c3                   	ret    

0010350c <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  10350c:	55                   	push   %ebp
  10350d:	89 e5                	mov    %esp,%ebp
  10350f:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103512:	0f 20 d8             	mov    %cr3,%eax
  103515:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
  103518:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  10351b:	8b 45 08             	mov    0x8(%ebp),%eax
  10351e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103521:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103528:	77 23                	ja     10354d <tlb_invalidate+0x41>
  10352a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10352d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103531:	c7 44 24 08 64 75 10 	movl   $0x107564,0x8(%esp)
  103538:	00 
  103539:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
  103540:	00 
  103541:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103548:	e8 a1 ce ff ff       	call   1003ee <__panic>
  10354d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103550:	05 00 00 00 40       	add    $0x40000000,%eax
  103555:	39 c2                	cmp    %eax,%edx
  103557:	75 0c                	jne    103565 <tlb_invalidate+0x59>
        invlpg((void *)la);
  103559:	8b 45 0c             	mov    0xc(%ebp),%eax
  10355c:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  10355f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103562:	0f 01 38             	invlpg (%eax)
    }
}
  103565:	90                   	nop
  103566:	c9                   	leave  
  103567:	c3                   	ret    

00103568 <check_alloc_page>:

static void
check_alloc_page(void) {
  103568:	55                   	push   %ebp
  103569:	89 e5                	mov    %esp,%ebp
  10356b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  10356e:	a1 10 cf 11 00       	mov    0x11cf10,%eax
  103573:	8b 40 18             	mov    0x18(%eax),%eax
  103576:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103578:	c7 04 24 e8 75 10 00 	movl   $0x1075e8,(%esp)
  10357f:	e8 13 cd ff ff       	call   100297 <cprintf>
}
  103584:	90                   	nop
  103585:	c9                   	leave  
  103586:	c3                   	ret    

00103587 <check_pgdir>:

static void
check_pgdir(void) {
  103587:	55                   	push   %ebp
  103588:	89 e5                	mov    %esp,%ebp
  10358a:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  10358d:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103592:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103597:	76 24                	jbe    1035bd <check_pgdir+0x36>
  103599:	c7 44 24 0c 07 76 10 	movl   $0x107607,0xc(%esp)
  1035a0:	00 
  1035a1:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1035a8:	00 
  1035a9:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  1035b0:	00 
  1035b1:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1035b8:	e8 31 ce ff ff       	call   1003ee <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  1035bd:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1035c2:	85 c0                	test   %eax,%eax
  1035c4:	74 0e                	je     1035d4 <check_pgdir+0x4d>
  1035c6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1035cb:	25 ff 0f 00 00       	and    $0xfff,%eax
  1035d0:	85 c0                	test   %eax,%eax
  1035d2:	74 24                	je     1035f8 <check_pgdir+0x71>
  1035d4:	c7 44 24 0c 24 76 10 	movl   $0x107624,0xc(%esp)
  1035db:	00 
  1035dc:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1035e3:	00 
  1035e4:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
  1035eb:	00 
  1035ec:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1035f3:	e8 f6 cd ff ff       	call   1003ee <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  1035f8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1035fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103604:	00 
  103605:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10360c:	00 
  10360d:	89 04 24             	mov    %eax,(%esp)
  103610:	e8 3e fd ff ff       	call   103353 <get_page>
  103615:	85 c0                	test   %eax,%eax
  103617:	74 24                	je     10363d <check_pgdir+0xb6>
  103619:	c7 44 24 0c 5c 76 10 	movl   $0x10765c,0xc(%esp)
  103620:	00 
  103621:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103628:	00 
  103629:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103630:	00 
  103631:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103638:	e8 b1 cd ff ff       	call   1003ee <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  10363d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103644:	e8 27 f5 ff ff       	call   102b70 <alloc_pages>
  103649:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  10364c:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103651:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103658:	00 
  103659:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103660:	00 
  103661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103664:	89 54 24 04          	mov    %edx,0x4(%esp)
  103668:	89 04 24             	mov    %eax,(%esp)
  10366b:	e8 e3 fd ff ff       	call   103453 <page_insert>
  103670:	85 c0                	test   %eax,%eax
  103672:	74 24                	je     103698 <check_pgdir+0x111>
  103674:	c7 44 24 0c 84 76 10 	movl   $0x107684,0xc(%esp)
  10367b:	00 
  10367c:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103683:	00 
  103684:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  10368b:	00 
  10368c:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103693:	e8 56 cd ff ff       	call   1003ee <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103698:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10369d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1036a4:	00 
  1036a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1036ac:	00 
  1036ad:	89 04 24             	mov    %eax,(%esp)
  1036b0:	e8 65 fb ff ff       	call   10321a <get_pte>
  1036b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1036bc:	75 24                	jne    1036e2 <check_pgdir+0x15b>
  1036be:	c7 44 24 0c b0 76 10 	movl   $0x1076b0,0xc(%esp)
  1036c5:	00 
  1036c6:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1036cd:	00 
  1036ce:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  1036d5:	00 
  1036d6:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1036dd:	e8 0c cd ff ff       	call   1003ee <__panic>
    assert(pte2page(*ptep) == p1);
  1036e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036e5:	8b 00                	mov    (%eax),%eax
  1036e7:	89 04 24             	mov    %eax,(%esp)
  1036ea:	e8 26 f2 ff ff       	call   102915 <pte2page>
  1036ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1036f2:	74 24                	je     103718 <check_pgdir+0x191>
  1036f4:	c7 44 24 0c dd 76 10 	movl   $0x1076dd,0xc(%esp)
  1036fb:	00 
  1036fc:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103703:	00 
  103704:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  10370b:	00 
  10370c:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103713:	e8 d6 cc ff ff       	call   1003ee <__panic>
    assert(page_ref(p1) == 1);
  103718:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10371b:	89 04 24             	mov    %eax,(%esp)
  10371e:	e8 48 f2 ff ff       	call   10296b <page_ref>
  103723:	83 f8 01             	cmp    $0x1,%eax
  103726:	74 24                	je     10374c <check_pgdir+0x1c5>
  103728:	c7 44 24 0c f3 76 10 	movl   $0x1076f3,0xc(%esp)
  10372f:	00 
  103730:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103737:	00 
  103738:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  10373f:	00 
  103740:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103747:	e8 a2 cc ff ff       	call   1003ee <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  10374c:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103751:	8b 00                	mov    (%eax),%eax
  103753:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103758:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10375b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10375e:	c1 e8 0c             	shr    $0xc,%eax
  103761:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103764:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103769:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10376c:	72 23                	jb     103791 <check_pgdir+0x20a>
  10376e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103771:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103775:	c7 44 24 08 c0 74 10 	movl   $0x1074c0,0x8(%esp)
  10377c:	00 
  10377d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103784:	00 
  103785:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  10378c:	e8 5d cc ff ff       	call   1003ee <__panic>
  103791:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103794:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103799:	83 c0 04             	add    $0x4,%eax
  10379c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  10379f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1037a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1037ab:	00 
  1037ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  1037b3:	00 
  1037b4:	89 04 24             	mov    %eax,(%esp)
  1037b7:	e8 5e fa ff ff       	call   10321a <get_pte>
  1037bc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1037bf:	74 24                	je     1037e5 <check_pgdir+0x25e>
  1037c1:	c7 44 24 0c 08 77 10 	movl   $0x107708,0xc(%esp)
  1037c8:	00 
  1037c9:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1037d0:	00 
  1037d1:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  1037d8:	00 
  1037d9:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1037e0:	e8 09 cc ff ff       	call   1003ee <__panic>

    p2 = alloc_page();
  1037e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1037ec:	e8 7f f3 ff ff       	call   102b70 <alloc_pages>
  1037f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  1037f4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1037f9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103800:	00 
  103801:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103808:	00 
  103809:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10380c:	89 54 24 04          	mov    %edx,0x4(%esp)
  103810:	89 04 24             	mov    %eax,(%esp)
  103813:	e8 3b fc ff ff       	call   103453 <page_insert>
  103818:	85 c0                	test   %eax,%eax
  10381a:	74 24                	je     103840 <check_pgdir+0x2b9>
  10381c:	c7 44 24 0c 30 77 10 	movl   $0x107730,0xc(%esp)
  103823:	00 
  103824:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  10382b:	00 
  10382c:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  103833:	00 
  103834:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  10383b:	e8 ae cb ff ff       	call   1003ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103840:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103845:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10384c:	00 
  10384d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103854:	00 
  103855:	89 04 24             	mov    %eax,(%esp)
  103858:	e8 bd f9 ff ff       	call   10321a <get_pte>
  10385d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103864:	75 24                	jne    10388a <check_pgdir+0x303>
  103866:	c7 44 24 0c 68 77 10 	movl   $0x107768,0xc(%esp)
  10386d:	00 
  10386e:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103875:	00 
  103876:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  10387d:	00 
  10387e:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103885:	e8 64 cb ff ff       	call   1003ee <__panic>
    assert(*ptep & PTE_U);
  10388a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10388d:	8b 00                	mov    (%eax),%eax
  10388f:	83 e0 04             	and    $0x4,%eax
  103892:	85 c0                	test   %eax,%eax
  103894:	75 24                	jne    1038ba <check_pgdir+0x333>
  103896:	c7 44 24 0c 98 77 10 	movl   $0x107798,0xc(%esp)
  10389d:	00 
  10389e:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1038a5:	00 
  1038a6:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
  1038ad:	00 
  1038ae:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1038b5:	e8 34 cb ff ff       	call   1003ee <__panic>
    assert(*ptep & PTE_W);
  1038ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1038bd:	8b 00                	mov    (%eax),%eax
  1038bf:	83 e0 02             	and    $0x2,%eax
  1038c2:	85 c0                	test   %eax,%eax
  1038c4:	75 24                	jne    1038ea <check_pgdir+0x363>
  1038c6:	c7 44 24 0c a6 77 10 	movl   $0x1077a6,0xc(%esp)
  1038cd:	00 
  1038ce:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1038d5:	00 
  1038d6:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  1038dd:	00 
  1038de:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1038e5:	e8 04 cb ff ff       	call   1003ee <__panic>
    assert(boot_pgdir[0] & PTE_U);
  1038ea:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1038ef:	8b 00                	mov    (%eax),%eax
  1038f1:	83 e0 04             	and    $0x4,%eax
  1038f4:	85 c0                	test   %eax,%eax
  1038f6:	75 24                	jne    10391c <check_pgdir+0x395>
  1038f8:	c7 44 24 0c b4 77 10 	movl   $0x1077b4,0xc(%esp)
  1038ff:	00 
  103900:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103907:	00 
  103908:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  10390f:	00 
  103910:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103917:	e8 d2 ca ff ff       	call   1003ee <__panic>
    assert(page_ref(p2) == 1);
  10391c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10391f:	89 04 24             	mov    %eax,(%esp)
  103922:	e8 44 f0 ff ff       	call   10296b <page_ref>
  103927:	83 f8 01             	cmp    $0x1,%eax
  10392a:	74 24                	je     103950 <check_pgdir+0x3c9>
  10392c:	c7 44 24 0c ca 77 10 	movl   $0x1077ca,0xc(%esp)
  103933:	00 
  103934:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  10393b:	00 
  10393c:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  103943:	00 
  103944:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  10394b:	e8 9e ca ff ff       	call   1003ee <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103950:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103955:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10395c:	00 
  10395d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103964:	00 
  103965:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103968:	89 54 24 04          	mov    %edx,0x4(%esp)
  10396c:	89 04 24             	mov    %eax,(%esp)
  10396f:	e8 df fa ff ff       	call   103453 <page_insert>
  103974:	85 c0                	test   %eax,%eax
  103976:	74 24                	je     10399c <check_pgdir+0x415>
  103978:	c7 44 24 0c dc 77 10 	movl   $0x1077dc,0xc(%esp)
  10397f:	00 
  103980:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103987:	00 
  103988:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  10398f:	00 
  103990:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103997:	e8 52 ca ff ff       	call   1003ee <__panic>
    assert(page_ref(p1) == 2);
  10399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10399f:	89 04 24             	mov    %eax,(%esp)
  1039a2:	e8 c4 ef ff ff       	call   10296b <page_ref>
  1039a7:	83 f8 02             	cmp    $0x2,%eax
  1039aa:	74 24                	je     1039d0 <check_pgdir+0x449>
  1039ac:	c7 44 24 0c 08 78 10 	movl   $0x107808,0xc(%esp)
  1039b3:	00 
  1039b4:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1039bb:	00 
  1039bc:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  1039c3:	00 
  1039c4:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1039cb:	e8 1e ca ff ff       	call   1003ee <__panic>
    assert(page_ref(p2) == 0);
  1039d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1039d3:	89 04 24             	mov    %eax,(%esp)
  1039d6:	e8 90 ef ff ff       	call   10296b <page_ref>
  1039db:	85 c0                	test   %eax,%eax
  1039dd:	74 24                	je     103a03 <check_pgdir+0x47c>
  1039df:	c7 44 24 0c 1a 78 10 	movl   $0x10781a,0xc(%esp)
  1039e6:	00 
  1039e7:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  1039ee:	00 
  1039ef:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  1039f6:	00 
  1039f7:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  1039fe:	e8 eb c9 ff ff       	call   1003ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103a03:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103a08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103a0f:	00 
  103a10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103a17:	00 
  103a18:	89 04 24             	mov    %eax,(%esp)
  103a1b:	e8 fa f7 ff ff       	call   10321a <get_pte>
  103a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103a27:	75 24                	jne    103a4d <check_pgdir+0x4c6>
  103a29:	c7 44 24 0c 68 77 10 	movl   $0x107768,0xc(%esp)
  103a30:	00 
  103a31:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103a38:	00 
  103a39:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  103a40:	00 
  103a41:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103a48:	e8 a1 c9 ff ff       	call   1003ee <__panic>
    assert(pte2page(*ptep) == p1);
  103a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a50:	8b 00                	mov    (%eax),%eax
  103a52:	89 04 24             	mov    %eax,(%esp)
  103a55:	e8 bb ee ff ff       	call   102915 <pte2page>
  103a5a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103a5d:	74 24                	je     103a83 <check_pgdir+0x4fc>
  103a5f:	c7 44 24 0c dd 76 10 	movl   $0x1076dd,0xc(%esp)
  103a66:	00 
  103a67:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103a6e:	00 
  103a6f:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  103a76:	00 
  103a77:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103a7e:	e8 6b c9 ff ff       	call   1003ee <__panic>
    assert((*ptep & PTE_U) == 0);
  103a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a86:	8b 00                	mov    (%eax),%eax
  103a88:	83 e0 04             	and    $0x4,%eax
  103a8b:	85 c0                	test   %eax,%eax
  103a8d:	74 24                	je     103ab3 <check_pgdir+0x52c>
  103a8f:	c7 44 24 0c 2c 78 10 	movl   $0x10782c,0xc(%esp)
  103a96:	00 
  103a97:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103a9e:	00 
  103a9f:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  103aa6:	00 
  103aa7:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103aae:	e8 3b c9 ff ff       	call   1003ee <__panic>

    page_remove(boot_pgdir, 0x0);
  103ab3:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103ab8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103abf:	00 
  103ac0:	89 04 24             	mov    %eax,(%esp)
  103ac3:	e8 46 f9 ff ff       	call   10340e <page_remove>
    assert(page_ref(p1) == 1);
  103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103acb:	89 04 24             	mov    %eax,(%esp)
  103ace:	e8 98 ee ff ff       	call   10296b <page_ref>
  103ad3:	83 f8 01             	cmp    $0x1,%eax
  103ad6:	74 24                	je     103afc <check_pgdir+0x575>
  103ad8:	c7 44 24 0c f3 76 10 	movl   $0x1076f3,0xc(%esp)
  103adf:	00 
  103ae0:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103ae7:	00 
  103ae8:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  103aef:	00 
  103af0:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103af7:	e8 f2 c8 ff ff       	call   1003ee <__panic>
    assert(page_ref(p2) == 0);
  103afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103aff:	89 04 24             	mov    %eax,(%esp)
  103b02:	e8 64 ee ff ff       	call   10296b <page_ref>
  103b07:	85 c0                	test   %eax,%eax
  103b09:	74 24                	je     103b2f <check_pgdir+0x5a8>
  103b0b:	c7 44 24 0c 1a 78 10 	movl   $0x10781a,0xc(%esp)
  103b12:	00 
  103b13:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103b1a:	00 
  103b1b:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
  103b22:	00 
  103b23:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103b2a:	e8 bf c8 ff ff       	call   1003ee <__panic>

    page_remove(boot_pgdir, PGSIZE);
  103b2f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103b34:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103b3b:	00 
  103b3c:	89 04 24             	mov    %eax,(%esp)
  103b3f:	e8 ca f8 ff ff       	call   10340e <page_remove>
    assert(page_ref(p1) == 0);
  103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103b47:	89 04 24             	mov    %eax,(%esp)
  103b4a:	e8 1c ee ff ff       	call   10296b <page_ref>
  103b4f:	85 c0                	test   %eax,%eax
  103b51:	74 24                	je     103b77 <check_pgdir+0x5f0>
  103b53:	c7 44 24 0c 41 78 10 	movl   $0x107841,0xc(%esp)
  103b5a:	00 
  103b5b:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103b62:	00 
  103b63:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  103b6a:	00 
  103b6b:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103b72:	e8 77 c8 ff ff       	call   1003ee <__panic>
    assert(page_ref(p2) == 0);
  103b77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103b7a:	89 04 24             	mov    %eax,(%esp)
  103b7d:	e8 e9 ed ff ff       	call   10296b <page_ref>
  103b82:	85 c0                	test   %eax,%eax
  103b84:	74 24                	je     103baa <check_pgdir+0x623>
  103b86:	c7 44 24 0c 1a 78 10 	movl   $0x10781a,0xc(%esp)
  103b8d:	00 
  103b8e:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103b95:	00 
  103b96:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
  103b9d:	00 
  103b9e:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103ba5:	e8 44 c8 ff ff       	call   1003ee <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  103baa:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103baf:	8b 00                	mov    (%eax),%eax
  103bb1:	89 04 24             	mov    %eax,(%esp)
  103bb4:	e8 9a ed ff ff       	call   102953 <pde2page>
  103bb9:	89 04 24             	mov    %eax,(%esp)
  103bbc:	e8 aa ed ff ff       	call   10296b <page_ref>
  103bc1:	83 f8 01             	cmp    $0x1,%eax
  103bc4:	74 24                	je     103bea <check_pgdir+0x663>
  103bc6:	c7 44 24 0c 54 78 10 	movl   $0x107854,0xc(%esp)
  103bcd:	00 
  103bce:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103bd5:	00 
  103bd6:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  103bdd:	00 
  103bde:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103be5:	e8 04 c8 ff ff       	call   1003ee <__panic>
    free_page(pde2page(boot_pgdir[0]));
  103bea:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103bef:	8b 00                	mov    (%eax),%eax
  103bf1:	89 04 24             	mov    %eax,(%esp)
  103bf4:	e8 5a ed ff ff       	call   102953 <pde2page>
  103bf9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103c00:	00 
  103c01:	89 04 24             	mov    %eax,(%esp)
  103c04:	e8 9f ef ff ff       	call   102ba8 <free_pages>
    boot_pgdir[0] = 0;
  103c09:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103c0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  103c14:	c7 04 24 7b 78 10 00 	movl   $0x10787b,(%esp)
  103c1b:	e8 77 c6 ff ff       	call   100297 <cprintf>
}
  103c20:	90                   	nop
  103c21:	c9                   	leave  
  103c22:	c3                   	ret    

00103c23 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  103c23:	55                   	push   %ebp
  103c24:	89 e5                	mov    %esp,%ebp
  103c26:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103c29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103c30:	e9 ca 00 00 00       	jmp    103cff <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  103c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c3e:	c1 e8 0c             	shr    $0xc,%eax
  103c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103c44:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103c49:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103c4c:	72 23                	jb     103c71 <check_boot_pgdir+0x4e>
  103c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c51:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c55:	c7 44 24 08 c0 74 10 	movl   $0x1074c0,0x8(%esp)
  103c5c:	00 
  103c5d:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  103c64:	00 
  103c65:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103c6c:	e8 7d c7 ff ff       	call   1003ee <__panic>
  103c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103c74:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103c79:	89 c2                	mov    %eax,%edx
  103c7b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103c80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c87:	00 
  103c88:	89 54 24 04          	mov    %edx,0x4(%esp)
  103c8c:	89 04 24             	mov    %eax,(%esp)
  103c8f:	e8 86 f5 ff ff       	call   10321a <get_pte>
  103c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103c97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103c9b:	75 24                	jne    103cc1 <check_boot_pgdir+0x9e>
  103c9d:	c7 44 24 0c 98 78 10 	movl   $0x107898,0xc(%esp)
  103ca4:	00 
  103ca5:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103cac:	00 
  103cad:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  103cb4:	00 
  103cb5:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103cbc:	e8 2d c7 ff ff       	call   1003ee <__panic>
        assert(PTE_ADDR(*ptep) == i);
  103cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103cc4:	8b 00                	mov    (%eax),%eax
  103cc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103ccb:	89 c2                	mov    %eax,%edx
  103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103cd0:	39 c2                	cmp    %eax,%edx
  103cd2:	74 24                	je     103cf8 <check_boot_pgdir+0xd5>
  103cd4:	c7 44 24 0c d5 78 10 	movl   $0x1078d5,0xc(%esp)
  103cdb:	00 
  103cdc:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103ce3:	00 
  103ce4:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  103ceb:	00 
  103cec:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103cf3:	e8 f6 c6 ff ff       	call   1003ee <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  103cf8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  103cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103d02:	a1 80 ce 11 00       	mov    0x11ce80,%eax
  103d07:	39 c2                	cmp    %eax,%edx
  103d09:	0f 82 26 ff ff ff    	jb     103c35 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  103d0f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103d14:	05 ac 0f 00 00       	add    $0xfac,%eax
  103d19:	8b 00                	mov    (%eax),%eax
  103d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103d20:	89 c2                	mov    %eax,%edx
  103d22:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103d27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103d2a:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  103d31:	77 23                	ja     103d56 <check_boot_pgdir+0x133>
  103d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103d3a:	c7 44 24 08 64 75 10 	movl   $0x107564,0x8(%esp)
  103d41:	00 
  103d42:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  103d49:	00 
  103d4a:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103d51:	e8 98 c6 ff ff       	call   1003ee <__panic>
  103d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103d59:	05 00 00 00 40       	add    $0x40000000,%eax
  103d5e:	39 c2                	cmp    %eax,%edx
  103d60:	74 24                	je     103d86 <check_boot_pgdir+0x163>
  103d62:	c7 44 24 0c ec 78 10 	movl   $0x1078ec,0xc(%esp)
  103d69:	00 
  103d6a:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103d71:	00 
  103d72:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  103d79:	00 
  103d7a:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103d81:	e8 68 c6 ff ff       	call   1003ee <__panic>

    assert(boot_pgdir[0] == 0);
  103d86:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103d8b:	8b 00                	mov    (%eax),%eax
  103d8d:	85 c0                	test   %eax,%eax
  103d8f:	74 24                	je     103db5 <check_boot_pgdir+0x192>
  103d91:	c7 44 24 0c 20 79 10 	movl   $0x107920,0xc(%esp)
  103d98:	00 
  103d99:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103da0:	00 
  103da1:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  103da8:	00 
  103da9:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103db0:	e8 39 c6 ff ff       	call   1003ee <__panic>

    struct Page *p;
    p = alloc_page();
  103db5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103dbc:	e8 af ed ff ff       	call   102b70 <alloc_pages>
  103dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  103dc4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103dc9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103dd0:	00 
  103dd1:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  103dd8:	00 
  103dd9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103ddc:	89 54 24 04          	mov    %edx,0x4(%esp)
  103de0:	89 04 24             	mov    %eax,(%esp)
  103de3:	e8 6b f6 ff ff       	call   103453 <page_insert>
  103de8:	85 c0                	test   %eax,%eax
  103dea:	74 24                	je     103e10 <check_boot_pgdir+0x1ed>
  103dec:	c7 44 24 0c 34 79 10 	movl   $0x107934,0xc(%esp)
  103df3:	00 
  103df4:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103dfb:	00 
  103dfc:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
  103e03:	00 
  103e04:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103e0b:	e8 de c5 ff ff       	call   1003ee <__panic>
    assert(page_ref(p) == 1);
  103e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e13:	89 04 24             	mov    %eax,(%esp)
  103e16:	e8 50 eb ff ff       	call   10296b <page_ref>
  103e1b:	83 f8 01             	cmp    $0x1,%eax
  103e1e:	74 24                	je     103e44 <check_boot_pgdir+0x221>
  103e20:	c7 44 24 0c 62 79 10 	movl   $0x107962,0xc(%esp)
  103e27:	00 
  103e28:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103e2f:	00 
  103e30:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
  103e37:	00 
  103e38:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103e3f:	e8 aa c5 ff ff       	call   1003ee <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  103e44:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103e49:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  103e50:	00 
  103e51:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  103e58:	00 
  103e59:	8b 55 e0             	mov    -0x20(%ebp),%edx
  103e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e60:	89 04 24             	mov    %eax,(%esp)
  103e63:	e8 eb f5 ff ff       	call   103453 <page_insert>
  103e68:	85 c0                	test   %eax,%eax
  103e6a:	74 24                	je     103e90 <check_boot_pgdir+0x26d>
  103e6c:	c7 44 24 0c 74 79 10 	movl   $0x107974,0xc(%esp)
  103e73:	00 
  103e74:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103e7b:	00 
  103e7c:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
  103e83:	00 
  103e84:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103e8b:	e8 5e c5 ff ff       	call   1003ee <__panic>
    assert(page_ref(p) == 2);
  103e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103e93:	89 04 24             	mov    %eax,(%esp)
  103e96:	e8 d0 ea ff ff       	call   10296b <page_ref>
  103e9b:	83 f8 02             	cmp    $0x2,%eax
  103e9e:	74 24                	je     103ec4 <check_boot_pgdir+0x2a1>
  103ea0:	c7 44 24 0c ab 79 10 	movl   $0x1079ab,0xc(%esp)
  103ea7:	00 
  103ea8:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103eaf:	00 
  103eb0:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  103eb7:	00 
  103eb8:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103ebf:	e8 2a c5 ff ff       	call   1003ee <__panic>

    const char *str = "ucore: Hello world!!";
  103ec4:	c7 45 dc bc 79 10 00 	movl   $0x1079bc,-0x24(%ebp)
    strcpy((void *)0x100, str);
  103ecb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103ece:	89 44 24 04          	mov    %eax,0x4(%esp)
  103ed2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103ed9:	e8 b4 23 00 00       	call   106292 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  103ede:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  103ee5:	00 
  103ee6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103eed:	e8 17 24 00 00       	call   106309 <strcmp>
  103ef2:	85 c0                	test   %eax,%eax
  103ef4:	74 24                	je     103f1a <check_boot_pgdir+0x2f7>
  103ef6:	c7 44 24 0c d4 79 10 	movl   $0x1079d4,0xc(%esp)
  103efd:	00 
  103efe:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103f05:	00 
  103f06:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
  103f0d:	00 
  103f0e:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103f15:	e8 d4 c4 ff ff       	call   1003ee <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  103f1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f1d:	89 04 24             	mov    %eax,(%esp)
  103f20:	e8 9c e9 ff ff       	call   1028c1 <page2kva>
  103f25:	05 00 01 00 00       	add    $0x100,%eax
  103f2a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  103f2d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  103f34:	e8 03 23 00 00       	call   10623c <strlen>
  103f39:	85 c0                	test   %eax,%eax
  103f3b:	74 24                	je     103f61 <check_boot_pgdir+0x33e>
  103f3d:	c7 44 24 0c 0c 7a 10 	movl   $0x107a0c,0xc(%esp)
  103f44:	00 
  103f45:	c7 44 24 08 ad 75 10 	movl   $0x1075ad,0x8(%esp)
  103f4c:	00 
  103f4d:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
  103f54:	00 
  103f55:	c7 04 24 88 75 10 00 	movl   $0x107588,(%esp)
  103f5c:	e8 8d c4 ff ff       	call   1003ee <__panic>

    free_page(p);
  103f61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f68:	00 
  103f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103f6c:	89 04 24             	mov    %eax,(%esp)
  103f6f:	e8 34 ec ff ff       	call   102ba8 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  103f74:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103f79:	8b 00                	mov    (%eax),%eax
  103f7b:	89 04 24             	mov    %eax,(%esp)
  103f7e:	e8 d0 e9 ff ff       	call   102953 <pde2page>
  103f83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103f8a:	00 
  103f8b:	89 04 24             	mov    %eax,(%esp)
  103f8e:	e8 15 ec ff ff       	call   102ba8 <free_pages>
    boot_pgdir[0] = 0;
  103f93:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  103f98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  103f9e:	c7 04 24 30 7a 10 00 	movl   $0x107a30,(%esp)
  103fa5:	e8 ed c2 ff ff       	call   100297 <cprintf>
}
  103faa:	90                   	nop
  103fab:	c9                   	leave  
  103fac:	c3                   	ret    

00103fad <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  103fad:	55                   	push   %ebp
  103fae:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  103fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  103fb3:	83 e0 04             	and    $0x4,%eax
  103fb6:	85 c0                	test   %eax,%eax
  103fb8:	74 04                	je     103fbe <perm2str+0x11>
  103fba:	b0 75                	mov    $0x75,%al
  103fbc:	eb 02                	jmp    103fc0 <perm2str+0x13>
  103fbe:	b0 2d                	mov    $0x2d,%al
  103fc0:	a2 08 cf 11 00       	mov    %al,0x11cf08
    str[1] = 'r';
  103fc5:	c6 05 09 cf 11 00 72 	movb   $0x72,0x11cf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
  103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  103fcf:	83 e0 02             	and    $0x2,%eax
  103fd2:	85 c0                	test   %eax,%eax
  103fd4:	74 04                	je     103fda <perm2str+0x2d>
  103fd6:	b0 77                	mov    $0x77,%al
  103fd8:	eb 02                	jmp    103fdc <perm2str+0x2f>
  103fda:	b0 2d                	mov    $0x2d,%al
  103fdc:	a2 0a cf 11 00       	mov    %al,0x11cf0a
    str[3] = '\0';
  103fe1:	c6 05 0b cf 11 00 00 	movb   $0x0,0x11cf0b
    return str;
  103fe8:	b8 08 cf 11 00       	mov    $0x11cf08,%eax
}
  103fed:	5d                   	pop    %ebp
  103fee:	c3                   	ret    

00103fef <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  103fef:	55                   	push   %ebp
  103ff0:	89 e5                	mov    %esp,%ebp
  103ff2:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  103ff5:	8b 45 10             	mov    0x10(%ebp),%eax
  103ff8:	3b 45 0c             	cmp    0xc(%ebp),%eax
  103ffb:	72 0d                	jb     10400a <get_pgtable_items+0x1b>
        return 0;
  103ffd:	b8 00 00 00 00       	mov    $0x0,%eax
  104002:	e9 98 00 00 00       	jmp    10409f <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  104007:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  10400a:	8b 45 10             	mov    0x10(%ebp),%eax
  10400d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104010:	73 18                	jae    10402a <get_pgtable_items+0x3b>
  104012:	8b 45 10             	mov    0x10(%ebp),%eax
  104015:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10401c:	8b 45 14             	mov    0x14(%ebp),%eax
  10401f:	01 d0                	add    %edx,%eax
  104021:	8b 00                	mov    (%eax),%eax
  104023:	83 e0 01             	and    $0x1,%eax
  104026:	85 c0                	test   %eax,%eax
  104028:	74 dd                	je     104007 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
  10402a:	8b 45 10             	mov    0x10(%ebp),%eax
  10402d:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104030:	73 68                	jae    10409a <get_pgtable_items+0xab>
        if (left_store != NULL) {
  104032:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  104036:	74 08                	je     104040 <get_pgtable_items+0x51>
            *left_store = start;
  104038:	8b 45 18             	mov    0x18(%ebp),%eax
  10403b:	8b 55 10             	mov    0x10(%ebp),%edx
  10403e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104040:	8b 45 10             	mov    0x10(%ebp),%eax
  104043:	8d 50 01             	lea    0x1(%eax),%edx
  104046:	89 55 10             	mov    %edx,0x10(%ebp)
  104049:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104050:	8b 45 14             	mov    0x14(%ebp),%eax
  104053:	01 d0                	add    %edx,%eax
  104055:	8b 00                	mov    (%eax),%eax
  104057:	83 e0 07             	and    $0x7,%eax
  10405a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10405d:	eb 03                	jmp    104062 <get_pgtable_items+0x73>
            start ++;
  10405f:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  104062:	8b 45 10             	mov    0x10(%ebp),%eax
  104065:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104068:	73 1d                	jae    104087 <get_pgtable_items+0x98>
  10406a:	8b 45 10             	mov    0x10(%ebp),%eax
  10406d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104074:	8b 45 14             	mov    0x14(%ebp),%eax
  104077:	01 d0                	add    %edx,%eax
  104079:	8b 00                	mov    (%eax),%eax
  10407b:	83 e0 07             	and    $0x7,%eax
  10407e:	89 c2                	mov    %eax,%edx
  104080:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104083:	39 c2                	cmp    %eax,%edx
  104085:	74 d8                	je     10405f <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
  104087:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10408b:	74 08                	je     104095 <get_pgtable_items+0xa6>
            *right_store = start;
  10408d:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104090:	8b 55 10             	mov    0x10(%ebp),%edx
  104093:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104095:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104098:	eb 05                	jmp    10409f <get_pgtable_items+0xb0>
    }
    return 0;
  10409a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10409f:	c9                   	leave  
  1040a0:	c3                   	ret    

001040a1 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  1040a1:	55                   	push   %ebp
  1040a2:	89 e5                	mov    %esp,%ebp
  1040a4:	57                   	push   %edi
  1040a5:	56                   	push   %esi
  1040a6:	53                   	push   %ebx
  1040a7:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  1040aa:	c7 04 24 50 7a 10 00 	movl   $0x107a50,(%esp)
  1040b1:	e8 e1 c1 ff ff       	call   100297 <cprintf>
    size_t left, right = 0, perm;
  1040b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1040bd:	e9 fa 00 00 00       	jmp    1041bc <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1040c5:	89 04 24             	mov    %eax,(%esp)
  1040c8:	e8 e0 fe ff ff       	call   103fad <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1040cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1040d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040d3:	29 d1                	sub    %edx,%ecx
  1040d5:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1040d7:	89 d6                	mov    %edx,%esi
  1040d9:	c1 e6 16             	shl    $0x16,%esi
  1040dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1040df:	89 d3                	mov    %edx,%ebx
  1040e1:	c1 e3 16             	shl    $0x16,%ebx
  1040e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040e7:	89 d1                	mov    %edx,%ecx
  1040e9:	c1 e1 16             	shl    $0x16,%ecx
  1040ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1040ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1040f2:	29 d7                	sub    %edx,%edi
  1040f4:	89 fa                	mov    %edi,%edx
  1040f6:	89 44 24 14          	mov    %eax,0x14(%esp)
  1040fa:	89 74 24 10          	mov    %esi,0x10(%esp)
  1040fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104102:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104106:	89 54 24 04          	mov    %edx,0x4(%esp)
  10410a:	c7 04 24 81 7a 10 00 	movl   $0x107a81,(%esp)
  104111:	e8 81 c1 ff ff       	call   100297 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  104116:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104119:	c1 e0 0a             	shl    $0xa,%eax
  10411c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  10411f:	eb 54                	jmp    104175 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104124:	89 04 24             	mov    %eax,(%esp)
  104127:	e8 81 fe ff ff       	call   103fad <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  10412c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10412f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104132:	29 d1                	sub    %edx,%ecx
  104134:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104136:	89 d6                	mov    %edx,%esi
  104138:	c1 e6 0c             	shl    $0xc,%esi
  10413b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10413e:	89 d3                	mov    %edx,%ebx
  104140:	c1 e3 0c             	shl    $0xc,%ebx
  104143:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104146:	89 d1                	mov    %edx,%ecx
  104148:	c1 e1 0c             	shl    $0xc,%ecx
  10414b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  10414e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104151:	29 d7                	sub    %edx,%edi
  104153:	89 fa                	mov    %edi,%edx
  104155:	89 44 24 14          	mov    %eax,0x14(%esp)
  104159:	89 74 24 10          	mov    %esi,0x10(%esp)
  10415d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104161:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104165:	89 54 24 04          	mov    %edx,0x4(%esp)
  104169:	c7 04 24 a0 7a 10 00 	movl   $0x107aa0,(%esp)
  104170:	e8 22 c1 ff ff       	call   100297 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104175:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10417a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10417d:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104180:	89 d3                	mov    %edx,%ebx
  104182:	c1 e3 0a             	shl    $0xa,%ebx
  104185:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104188:	89 d1                	mov    %edx,%ecx
  10418a:	c1 e1 0a             	shl    $0xa,%ecx
  10418d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104190:	89 54 24 14          	mov    %edx,0x14(%esp)
  104194:	8d 55 d8             	lea    -0x28(%ebp),%edx
  104197:	89 54 24 10          	mov    %edx,0x10(%esp)
  10419b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10419f:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1041a7:	89 0c 24             	mov    %ecx,(%esp)
  1041aa:	e8 40 fe ff ff       	call   103fef <get_pgtable_items>
  1041af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041b6:	0f 85 65 ff ff ff    	jne    104121 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1041bc:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1041c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1041c4:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1041c7:	89 54 24 14          	mov    %edx,0x14(%esp)
  1041cb:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1041ce:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1041d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1041da:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1041e1:	00 
  1041e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1041e9:	e8 01 fe ff ff       	call   103fef <get_pgtable_items>
  1041ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1041f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1041f5:	0f 85 c7 fe ff ff    	jne    1040c2 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1041fb:	c7 04 24 c4 7a 10 00 	movl   $0x107ac4,(%esp)
  104202:	e8 90 c0 ff ff       	call   100297 <cprintf>
}
  104207:	90                   	nop
  104208:	83 c4 4c             	add    $0x4c,%esp
  10420b:	5b                   	pop    %ebx
  10420c:	5e                   	pop    %esi
  10420d:	5f                   	pop    %edi
  10420e:	5d                   	pop    %ebp
  10420f:	c3                   	ret    

00104210 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  104210:	55                   	push   %ebp
  104211:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104213:	8b 45 08             	mov    0x8(%ebp),%eax
  104216:	8b 00                	mov    (%eax),%eax
}
  104218:	5d                   	pop    %ebp
  104219:	c3                   	ret    

0010421a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10421a:	55                   	push   %ebp
  10421b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  10421d:	8b 45 08             	mov    0x8(%ebp),%eax
  104220:	8b 55 0c             	mov    0xc(%ebp),%edx
  104223:	89 10                	mov    %edx,(%eax)
}
  104225:	90                   	nop
  104226:	5d                   	pop    %ebp
  104227:	c3                   	ret    

00104228 <fixsize>:
#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
  104228:	55                   	push   %ebp
  104229:	89 e5                	mov    %esp,%ebp
  size |= size >> 1;
  10422b:	8b 45 08             	mov    0x8(%ebp),%eax
  10422e:	d1 e8                	shr    %eax
  104230:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 2;
  104233:	8b 45 08             	mov    0x8(%ebp),%eax
  104236:	c1 e8 02             	shr    $0x2,%eax
  104239:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 4;
  10423c:	8b 45 08             	mov    0x8(%ebp),%eax
  10423f:	c1 e8 04             	shr    $0x4,%eax
  104242:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 8;
  104245:	8b 45 08             	mov    0x8(%ebp),%eax
  104248:	c1 e8 08             	shr    $0x8,%eax
  10424b:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 16;
  10424e:	8b 45 08             	mov    0x8(%ebp),%eax
  104251:	c1 e8 10             	shr    $0x10,%eax
  104254:	09 45 08             	or     %eax,0x8(%ebp)
  return size+1;
  104257:	8b 45 08             	mov    0x8(%ebp),%eax
  10425a:	40                   	inc    %eax
}
  10425b:	5d                   	pop    %ebp
  10425c:	c3                   	ret    

0010425d <buddy_init>:

struct allocRecord rec[80000];//存放偏移量的数组
int nr_block;//已分配的块数

static void buddy_init()
{
  10425d:	55                   	push   %ebp
  10425e:	89 e5                	mov    %esp,%ebp
  104260:	83 ec 10             	sub    $0x10,%esp
  104263:	c7 45 fc 40 93 1b 00 	movl   $0x1b9340,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10426a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10426d:	8b 55 fc             	mov    -0x4(%ebp),%edx
  104270:	89 50 04             	mov    %edx,0x4(%eax)
  104273:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104276:	8b 50 04             	mov    0x4(%eax),%edx
  104279:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10427c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free=0;
  10427e:	c7 05 48 93 1b 00 00 	movl   $0x0,0x1b9348
  104285:	00 00 00 
}
  104288:	90                   	nop
  104289:	c9                   	leave  
  10428a:	c3                   	ret    

0010428b <buddy2_new>:

//初始化二叉树上的节点
void buddy2_new( int size ) {
  10428b:	55                   	push   %ebp
  10428c:	89 e5                	mov    %esp,%ebp
  10428e:	83 ec 10             	sub    $0x10,%esp
  unsigned node_size;
  int i;
  nr_block=0;
  104291:	c7 05 20 cf 11 00 00 	movl   $0x0,0x11cf20
  104298:	00 00 00 
  if (size < 1 || !IS_POWER_OF_2(size))
  10429b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10429f:	7e 55                	jle    1042f6 <buddy2_new+0x6b>
  1042a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1042a4:	48                   	dec    %eax
  1042a5:	23 45 08             	and    0x8(%ebp),%eax
  1042a8:	85 c0                	test   %eax,%eax
  1042aa:	75 4a                	jne    1042f6 <buddy2_new+0x6b>
    return;

  root[0].size = size;
  1042ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1042af:	a3 40 cf 11 00       	mov    %eax,0x11cf40
  node_size = size * 2;
  1042b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1042b7:	01 c0                	add    %eax,%eax
  1042b9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  for (i = 0; i < 2 * size - 1; ++i) {
  1042bc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  1042c3:	eb 23                	jmp    1042e8 <buddy2_new+0x5d>
    if (IS_POWER_OF_2(i+1))
  1042c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1042c8:	40                   	inc    %eax
  1042c9:	23 45 f8             	and    -0x8(%ebp),%eax
  1042cc:	85 c0                	test   %eax,%eax
  1042ce:	75 08                	jne    1042d8 <buddy2_new+0x4d>
      node_size /= 2;
  1042d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1042d3:	d1 e8                	shr    %eax
  1042d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    root[i].longest = node_size;
  1042d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1042db:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1042de:	89 14 c5 44 cf 11 00 	mov    %edx,0x11cf44(,%eax,8)
    return;

  root[0].size = size;
  node_size = size * 2;

  for (i = 0; i < 2 * size - 1; ++i) {
  1042e5:	ff 45 f8             	incl   -0x8(%ebp)
  1042e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1042eb:	01 c0                	add    %eax,%eax
  1042ed:	48                   	dec    %eax
  1042ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1042f1:	7f d2                	jg     1042c5 <buddy2_new+0x3a>
    if (IS_POWER_OF_2(i+1))
      node_size /= 2;
    root[i].longest = node_size;
  }
  return;
  1042f3:	90                   	nop
  1042f4:	eb 01                	jmp    1042f7 <buddy2_new+0x6c>
void buddy2_new( int size ) {
  unsigned node_size;
  int i;
  nr_block=0;
  if (size < 1 || !IS_POWER_OF_2(size))
    return;
  1042f6:	90                   	nop
    if (IS_POWER_OF_2(i+1))
      node_size /= 2;
    root[i].longest = node_size;
  }
  return;
}
  1042f7:	c9                   	leave  
  1042f8:	c3                   	ret    

001042f9 <buddy_init_memmap>:

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
  1042f9:	55                   	push   %ebp
  1042fa:	89 e5                	mov    %esp,%ebp
  1042fc:	56                   	push   %esi
  1042fd:	53                   	push   %ebx
  1042fe:	83 ec 40             	sub    $0x40,%esp
    assert(n>0);
  104301:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104305:	75 24                	jne    10432b <buddy_init_memmap+0x32>
  104307:	c7 44 24 0c f8 7a 10 	movl   $0x107af8,0xc(%esp)
  10430e:	00 
  10430f:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104316:	00 
  104317:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
  10431e:	00 
  10431f:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104326:	e8 c3 c0 ff ff       	call   1003ee <__panic>
    struct Page* p=base;
  10432b:	8b 45 08             	mov    0x8(%ebp),%eax
  10432e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(;p!=base + n;p++)
  104331:	e9 dc 00 00 00       	jmp    104412 <buddy_init_memmap+0x119>
    {
        assert(PageReserved(p));
  104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104339:	83 c0 04             	add    $0x4,%eax
  10433c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  104343:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104346:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104349:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10434c:	0f a3 10             	bt     %edx,(%eax)
  10434f:	19 c0                	sbb    %eax,%eax
  104351:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
  104354:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  104358:	0f 95 c0             	setne  %al
  10435b:	0f b6 c0             	movzbl %al,%eax
  10435e:	85 c0                	test   %eax,%eax
  104360:	75 24                	jne    104386 <buddy_init_memmap+0x8d>
  104362:	c7 44 24 0c 21 7b 10 	movl   $0x107b21,0xc(%esp)
  104369:	00 
  10436a:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104371:	00 
  104372:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  104379:	00 
  10437a:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104381:	e8 68 c0 ff ff       	call   1003ee <__panic>
        p->flags = 0;
  104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104389:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property = 1;
  104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104393:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        set_page_ref(p, 0);   
  10439a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1043a1:	00 
  1043a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043a5:	89 04 24             	mov    %eax,(%esp)
  1043a8:	e8 6d fe ff ff       	call   10421a <set_page_ref>
        SetPageProperty(p);
  1043ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043b0:	83 c0 04             	add    $0x4,%eax
  1043b3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  1043ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1043bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  1043c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1043c3:	0f ab 10             	bts    %edx,(%eax)
        list_add_before(&free_list,&(p->page_link));     
  1043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1043c9:	83 c0 0c             	add    $0xc,%eax
  1043cc:	c7 45 f0 40 93 1b 00 	movl   $0x1b9340,-0x10(%ebp)
  1043d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  1043d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043d9:	8b 00                	mov    (%eax),%eax
  1043db:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1043de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1043e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1043e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1043e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1043ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043f0:	89 10                	mov    %edx,(%eax)
  1043f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1043f5:	8b 10                	mov    (%eax),%edx
  1043f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1043fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104400:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104403:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104406:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104409:	8b 55 d0             	mov    -0x30(%ebp),%edx
  10440c:	89 10                	mov    %edx,(%eax)
static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page* p=base;
    for(;p!=base + n;p++)
  10440e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104412:	8b 55 0c             	mov    0xc(%ebp),%edx
  104415:	89 d0                	mov    %edx,%eax
  104417:	c1 e0 02             	shl    $0x2,%eax
  10441a:	01 d0                	add    %edx,%eax
  10441c:	c1 e0 02             	shl    $0x2,%eax
  10441f:	89 c2                	mov    %eax,%edx
  104421:	8b 45 08             	mov    0x8(%ebp),%eax
  104424:	01 d0                	add    %edx,%eax
  104426:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104429:	0f 85 07 ff ff ff    	jne    104336 <buddy_init_memmap+0x3d>
        p->property = 1;
        set_page_ref(p, 0);   
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));     
    }
    nr_free += n;
  10442f:	8b 15 48 93 1b 00    	mov    0x1b9348,%edx
  104435:	8b 45 0c             	mov    0xc(%ebp),%eax
  104438:	01 d0                	add    %edx,%eax
  10443a:	a3 48 93 1b 00       	mov    %eax,0x1b9348
    int allocpages=UINT32_ROUND_DOWN(n);
  10443f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104442:	d1 e8                	shr    %eax
  104444:	0b 45 0c             	or     0xc(%ebp),%eax
  104447:	8b 55 0c             	mov    0xc(%ebp),%edx
  10444a:	d1 ea                	shr    %edx
  10444c:	0b 55 0c             	or     0xc(%ebp),%edx
  10444f:	c1 ea 02             	shr    $0x2,%edx
  104452:	09 d0                	or     %edx,%eax
  104454:	89 c1                	mov    %eax,%ecx
  104456:	8b 45 0c             	mov    0xc(%ebp),%eax
  104459:	d1 e8                	shr    %eax
  10445b:	0b 45 0c             	or     0xc(%ebp),%eax
  10445e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104461:	d1 ea                	shr    %edx
  104463:	0b 55 0c             	or     0xc(%ebp),%edx
  104466:	c1 ea 02             	shr    $0x2,%edx
  104469:	09 d0                	or     %edx,%eax
  10446b:	c1 e8 04             	shr    $0x4,%eax
  10446e:	09 c1                	or     %eax,%ecx
  104470:	8b 45 0c             	mov    0xc(%ebp),%eax
  104473:	d1 e8                	shr    %eax
  104475:	0b 45 0c             	or     0xc(%ebp),%eax
  104478:	8b 55 0c             	mov    0xc(%ebp),%edx
  10447b:	d1 ea                	shr    %edx
  10447d:	0b 55 0c             	or     0xc(%ebp),%edx
  104480:	c1 ea 02             	shr    $0x2,%edx
  104483:	09 d0                	or     %edx,%eax
  104485:	89 c3                	mov    %eax,%ebx
  104487:	8b 45 0c             	mov    0xc(%ebp),%eax
  10448a:	d1 e8                	shr    %eax
  10448c:	0b 45 0c             	or     0xc(%ebp),%eax
  10448f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104492:	d1 ea                	shr    %edx
  104494:	0b 55 0c             	or     0xc(%ebp),%edx
  104497:	c1 ea 02             	shr    $0x2,%edx
  10449a:	09 d0                	or     %edx,%eax
  10449c:	c1 e8 04             	shr    $0x4,%eax
  10449f:	09 d8                	or     %ebx,%eax
  1044a1:	c1 e8 08             	shr    $0x8,%eax
  1044a4:	09 c1                	or     %eax,%ecx
  1044a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044a9:	d1 e8                	shr    %eax
  1044ab:	0b 45 0c             	or     0xc(%ebp),%eax
  1044ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044b1:	d1 ea                	shr    %edx
  1044b3:	0b 55 0c             	or     0xc(%ebp),%edx
  1044b6:	c1 ea 02             	shr    $0x2,%edx
  1044b9:	09 d0                	or     %edx,%eax
  1044bb:	89 c3                	mov    %eax,%ebx
  1044bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044c0:	d1 e8                	shr    %eax
  1044c2:	0b 45 0c             	or     0xc(%ebp),%eax
  1044c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044c8:	d1 ea                	shr    %edx
  1044ca:	0b 55 0c             	or     0xc(%ebp),%edx
  1044cd:	c1 ea 02             	shr    $0x2,%edx
  1044d0:	09 d0                	or     %edx,%eax
  1044d2:	c1 e8 04             	shr    $0x4,%eax
  1044d5:	09 c3                	or     %eax,%ebx
  1044d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044da:	d1 e8                	shr    %eax
  1044dc:	0b 45 0c             	or     0xc(%ebp),%eax
  1044df:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044e2:	d1 ea                	shr    %edx
  1044e4:	0b 55 0c             	or     0xc(%ebp),%edx
  1044e7:	c1 ea 02             	shr    $0x2,%edx
  1044ea:	09 d0                	or     %edx,%eax
  1044ec:	89 c6                	mov    %eax,%esi
  1044ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044f1:	d1 e8                	shr    %eax
  1044f3:	0b 45 0c             	or     0xc(%ebp),%eax
  1044f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1044f9:	d1 ea                	shr    %edx
  1044fb:	0b 55 0c             	or     0xc(%ebp),%edx
  1044fe:	c1 ea 02             	shr    $0x2,%edx
  104501:	09 d0                	or     %edx,%eax
  104503:	c1 e8 04             	shr    $0x4,%eax
  104506:	09 f0                	or     %esi,%eax
  104508:	c1 e8 08             	shr    $0x8,%eax
  10450b:	09 d8                	or     %ebx,%eax
  10450d:	c1 e8 10             	shr    $0x10,%eax
  104510:	09 c8                	or     %ecx,%eax
  104512:	d1 e8                	shr    %eax
  104514:	23 45 0c             	and    0xc(%ebp),%eax
  104517:	85 c0                	test   %eax,%eax
  104519:	0f 84 dc 00 00 00    	je     1045fb <buddy_init_memmap+0x302>
  10451f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104522:	d1 e8                	shr    %eax
  104524:	0b 45 0c             	or     0xc(%ebp),%eax
  104527:	8b 55 0c             	mov    0xc(%ebp),%edx
  10452a:	d1 ea                	shr    %edx
  10452c:	0b 55 0c             	or     0xc(%ebp),%edx
  10452f:	c1 ea 02             	shr    $0x2,%edx
  104532:	09 d0                	or     %edx,%eax
  104534:	89 c1                	mov    %eax,%ecx
  104536:	8b 45 0c             	mov    0xc(%ebp),%eax
  104539:	d1 e8                	shr    %eax
  10453b:	0b 45 0c             	or     0xc(%ebp),%eax
  10453e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104541:	d1 ea                	shr    %edx
  104543:	0b 55 0c             	or     0xc(%ebp),%edx
  104546:	c1 ea 02             	shr    $0x2,%edx
  104549:	09 d0                	or     %edx,%eax
  10454b:	c1 e8 04             	shr    $0x4,%eax
  10454e:	09 c1                	or     %eax,%ecx
  104550:	8b 45 0c             	mov    0xc(%ebp),%eax
  104553:	d1 e8                	shr    %eax
  104555:	0b 45 0c             	or     0xc(%ebp),%eax
  104558:	8b 55 0c             	mov    0xc(%ebp),%edx
  10455b:	d1 ea                	shr    %edx
  10455d:	0b 55 0c             	or     0xc(%ebp),%edx
  104560:	c1 ea 02             	shr    $0x2,%edx
  104563:	09 d0                	or     %edx,%eax
  104565:	89 c3                	mov    %eax,%ebx
  104567:	8b 45 0c             	mov    0xc(%ebp),%eax
  10456a:	d1 e8                	shr    %eax
  10456c:	0b 45 0c             	or     0xc(%ebp),%eax
  10456f:	8b 55 0c             	mov    0xc(%ebp),%edx
  104572:	d1 ea                	shr    %edx
  104574:	0b 55 0c             	or     0xc(%ebp),%edx
  104577:	c1 ea 02             	shr    $0x2,%edx
  10457a:	09 d0                	or     %edx,%eax
  10457c:	c1 e8 04             	shr    $0x4,%eax
  10457f:	09 d8                	or     %ebx,%eax
  104581:	c1 e8 08             	shr    $0x8,%eax
  104584:	09 c1                	or     %eax,%ecx
  104586:	8b 45 0c             	mov    0xc(%ebp),%eax
  104589:	d1 e8                	shr    %eax
  10458b:	0b 45 0c             	or     0xc(%ebp),%eax
  10458e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104591:	d1 ea                	shr    %edx
  104593:	0b 55 0c             	or     0xc(%ebp),%edx
  104596:	c1 ea 02             	shr    $0x2,%edx
  104599:	09 d0                	or     %edx,%eax
  10459b:	89 c3                	mov    %eax,%ebx
  10459d:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045a0:	d1 e8                	shr    %eax
  1045a2:	0b 45 0c             	or     0xc(%ebp),%eax
  1045a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045a8:	d1 ea                	shr    %edx
  1045aa:	0b 55 0c             	or     0xc(%ebp),%edx
  1045ad:	c1 ea 02             	shr    $0x2,%edx
  1045b0:	09 d0                	or     %edx,%eax
  1045b2:	c1 e8 04             	shr    $0x4,%eax
  1045b5:	09 c3                	or     %eax,%ebx
  1045b7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045ba:	d1 e8                	shr    %eax
  1045bc:	0b 45 0c             	or     0xc(%ebp),%eax
  1045bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045c2:	d1 ea                	shr    %edx
  1045c4:	0b 55 0c             	or     0xc(%ebp),%edx
  1045c7:	c1 ea 02             	shr    $0x2,%edx
  1045ca:	09 d0                	or     %edx,%eax
  1045cc:	89 c6                	mov    %eax,%esi
  1045ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045d1:	d1 e8                	shr    %eax
  1045d3:	0b 45 0c             	or     0xc(%ebp),%eax
  1045d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  1045d9:	d1 ea                	shr    %edx
  1045db:	0b 55 0c             	or     0xc(%ebp),%edx
  1045de:	c1 ea 02             	shr    $0x2,%edx
  1045e1:	09 d0                	or     %edx,%eax
  1045e3:	c1 e8 04             	shr    $0x4,%eax
  1045e6:	09 f0                	or     %esi,%eax
  1045e8:	c1 e8 08             	shr    $0x8,%eax
  1045eb:	09 d8                	or     %ebx,%eax
  1045ed:	c1 e8 10             	shr    $0x10,%eax
  1045f0:	09 c8                	or     %ecx,%eax
  1045f2:	d1 e8                	shr    %eax
  1045f4:	f7 d0                	not    %eax
  1045f6:	23 45 0c             	and    0xc(%ebp),%eax
  1045f9:	eb 03                	jmp    1045fe <buddy_init_memmap+0x305>
  1045fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  1045fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    buddy2_new(allocpages);
  104601:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104604:	89 04 24             	mov    %eax,(%esp)
  104607:	e8 7f fc ff ff       	call   10428b <buddy2_new>
}
  10460c:	90                   	nop
  10460d:	83 c4 40             	add    $0x40,%esp
  104610:	5b                   	pop    %ebx
  104611:	5e                   	pop    %esi
  104612:	5d                   	pop    %ebp
  104613:	c3                   	ret    

00104614 <buddy2_alloc>:
//内存分配
int buddy2_alloc(struct buddy2* self, int size) {
  104614:	55                   	push   %ebp
  104615:	89 e5                	mov    %esp,%ebp
  104617:	53                   	push   %ebx
  104618:	83 ec 14             	sub    $0x14,%esp
  unsigned index = 0;//节点的标号
  10461b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  unsigned node_size;
  unsigned offset = 0;
  104622:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  if (self==NULL)//无法分配
  104629:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10462d:	75 0a                	jne    104639 <buddy2_alloc+0x25>
    return -1;
  10462f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  104634:	e9 64 01 00 00       	jmp    10479d <buddy2_alloc+0x189>

  if (size <= 0)//分配不合理
  104639:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10463d:	7f 09                	jg     104648 <buddy2_alloc+0x34>
    size = 1;
  10463f:	c7 45 0c 01 00 00 00 	movl   $0x1,0xc(%ebp)
  104646:	eb 19                	jmp    104661 <buddy2_alloc+0x4d>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
  104648:	8b 45 0c             	mov    0xc(%ebp),%eax
  10464b:	48                   	dec    %eax
  10464c:	23 45 0c             	and    0xc(%ebp),%eax
  10464f:	85 c0                	test   %eax,%eax
  104651:	74 0e                	je     104661 <buddy2_alloc+0x4d>
    size = fixsize(size);
  104653:	8b 45 0c             	mov    0xc(%ebp),%eax
  104656:	89 04 24             	mov    %eax,(%esp)
  104659:	e8 ca fb ff ff       	call   104228 <fixsize>
  10465e:	89 45 0c             	mov    %eax,0xc(%ebp)

  if (self[index].longest < size)//可分配内存不足
  104661:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104664:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  10466b:	8b 45 08             	mov    0x8(%ebp),%eax
  10466e:	01 d0                	add    %edx,%eax
  104670:	8b 50 04             	mov    0x4(%eax),%edx
  104673:	8b 45 0c             	mov    0xc(%ebp),%eax
  104676:	39 c2                	cmp    %eax,%edx
  104678:	73 0a                	jae    104684 <buddy2_alloc+0x70>
    return -1;
  10467a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10467f:	e9 19 01 00 00       	jmp    10479d <buddy2_alloc+0x189>

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
  104684:	8b 45 08             	mov    0x8(%ebp),%eax
  104687:	8b 00                	mov    (%eax),%eax
  104689:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10468c:	e9 85 00 00 00       	jmp    104716 <buddy2_alloc+0x102>
    if (self[LEFT_LEAF(index)].longest >= size)
  104691:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104694:	c1 e0 04             	shl    $0x4,%eax
  104697:	8d 50 08             	lea    0x8(%eax),%edx
  10469a:	8b 45 08             	mov    0x8(%ebp),%eax
  10469d:	01 d0                	add    %edx,%eax
  10469f:	8b 50 04             	mov    0x4(%eax),%edx
  1046a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046a5:	39 c2                	cmp    %eax,%edx
  1046a7:	72 5c                	jb     104705 <buddy2_alloc+0xf1>
    {
       if(self[RIGHT_LEAF(index)].longest>=size)
  1046a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046ac:	40                   	inc    %eax
  1046ad:	c1 e0 04             	shl    $0x4,%eax
  1046b0:	89 c2                	mov    %eax,%edx
  1046b2:	8b 45 08             	mov    0x8(%ebp),%eax
  1046b5:	01 d0                	add    %edx,%eax
  1046b7:	8b 50 04             	mov    0x4(%eax),%edx
  1046ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046bd:	39 c2                	cmp    %eax,%edx
  1046bf:	72 39                	jb     1046fa <buddy2_alloc+0xe6>
        {
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
  1046c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046c4:	c1 e0 04             	shl    $0x4,%eax
  1046c7:	8d 50 08             	lea    0x8(%eax),%edx
  1046ca:	8b 45 08             	mov    0x8(%ebp),%eax
  1046cd:	01 d0                	add    %edx,%eax
  1046cf:	8b 50 04             	mov    0x4(%eax),%edx
  1046d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046d5:	40                   	inc    %eax
  1046d6:	c1 e0 04             	shl    $0x4,%eax
  1046d9:	89 c1                	mov    %eax,%ecx
  1046db:	8b 45 08             	mov    0x8(%ebp),%eax
  1046de:	01 c8                	add    %ecx,%eax
  1046e0:	8b 40 04             	mov    0x4(%eax),%eax
  1046e3:	39 c2                	cmp    %eax,%edx
  1046e5:	77 08                	ja     1046ef <buddy2_alloc+0xdb>
  1046e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046ea:	01 c0                	add    %eax,%eax
  1046ec:	40                   	inc    %eax
  1046ed:	eb 06                	jmp    1046f5 <buddy2_alloc+0xe1>
  1046ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046f2:	40                   	inc    %eax
  1046f3:	01 c0                	add    %eax,%eax
  1046f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1046f8:	eb 14                	jmp    10470e <buddy2_alloc+0xfa>
         //找到两个相符合的节点中内存较小的结点
        }
       else
       {
         index=LEFT_LEAF(index);
  1046fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1046fd:	01 c0                	add    %eax,%eax
  1046ff:	40                   	inc    %eax
  104700:	89 45 f8             	mov    %eax,-0x8(%ebp)
  104703:	eb 09                	jmp    10470e <buddy2_alloc+0xfa>
       }  
    }
    else
      index = RIGHT_LEAF(index);
  104705:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104708:	40                   	inc    %eax
  104709:	01 c0                	add    %eax,%eax
  10470b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    size = fixsize(size);

  if (self[index].longest < size)//可分配内存不足
    return -1;

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
  10470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104711:	d1 e8                	shr    %eax
  104713:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104716:	8b 45 0c             	mov    0xc(%ebp),%eax
  104719:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10471c:	0f 85 6f ff ff ff    	jne    104691 <buddy2_alloc+0x7d>
    }
    else
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  104722:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104725:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  10472c:	8b 45 08             	mov    0x8(%ebp),%eax
  10472f:	01 d0                	add    %edx,%eax
  104731:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  offset = (index + 1) * node_size - self->size;
  104738:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10473b:	40                   	inc    %eax
  10473c:	0f af 45 f4          	imul   -0xc(%ebp),%eax
  104740:	89 c2                	mov    %eax,%edx
  104742:	8b 45 08             	mov    0x8(%ebp),%eax
  104745:	8b 00                	mov    (%eax),%eax
  104747:	29 c2                	sub    %eax,%edx
  104749:	89 d0                	mov    %edx,%eax
  10474b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while (index) {
  10474e:	eb 44                	jmp    104794 <buddy2_alloc+0x180>
    index = PARENT(index);
  104750:	8b 45 f8             	mov    -0x8(%ebp),%eax
  104753:	40                   	inc    %eax
  104754:	d1 e8                	shr    %eax
  104756:	48                   	dec    %eax
  104757:	89 45 f8             	mov    %eax,-0x8(%ebp)
    self[index].longest = 
  10475a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10475d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104764:	8b 45 08             	mov    0x8(%ebp),%eax
  104767:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  10476a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10476d:	40                   	inc    %eax
  10476e:	c1 e0 04             	shl    $0x4,%eax
  104771:	89 c2                	mov    %eax,%edx
  104773:	8b 45 08             	mov    0x8(%ebp),%eax
  104776:	01 d0                	add    %edx,%eax
  104778:	8b 50 04             	mov    0x4(%eax),%edx
  10477b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10477e:	c1 e0 04             	shl    $0x4,%eax
  104781:	8d 58 08             	lea    0x8(%eax),%ebx
  104784:	8b 45 08             	mov    0x8(%ebp),%eax
  104787:	01 d8                	add    %ebx,%eax
  104789:	8b 40 04             	mov    0x4(%eax),%eax
  10478c:	39 c2                	cmp    %eax,%edx
  10478e:	0f 43 c2             	cmovae %edx,%eax

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
    index = PARENT(index);
    self[index].longest = 
  104791:	89 41 04             	mov    %eax,0x4(%ecx)
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
  104794:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
  104798:	75 b6                	jne    104750 <buddy2_alloc+0x13c>
    index = PARENT(index);
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  }
//向上刷新，修改先祖结点的数值
  return offset;
  10479a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  10479d:	83 c4 14             	add    $0x14,%esp
  1047a0:	5b                   	pop    %ebx
  1047a1:	5d                   	pop    %ebp
  1047a2:	c3                   	ret    

001047a3 <buddy_alloc_pages>:

static struct Page*
buddy_alloc_pages(size_t n){
  1047a3:	55                   	push   %ebp
  1047a4:	89 e5                	mov    %esp,%ebp
  1047a6:	53                   	push   %ebx
  1047a7:	83 ec 44             	sub    $0x44,%esp
    assert(n>0);
  1047aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1047ae:	75 24                	jne    1047d4 <buddy_alloc_pages+0x31>
  1047b0:	c7 44 24 0c f8 7a 10 	movl   $0x107af8,0xc(%esp)
  1047b7:	00 
  1047b8:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  1047bf:	00 
  1047c0:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  1047c7:	00 
  1047c8:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  1047cf:	e8 1a bc ff ff       	call   1003ee <__panic>
    if(n>nr_free)
  1047d4:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  1047d9:	3b 45 08             	cmp    0x8(%ebp),%eax
  1047dc:	73 0a                	jae    1047e8 <buddy_alloc_pages+0x45>
        return NULL;
  1047de:	b8 00 00 00 00       	mov    $0x0,%eax
  1047e3:	e9 41 01 00 00       	jmp    104929 <buddy_alloc_pages+0x186>
    struct Page* page=NULL;
  1047e8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    struct Page* p;
    list_entry_t *le=&free_list,*len;
  1047ef:	c7 45 f4 40 93 1b 00 	movl   $0x1b9340,-0xc(%ebp)
    rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
  1047f6:	8b 1d 20 cf 11 00    	mov    0x11cf20,%ebx
  1047fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1047ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  104803:	c7 04 24 40 cf 11 00 	movl   $0x11cf40,(%esp)
  10480a:	e8 05 fe ff ff       	call   104614 <buddy2_alloc>
  10480f:	89 c2                	mov    %eax,%edx
  104811:	89 d8                	mov    %ebx,%eax
  104813:	01 c0                	add    %eax,%eax
  104815:	01 d8                	add    %ebx,%eax
  104817:	c1 e0 02             	shl    $0x2,%eax
  10481a:	05 64 93 1b 00       	add    $0x1b9364,%eax
  10481f:	89 10                	mov    %edx,(%eax)
    int i;
    for(i=0;i<rec[nr_block].offset+1;i++)
  104821:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  104828:	eb 12                	jmp    10483c <buddy_alloc_pages+0x99>
  10482a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10482d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104830:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104833:	8b 40 04             	mov    0x4(%eax),%eax
        le=list_next(le);
  104836:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page* page=NULL;
    struct Page* p;
    list_entry_t *le=&free_list,*len;
    rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
    int i;
    for(i=0;i<rec[nr_block].offset+1;i++)
  104839:	ff 45 f0             	incl   -0x10(%ebp)
  10483c:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  104842:	89 d0                	mov    %edx,%eax
  104844:	01 c0                	add    %eax,%eax
  104846:	01 d0                	add    %edx,%eax
  104848:	c1 e0 02             	shl    $0x2,%eax
  10484b:	05 64 93 1b 00       	add    $0x1b9364,%eax
  104850:	8b 00                	mov    (%eax),%eax
  104852:	40                   	inc    %eax
  104853:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104856:	7f d2                	jg     10482a <buddy_alloc_pages+0x87>
        le=list_next(le);
    page=le2page(le,page_link);
  104858:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10485b:	83 e8 0c             	sub    $0xc,%eax
  10485e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int allocpages;
    if(!IS_POWER_OF_2(n))
  104861:	8b 45 08             	mov    0x8(%ebp),%eax
  104864:	48                   	dec    %eax
  104865:	23 45 08             	and    0x8(%ebp),%eax
  104868:	85 c0                	test   %eax,%eax
  10486a:	74 10                	je     10487c <buddy_alloc_pages+0xd9>
        allocpages=fixsize(n);
  10486c:	8b 45 08             	mov    0x8(%ebp),%eax
  10486f:	89 04 24             	mov    %eax,(%esp)
  104872:	e8 b1 f9 ff ff       	call   104228 <fixsize>
  104877:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10487a:	eb 06                	jmp    104882 <buddy_alloc_pages+0xdf>
    else
    {
        allocpages=n;
  10487c:	8b 45 08             	mov    0x8(%ebp),%eax
  10487f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    }
    //根据需求n得到块大小
    rec[nr_block].base=page;//记录分配块首页
  104882:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  104888:	89 d0                	mov    %edx,%eax
  10488a:	01 c0                	add    %eax,%eax
  10488c:	01 d0                	add    %edx,%eax
  10488e:	c1 e0 02             	shl    $0x2,%eax
  104891:	8d 90 60 93 1b 00    	lea    0x1b9360(%eax),%edx
  104897:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10489a:	89 02                	mov    %eax,(%edx)
    rec[nr_block].nr=allocpages;//记录分配的页数
  10489c:	8b 15 20 cf 11 00    	mov    0x11cf20,%edx
  1048a2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1048a5:	89 d0                	mov    %edx,%eax
  1048a7:	01 c0                	add    %eax,%eax
  1048a9:	01 d0                	add    %edx,%eax
  1048ab:	c1 e0 02             	shl    $0x2,%eax
  1048ae:	05 68 93 1b 00       	add    $0x1b9368,%eax
  1048b3:	89 08                	mov    %ecx,(%eax)
    nr_block++;
  1048b5:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  1048ba:	40                   	inc    %eax
  1048bb:	a3 20 cf 11 00       	mov    %eax,0x11cf20
    for(i=0;i<allocpages;i++)
  1048c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  1048c7:	eb 3a                	jmp    104903 <buddy_alloc_pages+0x160>
  1048c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  1048cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1048d2:	8b 40 04             	mov    0x4(%eax),%eax
    {
        len=list_next(le);
  1048d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
        p=le2page(le,page_link);
  1048d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048db:	83 e8 0c             	sub    $0xc,%eax
  1048de:	89 45 dc             	mov    %eax,-0x24(%ebp)
        ClearPageProperty(p);
  1048e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1048e4:	83 c0 04             	add    $0x4,%eax
  1048e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
  1048ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1048f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1048f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1048f7:	0f b3 10             	btr    %edx,(%eax)
        le=len;
  1048fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1048fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    //根据需求n得到块大小
    rec[nr_block].base=page;//记录分配块首页
    rec[nr_block].nr=allocpages;//记录分配的页数
    nr_block++;
    for(i=0;i<allocpages;i++)
  104900:	ff 45 f0             	incl   -0x10(%ebp)
  104903:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104906:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104909:	7c be                	jl     1048c9 <buddy_alloc_pages+0x126>
        len=list_next(le);
        p=le2page(le,page_link);
        ClearPageProperty(p);
        le=len;
    }//修改每一页的状态
    nr_free-=allocpages;//减去已被分配的页数
  10490b:	8b 15 48 93 1b 00    	mov    0x1b9348,%edx
  104911:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104914:	29 c2                	sub    %eax,%edx
  104916:	89 d0                	mov    %edx,%eax
  104918:	a3 48 93 1b 00       	mov    %eax,0x1b9348
    page->property=n;
  10491d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104920:	8b 55 08             	mov    0x8(%ebp),%edx
  104923:	89 50 08             	mov    %edx,0x8(%eax)
    return page;
  104926:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
  104929:	83 c4 44             	add    $0x44,%esp
  10492c:	5b                   	pop    %ebx
  10492d:	5d                   	pop    %ebp
  10492e:	c3                   	ret    

0010492f <buddy_free_pages>:

void buddy_free_pages(struct Page* base, size_t n) {
  10492f:	55                   	push   %ebp
  104930:	89 e5                	mov    %esp,%ebp
  104932:	83 ec 58             	sub    $0x58,%esp
    unsigned node_size, index = 0;
  104935:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    unsigned left_longest, right_longest;
    struct buddy2* self=root;
  10493c:	c7 45 e0 40 cf 11 00 	movl   $0x11cf40,-0x20(%ebp)
  104943:	c7 45 bc 40 93 1b 00 	movl   $0x1b9340,-0x44(%ebp)
  10494a:	8b 45 bc             	mov    -0x44(%ebp),%eax
  10494d:	8b 40 04             	mov    0x4(%eax),%eax

    list_entry_t *le=list_next(&free_list);
  104950:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int i=0;
  104953:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    for(i=0;i<nr_block;i++)//找到块
  10495a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104961:	eb 1b                	jmp    10497e <buddy_free_pages+0x4f>
    {
    if(rec[i].base==base)
  104963:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104966:	89 d0                	mov    %edx,%eax
  104968:	01 c0                	add    %eax,%eax
  10496a:	01 d0                	add    %edx,%eax
  10496c:	c1 e0 02             	shl    $0x2,%eax
  10496f:	05 60 93 1b 00       	add    $0x1b9360,%eax
  104974:	8b 00                	mov    (%eax),%eax
  104976:	3b 45 08             	cmp    0x8(%ebp),%eax
  104979:	74 0f                	je     10498a <buddy_free_pages+0x5b>
    unsigned left_longest, right_longest;
    struct buddy2* self=root;

    list_entry_t *le=list_next(&free_list);
    int i=0;
    for(i=0;i<nr_block;i++)//找到块
  10497b:	ff 45 e8             	incl   -0x18(%ebp)
  10497e:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  104983:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104986:	7c db                	jl     104963 <buddy_free_pages+0x34>
  104988:	eb 01                	jmp    10498b <buddy_free_pages+0x5c>
    {
    if(rec[i].base==base)
        break;
  10498a:	90                   	nop
    }
    int offset=rec[i].offset;
  10498b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10498e:	89 d0                	mov    %edx,%eax
  104990:	01 c0                	add    %eax,%eax
  104992:	01 d0                	add    %edx,%eax
  104994:	c1 e0 02             	shl    $0x2,%eax
  104997:	05 64 93 1b 00       	add    $0x1b9364,%eax
  10499c:	8b 00                	mov    (%eax),%eax
  10499e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int pos=i;//暂存i
  1049a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1049a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    i=0;
  1049a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while(i<offset)
  1049ae:	eb 12                	jmp    1049c2 <buddy_free_pages+0x93>
  1049b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1049b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1049b9:	8b 40 04             	mov    0x4(%eax),%eax
    {
    le=list_next(le);
  1049bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    i++;
  1049bf:	ff 45 e8             	incl   -0x18(%ebp)
        break;
    }
    int offset=rec[i].offset;
    int pos=i;//暂存i
    i=0;
    while(i<offset)
  1049c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1049c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  1049c8:	7c e6                	jl     1049b0 <buddy_free_pages+0x81>
    {
    le=list_next(le);
    i++;
    }
    int allocpages;
    if(!IS_POWER_OF_2(n))
  1049ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1049cd:	48                   	dec    %eax
  1049ce:	23 45 0c             	and    0xc(%ebp),%eax
  1049d1:	85 c0                	test   %eax,%eax
  1049d3:	74 10                	je     1049e5 <buddy_free_pages+0xb6>
    allocpages=fixsize(n);
  1049d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1049d8:	89 04 24             	mov    %eax,(%esp)
  1049db:	e8 48 f8 ff ff       	call   104228 <fixsize>
  1049e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1049e3:	eb 06                	jmp    1049eb <buddy_free_pages+0xbc>
    else
    {
        allocpages=n;
  1049e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1049e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    assert(self && offset >= 0 && offset < self->size);//是否合法
  1049eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1049ef:	74 12                	je     104a03 <buddy_free_pages+0xd4>
  1049f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  1049f5:	78 0c                	js     104a03 <buddy_free_pages+0xd4>
  1049f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1049fa:	8b 10                	mov    (%eax),%edx
  1049fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1049ff:	39 c2                	cmp    %eax,%edx
  104a01:	77 24                	ja     104a27 <buddy_free_pages+0xf8>
  104a03:	c7 44 24 0c 34 7b 10 	movl   $0x107b34,0xc(%esp)
  104a0a:	00 
  104a0b:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104a12:	00 
  104a13:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  104a1a:	00 
  104a1b:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104a22:	e8 c7 b9 ff ff       	call   1003ee <__panic>
    node_size = 1;
  104a27:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    index = offset + self->size - 1;
  104a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a31:	8b 10                	mov    (%eax),%edx
  104a33:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104a36:	01 d0                	add    %edx,%eax
  104a38:	48                   	dec    %eax
  104a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    nr_free+=allocpages;//更新空闲页的数量
  104a3c:	8b 15 48 93 1b 00    	mov    0x1b9348,%edx
  104a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a45:	01 d0                	add    %edx,%eax
  104a47:	a3 48 93 1b 00       	mov    %eax,0x1b9348
    struct Page* p;
    self[index].longest = allocpages;
  104a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104a4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104a56:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104a59:	01 c2                	add    %eax,%edx
  104a5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104a5e:	89 42 04             	mov    %eax,0x4(%edx)
    for(i=0;i<allocpages;i++)//回收已分配的页
  104a61:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  104a68:	eb 48                	jmp    104ab2 <buddy_free_pages+0x183>
    {
        p=le2page(le,page_link);
  104a6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a6d:	83 e8 0c             	sub    $0xc,%eax
  104a70:	89 45 cc             	mov    %eax,-0x34(%ebp)
        p->flags=0;
  104a73:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104a76:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property=1;
  104a7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104a80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        SetPageProperty(p);
  104a87:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104a8a:	83 c0 04             	add    $0x4,%eax
  104a8d:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  104a94:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104a97:	8b 45 b8             	mov    -0x48(%ebp),%eax
  104a9a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  104a9d:	0f ab 10             	bts    %edx,(%eax)
  104aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104aa3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104aa6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104aa9:	8b 40 04             	mov    0x4(%eax),%eax
        le=list_next(le);
  104aac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    node_size = 1;
    index = offset + self->size - 1;
    nr_free+=allocpages;//更新空闲页的数量
    struct Page* p;
    self[index].longest = allocpages;
    for(i=0;i<allocpages;i++)//回收已分配的页
  104aaf:	ff 45 e8             	incl   -0x18(%ebp)
  104ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ab5:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  104ab8:	7c b0                	jl     104a6a <buddy_free_pages+0x13b>
        p->flags=0;
        p->property=1;
        SetPageProperty(p);
        le=list_next(le);
    }
    while (index) {//向上合并，修改先祖节点的记录值
  104aba:	eb 75                	jmp    104b31 <buddy_free_pages+0x202>
    index = PARENT(index);
  104abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104abf:	40                   	inc    %eax
  104ac0:	d1 e8                	shr    %eax
  104ac2:	48                   	dec    %eax
  104ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    node_size *= 2;
  104ac6:	d1 65 f4             	shll   -0xc(%ebp)

    left_longest = self[LEFT_LEAF(index)].longest;
  104ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104acc:	c1 e0 04             	shl    $0x4,%eax
  104acf:	8d 50 08             	lea    0x8(%eax),%edx
  104ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ad5:	01 d0                	add    %edx,%eax
  104ad7:	8b 40 04             	mov    0x4(%eax),%eax
  104ada:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    right_longest = self[RIGHT_LEAF(index)].longest;
  104add:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ae0:	40                   	inc    %eax
  104ae1:	c1 e0 04             	shl    $0x4,%eax
  104ae4:	89 c2                	mov    %eax,%edx
  104ae6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104ae9:	01 d0                	add    %edx,%eax
  104aeb:	8b 40 04             	mov    0x4(%eax),%eax
  104aee:	89 45 c0             	mov    %eax,-0x40(%ebp)

    if (left_longest + right_longest == node_size) 
  104af1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  104af4:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104af7:	01 d0                	add    %edx,%eax
  104af9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104afc:	75 17                	jne    104b15 <buddy_free_pages+0x1e6>
        self[index].longest = node_size;
  104afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b01:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104b08:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b0b:	01 c2                	add    %eax,%edx
  104b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b10:	89 42 04             	mov    %eax,0x4(%edx)
  104b13:	eb 1c                	jmp    104b31 <buddy_free_pages+0x202>
    else
        self[index].longest = MAX(left_longest, right_longest);
  104b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
  104b1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104b22:	01 c2                	add    %eax,%edx
  104b24:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104b27:	39 45 c0             	cmp    %eax,-0x40(%ebp)
  104b2a:	0f 43 45 c0          	cmovae -0x40(%ebp),%eax
  104b2e:	89 42 04             	mov    %eax,0x4(%edx)
        p->flags=0;
        p->property=1;
        SetPageProperty(p);
        le=list_next(le);
    }
    while (index) {//向上合并，修改先祖节点的记录值
  104b31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b35:	75 85                	jne    104abc <buddy_free_pages+0x18d>
    if (left_longest + right_longest == node_size) 
        self[index].longest = node_size;
    else
        self[index].longest = MAX(left_longest, right_longest);
    }
    for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
  104b37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104b3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104b3d:	eb 39                	jmp    104b78 <buddy_free_pages+0x249>
    {
    rec[i]=rec[i+1];
  104b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104b42:	8d 48 01             	lea    0x1(%eax),%ecx
  104b45:	8b 55 e8             	mov    -0x18(%ebp),%edx
  104b48:	89 d0                	mov    %edx,%eax
  104b4a:	01 c0                	add    %eax,%eax
  104b4c:	01 d0                	add    %edx,%eax
  104b4e:	c1 e0 02             	shl    $0x2,%eax
  104b51:	8d 90 60 93 1b 00    	lea    0x1b9360(%eax),%edx
  104b57:	89 c8                	mov    %ecx,%eax
  104b59:	01 c0                	add    %eax,%eax
  104b5b:	01 c8                	add    %ecx,%eax
  104b5d:	c1 e0 02             	shl    $0x2,%eax
  104b60:	05 60 93 1b 00       	add    $0x1b9360,%eax
  104b65:	8b 08                	mov    (%eax),%ecx
  104b67:	89 0a                	mov    %ecx,(%edx)
  104b69:	8b 48 04             	mov    0x4(%eax),%ecx
  104b6c:	89 4a 04             	mov    %ecx,0x4(%edx)
  104b6f:	8b 40 08             	mov    0x8(%eax),%eax
  104b72:	89 42 08             	mov    %eax,0x8(%edx)
    if (left_longest + right_longest == node_size) 
        self[index].longest = node_size;
    else
        self[index].longest = MAX(left_longest, right_longest);
    }
    for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
  104b75:	ff 45 e8             	incl   -0x18(%ebp)
  104b78:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  104b7d:	48                   	dec    %eax
  104b7e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  104b81:	7f bc                	jg     104b3f <buddy_free_pages+0x210>
    {
    rec[i]=rec[i+1];
    }
    nr_block--;//更新分配块数的值
  104b83:	a1 20 cf 11 00       	mov    0x11cf20,%eax
  104b88:	48                   	dec    %eax
  104b89:	a3 20 cf 11 00       	mov    %eax,0x11cf20
}
  104b8e:	90                   	nop
  104b8f:	c9                   	leave  
  104b90:	c3                   	ret    

00104b91 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
  104b91:	55                   	push   %ebp
  104b92:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104b94:	a1 48 93 1b 00       	mov    0x1b9348,%eax
}
  104b99:	5d                   	pop    %ebp
  104b9a:	c3                   	ret    

00104b9b <buddy_check>:

//以下是一个测试函数
static void

buddy_check(void) {
  104b9b:	55                   	push   %ebp
  104b9c:	89 e5                	mov    %esp,%ebp
  104b9e:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;
  104ba1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104bb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104bba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104bbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert((p0 = alloc_page()) != NULL);
  104bc0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104bc7:	e8 a4 df ff ff       	call   102b70 <alloc_pages>
  104bcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104bcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  104bd3:	75 24                	jne    104bf9 <buddy_check+0x5e>
  104bd5:	c7 44 24 0c 5f 7b 10 	movl   $0x107b5f,0xc(%esp)
  104bdc:	00 
  104bdd:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104be4:	00 
  104be5:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
  104bec:	00 
  104bed:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104bf4:	e8 f5 b7 ff ff       	call   1003ee <__panic>
    assert((A = alloc_page()) != NULL);
  104bf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c00:	e8 6b df ff ff       	call   102b70 <alloc_pages>
  104c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104c08:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  104c0c:	75 24                	jne    104c32 <buddy_check+0x97>
  104c0e:	c7 44 24 0c 7b 7b 10 	movl   $0x107b7b,0xc(%esp)
  104c15:	00 
  104c16:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104c1d:	00 
  104c1e:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
  104c25:	00 
  104c26:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104c2d:	e8 bc b7 ff ff       	call   1003ee <__panic>
    assert((B = alloc_page()) != NULL);
  104c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104c39:	e8 32 df ff ff       	call   102b70 <alloc_pages>
  104c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104c45:	75 24                	jne    104c6b <buddy_check+0xd0>
  104c47:	c7 44 24 0c 96 7b 10 	movl   $0x107b96,0xc(%esp)
  104c4e:	00 
  104c4f:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104c56:	00 
  104c57:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
  104c5e:	00 
  104c5f:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104c66:	e8 83 b7 ff ff       	call   1003ee <__panic>

    assert(p0 != A && p0 != B && A != B);
  104c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c6e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  104c71:	74 10                	je     104c83 <buddy_check+0xe8>
  104c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104c76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104c79:	74 08                	je     104c83 <buddy_check+0xe8>
  104c7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104c7e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104c81:	75 24                	jne    104ca7 <buddy_check+0x10c>
  104c83:	c7 44 24 0c b1 7b 10 	movl   $0x107bb1,0xc(%esp)
  104c8a:	00 
  104c8b:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104c92:	00 
  104c93:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
  104c9a:	00 
  104c9b:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104ca2:	e8 47 b7 ff ff       	call   1003ee <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
  104ca7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104caa:	89 04 24             	mov    %eax,(%esp)
  104cad:	e8 5e f5 ff ff       	call   104210 <page_ref>
  104cb2:	85 c0                	test   %eax,%eax
  104cb4:	75 1e                	jne    104cd4 <buddy_check+0x139>
  104cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104cb9:	89 04 24             	mov    %eax,(%esp)
  104cbc:	e8 4f f5 ff ff       	call   104210 <page_ref>
  104cc1:	85 c0                	test   %eax,%eax
  104cc3:	75 0f                	jne    104cd4 <buddy_check+0x139>
  104cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104cc8:	89 04 24             	mov    %eax,(%esp)
  104ccb:	e8 40 f5 ff ff       	call   104210 <page_ref>
  104cd0:	85 c0                	test   %eax,%eax
  104cd2:	74 24                	je     104cf8 <buddy_check+0x15d>
  104cd4:	c7 44 24 0c d0 7b 10 	movl   $0x107bd0,0xc(%esp)
  104cdb:	00 
  104cdc:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104ce3:	00 
  104ce4:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
  104ceb:	00 
  104cec:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104cf3:	e8 f6 b6 ff ff       	call   1003ee <__panic>
    free_page(p0);
  104cf8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104cff:	00 
  104d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104d03:	89 04 24             	mov    %eax,(%esp)
  104d06:	e8 9d de ff ff       	call   102ba8 <free_pages>
    free_page(A);
  104d0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d12:	00 
  104d13:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d16:	89 04 24             	mov    %eax,(%esp)
  104d19:	e8 8a de ff ff       	call   102ba8 <free_pages>
    free_page(B);
  104d1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104d25:	00 
  104d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d29:	89 04 24             	mov    %eax,(%esp)
  104d2c:	e8 77 de ff ff       	call   102ba8 <free_pages>
    
    A=alloc_pages(500);
  104d31:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
  104d38:	e8 33 de ff ff       	call   102b70 <alloc_pages>
  104d3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    B=alloc_pages(500);
  104d40:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
  104d47:	e8 24 de ff ff       	call   102b70 <alloc_pages>
  104d4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    cprintf("A %p\n",A);
  104d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d52:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d56:	c7 04 24 0a 7c 10 00 	movl   $0x107c0a,(%esp)
  104d5d:	e8 35 b5 ff ff       	call   100297 <cprintf>
    cprintf("B %p\n",B);
  104d62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d65:	89 44 24 04          	mov    %eax,0x4(%esp)
  104d69:	c7 04 24 10 7c 10 00 	movl   $0x107c10,(%esp)
  104d70:	e8 22 b5 ff ff       	call   100297 <cprintf>
    free_pages(A,250);
  104d75:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104d7c:	00 
  104d7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d80:	89 04 24             	mov    %eax,(%esp)
  104d83:	e8 20 de ff ff       	call   102ba8 <free_pages>
    free_pages(B,500);
  104d88:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
  104d8f:	00 
  104d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104d93:	89 04 24             	mov    %eax,(%esp)
  104d96:	e8 0d de ff ff       	call   102ba8 <free_pages>
    free_pages(A+250,250);
  104d9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104d9e:	05 88 13 00 00       	add    $0x1388,%eax
  104da3:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  104daa:	00 
  104dab:	89 04 24             	mov    %eax,(%esp)
  104dae:	e8 f5 dd ff ff       	call   102ba8 <free_pages>
    
    p0=alloc_pages(1024);
  104db3:	c7 04 24 00 04 00 00 	movl   $0x400,(%esp)
  104dba:	e8 b1 dd ff ff       	call   102b70 <alloc_pages>
  104dbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("p0 %p\n",p0);
  104dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  104dc9:	c7 04 24 16 7c 10 00 	movl   $0x107c16,(%esp)
  104dd0:	e8 c2 b4 ff ff       	call   100297 <cprintf>
    assert(p0 == A);
  104dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104dd8:	3b 45 e8             	cmp    -0x18(%ebp),%eax
  104ddb:	74 24                	je     104e01 <buddy_check+0x266>
  104ddd:	c7 44 24 0c 1d 7c 10 	movl   $0x107c1d,0xc(%esp)
  104de4:	00 
  104de5:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104dec:	00 
  104ded:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  104df4:	00 
  104df5:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104dfc:	e8 ed b5 ff ff       	call   1003ee <__panic>
    //以下是根据链接中的样例测试编写的
    A=alloc_pages(70);  
  104e01:	c7 04 24 46 00 00 00 	movl   $0x46,(%esp)
  104e08:	e8 63 dd ff ff       	call   102b70 <alloc_pages>
  104e0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    B=alloc_pages(35);
  104e10:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
  104e17:	e8 54 dd ff ff       	call   102b70 <alloc_pages>
  104e1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(A+128==B);//检查是否相邻
  104e1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e22:	05 00 0a 00 00       	add    $0xa00,%eax
  104e27:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  104e2a:	74 24                	je     104e50 <buddy_check+0x2b5>
  104e2c:	c7 44 24 0c 25 7c 10 	movl   $0x107c25,0xc(%esp)
  104e33:	00 
  104e34:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104e3b:	00 
  104e3c:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
  104e43:	00 
  104e44:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104e4b:	e8 9e b5 ff ff       	call   1003ee <__panic>
    cprintf("A %p\n",A);
  104e50:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e53:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e57:	c7 04 24 0a 7c 10 00 	movl   $0x107c0a,(%esp)
  104e5e:	e8 34 b4 ff ff       	call   100297 <cprintf>
    cprintf("B %p\n",B);
  104e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e66:	89 44 24 04          	mov    %eax,0x4(%esp)
  104e6a:	c7 04 24 10 7c 10 00 	movl   $0x107c10,(%esp)
  104e71:	e8 21 b4 ff ff       	call   100297 <cprintf>
    C=alloc_pages(80);
  104e76:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
  104e7d:	e8 ee dc ff ff       	call   102b70 <alloc_pages>
  104e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(A+256==C);//检查C有没有和A重叠
  104e85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104e88:	05 00 14 00 00       	add    $0x1400,%eax
  104e8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104e90:	74 24                	je     104eb6 <buddy_check+0x31b>
  104e92:	c7 44 24 0c 2e 7c 10 	movl   $0x107c2e,0xc(%esp)
  104e99:	00 
  104e9a:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104ea1:	00 
  104ea2:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  104ea9:	00 
  104eaa:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104eb1:	e8 38 b5 ff ff       	call   1003ee <__panic>
    cprintf("C %p\n",C);
  104eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ebd:	c7 04 24 37 7c 10 00 	movl   $0x107c37,(%esp)
  104ec4:	e8 ce b3 ff ff       	call   100297 <cprintf>
    free_pages(A,70);//释放A
  104ec9:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
  104ed0:	00 
  104ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104ed4:	89 04 24             	mov    %eax,(%esp)
  104ed7:	e8 cc dc ff ff       	call   102ba8 <free_pages>
    cprintf("B %p\n",B);
  104edc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104edf:	89 44 24 04          	mov    %eax,0x4(%esp)
  104ee3:	c7 04 24 10 7c 10 00 	movl   $0x107c10,(%esp)
  104eea:	e8 a8 b3 ff ff       	call   100297 <cprintf>
    D=alloc_pages(60);
  104eef:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
  104ef6:	e8 75 dc ff ff       	call   102b70 <alloc_pages>
  104efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("D %p\n",D);
  104efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f01:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f05:	c7 04 24 3d 7c 10 00 	movl   $0x107c3d,(%esp)
  104f0c:	e8 86 b3 ff ff       	call   100297 <cprintf>
    assert(B+64==D);//检查B，D是否相邻
  104f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f14:	05 00 05 00 00       	add    $0x500,%eax
  104f19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104f1c:	74 24                	je     104f42 <buddy_check+0x3a7>
  104f1e:	c7 44 24 0c 43 7c 10 	movl   $0x107c43,0xc(%esp)
  104f25:	00 
  104f26:	c7 44 24 08 fc 7a 10 	movl   $0x107afc,0x8(%esp)
  104f2d:	00 
  104f2e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
  104f35:	00 
  104f36:	c7 04 24 11 7b 10 00 	movl   $0x107b11,(%esp)
  104f3d:	e8 ac b4 ff ff       	call   1003ee <__panic>
    free_pages(B,35);
  104f42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  104f49:	00 
  104f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104f4d:	89 04 24             	mov    %eax,(%esp)
  104f50:	e8 53 dc ff ff       	call   102ba8 <free_pages>
    cprintf("D %p\n",D);
  104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f58:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f5c:	c7 04 24 3d 7c 10 00 	movl   $0x107c3d,(%esp)
  104f63:	e8 2f b3 ff ff       	call   100297 <cprintf>
    free_pages(D,60);
  104f68:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  104f6f:	00 
  104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f73:	89 04 24             	mov    %eax,(%esp)
  104f76:	e8 2d dc ff ff       	call   102ba8 <free_pages>
    cprintf("C %p\n",C);
  104f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  104f82:	c7 04 24 37 7c 10 00 	movl   $0x107c37,(%esp)
  104f89:	e8 09 b3 ff ff       	call   100297 <cprintf>
    free_pages(C,80);
  104f8e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  104f95:	00 
  104f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f99:	89 04 24             	mov    %eax,(%esp)
  104f9c:	e8 07 dc ff ff       	call   102ba8 <free_pages>
    free_pages(p0,1000);//全部释放
  104fa1:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
  104fa8:	00 
  104fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fac:	89 04 24             	mov    %eax,(%esp)
  104faf:	e8 f4 db ff ff       	call   102ba8 <free_pages>
}
  104fb4:	90                   	nop
  104fb5:	c9                   	leave  
  104fb6:	c3                   	ret    

00104fb7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  104fb7:	55                   	push   %ebp
  104fb8:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104fba:	8b 45 08             	mov    0x8(%ebp),%eax
  104fbd:	8b 15 18 cf 11 00    	mov    0x11cf18,%edx
  104fc3:	29 d0                	sub    %edx,%eax
  104fc5:	c1 f8 02             	sar    $0x2,%eax
  104fc8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  104fce:	5d                   	pop    %ebp
  104fcf:	c3                   	ret    

00104fd0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  104fd0:	55                   	push   %ebp
  104fd1:	89 e5                	mov    %esp,%ebp
  104fd3:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104fd6:	8b 45 08             	mov    0x8(%ebp),%eax
  104fd9:	89 04 24             	mov    %eax,(%esp)
  104fdc:	e8 d6 ff ff ff       	call   104fb7 <page2ppn>
  104fe1:	c1 e0 0c             	shl    $0xc,%eax
}
  104fe4:	c9                   	leave  
  104fe5:	c3                   	ret    

00104fe6 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  104fe6:	55                   	push   %ebp
  104fe7:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
  104fec:	8b 00                	mov    (%eax),%eax
}
  104fee:	5d                   	pop    %ebp
  104fef:	c3                   	ret    

00104ff0 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  104ff0:	55                   	push   %ebp
  104ff1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  104ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
  104ff9:	89 10                	mov    %edx,(%eax)
}
  104ffb:	90                   	nop
  104ffc:	5d                   	pop    %ebp
  104ffd:	c3                   	ret    

00104ffe <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  104ffe:	55                   	push   %ebp
  104fff:	89 e5                	mov    %esp,%ebp
  105001:	83 ec 10             	sub    $0x10,%esp
  105004:	c7 45 fc 40 93 1b 00 	movl   $0x1b9340,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10500b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10500e:	8b 55 fc             	mov    -0x4(%ebp),%edx
  105011:	89 50 04             	mov    %edx,0x4(%eax)
  105014:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105017:	8b 50 04             	mov    0x4(%eax),%edx
  10501a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10501d:	89 10                	mov    %edx,(%eax)
    // 初始化链表
    list_init(&free_list);
    // 将可用内存块数目设置为0
    nr_free = 0;
  10501f:	c7 05 48 93 1b 00 00 	movl   $0x0,0x1b9348
  105026:	00 00 00 
}
  105029:	90                   	nop
  10502a:	c9                   	leave  
  10502b:	c3                   	ret    

0010502c <default_init_memmap>:

// 根据每个物理页帧的情况来建立空闲页链表，且空闲页块应该是根据地址高低形成一个有序链表
// 参数：base->某个连续地址的空闲块的起始页；n->页个数
static void
default_init_memmap(struct Page *base, size_t n) {
  10502c:	55                   	push   %ebp
  10502d:	89 e5                	mov    %esp,%ebp
  10502f:	83 ec 58             	sub    $0x58,%esp
    // kern_init->pmm_init->page_init->init_memmap->pmm_manager->init_memmap
    // 判断n是否大于0
    assert(n > 0);
  105032:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105036:	75 24                	jne    10505c <default_init_memmap+0x30>
  105038:	c7 44 24 0c 7c 7c 10 	movl   $0x107c7c,0xc(%esp)
  10503f:	00 
  105040:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105047:	00 
  105048:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
  10504f:	00 
  105050:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105057:	e8 92 b3 ff ff       	call   1003ee <__panic>
    // 令p为连续地址的空闲块起始页
    struct Page *p = base;
  10505c:	8b 45 08             	mov    0x8(%ebp),%eax
  10505f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
  105062:	eb 7d                	jmp    1050e1 <default_init_memmap+0xb5>
        // 检查p的PG_reserved位是否设置为1，表示空闲可分配
        assert(PageReserved(p));
  105064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105067:	83 c0 04             	add    $0x4,%eax
  10506a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  105071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105077:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10507a:	0f a3 10             	bt     %edx,(%eax)
  10507d:	19 c0                	sbb    %eax,%eax
  10507f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  105082:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  105086:	0f 95 c0             	setne  %al
  105089:	0f b6 c0             	movzbl %al,%eax
  10508c:	85 c0                	test   %eax,%eax
  10508e:	75 24                	jne    1050b4 <default_init_memmap+0x88>
  105090:	c7 44 24 0c ad 7c 10 	movl   $0x107cad,0xc(%esp)
  105097:	00 
  105098:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  10509f:	00 
  1050a0:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
  1050a7:	00 
  1050a8:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1050af:	e8 3a b3 ff ff       	call   1003ee <__panic>
        // 设置flag为0，表示该页空闲
        p->flags = p->property = 0;
  1050b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  1050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050c1:	8b 50 08             	mov    0x8(%eax),%edx
  1050c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050c7:	89 50 04             	mov    %edx,0x4(%eax)
        // 将该页的ref设为0，表示该页空闲，没有引用
        set_page_ref(p, 0);
  1050ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1050d1:	00 
  1050d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050d5:	89 04 24             	mov    %eax,(%esp)
  1050d8:	e8 13 ff ff ff       	call   104ff0 <set_page_ref>
    // 判断n是否大于0
    assert(n > 0);
    // 令p为连续地址的空闲块起始页
    struct Page *p = base;
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
  1050dd:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  1050e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  1050e4:	89 d0                	mov    %edx,%eax
  1050e6:	c1 e0 02             	shl    $0x2,%eax
  1050e9:	01 d0                	add    %edx,%eax
  1050eb:	c1 e0 02             	shl    $0x2,%eax
  1050ee:	89 c2                	mov    %eax,%edx
  1050f0:	8b 45 08             	mov    0x8(%ebp),%eax
  1050f3:	01 d0                	add    %edx,%eax
  1050f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1050f8:	0f 85 66 ff ff ff    	jne    105064 <default_init_memmap+0x38>
        p->flags = p->property = 0;
        // 将该页的ref设为0，表示该页空闲，没有引用
        set_page_ref(p, 0);
    }
    // 空闲块的第一页的连续空页值property设置为块中的总页数
    base->property = n;
  1050fe:	8b 45 08             	mov    0x8(%ebp),%eax
  105101:	8b 55 0c             	mov    0xc(%ebp),%edx
  105104:	89 50 08             	mov    %edx,0x8(%eax)
    // 将空闲块的第一页的PG_property位设置为1，表示是起始页，可以用于分配内存
    SetPageProperty(base);
  105107:	8b 45 08             	mov    0x8(%ebp),%eax
  10510a:	83 c0 04             	add    $0x4,%eax
  10510d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  105114:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105117:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10511a:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10511d:	0f ab 10             	bts    %edx,(%eax)
    // 将空闲页的数目加n
    nr_free += n;
  105120:	8b 15 48 93 1b 00    	mov    0x1b9348,%edx
  105126:	8b 45 0c             	mov    0xc(%ebp),%eax
  105129:	01 d0                	add    %edx,%eax
  10512b:	a3 48 93 1b 00       	mov    %eax,0x1b9348
    // 将base->page_link此页链接到free_list中
    list_add(&free_list, &(base->page_link));
  105130:	8b 45 08             	mov    0x8(%ebp),%eax
  105133:	83 c0 0c             	add    $0xc,%eax
  105136:	c7 45 f0 40 93 1b 00 	movl   $0x1b9340,-0x10(%ebp)
  10513d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105140:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105143:	89 45 d8             	mov    %eax,-0x28(%ebp)
  105146:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105149:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  10514c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10514f:	8b 40 04             	mov    0x4(%eax),%eax
  105152:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105155:	89 55 d0             	mov    %edx,-0x30(%ebp)
  105158:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10515b:	89 55 cc             	mov    %edx,-0x34(%ebp)
  10515e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  105161:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105164:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105167:	89 10                	mov    %edx,(%eax)
  105169:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10516c:	8b 10                	mov    (%eax),%edx
  10516e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105171:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105174:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105177:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10517a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10517d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105180:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105183:	89 10                	mov    %edx,(%eax)
}
  105185:	90                   	nop
  105186:	c9                   	leave  
  105187:	c3                   	ret    

00105188 <default_alloc_pages>:

// firstfit从空闲链表头开始查找最小的地址->通过list_next找到下一个空闲块元素->通过le2page宏由链表元素获得对应的Page指针p
// ->通过p->peroperty了解此空闲块的大小，如果大于等于n，则找到，重新组织块，吧找到的page返回；否则继续查找->直到list_next==&free_list，表示找完一遍
static struct Page *
default_alloc_pages(size_t n) {
  105188:	55                   	push   %ebp
  105189:	89 e5                	mov    %esp,%ebp
  10518b:	83 ec 68             	sub    $0x68,%esp
    // n要大于0
    assert(n > 0);
  10518e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105192:	75 24                	jne    1051b8 <default_alloc_pages+0x30>
  105194:	c7 44 24 0c 7c 7c 10 	movl   $0x107c7c,0xc(%esp)
  10519b:	00 
  10519c:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1051a3:	00 
  1051a4:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
  1051ab:	00 
  1051ac:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1051b3:	e8 36 b2 ff ff       	call   1003ee <__panic>
    // 考虑边界情况，当n大于可以分配的内存数时，直接返回，确保分配不会超出范围，保证软件的鲁棒性
    if (n > nr_free) {
  1051b8:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  1051bd:	3b 45 08             	cmp    0x8(%ebp),%eax
  1051c0:	73 0a                	jae    1051cc <default_alloc_pages+0x44>
        return NULL;
  1051c2:	b8 00 00 00 00       	mov    $0x0,%eax
  1051c7:	e9 68 01 00 00       	jmp    105334 <default_alloc_pages+0x1ac>
    }
    struct Page *page = NULL;
  1051cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
  1051d3:	c7 45 f0 40 93 1b 00 	movl   $0x1b9340,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1051da:	eb 1c                	jmp    1051f8 <default_alloc_pages+0x70>
        // 由链表元素获得对应的Page指针p
        struct Page *p = le2page(le, page_link);
  1051dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1051df:	83 e8 0c             	sub    $0xc,%eax
  1051e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 如果当前页面的property大于等于n，说明空闲块的连续空页数大于等于n，可以分配，令page=p，直接退出
        if (p->property >= n) {
  1051e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051e8:	8b 40 08             	mov    0x8(%eax),%eax
  1051eb:	3b 45 08             	cmp    0x8(%ebp),%eax
  1051ee:	72 08                	jb     1051f8 <default_alloc_pages+0x70>
            page = p;
  1051f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  1051f6:	eb 18                	jmp    105210 <default_alloc_pages+0x88>
  1051f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1051fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1051fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105201:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  105204:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105207:	81 7d f0 40 93 1b 00 	cmpl   $0x1b9340,-0x10(%ebp)
  10520e:	75 cc                	jne    1051dc <default_alloc_pages+0x54>
            page = p;
            break;
        }
    }
    // 如果找到了空闲块，进行重新组织，否则直接返回NULL
    if (page != NULL) {
  105210:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105214:	0f 84 17 01 00 00    	je     105331 <default_alloc_pages+0x1a9>
        // 在空闲页链表中删除刚刚分配的空闲块
        list_del(&(page->page_link));
  10521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10521d:	83 c0 0c             	add    $0xc,%eax
  105220:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  105223:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105226:	8b 40 04             	mov    0x4(%eax),%eax
  105229:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10522c:	8b 12                	mov    (%edx),%edx
  10522e:	89 55 cc             	mov    %edx,-0x34(%ebp)
  105231:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  105234:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105237:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10523a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10523d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  105240:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105243:	89 10                	mov    %edx,(%eax)
        // 如果可以分配的空闲块的连续空页数大于n
        if (page->property > n) {
  105245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105248:	8b 40 08             	mov    0x8(%eax),%eax
  10524b:	3b 45 08             	cmp    0x8(%ebp),%eax
  10524e:	0f 86 8c 00 00 00    	jbe    1052e0 <default_alloc_pages+0x158>
            // 创建一个地址为page+n的新物理页
            struct Page *p = page + n;
  105254:	8b 55 08             	mov    0x8(%ebp),%edx
  105257:	89 d0                	mov    %edx,%eax
  105259:	c1 e0 02             	shl    $0x2,%eax
  10525c:	01 d0                	add    %edx,%eax
  10525e:	c1 e0 02             	shl    $0x2,%eax
  105261:	89 c2                	mov    %eax,%edx
  105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105266:	01 d0                	add    %edx,%eax
  105268:	89 45 e0             	mov    %eax,-0x20(%ebp)
            // 页面的property设置为page多出来的空闲连续页数
            p->property = page->property - n;
  10526b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10526e:	8b 40 08             	mov    0x8(%eax),%eax
  105271:	2b 45 08             	sub    0x8(%ebp),%eax
  105274:	89 c2                	mov    %eax,%edx
  105276:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105279:	89 50 08             	mov    %edx,0x8(%eax)
            // 设置p的Page_property位，表示为新的空闲块的起始页
            SetPageProperty(p);
  10527c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10527f:	83 c0 04             	add    $0x4,%eax
  105282:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
  105289:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  10528c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  10528f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105292:	0f ab 10             	bts    %edx,(%eax)
            // 将新的空闲块的页插入到空闲链表的后面
            list_add_after(&(page->page_link), &(p->page_link));
  105295:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105298:	83 c0 0c             	add    $0xc,%eax
  10529b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10529e:	83 c2 0c             	add    $0xc,%edx
  1052a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1052a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1052a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1052aa:	8b 40 04             	mov    0x4(%eax),%eax
  1052ad:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1052b0:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1052b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1052b6:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1052b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1052bc:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1052bf:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1052c2:	89 10                	mov    %edx,(%eax)
  1052c4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1052c7:	8b 10                	mov    (%eax),%edx
  1052c9:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1052cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1052cf:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1052d2:	8b 55 b8             	mov    -0x48(%ebp),%edx
  1052d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1052d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1052db:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1052de:	89 10                	mov    %edx,(%eax)
    }
        list_del(&(page->page_link));
  1052e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052e3:	83 c0 0c             	add    $0xc,%eax
  1052e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1052e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1052ec:	8b 40 04             	mov    0x4(%eax),%eax
  1052ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1052f2:	8b 12                	mov    (%edx),%edx
  1052f4:	89 55 ac             	mov    %edx,-0x54(%ebp)
  1052f7:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1052fa:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1052fd:	8b 55 a8             	mov    -0x58(%ebp),%edx
  105300:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105303:	8b 45 a8             	mov    -0x58(%ebp),%eax
  105306:	8b 55 ac             	mov    -0x54(%ebp),%edx
  105309:	89 10                	mov    %edx,(%eax)
        // 剩余空闲页的数目减n
        nr_free -= n;
  10530b:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  105310:	2b 45 08             	sub    0x8(%ebp),%eax
  105313:	a3 48 93 1b 00       	mov    %eax,0x1b9348
        // 清除page的Page_property位，表示page已经被分配
        ClearPageProperty(page);
  105318:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10531b:	83 c0 04             	add    $0x4,%eax
  10531e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  105325:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105328:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10532b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10532e:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105334:	c9                   	leave  
  105335:	c3                   	ret    

00105336 <default_free_pages>:

// default_alloc_pages的逆过程，但是需要考虑空闲块的合并问题。
// 将页面重新链接到空闲列表中，可以将小的空闲块合并到大的空闲块中。
static void
default_free_pages(struct Page *base, size_t n) {
  105336:	55                   	push   %ebp
  105337:	89 e5                	mov    %esp,%ebp
  105339:	81 ec 98 00 00 00    	sub    $0x98,%esp
    // n要大于0
    assert(n > 0);
  10533f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105343:	75 24                	jne    105369 <default_free_pages+0x33>
  105345:	c7 44 24 0c 7c 7c 10 	movl   $0x107c7c,0xc(%esp)
  10534c:	00 
  10534d:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105354:	00 
  105355:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
  10535c:	00 
  10535d:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105364:	e8 85 b0 ff ff       	call   1003ee <__panic>
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
  105369:	8b 45 08             	mov    0x8(%ebp),%eax
  10536c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
  10536f:	e9 9d 00 00 00       	jmp    105411 <default_free_pages+0xdb>
        // 检查每一页的Page_reserved位和Pager_property位是否都未被设置
        assert(!PageReserved(p) && !PageProperty(p));
  105374:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105377:	83 c0 04             	add    $0x4,%eax
  10537a:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  105381:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105384:	8b 45 bc             	mov    -0x44(%ebp),%eax
  105387:	8b 55 c0             	mov    -0x40(%ebp),%edx
  10538a:	0f a3 10             	bt     %edx,(%eax)
  10538d:	19 c0                	sbb    %eax,%eax
  10538f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  105392:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  105396:	0f 95 c0             	setne  %al
  105399:	0f b6 c0             	movzbl %al,%eax
  10539c:	85 c0                	test   %eax,%eax
  10539e:	75 2c                	jne    1053cc <default_free_pages+0x96>
  1053a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053a3:	83 c0 04             	add    $0x4,%eax
  1053a6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  1053ad:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1053b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1053b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1053b6:	0f a3 10             	bt     %edx,(%eax)
  1053b9:	19 c0                	sbb    %eax,%eax
  1053bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
  1053be:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  1053c2:	0f 95 c0             	setne  %al
  1053c5:	0f b6 c0             	movzbl %al,%eax
  1053c8:	85 c0                	test   %eax,%eax
  1053ca:	74 24                	je     1053f0 <default_free_pages+0xba>
  1053cc:	c7 44 24 0c c0 7c 10 	movl   $0x107cc0,0xc(%esp)
  1053d3:	00 
  1053d4:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1053db:	00 
  1053dc:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
  1053e3:	00 
  1053e4:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1053eb:	e8 fe af ff ff       	call   1003ee <__panic>
        // 设置每一页的flags都为0，表示可以分配
        p->flags = 0;
  1053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1053f3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
  1053fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  105401:	00 
  105402:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105405:	89 04 24             	mov    %eax,(%esp)
  105408:	e8 e3 fb ff ff       	call   104ff0 <set_page_ref>
    // n要大于0
    assert(n > 0);
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
  10540d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  105411:	8b 55 0c             	mov    0xc(%ebp),%edx
  105414:	89 d0                	mov    %edx,%eax
  105416:	c1 e0 02             	shl    $0x2,%eax
  105419:	01 d0                	add    %edx,%eax
  10541b:	c1 e0 02             	shl    $0x2,%eax
  10541e:	89 c2                	mov    %eax,%edx
  105420:	8b 45 08             	mov    0x8(%ebp),%eax
  105423:	01 d0                	add    %edx,%eax
  105425:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105428:	0f 85 46 ff ff ff    	jne    105374 <default_free_pages+0x3e>
        p->flags = 0;
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
    }
    // 释放块起始页的property连续空页数设置为n
    base->property = n;
  10542e:	8b 45 08             	mov    0x8(%ebp),%eax
  105431:	8b 55 0c             	mov    0xc(%ebp),%edx
  105434:	89 50 08             	mov    %edx,0x8(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
  105437:	8b 45 08             	mov    0x8(%ebp),%eax
  10543a:	83 c0 04             	add    $0x4,%eax
  10543d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  105444:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  105447:	8b 45 ac             	mov    -0x54(%ebp),%eax
  10544a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10544d:	0f ab 10             	bts    %edx,(%eax)
  105450:	c7 45 e8 40 93 1b 00 	movl   $0x1b9340,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  105457:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10545a:	8b 40 04             	mov    0x4(%eax),%eax
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = list_next(&free_list);
  10545d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while (le != &free_list) {
  105460:	e9 08 01 00 00       	jmp    10556d <default_free_pages+0x237>
        // 由链表元素获得对应Page指针p
        p = le2page(le, page_link);
  105465:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105468:	83 e8 0c             	sub    $0xc,%eax
  10546b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10546e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105477:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  10547a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // 如果释放块在下一个空闲块起始页的前面，那么进行合并
        if (base + base->property == p) {
  10547d:	8b 45 08             	mov    0x8(%ebp),%eax
  105480:	8b 50 08             	mov    0x8(%eax),%edx
  105483:	89 d0                	mov    %edx,%eax
  105485:	c1 e0 02             	shl    $0x2,%eax
  105488:	01 d0                	add    %edx,%eax
  10548a:	c1 e0 02             	shl    $0x2,%eax
  10548d:	89 c2                	mov    %eax,%edx
  10548f:	8b 45 08             	mov    0x8(%ebp),%eax
  105492:	01 d0                	add    %edx,%eax
  105494:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105497:	75 5a                	jne    1054f3 <default_free_pages+0x1bd>
            // 释放块的连续空页数要加上空闲块起始页p的连续空页数
            base->property += p->property;
  105499:	8b 45 08             	mov    0x8(%ebp),%eax
  10549c:	8b 50 08             	mov    0x8(%eax),%edx
  10549f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054a2:	8b 40 08             	mov    0x8(%eax),%eax
  1054a5:	01 c2                	add    %eax,%edx
  1054a7:	8b 45 08             	mov    0x8(%ebp),%eax
  1054aa:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除p的Page_property位，表示p不再是新的空闲块的起始页
            ClearPageProperty(p);
  1054ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054b0:	83 c0 04             	add    $0x4,%eax
  1054b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  1054ba:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1054bd:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1054c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1054c3:	0f b3 10             	btr    %edx,(%eax)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
  1054c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054c9:	83 c0 0c             	add    $0xc,%eax
  1054cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  1054cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054d2:	8b 40 04             	mov    0x4(%eax),%eax
  1054d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1054d8:	8b 12                	mov    (%edx),%edx
  1054da:	89 55 a8             	mov    %edx,-0x58(%ebp)
  1054dd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  1054e0:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1054e3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1054e6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  1054e9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1054ec:	8b 55 a8             	mov    -0x58(%ebp),%edx
  1054ef:	89 10                	mov    %edx,(%eax)
  1054f1:	eb 7a                	jmp    10556d <default_free_pages+0x237>
        }
        // 如果释放块的起始页在上一个空闲块的后面，那么进行合并
        else if (p + p->property == base) {
  1054f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1054f6:	8b 50 08             	mov    0x8(%eax),%edx
  1054f9:	89 d0                	mov    %edx,%eax
  1054fb:	c1 e0 02             	shl    $0x2,%eax
  1054fe:	01 d0                	add    %edx,%eax
  105500:	c1 e0 02             	shl    $0x2,%eax
  105503:	89 c2                	mov    %eax,%edx
  105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105508:	01 d0                	add    %edx,%eax
  10550a:	3b 45 08             	cmp    0x8(%ebp),%eax
  10550d:	75 5e                	jne    10556d <default_free_pages+0x237>
            // 空闲块的连续空页数要加上释放块起始页base的连续空页数
            p->property += base->property;
  10550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105512:	8b 50 08             	mov    0x8(%eax),%edx
  105515:	8b 45 08             	mov    0x8(%ebp),%eax
  105518:	8b 40 08             	mov    0x8(%eax),%eax
  10551b:	01 c2                	add    %eax,%edx
  10551d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105520:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除base的Page_property位，表示base不再是起始页
            ClearPageProperty(base);
  105523:	8b 45 08             	mov    0x8(%ebp),%eax
  105526:	83 c0 04             	add    $0x4,%eax
  105529:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  105530:	89 45 94             	mov    %eax,-0x6c(%ebp)
  105533:	8b 45 94             	mov    -0x6c(%ebp),%eax
  105536:	8b 55 cc             	mov    -0x34(%ebp),%edx
  105539:	0f b3 10             	btr    %edx,(%eax)
            // 新的空闲块的起始页变成p
            base = p;
  10553c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10553f:	89 45 08             	mov    %eax,0x8(%ebp)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
  105542:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105545:	83 c0 0c             	add    $0xc,%eax
  105548:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  10554b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10554e:	8b 40 04             	mov    0x4(%eax),%eax
  105551:	8b 55 d8             	mov    -0x28(%ebp),%edx
  105554:	8b 12                	mov    (%edx),%edx
  105556:	89 55 9c             	mov    %edx,-0x64(%ebp)
  105559:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  10555c:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10555f:	8b 55 98             	mov    -0x68(%ebp),%edx
  105562:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  105565:	8b 45 98             	mov    -0x68(%ebp),%eax
  105568:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10556b:	89 10                	mov    %edx,(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = list_next(&free_list);
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while (le != &free_list) {
  10556d:	81 7d f0 40 93 1b 00 	cmpl   $0x1b9340,-0x10(%ebp)
  105574:	0f 85 eb fe ff ff    	jne    105465 <default_free_pages+0x12f>
            // 将原来的空闲块删除
            list_del(&(p->page_link));
        }
    }
    // 将空闲页的数目加n
    nr_free += n;
  10557a:	8b 15 48 93 1b 00    	mov    0x1b9348,%edx
  105580:	8b 45 0c             	mov    0xc(%ebp),%eax
  105583:	01 d0                	add    %edx,%eax
  105585:	a3 48 93 1b 00       	mov    %eax,0x1b9348
  10558a:	c7 45 d0 40 93 1b 00 	movl   $0x1b9340,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  105591:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105594:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  105597:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while (le != &free_list) {
  10559a:	eb 74                	jmp    105610 <default_free_pages+0x2da>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
  10559c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10559f:	83 e8 0c             	sub    $0xc,%eax
  1055a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 找到能够新城新的合并块的位置
        if (base + base->property <= p) {
  1055a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1055a8:	8b 50 08             	mov    0x8(%eax),%edx
  1055ab:	89 d0                	mov    %edx,%eax
  1055ad:	c1 e0 02             	shl    $0x2,%eax
  1055b0:	01 d0                	add    %edx,%eax
  1055b2:	c1 e0 02             	shl    $0x2,%eax
  1055b5:	89 c2                	mov    %eax,%edx
  1055b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1055ba:	01 d0                	add    %edx,%eax
  1055bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1055bf:	77 40                	ja     105601 <default_free_pages+0x2cb>
            assert(base + base->property != p);
  1055c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1055c4:	8b 50 08             	mov    0x8(%eax),%edx
  1055c7:	89 d0                	mov    %edx,%eax
  1055c9:	c1 e0 02             	shl    $0x2,%eax
  1055cc:	01 d0                	add    %edx,%eax
  1055ce:	c1 e0 02             	shl    $0x2,%eax
  1055d1:	89 c2                	mov    %eax,%edx
  1055d3:	8b 45 08             	mov    0x8(%ebp),%eax
  1055d6:	01 d0                	add    %edx,%eax
  1055d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1055db:	75 3e                	jne    10561b <default_free_pages+0x2e5>
  1055dd:	c7 44 24 0c e5 7c 10 	movl   $0x107ce5,0xc(%esp)
  1055e4:	00 
  1055e5:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1055ec:	00 
  1055ed:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
  1055f4:	00 
  1055f5:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1055fc:	e8 ed ad ff ff       	call   1003ee <__panic>
  105601:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105604:	89 45 c8             	mov    %eax,-0x38(%ebp)
  105607:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10560a:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  10560d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    // 将空闲页的数目加n
    nr_free += n;
    le = list_next(&free_list);
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while (le != &free_list) {
  105610:	81 7d f0 40 93 1b 00 	cmpl   $0x1b9340,-0x10(%ebp)
  105617:	75 83                	jne    10559c <default_free_pages+0x266>
  105619:	eb 01                	jmp    10561c <default_free_pages+0x2e6>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
        // 找到能够新城新的合并块的位置
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
  10561b:	90                   	nop
        }
        le = list_next(le);
    }
    // 将base->page_link此页链接到le中，插入到合适位置
    list_add_before(le, &(base->page_link));
  10561c:	8b 45 08             	mov    0x8(%ebp),%eax
  10561f:	8d 50 0c             	lea    0xc(%eax),%edx
  105622:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105625:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  105628:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10562b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10562e:	8b 00                	mov    (%eax),%eax
  105630:	8b 55 90             	mov    -0x70(%ebp),%edx
  105633:	89 55 8c             	mov    %edx,-0x74(%ebp)
  105636:	89 45 88             	mov    %eax,-0x78(%ebp)
  105639:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  10563c:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  10563f:	8b 45 84             	mov    -0x7c(%ebp),%eax
  105642:	8b 55 8c             	mov    -0x74(%ebp),%edx
  105645:	89 10                	mov    %edx,(%eax)
  105647:	8b 45 84             	mov    -0x7c(%ebp),%eax
  10564a:	8b 10                	mov    (%eax),%edx
  10564c:	8b 45 88             	mov    -0x78(%ebp),%eax
  10564f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  105652:	8b 45 8c             	mov    -0x74(%ebp),%eax
  105655:	8b 55 84             	mov    -0x7c(%ebp),%edx
  105658:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  10565b:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10565e:	8b 55 88             	mov    -0x78(%ebp),%edx
  105661:	89 10                	mov    %edx,(%eax)
}
  105663:	90                   	nop
  105664:	c9                   	leave  
  105665:	c3                   	ret    

00105666 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  105666:	55                   	push   %ebp
  105667:	89 e5                	mov    %esp,%ebp
    return nr_free;
  105669:	a1 48 93 1b 00       	mov    0x1b9348,%eax
}
  10566e:	5d                   	pop    %ebp
  10566f:	c3                   	ret    

00105670 <basic_check>:

static void
basic_check(void) {
  105670:	55                   	push   %ebp
  105671:	89 e5                	mov    %esp,%ebp
  105673:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  105676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105680:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105683:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105686:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  105689:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105690:	e8 db d4 ff ff       	call   102b70 <alloc_pages>
  105695:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105698:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10569c:	75 24                	jne    1056c2 <basic_check+0x52>
  10569e:	c7 44 24 0c 00 7d 10 	movl   $0x107d00,0xc(%esp)
  1056a5:	00 
  1056a6:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1056ad:	00 
  1056ae:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
  1056b5:	00 
  1056b6:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1056bd:	e8 2c ad ff ff       	call   1003ee <__panic>
    assert((p1 = alloc_page()) != NULL);
  1056c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1056c9:	e8 a2 d4 ff ff       	call   102b70 <alloc_pages>
  1056ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1056d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1056d5:	75 24                	jne    1056fb <basic_check+0x8b>
  1056d7:	c7 44 24 0c 1c 7d 10 	movl   $0x107d1c,0xc(%esp)
  1056de:	00 
  1056df:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1056e6:	00 
  1056e7:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
  1056ee:	00 
  1056ef:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1056f6:	e8 f3 ac ff ff       	call   1003ee <__panic>
    assert((p2 = alloc_page()) != NULL);
  1056fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105702:	e8 69 d4 ff ff       	call   102b70 <alloc_pages>
  105707:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10570a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10570e:	75 24                	jne    105734 <basic_check+0xc4>
  105710:	c7 44 24 0c 38 7d 10 	movl   $0x107d38,0xc(%esp)
  105717:	00 
  105718:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  10571f:	00 
  105720:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
  105727:	00 
  105728:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  10572f:	e8 ba ac ff ff       	call   1003ee <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  105734:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105737:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  10573a:	74 10                	je     10574c <basic_check+0xdc>
  10573c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10573f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  105742:	74 08                	je     10574c <basic_check+0xdc>
  105744:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105747:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  10574a:	75 24                	jne    105770 <basic_check+0x100>
  10574c:	c7 44 24 0c 54 7d 10 	movl   $0x107d54,0xc(%esp)
  105753:	00 
  105754:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  10575b:	00 
  10575c:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  105763:	00 
  105764:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  10576b:	e8 7e ac ff ff       	call   1003ee <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  105770:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105773:	89 04 24             	mov    %eax,(%esp)
  105776:	e8 6b f8 ff ff       	call   104fe6 <page_ref>
  10577b:	85 c0                	test   %eax,%eax
  10577d:	75 1e                	jne    10579d <basic_check+0x12d>
  10577f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105782:	89 04 24             	mov    %eax,(%esp)
  105785:	e8 5c f8 ff ff       	call   104fe6 <page_ref>
  10578a:	85 c0                	test   %eax,%eax
  10578c:	75 0f                	jne    10579d <basic_check+0x12d>
  10578e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105791:	89 04 24             	mov    %eax,(%esp)
  105794:	e8 4d f8 ff ff       	call   104fe6 <page_ref>
  105799:	85 c0                	test   %eax,%eax
  10579b:	74 24                	je     1057c1 <basic_check+0x151>
  10579d:	c7 44 24 0c 78 7d 10 	movl   $0x107d78,0xc(%esp)
  1057a4:	00 
  1057a5:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1057ac:	00 
  1057ad:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  1057b4:	00 
  1057b5:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1057bc:	e8 2d ac ff ff       	call   1003ee <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  1057c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1057c4:	89 04 24             	mov    %eax,(%esp)
  1057c7:	e8 04 f8 ff ff       	call   104fd0 <page2pa>
  1057cc:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  1057d2:	c1 e2 0c             	shl    $0xc,%edx
  1057d5:	39 d0                	cmp    %edx,%eax
  1057d7:	72 24                	jb     1057fd <basic_check+0x18d>
  1057d9:	c7 44 24 0c b4 7d 10 	movl   $0x107db4,0xc(%esp)
  1057e0:	00 
  1057e1:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1057e8:	00 
  1057e9:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
  1057f0:	00 
  1057f1:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1057f8:	e8 f1 ab ff ff       	call   1003ee <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1057fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105800:	89 04 24             	mov    %eax,(%esp)
  105803:	e8 c8 f7 ff ff       	call   104fd0 <page2pa>
  105808:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  10580e:	c1 e2 0c             	shl    $0xc,%edx
  105811:	39 d0                	cmp    %edx,%eax
  105813:	72 24                	jb     105839 <basic_check+0x1c9>
  105815:	c7 44 24 0c d1 7d 10 	movl   $0x107dd1,0xc(%esp)
  10581c:	00 
  10581d:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105824:	00 
  105825:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
  10582c:	00 
  10582d:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105834:	e8 b5 ab ff ff       	call   1003ee <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  105839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10583c:	89 04 24             	mov    %eax,(%esp)
  10583f:	e8 8c f7 ff ff       	call   104fd0 <page2pa>
  105844:	8b 15 80 ce 11 00    	mov    0x11ce80,%edx
  10584a:	c1 e2 0c             	shl    $0xc,%edx
  10584d:	39 d0                	cmp    %edx,%eax
  10584f:	72 24                	jb     105875 <basic_check+0x205>
  105851:	c7 44 24 0c ee 7d 10 	movl   $0x107dee,0xc(%esp)
  105858:	00 
  105859:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105860:	00 
  105861:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  105868:	00 
  105869:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105870:	e8 79 ab ff ff       	call   1003ee <__panic>

    list_entry_t free_list_store = free_list;
  105875:	a1 40 93 1b 00       	mov    0x1b9340,%eax
  10587a:	8b 15 44 93 1b 00    	mov    0x1b9344,%edx
  105880:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105883:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105886:	c7 45 e4 40 93 1b 00 	movl   $0x1b9340,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10588d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105893:	89 50 04             	mov    %edx,0x4(%eax)
  105896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105899:	8b 50 04             	mov    0x4(%eax),%edx
  10589c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10589f:	89 10                	mov    %edx,(%eax)
  1058a1:	c7 45 d8 40 93 1b 00 	movl   $0x1b9340,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  1058a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1058ab:	8b 40 04             	mov    0x4(%eax),%eax
  1058ae:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  1058b1:	0f 94 c0             	sete   %al
  1058b4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  1058b7:	85 c0                	test   %eax,%eax
  1058b9:	75 24                	jne    1058df <basic_check+0x26f>
  1058bb:	c7 44 24 0c 0b 7e 10 	movl   $0x107e0b,0xc(%esp)
  1058c2:	00 
  1058c3:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1058ca:	00 
  1058cb:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
  1058d2:	00 
  1058d3:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1058da:	e8 0f ab ff ff       	call   1003ee <__panic>

    unsigned int nr_free_store = nr_free;
  1058df:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  1058e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  1058e7:	c7 05 48 93 1b 00 00 	movl   $0x0,0x1b9348
  1058ee:	00 00 00 

    assert(alloc_page() == NULL);
  1058f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1058f8:	e8 73 d2 ff ff       	call   102b70 <alloc_pages>
  1058fd:	85 c0                	test   %eax,%eax
  1058ff:	74 24                	je     105925 <basic_check+0x2b5>
  105901:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  105908:	00 
  105909:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105910:	00 
  105911:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  105918:	00 
  105919:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105920:	e8 c9 aa ff ff       	call   1003ee <__panic>

    free_page(p0);
  105925:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10592c:	00 
  10592d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105930:	89 04 24             	mov    %eax,(%esp)
  105933:	e8 70 d2 ff ff       	call   102ba8 <free_pages>
    free_page(p1);
  105938:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10593f:	00 
  105940:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105943:	89 04 24             	mov    %eax,(%esp)
  105946:	e8 5d d2 ff ff       	call   102ba8 <free_pages>
    free_page(p2);
  10594b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105952:	00 
  105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105956:	89 04 24             	mov    %eax,(%esp)
  105959:	e8 4a d2 ff ff       	call   102ba8 <free_pages>
    assert(nr_free == 3);
  10595e:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  105963:	83 f8 03             	cmp    $0x3,%eax
  105966:	74 24                	je     10598c <basic_check+0x31c>
  105968:	c7 44 24 0c 37 7e 10 	movl   $0x107e37,0xc(%esp)
  10596f:	00 
  105970:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105977:	00 
  105978:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
  10597f:	00 
  105980:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105987:	e8 62 aa ff ff       	call   1003ee <__panic>

    assert((p0 = alloc_page()) != NULL);
  10598c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105993:	e8 d8 d1 ff ff       	call   102b70 <alloc_pages>
  105998:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10599b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10599f:	75 24                	jne    1059c5 <basic_check+0x355>
  1059a1:	c7 44 24 0c 00 7d 10 	movl   $0x107d00,0xc(%esp)
  1059a8:	00 
  1059a9:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1059b0:	00 
  1059b1:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1059b8:	00 
  1059b9:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1059c0:	e8 29 aa ff ff       	call   1003ee <__panic>
    assert((p1 = alloc_page()) != NULL);
  1059c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1059cc:	e8 9f d1 ff ff       	call   102b70 <alloc_pages>
  1059d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1059d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1059d8:	75 24                	jne    1059fe <basic_check+0x38e>
  1059da:	c7 44 24 0c 1c 7d 10 	movl   $0x107d1c,0xc(%esp)
  1059e1:	00 
  1059e2:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1059e9:	00 
  1059ea:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  1059f1:	00 
  1059f2:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1059f9:	e8 f0 a9 ff ff       	call   1003ee <__panic>
    assert((p2 = alloc_page()) != NULL);
  1059fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105a05:	e8 66 d1 ff ff       	call   102b70 <alloc_pages>
  105a0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105a11:	75 24                	jne    105a37 <basic_check+0x3c7>
  105a13:	c7 44 24 0c 38 7d 10 	movl   $0x107d38,0xc(%esp)
  105a1a:	00 
  105a1b:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105a22:	00 
  105a23:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
  105a2a:	00 
  105a2b:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105a32:	e8 b7 a9 ff ff       	call   1003ee <__panic>

    assert(alloc_page() == NULL);
  105a37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105a3e:	e8 2d d1 ff ff       	call   102b70 <alloc_pages>
  105a43:	85 c0                	test   %eax,%eax
  105a45:	74 24                	je     105a6b <basic_check+0x3fb>
  105a47:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  105a4e:	00 
  105a4f:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105a56:	00 
  105a57:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
  105a5e:	00 
  105a5f:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105a66:	e8 83 a9 ff ff       	call   1003ee <__panic>

    free_page(p0);
  105a6b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105a72:	00 
  105a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105a76:	89 04 24             	mov    %eax,(%esp)
  105a79:	e8 2a d1 ff ff       	call   102ba8 <free_pages>
  105a7e:	c7 45 e8 40 93 1b 00 	movl   $0x1b9340,-0x18(%ebp)
  105a85:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a88:	8b 40 04             	mov    0x4(%eax),%eax
  105a8b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  105a8e:	0f 94 c0             	sete   %al
  105a91:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  105a94:	85 c0                	test   %eax,%eax
  105a96:	74 24                	je     105abc <basic_check+0x44c>
  105a98:	c7 44 24 0c 44 7e 10 	movl   $0x107e44,0xc(%esp)
  105a9f:	00 
  105aa0:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105aa7:	00 
  105aa8:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
  105aaf:	00 
  105ab0:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105ab7:	e8 32 a9 ff ff       	call   1003ee <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  105abc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105ac3:	e8 a8 d0 ff ff       	call   102b70 <alloc_pages>
  105ac8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105acb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ace:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105ad1:	74 24                	je     105af7 <basic_check+0x487>
  105ad3:	c7 44 24 0c 5c 7e 10 	movl   $0x107e5c,0xc(%esp)
  105ada:	00 
  105adb:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105ae2:	00 
  105ae3:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  105aea:	00 
  105aeb:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105af2:	e8 f7 a8 ff ff       	call   1003ee <__panic>
    assert(alloc_page() == NULL);
  105af7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105afe:	e8 6d d0 ff ff       	call   102b70 <alloc_pages>
  105b03:	85 c0                	test   %eax,%eax
  105b05:	74 24                	je     105b2b <basic_check+0x4bb>
  105b07:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  105b0e:	00 
  105b0f:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105b16:	00 
  105b17:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  105b1e:	00 
  105b1f:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105b26:	e8 c3 a8 ff ff       	call   1003ee <__panic>

    assert(nr_free == 0);
  105b2b:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  105b30:	85 c0                	test   %eax,%eax
  105b32:	74 24                	je     105b58 <basic_check+0x4e8>
  105b34:	c7 44 24 0c 75 7e 10 	movl   $0x107e75,0xc(%esp)
  105b3b:	00 
  105b3c:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105b43:	00 
  105b44:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  105b4b:	00 
  105b4c:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105b53:	e8 96 a8 ff ff       	call   1003ee <__panic>
    free_list = free_list_store;
  105b58:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105b5b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105b5e:	a3 40 93 1b 00       	mov    %eax,0x1b9340
  105b63:	89 15 44 93 1b 00    	mov    %edx,0x1b9344
    nr_free = nr_free_store;
  105b69:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b6c:	a3 48 93 1b 00       	mov    %eax,0x1b9348

    free_page(p);
  105b71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105b78:	00 
  105b79:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105b7c:	89 04 24             	mov    %eax,(%esp)
  105b7f:	e8 24 d0 ff ff       	call   102ba8 <free_pages>
    free_page(p1);
  105b84:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105b8b:	00 
  105b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b8f:	89 04 24             	mov    %eax,(%esp)
  105b92:	e8 11 d0 ff ff       	call   102ba8 <free_pages>
    free_page(p2);
  105b97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105b9e:	00 
  105b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105ba2:	89 04 24             	mov    %eax,(%esp)
  105ba5:	e8 fe cf ff ff       	call   102ba8 <free_pages>
}
  105baa:	90                   	nop
  105bab:	c9                   	leave  
  105bac:	c3                   	ret    

00105bad <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  105bad:	55                   	push   %ebp
  105bae:	89 e5                	mov    %esp,%ebp
  105bb0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  105bb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  105bbd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  105bc4:	c7 45 ec 40 93 1b 00 	movl   $0x1b9340,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105bcb:	eb 6a                	jmp    105c37 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  105bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105bd0:	83 e8 0c             	sub    $0xc,%eax
  105bd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
  105bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105bd9:	83 c0 04             	add    $0x4,%eax
  105bdc:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  105be3:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105be6:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105be9:	8b 55 b0             	mov    -0x50(%ebp),%edx
  105bec:	0f a3 10             	bt     %edx,(%eax)
  105bef:	19 c0                	sbb    %eax,%eax
  105bf1:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  105bf4:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  105bf8:	0f 95 c0             	setne  %al
  105bfb:	0f b6 c0             	movzbl %al,%eax
  105bfe:	85 c0                	test   %eax,%eax
  105c00:	75 24                	jne    105c26 <default_check+0x79>
  105c02:	c7 44 24 0c 82 7e 10 	movl   $0x107e82,0xc(%esp)
  105c09:	00 
  105c0a:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105c11:	00 
  105c12:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
  105c19:	00 
  105c1a:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105c21:	e8 c8 a7 ff ff       	call   1003ee <__panic>
        count ++, total += p->property;
  105c26:	ff 45 f4             	incl   -0xc(%ebp)
  105c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105c2c:	8b 50 08             	mov    0x8(%eax),%edx
  105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c32:	01 d0                	add    %edx,%eax
  105c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105c3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  105c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105c40:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  105c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105c46:	81 7d ec 40 93 1b 00 	cmpl   $0x1b9340,-0x14(%ebp)
  105c4d:	0f 85 7a ff ff ff    	jne    105bcd <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  105c53:	e8 83 cf ff ff       	call   102bdb <nr_free_pages>
  105c58:	89 c2                	mov    %eax,%edx
  105c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c5d:	39 c2                	cmp    %eax,%edx
  105c5f:	74 24                	je     105c85 <default_check+0xd8>
  105c61:	c7 44 24 0c 92 7e 10 	movl   $0x107e92,0xc(%esp)
  105c68:	00 
  105c69:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105c70:	00 
  105c71:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
  105c78:	00 
  105c79:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105c80:	e8 69 a7 ff ff       	call   1003ee <__panic>

    basic_check();
  105c85:	e8 e6 f9 ff ff       	call   105670 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  105c8a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  105c91:	e8 da ce ff ff       	call   102b70 <alloc_pages>
  105c96:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  105c99:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105c9d:	75 24                	jne    105cc3 <default_check+0x116>
  105c9f:	c7 44 24 0c ab 7e 10 	movl   $0x107eab,0xc(%esp)
  105ca6:	00 
  105ca7:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105cae:	00 
  105caf:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
  105cb6:	00 
  105cb7:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105cbe:	e8 2b a7 ff ff       	call   1003ee <__panic>
    assert(!PageProperty(p0));
  105cc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105cc6:	83 c0 04             	add    $0x4,%eax
  105cc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  105cd0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105cd3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  105cd6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105cd9:	0f a3 10             	bt     %edx,(%eax)
  105cdc:	19 c0                	sbb    %eax,%eax
  105cde:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
  105ce1:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  105ce5:	0f 95 c0             	setne  %al
  105ce8:	0f b6 c0             	movzbl %al,%eax
  105ceb:	85 c0                	test   %eax,%eax
  105ced:	74 24                	je     105d13 <default_check+0x166>
  105cef:	c7 44 24 0c b6 7e 10 	movl   $0x107eb6,0xc(%esp)
  105cf6:	00 
  105cf7:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105cfe:	00 
  105cff:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
  105d06:	00 
  105d07:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105d0e:	e8 db a6 ff ff       	call   1003ee <__panic>

    list_entry_t free_list_store = free_list;
  105d13:	a1 40 93 1b 00       	mov    0x1b9340,%eax
  105d18:	8b 15 44 93 1b 00    	mov    0x1b9344,%edx
  105d1e:	89 45 80             	mov    %eax,-0x80(%ebp)
  105d21:	89 55 84             	mov    %edx,-0x7c(%ebp)
  105d24:	c7 45 d0 40 93 1b 00 	movl   $0x1b9340,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  105d2b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105d2e:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105d31:	89 50 04             	mov    %edx,0x4(%eax)
  105d34:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105d37:	8b 50 04             	mov    0x4(%eax),%edx
  105d3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105d3d:	89 10                	mov    %edx,(%eax)
  105d3f:	c7 45 d8 40 93 1b 00 	movl   $0x1b9340,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  105d46:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105d49:	8b 40 04             	mov    0x4(%eax),%eax
  105d4c:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  105d4f:	0f 94 c0             	sete   %al
  105d52:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105d55:	85 c0                	test   %eax,%eax
  105d57:	75 24                	jne    105d7d <default_check+0x1d0>
  105d59:	c7 44 24 0c 0b 7e 10 	movl   $0x107e0b,0xc(%esp)
  105d60:	00 
  105d61:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105d68:	00 
  105d69:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
  105d70:	00 
  105d71:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105d78:	e8 71 a6 ff ff       	call   1003ee <__panic>
    assert(alloc_page() == NULL);
  105d7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105d84:	e8 e7 cd ff ff       	call   102b70 <alloc_pages>
  105d89:	85 c0                	test   %eax,%eax
  105d8b:	74 24                	je     105db1 <default_check+0x204>
  105d8d:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  105d94:	00 
  105d95:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105d9c:	00 
  105d9d:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
  105da4:	00 
  105da5:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105dac:	e8 3d a6 ff ff       	call   1003ee <__panic>

    unsigned int nr_free_store = nr_free;
  105db1:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  105db6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
  105db9:	c7 05 48 93 1b 00 00 	movl   $0x0,0x1b9348
  105dc0:	00 00 00 

    free_pages(p0 + 2, 3);
  105dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105dc6:	83 c0 28             	add    $0x28,%eax
  105dc9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105dd0:	00 
  105dd1:	89 04 24             	mov    %eax,(%esp)
  105dd4:	e8 cf cd ff ff       	call   102ba8 <free_pages>
    assert(alloc_pages(4) == NULL);
  105dd9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  105de0:	e8 8b cd ff ff       	call   102b70 <alloc_pages>
  105de5:	85 c0                	test   %eax,%eax
  105de7:	74 24                	je     105e0d <default_check+0x260>
  105de9:	c7 44 24 0c c8 7e 10 	movl   $0x107ec8,0xc(%esp)
  105df0:	00 
  105df1:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105df8:	00 
  105df9:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
  105e00:	00 
  105e01:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105e08:	e8 e1 a5 ff ff       	call   1003ee <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  105e0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e10:	83 c0 28             	add    $0x28,%eax
  105e13:	83 c0 04             	add    $0x4,%eax
  105e16:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  105e1d:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105e20:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105e23:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105e26:	0f a3 10             	bt     %edx,(%eax)
  105e29:	19 c0                	sbb    %eax,%eax
  105e2b:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  105e2e:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105e32:	0f 95 c0             	setne  %al
  105e35:	0f b6 c0             	movzbl %al,%eax
  105e38:	85 c0                	test   %eax,%eax
  105e3a:	74 0e                	je     105e4a <default_check+0x29d>
  105e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e3f:	83 c0 28             	add    $0x28,%eax
  105e42:	8b 40 08             	mov    0x8(%eax),%eax
  105e45:	83 f8 03             	cmp    $0x3,%eax
  105e48:	74 24                	je     105e6e <default_check+0x2c1>
  105e4a:	c7 44 24 0c e0 7e 10 	movl   $0x107ee0,0xc(%esp)
  105e51:	00 
  105e52:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105e59:	00 
  105e5a:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
  105e61:	00 
  105e62:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105e69:	e8 80 a5 ff ff       	call   1003ee <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  105e6e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105e75:	e8 f6 cc ff ff       	call   102b70 <alloc_pages>
  105e7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  105e7d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  105e81:	75 24                	jne    105ea7 <default_check+0x2fa>
  105e83:	c7 44 24 0c 0c 7f 10 	movl   $0x107f0c,0xc(%esp)
  105e8a:	00 
  105e8b:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105e92:	00 
  105e93:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
  105e9a:	00 
  105e9b:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105ea2:	e8 47 a5 ff ff       	call   1003ee <__panic>
    assert(alloc_page() == NULL);
  105ea7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105eae:	e8 bd cc ff ff       	call   102b70 <alloc_pages>
  105eb3:	85 c0                	test   %eax,%eax
  105eb5:	74 24                	je     105edb <default_check+0x32e>
  105eb7:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  105ebe:	00 
  105ebf:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105ec6:	00 
  105ec7:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
  105ece:	00 
  105ecf:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105ed6:	e8 13 a5 ff ff       	call   1003ee <__panic>
    assert(p0 + 2 == p1);
  105edb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105ede:	83 c0 28             	add    $0x28,%eax
  105ee1:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  105ee4:	74 24                	je     105f0a <default_check+0x35d>
  105ee6:	c7 44 24 0c 2a 7f 10 	movl   $0x107f2a,0xc(%esp)
  105eed:	00 
  105eee:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105ef5:	00 
  105ef6:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
  105efd:	00 
  105efe:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105f05:	e8 e4 a4 ff ff       	call   1003ee <__panic>

    p2 = p0 + 1;
  105f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f0d:	83 c0 14             	add    $0x14,%eax
  105f10:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
  105f13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105f1a:	00 
  105f1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f1e:	89 04 24             	mov    %eax,(%esp)
  105f21:	e8 82 cc ff ff       	call   102ba8 <free_pages>
    free_pages(p1, 3);
  105f26:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  105f2d:	00 
  105f2e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105f31:	89 04 24             	mov    %eax,(%esp)
  105f34:	e8 6f cc ff ff       	call   102ba8 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105f39:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f3c:	83 c0 04             	add    $0x4,%eax
  105f3f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  105f46:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105f49:	8b 45 94             	mov    -0x6c(%ebp),%eax
  105f4c:	8b 55 c8             	mov    -0x38(%ebp),%edx
  105f4f:	0f a3 10             	bt     %edx,(%eax)
  105f52:	19 c0                	sbb    %eax,%eax
  105f54:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  105f57:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  105f5b:	0f 95 c0             	setne  %al
  105f5e:	0f b6 c0             	movzbl %al,%eax
  105f61:	85 c0                	test   %eax,%eax
  105f63:	74 0b                	je     105f70 <default_check+0x3c3>
  105f65:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105f68:	8b 40 08             	mov    0x8(%eax),%eax
  105f6b:	83 f8 01             	cmp    $0x1,%eax
  105f6e:	74 24                	je     105f94 <default_check+0x3e7>
  105f70:	c7 44 24 0c 38 7f 10 	movl   $0x107f38,0xc(%esp)
  105f77:	00 
  105f78:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105f7f:	00 
  105f80:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
  105f87:	00 
  105f88:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105f8f:	e8 5a a4 ff ff       	call   1003ee <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  105f94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105f97:	83 c0 04             	add    $0x4,%eax
  105f9a:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  105fa1:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105fa4:	8b 45 8c             	mov    -0x74(%ebp),%eax
  105fa7:	8b 55 bc             	mov    -0x44(%ebp),%edx
  105faa:	0f a3 10             	bt     %edx,(%eax)
  105fad:	19 c0                	sbb    %eax,%eax
  105faf:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
  105fb2:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
  105fb6:	0f 95 c0             	setne  %al
  105fb9:	0f b6 c0             	movzbl %al,%eax
  105fbc:	85 c0                	test   %eax,%eax
  105fbe:	74 0b                	je     105fcb <default_check+0x41e>
  105fc0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105fc3:	8b 40 08             	mov    0x8(%eax),%eax
  105fc6:	83 f8 03             	cmp    $0x3,%eax
  105fc9:	74 24                	je     105fef <default_check+0x442>
  105fcb:	c7 44 24 0c 60 7f 10 	movl   $0x107f60,0xc(%esp)
  105fd2:	00 
  105fd3:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  105fda:	00 
  105fdb:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
  105fe2:	00 
  105fe3:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  105fea:	e8 ff a3 ff ff       	call   1003ee <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  105fef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105ff6:	e8 75 cb ff ff       	call   102b70 <alloc_pages>
  105ffb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  105ffe:	8b 45 c0             	mov    -0x40(%ebp),%eax
  106001:	83 e8 14             	sub    $0x14,%eax
  106004:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  106007:	74 24                	je     10602d <default_check+0x480>
  106009:	c7 44 24 0c 86 7f 10 	movl   $0x107f86,0xc(%esp)
  106010:	00 
  106011:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  106018:	00 
  106019:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
  106020:	00 
  106021:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  106028:	e8 c1 a3 ff ff       	call   1003ee <__panic>
    free_page(p0);
  10602d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  106034:	00 
  106035:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106038:	89 04 24             	mov    %eax,(%esp)
  10603b:	e8 68 cb ff ff       	call   102ba8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  106040:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  106047:	e8 24 cb ff ff       	call   102b70 <alloc_pages>
  10604c:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10604f:	8b 45 c0             	mov    -0x40(%ebp),%eax
  106052:	83 c0 14             	add    $0x14,%eax
  106055:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  106058:	74 24                	je     10607e <default_check+0x4d1>
  10605a:	c7 44 24 0c a4 7f 10 	movl   $0x107fa4,0xc(%esp)
  106061:	00 
  106062:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  106069:	00 
  10606a:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
  106071:	00 
  106072:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  106079:	e8 70 a3 ff ff       	call   1003ee <__panic>

    free_pages(p0, 2);
  10607e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  106085:	00 
  106086:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106089:	89 04 24             	mov    %eax,(%esp)
  10608c:	e8 17 cb ff ff       	call   102ba8 <free_pages>
    free_page(p2);
  106091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  106098:	00 
  106099:	8b 45 c0             	mov    -0x40(%ebp),%eax
  10609c:	89 04 24             	mov    %eax,(%esp)
  10609f:	e8 04 cb ff ff       	call   102ba8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1060a4:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1060ab:	e8 c0 ca ff ff       	call   102b70 <alloc_pages>
  1060b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1060b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1060b7:	75 24                	jne    1060dd <default_check+0x530>
  1060b9:	c7 44 24 0c c4 7f 10 	movl   $0x107fc4,0xc(%esp)
  1060c0:	00 
  1060c1:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1060c8:	00 
  1060c9:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
  1060d0:	00 
  1060d1:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1060d8:	e8 11 a3 ff ff       	call   1003ee <__panic>
    assert(alloc_page() == NULL);
  1060dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1060e4:	e8 87 ca ff ff       	call   102b70 <alloc_pages>
  1060e9:	85 c0                	test   %eax,%eax
  1060eb:	74 24                	je     106111 <default_check+0x564>
  1060ed:	c7 44 24 0c 22 7e 10 	movl   $0x107e22,0xc(%esp)
  1060f4:	00 
  1060f5:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1060fc:	00 
  1060fd:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
  106104:	00 
  106105:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  10610c:	e8 dd a2 ff ff       	call   1003ee <__panic>

    assert(nr_free == 0);
  106111:	a1 48 93 1b 00       	mov    0x1b9348,%eax
  106116:	85 c0                	test   %eax,%eax
  106118:	74 24                	je     10613e <default_check+0x591>
  10611a:	c7 44 24 0c 75 7e 10 	movl   $0x107e75,0xc(%esp)
  106121:	00 
  106122:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  106129:	00 
  10612a:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
  106131:	00 
  106132:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  106139:	e8 b0 a2 ff ff       	call   1003ee <__panic>
    nr_free = nr_free_store;
  10613e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  106141:	a3 48 93 1b 00       	mov    %eax,0x1b9348

    free_list = free_list_store;
  106146:	8b 45 80             	mov    -0x80(%ebp),%eax
  106149:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10614c:	a3 40 93 1b 00       	mov    %eax,0x1b9340
  106151:	89 15 44 93 1b 00    	mov    %edx,0x1b9344
    free_pages(p0, 5);
  106157:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10615e:	00 
  10615f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  106162:	89 04 24             	mov    %eax,(%esp)
  106165:	e8 3e ca ff ff       	call   102ba8 <free_pages>

    le = &free_list;
  10616a:	c7 45 ec 40 93 1b 00 	movl   $0x1b9340,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  106171:	eb 5a                	jmp    1061cd <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  106173:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106176:	8b 40 04             	mov    0x4(%eax),%eax
  106179:	8b 00                	mov    (%eax),%eax
  10617b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10617e:	75 0d                	jne    10618d <default_check+0x5e0>
  106180:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106183:	8b 00                	mov    (%eax),%eax
  106185:	8b 40 04             	mov    0x4(%eax),%eax
  106188:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10618b:	74 24                	je     1061b1 <default_check+0x604>
  10618d:	c7 44 24 0c e4 7f 10 	movl   $0x107fe4,0xc(%esp)
  106194:	00 
  106195:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  10619c:	00 
  10619d:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
  1061a4:	00 
  1061a5:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  1061ac:	e8 3d a2 ff ff       	call   1003ee <__panic>
        struct Page *p = le2page(le, page_link);
  1061b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1061b4:	83 e8 0c             	sub    $0xc,%eax
  1061b7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
  1061ba:	ff 4d f4             	decl   -0xc(%ebp)
  1061bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1061c0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1061c3:	8b 40 08             	mov    0x8(%eax),%eax
  1061c6:	29 c2                	sub    %eax,%edx
  1061c8:	89 d0                	mov    %edx,%eax
  1061ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1061cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1061d0:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1061d3:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1061d6:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1061d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1061dc:	81 7d ec 40 93 1b 00 	cmpl   $0x1b9340,-0x14(%ebp)
  1061e3:	75 8e                	jne    106173 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  1061e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1061e9:	74 24                	je     10620f <default_check+0x662>
  1061eb:	c7 44 24 0c 11 80 10 	movl   $0x108011,0xc(%esp)
  1061f2:	00 
  1061f3:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  1061fa:	00 
  1061fb:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
  106202:	00 
  106203:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  10620a:	e8 df a1 ff ff       	call   1003ee <__panic>
    assert(total == 0);
  10620f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  106213:	74 24                	je     106239 <default_check+0x68c>
  106215:	c7 44 24 0c 1c 80 10 	movl   $0x10801c,0xc(%esp)
  10621c:	00 
  10621d:	c7 44 24 08 82 7c 10 	movl   $0x107c82,0x8(%esp)
  106224:	00 
  106225:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
  10622c:	00 
  10622d:	c7 04 24 97 7c 10 00 	movl   $0x107c97,(%esp)
  106234:	e8 b5 a1 ff ff       	call   1003ee <__panic>
}
  106239:	90                   	nop
  10623a:	c9                   	leave  
  10623b:	c3                   	ret    

0010623c <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10623c:	55                   	push   %ebp
  10623d:	89 e5                	mov    %esp,%ebp
  10623f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106242:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  106249:	eb 03                	jmp    10624e <strlen+0x12>
        cnt ++;
  10624b:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  10624e:	8b 45 08             	mov    0x8(%ebp),%eax
  106251:	8d 50 01             	lea    0x1(%eax),%edx
  106254:	89 55 08             	mov    %edx,0x8(%ebp)
  106257:	0f b6 00             	movzbl (%eax),%eax
  10625a:	84 c0                	test   %al,%al
  10625c:	75 ed                	jne    10624b <strlen+0xf>
        cnt ++;
    }
    return cnt;
  10625e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106261:	c9                   	leave  
  106262:	c3                   	ret    

00106263 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  106263:	55                   	push   %ebp
  106264:	89 e5                	mov    %esp,%ebp
  106266:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  106269:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  106270:	eb 03                	jmp    106275 <strnlen+0x12>
        cnt ++;
  106272:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  106275:	8b 45 fc             	mov    -0x4(%ebp),%eax
  106278:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10627b:	73 10                	jae    10628d <strnlen+0x2a>
  10627d:	8b 45 08             	mov    0x8(%ebp),%eax
  106280:	8d 50 01             	lea    0x1(%eax),%edx
  106283:	89 55 08             	mov    %edx,0x8(%ebp)
  106286:	0f b6 00             	movzbl (%eax),%eax
  106289:	84 c0                	test   %al,%al
  10628b:	75 e5                	jne    106272 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  10628d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  106290:	c9                   	leave  
  106291:	c3                   	ret    

00106292 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  106292:	55                   	push   %ebp
  106293:	89 e5                	mov    %esp,%ebp
  106295:	57                   	push   %edi
  106296:	56                   	push   %esi
  106297:	83 ec 20             	sub    $0x20,%esp
  10629a:	8b 45 08             	mov    0x8(%ebp),%eax
  10629d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1062a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1062a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1062a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1062ac:	89 d1                	mov    %edx,%ecx
  1062ae:	89 c2                	mov    %eax,%edx
  1062b0:	89 ce                	mov    %ecx,%esi
  1062b2:	89 d7                	mov    %edx,%edi
  1062b4:	ac                   	lods   %ds:(%esi),%al
  1062b5:	aa                   	stos   %al,%es:(%edi)
  1062b6:	84 c0                	test   %al,%al
  1062b8:	75 fa                	jne    1062b4 <strcpy+0x22>
  1062ba:	89 fa                	mov    %edi,%edx
  1062bc:	89 f1                	mov    %esi,%ecx
  1062be:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1062c1:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1062c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1062c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1062ca:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1062cb:	83 c4 20             	add    $0x20,%esp
  1062ce:	5e                   	pop    %esi
  1062cf:	5f                   	pop    %edi
  1062d0:	5d                   	pop    %ebp
  1062d1:	c3                   	ret    

001062d2 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1062d2:	55                   	push   %ebp
  1062d3:	89 e5                	mov    %esp,%ebp
  1062d5:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1062d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1062db:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1062de:	eb 1e                	jmp    1062fe <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1062e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062e3:	0f b6 10             	movzbl (%eax),%edx
  1062e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1062e9:	88 10                	mov    %dl,(%eax)
  1062eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1062ee:	0f b6 00             	movzbl (%eax),%eax
  1062f1:	84 c0                	test   %al,%al
  1062f3:	74 03                	je     1062f8 <strncpy+0x26>
            src ++;
  1062f5:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  1062f8:	ff 45 fc             	incl   -0x4(%ebp)
  1062fb:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  1062fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106302:	75 dc                	jne    1062e0 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  106304:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106307:	c9                   	leave  
  106308:	c3                   	ret    

00106309 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  106309:	55                   	push   %ebp
  10630a:	89 e5                	mov    %esp,%ebp
  10630c:	57                   	push   %edi
  10630d:	56                   	push   %esi
  10630e:	83 ec 20             	sub    $0x20,%esp
  106311:	8b 45 08             	mov    0x8(%ebp),%eax
  106314:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10631a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  10631d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106320:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106323:	89 d1                	mov    %edx,%ecx
  106325:	89 c2                	mov    %eax,%edx
  106327:	89 ce                	mov    %ecx,%esi
  106329:	89 d7                	mov    %edx,%edi
  10632b:	ac                   	lods   %ds:(%esi),%al
  10632c:	ae                   	scas   %es:(%edi),%al
  10632d:	75 08                	jne    106337 <strcmp+0x2e>
  10632f:	84 c0                	test   %al,%al
  106331:	75 f8                	jne    10632b <strcmp+0x22>
  106333:	31 c0                	xor    %eax,%eax
  106335:	eb 04                	jmp    10633b <strcmp+0x32>
  106337:	19 c0                	sbb    %eax,%eax
  106339:	0c 01                	or     $0x1,%al
  10633b:	89 fa                	mov    %edi,%edx
  10633d:	89 f1                	mov    %esi,%ecx
  10633f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106342:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106345:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  106348:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  10634b:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  10634c:	83 c4 20             	add    $0x20,%esp
  10634f:	5e                   	pop    %esi
  106350:	5f                   	pop    %edi
  106351:	5d                   	pop    %ebp
  106352:	c3                   	ret    

00106353 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  106353:	55                   	push   %ebp
  106354:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106356:	eb 09                	jmp    106361 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  106358:	ff 4d 10             	decl   0x10(%ebp)
  10635b:	ff 45 08             	incl   0x8(%ebp)
  10635e:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  106361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106365:	74 1a                	je     106381 <strncmp+0x2e>
  106367:	8b 45 08             	mov    0x8(%ebp),%eax
  10636a:	0f b6 00             	movzbl (%eax),%eax
  10636d:	84 c0                	test   %al,%al
  10636f:	74 10                	je     106381 <strncmp+0x2e>
  106371:	8b 45 08             	mov    0x8(%ebp),%eax
  106374:	0f b6 10             	movzbl (%eax),%edx
  106377:	8b 45 0c             	mov    0xc(%ebp),%eax
  10637a:	0f b6 00             	movzbl (%eax),%eax
  10637d:	38 c2                	cmp    %al,%dl
  10637f:	74 d7                	je     106358 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  106381:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106385:	74 18                	je     10639f <strncmp+0x4c>
  106387:	8b 45 08             	mov    0x8(%ebp),%eax
  10638a:	0f b6 00             	movzbl (%eax),%eax
  10638d:	0f b6 d0             	movzbl %al,%edx
  106390:	8b 45 0c             	mov    0xc(%ebp),%eax
  106393:	0f b6 00             	movzbl (%eax),%eax
  106396:	0f b6 c0             	movzbl %al,%eax
  106399:	29 c2                	sub    %eax,%edx
  10639b:	89 d0                	mov    %edx,%eax
  10639d:	eb 05                	jmp    1063a4 <strncmp+0x51>
  10639f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1063a4:	5d                   	pop    %ebp
  1063a5:	c3                   	ret    

001063a6 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  1063a6:	55                   	push   %ebp
  1063a7:	89 e5                	mov    %esp,%ebp
  1063a9:	83 ec 04             	sub    $0x4,%esp
  1063ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063af:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1063b2:	eb 13                	jmp    1063c7 <strchr+0x21>
        if (*s == c) {
  1063b4:	8b 45 08             	mov    0x8(%ebp),%eax
  1063b7:	0f b6 00             	movzbl (%eax),%eax
  1063ba:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1063bd:	75 05                	jne    1063c4 <strchr+0x1e>
            return (char *)s;
  1063bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1063c2:	eb 12                	jmp    1063d6 <strchr+0x30>
        }
        s ++;
  1063c4:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  1063c7:	8b 45 08             	mov    0x8(%ebp),%eax
  1063ca:	0f b6 00             	movzbl (%eax),%eax
  1063cd:	84 c0                	test   %al,%al
  1063cf:	75 e3                	jne    1063b4 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  1063d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1063d6:	c9                   	leave  
  1063d7:	c3                   	ret    

001063d8 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  1063d8:	55                   	push   %ebp
  1063d9:	89 e5                	mov    %esp,%ebp
  1063db:	83 ec 04             	sub    $0x4,%esp
  1063de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063e1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  1063e4:	eb 0e                	jmp    1063f4 <strfind+0x1c>
        if (*s == c) {
  1063e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1063e9:	0f b6 00             	movzbl (%eax),%eax
  1063ec:	3a 45 fc             	cmp    -0x4(%ebp),%al
  1063ef:	74 0f                	je     106400 <strfind+0x28>
            break;
        }
        s ++;
  1063f1:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  1063f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1063f7:	0f b6 00             	movzbl (%eax),%eax
  1063fa:	84 c0                	test   %al,%al
  1063fc:	75 e8                	jne    1063e6 <strfind+0xe>
  1063fe:	eb 01                	jmp    106401 <strfind+0x29>
        if (*s == c) {
            break;
  106400:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  106401:	8b 45 08             	mov    0x8(%ebp),%eax
}
  106404:	c9                   	leave  
  106405:	c3                   	ret    

00106406 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  106406:	55                   	push   %ebp
  106407:	89 e5                	mov    %esp,%ebp
  106409:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  10640c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  106413:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10641a:	eb 03                	jmp    10641f <strtol+0x19>
        s ++;
  10641c:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  10641f:	8b 45 08             	mov    0x8(%ebp),%eax
  106422:	0f b6 00             	movzbl (%eax),%eax
  106425:	3c 20                	cmp    $0x20,%al
  106427:	74 f3                	je     10641c <strtol+0x16>
  106429:	8b 45 08             	mov    0x8(%ebp),%eax
  10642c:	0f b6 00             	movzbl (%eax),%eax
  10642f:	3c 09                	cmp    $0x9,%al
  106431:	74 e9                	je     10641c <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  106433:	8b 45 08             	mov    0x8(%ebp),%eax
  106436:	0f b6 00             	movzbl (%eax),%eax
  106439:	3c 2b                	cmp    $0x2b,%al
  10643b:	75 05                	jne    106442 <strtol+0x3c>
        s ++;
  10643d:	ff 45 08             	incl   0x8(%ebp)
  106440:	eb 14                	jmp    106456 <strtol+0x50>
    }
    else if (*s == '-') {
  106442:	8b 45 08             	mov    0x8(%ebp),%eax
  106445:	0f b6 00             	movzbl (%eax),%eax
  106448:	3c 2d                	cmp    $0x2d,%al
  10644a:	75 0a                	jne    106456 <strtol+0x50>
        s ++, neg = 1;
  10644c:	ff 45 08             	incl   0x8(%ebp)
  10644f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  106456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10645a:	74 06                	je     106462 <strtol+0x5c>
  10645c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  106460:	75 22                	jne    106484 <strtol+0x7e>
  106462:	8b 45 08             	mov    0x8(%ebp),%eax
  106465:	0f b6 00             	movzbl (%eax),%eax
  106468:	3c 30                	cmp    $0x30,%al
  10646a:	75 18                	jne    106484 <strtol+0x7e>
  10646c:	8b 45 08             	mov    0x8(%ebp),%eax
  10646f:	40                   	inc    %eax
  106470:	0f b6 00             	movzbl (%eax),%eax
  106473:	3c 78                	cmp    $0x78,%al
  106475:	75 0d                	jne    106484 <strtol+0x7e>
        s += 2, base = 16;
  106477:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  10647b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  106482:	eb 29                	jmp    1064ad <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  106484:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  106488:	75 16                	jne    1064a0 <strtol+0x9a>
  10648a:	8b 45 08             	mov    0x8(%ebp),%eax
  10648d:	0f b6 00             	movzbl (%eax),%eax
  106490:	3c 30                	cmp    $0x30,%al
  106492:	75 0c                	jne    1064a0 <strtol+0x9a>
        s ++, base = 8;
  106494:	ff 45 08             	incl   0x8(%ebp)
  106497:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  10649e:	eb 0d                	jmp    1064ad <strtol+0xa7>
    }
    else if (base == 0) {
  1064a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1064a4:	75 07                	jne    1064ad <strtol+0xa7>
        base = 10;
  1064a6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  1064ad:	8b 45 08             	mov    0x8(%ebp),%eax
  1064b0:	0f b6 00             	movzbl (%eax),%eax
  1064b3:	3c 2f                	cmp    $0x2f,%al
  1064b5:	7e 1b                	jle    1064d2 <strtol+0xcc>
  1064b7:	8b 45 08             	mov    0x8(%ebp),%eax
  1064ba:	0f b6 00             	movzbl (%eax),%eax
  1064bd:	3c 39                	cmp    $0x39,%al
  1064bf:	7f 11                	jg     1064d2 <strtol+0xcc>
            dig = *s - '0';
  1064c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1064c4:	0f b6 00             	movzbl (%eax),%eax
  1064c7:	0f be c0             	movsbl %al,%eax
  1064ca:	83 e8 30             	sub    $0x30,%eax
  1064cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1064d0:	eb 48                	jmp    10651a <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  1064d2:	8b 45 08             	mov    0x8(%ebp),%eax
  1064d5:	0f b6 00             	movzbl (%eax),%eax
  1064d8:	3c 60                	cmp    $0x60,%al
  1064da:	7e 1b                	jle    1064f7 <strtol+0xf1>
  1064dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1064df:	0f b6 00             	movzbl (%eax),%eax
  1064e2:	3c 7a                	cmp    $0x7a,%al
  1064e4:	7f 11                	jg     1064f7 <strtol+0xf1>
            dig = *s - 'a' + 10;
  1064e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1064e9:	0f b6 00             	movzbl (%eax),%eax
  1064ec:	0f be c0             	movsbl %al,%eax
  1064ef:	83 e8 57             	sub    $0x57,%eax
  1064f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1064f5:	eb 23                	jmp    10651a <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  1064f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1064fa:	0f b6 00             	movzbl (%eax),%eax
  1064fd:	3c 40                	cmp    $0x40,%al
  1064ff:	7e 3b                	jle    10653c <strtol+0x136>
  106501:	8b 45 08             	mov    0x8(%ebp),%eax
  106504:	0f b6 00             	movzbl (%eax),%eax
  106507:	3c 5a                	cmp    $0x5a,%al
  106509:	7f 31                	jg     10653c <strtol+0x136>
            dig = *s - 'A' + 10;
  10650b:	8b 45 08             	mov    0x8(%ebp),%eax
  10650e:	0f b6 00             	movzbl (%eax),%eax
  106511:	0f be c0             	movsbl %al,%eax
  106514:	83 e8 37             	sub    $0x37,%eax
  106517:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10651a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10651d:	3b 45 10             	cmp    0x10(%ebp),%eax
  106520:	7d 19                	jge    10653b <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106522:	ff 45 08             	incl   0x8(%ebp)
  106525:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106528:	0f af 45 10          	imul   0x10(%ebp),%eax
  10652c:	89 c2                	mov    %eax,%edx
  10652e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106531:	01 d0                	add    %edx,%eax
  106533:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  106536:	e9 72 ff ff ff       	jmp    1064ad <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  10653b:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  10653c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106540:	74 08                	je     10654a <strtol+0x144>
        *endptr = (char *) s;
  106542:	8b 45 0c             	mov    0xc(%ebp),%eax
  106545:	8b 55 08             	mov    0x8(%ebp),%edx
  106548:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10654a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  10654e:	74 07                	je     106557 <strtol+0x151>
  106550:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106553:	f7 d8                	neg    %eax
  106555:	eb 03                	jmp    10655a <strtol+0x154>
  106557:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10655a:	c9                   	leave  
  10655b:	c3                   	ret    

0010655c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  10655c:	55                   	push   %ebp
  10655d:	89 e5                	mov    %esp,%ebp
  10655f:	57                   	push   %edi
  106560:	83 ec 24             	sub    $0x24,%esp
  106563:	8b 45 0c             	mov    0xc(%ebp),%eax
  106566:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106569:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  10656d:	8b 55 08             	mov    0x8(%ebp),%edx
  106570:	89 55 f8             	mov    %edx,-0x8(%ebp)
  106573:	88 45 f7             	mov    %al,-0x9(%ebp)
  106576:	8b 45 10             	mov    0x10(%ebp),%eax
  106579:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  10657c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  10657f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  106583:	8b 55 f8             	mov    -0x8(%ebp),%edx
  106586:	89 d7                	mov    %edx,%edi
  106588:	f3 aa                	rep stos %al,%es:(%edi)
  10658a:	89 fa                	mov    %edi,%edx
  10658c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  10658f:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  106592:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106595:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  106596:	83 c4 24             	add    $0x24,%esp
  106599:	5f                   	pop    %edi
  10659a:	5d                   	pop    %ebp
  10659b:	c3                   	ret    

0010659c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  10659c:	55                   	push   %ebp
  10659d:	89 e5                	mov    %esp,%ebp
  10659f:	57                   	push   %edi
  1065a0:	56                   	push   %esi
  1065a1:	53                   	push   %ebx
  1065a2:	83 ec 30             	sub    $0x30,%esp
  1065a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1065a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1065ab:	8b 45 0c             	mov    0xc(%ebp),%eax
  1065ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1065b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1065b4:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1065b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1065bd:	73 42                	jae    106601 <memmove+0x65>
  1065bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1065c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1065c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1065c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1065cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1065ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1065d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1065d4:	c1 e8 02             	shr    $0x2,%eax
  1065d7:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  1065d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1065dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1065df:	89 d7                	mov    %edx,%edi
  1065e1:	89 c6                	mov    %eax,%esi
  1065e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1065e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1065e8:	83 e1 03             	and    $0x3,%ecx
  1065eb:	74 02                	je     1065ef <memmove+0x53>
  1065ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1065ef:	89 f0                	mov    %esi,%eax
  1065f1:	89 fa                	mov    %edi,%edx
  1065f3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  1065f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  1065f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  1065fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  1065ff:	eb 36                	jmp    106637 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106601:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106604:	8d 50 ff             	lea    -0x1(%eax),%edx
  106607:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10660a:	01 c2                	add    %eax,%edx
  10660c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10660f:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106612:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106615:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  106618:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10661b:	89 c1                	mov    %eax,%ecx
  10661d:	89 d8                	mov    %ebx,%eax
  10661f:	89 d6                	mov    %edx,%esi
  106621:	89 c7                	mov    %eax,%edi
  106623:	fd                   	std    
  106624:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106626:	fc                   	cld    
  106627:	89 f8                	mov    %edi,%eax
  106629:	89 f2                	mov    %esi,%edx
  10662b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  10662e:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106631:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  106634:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  106637:	83 c4 30             	add    $0x30,%esp
  10663a:	5b                   	pop    %ebx
  10663b:	5e                   	pop    %esi
  10663c:	5f                   	pop    %edi
  10663d:	5d                   	pop    %ebp
  10663e:	c3                   	ret    

0010663f <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  10663f:	55                   	push   %ebp
  106640:	89 e5                	mov    %esp,%ebp
  106642:	57                   	push   %edi
  106643:	56                   	push   %esi
  106644:	83 ec 20             	sub    $0x20,%esp
  106647:	8b 45 08             	mov    0x8(%ebp),%eax
  10664a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10664d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106650:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106653:	8b 45 10             	mov    0x10(%ebp),%eax
  106656:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106659:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10665c:	c1 e8 02             	shr    $0x2,%eax
  10665f:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  106661:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106664:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106667:	89 d7                	mov    %edx,%edi
  106669:	89 c6                	mov    %eax,%esi
  10666b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10666d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106670:	83 e1 03             	and    $0x3,%ecx
  106673:	74 02                	je     106677 <memcpy+0x38>
  106675:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106677:	89 f0                	mov    %esi,%eax
  106679:	89 fa                	mov    %edi,%edx
  10667b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  10667e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106681:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  106684:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  106687:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  106688:	83 c4 20             	add    $0x20,%esp
  10668b:	5e                   	pop    %esi
  10668c:	5f                   	pop    %edi
  10668d:	5d                   	pop    %ebp
  10668e:	c3                   	ret    

0010668f <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  10668f:	55                   	push   %ebp
  106690:	89 e5                	mov    %esp,%ebp
  106692:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  106695:	8b 45 08             	mov    0x8(%ebp),%eax
  106698:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  10669b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10669e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1066a1:	eb 2e                	jmp    1066d1 <memcmp+0x42>
        if (*s1 != *s2) {
  1066a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1066a6:	0f b6 10             	movzbl (%eax),%edx
  1066a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1066ac:	0f b6 00             	movzbl (%eax),%eax
  1066af:	38 c2                	cmp    %al,%dl
  1066b1:	74 18                	je     1066cb <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1066b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1066b6:	0f b6 00             	movzbl (%eax),%eax
  1066b9:	0f b6 d0             	movzbl %al,%edx
  1066bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1066bf:	0f b6 00             	movzbl (%eax),%eax
  1066c2:	0f b6 c0             	movzbl %al,%eax
  1066c5:	29 c2                	sub    %eax,%edx
  1066c7:	89 d0                	mov    %edx,%eax
  1066c9:	eb 18                	jmp    1066e3 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1066cb:	ff 45 fc             	incl   -0x4(%ebp)
  1066ce:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  1066d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1066d4:	8d 50 ff             	lea    -0x1(%eax),%edx
  1066d7:	89 55 10             	mov    %edx,0x10(%ebp)
  1066da:	85 c0                	test   %eax,%eax
  1066dc:	75 c5                	jne    1066a3 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  1066de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1066e3:	c9                   	leave  
  1066e4:	c3                   	ret    

001066e5 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1066e5:	55                   	push   %ebp
  1066e6:	89 e5                	mov    %esp,%ebp
  1066e8:	83 ec 58             	sub    $0x58,%esp
  1066eb:	8b 45 10             	mov    0x10(%ebp),%eax
  1066ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1066f1:	8b 45 14             	mov    0x14(%ebp),%eax
  1066f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1066f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1066fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1066fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106700:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  106703:	8b 45 18             	mov    0x18(%ebp),%eax
  106706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  106709:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10670c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10670f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106712:	89 55 f0             	mov    %edx,-0x10(%ebp)
  106715:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106718:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10671b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10671f:	74 1c                	je     10673d <printnum+0x58>
  106721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106724:	ba 00 00 00 00       	mov    $0x0,%edx
  106729:	f7 75 e4             	divl   -0x1c(%ebp)
  10672c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106732:	ba 00 00 00 00       	mov    $0x0,%edx
  106737:	f7 75 e4             	divl   -0x1c(%ebp)
  10673a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10673d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106740:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106743:	f7 75 e4             	divl   -0x1c(%ebp)
  106746:	89 45 e0             	mov    %eax,-0x20(%ebp)
  106749:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10674c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10674f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  106752:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106755:	89 55 ec             	mov    %edx,-0x14(%ebp)
  106758:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10675b:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10675e:	8b 45 18             	mov    0x18(%ebp),%eax
  106761:	ba 00 00 00 00       	mov    $0x0,%edx
  106766:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  106769:	77 56                	ja     1067c1 <printnum+0xdc>
  10676b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10676e:	72 05                	jb     106775 <printnum+0x90>
  106770:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  106773:	77 4c                	ja     1067c1 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  106775:	8b 45 1c             	mov    0x1c(%ebp),%eax
  106778:	8d 50 ff             	lea    -0x1(%eax),%edx
  10677b:	8b 45 20             	mov    0x20(%ebp),%eax
  10677e:	89 44 24 18          	mov    %eax,0x18(%esp)
  106782:	89 54 24 14          	mov    %edx,0x14(%esp)
  106786:	8b 45 18             	mov    0x18(%ebp),%eax
  106789:	89 44 24 10          	mov    %eax,0x10(%esp)
  10678d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106790:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106793:	89 44 24 08          	mov    %eax,0x8(%esp)
  106797:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10679b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10679e:	89 44 24 04          	mov    %eax,0x4(%esp)
  1067a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1067a5:	89 04 24             	mov    %eax,(%esp)
  1067a8:	e8 38 ff ff ff       	call   1066e5 <printnum>
  1067ad:	eb 1b                	jmp    1067ca <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1067af:	8b 45 0c             	mov    0xc(%ebp),%eax
  1067b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1067b6:	8b 45 20             	mov    0x20(%ebp),%eax
  1067b9:	89 04 24             	mov    %eax,(%esp)
  1067bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1067bf:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  1067c1:	ff 4d 1c             	decl   0x1c(%ebp)
  1067c4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1067c8:	7f e5                	jg     1067af <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1067ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1067cd:	05 d8 80 10 00       	add    $0x1080d8,%eax
  1067d2:	0f b6 00             	movzbl (%eax),%eax
  1067d5:	0f be c0             	movsbl %al,%eax
  1067d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  1067db:	89 54 24 04          	mov    %edx,0x4(%esp)
  1067df:	89 04 24             	mov    %eax,(%esp)
  1067e2:	8b 45 08             	mov    0x8(%ebp),%eax
  1067e5:	ff d0                	call   *%eax
}
  1067e7:	90                   	nop
  1067e8:	c9                   	leave  
  1067e9:	c3                   	ret    

001067ea <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1067ea:	55                   	push   %ebp
  1067eb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1067ed:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1067f1:	7e 14                	jle    106807 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1067f3:	8b 45 08             	mov    0x8(%ebp),%eax
  1067f6:	8b 00                	mov    (%eax),%eax
  1067f8:	8d 48 08             	lea    0x8(%eax),%ecx
  1067fb:	8b 55 08             	mov    0x8(%ebp),%edx
  1067fe:	89 0a                	mov    %ecx,(%edx)
  106800:	8b 50 04             	mov    0x4(%eax),%edx
  106803:	8b 00                	mov    (%eax),%eax
  106805:	eb 30                	jmp    106837 <getuint+0x4d>
    }
    else if (lflag) {
  106807:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10680b:	74 16                	je     106823 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  10680d:	8b 45 08             	mov    0x8(%ebp),%eax
  106810:	8b 00                	mov    (%eax),%eax
  106812:	8d 48 04             	lea    0x4(%eax),%ecx
  106815:	8b 55 08             	mov    0x8(%ebp),%edx
  106818:	89 0a                	mov    %ecx,(%edx)
  10681a:	8b 00                	mov    (%eax),%eax
  10681c:	ba 00 00 00 00       	mov    $0x0,%edx
  106821:	eb 14                	jmp    106837 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  106823:	8b 45 08             	mov    0x8(%ebp),%eax
  106826:	8b 00                	mov    (%eax),%eax
  106828:	8d 48 04             	lea    0x4(%eax),%ecx
  10682b:	8b 55 08             	mov    0x8(%ebp),%edx
  10682e:	89 0a                	mov    %ecx,(%edx)
  106830:	8b 00                	mov    (%eax),%eax
  106832:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  106837:	5d                   	pop    %ebp
  106838:	c3                   	ret    

00106839 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  106839:	55                   	push   %ebp
  10683a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  10683c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  106840:	7e 14                	jle    106856 <getint+0x1d>
        return va_arg(*ap, long long);
  106842:	8b 45 08             	mov    0x8(%ebp),%eax
  106845:	8b 00                	mov    (%eax),%eax
  106847:	8d 48 08             	lea    0x8(%eax),%ecx
  10684a:	8b 55 08             	mov    0x8(%ebp),%edx
  10684d:	89 0a                	mov    %ecx,(%edx)
  10684f:	8b 50 04             	mov    0x4(%eax),%edx
  106852:	8b 00                	mov    (%eax),%eax
  106854:	eb 28                	jmp    10687e <getint+0x45>
    }
    else if (lflag) {
  106856:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  10685a:	74 12                	je     10686e <getint+0x35>
        return va_arg(*ap, long);
  10685c:	8b 45 08             	mov    0x8(%ebp),%eax
  10685f:	8b 00                	mov    (%eax),%eax
  106861:	8d 48 04             	lea    0x4(%eax),%ecx
  106864:	8b 55 08             	mov    0x8(%ebp),%edx
  106867:	89 0a                	mov    %ecx,(%edx)
  106869:	8b 00                	mov    (%eax),%eax
  10686b:	99                   	cltd   
  10686c:	eb 10                	jmp    10687e <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  10686e:	8b 45 08             	mov    0x8(%ebp),%eax
  106871:	8b 00                	mov    (%eax),%eax
  106873:	8d 48 04             	lea    0x4(%eax),%ecx
  106876:	8b 55 08             	mov    0x8(%ebp),%edx
  106879:	89 0a                	mov    %ecx,(%edx)
  10687b:	8b 00                	mov    (%eax),%eax
  10687d:	99                   	cltd   
    }
}
  10687e:	5d                   	pop    %ebp
  10687f:	c3                   	ret    

00106880 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  106880:	55                   	push   %ebp
  106881:	89 e5                	mov    %esp,%ebp
  106883:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  106886:	8d 45 14             	lea    0x14(%ebp),%eax
  106889:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  10688c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10688f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106893:	8b 45 10             	mov    0x10(%ebp),%eax
  106896:	89 44 24 08          	mov    %eax,0x8(%esp)
  10689a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10689d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1068a4:	89 04 24             	mov    %eax,(%esp)
  1068a7:	e8 03 00 00 00       	call   1068af <vprintfmt>
    va_end(ap);
}
  1068ac:	90                   	nop
  1068ad:	c9                   	leave  
  1068ae:	c3                   	ret    

001068af <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1068af:	55                   	push   %ebp
  1068b0:	89 e5                	mov    %esp,%ebp
  1068b2:	56                   	push   %esi
  1068b3:	53                   	push   %ebx
  1068b4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1068b7:	eb 17                	jmp    1068d0 <vprintfmt+0x21>
            if (ch == '\0') {
  1068b9:	85 db                	test   %ebx,%ebx
  1068bb:	0f 84 bf 03 00 00    	je     106c80 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1068c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1068c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1068c8:	89 1c 24             	mov    %ebx,(%esp)
  1068cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1068ce:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1068d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1068d3:	8d 50 01             	lea    0x1(%eax),%edx
  1068d6:	89 55 10             	mov    %edx,0x10(%ebp)
  1068d9:	0f b6 00             	movzbl (%eax),%eax
  1068dc:	0f b6 d8             	movzbl %al,%ebx
  1068df:	83 fb 25             	cmp    $0x25,%ebx
  1068e2:	75 d5                	jne    1068b9 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  1068e4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1068e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1068ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1068f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1068f5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1068fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1068ff:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106902:	8b 45 10             	mov    0x10(%ebp),%eax
  106905:	8d 50 01             	lea    0x1(%eax),%edx
  106908:	89 55 10             	mov    %edx,0x10(%ebp)
  10690b:	0f b6 00             	movzbl (%eax),%eax
  10690e:	0f b6 d8             	movzbl %al,%ebx
  106911:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106914:	83 f8 55             	cmp    $0x55,%eax
  106917:	0f 87 37 03 00 00    	ja     106c54 <vprintfmt+0x3a5>
  10691d:	8b 04 85 fc 80 10 00 	mov    0x1080fc(,%eax,4),%eax
  106924:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106926:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  10692a:	eb d6                	jmp    106902 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10692c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  106930:	eb d0                	jmp    106902 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106932:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106939:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10693c:	89 d0                	mov    %edx,%eax
  10693e:	c1 e0 02             	shl    $0x2,%eax
  106941:	01 d0                	add    %edx,%eax
  106943:	01 c0                	add    %eax,%eax
  106945:	01 d8                	add    %ebx,%eax
  106947:	83 e8 30             	sub    $0x30,%eax
  10694a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10694d:	8b 45 10             	mov    0x10(%ebp),%eax
  106950:	0f b6 00             	movzbl (%eax),%eax
  106953:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106956:	83 fb 2f             	cmp    $0x2f,%ebx
  106959:	7e 38                	jle    106993 <vprintfmt+0xe4>
  10695b:	83 fb 39             	cmp    $0x39,%ebx
  10695e:	7f 33                	jg     106993 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106960:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  106963:	eb d4                	jmp    106939 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106965:	8b 45 14             	mov    0x14(%ebp),%eax
  106968:	8d 50 04             	lea    0x4(%eax),%edx
  10696b:	89 55 14             	mov    %edx,0x14(%ebp)
  10696e:	8b 00                	mov    (%eax),%eax
  106970:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106973:	eb 1f                	jmp    106994 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106975:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106979:	79 87                	jns    106902 <vprintfmt+0x53>
                width = 0;
  10697b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  106982:	e9 7b ff ff ff       	jmp    106902 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  106987:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10698e:	e9 6f ff ff ff       	jmp    106902 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  106993:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  106994:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106998:	0f 89 64 ff ff ff    	jns    106902 <vprintfmt+0x53>
                width = precision, precision = -1;
  10699e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1069a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1069a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1069ab:	e9 52 ff ff ff       	jmp    106902 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1069b0:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1069b3:	e9 4a ff ff ff       	jmp    106902 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1069b8:	8b 45 14             	mov    0x14(%ebp),%eax
  1069bb:	8d 50 04             	lea    0x4(%eax),%edx
  1069be:	89 55 14             	mov    %edx,0x14(%ebp)
  1069c1:	8b 00                	mov    (%eax),%eax
  1069c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1069c6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1069ca:	89 04 24             	mov    %eax,(%esp)
  1069cd:	8b 45 08             	mov    0x8(%ebp),%eax
  1069d0:	ff d0                	call   *%eax
            break;
  1069d2:	e9 a4 02 00 00       	jmp    106c7b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1069d7:	8b 45 14             	mov    0x14(%ebp),%eax
  1069da:	8d 50 04             	lea    0x4(%eax),%edx
  1069dd:	89 55 14             	mov    %edx,0x14(%ebp)
  1069e0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1069e2:	85 db                	test   %ebx,%ebx
  1069e4:	79 02                	jns    1069e8 <vprintfmt+0x139>
                err = -err;
  1069e6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1069e8:	83 fb 06             	cmp    $0x6,%ebx
  1069eb:	7f 0b                	jg     1069f8 <vprintfmt+0x149>
  1069ed:	8b 34 9d bc 80 10 00 	mov    0x1080bc(,%ebx,4),%esi
  1069f4:	85 f6                	test   %esi,%esi
  1069f6:	75 23                	jne    106a1b <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1069f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1069fc:	c7 44 24 08 e9 80 10 	movl   $0x1080e9,0x8(%esp)
  106a03:	00 
  106a04:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  106a0e:	89 04 24             	mov    %eax,(%esp)
  106a11:	e8 6a fe ff ff       	call   106880 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106a16:	e9 60 02 00 00       	jmp    106c7b <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  106a1b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  106a1f:	c7 44 24 08 f2 80 10 	movl   $0x1080f2,0x8(%esp)
  106a26:	00 
  106a27:	8b 45 0c             	mov    0xc(%ebp),%eax
  106a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  106a31:	89 04 24             	mov    %eax,(%esp)
  106a34:	e8 47 fe ff ff       	call   106880 <printfmt>
            }
            break;
  106a39:	e9 3d 02 00 00       	jmp    106c7b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  106a3e:	8b 45 14             	mov    0x14(%ebp),%eax
  106a41:	8d 50 04             	lea    0x4(%eax),%edx
  106a44:	89 55 14             	mov    %edx,0x14(%ebp)
  106a47:	8b 30                	mov    (%eax),%esi
  106a49:	85 f6                	test   %esi,%esi
  106a4b:	75 05                	jne    106a52 <vprintfmt+0x1a3>
                p = "(null)";
  106a4d:	be f5 80 10 00       	mov    $0x1080f5,%esi
            }
            if (width > 0 && padc != '-') {
  106a52:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a56:	7e 76                	jle    106ace <vprintfmt+0x21f>
  106a58:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  106a5c:	74 70                	je     106ace <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  106a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106a61:	89 44 24 04          	mov    %eax,0x4(%esp)
  106a65:	89 34 24             	mov    %esi,(%esp)
  106a68:	e8 f6 f7 ff ff       	call   106263 <strnlen>
  106a6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106a70:	29 c2                	sub    %eax,%edx
  106a72:	89 d0                	mov    %edx,%eax
  106a74:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106a77:	eb 16                	jmp    106a8f <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106a79:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  106a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  106a80:	89 54 24 04          	mov    %edx,0x4(%esp)
  106a84:	89 04 24             	mov    %eax,(%esp)
  106a87:	8b 45 08             	mov    0x8(%ebp),%eax
  106a8a:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  106a8c:	ff 4d e8             	decl   -0x18(%ebp)
  106a8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106a93:	7f e4                	jg     106a79 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106a95:	eb 37                	jmp    106ace <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  106a97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  106a9b:	74 1f                	je     106abc <vprintfmt+0x20d>
  106a9d:	83 fb 1f             	cmp    $0x1f,%ebx
  106aa0:	7e 05                	jle    106aa7 <vprintfmt+0x1f8>
  106aa2:	83 fb 7e             	cmp    $0x7e,%ebx
  106aa5:	7e 15                	jle    106abc <vprintfmt+0x20d>
                    putch('?', putdat);
  106aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
  106aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
  106aae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  106ab5:	8b 45 08             	mov    0x8(%ebp),%eax
  106ab8:	ff d0                	call   *%eax
  106aba:	eb 0f                	jmp    106acb <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  106abc:	8b 45 0c             	mov    0xc(%ebp),%eax
  106abf:	89 44 24 04          	mov    %eax,0x4(%esp)
  106ac3:	89 1c 24             	mov    %ebx,(%esp)
  106ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  106ac9:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  106acb:	ff 4d e8             	decl   -0x18(%ebp)
  106ace:	89 f0                	mov    %esi,%eax
  106ad0:	8d 70 01             	lea    0x1(%eax),%esi
  106ad3:	0f b6 00             	movzbl (%eax),%eax
  106ad6:	0f be d8             	movsbl %al,%ebx
  106ad9:	85 db                	test   %ebx,%ebx
  106adb:	74 27                	je     106b04 <vprintfmt+0x255>
  106add:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106ae1:	78 b4                	js     106a97 <vprintfmt+0x1e8>
  106ae3:	ff 4d e4             	decl   -0x1c(%ebp)
  106ae6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106aea:	79 ab                	jns    106a97 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  106aec:	eb 16                	jmp    106b04 <vprintfmt+0x255>
                putch(' ', putdat);
  106aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  106af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  106af5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  106afc:	8b 45 08             	mov    0x8(%ebp),%eax
  106aff:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  106b01:	ff 4d e8             	decl   -0x18(%ebp)
  106b04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106b08:	7f e4                	jg     106aee <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  106b0a:	e9 6c 01 00 00       	jmp    106c7b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  106b0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106b12:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b16:	8d 45 14             	lea    0x14(%ebp),%eax
  106b19:	89 04 24             	mov    %eax,(%esp)
  106b1c:	e8 18 fd ff ff       	call   106839 <getint>
  106b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b24:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106b2d:	85 d2                	test   %edx,%edx
  106b2f:	79 26                	jns    106b57 <vprintfmt+0x2a8>
                putch('-', putdat);
  106b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  106b34:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b38:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  106b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  106b42:	ff d0                	call   *%eax
                num = -(long long)num;
  106b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106b4a:	f7 d8                	neg    %eax
  106b4c:	83 d2 00             	adc    $0x0,%edx
  106b4f:	f7 da                	neg    %edx
  106b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b54:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106b57:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106b5e:	e9 a8 00 00 00       	jmp    106c0b <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106b66:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b6a:	8d 45 14             	lea    0x14(%ebp),%eax
  106b6d:	89 04 24             	mov    %eax,(%esp)
  106b70:	e8 75 fc ff ff       	call   1067ea <getuint>
  106b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b78:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  106b7b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  106b82:	e9 84 00 00 00       	jmp    106c0b <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  106b87:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  106b8e:	8d 45 14             	lea    0x14(%ebp),%eax
  106b91:	89 04 24             	mov    %eax,(%esp)
  106b94:	e8 51 fc ff ff       	call   1067ea <getuint>
  106b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106b9c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  106b9f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  106ba6:	eb 63                	jmp    106c0b <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  106ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  106baf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  106bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  106bb9:	ff d0                	call   *%eax
            putch('x', putdat);
  106bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
  106bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bc2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  106bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  106bcc:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  106bce:	8b 45 14             	mov    0x14(%ebp),%eax
  106bd1:	8d 50 04             	lea    0x4(%eax),%edx
  106bd4:	89 55 14             	mov    %edx,0x14(%ebp)
  106bd7:	8b 00                	mov    (%eax),%eax
  106bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106bdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106be3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106bea:	eb 1f                	jmp    106c0b <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  106bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106bef:	89 44 24 04          	mov    %eax,0x4(%esp)
  106bf3:	8d 45 14             	lea    0x14(%ebp),%eax
  106bf6:	89 04 24             	mov    %eax,(%esp)
  106bf9:	e8 ec fb ff ff       	call   1067ea <getuint>
  106bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106c01:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106c04:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  106c0b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  106c0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106c12:	89 54 24 18          	mov    %edx,0x18(%esp)
  106c16:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106c19:	89 54 24 14          	mov    %edx,0x14(%esp)
  106c1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  106c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  106c2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  106c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c32:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c36:	8b 45 08             	mov    0x8(%ebp),%eax
  106c39:	89 04 24             	mov    %eax,(%esp)
  106c3c:	e8 a4 fa ff ff       	call   1066e5 <printnum>
            break;
  106c41:	eb 38                	jmp    106c7b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106c43:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c46:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c4a:	89 1c 24             	mov    %ebx,(%esp)
  106c4d:	8b 45 08             	mov    0x8(%ebp),%eax
  106c50:	ff d0                	call   *%eax
            break;
  106c52:	eb 27                	jmp    106c7b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106c54:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c57:	89 44 24 04          	mov    %eax,0x4(%esp)
  106c5b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106c62:	8b 45 08             	mov    0x8(%ebp),%eax
  106c65:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106c67:	ff 4d 10             	decl   0x10(%ebp)
  106c6a:	eb 03                	jmp    106c6f <vprintfmt+0x3c0>
  106c6c:	ff 4d 10             	decl   0x10(%ebp)
  106c6f:	8b 45 10             	mov    0x10(%ebp),%eax
  106c72:	48                   	dec    %eax
  106c73:	0f b6 00             	movzbl (%eax),%eax
  106c76:	3c 25                	cmp    $0x25,%al
  106c78:	75 f2                	jne    106c6c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106c7a:	90                   	nop
        }
    }
  106c7b:	e9 37 fc ff ff       	jmp    1068b7 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  106c80:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  106c81:	83 c4 40             	add    $0x40,%esp
  106c84:	5b                   	pop    %ebx
  106c85:	5e                   	pop    %esi
  106c86:	5d                   	pop    %ebp
  106c87:	c3                   	ret    

00106c88 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  106c88:	55                   	push   %ebp
  106c89:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  106c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c8e:	8b 40 08             	mov    0x8(%eax),%eax
  106c91:	8d 50 01             	lea    0x1(%eax),%edx
  106c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c97:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  106c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  106c9d:	8b 10                	mov    (%eax),%edx
  106c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  106ca2:	8b 40 04             	mov    0x4(%eax),%eax
  106ca5:	39 c2                	cmp    %eax,%edx
  106ca7:	73 12                	jae    106cbb <sprintputch+0x33>
        *b->buf ++ = ch;
  106ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cac:	8b 00                	mov    (%eax),%eax
  106cae:	8d 48 01             	lea    0x1(%eax),%ecx
  106cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
  106cb4:	89 0a                	mov    %ecx,(%edx)
  106cb6:	8b 55 08             	mov    0x8(%ebp),%edx
  106cb9:	88 10                	mov    %dl,(%eax)
    }
}
  106cbb:	90                   	nop
  106cbc:	5d                   	pop    %ebp
  106cbd:	c3                   	ret    

00106cbe <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  106cbe:	55                   	push   %ebp
  106cbf:	89 e5                	mov    %esp,%ebp
  106cc1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  106cc4:	8d 45 14             	lea    0x14(%ebp),%eax
  106cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  106cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106ccd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106cd1:	8b 45 10             	mov    0x10(%ebp),%eax
  106cd4:	89 44 24 08          	mov    %eax,0x8(%esp)
  106cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  106cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  106ce2:	89 04 24             	mov    %eax,(%esp)
  106ce5:	e8 08 00 00 00       	call   106cf2 <vsnprintf>
  106cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  106ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106cf0:	c9                   	leave  
  106cf1:	c3                   	ret    

00106cf2 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106cf2:	55                   	push   %ebp
  106cf3:	89 e5                	mov    %esp,%ebp
  106cf5:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106cf8:	8b 45 08             	mov    0x8(%ebp),%eax
  106cfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  106cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  106d01:	8d 50 ff             	lea    -0x1(%eax),%edx
  106d04:	8b 45 08             	mov    0x8(%ebp),%eax
  106d07:	01 d0                	add    %edx,%eax
  106d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106d0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106d13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106d17:	74 0a                	je     106d23 <vsnprintf+0x31>
  106d19:	8b 55 ec             	mov    -0x14(%ebp),%edx
  106d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106d1f:	39 c2                	cmp    %eax,%edx
  106d21:	76 07                	jbe    106d2a <vsnprintf+0x38>
        return -E_INVAL;
  106d23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106d28:	eb 2a                	jmp    106d54 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  106d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106d31:	8b 45 10             	mov    0x10(%ebp),%eax
  106d34:	89 44 24 08          	mov    %eax,0x8(%esp)
  106d38:	8d 45 ec             	lea    -0x14(%ebp),%eax
  106d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  106d3f:	c7 04 24 88 6c 10 00 	movl   $0x106c88,(%esp)
  106d46:	e8 64 fb ff ff       	call   1068af <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  106d4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106d4e:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106d54:	c9                   	leave  
  106d55:	c3                   	ret    
