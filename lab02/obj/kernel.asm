
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba 60 39 2a c0       	mov    $0xc02a3960,%edx
c0100041:	b8 00 c0 11 c0       	mov    $0xc011c000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c010005d:	e8 fa 64 00 00       	call   c010655c <memset>

    cons_init();                // init the console
c0100062:	e8 79 15 00 00       	call   c01015e0 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 60 6d 10 c0 	movl   $0xc0106d60,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 7c 6d 10 c0 	movl   $0xc0106d7c,(%esp)
c010007c:	e8 16 02 00 00       	call   c0100297 <cprintf>

    print_kerninfo();
c0100081:	e8 b7 08 00 00       	call   c010093d <print_kerninfo>

    grade_backtrace();
c0100086:	e8 8e 00 00 00       	call   c0100119 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 a4 30 00 00       	call   c0103134 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 af 16 00 00       	call   c0101744 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 2d 18 00 00       	call   c01018c7 <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 f4 0c 00 00       	call   c0100d93 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 d3 17 00 00       	call   c0101877 <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
c01000a4:	e8 60 01 00 00       	call   c0100209 <lab1_switch_test>

    /* do nothing */
    while (1);
c01000a9:	eb fe                	jmp    c01000a9 <kern_init+0x73>

c01000ab <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000ab:	55                   	push   %ebp
c01000ac:	89 e5                	mov    %esp,%ebp
c01000ae:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000b1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b8:	00 
c01000b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000c0:	00 
c01000c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c8:	e8 b4 0c 00 00       	call   c0100d81 <mon_backtrace>
}
c01000cd:	90                   	nop
c01000ce:	c9                   	leave  
c01000cf:	c3                   	ret    

c01000d0 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000d0:	55                   	push   %ebp
c01000d1:	89 e5                	mov    %esp,%ebp
c01000d3:	53                   	push   %ebx
c01000d4:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d7:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000da:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000dd:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01000e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ef:	89 04 24             	mov    %eax,(%esp)
c01000f2:	e8 b4 ff ff ff       	call   c01000ab <grade_backtrace2>
}
c01000f7:	90                   	nop
c01000f8:	83 c4 14             	add    $0x14,%esp
c01000fb:	5b                   	pop    %ebx
c01000fc:	5d                   	pop    %ebp
c01000fd:	c3                   	ret    

c01000fe <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fe:	55                   	push   %ebp
c01000ff:	89 e5                	mov    %esp,%ebp
c0100101:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100104:	8b 45 10             	mov    0x10(%ebp),%eax
c0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
c010010b:	8b 45 08             	mov    0x8(%ebp),%eax
c010010e:	89 04 24             	mov    %eax,(%esp)
c0100111:	e8 ba ff ff ff       	call   c01000d0 <grade_backtrace1>
}
c0100116:	90                   	nop
c0100117:	c9                   	leave  
c0100118:	c3                   	ret    

c0100119 <grade_backtrace>:

void
grade_backtrace(void) {
c0100119:	55                   	push   %ebp
c010011a:	89 e5                	mov    %esp,%ebp
c010011c:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011f:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100124:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c010012b:	ff 
c010012c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100137:	e8 c2 ff ff ff       	call   c01000fe <grade_backtrace0>
}
c010013c:	90                   	nop
c010013d:	c9                   	leave  
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 81 6d 10 c0 	movl   $0xc0106d81,(%esp)
c010016e:	e8 24 01 00 00       	call   c0100297 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 8f 6d 10 c0 	movl   $0xc0106d8f,(%esp)
c010018d:	e8 05 01 00 00       	call   c0100297 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 9d 6d 10 c0 	movl   $0xc0106d9d,(%esp)
c01001ac:	e8 e6 00 00 00       	call   c0100297 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 ab 6d 10 c0 	movl   $0xc0106dab,(%esp)
c01001cb:	e8 c7 00 00 00       	call   c0100297 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 b9 6d 10 c0 	movl   $0xc0106db9,(%esp)
c01001ea:	e8 a8 00 00 00       	call   c0100297 <cprintf>
    round ++;
c01001ef:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c01001fa:	90                   	nop
c01001fb:	c9                   	leave  
c01001fc:	c3                   	ret    

c01001fd <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001fd:	55                   	push   %ebp
c01001fe:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100200:	90                   	nop
c0100201:	5d                   	pop    %ebp
c0100202:	c3                   	ret    

c0100203 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100203:	55                   	push   %ebp
c0100204:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100206:	90                   	nop
c0100207:	5d                   	pop    %ebp
c0100208:	c3                   	ret    

c0100209 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100209:	55                   	push   %ebp
c010020a:	89 e5                	mov    %esp,%ebp
c010020c:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c010020f:	e8 2b ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100214:	c7 04 24 c8 6d 10 c0 	movl   $0xc0106dc8,(%esp)
c010021b:	e8 77 00 00 00       	call   c0100297 <cprintf>
    lab1_switch_to_user();
c0100220:	e8 d8 ff ff ff       	call   c01001fd <lab1_switch_to_user>
    lab1_print_cur_status();
c0100225:	e8 15 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022a:	c7 04 24 e8 6d 10 c0 	movl   $0xc0106de8,(%esp)
c0100231:	e8 61 00 00 00       	call   c0100297 <cprintf>
    lab1_switch_to_kernel();
c0100236:	e8 c8 ff ff ff       	call   c0100203 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023b:	e8 ff fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100240:	90                   	nop
c0100241:	c9                   	leave  
c0100242:	c3                   	ret    

c0100243 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100243:	55                   	push   %ebp
c0100244:	89 e5                	mov    %esp,%ebp
c0100246:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100249:	8b 45 08             	mov    0x8(%ebp),%eax
c010024c:	89 04 24             	mov    %eax,(%esp)
c010024f:	e8 b9 13 00 00       	call   c010160d <cons_putc>
    (*cnt) ++;
c0100254:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100257:	8b 00                	mov    (%eax),%eax
c0100259:	8d 50 01             	lea    0x1(%eax),%edx
c010025c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025f:	89 10                	mov    %edx,(%eax)
}
c0100261:	90                   	nop
c0100262:	c9                   	leave  
c0100263:	c3                   	ret    

c0100264 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100264:	55                   	push   %ebp
c0100265:	89 e5                	mov    %esp,%ebp
c0100267:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010026a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100271:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100274:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100278:	8b 45 08             	mov    0x8(%ebp),%eax
c010027b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010027f:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100282:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100286:	c7 04 24 43 02 10 c0 	movl   $0xc0100243,(%esp)
c010028d:	e8 1d 66 00 00       	call   c01068af <vprintfmt>
    return cnt;
c0100292:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100295:	c9                   	leave  
c0100296:	c3                   	ret    

c0100297 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100297:	55                   	push   %ebp
c0100298:	89 e5                	mov    %esp,%ebp
c010029a:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010029d:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002a6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01002ad:	89 04 24             	mov    %eax,(%esp)
c01002b0:	e8 af ff ff ff       	call   c0100264 <vcprintf>
c01002b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002bb:	c9                   	leave  
c01002bc:	c3                   	ret    

c01002bd <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002bd:	55                   	push   %ebp
c01002be:	89 e5                	mov    %esp,%ebp
c01002c0:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002c3:	8b 45 08             	mov    0x8(%ebp),%eax
c01002c6:	89 04 24             	mov    %eax,(%esp)
c01002c9:	e8 3f 13 00 00       	call   c010160d <cons_putc>
}
c01002ce:	90                   	nop
c01002cf:	c9                   	leave  
c01002d0:	c3                   	ret    

c01002d1 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002d1:	55                   	push   %ebp
c01002d2:	89 e5                	mov    %esp,%ebp
c01002d4:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002d7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002de:	eb 13                	jmp    c01002f3 <cputs+0x22>
        cputch(c, &cnt);
c01002e0:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002e4:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002e7:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002eb:	89 04 24             	mov    %eax,(%esp)
c01002ee:	e8 50 ff ff ff       	call   c0100243 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01002f6:	8d 50 01             	lea    0x1(%eax),%edx
c01002f9:	89 55 08             	mov    %edx,0x8(%ebp)
c01002fc:	0f b6 00             	movzbl (%eax),%eax
c01002ff:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100302:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100306:	75 d8                	jne    c01002e0 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100308:	8d 45 f0             	lea    -0x10(%ebp),%eax
c010030b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010030f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100316:	e8 28 ff ff ff       	call   c0100243 <cputch>
    return cnt;
c010031b:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010031e:	c9                   	leave  
c010031f:	c3                   	ret    

c0100320 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100320:	55                   	push   %ebp
c0100321:	89 e5                	mov    %esp,%ebp
c0100323:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100326:	e8 1f 13 00 00       	call   c010164a <cons_getc>
c010032b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010032e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100332:	74 f2                	je     c0100326 <getchar+0x6>
        /* do nothing */;
    return c;
c0100334:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100337:	c9                   	leave  
c0100338:	c3                   	ret    

c0100339 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100339:	55                   	push   %ebp
c010033a:	89 e5                	mov    %esp,%ebp
c010033c:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010033f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100343:	74 13                	je     c0100358 <readline+0x1f>
        cprintf("%s", prompt);
c0100345:	8b 45 08             	mov    0x8(%ebp),%eax
c0100348:	89 44 24 04          	mov    %eax,0x4(%esp)
c010034c:	c7 04 24 07 6e 10 c0 	movl   $0xc0106e07,(%esp)
c0100353:	e8 3f ff ff ff       	call   c0100297 <cprintf>
    }
    int i = 0, c;
c0100358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010035f:	e8 bc ff ff ff       	call   c0100320 <getchar>
c0100364:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100367:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010036b:	79 07                	jns    c0100374 <readline+0x3b>
            return NULL;
c010036d:	b8 00 00 00 00       	mov    $0x0,%eax
c0100372:	eb 78                	jmp    c01003ec <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100374:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100378:	7e 28                	jle    c01003a2 <readline+0x69>
c010037a:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100381:	7f 1f                	jg     c01003a2 <readline+0x69>
            cputchar(c);
c0100383:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100386:	89 04 24             	mov    %eax,(%esp)
c0100389:	e8 2f ff ff ff       	call   c01002bd <cputchar>
            buf[i ++] = c;
c010038e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100391:	8d 50 01             	lea    0x1(%eax),%edx
c0100394:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100397:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010039a:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01003a0:	eb 45                	jmp    c01003e7 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003a2:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003a6:	75 16                	jne    c01003be <readline+0x85>
c01003a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003ac:	7e 10                	jle    c01003be <readline+0x85>
            cputchar(c);
c01003ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003b1:	89 04 24             	mov    %eax,(%esp)
c01003b4:	e8 04 ff ff ff       	call   c01002bd <cputchar>
            i --;
c01003b9:	ff 4d f4             	decl   -0xc(%ebp)
c01003bc:	eb 29                	jmp    c01003e7 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003be:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003c2:	74 06                	je     c01003ca <readline+0x91>
c01003c4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003c8:	75 95                	jne    c010035f <readline+0x26>
            cputchar(c);
c01003ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003cd:	89 04 24             	mov    %eax,(%esp)
c01003d0:	e8 e8 fe ff ff       	call   c01002bd <cputchar>
            buf[i] = '\0';
c01003d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003d8:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c01003dd:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003e0:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c01003e5:	eb 05                	jmp    c01003ec <readline+0xb3>
        }
    }
c01003e7:	e9 73 ff ff ff       	jmp    c010035f <readline+0x26>
}
c01003ec:	c9                   	leave  
c01003ed:	c3                   	ret    

c01003ee <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003ee:	55                   	push   %ebp
c01003ef:	89 e5                	mov    %esp,%ebp
c01003f1:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003f4:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c01003f9:	85 c0                	test   %eax,%eax
c01003fb:	75 5b                	jne    c0100458 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c01003fd:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100404:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100407:	8d 45 14             	lea    0x14(%ebp),%eax
c010040a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c010040d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100410:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100414:	8b 45 08             	mov    0x8(%ebp),%eax
c0100417:	89 44 24 04          	mov    %eax,0x4(%esp)
c010041b:	c7 04 24 0a 6e 10 c0 	movl   $0xc0106e0a,(%esp)
c0100422:	e8 70 fe ff ff       	call   c0100297 <cprintf>
    vcprintf(fmt, ap);
c0100427:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010042a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010042e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100431:	89 04 24             	mov    %eax,(%esp)
c0100434:	e8 2b fe ff ff       	call   c0100264 <vcprintf>
    cprintf("\n");
c0100439:	c7 04 24 26 6e 10 c0 	movl   $0xc0106e26,(%esp)
c0100440:	e8 52 fe ff ff       	call   c0100297 <cprintf>
    
    cprintf("stack trackback:\n");
c0100445:	c7 04 24 28 6e 10 c0 	movl   $0xc0106e28,(%esp)
c010044c:	e8 46 fe ff ff       	call   c0100297 <cprintf>
    print_stackframe();
c0100451:	e8 32 06 00 00       	call   c0100a88 <print_stackframe>
c0100456:	eb 01                	jmp    c0100459 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100458:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100459:	e8 20 14 00 00       	call   c010187e <intr_disable>
    while (1) {
        kmonitor(NULL);
c010045e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100465:	e8 4a 08 00 00       	call   c0100cb4 <kmonitor>
    }
c010046a:	eb f2                	jmp    c010045e <__panic+0x70>

c010046c <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c010046c:	55                   	push   %ebp
c010046d:	89 e5                	mov    %esp,%ebp
c010046f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100472:	8d 45 14             	lea    0x14(%ebp),%eax
c0100475:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100478:	8b 45 0c             	mov    0xc(%ebp),%eax
c010047b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010047f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100482:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100486:	c7 04 24 3a 6e 10 c0 	movl   $0xc0106e3a,(%esp)
c010048d:	e8 05 fe ff ff       	call   c0100297 <cprintf>
    vcprintf(fmt, ap);
c0100492:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100495:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100499:	8b 45 10             	mov    0x10(%ebp),%eax
c010049c:	89 04 24             	mov    %eax,(%esp)
c010049f:	e8 c0 fd ff ff       	call   c0100264 <vcprintf>
    cprintf("\n");
c01004a4:	c7 04 24 26 6e 10 c0 	movl   $0xc0106e26,(%esp)
c01004ab:	e8 e7 fd ff ff       	call   c0100297 <cprintf>
    va_end(ap);
}
c01004b0:	90                   	nop
c01004b1:	c9                   	leave  
c01004b2:	c3                   	ret    

c01004b3 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004b3:	55                   	push   %ebp
c01004b4:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004b6:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c01004bb:	5d                   	pop    %ebp
c01004bc:	c3                   	ret    

c01004bd <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004bd:	55                   	push   %ebp
c01004be:	89 e5                	mov    %esp,%ebp
c01004c0:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004c6:	8b 00                	mov    (%eax),%eax
c01004c8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004cb:	8b 45 10             	mov    0x10(%ebp),%eax
c01004ce:	8b 00                	mov    (%eax),%eax
c01004d0:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004da:	e9 ca 00 00 00       	jmp    c01005a9 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004df:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004e2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004e5:	01 d0                	add    %edx,%eax
c01004e7:	89 c2                	mov    %eax,%edx
c01004e9:	c1 ea 1f             	shr    $0x1f,%edx
c01004ec:	01 d0                	add    %edx,%eax
c01004ee:	d1 f8                	sar    %eax
c01004f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004f6:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004f9:	eb 03                	jmp    c01004fe <stab_binsearch+0x41>
            m --;
c01004fb:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100501:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100504:	7c 1f                	jl     c0100525 <stab_binsearch+0x68>
c0100506:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100509:	89 d0                	mov    %edx,%eax
c010050b:	01 c0                	add    %eax,%eax
c010050d:	01 d0                	add    %edx,%eax
c010050f:	c1 e0 02             	shl    $0x2,%eax
c0100512:	89 c2                	mov    %eax,%edx
c0100514:	8b 45 08             	mov    0x8(%ebp),%eax
c0100517:	01 d0                	add    %edx,%eax
c0100519:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010051d:	0f b6 c0             	movzbl %al,%eax
c0100520:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100523:	75 d6                	jne    c01004fb <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c0100525:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100528:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010052b:	7d 09                	jge    c0100536 <stab_binsearch+0x79>
            l = true_m + 1;
c010052d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100530:	40                   	inc    %eax
c0100531:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100534:	eb 73                	jmp    c01005a9 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100536:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c010053d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100540:	89 d0                	mov    %edx,%eax
c0100542:	01 c0                	add    %eax,%eax
c0100544:	01 d0                	add    %edx,%eax
c0100546:	c1 e0 02             	shl    $0x2,%eax
c0100549:	89 c2                	mov    %eax,%edx
c010054b:	8b 45 08             	mov    0x8(%ebp),%eax
c010054e:	01 d0                	add    %edx,%eax
c0100550:	8b 40 08             	mov    0x8(%eax),%eax
c0100553:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100556:	73 11                	jae    c0100569 <stab_binsearch+0xac>
            *region_left = m;
c0100558:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010055e:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100560:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100563:	40                   	inc    %eax
c0100564:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100567:	eb 40                	jmp    c01005a9 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100569:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010056c:	89 d0                	mov    %edx,%eax
c010056e:	01 c0                	add    %eax,%eax
c0100570:	01 d0                	add    %edx,%eax
c0100572:	c1 e0 02             	shl    $0x2,%eax
c0100575:	89 c2                	mov    %eax,%edx
c0100577:	8b 45 08             	mov    0x8(%ebp),%eax
c010057a:	01 d0                	add    %edx,%eax
c010057c:	8b 40 08             	mov    0x8(%eax),%eax
c010057f:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100582:	76 14                	jbe    c0100598 <stab_binsearch+0xdb>
            *region_right = m - 1;
c0100584:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100587:	8d 50 ff             	lea    -0x1(%eax),%edx
c010058a:	8b 45 10             	mov    0x10(%ebp),%eax
c010058d:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c010058f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100592:	48                   	dec    %eax
c0100593:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100596:	eb 11                	jmp    c01005a9 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c0100598:	8b 45 0c             	mov    0xc(%ebp),%eax
c010059b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010059e:	89 10                	mov    %edx,(%eax)
            l = m;
c01005a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005a6:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005ac:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005af:	0f 8e 2a ff ff ff    	jle    c01004df <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005b9:	75 0f                	jne    c01005ca <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005bb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005be:	8b 00                	mov    (%eax),%eax
c01005c0:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005c3:	8b 45 10             	mov    0x10(%ebp),%eax
c01005c6:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005c8:	eb 3e                	jmp    c0100608 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005ca:	8b 45 10             	mov    0x10(%ebp),%eax
c01005cd:	8b 00                	mov    (%eax),%eax
c01005cf:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005d2:	eb 03                	jmp    c01005d7 <stab_binsearch+0x11a>
c01005d4:	ff 4d fc             	decl   -0x4(%ebp)
c01005d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005da:	8b 00                	mov    (%eax),%eax
c01005dc:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005df:	7d 1f                	jge    c0100600 <stab_binsearch+0x143>
c01005e1:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005e4:	89 d0                	mov    %edx,%eax
c01005e6:	01 c0                	add    %eax,%eax
c01005e8:	01 d0                	add    %edx,%eax
c01005ea:	c1 e0 02             	shl    $0x2,%eax
c01005ed:	89 c2                	mov    %eax,%edx
c01005ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f2:	01 d0                	add    %edx,%eax
c01005f4:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005f8:	0f b6 c0             	movzbl %al,%eax
c01005fb:	3b 45 14             	cmp    0x14(%ebp),%eax
c01005fe:	75 d4                	jne    c01005d4 <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c0100600:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100603:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100606:	89 10                	mov    %edx,(%eax)
    }
}
c0100608:	90                   	nop
c0100609:	c9                   	leave  
c010060a:	c3                   	ret    

c010060b <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c010060b:	55                   	push   %ebp
c010060c:	89 e5                	mov    %esp,%ebp
c010060e:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100611:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100614:	c7 00 58 6e 10 c0    	movl   $0xc0106e58,(%eax)
    info->eip_line = 0;
c010061a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c0100624:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100627:	c7 40 08 58 6e 10 c0 	movl   $0xc0106e58,0x8(%eax)
    info->eip_fn_namelen = 9;
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100638:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063b:	8b 55 08             	mov    0x8(%ebp),%edx
c010063e:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100641:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100644:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c010064b:	c7 45 f4 54 82 10 c0 	movl   $0xc0108254,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100652:	c7 45 f0 dc 41 11 c0 	movl   $0xc01141dc,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100659:	c7 45 ec dd 41 11 c0 	movl   $0xc01141dd,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100660:	c7 45 e8 0d 6f 11 c0 	movl   $0xc0116f0d,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100667:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010066a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010066d:	76 0b                	jbe    c010067a <debuginfo_eip+0x6f>
c010066f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100672:	48                   	dec    %eax
c0100673:	0f b6 00             	movzbl (%eax),%eax
c0100676:	84 c0                	test   %al,%al
c0100678:	74 0a                	je     c0100684 <debuginfo_eip+0x79>
        return -1;
c010067a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010067f:	e9 b7 02 00 00       	jmp    c010093b <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c0100684:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c010068b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010068e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100691:	29 c2                	sub    %eax,%edx
c0100693:	89 d0                	mov    %edx,%eax
c0100695:	c1 f8 02             	sar    $0x2,%eax
c0100698:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c010069e:	48                   	dec    %eax
c010069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01006a5:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006a9:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006b0:	00 
c01006b1:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006b4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c2:	89 04 24             	mov    %eax,(%esp)
c01006c5:	e8 f3 fd ff ff       	call   c01004bd <stab_binsearch>
    if (lfile == 0)
c01006ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006cd:	85 c0                	test   %eax,%eax
c01006cf:	75 0a                	jne    c01006db <debuginfo_eip+0xd0>
        return -1;
c01006d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006d6:	e9 60 02 00 00       	jmp    c010093b <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006de:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006e1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ea:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006ee:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006f5:	00 
c01006f6:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006f9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006fd:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100700:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100704:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100707:	89 04 24             	mov    %eax,(%esp)
c010070a:	e8 ae fd ff ff       	call   c01004bd <stab_binsearch>

    if (lfun <= rfun) {
c010070f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100712:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100715:	39 c2                	cmp    %eax,%edx
c0100717:	7f 7c                	jg     c0100795 <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100719:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010071c:	89 c2                	mov    %eax,%edx
c010071e:	89 d0                	mov    %edx,%eax
c0100720:	01 c0                	add    %eax,%eax
c0100722:	01 d0                	add    %edx,%eax
c0100724:	c1 e0 02             	shl    $0x2,%eax
c0100727:	89 c2                	mov    %eax,%edx
c0100729:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072c:	01 d0                	add    %edx,%eax
c010072e:	8b 00                	mov    (%eax),%eax
c0100730:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100733:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100736:	29 d1                	sub    %edx,%ecx
c0100738:	89 ca                	mov    %ecx,%edx
c010073a:	39 d0                	cmp    %edx,%eax
c010073c:	73 22                	jae    c0100760 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010073e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100741:	89 c2                	mov    %eax,%edx
c0100743:	89 d0                	mov    %edx,%eax
c0100745:	01 c0                	add    %eax,%eax
c0100747:	01 d0                	add    %edx,%eax
c0100749:	c1 e0 02             	shl    $0x2,%eax
c010074c:	89 c2                	mov    %eax,%edx
c010074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100751:	01 d0                	add    %edx,%eax
c0100753:	8b 10                	mov    (%eax),%edx
c0100755:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100758:	01 c2                	add    %eax,%edx
c010075a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075d:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100760:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100763:	89 c2                	mov    %eax,%edx
c0100765:	89 d0                	mov    %edx,%eax
c0100767:	01 c0                	add    %eax,%eax
c0100769:	01 d0                	add    %edx,%eax
c010076b:	c1 e0 02             	shl    $0x2,%eax
c010076e:	89 c2                	mov    %eax,%edx
c0100770:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100773:	01 d0                	add    %edx,%eax
c0100775:	8b 50 08             	mov    0x8(%eax),%edx
c0100778:	8b 45 0c             	mov    0xc(%ebp),%eax
c010077b:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c010077e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100781:	8b 40 10             	mov    0x10(%eax),%eax
c0100784:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100787:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010078a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c010078d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100790:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100793:	eb 15                	jmp    c01007aa <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c0100795:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100798:	8b 55 08             	mov    0x8(%ebp),%edx
c010079b:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c010079e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007a1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007ad:	8b 40 08             	mov    0x8(%eax),%eax
c01007b0:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007b7:	00 
c01007b8:	89 04 24             	mov    %eax,(%esp)
c01007bb:	e8 18 5c 00 00       	call   c01063d8 <strfind>
c01007c0:	89 c2                	mov    %eax,%edx
c01007c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007c5:	8b 40 08             	mov    0x8(%eax),%eax
c01007c8:	29 c2                	sub    %eax,%edx
c01007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cd:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01007d3:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007d7:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007de:	00 
c01007df:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007e2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007e6:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f0:	89 04 24             	mov    %eax,(%esp)
c01007f3:	e8 c5 fc ff ff       	call   c01004bd <stab_binsearch>
    if (lline <= rline) {
c01007f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01007fe:	39 c2                	cmp    %eax,%edx
c0100800:	7f 23                	jg     c0100825 <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c0100802:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100805:	89 c2                	mov    %eax,%edx
c0100807:	89 d0                	mov    %edx,%eax
c0100809:	01 c0                	add    %eax,%eax
c010080b:	01 d0                	add    %edx,%eax
c010080d:	c1 e0 02             	shl    $0x2,%eax
c0100810:	89 c2                	mov    %eax,%edx
c0100812:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100815:	01 d0                	add    %edx,%eax
c0100817:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c010081b:	89 c2                	mov    %eax,%edx
c010081d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100820:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100823:	eb 11                	jmp    c0100836 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c0100825:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010082a:	e9 0c 01 00 00       	jmp    c010093b <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010082f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100832:	48                   	dec    %eax
c0100833:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100836:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100839:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010083c:	39 c2                	cmp    %eax,%edx
c010083e:	7c 56                	jl     c0100896 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c0100840:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100843:	89 c2                	mov    %eax,%edx
c0100845:	89 d0                	mov    %edx,%eax
c0100847:	01 c0                	add    %eax,%eax
c0100849:	01 d0                	add    %edx,%eax
c010084b:	c1 e0 02             	shl    $0x2,%eax
c010084e:	89 c2                	mov    %eax,%edx
c0100850:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100853:	01 d0                	add    %edx,%eax
c0100855:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100859:	3c 84                	cmp    $0x84,%al
c010085b:	74 39                	je     c0100896 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010085d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100860:	89 c2                	mov    %eax,%edx
c0100862:	89 d0                	mov    %edx,%eax
c0100864:	01 c0                	add    %eax,%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	c1 e0 02             	shl    $0x2,%eax
c010086b:	89 c2                	mov    %eax,%edx
c010086d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100876:	3c 64                	cmp    $0x64,%al
c0100878:	75 b5                	jne    c010082f <debuginfo_eip+0x224>
c010087a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010087d:	89 c2                	mov    %eax,%edx
c010087f:	89 d0                	mov    %edx,%eax
c0100881:	01 c0                	add    %eax,%eax
c0100883:	01 d0                	add    %edx,%eax
c0100885:	c1 e0 02             	shl    $0x2,%eax
c0100888:	89 c2                	mov    %eax,%edx
c010088a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010088d:	01 d0                	add    %edx,%eax
c010088f:	8b 40 08             	mov    0x8(%eax),%eax
c0100892:	85 c0                	test   %eax,%eax
c0100894:	74 99                	je     c010082f <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c0100896:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100899:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010089c:	39 c2                	cmp    %eax,%edx
c010089e:	7c 46                	jl     c01008e6 <debuginfo_eip+0x2db>
c01008a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a3:	89 c2                	mov    %eax,%edx
c01008a5:	89 d0                	mov    %edx,%eax
c01008a7:	01 c0                	add    %eax,%eax
c01008a9:	01 d0                	add    %edx,%eax
c01008ab:	c1 e0 02             	shl    $0x2,%eax
c01008ae:	89 c2                	mov    %eax,%edx
c01008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b3:	01 d0                	add    %edx,%eax
c01008b5:	8b 00                	mov    (%eax),%eax
c01008b7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008ba:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008bd:	29 d1                	sub    %edx,%ecx
c01008bf:	89 ca                	mov    %ecx,%edx
c01008c1:	39 d0                	cmp    %edx,%eax
c01008c3:	73 21                	jae    c01008e6 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008c8:	89 c2                	mov    %eax,%edx
c01008ca:	89 d0                	mov    %edx,%eax
c01008cc:	01 c0                	add    %eax,%eax
c01008ce:	01 d0                	add    %edx,%eax
c01008d0:	c1 e0 02             	shl    $0x2,%eax
c01008d3:	89 c2                	mov    %eax,%edx
c01008d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008d8:	01 d0                	add    %edx,%eax
c01008da:	8b 10                	mov    (%eax),%edx
c01008dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008df:	01 c2                	add    %eax,%edx
c01008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008e4:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008e6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008ec:	39 c2                	cmp    %eax,%edx
c01008ee:	7d 46                	jge    c0100936 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008f3:	40                   	inc    %eax
c01008f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008f7:	eb 16                	jmp    c010090f <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008fc:	8b 40 14             	mov    0x14(%eax),%eax
c01008ff:	8d 50 01             	lea    0x1(%eax),%edx
c0100902:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100905:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100908:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010090b:	40                   	inc    %eax
c010090c:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010090f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100912:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c0100915:	39 c2                	cmp    %eax,%edx
c0100917:	7d 1d                	jge    c0100936 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100919:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010091c:	89 c2                	mov    %eax,%edx
c010091e:	89 d0                	mov    %edx,%eax
c0100920:	01 c0                	add    %eax,%eax
c0100922:	01 d0                	add    %edx,%eax
c0100924:	c1 e0 02             	shl    $0x2,%eax
c0100927:	89 c2                	mov    %eax,%edx
c0100929:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010092c:	01 d0                	add    %edx,%eax
c010092e:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100932:	3c a0                	cmp    $0xa0,%al
c0100934:	74 c3                	je     c01008f9 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100936:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010093b:	c9                   	leave  
c010093c:	c3                   	ret    

c010093d <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c010093d:	55                   	push   %ebp
c010093e:	89 e5                	mov    %esp,%ebp
c0100940:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100943:	c7 04 24 62 6e 10 c0 	movl   $0xc0106e62,(%esp)
c010094a:	e8 48 f9 ff ff       	call   c0100297 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010094f:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100956:	c0 
c0100957:	c7 04 24 7b 6e 10 c0 	movl   $0xc0106e7b,(%esp)
c010095e:	e8 34 f9 ff ff       	call   c0100297 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100963:	c7 44 24 04 56 6d 10 	movl   $0xc0106d56,0x4(%esp)
c010096a:	c0 
c010096b:	c7 04 24 93 6e 10 c0 	movl   $0xc0106e93,(%esp)
c0100972:	e8 20 f9 ff ff       	call   c0100297 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100977:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c010097e:	c0 
c010097f:	c7 04 24 ab 6e 10 c0 	movl   $0xc0106eab,(%esp)
c0100986:	e8 0c f9 ff ff       	call   c0100297 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c010098b:	c7 44 24 04 60 39 2a 	movl   $0xc02a3960,0x4(%esp)
c0100992:	c0 
c0100993:	c7 04 24 c3 6e 10 c0 	movl   $0xc0106ec3,(%esp)
c010099a:	e8 f8 f8 ff ff       	call   c0100297 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c010099f:	b8 60 39 2a c0       	mov    $0xc02a3960,%eax
c01009a4:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009aa:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009af:	29 c2                	sub    %eax,%edx
c01009b1:	89 d0                	mov    %edx,%eax
c01009b3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b9:	85 c0                	test   %eax,%eax
c01009bb:	0f 48 c2             	cmovs  %edx,%eax
c01009be:	c1 f8 0a             	sar    $0xa,%eax
c01009c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009c5:	c7 04 24 dc 6e 10 c0 	movl   $0xc0106edc,(%esp)
c01009cc:	e8 c6 f8 ff ff       	call   c0100297 <cprintf>
}
c01009d1:	90                   	nop
c01009d2:	c9                   	leave  
c01009d3:	c3                   	ret    

c01009d4 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009d4:	55                   	push   %ebp
c01009d5:	89 e5                	mov    %esp,%ebp
c01009d7:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009e0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01009e7:	89 04 24             	mov    %eax,(%esp)
c01009ea:	e8 1c fc ff ff       	call   c010060b <debuginfo_eip>
c01009ef:	85 c0                	test   %eax,%eax
c01009f1:	74 15                	je     c0100a08 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fa:	c7 04 24 06 6f 10 c0 	movl   $0xc0106f06,(%esp)
c0100a01:	e8 91 f8 ff ff       	call   c0100297 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a06:	eb 6c                	jmp    c0100a74 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a08:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a0f:	eb 1b                	jmp    c0100a2c <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a11:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a17:	01 d0                	add    %edx,%eax
c0100a19:	0f b6 00             	movzbl (%eax),%eax
c0100a1c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a22:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a25:	01 ca                	add    %ecx,%edx
c0100a27:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a29:	ff 45 f4             	incl   -0xc(%ebp)
c0100a2c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a32:	7f dd                	jg     c0100a11 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a34:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a3d:	01 d0                	add    %edx,%eax
c0100a3f:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a42:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a45:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a48:	89 d1                	mov    %edx,%ecx
c0100a4a:	29 c1                	sub    %eax,%ecx
c0100a4c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a52:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a56:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a5c:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a60:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a64:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a68:	c7 04 24 22 6f 10 c0 	movl   $0xc0106f22,(%esp)
c0100a6f:	e8 23 f8 ff ff       	call   c0100297 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a74:	90                   	nop
c0100a75:	c9                   	leave  
c0100a76:	c3                   	ret    

c0100a77 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a77:	55                   	push   %ebp
c0100a78:	89 e5                	mov    %esp,%ebp
c0100a7a:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a7d:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a80:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a83:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a86:	c9                   	leave  
c0100a87:	c3                   	ret    

c0100a88 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a88:	55                   	push   %ebp
c0100a89:	89 e5                	mov    %esp,%ebp
c0100a8b:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a8e:	89 e8                	mov    %ebp,%eax
c0100a90:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a93:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100a96:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100a99:	e8 d9 ff ff ff       	call   c0100a77 <read_eip>
c0100a9e:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100aa1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aa8:	e9 84 00 00 00       	jmp    c0100b31 <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ab0:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100ab4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100abb:	c7 04 24 34 6f 10 c0 	movl   $0xc0106f34,(%esp)
c0100ac2:	e8 d0 f7 ff ff       	call   c0100297 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100aca:	83 c0 08             	add    $0x8,%eax
c0100acd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100ad0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ad7:	eb 24                	jmp    c0100afd <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100ad9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100adc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100ae3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100ae6:	01 d0                	add    %edx,%eax
c0100ae8:	8b 00                	mov    (%eax),%eax
c0100aea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100aee:	c7 04 24 50 6f 10 c0 	movl   $0xc0106f50,(%esp)
c0100af5:	e8 9d f7 ff ff       	call   c0100297 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100afa:	ff 45 e8             	incl   -0x18(%ebp)
c0100afd:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b01:	7e d6                	jle    c0100ad9 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100b03:	c7 04 24 58 6f 10 c0 	movl   $0xc0106f58,(%esp)
c0100b0a:	e8 88 f7 ff ff       	call   c0100297 <cprintf>
        print_debuginfo(eip - 1);
c0100b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b12:	48                   	dec    %eax
c0100b13:	89 04 24             	mov    %eax,(%esp)
c0100b16:	e8 b9 fe ff ff       	call   c01009d4 <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b1e:	83 c0 04             	add    $0x4,%eax
c0100b21:	8b 00                	mov    (%eax),%eax
c0100b23:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b26:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b29:	8b 00                	mov    (%eax),%eax
c0100b2b:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b2e:	ff 45 ec             	incl   -0x14(%ebp)
c0100b31:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b35:	74 0a                	je     c0100b41 <print_stackframe+0xb9>
c0100b37:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b3b:	0f 8e 6c ff ff ff    	jle    c0100aad <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b41:	90                   	nop
c0100b42:	c9                   	leave  
c0100b43:	c3                   	ret    

c0100b44 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b44:	55                   	push   %ebp
c0100b45:	89 e5                	mov    %esp,%ebp
c0100b47:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b51:	eb 0c                	jmp    c0100b5f <parse+0x1b>
            *buf ++ = '\0';
c0100b53:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b56:	8d 50 01             	lea    0x1(%eax),%edx
c0100b59:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b5c:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b62:	0f b6 00             	movzbl (%eax),%eax
c0100b65:	84 c0                	test   %al,%al
c0100b67:	74 1d                	je     c0100b86 <parse+0x42>
c0100b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6c:	0f b6 00             	movzbl (%eax),%eax
c0100b6f:	0f be c0             	movsbl %al,%eax
c0100b72:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b76:	c7 04 24 dc 6f 10 c0 	movl   $0xc0106fdc,(%esp)
c0100b7d:	e8 24 58 00 00       	call   c01063a6 <strchr>
c0100b82:	85 c0                	test   %eax,%eax
c0100b84:	75 cd                	jne    c0100b53 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b89:	0f b6 00             	movzbl (%eax),%eax
c0100b8c:	84 c0                	test   %al,%al
c0100b8e:	74 69                	je     c0100bf9 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b90:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b94:	75 14                	jne    c0100baa <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100b96:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100b9d:	00 
c0100b9e:	c7 04 24 e1 6f 10 c0 	movl   $0xc0106fe1,(%esp)
c0100ba5:	e8 ed f6 ff ff       	call   c0100297 <cprintf>
        }
        argv[argc ++] = buf;
c0100baa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bad:	8d 50 01             	lea    0x1(%eax),%edx
c0100bb0:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bb3:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bbd:	01 c2                	add    %eax,%edx
c0100bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bc2:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc4:	eb 03                	jmp    c0100bc9 <parse+0x85>
            buf ++;
c0100bc6:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcc:	0f b6 00             	movzbl (%eax),%eax
c0100bcf:	84 c0                	test   %al,%al
c0100bd1:	0f 84 7a ff ff ff    	je     c0100b51 <parse+0xd>
c0100bd7:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bda:	0f b6 00             	movzbl (%eax),%eax
c0100bdd:	0f be c0             	movsbl %al,%eax
c0100be0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be4:	c7 04 24 dc 6f 10 c0 	movl   $0xc0106fdc,(%esp)
c0100beb:	e8 b6 57 00 00       	call   c01063a6 <strchr>
c0100bf0:	85 c0                	test   %eax,%eax
c0100bf2:	74 d2                	je     c0100bc6 <parse+0x82>
            buf ++;
        }
    }
c0100bf4:	e9 58 ff ff ff       	jmp    c0100b51 <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100bf9:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100bfd:	c9                   	leave  
c0100bfe:	c3                   	ret    

c0100bff <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100bff:	55                   	push   %ebp
c0100c00:	89 e5                	mov    %esp,%ebp
c0100c02:	53                   	push   %ebx
c0100c03:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c06:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c09:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c10:	89 04 24             	mov    %eax,(%esp)
c0100c13:	e8 2c ff ff ff       	call   c0100b44 <parse>
c0100c18:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c1f:	75 0a                	jne    c0100c2b <runcmd+0x2c>
        return 0;
c0100c21:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c26:	e9 83 00 00 00       	jmp    c0100cae <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c2b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c32:	eb 5a                	jmp    c0100c8e <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c34:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c37:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c3a:	89 d0                	mov    %edx,%eax
c0100c3c:	01 c0                	add    %eax,%eax
c0100c3e:	01 d0                	add    %edx,%eax
c0100c40:	c1 e0 02             	shl    $0x2,%eax
c0100c43:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100c48:	8b 00                	mov    (%eax),%eax
c0100c4a:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c4e:	89 04 24             	mov    %eax,(%esp)
c0100c51:	e8 b3 56 00 00       	call   c0106309 <strcmp>
c0100c56:	85 c0                	test   %eax,%eax
c0100c58:	75 31                	jne    c0100c8b <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c5d:	89 d0                	mov    %edx,%eax
c0100c5f:	01 c0                	add    %eax,%eax
c0100c61:	01 d0                	add    %edx,%eax
c0100c63:	c1 e0 02             	shl    $0x2,%eax
c0100c66:	05 08 90 11 c0       	add    $0xc0119008,%eax
c0100c6b:	8b 10                	mov    (%eax),%edx
c0100c6d:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c70:	83 c0 04             	add    $0x4,%eax
c0100c73:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c76:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c7c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c80:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c84:	89 1c 24             	mov    %ebx,(%esp)
c0100c87:	ff d2                	call   *%edx
c0100c89:	eb 23                	jmp    c0100cae <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c8b:	ff 45 f4             	incl   -0xc(%ebp)
c0100c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c91:	83 f8 02             	cmp    $0x2,%eax
c0100c94:	76 9e                	jbe    c0100c34 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100c96:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100c99:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9d:	c7 04 24 ff 6f 10 c0 	movl   $0xc0106fff,(%esp)
c0100ca4:	e8 ee f5 ff ff       	call   c0100297 <cprintf>
    return 0;
c0100ca9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cae:	83 c4 64             	add    $0x64,%esp
c0100cb1:	5b                   	pop    %ebx
c0100cb2:	5d                   	pop    %ebp
c0100cb3:	c3                   	ret    

c0100cb4 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cb4:	55                   	push   %ebp
c0100cb5:	89 e5                	mov    %esp,%ebp
c0100cb7:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cba:	c7 04 24 18 70 10 c0 	movl   $0xc0107018,(%esp)
c0100cc1:	e8 d1 f5 ff ff       	call   c0100297 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cc6:	c7 04 24 40 70 10 c0 	movl   $0xc0107040,(%esp)
c0100ccd:	e8 c5 f5 ff ff       	call   c0100297 <cprintf>

    if (tf != NULL) {
c0100cd2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cd6:	74 0b                	je     c0100ce3 <kmonitor+0x2f>
        print_trapframe(tf);
c0100cd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cdb:	89 04 24             	mov    %eax,(%esp)
c0100cde:	e8 1e 0d 00 00       	call   c0101a01 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100ce3:	c7 04 24 65 70 10 c0 	movl   $0xc0107065,(%esp)
c0100cea:	e8 4a f6 ff ff       	call   c0100339 <readline>
c0100cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cf2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100cf6:	74 eb                	je     c0100ce3 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d02:	89 04 24             	mov    %eax,(%esp)
c0100d05:	e8 f5 fe ff ff       	call   c0100bff <runcmd>
c0100d0a:	85 c0                	test   %eax,%eax
c0100d0c:	78 02                	js     c0100d10 <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d0e:	eb d3                	jmp    c0100ce3 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d10:	90                   	nop
            }
        }
    }
}
c0100d11:	90                   	nop
c0100d12:	c9                   	leave  
c0100d13:	c3                   	ret    

c0100d14 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d14:	55                   	push   %ebp
c0100d15:	89 e5                	mov    %esp,%ebp
c0100d17:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d1a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d21:	eb 3d                	jmp    c0100d60 <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d23:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d26:	89 d0                	mov    %edx,%eax
c0100d28:	01 c0                	add    %eax,%eax
c0100d2a:	01 d0                	add    %edx,%eax
c0100d2c:	c1 e0 02             	shl    $0x2,%eax
c0100d2f:	05 04 90 11 c0       	add    $0xc0119004,%eax
c0100d34:	8b 08                	mov    (%eax),%ecx
c0100d36:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d39:	89 d0                	mov    %edx,%eax
c0100d3b:	01 c0                	add    %eax,%eax
c0100d3d:	01 d0                	add    %edx,%eax
c0100d3f:	c1 e0 02             	shl    $0x2,%eax
c0100d42:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100d47:	8b 00                	mov    (%eax),%eax
c0100d49:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d51:	c7 04 24 69 70 10 c0 	movl   $0xc0107069,(%esp)
c0100d58:	e8 3a f5 ff ff       	call   c0100297 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d5d:	ff 45 f4             	incl   -0xc(%ebp)
c0100d60:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d63:	83 f8 02             	cmp    $0x2,%eax
c0100d66:	76 bb                	jbe    c0100d23 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d68:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d6d:	c9                   	leave  
c0100d6e:	c3                   	ret    

c0100d6f <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d6f:	55                   	push   %ebp
c0100d70:	89 e5                	mov    %esp,%ebp
c0100d72:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d75:	e8 c3 fb ff ff       	call   c010093d <print_kerninfo>
    return 0;
c0100d7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d7f:	c9                   	leave  
c0100d80:	c3                   	ret    

c0100d81 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d81:	55                   	push   %ebp
c0100d82:	89 e5                	mov    %esp,%ebp
c0100d84:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d87:	e8 fc fc ff ff       	call   c0100a88 <print_stackframe>
    return 0;
c0100d8c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d91:	c9                   	leave  
c0100d92:	c3                   	ret    

c0100d93 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100d93:	55                   	push   %ebp
c0100d94:	89 e5                	mov    %esp,%ebp
c0100d96:	83 ec 28             	sub    $0x28,%esp
c0100d99:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100d9f:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100da3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100da7:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dab:	ee                   	out    %al,(%dx)
c0100dac:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100db2:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100db6:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100dba:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100dbd:	ee                   	out    %al,(%dx)
c0100dbe:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dc4:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100dc8:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100dcc:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100dd0:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dd1:	c7 05 0c cf 11 c0 00 	movl   $0x0,0xc011cf0c
c0100dd8:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100ddb:	c7 04 24 72 70 10 c0 	movl   $0xc0107072,(%esp)
c0100de2:	e8 b0 f4 ff ff       	call   c0100297 <cprintf>
    pic_enable(IRQ_TIMER);
c0100de7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100dee:	e8 1e 09 00 00       	call   c0101711 <pic_enable>
}
c0100df3:	90                   	nop
c0100df4:	c9                   	leave  
c0100df5:	c3                   	ret    

c0100df6 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100df6:	55                   	push   %ebp
c0100df7:	89 e5                	mov    %esp,%ebp
c0100df9:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100dfc:	9c                   	pushf  
c0100dfd:	58                   	pop    %eax
c0100dfe:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e01:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e04:	25 00 02 00 00       	and    $0x200,%eax
c0100e09:	85 c0                	test   %eax,%eax
c0100e0b:	74 0c                	je     c0100e19 <__intr_save+0x23>
        intr_disable();
c0100e0d:	e8 6c 0a 00 00       	call   c010187e <intr_disable>
        return 1;
c0100e12:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e17:	eb 05                	jmp    c0100e1e <__intr_save+0x28>
    }
    return 0;
c0100e19:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e1e:	c9                   	leave  
c0100e1f:	c3                   	ret    

c0100e20 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e20:	55                   	push   %ebp
c0100e21:	89 e5                	mov    %esp,%ebp
c0100e23:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e26:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e2a:	74 05                	je     c0100e31 <__intr_restore+0x11>
        intr_enable();
c0100e2c:	e8 46 0a 00 00       	call   c0101877 <intr_enable>
    }
}
c0100e31:	90                   	nop
c0100e32:	c9                   	leave  
c0100e33:	c3                   	ret    

c0100e34 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e34:	55                   	push   %ebp
c0100e35:	89 e5                	mov    %esp,%ebp
c0100e37:	83 ec 10             	sub    $0x10,%esp
c0100e3a:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e40:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e44:	89 c2                	mov    %eax,%edx
c0100e46:	ec                   	in     (%dx),%al
c0100e47:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e4a:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e50:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e53:	89 c2                	mov    %eax,%edx
c0100e55:	ec                   	in     (%dx),%al
c0100e56:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e59:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e5f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e63:	89 c2                	mov    %eax,%edx
c0100e65:	ec                   	in     (%dx),%al
c0100e66:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e69:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100e72:	89 c2                	mov    %eax,%edx
c0100e74:	ec                   	in     (%dx),%al
c0100e75:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e78:	90                   	nop
c0100e79:	c9                   	leave  
c0100e7a:	c3                   	ret    

c0100e7b <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e7b:	55                   	push   %ebp
c0100e7c:	89 e5                	mov    %esp,%ebp
c0100e7e:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e81:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100e88:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e8b:	0f b7 00             	movzwl (%eax),%eax
c0100e8e:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100e92:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e95:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100e9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e9d:	0f b7 00             	movzwl (%eax),%eax
c0100ea0:	0f b7 c0             	movzwl %ax,%eax
c0100ea3:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ea8:	74 12                	je     c0100ebc <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100eaa:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100eb1:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100eb8:	b4 03 
c0100eba:	eb 13                	jmp    c0100ecf <cga_init+0x54>
    } else {
        *cp = was;
c0100ebc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebf:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ec3:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ec6:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100ecd:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100ecf:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100ed6:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100eda:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ede:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100ee2:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0100ee5:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100ee6:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100eed:	40                   	inc    %eax
c0100eee:	0f b7 c0             	movzwl %ax,%eax
c0100ef1:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ef5:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100ef9:	89 c2                	mov    %eax,%edx
c0100efb:	ec                   	in     (%dx),%al
c0100efc:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100eff:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100f03:	0f b6 c0             	movzbl %al,%eax
c0100f06:	c1 e0 08             	shl    $0x8,%eax
c0100f09:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f0c:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f13:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f17:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f1b:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f1f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100f22:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f23:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f2a:	40                   	inc    %eax
c0100f2b:	0f b7 c0             	movzwl %ax,%eax
c0100f2e:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f32:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f36:	89 c2                	mov    %eax,%edx
c0100f38:	ec                   	in     (%dx),%al
c0100f39:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f3c:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f40:	0f b6 c0             	movzbl %al,%eax
c0100f43:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f46:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f49:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f51:	0f b7 c0             	movzwl %ax,%eax
c0100f54:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100f5a:	90                   	nop
c0100f5b:	c9                   	leave  
c0100f5c:	c3                   	ret    

c0100f5d <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f5d:	55                   	push   %ebp
c0100f5e:	89 e5                	mov    %esp,%ebp
c0100f60:	83 ec 38             	sub    $0x38,%esp
c0100f63:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f69:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f6d:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f71:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f75:	ee                   	out    %al,(%dx)
c0100f76:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f7c:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f80:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100f84:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100f87:	ee                   	out    %al,(%dx)
c0100f88:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100f8e:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100f92:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100f96:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100f9a:	ee                   	out    %al,(%dx)
c0100f9b:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100fa1:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fa5:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fa9:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100fac:	ee                   	out    %al,(%dx)
c0100fad:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100fb3:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fb7:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fbb:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fbf:	ee                   	out    %al,(%dx)
c0100fc0:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fc6:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fca:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100fce:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fd1:	ee                   	out    %al,(%dx)
c0100fd2:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100fd8:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100fdc:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100fe0:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100fe4:	ee                   	out    %al,(%dx)
c0100fe5:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100feb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100fee:	89 c2                	mov    %eax,%edx
c0100ff0:	ec                   	in     (%dx),%al
c0100ff1:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0100ff4:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0100ff8:	3c ff                	cmp    $0xff,%al
c0100ffa:	0f 95 c0             	setne  %al
c0100ffd:	0f b6 c0             	movzbl %al,%eax
c0101000:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c0101005:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010100b:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010100f:	89 c2                	mov    %eax,%edx
c0101011:	ec                   	in     (%dx),%al
c0101012:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101015:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c010101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010101e:	89 c2                	mov    %eax,%edx
c0101020:	ec                   	in     (%dx),%al
c0101021:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101024:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101029:	85 c0                	test   %eax,%eax
c010102b:	74 0c                	je     c0101039 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c010102d:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101034:	e8 d8 06 00 00       	call   c0101711 <pic_enable>
    }
}
c0101039:	90                   	nop
c010103a:	c9                   	leave  
c010103b:	c3                   	ret    

c010103c <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c010103c:	55                   	push   %ebp
c010103d:	89 e5                	mov    %esp,%ebp
c010103f:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101042:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101049:	eb 08                	jmp    c0101053 <lpt_putc_sub+0x17>
        delay();
c010104b:	e8 e4 fd ff ff       	call   c0100e34 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101050:	ff 45 fc             	incl   -0x4(%ebp)
c0101053:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101059:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010105c:	89 c2                	mov    %eax,%edx
c010105e:	ec                   	in     (%dx),%al
c010105f:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c0101062:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101066:	84 c0                	test   %al,%al
c0101068:	78 09                	js     c0101073 <lpt_putc_sub+0x37>
c010106a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101071:	7e d8                	jle    c010104b <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101073:	8b 45 08             	mov    0x8(%ebp),%eax
c0101076:	0f b6 c0             	movzbl %al,%eax
c0101079:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010107f:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101082:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0101086:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101089:	ee                   	out    %al,(%dx)
c010108a:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101090:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101094:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0101098:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010109c:	ee                   	out    %al,(%dx)
c010109d:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c01010a3:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01010a7:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01010ab:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01010af:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010b0:	90                   	nop
c01010b1:	c9                   	leave  
c01010b2:	c3                   	ret    

c01010b3 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010b3:	55                   	push   %ebp
c01010b4:	89 e5                	mov    %esp,%ebp
c01010b6:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010b9:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010bd:	74 0d                	je     c01010cc <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01010c2:	89 04 24             	mov    %eax,(%esp)
c01010c5:	e8 72 ff ff ff       	call   c010103c <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010ca:	eb 24                	jmp    c01010f0 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010cc:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010d3:	e8 64 ff ff ff       	call   c010103c <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010d8:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010df:	e8 58 ff ff ff       	call   c010103c <lpt_putc_sub>
        lpt_putc_sub('\b');
c01010e4:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010eb:	e8 4c ff ff ff       	call   c010103c <lpt_putc_sub>
    }
}
c01010f0:	90                   	nop
c01010f1:	c9                   	leave  
c01010f2:	c3                   	ret    

c01010f3 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c01010f3:	55                   	push   %ebp
c01010f4:	89 e5                	mov    %esp,%ebp
c01010f6:	53                   	push   %ebx
c01010f7:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c01010fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01010fd:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101102:	85 c0                	test   %eax,%eax
c0101104:	75 07                	jne    c010110d <cga_putc+0x1a>
        c |= 0x0700;
c0101106:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	0f b6 c0             	movzbl %al,%eax
c0101113:	83 f8 0a             	cmp    $0xa,%eax
c0101116:	74 54                	je     c010116c <cga_putc+0x79>
c0101118:	83 f8 0d             	cmp    $0xd,%eax
c010111b:	74 62                	je     c010117f <cga_putc+0x8c>
c010111d:	83 f8 08             	cmp    $0x8,%eax
c0101120:	0f 85 93 00 00 00    	jne    c01011b9 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101126:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010112d:	85 c0                	test   %eax,%eax
c010112f:	0f 84 ae 00 00 00    	je     c01011e3 <cga_putc+0xf0>
            crt_pos --;
c0101135:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010113c:	48                   	dec    %eax
c010113d:	0f b7 c0             	movzwl %ax,%eax
c0101140:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101146:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010114b:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c0101152:	01 d2                	add    %edx,%edx
c0101154:	01 c2                	add    %eax,%edx
c0101156:	8b 45 08             	mov    0x8(%ebp),%eax
c0101159:	98                   	cwtl   
c010115a:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010115f:	98                   	cwtl   
c0101160:	83 c8 20             	or     $0x20,%eax
c0101163:	98                   	cwtl   
c0101164:	0f b7 c0             	movzwl %ax,%eax
c0101167:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c010116a:	eb 77                	jmp    c01011e3 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c010116c:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101173:	83 c0 50             	add    $0x50,%eax
c0101176:	0f b7 c0             	movzwl %ax,%eax
c0101179:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010117f:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c0101186:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c010118d:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101192:	89 c8                	mov    %ecx,%eax
c0101194:	f7 e2                	mul    %edx
c0101196:	c1 ea 06             	shr    $0x6,%edx
c0101199:	89 d0                	mov    %edx,%eax
c010119b:	c1 e0 02             	shl    $0x2,%eax
c010119e:	01 d0                	add    %edx,%eax
c01011a0:	c1 e0 04             	shl    $0x4,%eax
c01011a3:	29 c1                	sub    %eax,%ecx
c01011a5:	89 c8                	mov    %ecx,%eax
c01011a7:	0f b7 c0             	movzwl %ax,%eax
c01011aa:	29 c3                	sub    %eax,%ebx
c01011ac:	89 d8                	mov    %ebx,%eax
c01011ae:	0f b7 c0             	movzwl %ax,%eax
c01011b1:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c01011b7:	eb 2b                	jmp    c01011e4 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011b9:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c01011bf:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011c6:	8d 50 01             	lea    0x1(%eax),%edx
c01011c9:	0f b7 d2             	movzwl %dx,%edx
c01011cc:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c01011d3:	01 c0                	add    %eax,%eax
c01011d5:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01011db:	0f b7 c0             	movzwl %ax,%eax
c01011de:	66 89 02             	mov    %ax,(%edx)
        break;
c01011e1:	eb 01                	jmp    c01011e4 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c01011e3:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c01011e4:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011eb:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c01011f0:	76 5d                	jbe    c010124f <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c01011f2:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c01011f7:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c01011fd:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101202:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101209:	00 
c010120a:	89 54 24 04          	mov    %edx,0x4(%esp)
c010120e:	89 04 24             	mov    %eax,(%esp)
c0101211:	e8 86 53 00 00       	call   c010659c <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101216:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010121d:	eb 14                	jmp    c0101233 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c010121f:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101224:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101227:	01 d2                	add    %edx,%edx
c0101229:	01 d0                	add    %edx,%eax
c010122b:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101230:	ff 45 f4             	incl   -0xc(%ebp)
c0101233:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c010123a:	7e e3                	jle    c010121f <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c010123c:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101243:	83 e8 50             	sub    $0x50,%eax
c0101246:	0f b7 c0             	movzwl %ax,%eax
c0101249:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010124f:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0101256:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010125a:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c010125e:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101262:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101266:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101267:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c010126e:	c1 e8 08             	shr    $0x8,%eax
c0101271:	0f b7 c0             	movzwl %ax,%eax
c0101274:	0f b6 c0             	movzbl %al,%eax
c0101277:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c010127e:	42                   	inc    %edx
c010127f:	0f b7 d2             	movzwl %dx,%edx
c0101282:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101286:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101289:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c010128d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101290:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101291:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0101298:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c010129c:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c01012a0:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c01012a4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012a8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012a9:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012b0:	0f b6 c0             	movzbl %al,%eax
c01012b3:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c01012ba:	42                   	inc    %edx
c01012bb:	0f b7 d2             	movzwl %dx,%edx
c01012be:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012c2:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012c5:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01012cc:	ee                   	out    %al,(%dx)
}
c01012cd:	90                   	nop
c01012ce:	83 c4 24             	add    $0x24,%esp
c01012d1:	5b                   	pop    %ebx
c01012d2:	5d                   	pop    %ebp
c01012d3:	c3                   	ret    

c01012d4 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012d4:	55                   	push   %ebp
c01012d5:	89 e5                	mov    %esp,%ebp
c01012d7:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012da:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012e1:	eb 08                	jmp    c01012eb <serial_putc_sub+0x17>
        delay();
c01012e3:	e8 4c fb ff ff       	call   c0100e34 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012e8:	ff 45 fc             	incl   -0x4(%ebp)
c01012eb:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01012f1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01012f4:	89 c2                	mov    %eax,%edx
c01012f6:	ec                   	in     (%dx),%al
c01012f7:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01012fa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c01012fe:	0f b6 c0             	movzbl %al,%eax
c0101301:	83 e0 20             	and    $0x20,%eax
c0101304:	85 c0                	test   %eax,%eax
c0101306:	75 09                	jne    c0101311 <serial_putc_sub+0x3d>
c0101308:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010130f:	7e d2                	jle    c01012e3 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101311:	8b 45 08             	mov    0x8(%ebp),%eax
c0101314:	0f b6 c0             	movzbl %al,%eax
c0101317:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c010131d:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101320:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101324:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101328:	ee                   	out    %al,(%dx)
}
c0101329:	90                   	nop
c010132a:	c9                   	leave  
c010132b:	c3                   	ret    

c010132c <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c010132c:	55                   	push   %ebp
c010132d:	89 e5                	mov    %esp,%ebp
c010132f:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101332:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101336:	74 0d                	je     c0101345 <serial_putc+0x19>
        serial_putc_sub(c);
c0101338:	8b 45 08             	mov    0x8(%ebp),%eax
c010133b:	89 04 24             	mov    %eax,(%esp)
c010133e:	e8 91 ff ff ff       	call   c01012d4 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101343:	eb 24                	jmp    c0101369 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101345:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010134c:	e8 83 ff ff ff       	call   c01012d4 <serial_putc_sub>
        serial_putc_sub(' ');
c0101351:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101358:	e8 77 ff ff ff       	call   c01012d4 <serial_putc_sub>
        serial_putc_sub('\b');
c010135d:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101364:	e8 6b ff ff ff       	call   c01012d4 <serial_putc_sub>
    }
}
c0101369:	90                   	nop
c010136a:	c9                   	leave  
c010136b:	c3                   	ret    

c010136c <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c010136c:	55                   	push   %ebp
c010136d:	89 e5                	mov    %esp,%ebp
c010136f:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101372:	eb 33                	jmp    c01013a7 <cons_intr+0x3b>
        if (c != 0) {
c0101374:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101378:	74 2d                	je     c01013a7 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c010137a:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c010137f:	8d 50 01             	lea    0x1(%eax),%edx
c0101382:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c0101388:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010138b:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101391:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101396:	3d 00 02 00 00       	cmp    $0x200,%eax
c010139b:	75 0a                	jne    c01013a7 <cons_intr+0x3b>
                cons.wpos = 0;
c010139d:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c01013a4:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01013aa:	ff d0                	call   *%eax
c01013ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013af:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013b3:	75 bf                	jne    c0101374 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013b5:	90                   	nop
c01013b6:	c9                   	leave  
c01013b7:	c3                   	ret    

c01013b8 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013b8:	55                   	push   %ebp
c01013b9:	89 e5                	mov    %esp,%ebp
c01013bb:	83 ec 10             	sub    $0x10,%esp
c01013be:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013c4:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01013c7:	89 c2                	mov    %eax,%edx
c01013c9:	ec                   	in     (%dx),%al
c01013ca:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013cd:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013d1:	0f b6 c0             	movzbl %al,%eax
c01013d4:	83 e0 01             	and    $0x1,%eax
c01013d7:	85 c0                	test   %eax,%eax
c01013d9:	75 07                	jne    c01013e2 <serial_proc_data+0x2a>
        return -1;
c01013db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013e0:	eb 2a                	jmp    c010140c <serial_proc_data+0x54>
c01013e2:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01013ec:	89 c2                	mov    %eax,%edx
c01013ee:	ec                   	in     (%dx),%al
c01013ef:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c01013f2:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c01013f6:	0f b6 c0             	movzbl %al,%eax
c01013f9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c01013fc:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101400:	75 07                	jne    c0101409 <serial_proc_data+0x51>
        c = '\b';
c0101402:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101409:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010140c:	c9                   	leave  
c010140d:	c3                   	ret    

c010140e <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010140e:	55                   	push   %ebp
c010140f:	89 e5                	mov    %esp,%ebp
c0101411:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101414:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101419:	85 c0                	test   %eax,%eax
c010141b:	74 0c                	je     c0101429 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010141d:	c7 04 24 b8 13 10 c0 	movl   $0xc01013b8,(%esp)
c0101424:	e8 43 ff ff ff       	call   c010136c <cons_intr>
    }
}
c0101429:	90                   	nop
c010142a:	c9                   	leave  
c010142b:	c3                   	ret    

c010142c <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010142c:	55                   	push   %ebp
c010142d:	89 e5                	mov    %esp,%ebp
c010142f:	83 ec 28             	sub    $0x28,%esp
c0101432:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101438:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010143b:	89 c2                	mov    %eax,%edx
c010143d:	ec                   	in     (%dx),%al
c010143e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101441:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101445:	0f b6 c0             	movzbl %al,%eax
c0101448:	83 e0 01             	and    $0x1,%eax
c010144b:	85 c0                	test   %eax,%eax
c010144d:	75 0a                	jne    c0101459 <kbd_proc_data+0x2d>
        return -1;
c010144f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101454:	e9 56 01 00 00       	jmp    c01015af <kbd_proc_data+0x183>
c0101459:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010145f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101462:	89 c2                	mov    %eax,%edx
c0101464:	ec                   	in     (%dx),%al
c0101465:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101468:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c010146c:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010146f:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101473:	75 17                	jne    c010148c <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101475:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010147a:	83 c8 40             	or     $0x40,%eax
c010147d:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c0101482:	b8 00 00 00 00       	mov    $0x0,%eax
c0101487:	e9 23 01 00 00       	jmp    c01015af <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c010148c:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101490:	84 c0                	test   %al,%al
c0101492:	79 45                	jns    c01014d9 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101494:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101499:	83 e0 40             	and    $0x40,%eax
c010149c:	85 c0                	test   %eax,%eax
c010149e:	75 08                	jne    c01014a8 <kbd_proc_data+0x7c>
c01014a0:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014a4:	24 7f                	and    $0x7f,%al
c01014a6:	eb 04                	jmp    c01014ac <kbd_proc_data+0x80>
c01014a8:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ac:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014af:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014b3:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c01014ba:	0c 40                	or     $0x40,%al
c01014bc:	0f b6 c0             	movzbl %al,%eax
c01014bf:	f7 d0                	not    %eax
c01014c1:	89 c2                	mov    %eax,%edx
c01014c3:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014c8:	21 d0                	and    %edx,%eax
c01014ca:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01014cf:	b8 00 00 00 00       	mov    $0x0,%eax
c01014d4:	e9 d6 00 00 00       	jmp    c01015af <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c01014d9:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014de:	83 e0 40             	and    $0x40,%eax
c01014e1:	85 c0                	test   %eax,%eax
c01014e3:	74 11                	je     c01014f6 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c01014e5:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c01014e9:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014ee:	83 e0 bf             	and    $0xffffffbf,%eax
c01014f1:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c01014f6:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014fa:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101501:	0f b6 d0             	movzbl %al,%edx
c0101504:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101509:	09 d0                	or     %edx,%eax
c010150b:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c0101510:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101514:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c010151b:	0f b6 d0             	movzbl %al,%edx
c010151e:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101523:	31 d0                	xor    %edx,%eax
c0101525:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c010152a:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010152f:	83 e0 03             	and    $0x3,%eax
c0101532:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c0101539:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010153d:	01 d0                	add    %edx,%eax
c010153f:	0f b6 00             	movzbl (%eax),%eax
c0101542:	0f b6 c0             	movzbl %al,%eax
c0101545:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101548:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010154d:	83 e0 08             	and    $0x8,%eax
c0101550:	85 c0                	test   %eax,%eax
c0101552:	74 22                	je     c0101576 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101554:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101558:	7e 0c                	jle    c0101566 <kbd_proc_data+0x13a>
c010155a:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010155e:	7f 06                	jg     c0101566 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101560:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101564:	eb 10                	jmp    c0101576 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101566:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c010156a:	7e 0a                	jle    c0101576 <kbd_proc_data+0x14a>
c010156c:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101570:	7f 04                	jg     c0101576 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101572:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101576:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010157b:	f7 d0                	not    %eax
c010157d:	83 e0 06             	and    $0x6,%eax
c0101580:	85 c0                	test   %eax,%eax
c0101582:	75 28                	jne    c01015ac <kbd_proc_data+0x180>
c0101584:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c010158b:	75 1f                	jne    c01015ac <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c010158d:	c7 04 24 8d 70 10 c0 	movl   $0xc010708d,(%esp)
c0101594:	e8 fe ec ff ff       	call   c0100297 <cprintf>
c0101599:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c010159f:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015a3:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015a7:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015ab:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015af:	c9                   	leave  
c01015b0:	c3                   	ret    

c01015b1 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015b1:	55                   	push   %ebp
c01015b2:	89 e5                	mov    %esp,%ebp
c01015b4:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015b7:	c7 04 24 2c 14 10 c0 	movl   $0xc010142c,(%esp)
c01015be:	e8 a9 fd ff ff       	call   c010136c <cons_intr>
}
c01015c3:	90                   	nop
c01015c4:	c9                   	leave  
c01015c5:	c3                   	ret    

c01015c6 <kbd_init>:

static void
kbd_init(void) {
c01015c6:	55                   	push   %ebp
c01015c7:	89 e5                	mov    %esp,%ebp
c01015c9:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015cc:	e8 e0 ff ff ff       	call   c01015b1 <kbd_intr>
    pic_enable(IRQ_KBD);
c01015d1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015d8:	e8 34 01 00 00       	call   c0101711 <pic_enable>
}
c01015dd:	90                   	nop
c01015de:	c9                   	leave  
c01015df:	c3                   	ret    

c01015e0 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015e0:	55                   	push   %ebp
c01015e1:	89 e5                	mov    %esp,%ebp
c01015e3:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c01015e6:	e8 90 f8 ff ff       	call   c0100e7b <cga_init>
    serial_init();
c01015eb:	e8 6d f9 ff ff       	call   c0100f5d <serial_init>
    kbd_init();
c01015f0:	e8 d1 ff ff ff       	call   c01015c6 <kbd_init>
    if (!serial_exists) {
c01015f5:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c01015fa:	85 c0                	test   %eax,%eax
c01015fc:	75 0c                	jne    c010160a <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c01015fe:	c7 04 24 99 70 10 c0 	movl   $0xc0107099,(%esp)
c0101605:	e8 8d ec ff ff       	call   c0100297 <cprintf>
    }
}
c010160a:	90                   	nop
c010160b:	c9                   	leave  
c010160c:	c3                   	ret    

c010160d <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010160d:	55                   	push   %ebp
c010160e:	89 e5                	mov    %esp,%ebp
c0101610:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101613:	e8 de f7 ff ff       	call   c0100df6 <__intr_save>
c0101618:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c010161b:	8b 45 08             	mov    0x8(%ebp),%eax
c010161e:	89 04 24             	mov    %eax,(%esp)
c0101621:	e8 8d fa ff ff       	call   c01010b3 <lpt_putc>
        cga_putc(c);
c0101626:	8b 45 08             	mov    0x8(%ebp),%eax
c0101629:	89 04 24             	mov    %eax,(%esp)
c010162c:	e8 c2 fa ff ff       	call   c01010f3 <cga_putc>
        serial_putc(c);
c0101631:	8b 45 08             	mov    0x8(%ebp),%eax
c0101634:	89 04 24             	mov    %eax,(%esp)
c0101637:	e8 f0 fc ff ff       	call   c010132c <serial_putc>
    }
    local_intr_restore(intr_flag);
c010163c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010163f:	89 04 24             	mov    %eax,(%esp)
c0101642:	e8 d9 f7 ff ff       	call   c0100e20 <__intr_restore>
}
c0101647:	90                   	nop
c0101648:	c9                   	leave  
c0101649:	c3                   	ret    

c010164a <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c010164a:	55                   	push   %ebp
c010164b:	89 e5                	mov    %esp,%ebp
c010164d:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101657:	e8 9a f7 ff ff       	call   c0100df6 <__intr_save>
c010165c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010165f:	e8 aa fd ff ff       	call   c010140e <serial_intr>
        kbd_intr();
c0101664:	e8 48 ff ff ff       	call   c01015b1 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101669:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c010166f:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101674:	39 c2                	cmp    %eax,%edx
c0101676:	74 31                	je     c01016a9 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101678:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c010167d:	8d 50 01             	lea    0x1(%eax),%edx
c0101680:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c0101686:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c010168d:	0f b6 c0             	movzbl %al,%eax
c0101690:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101693:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101698:	3d 00 02 00 00       	cmp    $0x200,%eax
c010169d:	75 0a                	jne    c01016a9 <cons_getc+0x5f>
                cons.rpos = 0;
c010169f:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c01016a6:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016ac:	89 04 24             	mov    %eax,(%esp)
c01016af:	e8 6c f7 ff ff       	call   c0100e20 <__intr_restore>
    return c;
c01016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016b7:	c9                   	leave  
c01016b8:	c3                   	ret    

c01016b9 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016b9:	55                   	push   %ebp
c01016ba:	89 e5                	mov    %esp,%ebp
c01016bc:	83 ec 14             	sub    $0x14,%esp
c01016bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01016c2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016c9:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c01016cf:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c01016d4:	85 c0                	test   %eax,%eax
c01016d6:	74 36                	je     c010170e <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c01016d8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016db:	0f b6 c0             	movzbl %al,%eax
c01016de:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c01016e4:	88 45 fa             	mov    %al,-0x6(%ebp)
c01016e7:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c01016eb:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c01016ef:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c01016f0:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c01016f4:	c1 e8 08             	shr    $0x8,%eax
c01016f7:	0f b7 c0             	movzwl %ax,%eax
c01016fa:	0f b6 c0             	movzbl %al,%eax
c01016fd:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101703:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101706:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c010170a:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010170d:	ee                   	out    %al,(%dx)
    }
}
c010170e:	90                   	nop
c010170f:	c9                   	leave  
c0101710:	c3                   	ret    

c0101711 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101711:	55                   	push   %ebp
c0101712:	89 e5                	mov    %esp,%ebp
c0101714:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101717:	8b 45 08             	mov    0x8(%ebp),%eax
c010171a:	ba 01 00 00 00       	mov    $0x1,%edx
c010171f:	88 c1                	mov    %al,%cl
c0101721:	d3 e2                	shl    %cl,%edx
c0101723:	89 d0                	mov    %edx,%eax
c0101725:	98                   	cwtl   
c0101726:	f7 d0                	not    %eax
c0101728:	0f bf d0             	movswl %ax,%edx
c010172b:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101732:	98                   	cwtl   
c0101733:	21 d0                	and    %edx,%eax
c0101735:	98                   	cwtl   
c0101736:	0f b7 c0             	movzwl %ax,%eax
c0101739:	89 04 24             	mov    %eax,(%esp)
c010173c:	e8 78 ff ff ff       	call   c01016b9 <pic_setmask>
}
c0101741:	90                   	nop
c0101742:	c9                   	leave  
c0101743:	c3                   	ret    

c0101744 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101744:	55                   	push   %ebp
c0101745:	89 e5                	mov    %esp,%ebp
c0101747:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c010174a:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c0101751:	00 00 00 
c0101754:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c010175a:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010175e:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101762:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101766:	ee                   	out    %al,(%dx)
c0101767:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010176d:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101771:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101775:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101778:	ee                   	out    %al,(%dx)
c0101779:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c010177f:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101783:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101787:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010178b:	ee                   	out    %al,(%dx)
c010178c:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0101792:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0101796:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010179a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010179d:	ee                   	out    %al,(%dx)
c010179e:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c01017a4:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017a8:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017ac:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017b0:	ee                   	out    %al,(%dx)
c01017b1:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017b7:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017bb:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017c2:	ee                   	out    %al,(%dx)
c01017c3:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017c9:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017cd:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017d1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017d5:	ee                   	out    %al,(%dx)
c01017d6:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017dc:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017e0:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c01017e4:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01017e7:	ee                   	out    %al,(%dx)
c01017e8:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01017ee:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c01017f2:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c01017f6:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01017fa:	ee                   	out    %al,(%dx)
c01017fb:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0101801:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101805:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101809:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0101813:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0101817:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c010181b:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010181f:	ee                   	out    %al,(%dx)
c0101820:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0101826:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c010182a:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010182e:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0101831:	ee                   	out    %al,(%dx)
c0101832:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101838:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c010183c:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c0101840:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101844:	ee                   	out    %al,(%dx)
c0101845:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c010184b:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c010184f:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c0101853:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101856:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101857:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010185e:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101863:	74 0f                	je     c0101874 <pic_init+0x130>
        pic_setmask(irq_mask);
c0101865:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c010186c:	89 04 24             	mov    %eax,(%esp)
c010186f:	e8 45 fe ff ff       	call   c01016b9 <pic_setmask>
    }
}
c0101874:	90                   	nop
c0101875:	c9                   	leave  
c0101876:	c3                   	ret    

c0101877 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101877:	55                   	push   %ebp
c0101878:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c010187a:	fb                   	sti    
    sti();
}
c010187b:	90                   	nop
c010187c:	5d                   	pop    %ebp
c010187d:	c3                   	ret    

c010187e <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010187e:	55                   	push   %ebp
c010187f:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c0101881:	fa                   	cli    
    cli();
}
c0101882:	90                   	nop
c0101883:	5d                   	pop    %ebp
c0101884:	c3                   	ret    

c0101885 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c0101885:	55                   	push   %ebp
c0101886:	89 e5                	mov    %esp,%ebp
c0101888:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010188b:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101892:	00 
c0101893:	c7 04 24 c0 70 10 c0 	movl   $0xc01070c0,(%esp)
c010189a:	e8 f8 e9 ff ff       	call   c0100297 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010189f:	c7 04 24 ca 70 10 c0 	movl   $0xc01070ca,(%esp)
c01018a6:	e8 ec e9 ff ff       	call   c0100297 <cprintf>
    panic("EOT: kernel seems ok.");
c01018ab:	c7 44 24 08 d8 70 10 	movl   $0xc01070d8,0x8(%esp)
c01018b2:	c0 
c01018b3:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c01018ba:	00 
c01018bb:	c7 04 24 ee 70 10 c0 	movl   $0xc01070ee,(%esp)
c01018c2:	e8 27 eb ff ff       	call   c01003ee <__panic>

c01018c7 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018c7:	55                   	push   %ebp
c01018c8:	89 e5                	mov    %esp,%ebp
c01018ca:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01018cd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018d4:	e9 c4 00 00 00       	jmp    c010199d <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c01018d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018dc:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c01018e3:	0f b7 d0             	movzwl %ax,%edx
c01018e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e9:	66 89 14 c5 80 c6 11 	mov    %dx,-0x3fee3980(,%eax,8)
c01018f0:	c0 
c01018f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f4:	66 c7 04 c5 82 c6 11 	movw   $0x8,-0x3fee397e(,%eax,8)
c01018fb:	c0 08 00 
c01018fe:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101901:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c0101908:	c0 
c0101909:	80 e2 e0             	and    $0xe0,%dl
c010190c:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c0101913:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101916:	0f b6 14 c5 84 c6 11 	movzbl -0x3fee397c(,%eax,8),%edx
c010191d:	c0 
c010191e:	80 e2 1f             	and    $0x1f,%dl
c0101921:	88 14 c5 84 c6 11 c0 	mov    %dl,-0x3fee397c(,%eax,8)
c0101928:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010192b:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101932:	c0 
c0101933:	80 e2 f0             	and    $0xf0,%dl
c0101936:	80 ca 0e             	or     $0xe,%dl
c0101939:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101940:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101943:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c010194a:	c0 
c010194b:	80 e2 ef             	and    $0xef,%dl
c010194e:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c0101955:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101958:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c010195f:	c0 
c0101960:	80 e2 9f             	and    $0x9f,%dl
c0101963:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c010196a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010196d:	0f b6 14 c5 85 c6 11 	movzbl -0x3fee397b(,%eax,8),%edx
c0101974:	c0 
c0101975:	80 ca 80             	or     $0x80,%dl
c0101978:	88 14 c5 85 c6 11 c0 	mov    %dl,-0x3fee397b(,%eax,8)
c010197f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101982:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101989:	c1 e8 10             	shr    $0x10,%eax
c010198c:	0f b7 d0             	movzwl %ax,%edx
c010198f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101992:	66 89 14 c5 86 c6 11 	mov    %dx,-0x3fee397a(,%eax,8)
c0101999:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010199a:	ff 45 fc             	incl   -0x4(%ebp)
c010199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a0:	3d ff 00 00 00       	cmp    $0xff,%eax
c01019a5:	0f 86 2e ff ff ff    	jbe    c01018d9 <idt_init+0x12>
c01019ab:	c7 45 f8 60 95 11 c0 	movl   $0xc0119560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01019b2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01019b5:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c01019b8:	90                   	nop
c01019b9:	c9                   	leave  
c01019ba:	c3                   	ret    

c01019bb <trapname>:

static const char *
trapname(int trapno) {
c01019bb:	55                   	push   %ebp
c01019bc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c01019be:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c1:	83 f8 13             	cmp    $0x13,%eax
c01019c4:	77 0c                	ja     c01019d2 <trapname+0x17>
        return excnames[trapno];
c01019c6:	8b 45 08             	mov    0x8(%ebp),%eax
c01019c9:	8b 04 85 40 74 10 c0 	mov    -0x3fef8bc0(,%eax,4),%eax
c01019d0:	eb 18                	jmp    c01019ea <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c01019d2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c01019d6:	7e 0d                	jle    c01019e5 <trapname+0x2a>
c01019d8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c01019dc:	7f 07                	jg     c01019e5 <trapname+0x2a>
        return "Hardware Interrupt";
c01019de:	b8 ff 70 10 c0       	mov    $0xc01070ff,%eax
c01019e3:	eb 05                	jmp    c01019ea <trapname+0x2f>
    }
    return "(unknown trap)";
c01019e5:	b8 12 71 10 c0       	mov    $0xc0107112,%eax
}
c01019ea:	5d                   	pop    %ebp
c01019eb:	c3                   	ret    

c01019ec <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c01019ec:	55                   	push   %ebp
c01019ed:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c01019ef:	8b 45 08             	mov    0x8(%ebp),%eax
c01019f2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01019f6:	83 f8 08             	cmp    $0x8,%eax
c01019f9:	0f 94 c0             	sete   %al
c01019fc:	0f b6 c0             	movzbl %al,%eax
}
c01019ff:	5d                   	pop    %ebp
c0101a00:	c3                   	ret    

c0101a01 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101a01:	55                   	push   %ebp
c0101a02:	89 e5                	mov    %esp,%ebp
c0101a04:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101a07:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a0e:	c7 04 24 53 71 10 c0 	movl   $0xc0107153,(%esp)
c0101a15:	e8 7d e8 ff ff       	call   c0100297 <cprintf>
    print_regs(&tf->tf_regs);
c0101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a1d:	89 04 24             	mov    %eax,(%esp)
c0101a20:	e8 91 01 00 00       	call   c0101bb6 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101a25:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a28:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101a2c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a30:	c7 04 24 64 71 10 c0 	movl   $0xc0107164,(%esp)
c0101a37:	e8 5b e8 ff ff       	call   c0100297 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101a3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a3f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101a43:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a47:	c7 04 24 77 71 10 c0 	movl   $0xc0107177,(%esp)
c0101a4e:	e8 44 e8 ff ff       	call   c0100297 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101a53:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a56:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101a5a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a5e:	c7 04 24 8a 71 10 c0 	movl   $0xc010718a,(%esp)
c0101a65:	e8 2d e8 ff ff       	call   c0100297 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101a6a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a6d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101a71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a75:	c7 04 24 9d 71 10 c0 	movl   $0xc010719d,(%esp)
c0101a7c:	e8 16 e8 ff ff       	call   c0100297 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101a81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a84:	8b 40 30             	mov    0x30(%eax),%eax
c0101a87:	89 04 24             	mov    %eax,(%esp)
c0101a8a:	e8 2c ff ff ff       	call   c01019bb <trapname>
c0101a8f:	89 c2                	mov    %eax,%edx
c0101a91:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a94:	8b 40 30             	mov    0x30(%eax),%eax
c0101a97:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101a9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101a9f:	c7 04 24 b0 71 10 c0 	movl   $0xc01071b0,(%esp)
c0101aa6:	e8 ec e7 ff ff       	call   c0100297 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101aab:	8b 45 08             	mov    0x8(%ebp),%eax
c0101aae:	8b 40 34             	mov    0x34(%eax),%eax
c0101ab1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ab5:	c7 04 24 c2 71 10 c0 	movl   $0xc01071c2,(%esp)
c0101abc:	e8 d6 e7 ff ff       	call   c0100297 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101ac1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ac4:	8b 40 38             	mov    0x38(%eax),%eax
c0101ac7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101acb:	c7 04 24 d1 71 10 c0 	movl   $0xc01071d1,(%esp)
c0101ad2:	e8 c0 e7 ff ff       	call   c0100297 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101ad7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ada:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101ade:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ae2:	c7 04 24 e0 71 10 c0 	movl   $0xc01071e0,(%esp)
c0101ae9:	e8 a9 e7 ff ff       	call   c0100297 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101aee:	8b 45 08             	mov    0x8(%ebp),%eax
c0101af1:	8b 40 40             	mov    0x40(%eax),%eax
c0101af4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101af8:	c7 04 24 f3 71 10 c0 	movl   $0xc01071f3,(%esp)
c0101aff:	e8 93 e7 ff ff       	call   c0100297 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b04:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101b0b:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101b12:	eb 3d                	jmp    c0101b51 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b17:	8b 50 40             	mov    0x40(%eax),%edx
c0101b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101b1d:	21 d0                	and    %edx,%eax
c0101b1f:	85 c0                	test   %eax,%eax
c0101b21:	74 28                	je     c0101b4b <print_trapframe+0x14a>
c0101b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b26:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101b2d:	85 c0                	test   %eax,%eax
c0101b2f:	74 1a                	je     c0101b4b <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101b31:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b34:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b3f:	c7 04 24 02 72 10 c0 	movl   $0xc0107202,(%esp)
c0101b46:	e8 4c e7 ff ff       	call   c0100297 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101b4b:	ff 45 f4             	incl   -0xc(%ebp)
c0101b4e:	d1 65 f0             	shll   -0x10(%ebp)
c0101b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101b54:	83 f8 17             	cmp    $0x17,%eax
c0101b57:	76 bb                	jbe    c0101b14 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101b59:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5c:	8b 40 40             	mov    0x40(%eax),%eax
c0101b5f:	25 00 30 00 00       	and    $0x3000,%eax
c0101b64:	c1 e8 0c             	shr    $0xc,%eax
c0101b67:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b6b:	c7 04 24 06 72 10 c0 	movl   $0xc0107206,(%esp)
c0101b72:	e8 20 e7 ff ff       	call   c0100297 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101b77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b7a:	89 04 24             	mov    %eax,(%esp)
c0101b7d:	e8 6a fe ff ff       	call   c01019ec <trap_in_kernel>
c0101b82:	85 c0                	test   %eax,%eax
c0101b84:	75 2d                	jne    c0101bb3 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b89:	8b 40 44             	mov    0x44(%eax),%eax
c0101b8c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b90:	c7 04 24 0f 72 10 c0 	movl   $0xc010720f,(%esp)
c0101b97:	e8 fb e6 ff ff       	call   c0100297 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101b9c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b9f:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba7:	c7 04 24 1e 72 10 c0 	movl   $0xc010721e,(%esp)
c0101bae:	e8 e4 e6 ff ff       	call   c0100297 <cprintf>
    }
}
c0101bb3:	90                   	nop
c0101bb4:	c9                   	leave  
c0101bb5:	c3                   	ret    

c0101bb6 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101bb6:	55                   	push   %ebp
c0101bb7:	89 e5                	mov    %esp,%ebp
c0101bb9:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101bbc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bbf:	8b 00                	mov    (%eax),%eax
c0101bc1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bc5:	c7 04 24 31 72 10 c0 	movl   $0xc0107231,(%esp)
c0101bcc:	e8 c6 e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101bd1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd4:	8b 40 04             	mov    0x4(%eax),%eax
c0101bd7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bdb:	c7 04 24 40 72 10 c0 	movl   $0xc0107240,(%esp)
c0101be2:	e8 b0 e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101be7:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bea:	8b 40 08             	mov    0x8(%eax),%eax
c0101bed:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf1:	c7 04 24 4f 72 10 c0 	movl   $0xc010724f,(%esp)
c0101bf8:	e8 9a e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101bfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c00:	8b 40 0c             	mov    0xc(%eax),%eax
c0101c03:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c07:	c7 04 24 5e 72 10 c0 	movl   $0xc010725e,(%esp)
c0101c0e:	e8 84 e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101c13:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c16:	8b 40 10             	mov    0x10(%eax),%eax
c0101c19:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c1d:	c7 04 24 6d 72 10 c0 	movl   $0xc010726d,(%esp)
c0101c24:	e8 6e e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101c29:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2c:	8b 40 14             	mov    0x14(%eax),%eax
c0101c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c33:	c7 04 24 7c 72 10 c0 	movl   $0xc010727c,(%esp)
c0101c3a:	e8 58 e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c42:	8b 40 18             	mov    0x18(%eax),%eax
c0101c45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c49:	c7 04 24 8b 72 10 c0 	movl   $0xc010728b,(%esp)
c0101c50:	e8 42 e6 ff ff       	call   c0100297 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101c55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c58:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101c5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5f:	c7 04 24 9a 72 10 c0 	movl   $0xc010729a,(%esp)
c0101c66:	e8 2c e6 ff ff       	call   c0100297 <cprintf>
}
c0101c6b:	90                   	nop
c0101c6c:	c9                   	leave  
c0101c6d:	c3                   	ret    

c0101c6e <trap_dispatch>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101c6e:	55                   	push   %ebp
c0101c6f:	89 e5                	mov    %esp,%ebp
c0101c71:	83 ec 28             	sub    $0x28,%esp
    char c;

    switch (tf->tf_trapno) {
c0101c74:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c77:	8b 40 30             	mov    0x30(%eax),%eax
c0101c7a:	83 f8 2f             	cmp    $0x2f,%eax
c0101c7d:	77 21                	ja     c0101ca0 <trap_dispatch+0x32>
c0101c7f:	83 f8 2e             	cmp    $0x2e,%eax
c0101c82:	0f 83 0c 01 00 00    	jae    c0101d94 <trap_dispatch+0x126>
c0101c88:	83 f8 21             	cmp    $0x21,%eax
c0101c8b:	0f 84 8c 00 00 00    	je     c0101d1d <trap_dispatch+0xaf>
c0101c91:	83 f8 24             	cmp    $0x24,%eax
c0101c94:	74 61                	je     c0101cf7 <trap_dispatch+0x89>
c0101c96:	83 f8 20             	cmp    $0x20,%eax
c0101c99:	74 16                	je     c0101cb1 <trap_dispatch+0x43>
c0101c9b:	e9 bf 00 00 00       	jmp    c0101d5f <trap_dispatch+0xf1>
c0101ca0:	83 e8 78             	sub    $0x78,%eax
c0101ca3:	83 f8 01             	cmp    $0x1,%eax
c0101ca6:	0f 87 b3 00 00 00    	ja     c0101d5f <trap_dispatch+0xf1>
c0101cac:	e9 92 00 00 00       	jmp    c0101d43 <trap_dispatch+0xd5>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101cb1:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0101cb6:	40                   	inc    %eax
c0101cb7:	a3 0c cf 11 c0       	mov    %eax,0xc011cf0c
        if (ticks % TICK_NUM == 0) {
c0101cbc:	8b 0d 0c cf 11 c0    	mov    0xc011cf0c,%ecx
c0101cc2:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101cc7:	89 c8                	mov    %ecx,%eax
c0101cc9:	f7 e2                	mul    %edx
c0101ccb:	c1 ea 05             	shr    $0x5,%edx
c0101cce:	89 d0                	mov    %edx,%eax
c0101cd0:	c1 e0 02             	shl    $0x2,%eax
c0101cd3:	01 d0                	add    %edx,%eax
c0101cd5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101cdc:	01 d0                	add    %edx,%eax
c0101cde:	c1 e0 02             	shl    $0x2,%eax
c0101ce1:	29 c1                	sub    %eax,%ecx
c0101ce3:	89 ca                	mov    %ecx,%edx
c0101ce5:	85 d2                	test   %edx,%edx
c0101ce7:	0f 85 aa 00 00 00    	jne    c0101d97 <trap_dispatch+0x129>
            print_ticks();
c0101ced:	e8 93 fb ff ff       	call   c0101885 <print_ticks>
        }
        break;
c0101cf2:	e9 a0 00 00 00       	jmp    c0101d97 <trap_dispatch+0x129>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101cf7:	e8 4e f9 ff ff       	call   c010164a <cons_getc>
c0101cfc:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101cff:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d03:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d07:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0f:	c7 04 24 a9 72 10 c0 	movl   $0xc01072a9,(%esp)
c0101d16:	e8 7c e5 ff ff       	call   c0100297 <cprintf>
        break;
c0101d1b:	eb 7b                	jmp    c0101d98 <trap_dispatch+0x12a>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101d1d:	e8 28 f9 ff ff       	call   c010164a <cons_getc>
c0101d22:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101d25:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101d29:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101d2d:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101d31:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d35:	c7 04 24 bb 72 10 c0 	movl   $0xc01072bb,(%esp)
c0101d3c:	e8 56 e5 ff ff       	call   c0100297 <cprintf>
        break;
c0101d41:	eb 55                	jmp    c0101d98 <trap_dispatch+0x12a>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c0101d43:	c7 44 24 08 ca 72 10 	movl   $0xc01072ca,0x8(%esp)
c0101d4a:	c0 
c0101d4b:	c7 44 24 04 ac 00 00 	movl   $0xac,0x4(%esp)
c0101d52:	00 
c0101d53:	c7 04 24 ee 70 10 c0 	movl   $0xc01070ee,(%esp)
c0101d5a:	e8 8f e6 ff ff       	call   c01003ee <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101d5f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d62:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101d66:	83 e0 03             	and    $0x3,%eax
c0101d69:	85 c0                	test   %eax,%eax
c0101d6b:	75 2b                	jne    c0101d98 <trap_dispatch+0x12a>
            print_trapframe(tf);
c0101d6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d70:	89 04 24             	mov    %eax,(%esp)
c0101d73:	e8 89 fc ff ff       	call   c0101a01 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101d78:	c7 44 24 08 da 72 10 	movl   $0xc01072da,0x8(%esp)
c0101d7f:	c0 
c0101d80:	c7 44 24 04 b6 00 00 	movl   $0xb6,0x4(%esp)
c0101d87:	00 
c0101d88:	c7 04 24 ee 70 10 c0 	movl   $0xc01070ee,(%esp)
c0101d8f:	e8 5a e6 ff ff       	call   c01003ee <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0101d94:	90                   	nop
c0101d95:	eb 01                	jmp    c0101d98 <trap_dispatch+0x12a>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c0101d97:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c0101d98:	90                   	nop
c0101d99:	c9                   	leave  
c0101d9a:	c3                   	ret    

c0101d9b <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101d9b:	55                   	push   %ebp
c0101d9c:	89 e5                	mov    %esp,%ebp
c0101d9e:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101da1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101da4:	89 04 24             	mov    %eax,(%esp)
c0101da7:	e8 c2 fe ff ff       	call   c0101c6e <trap_dispatch>
}
c0101dac:	90                   	nop
c0101dad:	c9                   	leave  
c0101dae:	c3                   	ret    

c0101daf <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0101daf:	6a 00                	push   $0x0
  pushl $0
c0101db1:	6a 00                	push   $0x0
  jmp __alltraps
c0101db3:	e9 69 0a 00 00       	jmp    c0102821 <__alltraps>

c0101db8 <vector1>:
.globl vector1
vector1:
  pushl $0
c0101db8:	6a 00                	push   $0x0
  pushl $1
c0101dba:	6a 01                	push   $0x1
  jmp __alltraps
c0101dbc:	e9 60 0a 00 00       	jmp    c0102821 <__alltraps>

c0101dc1 <vector2>:
.globl vector2
vector2:
  pushl $0
c0101dc1:	6a 00                	push   $0x0
  pushl $2
c0101dc3:	6a 02                	push   $0x2
  jmp __alltraps
c0101dc5:	e9 57 0a 00 00       	jmp    c0102821 <__alltraps>

c0101dca <vector3>:
.globl vector3
vector3:
  pushl $0
c0101dca:	6a 00                	push   $0x0
  pushl $3
c0101dcc:	6a 03                	push   $0x3
  jmp __alltraps
c0101dce:	e9 4e 0a 00 00       	jmp    c0102821 <__alltraps>

c0101dd3 <vector4>:
.globl vector4
vector4:
  pushl $0
c0101dd3:	6a 00                	push   $0x0
  pushl $4
c0101dd5:	6a 04                	push   $0x4
  jmp __alltraps
c0101dd7:	e9 45 0a 00 00       	jmp    c0102821 <__alltraps>

c0101ddc <vector5>:
.globl vector5
vector5:
  pushl $0
c0101ddc:	6a 00                	push   $0x0
  pushl $5
c0101dde:	6a 05                	push   $0x5
  jmp __alltraps
c0101de0:	e9 3c 0a 00 00       	jmp    c0102821 <__alltraps>

c0101de5 <vector6>:
.globl vector6
vector6:
  pushl $0
c0101de5:	6a 00                	push   $0x0
  pushl $6
c0101de7:	6a 06                	push   $0x6
  jmp __alltraps
c0101de9:	e9 33 0a 00 00       	jmp    c0102821 <__alltraps>

c0101dee <vector7>:
.globl vector7
vector7:
  pushl $0
c0101dee:	6a 00                	push   $0x0
  pushl $7
c0101df0:	6a 07                	push   $0x7
  jmp __alltraps
c0101df2:	e9 2a 0a 00 00       	jmp    c0102821 <__alltraps>

c0101df7 <vector8>:
.globl vector8
vector8:
  pushl $8
c0101df7:	6a 08                	push   $0x8
  jmp __alltraps
c0101df9:	e9 23 0a 00 00       	jmp    c0102821 <__alltraps>

c0101dfe <vector9>:
.globl vector9
vector9:
  pushl $0
c0101dfe:	6a 00                	push   $0x0
  pushl $9
c0101e00:	6a 09                	push   $0x9
  jmp __alltraps
c0101e02:	e9 1a 0a 00 00       	jmp    c0102821 <__alltraps>

c0101e07 <vector10>:
.globl vector10
vector10:
  pushl $10
c0101e07:	6a 0a                	push   $0xa
  jmp __alltraps
c0101e09:	e9 13 0a 00 00       	jmp    c0102821 <__alltraps>

c0101e0e <vector11>:
.globl vector11
vector11:
  pushl $11
c0101e0e:	6a 0b                	push   $0xb
  jmp __alltraps
c0101e10:	e9 0c 0a 00 00       	jmp    c0102821 <__alltraps>

c0101e15 <vector12>:
.globl vector12
vector12:
  pushl $12
c0101e15:	6a 0c                	push   $0xc
  jmp __alltraps
c0101e17:	e9 05 0a 00 00       	jmp    c0102821 <__alltraps>

c0101e1c <vector13>:
.globl vector13
vector13:
  pushl $13
c0101e1c:	6a 0d                	push   $0xd
  jmp __alltraps
c0101e1e:	e9 fe 09 00 00       	jmp    c0102821 <__alltraps>

c0101e23 <vector14>:
.globl vector14
vector14:
  pushl $14
c0101e23:	6a 0e                	push   $0xe
  jmp __alltraps
c0101e25:	e9 f7 09 00 00       	jmp    c0102821 <__alltraps>

c0101e2a <vector15>:
.globl vector15
vector15:
  pushl $0
c0101e2a:	6a 00                	push   $0x0
  pushl $15
c0101e2c:	6a 0f                	push   $0xf
  jmp __alltraps
c0101e2e:	e9 ee 09 00 00       	jmp    c0102821 <__alltraps>

c0101e33 <vector16>:
.globl vector16
vector16:
  pushl $0
c0101e33:	6a 00                	push   $0x0
  pushl $16
c0101e35:	6a 10                	push   $0x10
  jmp __alltraps
c0101e37:	e9 e5 09 00 00       	jmp    c0102821 <__alltraps>

c0101e3c <vector17>:
.globl vector17
vector17:
  pushl $17
c0101e3c:	6a 11                	push   $0x11
  jmp __alltraps
c0101e3e:	e9 de 09 00 00       	jmp    c0102821 <__alltraps>

c0101e43 <vector18>:
.globl vector18
vector18:
  pushl $0
c0101e43:	6a 00                	push   $0x0
  pushl $18
c0101e45:	6a 12                	push   $0x12
  jmp __alltraps
c0101e47:	e9 d5 09 00 00       	jmp    c0102821 <__alltraps>

c0101e4c <vector19>:
.globl vector19
vector19:
  pushl $0
c0101e4c:	6a 00                	push   $0x0
  pushl $19
c0101e4e:	6a 13                	push   $0x13
  jmp __alltraps
c0101e50:	e9 cc 09 00 00       	jmp    c0102821 <__alltraps>

c0101e55 <vector20>:
.globl vector20
vector20:
  pushl $0
c0101e55:	6a 00                	push   $0x0
  pushl $20
c0101e57:	6a 14                	push   $0x14
  jmp __alltraps
c0101e59:	e9 c3 09 00 00       	jmp    c0102821 <__alltraps>

c0101e5e <vector21>:
.globl vector21
vector21:
  pushl $0
c0101e5e:	6a 00                	push   $0x0
  pushl $21
c0101e60:	6a 15                	push   $0x15
  jmp __alltraps
c0101e62:	e9 ba 09 00 00       	jmp    c0102821 <__alltraps>

c0101e67 <vector22>:
.globl vector22
vector22:
  pushl $0
c0101e67:	6a 00                	push   $0x0
  pushl $22
c0101e69:	6a 16                	push   $0x16
  jmp __alltraps
c0101e6b:	e9 b1 09 00 00       	jmp    c0102821 <__alltraps>

c0101e70 <vector23>:
.globl vector23
vector23:
  pushl $0
c0101e70:	6a 00                	push   $0x0
  pushl $23
c0101e72:	6a 17                	push   $0x17
  jmp __alltraps
c0101e74:	e9 a8 09 00 00       	jmp    c0102821 <__alltraps>

c0101e79 <vector24>:
.globl vector24
vector24:
  pushl $0
c0101e79:	6a 00                	push   $0x0
  pushl $24
c0101e7b:	6a 18                	push   $0x18
  jmp __alltraps
c0101e7d:	e9 9f 09 00 00       	jmp    c0102821 <__alltraps>

c0101e82 <vector25>:
.globl vector25
vector25:
  pushl $0
c0101e82:	6a 00                	push   $0x0
  pushl $25
c0101e84:	6a 19                	push   $0x19
  jmp __alltraps
c0101e86:	e9 96 09 00 00       	jmp    c0102821 <__alltraps>

c0101e8b <vector26>:
.globl vector26
vector26:
  pushl $0
c0101e8b:	6a 00                	push   $0x0
  pushl $26
c0101e8d:	6a 1a                	push   $0x1a
  jmp __alltraps
c0101e8f:	e9 8d 09 00 00       	jmp    c0102821 <__alltraps>

c0101e94 <vector27>:
.globl vector27
vector27:
  pushl $0
c0101e94:	6a 00                	push   $0x0
  pushl $27
c0101e96:	6a 1b                	push   $0x1b
  jmp __alltraps
c0101e98:	e9 84 09 00 00       	jmp    c0102821 <__alltraps>

c0101e9d <vector28>:
.globl vector28
vector28:
  pushl $0
c0101e9d:	6a 00                	push   $0x0
  pushl $28
c0101e9f:	6a 1c                	push   $0x1c
  jmp __alltraps
c0101ea1:	e9 7b 09 00 00       	jmp    c0102821 <__alltraps>

c0101ea6 <vector29>:
.globl vector29
vector29:
  pushl $0
c0101ea6:	6a 00                	push   $0x0
  pushl $29
c0101ea8:	6a 1d                	push   $0x1d
  jmp __alltraps
c0101eaa:	e9 72 09 00 00       	jmp    c0102821 <__alltraps>

c0101eaf <vector30>:
.globl vector30
vector30:
  pushl $0
c0101eaf:	6a 00                	push   $0x0
  pushl $30
c0101eb1:	6a 1e                	push   $0x1e
  jmp __alltraps
c0101eb3:	e9 69 09 00 00       	jmp    c0102821 <__alltraps>

c0101eb8 <vector31>:
.globl vector31
vector31:
  pushl $0
c0101eb8:	6a 00                	push   $0x0
  pushl $31
c0101eba:	6a 1f                	push   $0x1f
  jmp __alltraps
c0101ebc:	e9 60 09 00 00       	jmp    c0102821 <__alltraps>

c0101ec1 <vector32>:
.globl vector32
vector32:
  pushl $0
c0101ec1:	6a 00                	push   $0x0
  pushl $32
c0101ec3:	6a 20                	push   $0x20
  jmp __alltraps
c0101ec5:	e9 57 09 00 00       	jmp    c0102821 <__alltraps>

c0101eca <vector33>:
.globl vector33
vector33:
  pushl $0
c0101eca:	6a 00                	push   $0x0
  pushl $33
c0101ecc:	6a 21                	push   $0x21
  jmp __alltraps
c0101ece:	e9 4e 09 00 00       	jmp    c0102821 <__alltraps>

c0101ed3 <vector34>:
.globl vector34
vector34:
  pushl $0
c0101ed3:	6a 00                	push   $0x0
  pushl $34
c0101ed5:	6a 22                	push   $0x22
  jmp __alltraps
c0101ed7:	e9 45 09 00 00       	jmp    c0102821 <__alltraps>

c0101edc <vector35>:
.globl vector35
vector35:
  pushl $0
c0101edc:	6a 00                	push   $0x0
  pushl $35
c0101ede:	6a 23                	push   $0x23
  jmp __alltraps
c0101ee0:	e9 3c 09 00 00       	jmp    c0102821 <__alltraps>

c0101ee5 <vector36>:
.globl vector36
vector36:
  pushl $0
c0101ee5:	6a 00                	push   $0x0
  pushl $36
c0101ee7:	6a 24                	push   $0x24
  jmp __alltraps
c0101ee9:	e9 33 09 00 00       	jmp    c0102821 <__alltraps>

c0101eee <vector37>:
.globl vector37
vector37:
  pushl $0
c0101eee:	6a 00                	push   $0x0
  pushl $37
c0101ef0:	6a 25                	push   $0x25
  jmp __alltraps
c0101ef2:	e9 2a 09 00 00       	jmp    c0102821 <__alltraps>

c0101ef7 <vector38>:
.globl vector38
vector38:
  pushl $0
c0101ef7:	6a 00                	push   $0x0
  pushl $38
c0101ef9:	6a 26                	push   $0x26
  jmp __alltraps
c0101efb:	e9 21 09 00 00       	jmp    c0102821 <__alltraps>

c0101f00 <vector39>:
.globl vector39
vector39:
  pushl $0
c0101f00:	6a 00                	push   $0x0
  pushl $39
c0101f02:	6a 27                	push   $0x27
  jmp __alltraps
c0101f04:	e9 18 09 00 00       	jmp    c0102821 <__alltraps>

c0101f09 <vector40>:
.globl vector40
vector40:
  pushl $0
c0101f09:	6a 00                	push   $0x0
  pushl $40
c0101f0b:	6a 28                	push   $0x28
  jmp __alltraps
c0101f0d:	e9 0f 09 00 00       	jmp    c0102821 <__alltraps>

c0101f12 <vector41>:
.globl vector41
vector41:
  pushl $0
c0101f12:	6a 00                	push   $0x0
  pushl $41
c0101f14:	6a 29                	push   $0x29
  jmp __alltraps
c0101f16:	e9 06 09 00 00       	jmp    c0102821 <__alltraps>

c0101f1b <vector42>:
.globl vector42
vector42:
  pushl $0
c0101f1b:	6a 00                	push   $0x0
  pushl $42
c0101f1d:	6a 2a                	push   $0x2a
  jmp __alltraps
c0101f1f:	e9 fd 08 00 00       	jmp    c0102821 <__alltraps>

c0101f24 <vector43>:
.globl vector43
vector43:
  pushl $0
c0101f24:	6a 00                	push   $0x0
  pushl $43
c0101f26:	6a 2b                	push   $0x2b
  jmp __alltraps
c0101f28:	e9 f4 08 00 00       	jmp    c0102821 <__alltraps>

c0101f2d <vector44>:
.globl vector44
vector44:
  pushl $0
c0101f2d:	6a 00                	push   $0x0
  pushl $44
c0101f2f:	6a 2c                	push   $0x2c
  jmp __alltraps
c0101f31:	e9 eb 08 00 00       	jmp    c0102821 <__alltraps>

c0101f36 <vector45>:
.globl vector45
vector45:
  pushl $0
c0101f36:	6a 00                	push   $0x0
  pushl $45
c0101f38:	6a 2d                	push   $0x2d
  jmp __alltraps
c0101f3a:	e9 e2 08 00 00       	jmp    c0102821 <__alltraps>

c0101f3f <vector46>:
.globl vector46
vector46:
  pushl $0
c0101f3f:	6a 00                	push   $0x0
  pushl $46
c0101f41:	6a 2e                	push   $0x2e
  jmp __alltraps
c0101f43:	e9 d9 08 00 00       	jmp    c0102821 <__alltraps>

c0101f48 <vector47>:
.globl vector47
vector47:
  pushl $0
c0101f48:	6a 00                	push   $0x0
  pushl $47
c0101f4a:	6a 2f                	push   $0x2f
  jmp __alltraps
c0101f4c:	e9 d0 08 00 00       	jmp    c0102821 <__alltraps>

c0101f51 <vector48>:
.globl vector48
vector48:
  pushl $0
c0101f51:	6a 00                	push   $0x0
  pushl $48
c0101f53:	6a 30                	push   $0x30
  jmp __alltraps
c0101f55:	e9 c7 08 00 00       	jmp    c0102821 <__alltraps>

c0101f5a <vector49>:
.globl vector49
vector49:
  pushl $0
c0101f5a:	6a 00                	push   $0x0
  pushl $49
c0101f5c:	6a 31                	push   $0x31
  jmp __alltraps
c0101f5e:	e9 be 08 00 00       	jmp    c0102821 <__alltraps>

c0101f63 <vector50>:
.globl vector50
vector50:
  pushl $0
c0101f63:	6a 00                	push   $0x0
  pushl $50
c0101f65:	6a 32                	push   $0x32
  jmp __alltraps
c0101f67:	e9 b5 08 00 00       	jmp    c0102821 <__alltraps>

c0101f6c <vector51>:
.globl vector51
vector51:
  pushl $0
c0101f6c:	6a 00                	push   $0x0
  pushl $51
c0101f6e:	6a 33                	push   $0x33
  jmp __alltraps
c0101f70:	e9 ac 08 00 00       	jmp    c0102821 <__alltraps>

c0101f75 <vector52>:
.globl vector52
vector52:
  pushl $0
c0101f75:	6a 00                	push   $0x0
  pushl $52
c0101f77:	6a 34                	push   $0x34
  jmp __alltraps
c0101f79:	e9 a3 08 00 00       	jmp    c0102821 <__alltraps>

c0101f7e <vector53>:
.globl vector53
vector53:
  pushl $0
c0101f7e:	6a 00                	push   $0x0
  pushl $53
c0101f80:	6a 35                	push   $0x35
  jmp __alltraps
c0101f82:	e9 9a 08 00 00       	jmp    c0102821 <__alltraps>

c0101f87 <vector54>:
.globl vector54
vector54:
  pushl $0
c0101f87:	6a 00                	push   $0x0
  pushl $54
c0101f89:	6a 36                	push   $0x36
  jmp __alltraps
c0101f8b:	e9 91 08 00 00       	jmp    c0102821 <__alltraps>

c0101f90 <vector55>:
.globl vector55
vector55:
  pushl $0
c0101f90:	6a 00                	push   $0x0
  pushl $55
c0101f92:	6a 37                	push   $0x37
  jmp __alltraps
c0101f94:	e9 88 08 00 00       	jmp    c0102821 <__alltraps>

c0101f99 <vector56>:
.globl vector56
vector56:
  pushl $0
c0101f99:	6a 00                	push   $0x0
  pushl $56
c0101f9b:	6a 38                	push   $0x38
  jmp __alltraps
c0101f9d:	e9 7f 08 00 00       	jmp    c0102821 <__alltraps>

c0101fa2 <vector57>:
.globl vector57
vector57:
  pushl $0
c0101fa2:	6a 00                	push   $0x0
  pushl $57
c0101fa4:	6a 39                	push   $0x39
  jmp __alltraps
c0101fa6:	e9 76 08 00 00       	jmp    c0102821 <__alltraps>

c0101fab <vector58>:
.globl vector58
vector58:
  pushl $0
c0101fab:	6a 00                	push   $0x0
  pushl $58
c0101fad:	6a 3a                	push   $0x3a
  jmp __alltraps
c0101faf:	e9 6d 08 00 00       	jmp    c0102821 <__alltraps>

c0101fb4 <vector59>:
.globl vector59
vector59:
  pushl $0
c0101fb4:	6a 00                	push   $0x0
  pushl $59
c0101fb6:	6a 3b                	push   $0x3b
  jmp __alltraps
c0101fb8:	e9 64 08 00 00       	jmp    c0102821 <__alltraps>

c0101fbd <vector60>:
.globl vector60
vector60:
  pushl $0
c0101fbd:	6a 00                	push   $0x0
  pushl $60
c0101fbf:	6a 3c                	push   $0x3c
  jmp __alltraps
c0101fc1:	e9 5b 08 00 00       	jmp    c0102821 <__alltraps>

c0101fc6 <vector61>:
.globl vector61
vector61:
  pushl $0
c0101fc6:	6a 00                	push   $0x0
  pushl $61
c0101fc8:	6a 3d                	push   $0x3d
  jmp __alltraps
c0101fca:	e9 52 08 00 00       	jmp    c0102821 <__alltraps>

c0101fcf <vector62>:
.globl vector62
vector62:
  pushl $0
c0101fcf:	6a 00                	push   $0x0
  pushl $62
c0101fd1:	6a 3e                	push   $0x3e
  jmp __alltraps
c0101fd3:	e9 49 08 00 00       	jmp    c0102821 <__alltraps>

c0101fd8 <vector63>:
.globl vector63
vector63:
  pushl $0
c0101fd8:	6a 00                	push   $0x0
  pushl $63
c0101fda:	6a 3f                	push   $0x3f
  jmp __alltraps
c0101fdc:	e9 40 08 00 00       	jmp    c0102821 <__alltraps>

c0101fe1 <vector64>:
.globl vector64
vector64:
  pushl $0
c0101fe1:	6a 00                	push   $0x0
  pushl $64
c0101fe3:	6a 40                	push   $0x40
  jmp __alltraps
c0101fe5:	e9 37 08 00 00       	jmp    c0102821 <__alltraps>

c0101fea <vector65>:
.globl vector65
vector65:
  pushl $0
c0101fea:	6a 00                	push   $0x0
  pushl $65
c0101fec:	6a 41                	push   $0x41
  jmp __alltraps
c0101fee:	e9 2e 08 00 00       	jmp    c0102821 <__alltraps>

c0101ff3 <vector66>:
.globl vector66
vector66:
  pushl $0
c0101ff3:	6a 00                	push   $0x0
  pushl $66
c0101ff5:	6a 42                	push   $0x42
  jmp __alltraps
c0101ff7:	e9 25 08 00 00       	jmp    c0102821 <__alltraps>

c0101ffc <vector67>:
.globl vector67
vector67:
  pushl $0
c0101ffc:	6a 00                	push   $0x0
  pushl $67
c0101ffe:	6a 43                	push   $0x43
  jmp __alltraps
c0102000:	e9 1c 08 00 00       	jmp    c0102821 <__alltraps>

c0102005 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102005:	6a 00                	push   $0x0
  pushl $68
c0102007:	6a 44                	push   $0x44
  jmp __alltraps
c0102009:	e9 13 08 00 00       	jmp    c0102821 <__alltraps>

c010200e <vector69>:
.globl vector69
vector69:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $69
c0102010:	6a 45                	push   $0x45
  jmp __alltraps
c0102012:	e9 0a 08 00 00       	jmp    c0102821 <__alltraps>

c0102017 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $70
c0102019:	6a 46                	push   $0x46
  jmp __alltraps
c010201b:	e9 01 08 00 00       	jmp    c0102821 <__alltraps>

c0102020 <vector71>:
.globl vector71
vector71:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $71
c0102022:	6a 47                	push   $0x47
  jmp __alltraps
c0102024:	e9 f8 07 00 00       	jmp    c0102821 <__alltraps>

c0102029 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $72
c010202b:	6a 48                	push   $0x48
  jmp __alltraps
c010202d:	e9 ef 07 00 00       	jmp    c0102821 <__alltraps>

c0102032 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $73
c0102034:	6a 49                	push   $0x49
  jmp __alltraps
c0102036:	e9 e6 07 00 00       	jmp    c0102821 <__alltraps>

c010203b <vector74>:
.globl vector74
vector74:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $74
c010203d:	6a 4a                	push   $0x4a
  jmp __alltraps
c010203f:	e9 dd 07 00 00       	jmp    c0102821 <__alltraps>

c0102044 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $75
c0102046:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102048:	e9 d4 07 00 00       	jmp    c0102821 <__alltraps>

c010204d <vector76>:
.globl vector76
vector76:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $76
c010204f:	6a 4c                	push   $0x4c
  jmp __alltraps
c0102051:	e9 cb 07 00 00       	jmp    c0102821 <__alltraps>

c0102056 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102056:	6a 00                	push   $0x0
  pushl $77
c0102058:	6a 4d                	push   $0x4d
  jmp __alltraps
c010205a:	e9 c2 07 00 00       	jmp    c0102821 <__alltraps>

c010205f <vector78>:
.globl vector78
vector78:
  pushl $0
c010205f:	6a 00                	push   $0x0
  pushl $78
c0102061:	6a 4e                	push   $0x4e
  jmp __alltraps
c0102063:	e9 b9 07 00 00       	jmp    c0102821 <__alltraps>

c0102068 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102068:	6a 00                	push   $0x0
  pushl $79
c010206a:	6a 4f                	push   $0x4f
  jmp __alltraps
c010206c:	e9 b0 07 00 00       	jmp    c0102821 <__alltraps>

c0102071 <vector80>:
.globl vector80
vector80:
  pushl $0
c0102071:	6a 00                	push   $0x0
  pushl $80
c0102073:	6a 50                	push   $0x50
  jmp __alltraps
c0102075:	e9 a7 07 00 00       	jmp    c0102821 <__alltraps>

c010207a <vector81>:
.globl vector81
vector81:
  pushl $0
c010207a:	6a 00                	push   $0x0
  pushl $81
c010207c:	6a 51                	push   $0x51
  jmp __alltraps
c010207e:	e9 9e 07 00 00       	jmp    c0102821 <__alltraps>

c0102083 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102083:	6a 00                	push   $0x0
  pushl $82
c0102085:	6a 52                	push   $0x52
  jmp __alltraps
c0102087:	e9 95 07 00 00       	jmp    c0102821 <__alltraps>

c010208c <vector83>:
.globl vector83
vector83:
  pushl $0
c010208c:	6a 00                	push   $0x0
  pushl $83
c010208e:	6a 53                	push   $0x53
  jmp __alltraps
c0102090:	e9 8c 07 00 00       	jmp    c0102821 <__alltraps>

c0102095 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102095:	6a 00                	push   $0x0
  pushl $84
c0102097:	6a 54                	push   $0x54
  jmp __alltraps
c0102099:	e9 83 07 00 00       	jmp    c0102821 <__alltraps>

c010209e <vector85>:
.globl vector85
vector85:
  pushl $0
c010209e:	6a 00                	push   $0x0
  pushl $85
c01020a0:	6a 55                	push   $0x55
  jmp __alltraps
c01020a2:	e9 7a 07 00 00       	jmp    c0102821 <__alltraps>

c01020a7 <vector86>:
.globl vector86
vector86:
  pushl $0
c01020a7:	6a 00                	push   $0x0
  pushl $86
c01020a9:	6a 56                	push   $0x56
  jmp __alltraps
c01020ab:	e9 71 07 00 00       	jmp    c0102821 <__alltraps>

c01020b0 <vector87>:
.globl vector87
vector87:
  pushl $0
c01020b0:	6a 00                	push   $0x0
  pushl $87
c01020b2:	6a 57                	push   $0x57
  jmp __alltraps
c01020b4:	e9 68 07 00 00       	jmp    c0102821 <__alltraps>

c01020b9 <vector88>:
.globl vector88
vector88:
  pushl $0
c01020b9:	6a 00                	push   $0x0
  pushl $88
c01020bb:	6a 58                	push   $0x58
  jmp __alltraps
c01020bd:	e9 5f 07 00 00       	jmp    c0102821 <__alltraps>

c01020c2 <vector89>:
.globl vector89
vector89:
  pushl $0
c01020c2:	6a 00                	push   $0x0
  pushl $89
c01020c4:	6a 59                	push   $0x59
  jmp __alltraps
c01020c6:	e9 56 07 00 00       	jmp    c0102821 <__alltraps>

c01020cb <vector90>:
.globl vector90
vector90:
  pushl $0
c01020cb:	6a 00                	push   $0x0
  pushl $90
c01020cd:	6a 5a                	push   $0x5a
  jmp __alltraps
c01020cf:	e9 4d 07 00 00       	jmp    c0102821 <__alltraps>

c01020d4 <vector91>:
.globl vector91
vector91:
  pushl $0
c01020d4:	6a 00                	push   $0x0
  pushl $91
c01020d6:	6a 5b                	push   $0x5b
  jmp __alltraps
c01020d8:	e9 44 07 00 00       	jmp    c0102821 <__alltraps>

c01020dd <vector92>:
.globl vector92
vector92:
  pushl $0
c01020dd:	6a 00                	push   $0x0
  pushl $92
c01020df:	6a 5c                	push   $0x5c
  jmp __alltraps
c01020e1:	e9 3b 07 00 00       	jmp    c0102821 <__alltraps>

c01020e6 <vector93>:
.globl vector93
vector93:
  pushl $0
c01020e6:	6a 00                	push   $0x0
  pushl $93
c01020e8:	6a 5d                	push   $0x5d
  jmp __alltraps
c01020ea:	e9 32 07 00 00       	jmp    c0102821 <__alltraps>

c01020ef <vector94>:
.globl vector94
vector94:
  pushl $0
c01020ef:	6a 00                	push   $0x0
  pushl $94
c01020f1:	6a 5e                	push   $0x5e
  jmp __alltraps
c01020f3:	e9 29 07 00 00       	jmp    c0102821 <__alltraps>

c01020f8 <vector95>:
.globl vector95
vector95:
  pushl $0
c01020f8:	6a 00                	push   $0x0
  pushl $95
c01020fa:	6a 5f                	push   $0x5f
  jmp __alltraps
c01020fc:	e9 20 07 00 00       	jmp    c0102821 <__alltraps>

c0102101 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102101:	6a 00                	push   $0x0
  pushl $96
c0102103:	6a 60                	push   $0x60
  jmp __alltraps
c0102105:	e9 17 07 00 00       	jmp    c0102821 <__alltraps>

c010210a <vector97>:
.globl vector97
vector97:
  pushl $0
c010210a:	6a 00                	push   $0x0
  pushl $97
c010210c:	6a 61                	push   $0x61
  jmp __alltraps
c010210e:	e9 0e 07 00 00       	jmp    c0102821 <__alltraps>

c0102113 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102113:	6a 00                	push   $0x0
  pushl $98
c0102115:	6a 62                	push   $0x62
  jmp __alltraps
c0102117:	e9 05 07 00 00       	jmp    c0102821 <__alltraps>

c010211c <vector99>:
.globl vector99
vector99:
  pushl $0
c010211c:	6a 00                	push   $0x0
  pushl $99
c010211e:	6a 63                	push   $0x63
  jmp __alltraps
c0102120:	e9 fc 06 00 00       	jmp    c0102821 <__alltraps>

c0102125 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102125:	6a 00                	push   $0x0
  pushl $100
c0102127:	6a 64                	push   $0x64
  jmp __alltraps
c0102129:	e9 f3 06 00 00       	jmp    c0102821 <__alltraps>

c010212e <vector101>:
.globl vector101
vector101:
  pushl $0
c010212e:	6a 00                	push   $0x0
  pushl $101
c0102130:	6a 65                	push   $0x65
  jmp __alltraps
c0102132:	e9 ea 06 00 00       	jmp    c0102821 <__alltraps>

c0102137 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102137:	6a 00                	push   $0x0
  pushl $102
c0102139:	6a 66                	push   $0x66
  jmp __alltraps
c010213b:	e9 e1 06 00 00       	jmp    c0102821 <__alltraps>

c0102140 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102140:	6a 00                	push   $0x0
  pushl $103
c0102142:	6a 67                	push   $0x67
  jmp __alltraps
c0102144:	e9 d8 06 00 00       	jmp    c0102821 <__alltraps>

c0102149 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102149:	6a 00                	push   $0x0
  pushl $104
c010214b:	6a 68                	push   $0x68
  jmp __alltraps
c010214d:	e9 cf 06 00 00       	jmp    c0102821 <__alltraps>

c0102152 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102152:	6a 00                	push   $0x0
  pushl $105
c0102154:	6a 69                	push   $0x69
  jmp __alltraps
c0102156:	e9 c6 06 00 00       	jmp    c0102821 <__alltraps>

c010215b <vector106>:
.globl vector106
vector106:
  pushl $0
c010215b:	6a 00                	push   $0x0
  pushl $106
c010215d:	6a 6a                	push   $0x6a
  jmp __alltraps
c010215f:	e9 bd 06 00 00       	jmp    c0102821 <__alltraps>

c0102164 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102164:	6a 00                	push   $0x0
  pushl $107
c0102166:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102168:	e9 b4 06 00 00       	jmp    c0102821 <__alltraps>

c010216d <vector108>:
.globl vector108
vector108:
  pushl $0
c010216d:	6a 00                	push   $0x0
  pushl $108
c010216f:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102171:	e9 ab 06 00 00       	jmp    c0102821 <__alltraps>

c0102176 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102176:	6a 00                	push   $0x0
  pushl $109
c0102178:	6a 6d                	push   $0x6d
  jmp __alltraps
c010217a:	e9 a2 06 00 00       	jmp    c0102821 <__alltraps>

c010217f <vector110>:
.globl vector110
vector110:
  pushl $0
c010217f:	6a 00                	push   $0x0
  pushl $110
c0102181:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102183:	e9 99 06 00 00       	jmp    c0102821 <__alltraps>

c0102188 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102188:	6a 00                	push   $0x0
  pushl $111
c010218a:	6a 6f                	push   $0x6f
  jmp __alltraps
c010218c:	e9 90 06 00 00       	jmp    c0102821 <__alltraps>

c0102191 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102191:	6a 00                	push   $0x0
  pushl $112
c0102193:	6a 70                	push   $0x70
  jmp __alltraps
c0102195:	e9 87 06 00 00       	jmp    c0102821 <__alltraps>

c010219a <vector113>:
.globl vector113
vector113:
  pushl $0
c010219a:	6a 00                	push   $0x0
  pushl $113
c010219c:	6a 71                	push   $0x71
  jmp __alltraps
c010219e:	e9 7e 06 00 00       	jmp    c0102821 <__alltraps>

c01021a3 <vector114>:
.globl vector114
vector114:
  pushl $0
c01021a3:	6a 00                	push   $0x0
  pushl $114
c01021a5:	6a 72                	push   $0x72
  jmp __alltraps
c01021a7:	e9 75 06 00 00       	jmp    c0102821 <__alltraps>

c01021ac <vector115>:
.globl vector115
vector115:
  pushl $0
c01021ac:	6a 00                	push   $0x0
  pushl $115
c01021ae:	6a 73                	push   $0x73
  jmp __alltraps
c01021b0:	e9 6c 06 00 00       	jmp    c0102821 <__alltraps>

c01021b5 <vector116>:
.globl vector116
vector116:
  pushl $0
c01021b5:	6a 00                	push   $0x0
  pushl $116
c01021b7:	6a 74                	push   $0x74
  jmp __alltraps
c01021b9:	e9 63 06 00 00       	jmp    c0102821 <__alltraps>

c01021be <vector117>:
.globl vector117
vector117:
  pushl $0
c01021be:	6a 00                	push   $0x0
  pushl $117
c01021c0:	6a 75                	push   $0x75
  jmp __alltraps
c01021c2:	e9 5a 06 00 00       	jmp    c0102821 <__alltraps>

c01021c7 <vector118>:
.globl vector118
vector118:
  pushl $0
c01021c7:	6a 00                	push   $0x0
  pushl $118
c01021c9:	6a 76                	push   $0x76
  jmp __alltraps
c01021cb:	e9 51 06 00 00       	jmp    c0102821 <__alltraps>

c01021d0 <vector119>:
.globl vector119
vector119:
  pushl $0
c01021d0:	6a 00                	push   $0x0
  pushl $119
c01021d2:	6a 77                	push   $0x77
  jmp __alltraps
c01021d4:	e9 48 06 00 00       	jmp    c0102821 <__alltraps>

c01021d9 <vector120>:
.globl vector120
vector120:
  pushl $0
c01021d9:	6a 00                	push   $0x0
  pushl $120
c01021db:	6a 78                	push   $0x78
  jmp __alltraps
c01021dd:	e9 3f 06 00 00       	jmp    c0102821 <__alltraps>

c01021e2 <vector121>:
.globl vector121
vector121:
  pushl $0
c01021e2:	6a 00                	push   $0x0
  pushl $121
c01021e4:	6a 79                	push   $0x79
  jmp __alltraps
c01021e6:	e9 36 06 00 00       	jmp    c0102821 <__alltraps>

c01021eb <vector122>:
.globl vector122
vector122:
  pushl $0
c01021eb:	6a 00                	push   $0x0
  pushl $122
c01021ed:	6a 7a                	push   $0x7a
  jmp __alltraps
c01021ef:	e9 2d 06 00 00       	jmp    c0102821 <__alltraps>

c01021f4 <vector123>:
.globl vector123
vector123:
  pushl $0
c01021f4:	6a 00                	push   $0x0
  pushl $123
c01021f6:	6a 7b                	push   $0x7b
  jmp __alltraps
c01021f8:	e9 24 06 00 00       	jmp    c0102821 <__alltraps>

c01021fd <vector124>:
.globl vector124
vector124:
  pushl $0
c01021fd:	6a 00                	push   $0x0
  pushl $124
c01021ff:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102201:	e9 1b 06 00 00       	jmp    c0102821 <__alltraps>

c0102206 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $125
c0102208:	6a 7d                	push   $0x7d
  jmp __alltraps
c010220a:	e9 12 06 00 00       	jmp    c0102821 <__alltraps>

c010220f <vector126>:
.globl vector126
vector126:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $126
c0102211:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102213:	e9 09 06 00 00       	jmp    c0102821 <__alltraps>

c0102218 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102218:	6a 00                	push   $0x0
  pushl $127
c010221a:	6a 7f                	push   $0x7f
  jmp __alltraps
c010221c:	e9 00 06 00 00       	jmp    c0102821 <__alltraps>

c0102221 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102221:	6a 00                	push   $0x0
  pushl $128
c0102223:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102228:	e9 f4 05 00 00       	jmp    c0102821 <__alltraps>

c010222d <vector129>:
.globl vector129
vector129:
  pushl $0
c010222d:	6a 00                	push   $0x0
  pushl $129
c010222f:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102234:	e9 e8 05 00 00       	jmp    c0102821 <__alltraps>

c0102239 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102239:	6a 00                	push   $0x0
  pushl $130
c010223b:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102240:	e9 dc 05 00 00       	jmp    c0102821 <__alltraps>

c0102245 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102245:	6a 00                	push   $0x0
  pushl $131
c0102247:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c010224c:	e9 d0 05 00 00       	jmp    c0102821 <__alltraps>

c0102251 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102251:	6a 00                	push   $0x0
  pushl $132
c0102253:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102258:	e9 c4 05 00 00       	jmp    c0102821 <__alltraps>

c010225d <vector133>:
.globl vector133
vector133:
  pushl $0
c010225d:	6a 00                	push   $0x0
  pushl $133
c010225f:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102264:	e9 b8 05 00 00       	jmp    c0102821 <__alltraps>

c0102269 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102269:	6a 00                	push   $0x0
  pushl $134
c010226b:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102270:	e9 ac 05 00 00       	jmp    c0102821 <__alltraps>

c0102275 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102275:	6a 00                	push   $0x0
  pushl $135
c0102277:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c010227c:	e9 a0 05 00 00       	jmp    c0102821 <__alltraps>

c0102281 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102281:	6a 00                	push   $0x0
  pushl $136
c0102283:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102288:	e9 94 05 00 00       	jmp    c0102821 <__alltraps>

c010228d <vector137>:
.globl vector137
vector137:
  pushl $0
c010228d:	6a 00                	push   $0x0
  pushl $137
c010228f:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102294:	e9 88 05 00 00       	jmp    c0102821 <__alltraps>

c0102299 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102299:	6a 00                	push   $0x0
  pushl $138
c010229b:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01022a0:	e9 7c 05 00 00       	jmp    c0102821 <__alltraps>

c01022a5 <vector139>:
.globl vector139
vector139:
  pushl $0
c01022a5:	6a 00                	push   $0x0
  pushl $139
c01022a7:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c01022ac:	e9 70 05 00 00       	jmp    c0102821 <__alltraps>

c01022b1 <vector140>:
.globl vector140
vector140:
  pushl $0
c01022b1:	6a 00                	push   $0x0
  pushl $140
c01022b3:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c01022b8:	e9 64 05 00 00       	jmp    c0102821 <__alltraps>

c01022bd <vector141>:
.globl vector141
vector141:
  pushl $0
c01022bd:	6a 00                	push   $0x0
  pushl $141
c01022bf:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01022c4:	e9 58 05 00 00       	jmp    c0102821 <__alltraps>

c01022c9 <vector142>:
.globl vector142
vector142:
  pushl $0
c01022c9:	6a 00                	push   $0x0
  pushl $142
c01022cb:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01022d0:	e9 4c 05 00 00       	jmp    c0102821 <__alltraps>

c01022d5 <vector143>:
.globl vector143
vector143:
  pushl $0
c01022d5:	6a 00                	push   $0x0
  pushl $143
c01022d7:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01022dc:	e9 40 05 00 00       	jmp    c0102821 <__alltraps>

c01022e1 <vector144>:
.globl vector144
vector144:
  pushl $0
c01022e1:	6a 00                	push   $0x0
  pushl $144
c01022e3:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01022e8:	e9 34 05 00 00       	jmp    c0102821 <__alltraps>

c01022ed <vector145>:
.globl vector145
vector145:
  pushl $0
c01022ed:	6a 00                	push   $0x0
  pushl $145
c01022ef:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01022f4:	e9 28 05 00 00       	jmp    c0102821 <__alltraps>

c01022f9 <vector146>:
.globl vector146
vector146:
  pushl $0
c01022f9:	6a 00                	push   $0x0
  pushl $146
c01022fb:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102300:	e9 1c 05 00 00       	jmp    c0102821 <__alltraps>

c0102305 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102305:	6a 00                	push   $0x0
  pushl $147
c0102307:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010230c:	e9 10 05 00 00       	jmp    c0102821 <__alltraps>

c0102311 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102311:	6a 00                	push   $0x0
  pushl $148
c0102313:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102318:	e9 04 05 00 00       	jmp    c0102821 <__alltraps>

c010231d <vector149>:
.globl vector149
vector149:
  pushl $0
c010231d:	6a 00                	push   $0x0
  pushl $149
c010231f:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102324:	e9 f8 04 00 00       	jmp    c0102821 <__alltraps>

c0102329 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102329:	6a 00                	push   $0x0
  pushl $150
c010232b:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102330:	e9 ec 04 00 00       	jmp    c0102821 <__alltraps>

c0102335 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102335:	6a 00                	push   $0x0
  pushl $151
c0102337:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010233c:	e9 e0 04 00 00       	jmp    c0102821 <__alltraps>

c0102341 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102341:	6a 00                	push   $0x0
  pushl $152
c0102343:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102348:	e9 d4 04 00 00       	jmp    c0102821 <__alltraps>

c010234d <vector153>:
.globl vector153
vector153:
  pushl $0
c010234d:	6a 00                	push   $0x0
  pushl $153
c010234f:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102354:	e9 c8 04 00 00       	jmp    c0102821 <__alltraps>

c0102359 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102359:	6a 00                	push   $0x0
  pushl $154
c010235b:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102360:	e9 bc 04 00 00       	jmp    c0102821 <__alltraps>

c0102365 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102365:	6a 00                	push   $0x0
  pushl $155
c0102367:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c010236c:	e9 b0 04 00 00       	jmp    c0102821 <__alltraps>

c0102371 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102371:	6a 00                	push   $0x0
  pushl $156
c0102373:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102378:	e9 a4 04 00 00       	jmp    c0102821 <__alltraps>

c010237d <vector157>:
.globl vector157
vector157:
  pushl $0
c010237d:	6a 00                	push   $0x0
  pushl $157
c010237f:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102384:	e9 98 04 00 00       	jmp    c0102821 <__alltraps>

c0102389 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102389:	6a 00                	push   $0x0
  pushl $158
c010238b:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102390:	e9 8c 04 00 00       	jmp    c0102821 <__alltraps>

c0102395 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102395:	6a 00                	push   $0x0
  pushl $159
c0102397:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c010239c:	e9 80 04 00 00       	jmp    c0102821 <__alltraps>

c01023a1 <vector160>:
.globl vector160
vector160:
  pushl $0
c01023a1:	6a 00                	push   $0x0
  pushl $160
c01023a3:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c01023a8:	e9 74 04 00 00       	jmp    c0102821 <__alltraps>

c01023ad <vector161>:
.globl vector161
vector161:
  pushl $0
c01023ad:	6a 00                	push   $0x0
  pushl $161
c01023af:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c01023b4:	e9 68 04 00 00       	jmp    c0102821 <__alltraps>

c01023b9 <vector162>:
.globl vector162
vector162:
  pushl $0
c01023b9:	6a 00                	push   $0x0
  pushl $162
c01023bb:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c01023c0:	e9 5c 04 00 00       	jmp    c0102821 <__alltraps>

c01023c5 <vector163>:
.globl vector163
vector163:
  pushl $0
c01023c5:	6a 00                	push   $0x0
  pushl $163
c01023c7:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01023cc:	e9 50 04 00 00       	jmp    c0102821 <__alltraps>

c01023d1 <vector164>:
.globl vector164
vector164:
  pushl $0
c01023d1:	6a 00                	push   $0x0
  pushl $164
c01023d3:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01023d8:	e9 44 04 00 00       	jmp    c0102821 <__alltraps>

c01023dd <vector165>:
.globl vector165
vector165:
  pushl $0
c01023dd:	6a 00                	push   $0x0
  pushl $165
c01023df:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01023e4:	e9 38 04 00 00       	jmp    c0102821 <__alltraps>

c01023e9 <vector166>:
.globl vector166
vector166:
  pushl $0
c01023e9:	6a 00                	push   $0x0
  pushl $166
c01023eb:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01023f0:	e9 2c 04 00 00       	jmp    c0102821 <__alltraps>

c01023f5 <vector167>:
.globl vector167
vector167:
  pushl $0
c01023f5:	6a 00                	push   $0x0
  pushl $167
c01023f7:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01023fc:	e9 20 04 00 00       	jmp    c0102821 <__alltraps>

c0102401 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102401:	6a 00                	push   $0x0
  pushl $168
c0102403:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102408:	e9 14 04 00 00       	jmp    c0102821 <__alltraps>

c010240d <vector169>:
.globl vector169
vector169:
  pushl $0
c010240d:	6a 00                	push   $0x0
  pushl $169
c010240f:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102414:	e9 08 04 00 00       	jmp    c0102821 <__alltraps>

c0102419 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102419:	6a 00                	push   $0x0
  pushl $170
c010241b:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102420:	e9 fc 03 00 00       	jmp    c0102821 <__alltraps>

c0102425 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102425:	6a 00                	push   $0x0
  pushl $171
c0102427:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010242c:	e9 f0 03 00 00       	jmp    c0102821 <__alltraps>

c0102431 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102431:	6a 00                	push   $0x0
  pushl $172
c0102433:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102438:	e9 e4 03 00 00       	jmp    c0102821 <__alltraps>

c010243d <vector173>:
.globl vector173
vector173:
  pushl $0
c010243d:	6a 00                	push   $0x0
  pushl $173
c010243f:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102444:	e9 d8 03 00 00       	jmp    c0102821 <__alltraps>

c0102449 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102449:	6a 00                	push   $0x0
  pushl $174
c010244b:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102450:	e9 cc 03 00 00       	jmp    c0102821 <__alltraps>

c0102455 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102455:	6a 00                	push   $0x0
  pushl $175
c0102457:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c010245c:	e9 c0 03 00 00       	jmp    c0102821 <__alltraps>

c0102461 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102461:	6a 00                	push   $0x0
  pushl $176
c0102463:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102468:	e9 b4 03 00 00       	jmp    c0102821 <__alltraps>

c010246d <vector177>:
.globl vector177
vector177:
  pushl $0
c010246d:	6a 00                	push   $0x0
  pushl $177
c010246f:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102474:	e9 a8 03 00 00       	jmp    c0102821 <__alltraps>

c0102479 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102479:	6a 00                	push   $0x0
  pushl $178
c010247b:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102480:	e9 9c 03 00 00       	jmp    c0102821 <__alltraps>

c0102485 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102485:	6a 00                	push   $0x0
  pushl $179
c0102487:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c010248c:	e9 90 03 00 00       	jmp    c0102821 <__alltraps>

c0102491 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102491:	6a 00                	push   $0x0
  pushl $180
c0102493:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102498:	e9 84 03 00 00       	jmp    c0102821 <__alltraps>

c010249d <vector181>:
.globl vector181
vector181:
  pushl $0
c010249d:	6a 00                	push   $0x0
  pushl $181
c010249f:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c01024a4:	e9 78 03 00 00       	jmp    c0102821 <__alltraps>

c01024a9 <vector182>:
.globl vector182
vector182:
  pushl $0
c01024a9:	6a 00                	push   $0x0
  pushl $182
c01024ab:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c01024b0:	e9 6c 03 00 00       	jmp    c0102821 <__alltraps>

c01024b5 <vector183>:
.globl vector183
vector183:
  pushl $0
c01024b5:	6a 00                	push   $0x0
  pushl $183
c01024b7:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c01024bc:	e9 60 03 00 00       	jmp    c0102821 <__alltraps>

c01024c1 <vector184>:
.globl vector184
vector184:
  pushl $0
c01024c1:	6a 00                	push   $0x0
  pushl $184
c01024c3:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01024c8:	e9 54 03 00 00       	jmp    c0102821 <__alltraps>

c01024cd <vector185>:
.globl vector185
vector185:
  pushl $0
c01024cd:	6a 00                	push   $0x0
  pushl $185
c01024cf:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01024d4:	e9 48 03 00 00       	jmp    c0102821 <__alltraps>

c01024d9 <vector186>:
.globl vector186
vector186:
  pushl $0
c01024d9:	6a 00                	push   $0x0
  pushl $186
c01024db:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01024e0:	e9 3c 03 00 00       	jmp    c0102821 <__alltraps>

c01024e5 <vector187>:
.globl vector187
vector187:
  pushl $0
c01024e5:	6a 00                	push   $0x0
  pushl $187
c01024e7:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01024ec:	e9 30 03 00 00       	jmp    c0102821 <__alltraps>

c01024f1 <vector188>:
.globl vector188
vector188:
  pushl $0
c01024f1:	6a 00                	push   $0x0
  pushl $188
c01024f3:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01024f8:	e9 24 03 00 00       	jmp    c0102821 <__alltraps>

c01024fd <vector189>:
.globl vector189
vector189:
  pushl $0
c01024fd:	6a 00                	push   $0x0
  pushl $189
c01024ff:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102504:	e9 18 03 00 00       	jmp    c0102821 <__alltraps>

c0102509 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102509:	6a 00                	push   $0x0
  pushl $190
c010250b:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102510:	e9 0c 03 00 00       	jmp    c0102821 <__alltraps>

c0102515 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102515:	6a 00                	push   $0x0
  pushl $191
c0102517:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010251c:	e9 00 03 00 00       	jmp    c0102821 <__alltraps>

c0102521 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102521:	6a 00                	push   $0x0
  pushl $192
c0102523:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102528:	e9 f4 02 00 00       	jmp    c0102821 <__alltraps>

c010252d <vector193>:
.globl vector193
vector193:
  pushl $0
c010252d:	6a 00                	push   $0x0
  pushl $193
c010252f:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102534:	e9 e8 02 00 00       	jmp    c0102821 <__alltraps>

c0102539 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102539:	6a 00                	push   $0x0
  pushl $194
c010253b:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102540:	e9 dc 02 00 00       	jmp    c0102821 <__alltraps>

c0102545 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102545:	6a 00                	push   $0x0
  pushl $195
c0102547:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c010254c:	e9 d0 02 00 00       	jmp    c0102821 <__alltraps>

c0102551 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102551:	6a 00                	push   $0x0
  pushl $196
c0102553:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102558:	e9 c4 02 00 00       	jmp    c0102821 <__alltraps>

c010255d <vector197>:
.globl vector197
vector197:
  pushl $0
c010255d:	6a 00                	push   $0x0
  pushl $197
c010255f:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102564:	e9 b8 02 00 00       	jmp    c0102821 <__alltraps>

c0102569 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102569:	6a 00                	push   $0x0
  pushl $198
c010256b:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102570:	e9 ac 02 00 00       	jmp    c0102821 <__alltraps>

c0102575 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102575:	6a 00                	push   $0x0
  pushl $199
c0102577:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c010257c:	e9 a0 02 00 00       	jmp    c0102821 <__alltraps>

c0102581 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102581:	6a 00                	push   $0x0
  pushl $200
c0102583:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102588:	e9 94 02 00 00       	jmp    c0102821 <__alltraps>

c010258d <vector201>:
.globl vector201
vector201:
  pushl $0
c010258d:	6a 00                	push   $0x0
  pushl $201
c010258f:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102594:	e9 88 02 00 00       	jmp    c0102821 <__alltraps>

c0102599 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102599:	6a 00                	push   $0x0
  pushl $202
c010259b:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01025a0:	e9 7c 02 00 00       	jmp    c0102821 <__alltraps>

c01025a5 <vector203>:
.globl vector203
vector203:
  pushl $0
c01025a5:	6a 00                	push   $0x0
  pushl $203
c01025a7:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c01025ac:	e9 70 02 00 00       	jmp    c0102821 <__alltraps>

c01025b1 <vector204>:
.globl vector204
vector204:
  pushl $0
c01025b1:	6a 00                	push   $0x0
  pushl $204
c01025b3:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c01025b8:	e9 64 02 00 00       	jmp    c0102821 <__alltraps>

c01025bd <vector205>:
.globl vector205
vector205:
  pushl $0
c01025bd:	6a 00                	push   $0x0
  pushl $205
c01025bf:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01025c4:	e9 58 02 00 00       	jmp    c0102821 <__alltraps>

c01025c9 <vector206>:
.globl vector206
vector206:
  pushl $0
c01025c9:	6a 00                	push   $0x0
  pushl $206
c01025cb:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01025d0:	e9 4c 02 00 00       	jmp    c0102821 <__alltraps>

c01025d5 <vector207>:
.globl vector207
vector207:
  pushl $0
c01025d5:	6a 00                	push   $0x0
  pushl $207
c01025d7:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01025dc:	e9 40 02 00 00       	jmp    c0102821 <__alltraps>

c01025e1 <vector208>:
.globl vector208
vector208:
  pushl $0
c01025e1:	6a 00                	push   $0x0
  pushl $208
c01025e3:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01025e8:	e9 34 02 00 00       	jmp    c0102821 <__alltraps>

c01025ed <vector209>:
.globl vector209
vector209:
  pushl $0
c01025ed:	6a 00                	push   $0x0
  pushl $209
c01025ef:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01025f4:	e9 28 02 00 00       	jmp    c0102821 <__alltraps>

c01025f9 <vector210>:
.globl vector210
vector210:
  pushl $0
c01025f9:	6a 00                	push   $0x0
  pushl $210
c01025fb:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102600:	e9 1c 02 00 00       	jmp    c0102821 <__alltraps>

c0102605 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102605:	6a 00                	push   $0x0
  pushl $211
c0102607:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010260c:	e9 10 02 00 00       	jmp    c0102821 <__alltraps>

c0102611 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102611:	6a 00                	push   $0x0
  pushl $212
c0102613:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102618:	e9 04 02 00 00       	jmp    c0102821 <__alltraps>

c010261d <vector213>:
.globl vector213
vector213:
  pushl $0
c010261d:	6a 00                	push   $0x0
  pushl $213
c010261f:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102624:	e9 f8 01 00 00       	jmp    c0102821 <__alltraps>

c0102629 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102629:	6a 00                	push   $0x0
  pushl $214
c010262b:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102630:	e9 ec 01 00 00       	jmp    c0102821 <__alltraps>

c0102635 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102635:	6a 00                	push   $0x0
  pushl $215
c0102637:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010263c:	e9 e0 01 00 00       	jmp    c0102821 <__alltraps>

c0102641 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102641:	6a 00                	push   $0x0
  pushl $216
c0102643:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102648:	e9 d4 01 00 00       	jmp    c0102821 <__alltraps>

c010264d <vector217>:
.globl vector217
vector217:
  pushl $0
c010264d:	6a 00                	push   $0x0
  pushl $217
c010264f:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102654:	e9 c8 01 00 00       	jmp    c0102821 <__alltraps>

c0102659 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102659:	6a 00                	push   $0x0
  pushl $218
c010265b:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102660:	e9 bc 01 00 00       	jmp    c0102821 <__alltraps>

c0102665 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102665:	6a 00                	push   $0x0
  pushl $219
c0102667:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c010266c:	e9 b0 01 00 00       	jmp    c0102821 <__alltraps>

c0102671 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102671:	6a 00                	push   $0x0
  pushl $220
c0102673:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102678:	e9 a4 01 00 00       	jmp    c0102821 <__alltraps>

c010267d <vector221>:
.globl vector221
vector221:
  pushl $0
c010267d:	6a 00                	push   $0x0
  pushl $221
c010267f:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102684:	e9 98 01 00 00       	jmp    c0102821 <__alltraps>

c0102689 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102689:	6a 00                	push   $0x0
  pushl $222
c010268b:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102690:	e9 8c 01 00 00       	jmp    c0102821 <__alltraps>

c0102695 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102695:	6a 00                	push   $0x0
  pushl $223
c0102697:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c010269c:	e9 80 01 00 00       	jmp    c0102821 <__alltraps>

c01026a1 <vector224>:
.globl vector224
vector224:
  pushl $0
c01026a1:	6a 00                	push   $0x0
  pushl $224
c01026a3:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c01026a8:	e9 74 01 00 00       	jmp    c0102821 <__alltraps>

c01026ad <vector225>:
.globl vector225
vector225:
  pushl $0
c01026ad:	6a 00                	push   $0x0
  pushl $225
c01026af:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c01026b4:	e9 68 01 00 00       	jmp    c0102821 <__alltraps>

c01026b9 <vector226>:
.globl vector226
vector226:
  pushl $0
c01026b9:	6a 00                	push   $0x0
  pushl $226
c01026bb:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c01026c0:	e9 5c 01 00 00       	jmp    c0102821 <__alltraps>

c01026c5 <vector227>:
.globl vector227
vector227:
  pushl $0
c01026c5:	6a 00                	push   $0x0
  pushl $227
c01026c7:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c01026cc:	e9 50 01 00 00       	jmp    c0102821 <__alltraps>

c01026d1 <vector228>:
.globl vector228
vector228:
  pushl $0
c01026d1:	6a 00                	push   $0x0
  pushl $228
c01026d3:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c01026d8:	e9 44 01 00 00       	jmp    c0102821 <__alltraps>

c01026dd <vector229>:
.globl vector229
vector229:
  pushl $0
c01026dd:	6a 00                	push   $0x0
  pushl $229
c01026df:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c01026e4:	e9 38 01 00 00       	jmp    c0102821 <__alltraps>

c01026e9 <vector230>:
.globl vector230
vector230:
  pushl $0
c01026e9:	6a 00                	push   $0x0
  pushl $230
c01026eb:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c01026f0:	e9 2c 01 00 00       	jmp    c0102821 <__alltraps>

c01026f5 <vector231>:
.globl vector231
vector231:
  pushl $0
c01026f5:	6a 00                	push   $0x0
  pushl $231
c01026f7:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c01026fc:	e9 20 01 00 00       	jmp    c0102821 <__alltraps>

c0102701 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102701:	6a 00                	push   $0x0
  pushl $232
c0102703:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102708:	e9 14 01 00 00       	jmp    c0102821 <__alltraps>

c010270d <vector233>:
.globl vector233
vector233:
  pushl $0
c010270d:	6a 00                	push   $0x0
  pushl $233
c010270f:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102714:	e9 08 01 00 00       	jmp    c0102821 <__alltraps>

c0102719 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102719:	6a 00                	push   $0x0
  pushl $234
c010271b:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102720:	e9 fc 00 00 00       	jmp    c0102821 <__alltraps>

c0102725 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102725:	6a 00                	push   $0x0
  pushl $235
c0102727:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010272c:	e9 f0 00 00 00       	jmp    c0102821 <__alltraps>

c0102731 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102731:	6a 00                	push   $0x0
  pushl $236
c0102733:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102738:	e9 e4 00 00 00       	jmp    c0102821 <__alltraps>

c010273d <vector237>:
.globl vector237
vector237:
  pushl $0
c010273d:	6a 00                	push   $0x0
  pushl $237
c010273f:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102744:	e9 d8 00 00 00       	jmp    c0102821 <__alltraps>

c0102749 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102749:	6a 00                	push   $0x0
  pushl $238
c010274b:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102750:	e9 cc 00 00 00       	jmp    c0102821 <__alltraps>

c0102755 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102755:	6a 00                	push   $0x0
  pushl $239
c0102757:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c010275c:	e9 c0 00 00 00       	jmp    c0102821 <__alltraps>

c0102761 <vector240>:
.globl vector240
vector240:
  pushl $0
c0102761:	6a 00                	push   $0x0
  pushl $240
c0102763:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102768:	e9 b4 00 00 00       	jmp    c0102821 <__alltraps>

c010276d <vector241>:
.globl vector241
vector241:
  pushl $0
c010276d:	6a 00                	push   $0x0
  pushl $241
c010276f:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102774:	e9 a8 00 00 00       	jmp    c0102821 <__alltraps>

c0102779 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102779:	6a 00                	push   $0x0
  pushl $242
c010277b:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102780:	e9 9c 00 00 00       	jmp    c0102821 <__alltraps>

c0102785 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102785:	6a 00                	push   $0x0
  pushl $243
c0102787:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c010278c:	e9 90 00 00 00       	jmp    c0102821 <__alltraps>

c0102791 <vector244>:
.globl vector244
vector244:
  pushl $0
c0102791:	6a 00                	push   $0x0
  pushl $244
c0102793:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102798:	e9 84 00 00 00       	jmp    c0102821 <__alltraps>

c010279d <vector245>:
.globl vector245
vector245:
  pushl $0
c010279d:	6a 00                	push   $0x0
  pushl $245
c010279f:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c01027a4:	e9 78 00 00 00       	jmp    c0102821 <__alltraps>

c01027a9 <vector246>:
.globl vector246
vector246:
  pushl $0
c01027a9:	6a 00                	push   $0x0
  pushl $246
c01027ab:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c01027b0:	e9 6c 00 00 00       	jmp    c0102821 <__alltraps>

c01027b5 <vector247>:
.globl vector247
vector247:
  pushl $0
c01027b5:	6a 00                	push   $0x0
  pushl $247
c01027b7:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c01027bc:	e9 60 00 00 00       	jmp    c0102821 <__alltraps>

c01027c1 <vector248>:
.globl vector248
vector248:
  pushl $0
c01027c1:	6a 00                	push   $0x0
  pushl $248
c01027c3:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c01027c8:	e9 54 00 00 00       	jmp    c0102821 <__alltraps>

c01027cd <vector249>:
.globl vector249
vector249:
  pushl $0
c01027cd:	6a 00                	push   $0x0
  pushl $249
c01027cf:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c01027d4:	e9 48 00 00 00       	jmp    c0102821 <__alltraps>

c01027d9 <vector250>:
.globl vector250
vector250:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $250
c01027db:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c01027e0:	e9 3c 00 00 00       	jmp    c0102821 <__alltraps>

c01027e5 <vector251>:
.globl vector251
vector251:
  pushl $0
c01027e5:	6a 00                	push   $0x0
  pushl $251
c01027e7:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c01027ec:	e9 30 00 00 00       	jmp    c0102821 <__alltraps>

c01027f1 <vector252>:
.globl vector252
vector252:
  pushl $0
c01027f1:	6a 00                	push   $0x0
  pushl $252
c01027f3:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c01027f8:	e9 24 00 00 00       	jmp    c0102821 <__alltraps>

c01027fd <vector253>:
.globl vector253
vector253:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $253
c01027ff:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102804:	e9 18 00 00 00       	jmp    c0102821 <__alltraps>

c0102809 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102809:	6a 00                	push   $0x0
  pushl $254
c010280b:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102810:	e9 0c 00 00 00       	jmp    c0102821 <__alltraps>

c0102815 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102815:	6a 00                	push   $0x0
  pushl $255
c0102817:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c010281c:	e9 00 00 00 00       	jmp    c0102821 <__alltraps>

c0102821 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102821:	1e                   	push   %ds
    pushl %es
c0102822:	06                   	push   %es
    pushl %fs
c0102823:	0f a0                	push   %fs
    pushl %gs
c0102825:	0f a8                	push   %gs
    pushal
c0102827:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102828:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c010282d:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c010282f:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102831:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102832:	e8 64 f5 ff ff       	call   c0101d9b <trap>

    # pop the pushed stack pointer
    popl %esp
c0102837:	5c                   	pop    %esp

c0102838 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102838:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102839:	0f a9                	pop    %gs
    popl %fs
c010283b:	0f a1                	pop    %fs
    popl %es
c010283d:	07                   	pop    %es
    popl %ds
c010283e:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010283f:	83 c4 08             	add    $0x8,%esp
    iret
c0102842:	cf                   	iret   

c0102843 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102843:	55                   	push   %ebp
c0102844:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102846:	8b 45 08             	mov    0x8(%ebp),%eax
c0102849:	8b 15 18 cf 11 c0    	mov    0xc011cf18,%edx
c010284f:	29 d0                	sub    %edx,%eax
c0102851:	c1 f8 02             	sar    $0x2,%eax
c0102854:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010285a:	5d                   	pop    %ebp
c010285b:	c3                   	ret    

c010285c <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010285c:	55                   	push   %ebp
c010285d:	89 e5                	mov    %esp,%ebp
c010285f:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102862:	8b 45 08             	mov    0x8(%ebp),%eax
c0102865:	89 04 24             	mov    %eax,(%esp)
c0102868:	e8 d6 ff ff ff       	call   c0102843 <page2ppn>
c010286d:	c1 e0 0c             	shl    $0xc,%eax
}
c0102870:	c9                   	leave  
c0102871:	c3                   	ret    

c0102872 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102872:	55                   	push   %ebp
c0102873:	89 e5                	mov    %esp,%ebp
c0102875:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102878:	8b 45 08             	mov    0x8(%ebp),%eax
c010287b:	c1 e8 0c             	shr    $0xc,%eax
c010287e:	89 c2                	mov    %eax,%edx
c0102880:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102885:	39 c2                	cmp    %eax,%edx
c0102887:	72 1c                	jb     c01028a5 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102889:	c7 44 24 08 90 74 10 	movl   $0xc0107490,0x8(%esp)
c0102890:	c0 
c0102891:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102898:	00 
c0102899:	c7 04 24 af 74 10 c0 	movl   $0xc01074af,(%esp)
c01028a0:	e8 49 db ff ff       	call   c01003ee <__panic>
    }
    return &pages[PPN(pa)];
c01028a5:	8b 0d 18 cf 11 c0    	mov    0xc011cf18,%ecx
c01028ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ae:	c1 e8 0c             	shr    $0xc,%eax
c01028b1:	89 c2                	mov    %eax,%edx
c01028b3:	89 d0                	mov    %edx,%eax
c01028b5:	c1 e0 02             	shl    $0x2,%eax
c01028b8:	01 d0                	add    %edx,%eax
c01028ba:	c1 e0 02             	shl    $0x2,%eax
c01028bd:	01 c8                	add    %ecx,%eax
}
c01028bf:	c9                   	leave  
c01028c0:	c3                   	ret    

c01028c1 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c01028c1:	55                   	push   %ebp
c01028c2:	89 e5                	mov    %esp,%ebp
c01028c4:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c01028c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01028ca:	89 04 24             	mov    %eax,(%esp)
c01028cd:	e8 8a ff ff ff       	call   c010285c <page2pa>
c01028d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01028d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028d8:	c1 e8 0c             	shr    $0xc,%eax
c01028db:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01028de:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c01028e3:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c01028e6:	72 23                	jb     c010290b <page2kva+0x4a>
c01028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01028eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01028ef:	c7 44 24 08 c0 74 10 	movl   $0xc01074c0,0x8(%esp)
c01028f6:	c0 
c01028f7:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01028fe:	00 
c01028ff:	c7 04 24 af 74 10 c0 	movl   $0xc01074af,(%esp)
c0102906:	e8 e3 da ff ff       	call   c01003ee <__panic>
c010290b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010290e:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102913:	c9                   	leave  
c0102914:	c3                   	ret    

c0102915 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102915:	55                   	push   %ebp
c0102916:	89 e5                	mov    %esp,%ebp
c0102918:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c010291b:	8b 45 08             	mov    0x8(%ebp),%eax
c010291e:	83 e0 01             	and    $0x1,%eax
c0102921:	85 c0                	test   %eax,%eax
c0102923:	75 1c                	jne    c0102941 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102925:	c7 44 24 08 e4 74 10 	movl   $0xc01074e4,0x8(%esp)
c010292c:	c0 
c010292d:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0102934:	00 
c0102935:	c7 04 24 af 74 10 c0 	movl   $0xc01074af,(%esp)
c010293c:	e8 ad da ff ff       	call   c01003ee <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102941:	8b 45 08             	mov    0x8(%ebp),%eax
c0102944:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102949:	89 04 24             	mov    %eax,(%esp)
c010294c:	e8 21 ff ff ff       	call   c0102872 <pa2page>
}
c0102951:	c9                   	leave  
c0102952:	c3                   	ret    

c0102953 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102953:	55                   	push   %ebp
c0102954:	89 e5                	mov    %esp,%ebp
c0102956:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102959:	8b 45 08             	mov    0x8(%ebp),%eax
c010295c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102961:	89 04 24             	mov    %eax,(%esp)
c0102964:	e8 09 ff ff ff       	call   c0102872 <pa2page>
}
c0102969:	c9                   	leave  
c010296a:	c3                   	ret    

c010296b <page_ref>:

static inline int
page_ref(struct Page *page) {
c010296b:	55                   	push   %ebp
c010296c:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010296e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102971:	8b 00                	mov    (%eax),%eax
}
c0102973:	5d                   	pop    %ebp
c0102974:	c3                   	ret    

c0102975 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102975:	55                   	push   %ebp
c0102976:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102978:	8b 45 08             	mov    0x8(%ebp),%eax
c010297b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010297e:	89 10                	mov    %edx,(%eax)
}
c0102980:	90                   	nop
c0102981:	5d                   	pop    %ebp
c0102982:	c3                   	ret    

c0102983 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102983:	55                   	push   %ebp
c0102984:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102986:	8b 45 08             	mov    0x8(%ebp),%eax
c0102989:	8b 00                	mov    (%eax),%eax
c010298b:	8d 50 01             	lea    0x1(%eax),%edx
c010298e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102991:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102993:	8b 45 08             	mov    0x8(%ebp),%eax
c0102996:	8b 00                	mov    (%eax),%eax
}
c0102998:	5d                   	pop    %ebp
c0102999:	c3                   	ret    

c010299a <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c010299a:	55                   	push   %ebp
c010299b:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010299d:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a0:	8b 00                	mov    (%eax),%eax
c01029a2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01029a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01029a8:	89 10                	mov    %edx,(%eax)
    return page->ref;
c01029aa:	8b 45 08             	mov    0x8(%ebp),%eax
c01029ad:	8b 00                	mov    (%eax),%eax
}
c01029af:	5d                   	pop    %ebp
c01029b0:	c3                   	ret    

c01029b1 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c01029b1:	55                   	push   %ebp
c01029b2:	89 e5                	mov    %esp,%ebp
c01029b4:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c01029b7:	9c                   	pushf  
c01029b8:	58                   	pop    %eax
c01029b9:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c01029bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c01029bf:	25 00 02 00 00       	and    $0x200,%eax
c01029c4:	85 c0                	test   %eax,%eax
c01029c6:	74 0c                	je     c01029d4 <__intr_save+0x23>
        intr_disable();
c01029c8:	e8 b1 ee ff ff       	call   c010187e <intr_disable>
        return 1;
c01029cd:	b8 01 00 00 00       	mov    $0x1,%eax
c01029d2:	eb 05                	jmp    c01029d9 <__intr_save+0x28>
    }
    return 0;
c01029d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01029d9:	c9                   	leave  
c01029da:	c3                   	ret    

c01029db <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c01029db:	55                   	push   %ebp
c01029dc:	89 e5                	mov    %esp,%ebp
c01029de:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c01029e1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01029e5:	74 05                	je     c01029ec <__intr_restore+0x11>
        intr_enable();
c01029e7:	e8 8b ee ff ff       	call   c0101877 <intr_enable>
    }
}
c01029ec:	90                   	nop
c01029ed:	c9                   	leave  
c01029ee:	c3                   	ret    

c01029ef <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01029ef:	55                   	push   %ebp
c01029f0:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01029f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01029f5:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01029f8:	b8 23 00 00 00       	mov    $0x23,%eax
c01029fd:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01029ff:	b8 23 00 00 00       	mov    $0x23,%eax
c0102a04:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102a06:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a0b:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102a0d:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a12:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102a14:	b8 10 00 00 00       	mov    $0x10,%eax
c0102a19:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102a1b:	ea 22 2a 10 c0 08 00 	ljmp   $0x8,$0xc0102a22
}
c0102a22:	90                   	nop
c0102a23:	5d                   	pop    %ebp
c0102a24:	c3                   	ret    

c0102a25 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102a25:	55                   	push   %ebp
c0102a26:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102a28:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a2b:	a3 a4 ce 11 c0       	mov    %eax,0xc011cea4
}
c0102a30:	90                   	nop
c0102a31:	5d                   	pop    %ebp
c0102a32:	c3                   	ret    

c0102a33 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102a33:	55                   	push   %ebp
c0102a34:	89 e5                	mov    %esp,%ebp
c0102a36:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102a39:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0102a3e:	89 04 24             	mov    %eax,(%esp)
c0102a41:	e8 df ff ff ff       	call   c0102a25 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102a46:	66 c7 05 a8 ce 11 c0 	movw   $0x10,0xc011cea8
c0102a4d:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102a4f:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0102a56:	68 00 
c0102a58:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102a5d:	0f b7 c0             	movzwl %ax,%eax
c0102a60:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0102a66:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102a6b:	c1 e8 10             	shr    $0x10,%eax
c0102a6e:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0102a73:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102a7a:	24 f0                	and    $0xf0,%al
c0102a7c:	0c 09                	or     $0x9,%al
c0102a7e:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102a83:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102a8a:	24 ef                	and    $0xef,%al
c0102a8c:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102a91:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102a98:	24 9f                	and    $0x9f,%al
c0102a9a:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102a9f:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0102aa6:	0c 80                	or     $0x80,%al
c0102aa8:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0102aad:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102ab4:	24 f0                	and    $0xf0,%al
c0102ab6:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102abb:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102ac2:	24 ef                	and    $0xef,%al
c0102ac4:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102ac9:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102ad0:	24 df                	and    $0xdf,%al
c0102ad2:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102ad7:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102ade:	0c 40                	or     $0x40,%al
c0102ae0:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102ae5:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0102aec:	24 7f                	and    $0x7f,%al
c0102aee:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0102af3:	b8 a0 ce 11 c0       	mov    $0xc011cea0,%eax
c0102af8:	c1 e8 18             	shr    $0x18,%eax
c0102afb:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102b00:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0102b07:	e8 e3 fe ff ff       	call   c01029ef <lgdt>
c0102b0c:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102b12:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102b16:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102b19:	90                   	nop
c0102b1a:	c9                   	leave  
c0102b1b:	c3                   	ret    

c0102b1c <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102b1c:	55                   	push   %ebp
c0102b1d:	89 e5                	mov    %esp,%ebp
c0102b1f:	83 ec 18             	sub    $0x18,%esp
    // pmm_manager = &default_pmm_manager;
    // cprintf("memory management: %s\n", pmm_manager->name);
    // pmm_manager->init();
    pmm_manager = &buddy_pmm_manager;
c0102b22:	c7 05 10 cf 11 c0 60 	movl   $0xc0107c60,0xc011cf10
c0102b29:	7c 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102b2c:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102b31:	8b 00                	mov    (%eax),%eax
c0102b33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102b37:	c7 04 24 10 75 10 c0 	movl   $0xc0107510,(%esp)
c0102b3e:	e8 54 d7 ff ff       	call   c0100297 <cprintf>
    pmm_manager->init();
c0102b43:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102b48:	8b 40 04             	mov    0x4(%eax),%eax
c0102b4b:	ff d0                	call   *%eax
}
c0102b4d:	90                   	nop
c0102b4e:	c9                   	leave  
c0102b4f:	c3                   	ret    

c0102b50 <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102b50:	55                   	push   %ebp
c0102b51:	89 e5                	mov    %esp,%ebp
c0102b53:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102b56:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102b5b:	8b 40 08             	mov    0x8(%eax),%eax
c0102b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102b61:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102b65:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b68:	89 14 24             	mov    %edx,(%esp)
c0102b6b:	ff d0                	call   *%eax
}
c0102b6d:	90                   	nop
c0102b6e:	c9                   	leave  
c0102b6f:	c3                   	ret    

c0102b70 <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c0102b70:	55                   	push   %ebp
c0102b71:	89 e5                	mov    %esp,%ebp
c0102b73:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0102b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0102b7d:	e8 2f fe ff ff       	call   c01029b1 <__intr_save>
c0102b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0102b85:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102b8a:	8b 40 0c             	mov    0xc(%eax),%eax
c0102b8d:	8b 55 08             	mov    0x8(%ebp),%edx
c0102b90:	89 14 24             	mov    %edx,(%esp)
c0102b93:	ff d0                	call   *%eax
c0102b95:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0102b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102b9b:	89 04 24             	mov    %eax,(%esp)
c0102b9e:	e8 38 fe ff ff       	call   c01029db <__intr_restore>
    return page;
c0102ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102ba6:	c9                   	leave  
c0102ba7:	c3                   	ret    

c0102ba8 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0102ba8:	55                   	push   %ebp
c0102ba9:	89 e5                	mov    %esp,%ebp
c0102bab:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0102bae:	e8 fe fd ff ff       	call   c01029b1 <__intr_save>
c0102bb3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0102bb6:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102bbb:	8b 40 10             	mov    0x10(%eax),%eax
c0102bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bc1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0102bc5:	8b 55 08             	mov    0x8(%ebp),%edx
c0102bc8:	89 14 24             	mov    %edx,(%esp)
c0102bcb:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c0102bcd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bd0:	89 04 24             	mov    %eax,(%esp)
c0102bd3:	e8 03 fe ff ff       	call   c01029db <__intr_restore>
}
c0102bd8:	90                   	nop
c0102bd9:	c9                   	leave  
c0102bda:	c3                   	ret    

c0102bdb <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0102bdb:	55                   	push   %ebp
c0102bdc:	89 e5                	mov    %esp,%ebp
c0102bde:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c0102be1:	e8 cb fd ff ff       	call   c01029b1 <__intr_save>
c0102be6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0102be9:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0102bee:	8b 40 14             	mov    0x14(%eax),%eax
c0102bf1:	ff d0                	call   *%eax
c0102bf3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0102bf6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102bf9:	89 04 24             	mov    %eax,(%esp)
c0102bfc:	e8 da fd ff ff       	call   c01029db <__intr_restore>
    return ret;
c0102c01:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0102c04:	c9                   	leave  
c0102c05:	c3                   	ret    

c0102c06 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c0102c06:	55                   	push   %ebp
c0102c07:	89 e5                	mov    %esp,%ebp
c0102c09:	57                   	push   %edi
c0102c0a:	56                   	push   %esi
c0102c0b:	53                   	push   %ebx
c0102c0c:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0102c12:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c0102c19:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0102c20:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0102c27:	c7 04 24 27 75 10 c0 	movl   $0xc0107527,(%esp)
c0102c2e:	e8 64 d6 ff ff       	call   c0100297 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102c33:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102c3a:	e9 22 01 00 00       	jmp    c0102d61 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102c3f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c42:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c45:	89 d0                	mov    %edx,%eax
c0102c47:	c1 e0 02             	shl    $0x2,%eax
c0102c4a:	01 d0                	add    %edx,%eax
c0102c4c:	c1 e0 02             	shl    $0x2,%eax
c0102c4f:	01 c8                	add    %ecx,%eax
c0102c51:	8b 50 08             	mov    0x8(%eax),%edx
c0102c54:	8b 40 04             	mov    0x4(%eax),%eax
c0102c57:	89 45 b8             	mov    %eax,-0x48(%ebp)
c0102c5a:	89 55 bc             	mov    %edx,-0x44(%ebp)
c0102c5d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c60:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c63:	89 d0                	mov    %edx,%eax
c0102c65:	c1 e0 02             	shl    $0x2,%eax
c0102c68:	01 d0                	add    %edx,%eax
c0102c6a:	c1 e0 02             	shl    $0x2,%eax
c0102c6d:	01 c8                	add    %ecx,%eax
c0102c6f:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102c72:	8b 58 10             	mov    0x10(%eax),%ebx
c0102c75:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102c78:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102c7b:	01 c8                	add    %ecx,%eax
c0102c7d:	11 da                	adc    %ebx,%edx
c0102c7f:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0102c82:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0102c85:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102c88:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c8b:	89 d0                	mov    %edx,%eax
c0102c8d:	c1 e0 02             	shl    $0x2,%eax
c0102c90:	01 d0                	add    %edx,%eax
c0102c92:	c1 e0 02             	shl    $0x2,%eax
c0102c95:	01 c8                	add    %ecx,%eax
c0102c97:	83 c0 14             	add    $0x14,%eax
c0102c9a:	8b 00                	mov    (%eax),%eax
c0102c9c:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0102c9f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102ca2:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102ca5:	83 c0 ff             	add    $0xffffffff,%eax
c0102ca8:	83 d2 ff             	adc    $0xffffffff,%edx
c0102cab:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c0102cb1:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0102cb7:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102cba:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102cbd:	89 d0                	mov    %edx,%eax
c0102cbf:	c1 e0 02             	shl    $0x2,%eax
c0102cc2:	01 d0                	add    %edx,%eax
c0102cc4:	c1 e0 02             	shl    $0x2,%eax
c0102cc7:	01 c8                	add    %ecx,%eax
c0102cc9:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ccc:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ccf:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0102cd2:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0102cd6:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0102cdc:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c0102ce2:	89 44 24 14          	mov    %eax,0x14(%esp)
c0102ce6:	89 54 24 18          	mov    %edx,0x18(%esp)
c0102cea:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102ced:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102cf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102cf4:	89 54 24 10          	mov    %edx,0x10(%esp)
c0102cf8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0102cfc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c0102d00:	c7 04 24 34 75 10 c0 	movl   $0xc0107534,(%esp)
c0102d07:	e8 8b d5 ff ff       	call   c0100297 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c0102d0c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102d0f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d12:	89 d0                	mov    %edx,%eax
c0102d14:	c1 e0 02             	shl    $0x2,%eax
c0102d17:	01 d0                	add    %edx,%eax
c0102d19:	c1 e0 02             	shl    $0x2,%eax
c0102d1c:	01 c8                	add    %ecx,%eax
c0102d1e:	83 c0 14             	add    $0x14,%eax
c0102d21:	8b 00                	mov    (%eax),%eax
c0102d23:	83 f8 01             	cmp    $0x1,%eax
c0102d26:	75 36                	jne    c0102d5e <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0102d28:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d2b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d2e:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d31:	77 2b                	ja     c0102d5e <page_init+0x158>
c0102d33:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0102d36:	72 05                	jb     c0102d3d <page_init+0x137>
c0102d38:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0102d3b:	73 21                	jae    c0102d5e <page_init+0x158>
c0102d3d:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d41:	77 1b                	ja     c0102d5e <page_init+0x158>
c0102d43:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0102d47:	72 09                	jb     c0102d52 <page_init+0x14c>
c0102d49:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0102d50:	77 0c                	ja     c0102d5e <page_init+0x158>
                maxpa = end;
c0102d52:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0102d55:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102d58:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102d5b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0102d5e:	ff 45 dc             	incl   -0x24(%ebp)
c0102d61:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102d64:	8b 00                	mov    (%eax),%eax
c0102d66:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102d69:	0f 8f d0 fe ff ff    	jg     c0102c3f <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0102d6f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d73:	72 1d                	jb     c0102d92 <page_init+0x18c>
c0102d75:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102d79:	77 09                	ja     c0102d84 <page_init+0x17e>
c0102d7b:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0102d82:	76 0e                	jbe    c0102d92 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0102d84:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0102d8b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0102d92:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d95:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0102d98:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102d9c:	c1 ea 0c             	shr    $0xc,%edx
c0102d9f:	a3 80 ce 11 c0       	mov    %eax,0xc011ce80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0102da4:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0102dab:	b8 60 39 2a c0       	mov    $0xc02a3960,%eax
c0102db0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102db3:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0102db6:	01 d0                	add    %edx,%eax
c0102db8:	89 45 a8             	mov    %eax,-0x58(%ebp)
c0102dbb:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102dbe:	ba 00 00 00 00       	mov    $0x0,%edx
c0102dc3:	f7 75 ac             	divl   -0x54(%ebp)
c0102dc6:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0102dc9:	29 d0                	sub    %edx,%eax
c0102dcb:	a3 18 cf 11 c0       	mov    %eax,0xc011cf18

    for (i = 0; i < npage; i ++) {
c0102dd0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102dd7:	eb 2e                	jmp    c0102e07 <page_init+0x201>
        SetPageReserved(pages + i);
c0102dd9:	8b 0d 18 cf 11 c0    	mov    0xc011cf18,%ecx
c0102ddf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102de2:	89 d0                	mov    %edx,%eax
c0102de4:	c1 e0 02             	shl    $0x2,%eax
c0102de7:	01 d0                	add    %edx,%eax
c0102de9:	c1 e0 02             	shl    $0x2,%eax
c0102dec:	01 c8                	add    %ecx,%eax
c0102dee:	83 c0 04             	add    $0x4,%eax
c0102df1:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c0102df8:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dfb:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0102dfe:	8b 55 90             	mov    -0x70(%ebp),%edx
c0102e01:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c0102e04:	ff 45 dc             	incl   -0x24(%ebp)
c0102e07:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e0a:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0102e0f:	39 c2                	cmp    %eax,%edx
c0102e11:	72 c6                	jb     c0102dd9 <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0102e13:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c0102e19:	89 d0                	mov    %edx,%eax
c0102e1b:	c1 e0 02             	shl    $0x2,%eax
c0102e1e:	01 d0                	add    %edx,%eax
c0102e20:	c1 e0 02             	shl    $0x2,%eax
c0102e23:	89 c2                	mov    %eax,%edx
c0102e25:	a1 18 cf 11 c0       	mov    0xc011cf18,%eax
c0102e2a:	01 d0                	add    %edx,%eax
c0102e2c:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0102e2f:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0102e36:	77 23                	ja     c0102e5b <page_init+0x255>
c0102e38:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102e3f:	c7 44 24 08 64 75 10 	movl   $0xc0107564,0x8(%esp)
c0102e46:	c0 
c0102e47:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c0102e4e:	00 
c0102e4f:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0102e56:	e8 93 d5 ff ff       	call   c01003ee <__panic>
c0102e5b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0102e5e:	05 00 00 00 40       	add    $0x40000000,%eax
c0102e63:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0102e66:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0102e6d:	e9 61 01 00 00       	jmp    c0102fd3 <page_init+0x3cd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0102e72:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e75:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e78:	89 d0                	mov    %edx,%eax
c0102e7a:	c1 e0 02             	shl    $0x2,%eax
c0102e7d:	01 d0                	add    %edx,%eax
c0102e7f:	c1 e0 02             	shl    $0x2,%eax
c0102e82:	01 c8                	add    %ecx,%eax
c0102e84:	8b 50 08             	mov    0x8(%eax),%edx
c0102e87:	8b 40 04             	mov    0x4(%eax),%eax
c0102e8a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102e8d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102e90:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102e93:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102e96:	89 d0                	mov    %edx,%eax
c0102e98:	c1 e0 02             	shl    $0x2,%eax
c0102e9b:	01 d0                	add    %edx,%eax
c0102e9d:	c1 e0 02             	shl    $0x2,%eax
c0102ea0:	01 c8                	add    %ecx,%eax
c0102ea2:	8b 48 0c             	mov    0xc(%eax),%ecx
c0102ea5:	8b 58 10             	mov    0x10(%eax),%ebx
c0102ea8:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102eab:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102eae:	01 c8                	add    %ecx,%eax
c0102eb0:	11 da                	adc    %ebx,%edx
c0102eb2:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102eb5:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0102eb8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0102ebb:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102ebe:	89 d0                	mov    %edx,%eax
c0102ec0:	c1 e0 02             	shl    $0x2,%eax
c0102ec3:	01 d0                	add    %edx,%eax
c0102ec5:	c1 e0 02             	shl    $0x2,%eax
c0102ec8:	01 c8                	add    %ecx,%eax
c0102eca:	83 c0 14             	add    $0x14,%eax
c0102ecd:	8b 00                	mov    (%eax),%eax
c0102ecf:	83 f8 01             	cmp    $0x1,%eax
c0102ed2:	0f 85 f8 00 00 00    	jne    c0102fd0 <page_init+0x3ca>
            if (begin < freemem) {
c0102ed8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102edb:	ba 00 00 00 00       	mov    $0x0,%edx
c0102ee0:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102ee3:	72 17                	jb     c0102efc <page_init+0x2f6>
c0102ee5:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0102ee8:	77 05                	ja     c0102eef <page_init+0x2e9>
c0102eea:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0102eed:	76 0d                	jbe    c0102efc <page_init+0x2f6>
                begin = freemem;
c0102eef:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102ef2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102ef5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c0102efc:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f00:	72 1d                	jb     c0102f1f <page_init+0x319>
c0102f02:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0102f06:	77 09                	ja     c0102f11 <page_init+0x30b>
c0102f08:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c0102f0f:	76 0e                	jbe    c0102f1f <page_init+0x319>
                end = KMEMSIZE;
c0102f11:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0102f18:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0102f1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f22:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f25:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f28:	0f 87 a2 00 00 00    	ja     c0102fd0 <page_init+0x3ca>
c0102f2e:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f31:	72 09                	jb     c0102f3c <page_init+0x336>
c0102f33:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102f36:	0f 83 94 00 00 00    	jae    c0102fd0 <page_init+0x3ca>
                begin = ROUNDUP(begin, PGSIZE);
c0102f3c:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0102f43:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102f46:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0102f49:	01 d0                	add    %edx,%eax
c0102f4b:	48                   	dec    %eax
c0102f4c:	89 45 98             	mov    %eax,-0x68(%ebp)
c0102f4f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f52:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f57:	f7 75 9c             	divl   -0x64(%ebp)
c0102f5a:	8b 45 98             	mov    -0x68(%ebp),%eax
c0102f5d:	29 d0                	sub    %edx,%eax
c0102f5f:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f64:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0102f67:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0102f6a:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f6d:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0102f70:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0102f73:	ba 00 00 00 00       	mov    $0x0,%edx
c0102f78:	89 c3                	mov    %eax,%ebx
c0102f7a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0102f80:	89 de                	mov    %ebx,%esi
c0102f82:	89 d0                	mov    %edx,%eax
c0102f84:	83 e0 00             	and    $0x0,%eax
c0102f87:	89 c7                	mov    %eax,%edi
c0102f89:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0102f8c:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0102f8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102f92:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102f95:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f98:	77 36                	ja     c0102fd0 <page_init+0x3ca>
c0102f9a:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0102f9d:	72 05                	jb     c0102fa4 <page_init+0x39e>
c0102f9f:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0102fa2:	73 2c                	jae    c0102fd0 <page_init+0x3ca>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0102fa4:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102fa7:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102faa:	2b 45 d0             	sub    -0x30(%ebp),%eax
c0102fad:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0102fb0:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0102fb4:	c1 ea 0c             	shr    $0xc,%edx
c0102fb7:	89 c3                	mov    %eax,%ebx
c0102fb9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102fbc:	89 04 24             	mov    %eax,(%esp)
c0102fbf:	e8 ae f8 ff ff       	call   c0102872 <pa2page>
c0102fc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0102fc8:	89 04 24             	mov    %eax,(%esp)
c0102fcb:	e8 80 fb ff ff       	call   c0102b50 <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c0102fd0:	ff 45 dc             	incl   -0x24(%ebp)
c0102fd3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102fd6:	8b 00                	mov    (%eax),%eax
c0102fd8:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0102fdb:	0f 8f 91 fe ff ff    	jg     c0102e72 <page_init+0x26c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c0102fe1:	90                   	nop
c0102fe2:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0102fe8:	5b                   	pop    %ebx
c0102fe9:	5e                   	pop    %esi
c0102fea:	5f                   	pop    %edi
c0102feb:	5d                   	pop    %ebp
c0102fec:	c3                   	ret    

c0102fed <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c0102fed:	55                   	push   %ebp
c0102fee:	89 e5                	mov    %esp,%ebp
c0102ff0:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c0102ff3:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102ff6:	33 45 14             	xor    0x14(%ebp),%eax
c0102ff9:	25 ff 0f 00 00       	and    $0xfff,%eax
c0102ffe:	85 c0                	test   %eax,%eax
c0103000:	74 24                	je     c0103026 <boot_map_segment+0x39>
c0103002:	c7 44 24 0c 96 75 10 	movl   $0xc0107596,0xc(%esp)
c0103009:	c0 
c010300a:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103011:	c0 
c0103012:	c7 44 24 04 fe 00 00 	movl   $0xfe,0x4(%esp)
c0103019:	00 
c010301a:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103021:	e8 c8 d3 ff ff       	call   c01003ee <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103026:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010302d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103030:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103035:	89 c2                	mov    %eax,%edx
c0103037:	8b 45 10             	mov    0x10(%ebp),%eax
c010303a:	01 c2                	add    %eax,%edx
c010303c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010303f:	01 d0                	add    %edx,%eax
c0103041:	48                   	dec    %eax
c0103042:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103045:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103048:	ba 00 00 00 00       	mov    $0x0,%edx
c010304d:	f7 75 f0             	divl   -0x10(%ebp)
c0103050:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103053:	29 d0                	sub    %edx,%eax
c0103055:	c1 e8 0c             	shr    $0xc,%eax
c0103058:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010305b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010305e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103061:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103064:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103069:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010306c:	8b 45 14             	mov    0x14(%ebp),%eax
c010306f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103072:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103075:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010307a:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010307d:	eb 68                	jmp    c01030e7 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010307f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103086:	00 
c0103087:	8b 45 0c             	mov    0xc(%ebp),%eax
c010308a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010308e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103091:	89 04 24             	mov    %eax,(%esp)
c0103094:	e8 81 01 00 00       	call   c010321a <get_pte>
c0103099:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010309c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01030a0:	75 24                	jne    c01030c6 <boot_map_segment+0xd9>
c01030a2:	c7 44 24 0c c2 75 10 	movl   $0xc01075c2,0xc(%esp)
c01030a9:	c0 
c01030aa:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01030b1:	c0 
c01030b2:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c01030b9:	00 
c01030ba:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01030c1:	e8 28 d3 ff ff       	call   c01003ee <__panic>
        *ptep = pa | PTE_P | perm;
c01030c6:	8b 45 14             	mov    0x14(%ebp),%eax
c01030c9:	0b 45 18             	or     0x18(%ebp),%eax
c01030cc:	83 c8 01             	or     $0x1,%eax
c01030cf:	89 c2                	mov    %eax,%edx
c01030d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01030d4:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01030d6:	ff 4d f4             	decl   -0xc(%ebp)
c01030d9:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01030e0:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01030e7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01030eb:	75 92                	jne    c010307f <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01030ed:	90                   	nop
c01030ee:	c9                   	leave  
c01030ef:	c3                   	ret    

c01030f0 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01030f0:	55                   	push   %ebp
c01030f1:	89 e5                	mov    %esp,%ebp
c01030f3:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01030f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01030fd:	e8 6e fa ff ff       	call   c0102b70 <alloc_pages>
c0103102:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103105:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103109:	75 1c                	jne    c0103127 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c010310b:	c7 44 24 08 cf 75 10 	movl   $0xc01075cf,0x8(%esp)
c0103112:	c0 
c0103113:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c010311a:	00 
c010311b:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103122:	e8 c7 d2 ff ff       	call   c01003ee <__panic>
    }
    return page2kva(p);
c0103127:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010312a:	89 04 24             	mov    %eax,(%esp)
c010312d:	e8 8f f7 ff ff       	call   c01028c1 <page2kva>
}
c0103132:	c9                   	leave  
c0103133:	c3                   	ret    

c0103134 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103134:	55                   	push   %ebp
c0103135:	89 e5                	mov    %esp,%ebp
c0103137:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c010313a:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010313f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103142:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103149:	77 23                	ja     c010316e <pmm_init+0x3a>
c010314b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010314e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103152:	c7 44 24 08 64 75 10 	movl   $0xc0107564,0x8(%esp)
c0103159:	c0 
c010315a:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c0103161:	00 
c0103162:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103169:	e8 80 d2 ff ff       	call   c01003ee <__panic>
c010316e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103171:	05 00 00 00 40       	add    $0x40000000,%eax
c0103176:	a3 14 cf 11 c0       	mov    %eax,0xc011cf14
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010317b:	e8 9c f9 ff ff       	call   c0102b1c <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103180:	e8 81 fa ff ff       	call   c0102c06 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103185:	e8 de 03 00 00       	call   c0103568 <check_alloc_page>

    check_pgdir();
c010318a:	e8 f8 03 00 00       	call   c0103587 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010318f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103194:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c010319a:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010319f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01031a2:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01031a9:	77 23                	ja     c01031ce <pmm_init+0x9a>
c01031ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031ae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01031b2:	c7 44 24 08 64 75 10 	movl   $0xc0107564,0x8(%esp)
c01031b9:	c0 
c01031ba:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
c01031c1:	00 
c01031c2:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01031c9:	e8 20 d2 ff ff       	call   c01003ee <__panic>
c01031ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01031d1:	05 00 00 00 40       	add    $0x40000000,%eax
c01031d6:	83 c8 03             	or     $0x3,%eax
c01031d9:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01031db:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01031e0:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01031e7:	00 
c01031e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01031ef:	00 
c01031f0:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01031f7:	38 
c01031f8:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01031ff:	c0 
c0103200:	89 04 24             	mov    %eax,(%esp)
c0103203:	e8 e5 fd ff ff       	call   c0102fed <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103208:	e8 26 f8 ff ff       	call   c0102a33 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c010320d:	e8 11 0a 00 00       	call   c0103c23 <check_boot_pgdir>

    print_pgdir();
c0103212:	e8 8a 0e 00 00       	call   c01040a1 <print_pgdir>

}
c0103217:	90                   	nop
c0103218:	c9                   	leave  
c0103219:	c3                   	ret    

c010321a <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c010321a:	55                   	push   %ebp
c010321b:	89 e5                	mov    %esp,%ebp
c010321d:	83 ec 38             	sub    $0x38,%esp
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    // 首先找到页目录项，尝试获得页表
    pde_t *pdep = &pgdir[PDX(la)];
c0103220:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103223:	c1 e8 16             	shr    $0x16,%eax
c0103226:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010322d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103230:	01 d0                	add    %edx,%eax
c0103232:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 检查这个页目录项是否存在，存在则直接返回找到的页目录项
    if (!(*pdep & PTE_P)) {
c0103235:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103238:	8b 00                	mov    (%eax),%eax
c010323a:	83 e0 01             	and    $0x1,%eax
c010323d:	85 c0                	test   %eax,%eax
c010323f:	0f 85 af 00 00 00    	jne    c01032f4 <get_pte+0xda>
        struct Page *page;
        // 页目录项不存在，且参数不要求创建新的页表，直接返回NULL
        if (!create || (page = alloc_page()) == NULL) {
c0103245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103249:	74 15                	je     c0103260 <get_pte+0x46>
c010324b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103252:	e8 19 f9 ff ff       	call   c0102b70 <alloc_pages>
c0103257:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010325a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010325e:	75 0a                	jne    c010326a <get_pte+0x50>
            return NULL;
c0103260:	b8 00 00 00 00       	mov    $0x0,%eax
c0103265:	e9 e7 00 00 00       	jmp    c0103351 <get_pte+0x137>
        }
        // 页目录项不存在，且参数要求创建新的页表
        // 设置物理页被引用一次
        set_page_ref(page, 1);
c010326a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103271:	00 
c0103272:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103275:	89 04 24             	mov    %eax,(%esp)
c0103278:	e8 f8 f6 ff ff       	call   c0102975 <set_page_ref>
        // 获得物理页的线性物理地址
        uintptr_t pa = page2pa(page);
c010327d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103280:	89 04 24             	mov    %eax,(%esp)
c0103283:	e8 d4 f5 ff ff       	call   c010285c <page2pa>
c0103288:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将物理地址转换成虚拟地址后，用memset函数清除页目录进行初始化
        memset(KADDR(pa), 0, PGSIZE);
c010328b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010328e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103291:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103294:	c1 e8 0c             	shr    $0xc,%eax
c0103297:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010329a:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c010329f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c01032a2:	72 23                	jb     c01032c7 <get_pte+0xad>
c01032a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01032ab:	c7 44 24 08 c0 74 10 	movl   $0xc01074c0,0x8(%esp)
c01032b2:	c0 
c01032b3:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
c01032ba:	00 
c01032bb:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01032c2:	e8 27 d1 ff ff       	call   c01003ee <__panic>
c01032c7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01032ca:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01032cf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01032d6:	00 
c01032d7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01032de:	00 
c01032df:	89 04 24             	mov    %eax,(%esp)
c01032e2:	e8 75 32 00 00       	call   c010655c <memset>
        // 设置页目录项的权限
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c01032e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01032ea:	83 c8 07             	or     $0x7,%eax
c01032ed:	89 c2                	mov    %eax,%edx
c01032ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f2:	89 10                	mov    %edx,(%eax)
    }
    // 返回虚拟地址la对应的页表项入口地址
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01032f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f7:	8b 00                	mov    (%eax),%eax
c01032f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01032fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103301:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103304:	c1 e8 0c             	shr    $0xc,%eax
c0103307:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010330a:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c010330f:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103312:	72 23                	jb     c0103337 <get_pte+0x11d>
c0103314:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103317:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010331b:	c7 44 24 08 c0 74 10 	movl   $0xc01074c0,0x8(%esp)
c0103322:	c0 
c0103323:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c010332a:	00 
c010332b:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103332:	e8 b7 d0 ff ff       	call   c01003ee <__panic>
c0103337:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010333a:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010333f:	89 c2                	mov    %eax,%edx
c0103341:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103344:	c1 e8 0c             	shr    $0xc,%eax
c0103347:	25 ff 03 00 00       	and    $0x3ff,%eax
c010334c:	c1 e0 02             	shl    $0x2,%eax
c010334f:	01 d0                	add    %edx,%eax
}
c0103351:	c9                   	leave  
c0103352:	c3                   	ret    

c0103353 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103353:	55                   	push   %ebp
c0103354:	89 e5                	mov    %esp,%ebp
c0103356:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103359:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103360:	00 
c0103361:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103364:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103368:	8b 45 08             	mov    0x8(%ebp),%eax
c010336b:	89 04 24             	mov    %eax,(%esp)
c010336e:	e8 a7 fe ff ff       	call   c010321a <get_pte>
c0103373:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103376:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010337a:	74 08                	je     c0103384 <get_page+0x31>
        *ptep_store = ptep;
c010337c:	8b 45 10             	mov    0x10(%ebp),%eax
c010337f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103382:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103384:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103388:	74 1b                	je     c01033a5 <get_page+0x52>
c010338a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010338d:	8b 00                	mov    (%eax),%eax
c010338f:	83 e0 01             	and    $0x1,%eax
c0103392:	85 c0                	test   %eax,%eax
c0103394:	74 0f                	je     c01033a5 <get_page+0x52>
        return pte2page(*ptep);
c0103396:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103399:	8b 00                	mov    (%eax),%eax
c010339b:	89 04 24             	mov    %eax,(%esp)
c010339e:	e8 72 f5 ff ff       	call   c0102915 <pte2page>
c01033a3:	eb 05                	jmp    c01033aa <get_page+0x57>
    }
    return NULL;
c01033a5:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01033aa:	c9                   	leave  
c01033ab:	c3                   	ret    

c01033ac <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01033ac:	55                   	push   %ebp
c01033ad:	89 e5                	mov    %esp,%ebp
c01033af:	83 ec 28             	sub    $0x28,%esp
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    // 检查这个页目录项是否存在
    if (*ptep & PTE_P) {
c01033b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01033b5:	8b 00                	mov    (%eax),%eax
c01033b7:	83 e0 01             	and    $0x1,%eax
c01033ba:	85 c0                	test   %eax,%eax
c01033bc:	74 4d                	je     c010340b <page_remove_pte+0x5f>
        // 找到这个页目录项对应的页
        struct Page *page = pte2page(*ptep);
c01033be:	8b 45 10             	mov    0x10(%ebp),%eax
c01033c1:	8b 00                	mov    (%eax),%eax
c01033c3:	89 04 24             	mov    %eax,(%esp)
c01033c6:	e8 4a f5 ff ff       	call   c0102915 <pte2page>
c01033cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 将这个页的引用数减一
        if (page_ref_dec(page) == 0) {
c01033ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033d1:	89 04 24             	mov    %eax,(%esp)
c01033d4:	e8 c1 f5 ff ff       	call   c010299a <page_ref_dec>
c01033d9:	85 c0                	test   %eax,%eax
c01033db:	75 13                	jne    c01033f0 <page_remove_pte+0x44>
        // 如果这个页的引用数为0，那么释放此页
            free_page(page);
c01033dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033e4:	00 
c01033e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01033e8:	89 04 24             	mov    %eax,(%esp)
c01033eb:	e8 b8 f7 ff ff       	call   c0102ba8 <free_pages>
        }
        // 清除页目录项
        *ptep = 0;
c01033f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01033f3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 当修改的页表正在使用时，那么无效
        tlb_invalidate(pgdir, la);
c01033f9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01033fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103400:	8b 45 08             	mov    0x8(%ebp),%eax
c0103403:	89 04 24             	mov    %eax,(%esp)
c0103406:	e8 01 01 00 00       	call   c010350c <tlb_invalidate>
    }
}
c010340b:	90                   	nop
c010340c:	c9                   	leave  
c010340d:	c3                   	ret    

c010340e <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c010340e:	55                   	push   %ebp
c010340f:	89 e5                	mov    %esp,%ebp
c0103411:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103414:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010341b:	00 
c010341c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010341f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103423:	8b 45 08             	mov    0x8(%ebp),%eax
c0103426:	89 04 24             	mov    %eax,(%esp)
c0103429:	e8 ec fd ff ff       	call   c010321a <get_pte>
c010342e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0103431:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103435:	74 19                	je     c0103450 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103437:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010343a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010343e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103441:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103445:	8b 45 08             	mov    0x8(%ebp),%eax
c0103448:	89 04 24             	mov    %eax,(%esp)
c010344b:	e8 5c ff ff ff       	call   c01033ac <page_remove_pte>
    }
}
c0103450:	90                   	nop
c0103451:	c9                   	leave  
c0103452:	c3                   	ret    

c0103453 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103453:	55                   	push   %ebp
c0103454:	89 e5                	mov    %esp,%ebp
c0103456:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103459:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103460:	00 
c0103461:	8b 45 10             	mov    0x10(%ebp),%eax
c0103464:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103468:	8b 45 08             	mov    0x8(%ebp),%eax
c010346b:	89 04 24             	mov    %eax,(%esp)
c010346e:	e8 a7 fd ff ff       	call   c010321a <get_pte>
c0103473:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103476:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010347a:	75 0a                	jne    c0103486 <page_insert+0x33>
        return -E_NO_MEM;
c010347c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103481:	e9 84 00 00 00       	jmp    c010350a <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103486:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103489:	89 04 24             	mov    %eax,(%esp)
c010348c:	e8 f2 f4 ff ff       	call   c0102983 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103491:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103494:	8b 00                	mov    (%eax),%eax
c0103496:	83 e0 01             	and    $0x1,%eax
c0103499:	85 c0                	test   %eax,%eax
c010349b:	74 3e                	je     c01034db <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010349d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034a0:	8b 00                	mov    (%eax),%eax
c01034a2:	89 04 24             	mov    %eax,(%esp)
c01034a5:	e8 6b f4 ff ff       	call   c0102915 <pte2page>
c01034aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01034ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01034b0:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01034b3:	75 0d                	jne    c01034c2 <page_insert+0x6f>
            page_ref_dec(page);
c01034b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034b8:	89 04 24             	mov    %eax,(%esp)
c01034bb:	e8 da f4 ff ff       	call   c010299a <page_ref_dec>
c01034c0:	eb 19                	jmp    c01034db <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01034c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034c5:	89 44 24 08          	mov    %eax,0x8(%esp)
c01034c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01034cc:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034d0:	8b 45 08             	mov    0x8(%ebp),%eax
c01034d3:	89 04 24             	mov    %eax,(%esp)
c01034d6:	e8 d1 fe ff ff       	call   c01033ac <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01034db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034de:	89 04 24             	mov    %eax,(%esp)
c01034e1:	e8 76 f3 ff ff       	call   c010285c <page2pa>
c01034e6:	0b 45 14             	or     0x14(%ebp),%eax
c01034e9:	83 c8 01             	or     $0x1,%eax
c01034ec:	89 c2                	mov    %eax,%edx
c01034ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01034f1:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01034f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01034f6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01034fd:	89 04 24             	mov    %eax,(%esp)
c0103500:	e8 07 00 00 00       	call   c010350c <tlb_invalidate>
    return 0;
c0103505:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010350a:	c9                   	leave  
c010350b:	c3                   	ret    

c010350c <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c010350c:	55                   	push   %ebp
c010350d:	89 e5                	mov    %esp,%ebp
c010350f:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103512:	0f 20 d8             	mov    %cr3,%eax
c0103515:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0103518:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c010351b:	8b 45 08             	mov    0x8(%ebp),%eax
c010351e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103521:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103528:	77 23                	ja     c010354d <tlb_invalidate+0x41>
c010352a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010352d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103531:	c7 44 24 08 64 75 10 	movl   $0xc0107564,0x8(%esp)
c0103538:	c0 
c0103539:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
c0103540:	00 
c0103541:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103548:	e8 a1 ce ff ff       	call   c01003ee <__panic>
c010354d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103550:	05 00 00 00 40       	add    $0x40000000,%eax
c0103555:	39 c2                	cmp    %eax,%edx
c0103557:	75 0c                	jne    c0103565 <tlb_invalidate+0x59>
        invlpg((void *)la);
c0103559:	8b 45 0c             	mov    0xc(%ebp),%eax
c010355c:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c010355f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103562:	0f 01 38             	invlpg (%eax)
    }
}
c0103565:	90                   	nop
c0103566:	c9                   	leave  
c0103567:	c3                   	ret    

c0103568 <check_alloc_page>:

static void
check_alloc_page(void) {
c0103568:	55                   	push   %ebp
c0103569:	89 e5                	mov    %esp,%ebp
c010356b:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010356e:	a1 10 cf 11 c0       	mov    0xc011cf10,%eax
c0103573:	8b 40 18             	mov    0x18(%eax),%eax
c0103576:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103578:	c7 04 24 e8 75 10 c0 	movl   $0xc01075e8,(%esp)
c010357f:	e8 13 cd ff ff       	call   c0100297 <cprintf>
}
c0103584:	90                   	nop
c0103585:	c9                   	leave  
c0103586:	c3                   	ret    

c0103587 <check_pgdir>:

static void
check_pgdir(void) {
c0103587:	55                   	push   %ebp
c0103588:	89 e5                	mov    %esp,%ebp
c010358a:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c010358d:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103592:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103597:	76 24                	jbe    c01035bd <check_pgdir+0x36>
c0103599:	c7 44 24 0c 07 76 10 	movl   $0xc0107607,0xc(%esp)
c01035a0:	c0 
c01035a1:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01035a8:	c0 
c01035a9:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c01035b0:	00 
c01035b1:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01035b8:	e8 31 ce ff ff       	call   c01003ee <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c01035bd:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01035c2:	85 c0                	test   %eax,%eax
c01035c4:	74 0e                	je     c01035d4 <check_pgdir+0x4d>
c01035c6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01035cb:	25 ff 0f 00 00       	and    $0xfff,%eax
c01035d0:	85 c0                	test   %eax,%eax
c01035d2:	74 24                	je     c01035f8 <check_pgdir+0x71>
c01035d4:	c7 44 24 0c 24 76 10 	movl   $0xc0107624,0xc(%esp)
c01035db:	c0 
c01035dc:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01035e3:	c0 
c01035e4:	c7 44 24 04 f8 01 00 	movl   $0x1f8,0x4(%esp)
c01035eb:	00 
c01035ec:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01035f3:	e8 f6 cd ff ff       	call   c01003ee <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01035f8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01035fd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103604:	00 
c0103605:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010360c:	00 
c010360d:	89 04 24             	mov    %eax,(%esp)
c0103610:	e8 3e fd ff ff       	call   c0103353 <get_page>
c0103615:	85 c0                	test   %eax,%eax
c0103617:	74 24                	je     c010363d <check_pgdir+0xb6>
c0103619:	c7 44 24 0c 5c 76 10 	movl   $0xc010765c,0xc(%esp)
c0103620:	c0 
c0103621:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103628:	c0 
c0103629:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103630:	00 
c0103631:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103638:	e8 b1 cd ff ff       	call   c01003ee <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c010363d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103644:	e8 27 f5 ff ff       	call   c0102b70 <alloc_pages>
c0103649:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c010364c:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103651:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103658:	00 
c0103659:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103660:	00 
c0103661:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103664:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103668:	89 04 24             	mov    %eax,(%esp)
c010366b:	e8 e3 fd ff ff       	call   c0103453 <page_insert>
c0103670:	85 c0                	test   %eax,%eax
c0103672:	74 24                	je     c0103698 <check_pgdir+0x111>
c0103674:	c7 44 24 0c 84 76 10 	movl   $0xc0107684,0xc(%esp)
c010367b:	c0 
c010367c:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103683:	c0 
c0103684:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c010368b:	00 
c010368c:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103693:	e8 56 cd ff ff       	call   c01003ee <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103698:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010369d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01036a4:	00 
c01036a5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01036ac:	00 
c01036ad:	89 04 24             	mov    %eax,(%esp)
c01036b0:	e8 65 fb ff ff       	call   c010321a <get_pte>
c01036b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01036bc:	75 24                	jne    c01036e2 <check_pgdir+0x15b>
c01036be:	c7 44 24 0c b0 76 10 	movl   $0xc01076b0,0xc(%esp)
c01036c5:	c0 
c01036c6:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01036cd:	c0 
c01036ce:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c01036d5:	00 
c01036d6:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01036dd:	e8 0c cd ff ff       	call   c01003ee <__panic>
    assert(pte2page(*ptep) == p1);
c01036e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036e5:	8b 00                	mov    (%eax),%eax
c01036e7:	89 04 24             	mov    %eax,(%esp)
c01036ea:	e8 26 f2 ff ff       	call   c0102915 <pte2page>
c01036ef:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01036f2:	74 24                	je     c0103718 <check_pgdir+0x191>
c01036f4:	c7 44 24 0c dd 76 10 	movl   $0xc01076dd,0xc(%esp)
c01036fb:	c0 
c01036fc:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103703:	c0 
c0103704:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c010370b:	00 
c010370c:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103713:	e8 d6 cc ff ff       	call   c01003ee <__panic>
    assert(page_ref(p1) == 1);
c0103718:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010371b:	89 04 24             	mov    %eax,(%esp)
c010371e:	e8 48 f2 ff ff       	call   c010296b <page_ref>
c0103723:	83 f8 01             	cmp    $0x1,%eax
c0103726:	74 24                	je     c010374c <check_pgdir+0x1c5>
c0103728:	c7 44 24 0c f3 76 10 	movl   $0xc01076f3,0xc(%esp)
c010372f:	c0 
c0103730:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103737:	c0 
c0103738:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c010373f:	00 
c0103740:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103747:	e8 a2 cc ff ff       	call   c01003ee <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c010374c:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103751:	8b 00                	mov    (%eax),%eax
c0103753:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103758:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010375b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010375e:	c1 e8 0c             	shr    $0xc,%eax
c0103761:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103764:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103769:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c010376c:	72 23                	jb     c0103791 <check_pgdir+0x20a>
c010376e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103771:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103775:	c7 44 24 08 c0 74 10 	movl   $0xc01074c0,0x8(%esp)
c010377c:	c0 
c010377d:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103784:	00 
c0103785:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c010378c:	e8 5d cc ff ff       	call   c01003ee <__panic>
c0103791:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103794:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103799:	83 c0 04             	add    $0x4,%eax
c010379c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010379f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01037a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01037ab:	00 
c01037ac:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01037b3:	00 
c01037b4:	89 04 24             	mov    %eax,(%esp)
c01037b7:	e8 5e fa ff ff       	call   c010321a <get_pte>
c01037bc:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01037bf:	74 24                	je     c01037e5 <check_pgdir+0x25e>
c01037c1:	c7 44 24 0c 08 77 10 	movl   $0xc0107708,0xc(%esp)
c01037c8:	c0 
c01037c9:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01037d0:	c0 
c01037d1:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c01037d8:	00 
c01037d9:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01037e0:	e8 09 cc ff ff       	call   c01003ee <__panic>

    p2 = alloc_page();
c01037e5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01037ec:	e8 7f f3 ff ff       	call   c0102b70 <alloc_pages>
c01037f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01037f4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01037f9:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103800:	00 
c0103801:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103808:	00 
c0103809:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010380c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103810:	89 04 24             	mov    %eax,(%esp)
c0103813:	e8 3b fc ff ff       	call   c0103453 <page_insert>
c0103818:	85 c0                	test   %eax,%eax
c010381a:	74 24                	je     c0103840 <check_pgdir+0x2b9>
c010381c:	c7 44 24 0c 30 77 10 	movl   $0xc0107730,0xc(%esp)
c0103823:	c0 
c0103824:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c010382b:	c0 
c010382c:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0103833:	00 
c0103834:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c010383b:	e8 ae cb ff ff       	call   c01003ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103840:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103845:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010384c:	00 
c010384d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103854:	00 
c0103855:	89 04 24             	mov    %eax,(%esp)
c0103858:	e8 bd f9 ff ff       	call   c010321a <get_pte>
c010385d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103860:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103864:	75 24                	jne    c010388a <check_pgdir+0x303>
c0103866:	c7 44 24 0c 68 77 10 	movl   $0xc0107768,0xc(%esp)
c010386d:	c0 
c010386e:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103875:	c0 
c0103876:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c010387d:	00 
c010387e:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103885:	e8 64 cb ff ff       	call   c01003ee <__panic>
    assert(*ptep & PTE_U);
c010388a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010388d:	8b 00                	mov    (%eax),%eax
c010388f:	83 e0 04             	and    $0x4,%eax
c0103892:	85 c0                	test   %eax,%eax
c0103894:	75 24                	jne    c01038ba <check_pgdir+0x333>
c0103896:	c7 44 24 0c 98 77 10 	movl   $0xc0107798,0xc(%esp)
c010389d:	c0 
c010389e:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01038a5:	c0 
c01038a6:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c01038ad:	00 
c01038ae:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01038b5:	e8 34 cb ff ff       	call   c01003ee <__panic>
    assert(*ptep & PTE_W);
c01038ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01038bd:	8b 00                	mov    (%eax),%eax
c01038bf:	83 e0 02             	and    $0x2,%eax
c01038c2:	85 c0                	test   %eax,%eax
c01038c4:	75 24                	jne    c01038ea <check_pgdir+0x363>
c01038c6:	c7 44 24 0c a6 77 10 	movl   $0xc01077a6,0xc(%esp)
c01038cd:	c0 
c01038ce:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01038d5:	c0 
c01038d6:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c01038dd:	00 
c01038de:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01038e5:	e8 04 cb ff ff       	call   c01003ee <__panic>
    assert(boot_pgdir[0] & PTE_U);
c01038ea:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01038ef:	8b 00                	mov    (%eax),%eax
c01038f1:	83 e0 04             	and    $0x4,%eax
c01038f4:	85 c0                	test   %eax,%eax
c01038f6:	75 24                	jne    c010391c <check_pgdir+0x395>
c01038f8:	c7 44 24 0c b4 77 10 	movl   $0xc01077b4,0xc(%esp)
c01038ff:	c0 
c0103900:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103907:	c0 
c0103908:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c010390f:	00 
c0103910:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103917:	e8 d2 ca ff ff       	call   c01003ee <__panic>
    assert(page_ref(p2) == 1);
c010391c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010391f:	89 04 24             	mov    %eax,(%esp)
c0103922:	e8 44 f0 ff ff       	call   c010296b <page_ref>
c0103927:	83 f8 01             	cmp    $0x1,%eax
c010392a:	74 24                	je     c0103950 <check_pgdir+0x3c9>
c010392c:	c7 44 24 0c ca 77 10 	movl   $0xc01077ca,0xc(%esp)
c0103933:	c0 
c0103934:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c010393b:	c0 
c010393c:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0103943:	00 
c0103944:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c010394b:	e8 9e ca ff ff       	call   c01003ee <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103950:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103955:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c010395c:	00 
c010395d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103964:	00 
c0103965:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103968:	89 54 24 04          	mov    %edx,0x4(%esp)
c010396c:	89 04 24             	mov    %eax,(%esp)
c010396f:	e8 df fa ff ff       	call   c0103453 <page_insert>
c0103974:	85 c0                	test   %eax,%eax
c0103976:	74 24                	je     c010399c <check_pgdir+0x415>
c0103978:	c7 44 24 0c dc 77 10 	movl   $0xc01077dc,0xc(%esp)
c010397f:	c0 
c0103980:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103987:	c0 
c0103988:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c010398f:	00 
c0103990:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103997:	e8 52 ca ff ff       	call   c01003ee <__panic>
    assert(page_ref(p1) == 2);
c010399c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010399f:	89 04 24             	mov    %eax,(%esp)
c01039a2:	e8 c4 ef ff ff       	call   c010296b <page_ref>
c01039a7:	83 f8 02             	cmp    $0x2,%eax
c01039aa:	74 24                	je     c01039d0 <check_pgdir+0x449>
c01039ac:	c7 44 24 0c 08 78 10 	movl   $0xc0107808,0xc(%esp)
c01039b3:	c0 
c01039b4:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01039bb:	c0 
c01039bc:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c01039c3:	00 
c01039c4:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01039cb:	e8 1e ca ff ff       	call   c01003ee <__panic>
    assert(page_ref(p2) == 0);
c01039d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01039d3:	89 04 24             	mov    %eax,(%esp)
c01039d6:	e8 90 ef ff ff       	call   c010296b <page_ref>
c01039db:	85 c0                	test   %eax,%eax
c01039dd:	74 24                	je     c0103a03 <check_pgdir+0x47c>
c01039df:	c7 44 24 0c 1a 78 10 	movl   $0xc010781a,0xc(%esp)
c01039e6:	c0 
c01039e7:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c01039ee:	c0 
c01039ef:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c01039f6:	00 
c01039f7:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c01039fe:	e8 eb c9 ff ff       	call   c01003ee <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103a03:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103a08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103a0f:	00 
c0103a10:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103a17:	00 
c0103a18:	89 04 24             	mov    %eax,(%esp)
c0103a1b:	e8 fa f7 ff ff       	call   c010321a <get_pte>
c0103a20:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a23:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103a27:	75 24                	jne    c0103a4d <check_pgdir+0x4c6>
c0103a29:	c7 44 24 0c 68 77 10 	movl   $0xc0107768,0xc(%esp)
c0103a30:	c0 
c0103a31:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103a38:	c0 
c0103a39:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0103a40:	00 
c0103a41:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103a48:	e8 a1 c9 ff ff       	call   c01003ee <__panic>
    assert(pte2page(*ptep) == p1);
c0103a4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a50:	8b 00                	mov    (%eax),%eax
c0103a52:	89 04 24             	mov    %eax,(%esp)
c0103a55:	e8 bb ee ff ff       	call   c0102915 <pte2page>
c0103a5a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103a5d:	74 24                	je     c0103a83 <check_pgdir+0x4fc>
c0103a5f:	c7 44 24 0c dd 76 10 	movl   $0xc01076dd,0xc(%esp)
c0103a66:	c0 
c0103a67:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103a6e:	c0 
c0103a6f:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0103a76:	00 
c0103a77:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103a7e:	e8 6b c9 ff ff       	call   c01003ee <__panic>
    assert((*ptep & PTE_U) == 0);
c0103a83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a86:	8b 00                	mov    (%eax),%eax
c0103a88:	83 e0 04             	and    $0x4,%eax
c0103a8b:	85 c0                	test   %eax,%eax
c0103a8d:	74 24                	je     c0103ab3 <check_pgdir+0x52c>
c0103a8f:	c7 44 24 0c 2c 78 10 	movl   $0xc010782c,0xc(%esp)
c0103a96:	c0 
c0103a97:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103a9e:	c0 
c0103a9f:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0103aa6:	00 
c0103aa7:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103aae:	e8 3b c9 ff ff       	call   c01003ee <__panic>

    page_remove(boot_pgdir, 0x0);
c0103ab3:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103ab8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103abf:	00 
c0103ac0:	89 04 24             	mov    %eax,(%esp)
c0103ac3:	e8 46 f9 ff ff       	call   c010340e <page_remove>
    assert(page_ref(p1) == 1);
c0103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103acb:	89 04 24             	mov    %eax,(%esp)
c0103ace:	e8 98 ee ff ff       	call   c010296b <page_ref>
c0103ad3:	83 f8 01             	cmp    $0x1,%eax
c0103ad6:	74 24                	je     c0103afc <check_pgdir+0x575>
c0103ad8:	c7 44 24 0c f3 76 10 	movl   $0xc01076f3,0xc(%esp)
c0103adf:	c0 
c0103ae0:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103ae7:	c0 
c0103ae8:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0103aef:	00 
c0103af0:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103af7:	e8 f2 c8 ff ff       	call   c01003ee <__panic>
    assert(page_ref(p2) == 0);
c0103afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103aff:	89 04 24             	mov    %eax,(%esp)
c0103b02:	e8 64 ee ff ff       	call   c010296b <page_ref>
c0103b07:	85 c0                	test   %eax,%eax
c0103b09:	74 24                	je     c0103b2f <check_pgdir+0x5a8>
c0103b0b:	c7 44 24 0c 1a 78 10 	movl   $0xc010781a,0xc(%esp)
c0103b12:	c0 
c0103b13:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103b1a:	c0 
c0103b1b:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0103b22:	00 
c0103b23:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103b2a:	e8 bf c8 ff ff       	call   c01003ee <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0103b2f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103b34:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103b3b:	00 
c0103b3c:	89 04 24             	mov    %eax,(%esp)
c0103b3f:	e8 ca f8 ff ff       	call   c010340e <page_remove>
    assert(page_ref(p1) == 0);
c0103b44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b47:	89 04 24             	mov    %eax,(%esp)
c0103b4a:	e8 1c ee ff ff       	call   c010296b <page_ref>
c0103b4f:	85 c0                	test   %eax,%eax
c0103b51:	74 24                	je     c0103b77 <check_pgdir+0x5f0>
c0103b53:	c7 44 24 0c 41 78 10 	movl   $0xc0107841,0xc(%esp)
c0103b5a:	c0 
c0103b5b:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103b62:	c0 
c0103b63:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0103b6a:	00 
c0103b6b:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103b72:	e8 77 c8 ff ff       	call   c01003ee <__panic>
    assert(page_ref(p2) == 0);
c0103b77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103b7a:	89 04 24             	mov    %eax,(%esp)
c0103b7d:	e8 e9 ed ff ff       	call   c010296b <page_ref>
c0103b82:	85 c0                	test   %eax,%eax
c0103b84:	74 24                	je     c0103baa <check_pgdir+0x623>
c0103b86:	c7 44 24 0c 1a 78 10 	movl   $0xc010781a,0xc(%esp)
c0103b8d:	c0 
c0103b8e:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103b95:	c0 
c0103b96:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0103b9d:	00 
c0103b9e:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103ba5:	e8 44 c8 ff ff       	call   c01003ee <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0103baa:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103baf:	8b 00                	mov    (%eax),%eax
c0103bb1:	89 04 24             	mov    %eax,(%esp)
c0103bb4:	e8 9a ed ff ff       	call   c0102953 <pde2page>
c0103bb9:	89 04 24             	mov    %eax,(%esp)
c0103bbc:	e8 aa ed ff ff       	call   c010296b <page_ref>
c0103bc1:	83 f8 01             	cmp    $0x1,%eax
c0103bc4:	74 24                	je     c0103bea <check_pgdir+0x663>
c0103bc6:	c7 44 24 0c 54 78 10 	movl   $0xc0107854,0xc(%esp)
c0103bcd:	c0 
c0103bce:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103bd5:	c0 
c0103bd6:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0103bdd:	00 
c0103bde:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103be5:	e8 04 c8 ff ff       	call   c01003ee <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0103bea:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103bef:	8b 00                	mov    (%eax),%eax
c0103bf1:	89 04 24             	mov    %eax,(%esp)
c0103bf4:	e8 5a ed ff ff       	call   c0102953 <pde2page>
c0103bf9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c00:	00 
c0103c01:	89 04 24             	mov    %eax,(%esp)
c0103c04:	e8 9f ef ff ff       	call   c0102ba8 <free_pages>
    boot_pgdir[0] = 0;
c0103c09:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103c0e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0103c14:	c7 04 24 7b 78 10 c0 	movl   $0xc010787b,(%esp)
c0103c1b:	e8 77 c6 ff ff       	call   c0100297 <cprintf>
}
c0103c20:	90                   	nop
c0103c21:	c9                   	leave  
c0103c22:	c3                   	ret    

c0103c23 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0103c23:	55                   	push   %ebp
c0103c24:	89 e5                	mov    %esp,%ebp
c0103c26:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103c29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103c30:	e9 ca 00 00 00       	jmp    c0103cff <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0103c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c38:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c3e:	c1 e8 0c             	shr    $0xc,%eax
c0103c41:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c44:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103c49:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103c4c:	72 23                	jb     c0103c71 <check_boot_pgdir+0x4e>
c0103c4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c51:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c55:	c7 44 24 08 c0 74 10 	movl   $0xc01074c0,0x8(%esp)
c0103c5c:	c0 
c0103c5d:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0103c64:	00 
c0103c65:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103c6c:	e8 7d c7 ff ff       	call   c01003ee <__panic>
c0103c71:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c74:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103c79:	89 c2                	mov    %eax,%edx
c0103c7b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103c80:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c87:	00 
c0103c88:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103c8c:	89 04 24             	mov    %eax,(%esp)
c0103c8f:	e8 86 f5 ff ff       	call   c010321a <get_pte>
c0103c94:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c97:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103c9b:	75 24                	jne    c0103cc1 <check_boot_pgdir+0x9e>
c0103c9d:	c7 44 24 0c 98 78 10 	movl   $0xc0107898,0xc(%esp)
c0103ca4:	c0 
c0103ca5:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103cac:	c0 
c0103cad:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c0103cb4:	00 
c0103cb5:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103cbc:	e8 2d c7 ff ff       	call   c01003ee <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0103cc1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cc4:	8b 00                	mov    (%eax),%eax
c0103cc6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103ccb:	89 c2                	mov    %eax,%edx
c0103ccd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd0:	39 c2                	cmp    %eax,%edx
c0103cd2:	74 24                	je     c0103cf8 <check_boot_pgdir+0xd5>
c0103cd4:	c7 44 24 0c d5 78 10 	movl   $0xc01078d5,0xc(%esp)
c0103cdb:	c0 
c0103cdc:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103ce3:	c0 
c0103ce4:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0103ceb:	00 
c0103cec:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103cf3:	e8 f6 c6 ff ff       	call   c01003ee <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c0103cf8:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c0103cff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d02:	a1 80 ce 11 c0       	mov    0xc011ce80,%eax
c0103d07:	39 c2                	cmp    %eax,%edx
c0103d09:	0f 82 26 ff ff ff    	jb     c0103c35 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0103d0f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103d14:	05 ac 0f 00 00       	add    $0xfac,%eax
c0103d19:	8b 00                	mov    (%eax),%eax
c0103d1b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103d20:	89 c2                	mov    %eax,%edx
c0103d22:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103d27:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103d2a:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0103d31:	77 23                	ja     c0103d56 <check_boot_pgdir+0x133>
c0103d33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d36:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103d3a:	c7 44 24 08 64 75 10 	movl   $0xc0107564,0x8(%esp)
c0103d41:	c0 
c0103d42:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0103d49:	00 
c0103d4a:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103d51:	e8 98 c6 ff ff       	call   c01003ee <__panic>
c0103d56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103d59:	05 00 00 00 40       	add    $0x40000000,%eax
c0103d5e:	39 c2                	cmp    %eax,%edx
c0103d60:	74 24                	je     c0103d86 <check_boot_pgdir+0x163>
c0103d62:	c7 44 24 0c ec 78 10 	movl   $0xc01078ec,0xc(%esp)
c0103d69:	c0 
c0103d6a:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103d71:	c0 
c0103d72:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0103d79:	00 
c0103d7a:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103d81:	e8 68 c6 ff ff       	call   c01003ee <__panic>

    assert(boot_pgdir[0] == 0);
c0103d86:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103d8b:	8b 00                	mov    (%eax),%eax
c0103d8d:	85 c0                	test   %eax,%eax
c0103d8f:	74 24                	je     c0103db5 <check_boot_pgdir+0x192>
c0103d91:	c7 44 24 0c 20 79 10 	movl   $0xc0107920,0xc(%esp)
c0103d98:	c0 
c0103d99:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103da0:	c0 
c0103da1:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0103da8:	00 
c0103da9:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103db0:	e8 39 c6 ff ff       	call   c01003ee <__panic>

    struct Page *p;
    p = alloc_page();
c0103db5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103dbc:	e8 af ed ff ff       	call   c0102b70 <alloc_pages>
c0103dc1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0103dc4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103dc9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103dd0:	00 
c0103dd1:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0103dd8:	00 
c0103dd9:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103ddc:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103de0:	89 04 24             	mov    %eax,(%esp)
c0103de3:	e8 6b f6 ff ff       	call   c0103453 <page_insert>
c0103de8:	85 c0                	test   %eax,%eax
c0103dea:	74 24                	je     c0103e10 <check_boot_pgdir+0x1ed>
c0103dec:	c7 44 24 0c 34 79 10 	movl   $0xc0107934,0xc(%esp)
c0103df3:	c0 
c0103df4:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103dfb:	c0 
c0103dfc:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
c0103e03:	00 
c0103e04:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103e0b:	e8 de c5 ff ff       	call   c01003ee <__panic>
    assert(page_ref(p) == 1);
c0103e10:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e13:	89 04 24             	mov    %eax,(%esp)
c0103e16:	e8 50 eb ff ff       	call   c010296b <page_ref>
c0103e1b:	83 f8 01             	cmp    $0x1,%eax
c0103e1e:	74 24                	je     c0103e44 <check_boot_pgdir+0x221>
c0103e20:	c7 44 24 0c 62 79 10 	movl   $0xc0107962,0xc(%esp)
c0103e27:	c0 
c0103e28:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103e2f:	c0 
c0103e30:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
c0103e37:	00 
c0103e38:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103e3f:	e8 aa c5 ff ff       	call   c01003ee <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0103e44:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103e49:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0103e50:	00 
c0103e51:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0103e58:	00 
c0103e59:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0103e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e60:	89 04 24             	mov    %eax,(%esp)
c0103e63:	e8 eb f5 ff ff       	call   c0103453 <page_insert>
c0103e68:	85 c0                	test   %eax,%eax
c0103e6a:	74 24                	je     c0103e90 <check_boot_pgdir+0x26d>
c0103e6c:	c7 44 24 0c 74 79 10 	movl   $0xc0107974,0xc(%esp)
c0103e73:	c0 
c0103e74:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103e7b:	c0 
c0103e7c:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
c0103e83:	00 
c0103e84:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103e8b:	e8 5e c5 ff ff       	call   c01003ee <__panic>
    assert(page_ref(p) == 2);
c0103e90:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103e93:	89 04 24             	mov    %eax,(%esp)
c0103e96:	e8 d0 ea ff ff       	call   c010296b <page_ref>
c0103e9b:	83 f8 02             	cmp    $0x2,%eax
c0103e9e:	74 24                	je     c0103ec4 <check_boot_pgdir+0x2a1>
c0103ea0:	c7 44 24 0c ab 79 10 	movl   $0xc01079ab,0xc(%esp)
c0103ea7:	c0 
c0103ea8:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103eaf:	c0 
c0103eb0:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c0103eb7:	00 
c0103eb8:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103ebf:	e8 2a c5 ff ff       	call   c01003ee <__panic>

    const char *str = "ucore: Hello world!!";
c0103ec4:	c7 45 dc bc 79 10 c0 	movl   $0xc01079bc,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0103ecb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103ece:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103ed2:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103ed9:	e8 b4 23 00 00       	call   c0106292 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c0103ede:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0103ee5:	00 
c0103ee6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103eed:	e8 17 24 00 00       	call   c0106309 <strcmp>
c0103ef2:	85 c0                	test   %eax,%eax
c0103ef4:	74 24                	je     c0103f1a <check_boot_pgdir+0x2f7>
c0103ef6:	c7 44 24 0c d4 79 10 	movl   $0xc01079d4,0xc(%esp)
c0103efd:	c0 
c0103efe:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103f05:	c0 
c0103f06:	c7 44 24 04 3b 02 00 	movl   $0x23b,0x4(%esp)
c0103f0d:	00 
c0103f0e:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103f15:	e8 d4 c4 ff ff       	call   c01003ee <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c0103f1a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f1d:	89 04 24             	mov    %eax,(%esp)
c0103f20:	e8 9c e9 ff ff       	call   c01028c1 <page2kva>
c0103f25:	05 00 01 00 00       	add    $0x100,%eax
c0103f2a:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0103f2d:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0103f34:	e8 03 23 00 00       	call   c010623c <strlen>
c0103f39:	85 c0                	test   %eax,%eax
c0103f3b:	74 24                	je     c0103f61 <check_boot_pgdir+0x33e>
c0103f3d:	c7 44 24 0c 0c 7a 10 	movl   $0xc0107a0c,0xc(%esp)
c0103f44:	c0 
c0103f45:	c7 44 24 08 ad 75 10 	movl   $0xc01075ad,0x8(%esp)
c0103f4c:	c0 
c0103f4d:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c0103f54:	00 
c0103f55:	c7 04 24 88 75 10 c0 	movl   $0xc0107588,(%esp)
c0103f5c:	e8 8d c4 ff ff       	call   c01003ee <__panic>

    free_page(p);
c0103f61:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f68:	00 
c0103f69:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103f6c:	89 04 24             	mov    %eax,(%esp)
c0103f6f:	e8 34 ec ff ff       	call   c0102ba8 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0103f74:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103f79:	8b 00                	mov    (%eax),%eax
c0103f7b:	89 04 24             	mov    %eax,(%esp)
c0103f7e:	e8 d0 e9 ff ff       	call   c0102953 <pde2page>
c0103f83:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f8a:	00 
c0103f8b:	89 04 24             	mov    %eax,(%esp)
c0103f8e:	e8 15 ec ff ff       	call   c0102ba8 <free_pages>
    boot_pgdir[0] = 0;
c0103f93:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0103f98:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0103f9e:	c7 04 24 30 7a 10 c0 	movl   $0xc0107a30,(%esp)
c0103fa5:	e8 ed c2 ff ff       	call   c0100297 <cprintf>
}
c0103faa:	90                   	nop
c0103fab:	c9                   	leave  
c0103fac:	c3                   	ret    

c0103fad <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0103fad:	55                   	push   %ebp
c0103fae:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0103fb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fb3:	83 e0 04             	and    $0x4,%eax
c0103fb6:	85 c0                	test   %eax,%eax
c0103fb8:	74 04                	je     c0103fbe <perm2str+0x11>
c0103fba:	b0 75                	mov    $0x75,%al
c0103fbc:	eb 02                	jmp    c0103fc0 <perm2str+0x13>
c0103fbe:	b0 2d                	mov    $0x2d,%al
c0103fc0:	a2 08 cf 11 c0       	mov    %al,0xc011cf08
    str[1] = 'r';
c0103fc5:	c6 05 09 cf 11 c0 72 	movb   $0x72,0xc011cf09
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0103fcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103fcf:	83 e0 02             	and    $0x2,%eax
c0103fd2:	85 c0                	test   %eax,%eax
c0103fd4:	74 04                	je     c0103fda <perm2str+0x2d>
c0103fd6:	b0 77                	mov    $0x77,%al
c0103fd8:	eb 02                	jmp    c0103fdc <perm2str+0x2f>
c0103fda:	b0 2d                	mov    $0x2d,%al
c0103fdc:	a2 0a cf 11 c0       	mov    %al,0xc011cf0a
    str[3] = '\0';
c0103fe1:	c6 05 0b cf 11 c0 00 	movb   $0x0,0xc011cf0b
    return str;
c0103fe8:	b8 08 cf 11 c0       	mov    $0xc011cf08,%eax
}
c0103fed:	5d                   	pop    %ebp
c0103fee:	c3                   	ret    

c0103fef <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0103fef:	55                   	push   %ebp
c0103ff0:	89 e5                	mov    %esp,%ebp
c0103ff2:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0103ff5:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ff8:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103ffb:	72 0d                	jb     c010400a <get_pgtable_items+0x1b>
        return 0;
c0103ffd:	b8 00 00 00 00       	mov    $0x0,%eax
c0104002:	e9 98 00 00 00       	jmp    c010409f <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104007:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c010400a:	8b 45 10             	mov    0x10(%ebp),%eax
c010400d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104010:	73 18                	jae    c010402a <get_pgtable_items+0x3b>
c0104012:	8b 45 10             	mov    0x10(%ebp),%eax
c0104015:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010401c:	8b 45 14             	mov    0x14(%ebp),%eax
c010401f:	01 d0                	add    %edx,%eax
c0104021:	8b 00                	mov    (%eax),%eax
c0104023:	83 e0 01             	and    $0x1,%eax
c0104026:	85 c0                	test   %eax,%eax
c0104028:	74 dd                	je     c0104007 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c010402a:	8b 45 10             	mov    0x10(%ebp),%eax
c010402d:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104030:	73 68                	jae    c010409a <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0104032:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104036:	74 08                	je     c0104040 <get_pgtable_items+0x51>
            *left_store = start;
c0104038:	8b 45 18             	mov    0x18(%ebp),%eax
c010403b:	8b 55 10             	mov    0x10(%ebp),%edx
c010403e:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0104040:	8b 45 10             	mov    0x10(%ebp),%eax
c0104043:	8d 50 01             	lea    0x1(%eax),%edx
c0104046:	89 55 10             	mov    %edx,0x10(%ebp)
c0104049:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104050:	8b 45 14             	mov    0x14(%ebp),%eax
c0104053:	01 d0                	add    %edx,%eax
c0104055:	8b 00                	mov    (%eax),%eax
c0104057:	83 e0 07             	and    $0x7,%eax
c010405a:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010405d:	eb 03                	jmp    c0104062 <get_pgtable_items+0x73>
            start ++;
c010405f:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104062:	8b 45 10             	mov    0x10(%ebp),%eax
c0104065:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104068:	73 1d                	jae    c0104087 <get_pgtable_items+0x98>
c010406a:	8b 45 10             	mov    0x10(%ebp),%eax
c010406d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104074:	8b 45 14             	mov    0x14(%ebp),%eax
c0104077:	01 d0                	add    %edx,%eax
c0104079:	8b 00                	mov    (%eax),%eax
c010407b:	83 e0 07             	and    $0x7,%eax
c010407e:	89 c2                	mov    %eax,%edx
c0104080:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104083:	39 c2                	cmp    %eax,%edx
c0104085:	74 d8                	je     c010405f <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c0104087:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010408b:	74 08                	je     c0104095 <get_pgtable_items+0xa6>
            *right_store = start;
c010408d:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104090:	8b 55 10             	mov    0x10(%ebp),%edx
c0104093:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104095:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104098:	eb 05                	jmp    c010409f <get_pgtable_items+0xb0>
    }
    return 0;
c010409a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010409f:	c9                   	leave  
c01040a0:	c3                   	ret    

c01040a1 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c01040a1:	55                   	push   %ebp
c01040a2:	89 e5                	mov    %esp,%ebp
c01040a4:	57                   	push   %edi
c01040a5:	56                   	push   %esi
c01040a6:	53                   	push   %ebx
c01040a7:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c01040aa:	c7 04 24 50 7a 10 c0 	movl   $0xc0107a50,(%esp)
c01040b1:	e8 e1 c1 ff ff       	call   c0100297 <cprintf>
    size_t left, right = 0, perm;
c01040b6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01040bd:	e9 fa 00 00 00       	jmp    c01041bc <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01040c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01040c5:	89 04 24             	mov    %eax,(%esp)
c01040c8:	e8 e0 fe ff ff       	call   c0103fad <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01040cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01040d0:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040d3:	29 d1                	sub    %edx,%ecx
c01040d5:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01040d7:	89 d6                	mov    %edx,%esi
c01040d9:	c1 e6 16             	shl    $0x16,%esi
c01040dc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01040df:	89 d3                	mov    %edx,%ebx
c01040e1:	c1 e3 16             	shl    $0x16,%ebx
c01040e4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040e7:	89 d1                	mov    %edx,%ecx
c01040e9:	c1 e1 16             	shl    $0x16,%ecx
c01040ec:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01040ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01040f2:	29 d7                	sub    %edx,%edi
c01040f4:	89 fa                	mov    %edi,%edx
c01040f6:	89 44 24 14          	mov    %eax,0x14(%esp)
c01040fa:	89 74 24 10          	mov    %esi,0x10(%esp)
c01040fe:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104102:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104106:	89 54 24 04          	mov    %edx,0x4(%esp)
c010410a:	c7 04 24 81 7a 10 c0 	movl   $0xc0107a81,(%esp)
c0104111:	e8 81 c1 ff ff       	call   c0100297 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0104116:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104119:	c1 e0 0a             	shl    $0xa,%eax
c010411c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c010411f:	eb 54                	jmp    c0104175 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104121:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104124:	89 04 24             	mov    %eax,(%esp)
c0104127:	e8 81 fe ff ff       	call   c0103fad <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c010412c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010412f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104132:	29 d1                	sub    %edx,%ecx
c0104134:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104136:	89 d6                	mov    %edx,%esi
c0104138:	c1 e6 0c             	shl    $0xc,%esi
c010413b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010413e:	89 d3                	mov    %edx,%ebx
c0104140:	c1 e3 0c             	shl    $0xc,%ebx
c0104143:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104146:	89 d1                	mov    %edx,%ecx
c0104148:	c1 e1 0c             	shl    $0xc,%ecx
c010414b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c010414e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104151:	29 d7                	sub    %edx,%edi
c0104153:	89 fa                	mov    %edi,%edx
c0104155:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104159:	89 74 24 10          	mov    %esi,0x10(%esp)
c010415d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104161:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104165:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104169:	c7 04 24 a0 7a 10 c0 	movl   $0xc0107aa0,(%esp)
c0104170:	e8 22 c1 ff ff       	call   c0100297 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104175:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010417a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010417d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104180:	89 d3                	mov    %edx,%ebx
c0104182:	c1 e3 0a             	shl    $0xa,%ebx
c0104185:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104188:	89 d1                	mov    %edx,%ecx
c010418a:	c1 e1 0a             	shl    $0xa,%ecx
c010418d:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104190:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104194:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104197:	89 54 24 10          	mov    %edx,0x10(%esp)
c010419b:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010419f:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01041a7:	89 0c 24             	mov    %ecx,(%esp)
c01041aa:	e8 40 fe ff ff       	call   c0103fef <get_pgtable_items>
c01041af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041b2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041b6:	0f 85 65 ff ff ff    	jne    c0104121 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01041bc:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01041c1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01041c4:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01041c7:	89 54 24 14          	mov    %edx,0x14(%esp)
c01041cb:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01041ce:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01041d6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01041da:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01041e1:	00 
c01041e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01041e9:	e8 01 fe ff ff       	call   c0103fef <get_pgtable_items>
c01041ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01041f1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01041f5:	0f 85 c7 fe ff ff    	jne    c01040c2 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01041fb:	c7 04 24 c4 7a 10 c0 	movl   $0xc0107ac4,(%esp)
c0104202:	e8 90 c0 ff ff       	call   c0100297 <cprintf>
}
c0104207:	90                   	nop
c0104208:	83 c4 4c             	add    $0x4c,%esp
c010420b:	5b                   	pop    %ebx
c010420c:	5e                   	pop    %esi
c010420d:	5f                   	pop    %edi
c010420e:	5d                   	pop    %ebp
c010420f:	c3                   	ret    

c0104210 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104210:	55                   	push   %ebp
c0104211:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104213:	8b 45 08             	mov    0x8(%ebp),%eax
c0104216:	8b 00                	mov    (%eax),%eax
}
c0104218:	5d                   	pop    %ebp
c0104219:	c3                   	ret    

c010421a <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010421a:	55                   	push   %ebp
c010421b:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c010421d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104220:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104223:	89 10                	mov    %edx,(%eax)
}
c0104225:	90                   	nop
c0104226:	5d                   	pop    %ebp
c0104227:	c3                   	ret    

c0104228 <fixsize>:
#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
c0104228:	55                   	push   %ebp
c0104229:	89 e5                	mov    %esp,%ebp
  size |= size >> 1;
c010422b:	8b 45 08             	mov    0x8(%ebp),%eax
c010422e:	d1 e8                	shr    %eax
c0104230:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 2;
c0104233:	8b 45 08             	mov    0x8(%ebp),%eax
c0104236:	c1 e8 02             	shr    $0x2,%eax
c0104239:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 4;
c010423c:	8b 45 08             	mov    0x8(%ebp),%eax
c010423f:	c1 e8 04             	shr    $0x4,%eax
c0104242:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 8;
c0104245:	8b 45 08             	mov    0x8(%ebp),%eax
c0104248:	c1 e8 08             	shr    $0x8,%eax
c010424b:	09 45 08             	or     %eax,0x8(%ebp)
  size |= size >> 16;
c010424e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104251:	c1 e8 10             	shr    $0x10,%eax
c0104254:	09 45 08             	or     %eax,0x8(%ebp)
  return size+1;
c0104257:	8b 45 08             	mov    0x8(%ebp),%eax
c010425a:	40                   	inc    %eax
}
c010425b:	5d                   	pop    %ebp
c010425c:	c3                   	ret    

c010425d <buddy_init>:

struct allocRecord rec[80000];//存放偏移量的数组
int nr_block;//已分配的块数

static void buddy_init()
{
c010425d:	55                   	push   %ebp
c010425e:	89 e5                	mov    %esp,%ebp
c0104260:	83 ec 10             	sub    $0x10,%esp
c0104263:	c7 45 fc 40 93 1b c0 	movl   $0xc01b9340,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010426a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010426d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104270:	89 50 04             	mov    %edx,0x4(%eax)
c0104273:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104276:	8b 50 04             	mov    0x4(%eax),%edx
c0104279:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010427c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free=0;
c010427e:	c7 05 48 93 1b c0 00 	movl   $0x0,0xc01b9348
c0104285:	00 00 00 
}
c0104288:	90                   	nop
c0104289:	c9                   	leave  
c010428a:	c3                   	ret    

c010428b <buddy2_new>:

//初始化二叉树上的节点
void buddy2_new( int size ) {
c010428b:	55                   	push   %ebp
c010428c:	89 e5                	mov    %esp,%ebp
c010428e:	83 ec 10             	sub    $0x10,%esp
  unsigned node_size;
  int i;
  nr_block=0;
c0104291:	c7 05 20 cf 11 c0 00 	movl   $0x0,0xc011cf20
c0104298:	00 00 00 
  if (size < 1 || !IS_POWER_OF_2(size))
c010429b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010429f:	7e 55                	jle    c01042f6 <buddy2_new+0x6b>
c01042a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01042a4:	48                   	dec    %eax
c01042a5:	23 45 08             	and    0x8(%ebp),%eax
c01042a8:	85 c0                	test   %eax,%eax
c01042aa:	75 4a                	jne    c01042f6 <buddy2_new+0x6b>
    return;

  root[0].size = size;
c01042ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01042af:	a3 40 cf 11 c0       	mov    %eax,0xc011cf40
  node_size = size * 2;
c01042b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01042b7:	01 c0                	add    %eax,%eax
c01042b9:	89 45 fc             	mov    %eax,-0x4(%ebp)

  for (i = 0; i < 2 * size - 1; ++i) {
c01042bc:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
c01042c3:	eb 23                	jmp    c01042e8 <buddy2_new+0x5d>
    if (IS_POWER_OF_2(i+1))
c01042c5:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01042c8:	40                   	inc    %eax
c01042c9:	23 45 f8             	and    -0x8(%ebp),%eax
c01042cc:	85 c0                	test   %eax,%eax
c01042ce:	75 08                	jne    c01042d8 <buddy2_new+0x4d>
      node_size /= 2;
c01042d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01042d3:	d1 e8                	shr    %eax
c01042d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
    root[i].longest = node_size;
c01042d8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01042db:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01042de:	89 14 c5 44 cf 11 c0 	mov    %edx,-0x3fee30bc(,%eax,8)
    return;

  root[0].size = size;
  node_size = size * 2;

  for (i = 0; i < 2 * size - 1; ++i) {
c01042e5:	ff 45 f8             	incl   -0x8(%ebp)
c01042e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01042eb:	01 c0                	add    %eax,%eax
c01042ed:	48                   	dec    %eax
c01042ee:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01042f1:	7f d2                	jg     c01042c5 <buddy2_new+0x3a>
    if (IS_POWER_OF_2(i+1))
      node_size /= 2;
    root[i].longest = node_size;
  }
  return;
c01042f3:	90                   	nop
c01042f4:	eb 01                	jmp    c01042f7 <buddy2_new+0x6c>
void buddy2_new( int size ) {
  unsigned node_size;
  int i;
  nr_block=0;
  if (size < 1 || !IS_POWER_OF_2(size))
    return;
c01042f6:	90                   	nop
    if (IS_POWER_OF_2(i+1))
      node_size /= 2;
    root[i].longest = node_size;
  }
  return;
}
c01042f7:	c9                   	leave  
c01042f8:	c3                   	ret    

c01042f9 <buddy_init_memmap>:

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
c01042f9:	55                   	push   %ebp
c01042fa:	89 e5                	mov    %esp,%ebp
c01042fc:	56                   	push   %esi
c01042fd:	53                   	push   %ebx
c01042fe:	83 ec 40             	sub    $0x40,%esp
    assert(n>0);
c0104301:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104305:	75 24                	jne    c010432b <buddy_init_memmap+0x32>
c0104307:	c7 44 24 0c f8 7a 10 	movl   $0xc0107af8,0xc(%esp)
c010430e:	c0 
c010430f:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104316:	c0 
c0104317:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
c010431e:	00 
c010431f:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104326:	e8 c3 c0 ff ff       	call   c01003ee <__panic>
    struct Page* p=base;
c010432b:	8b 45 08             	mov    0x8(%ebp),%eax
c010432e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(;p!=base + n;p++)
c0104331:	e9 dc 00 00 00       	jmp    c0104412 <buddy_init_memmap+0x119>
    {
        assert(PageReserved(p));
c0104336:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104339:	83 c0 04             	add    $0x4,%eax
c010433c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0104343:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104346:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104349:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010434c:	0f a3 10             	bt     %edx,(%eax)
c010434f:	19 c0                	sbb    %eax,%eax
c0104351:	89 45 dc             	mov    %eax,-0x24(%ebp)
    return oldbit != 0;
c0104354:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0104358:	0f 95 c0             	setne  %al
c010435b:	0f b6 c0             	movzbl %al,%eax
c010435e:	85 c0                	test   %eax,%eax
c0104360:	75 24                	jne    c0104386 <buddy_init_memmap+0x8d>
c0104362:	c7 44 24 0c 21 7b 10 	movl   $0xc0107b21,0xc(%esp)
c0104369:	c0 
c010436a:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104371:	c0 
c0104372:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
c0104379:	00 
c010437a:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104381:	e8 68 c0 ff ff       	call   c01003ee <__panic>
        p->flags = 0;
c0104386:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104389:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property = 1;
c0104390:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104393:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        set_page_ref(p, 0);   
c010439a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01043a1:	00 
c01043a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043a5:	89 04 24             	mov    %eax,(%esp)
c01043a8:	e8 6d fe ff ff       	call   c010421a <set_page_ref>
        SetPageProperty(p);
c01043ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043b0:	83 c0 04             	add    $0x4,%eax
c01043b3:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c01043ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01043bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01043c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01043c3:	0f ab 10             	bts    %edx,(%eax)
        list_add_before(&free_list,&(p->page_link));     
c01043c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01043c9:	83 c0 0c             	add    $0xc,%eax
c01043cc:	c7 45 f0 40 93 1b c0 	movl   $0xc01b9340,-0x10(%ebp)
c01043d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01043d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043d9:	8b 00                	mov    (%eax),%eax
c01043db:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01043de:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01043e1:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01043e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01043e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01043ea:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043ed:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043f0:	89 10                	mov    %edx,(%eax)
c01043f2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01043f5:	8b 10                	mov    (%eax),%edx
c01043f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043fa:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01043fd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104400:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104403:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104406:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104409:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010440c:	89 10                	mov    %edx,(%eax)
static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page* p=base;
    for(;p!=base + n;p++)
c010440e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104412:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104415:	89 d0                	mov    %edx,%eax
c0104417:	c1 e0 02             	shl    $0x2,%eax
c010441a:	01 d0                	add    %edx,%eax
c010441c:	c1 e0 02             	shl    $0x2,%eax
c010441f:	89 c2                	mov    %eax,%edx
c0104421:	8b 45 08             	mov    0x8(%ebp),%eax
c0104424:	01 d0                	add    %edx,%eax
c0104426:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104429:	0f 85 07 ff ff ff    	jne    c0104336 <buddy_init_memmap+0x3d>
        p->property = 1;
        set_page_ref(p, 0);   
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));     
    }
    nr_free += n;
c010442f:	8b 15 48 93 1b c0    	mov    0xc01b9348,%edx
c0104435:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104438:	01 d0                	add    %edx,%eax
c010443a:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
    int allocpages=UINT32_ROUND_DOWN(n);
c010443f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104442:	d1 e8                	shr    %eax
c0104444:	0b 45 0c             	or     0xc(%ebp),%eax
c0104447:	8b 55 0c             	mov    0xc(%ebp),%edx
c010444a:	d1 ea                	shr    %edx
c010444c:	0b 55 0c             	or     0xc(%ebp),%edx
c010444f:	c1 ea 02             	shr    $0x2,%edx
c0104452:	09 d0                	or     %edx,%eax
c0104454:	89 c1                	mov    %eax,%ecx
c0104456:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104459:	d1 e8                	shr    %eax
c010445b:	0b 45 0c             	or     0xc(%ebp),%eax
c010445e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104461:	d1 ea                	shr    %edx
c0104463:	0b 55 0c             	or     0xc(%ebp),%edx
c0104466:	c1 ea 02             	shr    $0x2,%edx
c0104469:	09 d0                	or     %edx,%eax
c010446b:	c1 e8 04             	shr    $0x4,%eax
c010446e:	09 c1                	or     %eax,%ecx
c0104470:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104473:	d1 e8                	shr    %eax
c0104475:	0b 45 0c             	or     0xc(%ebp),%eax
c0104478:	8b 55 0c             	mov    0xc(%ebp),%edx
c010447b:	d1 ea                	shr    %edx
c010447d:	0b 55 0c             	or     0xc(%ebp),%edx
c0104480:	c1 ea 02             	shr    $0x2,%edx
c0104483:	09 d0                	or     %edx,%eax
c0104485:	89 c3                	mov    %eax,%ebx
c0104487:	8b 45 0c             	mov    0xc(%ebp),%eax
c010448a:	d1 e8                	shr    %eax
c010448c:	0b 45 0c             	or     0xc(%ebp),%eax
c010448f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104492:	d1 ea                	shr    %edx
c0104494:	0b 55 0c             	or     0xc(%ebp),%edx
c0104497:	c1 ea 02             	shr    $0x2,%edx
c010449a:	09 d0                	or     %edx,%eax
c010449c:	c1 e8 04             	shr    $0x4,%eax
c010449f:	09 d8                	or     %ebx,%eax
c01044a1:	c1 e8 08             	shr    $0x8,%eax
c01044a4:	09 c1                	or     %eax,%ecx
c01044a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044a9:	d1 e8                	shr    %eax
c01044ab:	0b 45 0c             	or     0xc(%ebp),%eax
c01044ae:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044b1:	d1 ea                	shr    %edx
c01044b3:	0b 55 0c             	or     0xc(%ebp),%edx
c01044b6:	c1 ea 02             	shr    $0x2,%edx
c01044b9:	09 d0                	or     %edx,%eax
c01044bb:	89 c3                	mov    %eax,%ebx
c01044bd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044c0:	d1 e8                	shr    %eax
c01044c2:	0b 45 0c             	or     0xc(%ebp),%eax
c01044c5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044c8:	d1 ea                	shr    %edx
c01044ca:	0b 55 0c             	or     0xc(%ebp),%edx
c01044cd:	c1 ea 02             	shr    $0x2,%edx
c01044d0:	09 d0                	or     %edx,%eax
c01044d2:	c1 e8 04             	shr    $0x4,%eax
c01044d5:	09 c3                	or     %eax,%ebx
c01044d7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044da:	d1 e8                	shr    %eax
c01044dc:	0b 45 0c             	or     0xc(%ebp),%eax
c01044df:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044e2:	d1 ea                	shr    %edx
c01044e4:	0b 55 0c             	or     0xc(%ebp),%edx
c01044e7:	c1 ea 02             	shr    $0x2,%edx
c01044ea:	09 d0                	or     %edx,%eax
c01044ec:	89 c6                	mov    %eax,%esi
c01044ee:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044f1:	d1 e8                	shr    %eax
c01044f3:	0b 45 0c             	or     0xc(%ebp),%eax
c01044f6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01044f9:	d1 ea                	shr    %edx
c01044fb:	0b 55 0c             	or     0xc(%ebp),%edx
c01044fe:	c1 ea 02             	shr    $0x2,%edx
c0104501:	09 d0                	or     %edx,%eax
c0104503:	c1 e8 04             	shr    $0x4,%eax
c0104506:	09 f0                	or     %esi,%eax
c0104508:	c1 e8 08             	shr    $0x8,%eax
c010450b:	09 d8                	or     %ebx,%eax
c010450d:	c1 e8 10             	shr    $0x10,%eax
c0104510:	09 c8                	or     %ecx,%eax
c0104512:	d1 e8                	shr    %eax
c0104514:	23 45 0c             	and    0xc(%ebp),%eax
c0104517:	85 c0                	test   %eax,%eax
c0104519:	0f 84 dc 00 00 00    	je     c01045fb <buddy_init_memmap+0x302>
c010451f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104522:	d1 e8                	shr    %eax
c0104524:	0b 45 0c             	or     0xc(%ebp),%eax
c0104527:	8b 55 0c             	mov    0xc(%ebp),%edx
c010452a:	d1 ea                	shr    %edx
c010452c:	0b 55 0c             	or     0xc(%ebp),%edx
c010452f:	c1 ea 02             	shr    $0x2,%edx
c0104532:	09 d0                	or     %edx,%eax
c0104534:	89 c1                	mov    %eax,%ecx
c0104536:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104539:	d1 e8                	shr    %eax
c010453b:	0b 45 0c             	or     0xc(%ebp),%eax
c010453e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104541:	d1 ea                	shr    %edx
c0104543:	0b 55 0c             	or     0xc(%ebp),%edx
c0104546:	c1 ea 02             	shr    $0x2,%edx
c0104549:	09 d0                	or     %edx,%eax
c010454b:	c1 e8 04             	shr    $0x4,%eax
c010454e:	09 c1                	or     %eax,%ecx
c0104550:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104553:	d1 e8                	shr    %eax
c0104555:	0b 45 0c             	or     0xc(%ebp),%eax
c0104558:	8b 55 0c             	mov    0xc(%ebp),%edx
c010455b:	d1 ea                	shr    %edx
c010455d:	0b 55 0c             	or     0xc(%ebp),%edx
c0104560:	c1 ea 02             	shr    $0x2,%edx
c0104563:	09 d0                	or     %edx,%eax
c0104565:	89 c3                	mov    %eax,%ebx
c0104567:	8b 45 0c             	mov    0xc(%ebp),%eax
c010456a:	d1 e8                	shr    %eax
c010456c:	0b 45 0c             	or     0xc(%ebp),%eax
c010456f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104572:	d1 ea                	shr    %edx
c0104574:	0b 55 0c             	or     0xc(%ebp),%edx
c0104577:	c1 ea 02             	shr    $0x2,%edx
c010457a:	09 d0                	or     %edx,%eax
c010457c:	c1 e8 04             	shr    $0x4,%eax
c010457f:	09 d8                	or     %ebx,%eax
c0104581:	c1 e8 08             	shr    $0x8,%eax
c0104584:	09 c1                	or     %eax,%ecx
c0104586:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104589:	d1 e8                	shr    %eax
c010458b:	0b 45 0c             	or     0xc(%ebp),%eax
c010458e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104591:	d1 ea                	shr    %edx
c0104593:	0b 55 0c             	or     0xc(%ebp),%edx
c0104596:	c1 ea 02             	shr    $0x2,%edx
c0104599:	09 d0                	or     %edx,%eax
c010459b:	89 c3                	mov    %eax,%ebx
c010459d:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045a0:	d1 e8                	shr    %eax
c01045a2:	0b 45 0c             	or     0xc(%ebp),%eax
c01045a5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045a8:	d1 ea                	shr    %edx
c01045aa:	0b 55 0c             	or     0xc(%ebp),%edx
c01045ad:	c1 ea 02             	shr    $0x2,%edx
c01045b0:	09 d0                	or     %edx,%eax
c01045b2:	c1 e8 04             	shr    $0x4,%eax
c01045b5:	09 c3                	or     %eax,%ebx
c01045b7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045ba:	d1 e8                	shr    %eax
c01045bc:	0b 45 0c             	or     0xc(%ebp),%eax
c01045bf:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045c2:	d1 ea                	shr    %edx
c01045c4:	0b 55 0c             	or     0xc(%ebp),%edx
c01045c7:	c1 ea 02             	shr    $0x2,%edx
c01045ca:	09 d0                	or     %edx,%eax
c01045cc:	89 c6                	mov    %eax,%esi
c01045ce:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045d1:	d1 e8                	shr    %eax
c01045d3:	0b 45 0c             	or     0xc(%ebp),%eax
c01045d6:	8b 55 0c             	mov    0xc(%ebp),%edx
c01045d9:	d1 ea                	shr    %edx
c01045db:	0b 55 0c             	or     0xc(%ebp),%edx
c01045de:	c1 ea 02             	shr    $0x2,%edx
c01045e1:	09 d0                	or     %edx,%eax
c01045e3:	c1 e8 04             	shr    $0x4,%eax
c01045e6:	09 f0                	or     %esi,%eax
c01045e8:	c1 e8 08             	shr    $0x8,%eax
c01045eb:	09 d8                	or     %ebx,%eax
c01045ed:	c1 e8 10             	shr    $0x10,%eax
c01045f0:	09 c8                	or     %ecx,%eax
c01045f2:	d1 e8                	shr    %eax
c01045f4:	f7 d0                	not    %eax
c01045f6:	23 45 0c             	and    0xc(%ebp),%eax
c01045f9:	eb 03                	jmp    c01045fe <buddy_init_memmap+0x305>
c01045fb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01045fe:	89 45 e8             	mov    %eax,-0x18(%ebp)
    buddy2_new(allocpages);
c0104601:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104604:	89 04 24             	mov    %eax,(%esp)
c0104607:	e8 7f fc ff ff       	call   c010428b <buddy2_new>
}
c010460c:	90                   	nop
c010460d:	83 c4 40             	add    $0x40,%esp
c0104610:	5b                   	pop    %ebx
c0104611:	5e                   	pop    %esi
c0104612:	5d                   	pop    %ebp
c0104613:	c3                   	ret    

c0104614 <buddy2_alloc>:
//内存分配
int buddy2_alloc(struct buddy2* self, int size) {
c0104614:	55                   	push   %ebp
c0104615:	89 e5                	mov    %esp,%ebp
c0104617:	53                   	push   %ebx
c0104618:	83 ec 14             	sub    $0x14,%esp
  unsigned index = 0;//节点的标号
c010461b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  unsigned node_size;
  unsigned offset = 0;
c0104622:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)

  if (self==NULL)//无法分配
c0104629:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010462d:	75 0a                	jne    c0104639 <buddy2_alloc+0x25>
    return -1;
c010462f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0104634:	e9 64 01 00 00       	jmp    c010479d <buddy2_alloc+0x189>

  if (size <= 0)//分配不合理
c0104639:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010463d:	7f 09                	jg     c0104648 <buddy2_alloc+0x34>
    size = 1;
c010463f:	c7 45 0c 01 00 00 00 	movl   $0x1,0xc(%ebp)
c0104646:	eb 19                	jmp    c0104661 <buddy2_alloc+0x4d>
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
c0104648:	8b 45 0c             	mov    0xc(%ebp),%eax
c010464b:	48                   	dec    %eax
c010464c:	23 45 0c             	and    0xc(%ebp),%eax
c010464f:	85 c0                	test   %eax,%eax
c0104651:	74 0e                	je     c0104661 <buddy2_alloc+0x4d>
    size = fixsize(size);
c0104653:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104656:	89 04 24             	mov    %eax,(%esp)
c0104659:	e8 ca fb ff ff       	call   c0104228 <fixsize>
c010465e:	89 45 0c             	mov    %eax,0xc(%ebp)

  if (self[index].longest < size)//可分配内存不足
c0104661:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104664:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010466b:	8b 45 08             	mov    0x8(%ebp),%eax
c010466e:	01 d0                	add    %edx,%eax
c0104670:	8b 50 04             	mov    0x4(%eax),%edx
c0104673:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104676:	39 c2                	cmp    %eax,%edx
c0104678:	73 0a                	jae    c0104684 <buddy2_alloc+0x70>
    return -1;
c010467a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010467f:	e9 19 01 00 00       	jmp    c010479d <buddy2_alloc+0x189>

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
c0104684:	8b 45 08             	mov    0x8(%ebp),%eax
c0104687:	8b 00                	mov    (%eax),%eax
c0104689:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010468c:	e9 85 00 00 00       	jmp    c0104716 <buddy2_alloc+0x102>
    if (self[LEFT_LEAF(index)].longest >= size)
c0104691:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104694:	c1 e0 04             	shl    $0x4,%eax
c0104697:	8d 50 08             	lea    0x8(%eax),%edx
c010469a:	8b 45 08             	mov    0x8(%ebp),%eax
c010469d:	01 d0                	add    %edx,%eax
c010469f:	8b 50 04             	mov    0x4(%eax),%edx
c01046a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046a5:	39 c2                	cmp    %eax,%edx
c01046a7:	72 5c                	jb     c0104705 <buddy2_alloc+0xf1>
    {
       if(self[RIGHT_LEAF(index)].longest>=size)
c01046a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046ac:	40                   	inc    %eax
c01046ad:	c1 e0 04             	shl    $0x4,%eax
c01046b0:	89 c2                	mov    %eax,%edx
c01046b2:	8b 45 08             	mov    0x8(%ebp),%eax
c01046b5:	01 d0                	add    %edx,%eax
c01046b7:	8b 50 04             	mov    0x4(%eax),%edx
c01046ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046bd:	39 c2                	cmp    %eax,%edx
c01046bf:	72 39                	jb     c01046fa <buddy2_alloc+0xe6>
        {
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
c01046c1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046c4:	c1 e0 04             	shl    $0x4,%eax
c01046c7:	8d 50 08             	lea    0x8(%eax),%edx
c01046ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01046cd:	01 d0                	add    %edx,%eax
c01046cf:	8b 50 04             	mov    0x4(%eax),%edx
c01046d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046d5:	40                   	inc    %eax
c01046d6:	c1 e0 04             	shl    $0x4,%eax
c01046d9:	89 c1                	mov    %eax,%ecx
c01046db:	8b 45 08             	mov    0x8(%ebp),%eax
c01046de:	01 c8                	add    %ecx,%eax
c01046e0:	8b 40 04             	mov    0x4(%eax),%eax
c01046e3:	39 c2                	cmp    %eax,%edx
c01046e5:	77 08                	ja     c01046ef <buddy2_alloc+0xdb>
c01046e7:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046ea:	01 c0                	add    %eax,%eax
c01046ec:	40                   	inc    %eax
c01046ed:	eb 06                	jmp    c01046f5 <buddy2_alloc+0xe1>
c01046ef:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046f2:	40                   	inc    %eax
c01046f3:	01 c0                	add    %eax,%eax
c01046f5:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01046f8:	eb 14                	jmp    c010470e <buddy2_alloc+0xfa>
         //找到两个相符合的节点中内存较小的结点
        }
       else
       {
         index=LEFT_LEAF(index);
c01046fa:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01046fd:	01 c0                	add    %eax,%eax
c01046ff:	40                   	inc    %eax
c0104700:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0104703:	eb 09                	jmp    c010470e <buddy2_alloc+0xfa>
       }  
    }
    else
      index = RIGHT_LEAF(index);
c0104705:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104708:	40                   	inc    %eax
c0104709:	01 c0                	add    %eax,%eax
c010470b:	89 45 f8             	mov    %eax,-0x8(%ebp)
    size = fixsize(size);

  if (self[index].longest < size)//可分配内存不足
    return -1;

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
c010470e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104711:	d1 e8                	shr    %eax
c0104713:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104716:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104719:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010471c:	0f 85 6f ff ff ff    	jne    c0104691 <buddy2_alloc+0x7d>
    }
    else
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
c0104722:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104725:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010472c:	8b 45 08             	mov    0x8(%ebp),%eax
c010472f:	01 d0                	add    %edx,%eax
c0104731:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  offset = (index + 1) * node_size - self->size;
c0104738:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010473b:	40                   	inc    %eax
c010473c:	0f af 45 f4          	imul   -0xc(%ebp),%eax
c0104740:	89 c2                	mov    %eax,%edx
c0104742:	8b 45 08             	mov    0x8(%ebp),%eax
c0104745:	8b 00                	mov    (%eax),%eax
c0104747:	29 c2                	sub    %eax,%edx
c0104749:	89 d0                	mov    %edx,%eax
c010474b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  while (index) {
c010474e:	eb 44                	jmp    c0104794 <buddy2_alloc+0x180>
    index = PARENT(index);
c0104750:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0104753:	40                   	inc    %eax
c0104754:	d1 e8                	shr    %eax
c0104756:	48                   	dec    %eax
c0104757:	89 45 f8             	mov    %eax,-0x8(%ebp)
    self[index].longest = 
c010475a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010475d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104764:	8b 45 08             	mov    0x8(%ebp),%eax
c0104767:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
c010476a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010476d:	40                   	inc    %eax
c010476e:	c1 e0 04             	shl    $0x4,%eax
c0104771:	89 c2                	mov    %eax,%edx
c0104773:	8b 45 08             	mov    0x8(%ebp),%eax
c0104776:	01 d0                	add    %edx,%eax
c0104778:	8b 50 04             	mov    0x4(%eax),%edx
c010477b:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010477e:	c1 e0 04             	shl    $0x4,%eax
c0104781:	8d 58 08             	lea    0x8(%eax),%ebx
c0104784:	8b 45 08             	mov    0x8(%ebp),%eax
c0104787:	01 d8                	add    %ebx,%eax
c0104789:	8b 40 04             	mov    0x4(%eax),%eax
c010478c:	39 c2                	cmp    %eax,%edx
c010478e:	0f 43 c2             	cmovae %edx,%eax

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
    index = PARENT(index);
    self[index].longest = 
c0104791:	89 41 04             	mov    %eax,0x4(%ecx)
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
c0104794:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104798:	75 b6                	jne    c0104750 <buddy2_alloc+0x13c>
    index = PARENT(index);
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  }
//向上刷新，修改先祖结点的数值
  return offset;
c010479a:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c010479d:	83 c4 14             	add    $0x14,%esp
c01047a0:	5b                   	pop    %ebx
c01047a1:	5d                   	pop    %ebp
c01047a2:	c3                   	ret    

c01047a3 <buddy_alloc_pages>:

static struct Page*
buddy_alloc_pages(size_t n){
c01047a3:	55                   	push   %ebp
c01047a4:	89 e5                	mov    %esp,%ebp
c01047a6:	53                   	push   %ebx
c01047a7:	83 ec 44             	sub    $0x44,%esp
    assert(n>0);
c01047aa:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01047ae:	75 24                	jne    c01047d4 <buddy_alloc_pages+0x31>
c01047b0:	c7 44 24 0c f8 7a 10 	movl   $0xc0107af8,0xc(%esp)
c01047b7:	c0 
c01047b8:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c01047bf:	c0 
c01047c0:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
c01047c7:	00 
c01047c8:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c01047cf:	e8 1a bc ff ff       	call   c01003ee <__panic>
    if(n>nr_free)
c01047d4:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c01047d9:	3b 45 08             	cmp    0x8(%ebp),%eax
c01047dc:	73 0a                	jae    c01047e8 <buddy_alloc_pages+0x45>
        return NULL;
c01047de:	b8 00 00 00 00       	mov    $0x0,%eax
c01047e3:	e9 41 01 00 00       	jmp    c0104929 <buddy_alloc_pages+0x186>
    struct Page* page=NULL;
c01047e8:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    struct Page* p;
    list_entry_t *le=&free_list,*len;
c01047ef:	c7 45 f4 40 93 1b c0 	movl   $0xc01b9340,-0xc(%ebp)
    rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
c01047f6:	8b 1d 20 cf 11 c0    	mov    0xc011cf20,%ebx
c01047fc:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104803:	c7 04 24 40 cf 11 c0 	movl   $0xc011cf40,(%esp)
c010480a:	e8 05 fe ff ff       	call   c0104614 <buddy2_alloc>
c010480f:	89 c2                	mov    %eax,%edx
c0104811:	89 d8                	mov    %ebx,%eax
c0104813:	01 c0                	add    %eax,%eax
c0104815:	01 d8                	add    %ebx,%eax
c0104817:	c1 e0 02             	shl    $0x2,%eax
c010481a:	05 64 93 1b c0       	add    $0xc01b9364,%eax
c010481f:	89 10                	mov    %edx,(%eax)
    int i;
    for(i=0;i<rec[nr_block].offset+1;i++)
c0104821:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0104828:	eb 12                	jmp    c010483c <buddy_alloc_pages+0x99>
c010482a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010482d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104830:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104833:	8b 40 04             	mov    0x4(%eax),%eax
        le=list_next(le);
c0104836:	89 45 f4             	mov    %eax,-0xc(%ebp)
    struct Page* page=NULL;
    struct Page* p;
    list_entry_t *le=&free_list,*len;
    rec[nr_block].offset=buddy2_alloc(root,n);//记录偏移量
    int i;
    for(i=0;i<rec[nr_block].offset+1;i++)
c0104839:	ff 45 f0             	incl   -0x10(%ebp)
c010483c:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0104842:	89 d0                	mov    %edx,%eax
c0104844:	01 c0                	add    %eax,%eax
c0104846:	01 d0                	add    %edx,%eax
c0104848:	c1 e0 02             	shl    $0x2,%eax
c010484b:	05 64 93 1b c0       	add    $0xc01b9364,%eax
c0104850:	8b 00                	mov    (%eax),%eax
c0104852:	40                   	inc    %eax
c0104853:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104856:	7f d2                	jg     c010482a <buddy_alloc_pages+0x87>
        le=list_next(le);
    page=le2page(le,page_link);
c0104858:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010485b:	83 e8 0c             	sub    $0xc,%eax
c010485e:	89 45 e8             	mov    %eax,-0x18(%ebp)
    int allocpages;
    if(!IS_POWER_OF_2(n))
c0104861:	8b 45 08             	mov    0x8(%ebp),%eax
c0104864:	48                   	dec    %eax
c0104865:	23 45 08             	and    0x8(%ebp),%eax
c0104868:	85 c0                	test   %eax,%eax
c010486a:	74 10                	je     c010487c <buddy_alloc_pages+0xd9>
        allocpages=fixsize(n);
c010486c:	8b 45 08             	mov    0x8(%ebp),%eax
c010486f:	89 04 24             	mov    %eax,(%esp)
c0104872:	e8 b1 f9 ff ff       	call   c0104228 <fixsize>
c0104877:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010487a:	eb 06                	jmp    c0104882 <buddy_alloc_pages+0xdf>
    else
    {
        allocpages=n;
c010487c:	8b 45 08             	mov    0x8(%ebp),%eax
c010487f:	89 45 ec             	mov    %eax,-0x14(%ebp)
    }
    //根据需求n得到块大小
    rec[nr_block].base=page;//记录分配块首页
c0104882:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c0104888:	89 d0                	mov    %edx,%eax
c010488a:	01 c0                	add    %eax,%eax
c010488c:	01 d0                	add    %edx,%eax
c010488e:	c1 e0 02             	shl    $0x2,%eax
c0104891:	8d 90 60 93 1b c0    	lea    -0x3fe46ca0(%eax),%edx
c0104897:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010489a:	89 02                	mov    %eax,(%edx)
    rec[nr_block].nr=allocpages;//记录分配的页数
c010489c:	8b 15 20 cf 11 c0    	mov    0xc011cf20,%edx
c01048a2:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c01048a5:	89 d0                	mov    %edx,%eax
c01048a7:	01 c0                	add    %eax,%eax
c01048a9:	01 d0                	add    %edx,%eax
c01048ab:	c1 e0 02             	shl    $0x2,%eax
c01048ae:	05 68 93 1b c0       	add    $0xc01b9368,%eax
c01048b3:	89 08                	mov    %ecx,(%eax)
    nr_block++;
c01048b5:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c01048ba:	40                   	inc    %eax
c01048bb:	a3 20 cf 11 c0       	mov    %eax,0xc011cf20
    for(i=0;i<allocpages;i++)
c01048c0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c01048c7:	eb 3a                	jmp    c0104903 <buddy_alloc_pages+0x160>
c01048c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01048cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01048d2:	8b 40 04             	mov    0x4(%eax),%eax
    {
        len=list_next(le);
c01048d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
        p=le2page(le,page_link);
c01048d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048db:	83 e8 0c             	sub    $0xc,%eax
c01048de:	89 45 dc             	mov    %eax,-0x24(%ebp)
        ClearPageProperty(p);
c01048e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01048e4:	83 c0 04             	add    $0x4,%eax
c01048e7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01048ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01048f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01048f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01048f7:	0f b3 10             	btr    %edx,(%eax)
        le=len;
c01048fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048fd:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    //根据需求n得到块大小
    rec[nr_block].base=page;//记录分配块首页
    rec[nr_block].nr=allocpages;//记录分配的页数
    nr_block++;
    for(i=0;i<allocpages;i++)
c0104900:	ff 45 f0             	incl   -0x10(%ebp)
c0104903:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104906:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104909:	7c be                	jl     c01048c9 <buddy_alloc_pages+0x126>
        len=list_next(le);
        p=le2page(le,page_link);
        ClearPageProperty(p);
        le=len;
    }//修改每一页的状态
    nr_free-=allocpages;//减去已被分配的页数
c010490b:	8b 15 48 93 1b c0    	mov    0xc01b9348,%edx
c0104911:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104914:	29 c2                	sub    %eax,%edx
c0104916:	89 d0                	mov    %edx,%eax
c0104918:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
    page->property=n;
c010491d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104920:	8b 55 08             	mov    0x8(%ebp),%edx
c0104923:	89 50 08             	mov    %edx,0x8(%eax)
    return page;
c0104926:	8b 45 e8             	mov    -0x18(%ebp),%eax
}
c0104929:	83 c4 44             	add    $0x44,%esp
c010492c:	5b                   	pop    %ebx
c010492d:	5d                   	pop    %ebp
c010492e:	c3                   	ret    

c010492f <buddy_free_pages>:

void buddy_free_pages(struct Page* base, size_t n) {
c010492f:	55                   	push   %ebp
c0104930:	89 e5                	mov    %esp,%ebp
c0104932:	83 ec 58             	sub    $0x58,%esp
    unsigned node_size, index = 0;
c0104935:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    unsigned left_longest, right_longest;
    struct buddy2* self=root;
c010493c:	c7 45 e0 40 cf 11 c0 	movl   $0xc011cf40,-0x20(%ebp)
c0104943:	c7 45 bc 40 93 1b c0 	movl   $0xc01b9340,-0x44(%ebp)
c010494a:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010494d:	8b 40 04             	mov    0x4(%eax),%eax

    list_entry_t *le=list_next(&free_list);
c0104950:	89 45 ec             	mov    %eax,-0x14(%ebp)
    int i=0;
c0104953:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    for(i=0;i<nr_block;i++)//找到块
c010495a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104961:	eb 1b                	jmp    c010497e <buddy_free_pages+0x4f>
    {
    if(rec[i].base==base)
c0104963:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104966:	89 d0                	mov    %edx,%eax
c0104968:	01 c0                	add    %eax,%eax
c010496a:	01 d0                	add    %edx,%eax
c010496c:	c1 e0 02             	shl    $0x2,%eax
c010496f:	05 60 93 1b c0       	add    $0xc01b9360,%eax
c0104974:	8b 00                	mov    (%eax),%eax
c0104976:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104979:	74 0f                	je     c010498a <buddy_free_pages+0x5b>
    unsigned left_longest, right_longest;
    struct buddy2* self=root;

    list_entry_t *le=list_next(&free_list);
    int i=0;
    for(i=0;i<nr_block;i++)//找到块
c010497b:	ff 45 e8             	incl   -0x18(%ebp)
c010497e:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0104983:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104986:	7c db                	jl     c0104963 <buddy_free_pages+0x34>
c0104988:	eb 01                	jmp    c010498b <buddy_free_pages+0x5c>
    {
    if(rec[i].base==base)
        break;
c010498a:	90                   	nop
    }
    int offset=rec[i].offset;
c010498b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010498e:	89 d0                	mov    %edx,%eax
c0104990:	01 c0                	add    %eax,%eax
c0104992:	01 d0                	add    %edx,%eax
c0104994:	c1 e0 02             	shl    $0x2,%eax
c0104997:	05 64 93 1b c0       	add    $0xc01b9364,%eax
c010499c:	8b 00                	mov    (%eax),%eax
c010499e:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int pos=i;//暂存i
c01049a1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01049a4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    i=0;
c01049a7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
    while(i<offset)
c01049ae:	eb 12                	jmp    c01049c2 <buddy_free_pages+0x93>
c01049b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01049b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01049b9:	8b 40 04             	mov    0x4(%eax),%eax
    {
    le=list_next(le);
c01049bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
    i++;
c01049bf:	ff 45 e8             	incl   -0x18(%ebp)
        break;
    }
    int offset=rec[i].offset;
    int pos=i;//暂存i
    i=0;
    while(i<offset)
c01049c2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01049c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
c01049c8:	7c e6                	jl     c01049b0 <buddy_free_pages+0x81>
    {
    le=list_next(le);
    i++;
    }
    int allocpages;
    if(!IS_POWER_OF_2(n))
c01049ca:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049cd:	48                   	dec    %eax
c01049ce:	23 45 0c             	and    0xc(%ebp),%eax
c01049d1:	85 c0                	test   %eax,%eax
c01049d3:	74 10                	je     c01049e5 <buddy_free_pages+0xb6>
    allocpages=fixsize(n);
c01049d5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049d8:	89 04 24             	mov    %eax,(%esp)
c01049db:	e8 48 f8 ff ff       	call   c0104228 <fixsize>
c01049e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01049e3:	eb 06                	jmp    c01049eb <buddy_free_pages+0xbc>
    else
    {
        allocpages=n;
c01049e5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01049e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    }
    assert(self && offset >= 0 && offset < self->size);//是否合法
c01049eb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01049ef:	74 12                	je     c0104a03 <buddy_free_pages+0xd4>
c01049f1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c01049f5:	78 0c                	js     c0104a03 <buddy_free_pages+0xd4>
c01049f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049fa:	8b 10                	mov    (%eax),%edx
c01049fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01049ff:	39 c2                	cmp    %eax,%edx
c0104a01:	77 24                	ja     c0104a27 <buddy_free_pages+0xf8>
c0104a03:	c7 44 24 0c 34 7b 10 	movl   $0xc0107b34,0xc(%esp)
c0104a0a:	c0 
c0104a0b:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104a12:	c0 
c0104a13:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104a1a:	00 
c0104a1b:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104a22:	e8 c7 b9 ff ff       	call   c01003ee <__panic>
    node_size = 1;
c0104a27:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    index = offset + self->size - 1;
c0104a2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a31:	8b 10                	mov    (%eax),%edx
c0104a33:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104a36:	01 d0                	add    %edx,%eax
c0104a38:	48                   	dec    %eax
c0104a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
    nr_free+=allocpages;//更新空闲页的数量
c0104a3c:	8b 15 48 93 1b c0    	mov    0xc01b9348,%edx
c0104a42:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a45:	01 d0                	add    %edx,%eax
c0104a47:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
    struct Page* p;
    self[index].longest = allocpages;
c0104a4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104a4f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104a56:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a59:	01 c2                	add    %eax,%edx
c0104a5b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104a5e:	89 42 04             	mov    %eax,0x4(%edx)
    for(i=0;i<allocpages;i++)//回收已分配的页
c0104a61:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0104a68:	eb 48                	jmp    c0104ab2 <buddy_free_pages+0x183>
    {
        p=le2page(le,page_link);
c0104a6a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a6d:	83 e8 0c             	sub    $0xc,%eax
c0104a70:	89 45 cc             	mov    %eax,-0x34(%ebp)
        p->flags=0;
c0104a73:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104a76:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        p->property=1;
c0104a7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104a80:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
        SetPageProperty(p);
c0104a87:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104a8a:	83 c0 04             	add    $0x4,%eax
c0104a8d:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0104a94:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104a97:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0104a9a:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0104a9d:	0f ab 10             	bts    %edx,(%eax)
c0104aa0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104aa3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104aa6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104aa9:	8b 40 04             	mov    0x4(%eax),%eax
        le=list_next(le);
c0104aac:	89 45 ec             	mov    %eax,-0x14(%ebp)
    node_size = 1;
    index = offset + self->size - 1;
    nr_free+=allocpages;//更新空闲页的数量
    struct Page* p;
    self[index].longest = allocpages;
    for(i=0;i<allocpages;i++)//回收已分配的页
c0104aaf:	ff 45 e8             	incl   -0x18(%ebp)
c0104ab2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ab5:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
c0104ab8:	7c b0                	jl     c0104a6a <buddy_free_pages+0x13b>
        p->flags=0;
        p->property=1;
        SetPageProperty(p);
        le=list_next(le);
    }
    while (index) {//向上合并，修改先祖节点的记录值
c0104aba:	eb 75                	jmp    c0104b31 <buddy_free_pages+0x202>
    index = PARENT(index);
c0104abc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104abf:	40                   	inc    %eax
c0104ac0:	d1 e8                	shr    %eax
c0104ac2:	48                   	dec    %eax
c0104ac3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    node_size *= 2;
c0104ac6:	d1 65 f4             	shll   -0xc(%ebp)

    left_longest = self[LEFT_LEAF(index)].longest;
c0104ac9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104acc:	c1 e0 04             	shl    $0x4,%eax
c0104acf:	8d 50 08             	lea    0x8(%eax),%edx
c0104ad2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ad5:	01 d0                	add    %edx,%eax
c0104ad7:	8b 40 04             	mov    0x4(%eax),%eax
c0104ada:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    right_longest = self[RIGHT_LEAF(index)].longest;
c0104add:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ae0:	40                   	inc    %eax
c0104ae1:	c1 e0 04             	shl    $0x4,%eax
c0104ae4:	89 c2                	mov    %eax,%edx
c0104ae6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104ae9:	01 d0                	add    %edx,%eax
c0104aeb:	8b 40 04             	mov    0x4(%eax),%eax
c0104aee:	89 45 c0             	mov    %eax,-0x40(%ebp)

    if (left_longest + right_longest == node_size) 
c0104af1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0104af4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104af7:	01 d0                	add    %edx,%eax
c0104af9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104afc:	75 17                	jne    c0104b15 <buddy_free_pages+0x1e6>
        self[index].longest = node_size;
c0104afe:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b01:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104b08:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b0b:	01 c2                	add    %eax,%edx
c0104b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b10:	89 42 04             	mov    %eax,0x4(%edx)
c0104b13:	eb 1c                	jmp    c0104b31 <buddy_free_pages+0x202>
    else
        self[index].longest = MAX(left_longest, right_longest);
c0104b15:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b18:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0104b1f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104b22:	01 c2                	add    %eax,%edx
c0104b24:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104b27:	39 45 c0             	cmp    %eax,-0x40(%ebp)
c0104b2a:	0f 43 45 c0          	cmovae -0x40(%ebp),%eax
c0104b2e:	89 42 04             	mov    %eax,0x4(%edx)
        p->flags=0;
        p->property=1;
        SetPageProperty(p);
        le=list_next(le);
    }
    while (index) {//向上合并，修改先祖节点的记录值
c0104b31:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b35:	75 85                	jne    c0104abc <buddy_free_pages+0x18d>
    if (left_longest + right_longest == node_size) 
        self[index].longest = node_size;
    else
        self[index].longest = MAX(left_longest, right_longest);
    }
    for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
c0104b37:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104b3a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104b3d:	eb 39                	jmp    c0104b78 <buddy_free_pages+0x249>
    {
    rec[i]=rec[i+1];
c0104b3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b42:	8d 48 01             	lea    0x1(%eax),%ecx
c0104b45:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0104b48:	89 d0                	mov    %edx,%eax
c0104b4a:	01 c0                	add    %eax,%eax
c0104b4c:	01 d0                	add    %edx,%eax
c0104b4e:	c1 e0 02             	shl    $0x2,%eax
c0104b51:	8d 90 60 93 1b c0    	lea    -0x3fe46ca0(%eax),%edx
c0104b57:	89 c8                	mov    %ecx,%eax
c0104b59:	01 c0                	add    %eax,%eax
c0104b5b:	01 c8                	add    %ecx,%eax
c0104b5d:	c1 e0 02             	shl    $0x2,%eax
c0104b60:	05 60 93 1b c0       	add    $0xc01b9360,%eax
c0104b65:	8b 08                	mov    (%eax),%ecx
c0104b67:	89 0a                	mov    %ecx,(%edx)
c0104b69:	8b 48 04             	mov    0x4(%eax),%ecx
c0104b6c:	89 4a 04             	mov    %ecx,0x4(%edx)
c0104b6f:	8b 40 08             	mov    0x8(%eax),%eax
c0104b72:	89 42 08             	mov    %eax,0x8(%edx)
    if (left_longest + right_longest == node_size) 
        self[index].longest = node_size;
    else
        self[index].longest = MAX(left_longest, right_longest);
    }
    for(i=pos;i<nr_block-1;i++)//清除此次的分配记录
c0104b75:	ff 45 e8             	incl   -0x18(%ebp)
c0104b78:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0104b7d:	48                   	dec    %eax
c0104b7e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0104b81:	7f bc                	jg     c0104b3f <buddy_free_pages+0x210>
    {
    rec[i]=rec[i+1];
    }
    nr_block--;//更新分配块数的值
c0104b83:	a1 20 cf 11 c0       	mov    0xc011cf20,%eax
c0104b88:	48                   	dec    %eax
c0104b89:	a3 20 cf 11 c0       	mov    %eax,0xc011cf20
}
c0104b8e:	90                   	nop
c0104b8f:	c9                   	leave  
c0104b90:	c3                   	ret    

c0104b91 <buddy_nr_free_pages>:

static size_t
buddy_nr_free_pages(void) {
c0104b91:	55                   	push   %ebp
c0104b92:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104b94:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
}
c0104b99:	5d                   	pop    %ebp
c0104b9a:	c3                   	ret    

c0104b9b <buddy_check>:

//以下是一个测试函数
static void

buddy_check(void) {
c0104b9b:	55                   	push   %ebp
c0104b9c:	89 e5                	mov    %esp,%ebp
c0104b9e:	83 ec 38             	sub    $0x38,%esp
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;
c0104ba1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104ba8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bab:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104bae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104bb1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104bb4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104bb7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104bba:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104bbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    assert((p0 = alloc_page()) != NULL);
c0104bc0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104bc7:	e8 a4 df ff ff       	call   c0102b70 <alloc_pages>
c0104bcc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104bcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104bd3:	75 24                	jne    c0104bf9 <buddy_check+0x5e>
c0104bd5:	c7 44 24 0c 5f 7b 10 	movl   $0xc0107b5f,0xc(%esp)
c0104bdc:	c0 
c0104bdd:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104be4:	c0 
c0104be5:	c7 44 24 04 f7 00 00 	movl   $0xf7,0x4(%esp)
c0104bec:	00 
c0104bed:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104bf4:	e8 f5 b7 ff ff       	call   c01003ee <__panic>
    assert((A = alloc_page()) != NULL);
c0104bf9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c00:	e8 6b df ff ff       	call   c0102b70 <alloc_pages>
c0104c05:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104c08:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104c0c:	75 24                	jne    c0104c32 <buddy_check+0x97>
c0104c0e:	c7 44 24 0c 7b 7b 10 	movl   $0xc0107b7b,0xc(%esp)
c0104c15:	c0 
c0104c16:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104c1d:	c0 
c0104c1e:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c0104c25:	00 
c0104c26:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104c2d:	e8 bc b7 ff ff       	call   c01003ee <__panic>
    assert((B = alloc_page()) != NULL);
c0104c32:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104c39:	e8 32 df ff ff       	call   c0102b70 <alloc_pages>
c0104c3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c41:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104c45:	75 24                	jne    c0104c6b <buddy_check+0xd0>
c0104c47:	c7 44 24 0c 96 7b 10 	movl   $0xc0107b96,0xc(%esp)
c0104c4e:	c0 
c0104c4f:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104c56:	c0 
c0104c57:	c7 44 24 04 f9 00 00 	movl   $0xf9,0x4(%esp)
c0104c5e:	00 
c0104c5f:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104c66:	e8 83 b7 ff ff       	call   c01003ee <__panic>

    assert(p0 != A && p0 != B && A != B);
c0104c6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c6e:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0104c71:	74 10                	je     c0104c83 <buddy_check+0xe8>
c0104c73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104c76:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104c79:	74 08                	je     c0104c83 <buddy_check+0xe8>
c0104c7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104c7e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104c81:	75 24                	jne    c0104ca7 <buddy_check+0x10c>
c0104c83:	c7 44 24 0c b1 7b 10 	movl   $0xc0107bb1,0xc(%esp)
c0104c8a:	c0 
c0104c8b:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104c92:	c0 
c0104c93:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0104c9a:	00 
c0104c9b:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104ca2:	e8 47 b7 ff ff       	call   c01003ee <__panic>
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
c0104ca7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104caa:	89 04 24             	mov    %eax,(%esp)
c0104cad:	e8 5e f5 ff ff       	call   c0104210 <page_ref>
c0104cb2:	85 c0                	test   %eax,%eax
c0104cb4:	75 1e                	jne    c0104cd4 <buddy_check+0x139>
c0104cb6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104cb9:	89 04 24             	mov    %eax,(%esp)
c0104cbc:	e8 4f f5 ff ff       	call   c0104210 <page_ref>
c0104cc1:	85 c0                	test   %eax,%eax
c0104cc3:	75 0f                	jne    c0104cd4 <buddy_check+0x139>
c0104cc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104cc8:	89 04 24             	mov    %eax,(%esp)
c0104ccb:	e8 40 f5 ff ff       	call   c0104210 <page_ref>
c0104cd0:	85 c0                	test   %eax,%eax
c0104cd2:	74 24                	je     c0104cf8 <buddy_check+0x15d>
c0104cd4:	c7 44 24 0c d0 7b 10 	movl   $0xc0107bd0,0xc(%esp)
c0104cdb:	c0 
c0104cdc:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104ce3:	c0 
c0104ce4:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0104ceb:	00 
c0104cec:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104cf3:	e8 f6 b6 ff ff       	call   c01003ee <__panic>
    free_page(p0);
c0104cf8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104cff:	00 
c0104d00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104d03:	89 04 24             	mov    %eax,(%esp)
c0104d06:	e8 9d de ff ff       	call   c0102ba8 <free_pages>
    free_page(A);
c0104d0b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d12:	00 
c0104d13:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d16:	89 04 24             	mov    %eax,(%esp)
c0104d19:	e8 8a de ff ff       	call   c0102ba8 <free_pages>
    free_page(B);
c0104d1e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104d25:	00 
c0104d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d29:	89 04 24             	mov    %eax,(%esp)
c0104d2c:	e8 77 de ff ff       	call   c0102ba8 <free_pages>
    
    A=alloc_pages(500);
c0104d31:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
c0104d38:	e8 33 de ff ff       	call   c0102b70 <alloc_pages>
c0104d3d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    B=alloc_pages(500);
c0104d40:	c7 04 24 f4 01 00 00 	movl   $0x1f4,(%esp)
c0104d47:	e8 24 de ff ff       	call   c0102b70 <alloc_pages>
c0104d4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    cprintf("A %p\n",A);
c0104d4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d52:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d56:	c7 04 24 0a 7c 10 c0 	movl   $0xc0107c0a,(%esp)
c0104d5d:	e8 35 b5 ff ff       	call   c0100297 <cprintf>
    cprintf("B %p\n",B);
c0104d62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d65:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104d69:	c7 04 24 10 7c 10 c0 	movl   $0xc0107c10,(%esp)
c0104d70:	e8 22 b5 ff ff       	call   c0100297 <cprintf>
    free_pages(A,250);
c0104d75:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104d7c:	00 
c0104d7d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d80:	89 04 24             	mov    %eax,(%esp)
c0104d83:	e8 20 de ff ff       	call   c0102ba8 <free_pages>
    free_pages(B,500);
c0104d88:	c7 44 24 04 f4 01 00 	movl   $0x1f4,0x4(%esp)
c0104d8f:	00 
c0104d90:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d93:	89 04 24             	mov    %eax,(%esp)
c0104d96:	e8 0d de ff ff       	call   c0102ba8 <free_pages>
    free_pages(A+250,250);
c0104d9b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104d9e:	05 88 13 00 00       	add    $0x1388,%eax
c0104da3:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0104daa:	00 
c0104dab:	89 04 24             	mov    %eax,(%esp)
c0104dae:	e8 f5 dd ff ff       	call   c0102ba8 <free_pages>
    
    p0=alloc_pages(1024);
c0104db3:	c7 04 24 00 04 00 00 	movl   $0x400,(%esp)
c0104dba:	e8 b1 dd ff ff       	call   c0102b70 <alloc_pages>
c0104dbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    cprintf("p0 %p\n",p0);
c0104dc2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104dc9:	c7 04 24 16 7c 10 c0 	movl   $0xc0107c16,(%esp)
c0104dd0:	e8 c2 b4 ff ff       	call   c0100297 <cprintf>
    assert(p0 == A);
c0104dd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104dd8:	3b 45 e8             	cmp    -0x18(%ebp),%eax
c0104ddb:	74 24                	je     c0104e01 <buddy_check+0x266>
c0104ddd:	c7 44 24 0c 1d 7c 10 	movl   $0xc0107c1d,0xc(%esp)
c0104de4:	c0 
c0104de5:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104dec:	c0 
c0104ded:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c0104df4:	00 
c0104df5:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104dfc:	e8 ed b5 ff ff       	call   c01003ee <__panic>
    //以下是根据链接中的样例测试编写的
    A=alloc_pages(70);  
c0104e01:	c7 04 24 46 00 00 00 	movl   $0x46,(%esp)
c0104e08:	e8 63 dd ff ff       	call   c0102b70 <alloc_pages>
c0104e0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    B=alloc_pages(35);
c0104e10:	c7 04 24 23 00 00 00 	movl   $0x23,(%esp)
c0104e17:	e8 54 dd ff ff       	call   c0102b70 <alloc_pages>
c0104e1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(A+128==B);//检查是否相邻
c0104e1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e22:	05 00 0a 00 00       	add    $0xa00,%eax
c0104e27:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0104e2a:	74 24                	je     c0104e50 <buddy_check+0x2b5>
c0104e2c:	c7 44 24 0c 25 7c 10 	movl   $0xc0107c25,0xc(%esp)
c0104e33:	c0 
c0104e34:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104e3b:	c0 
c0104e3c:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0104e43:	00 
c0104e44:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104e4b:	e8 9e b5 ff ff       	call   c01003ee <__panic>
    cprintf("A %p\n",A);
c0104e50:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e57:	c7 04 24 0a 7c 10 c0 	movl   $0xc0107c0a,(%esp)
c0104e5e:	e8 34 b4 ff ff       	call   c0100297 <cprintf>
    cprintf("B %p\n",B);
c0104e63:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104e6a:	c7 04 24 10 7c 10 c0 	movl   $0xc0107c10,(%esp)
c0104e71:	e8 21 b4 ff ff       	call   c0100297 <cprintf>
    C=alloc_pages(80);
c0104e76:	c7 04 24 50 00 00 00 	movl   $0x50,(%esp)
c0104e7d:	e8 ee dc ff ff       	call   c0102b70 <alloc_pages>
c0104e82:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(A+256==C);//检查C有没有和A重叠
c0104e85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104e88:	05 00 14 00 00       	add    $0x1400,%eax
c0104e8d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104e90:	74 24                	je     c0104eb6 <buddy_check+0x31b>
c0104e92:	c7 44 24 0c 2e 7c 10 	movl   $0xc0107c2e,0xc(%esp)
c0104e99:	c0 
c0104e9a:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104ea1:	c0 
c0104ea2:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c0104ea9:	00 
c0104eaa:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104eb1:	e8 38 b5 ff ff       	call   c01003ee <__panic>
    cprintf("C %p\n",C);
c0104eb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104eb9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ebd:	c7 04 24 37 7c 10 c0 	movl   $0xc0107c37,(%esp)
c0104ec4:	e8 ce b3 ff ff       	call   c0100297 <cprintf>
    free_pages(A,70);//释放A
c0104ec9:	c7 44 24 04 46 00 00 	movl   $0x46,0x4(%esp)
c0104ed0:	00 
c0104ed1:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104ed4:	89 04 24             	mov    %eax,(%esp)
c0104ed7:	e8 cc dc ff ff       	call   c0102ba8 <free_pages>
    cprintf("B %p\n",B);
c0104edc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104edf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104ee3:	c7 04 24 10 7c 10 c0 	movl   $0xc0107c10,(%esp)
c0104eea:	e8 a8 b3 ff ff       	call   c0100297 <cprintf>
    D=alloc_pages(60);
c0104eef:	c7 04 24 3c 00 00 00 	movl   $0x3c,(%esp)
c0104ef6:	e8 75 dc ff ff       	call   c0102b70 <alloc_pages>
c0104efb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("D %p\n",D);
c0104efe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f05:	c7 04 24 3d 7c 10 c0 	movl   $0xc0107c3d,(%esp)
c0104f0c:	e8 86 b3 ff ff       	call   c0100297 <cprintf>
    assert(B+64==D);//检查B，D是否相邻
c0104f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f14:	05 00 05 00 00       	add    $0x500,%eax
c0104f19:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104f1c:	74 24                	je     c0104f42 <buddy_check+0x3a7>
c0104f1e:	c7 44 24 0c 43 7c 10 	movl   $0xc0107c43,0xc(%esp)
c0104f25:	c0 
c0104f26:	c7 44 24 08 fc 7a 10 	movl   $0xc0107afc,0x8(%esp)
c0104f2d:	c0 
c0104f2e:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0104f35:	00 
c0104f36:	c7 04 24 11 7b 10 c0 	movl   $0xc0107b11,(%esp)
c0104f3d:	e8 ac b4 ff ff       	call   c01003ee <__panic>
    free_pages(B,35);
c0104f42:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
c0104f49:	00 
c0104f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f4d:	89 04 24             	mov    %eax,(%esp)
c0104f50:	e8 53 dc ff ff       	call   c0102ba8 <free_pages>
    cprintf("D %p\n",D);
c0104f55:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f58:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f5c:	c7 04 24 3d 7c 10 c0 	movl   $0xc0107c3d,(%esp)
c0104f63:	e8 2f b3 ff ff       	call   c0100297 <cprintf>
    free_pages(D,60);
c0104f68:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
c0104f6f:	00 
c0104f70:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f73:	89 04 24             	mov    %eax,(%esp)
c0104f76:	e8 2d dc ff ff       	call   c0102ba8 <free_pages>
    cprintf("C %p\n",C);
c0104f7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104f82:	c7 04 24 37 7c 10 c0 	movl   $0xc0107c37,(%esp)
c0104f89:	e8 09 b3 ff ff       	call   c0100297 <cprintf>
    free_pages(C,80);
c0104f8e:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
c0104f95:	00 
c0104f96:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f99:	89 04 24             	mov    %eax,(%esp)
c0104f9c:	e8 07 dc ff ff       	call   c0102ba8 <free_pages>
    free_pages(p0,1000);//全部释放
c0104fa1:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
c0104fa8:	00 
c0104fa9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fac:	89 04 24             	mov    %eax,(%esp)
c0104faf:	e8 f4 db ff ff       	call   c0102ba8 <free_pages>
}
c0104fb4:	90                   	nop
c0104fb5:	c9                   	leave  
c0104fb6:	c3                   	ret    

c0104fb7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104fb7:	55                   	push   %ebp
c0104fb8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104fba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fbd:	8b 15 18 cf 11 c0    	mov    0xc011cf18,%edx
c0104fc3:	29 d0                	sub    %edx,%eax
c0104fc5:	c1 f8 02             	sar    $0x2,%eax
c0104fc8:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0104fce:	5d                   	pop    %ebp
c0104fcf:	c3                   	ret    

c0104fd0 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0104fd0:	55                   	push   %ebp
c0104fd1:	89 e5                	mov    %esp,%ebp
c0104fd3:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104fd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fd9:	89 04 24             	mov    %eax,(%esp)
c0104fdc:	e8 d6 ff ff ff       	call   c0104fb7 <page2ppn>
c0104fe1:	c1 e0 0c             	shl    $0xc,%eax
}
c0104fe4:	c9                   	leave  
c0104fe5:	c3                   	ret    

c0104fe6 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104fe6:	55                   	push   %ebp
c0104fe7:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104fe9:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fec:	8b 00                	mov    (%eax),%eax
}
c0104fee:	5d                   	pop    %ebp
c0104fef:	c3                   	ret    

c0104ff0 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0104ff0:	55                   	push   %ebp
c0104ff1:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104ff3:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ff6:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104ff9:	89 10                	mov    %edx,(%eax)
}
c0104ffb:	90                   	nop
c0104ffc:	5d                   	pop    %ebp
c0104ffd:	c3                   	ret    

c0104ffe <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0104ffe:	55                   	push   %ebp
c0104fff:	89 e5                	mov    %esp,%ebp
c0105001:	83 ec 10             	sub    $0x10,%esp
c0105004:	c7 45 fc 40 93 1b c0 	movl   $0xc01b9340,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010500b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010500e:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0105011:	89 50 04             	mov    %edx,0x4(%eax)
c0105014:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105017:	8b 50 04             	mov    0x4(%eax),%edx
c010501a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010501d:	89 10                	mov    %edx,(%eax)
    // 初始化链表
    list_init(&free_list);
    // 将可用内存块数目设置为0
    nr_free = 0;
c010501f:	c7 05 48 93 1b c0 00 	movl   $0x0,0xc01b9348
c0105026:	00 00 00 
}
c0105029:	90                   	nop
c010502a:	c9                   	leave  
c010502b:	c3                   	ret    

c010502c <default_init_memmap>:

// 根据每个物理页帧的情况来建立空闲页链表，且空闲页块应该是根据地址高低形成一个有序链表
// 参数：base->某个连续地址的空闲块的起始页；n->页个数
static void
default_init_memmap(struct Page *base, size_t n) {
c010502c:	55                   	push   %ebp
c010502d:	89 e5                	mov    %esp,%ebp
c010502f:	83 ec 58             	sub    $0x58,%esp
    // kern_init->pmm_init->page_init->init_memmap->pmm_manager->init_memmap
    // 判断n是否大于0
    assert(n > 0);
c0105032:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105036:	75 24                	jne    c010505c <default_init_memmap+0x30>
c0105038:	c7 44 24 0c 7c 7c 10 	movl   $0xc0107c7c,0xc(%esp)
c010503f:	c0 
c0105040:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105047:	c0 
c0105048:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c010504f:	00 
c0105050:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105057:	e8 92 b3 ff ff       	call   c01003ee <__panic>
    // 令p为连续地址的空闲块起始页
    struct Page *p = base;
c010505c:	8b 45 08             	mov    0x8(%ebp),%eax
c010505f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
c0105062:	eb 7d                	jmp    c01050e1 <default_init_memmap+0xb5>
        // 检查p的PG_reserved位是否设置为1，表示空闲可分配
        assert(PageReserved(p));
c0105064:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105067:	83 c0 04             	add    $0x4,%eax
c010506a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0105071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105074:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105077:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010507a:	0f a3 10             	bt     %edx,(%eax)
c010507d:	19 c0                	sbb    %eax,%eax
c010507f:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0105082:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0105086:	0f 95 c0             	setne  %al
c0105089:	0f b6 c0             	movzbl %al,%eax
c010508c:	85 c0                	test   %eax,%eax
c010508e:	75 24                	jne    c01050b4 <default_init_memmap+0x88>
c0105090:	c7 44 24 0c ad 7c 10 	movl   $0xc0107cad,0xc(%esp)
c0105097:	c0 
c0105098:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c010509f:	c0 
c01050a0:	c7 44 24 04 79 00 00 	movl   $0x79,0x4(%esp)
c01050a7:	00 
c01050a8:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01050af:	e8 3a b3 ff ff       	call   c01003ee <__panic>
        // 设置flag为0，表示该页空闲
        p->flags = p->property = 0;
c01050b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050b7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c01050be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c1:	8b 50 08             	mov    0x8(%eax),%edx
c01050c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050c7:	89 50 04             	mov    %edx,0x4(%eax)
        // 将该页的ref设为0，表示该页空闲，没有引用
        set_page_ref(p, 0);
c01050ca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01050d1:	00 
c01050d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050d5:	89 04 24             	mov    %eax,(%esp)
c01050d8:	e8 13 ff ff ff       	call   c0104ff0 <set_page_ref>
    // 判断n是否大于0
    assert(n > 0);
    // 令p为连续地址的空闲块起始页
    struct Page *p = base;
    // 将这个空闲块的每个页面初始化
    for (; p != base + n; p ++) {
c01050dd:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c01050e1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01050e4:	89 d0                	mov    %edx,%eax
c01050e6:	c1 e0 02             	shl    $0x2,%eax
c01050e9:	01 d0                	add    %edx,%eax
c01050eb:	c1 e0 02             	shl    $0x2,%eax
c01050ee:	89 c2                	mov    %eax,%edx
c01050f0:	8b 45 08             	mov    0x8(%ebp),%eax
c01050f3:	01 d0                	add    %edx,%eax
c01050f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01050f8:	0f 85 66 ff ff ff    	jne    c0105064 <default_init_memmap+0x38>
        p->flags = p->property = 0;
        // 将该页的ref设为0，表示该页空闲，没有引用
        set_page_ref(p, 0);
    }
    // 空闲块的第一页的连续空页值property设置为块中的总页数
    base->property = n;
c01050fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0105101:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105104:	89 50 08             	mov    %edx,0x8(%eax)
    // 将空闲块的第一页的PG_property位设置为1，表示是起始页，可以用于分配内存
    SetPageProperty(base);
c0105107:	8b 45 08             	mov    0x8(%ebp),%eax
c010510a:	83 c0 04             	add    $0x4,%eax
c010510d:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0105114:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105117:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010511a:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010511d:	0f ab 10             	bts    %edx,(%eax)
    // 将空闲页的数目加n
    nr_free += n;
c0105120:	8b 15 48 93 1b c0    	mov    0xc01b9348,%edx
c0105126:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105129:	01 d0                	add    %edx,%eax
c010512b:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
    // 将base->page_link此页链接到free_list中
    list_add(&free_list, &(base->page_link));
c0105130:	8b 45 08             	mov    0x8(%ebp),%eax
c0105133:	83 c0 0c             	add    $0xc,%eax
c0105136:	c7 45 f0 40 93 1b c0 	movl   $0xc01b9340,-0x10(%ebp)
c010513d:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105140:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105143:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0105146:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105149:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c010514c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010514f:	8b 40 04             	mov    0x4(%eax),%eax
c0105152:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105155:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105158:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010515b:	89 55 cc             	mov    %edx,-0x34(%ebp)
c010515e:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105161:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105164:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105167:	89 10                	mov    %edx,(%eax)
c0105169:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010516c:	8b 10                	mov    (%eax),%edx
c010516e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105171:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105174:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105177:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010517a:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010517d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105180:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105183:	89 10                	mov    %edx,(%eax)
}
c0105185:	90                   	nop
c0105186:	c9                   	leave  
c0105187:	c3                   	ret    

c0105188 <default_alloc_pages>:

// firstfit从空闲链表头开始查找最小的地址->通过list_next找到下一个空闲块元素->通过le2page宏由链表元素获得对应的Page指针p
// ->通过p->peroperty了解此空闲块的大小，如果大于等于n，则找到，重新组织块，吧找到的page返回；否则继续查找->直到list_next==&free_list，表示找完一遍
static struct Page *
default_alloc_pages(size_t n) {
c0105188:	55                   	push   %ebp
c0105189:	89 e5                	mov    %esp,%ebp
c010518b:	83 ec 68             	sub    $0x68,%esp
    // n要大于0
    assert(n > 0);
c010518e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105192:	75 24                	jne    c01051b8 <default_alloc_pages+0x30>
c0105194:	c7 44 24 0c 7c 7c 10 	movl   $0xc0107c7c,0xc(%esp)
c010519b:	c0 
c010519c:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01051a3:	c0 
c01051a4:	c7 44 24 04 8e 00 00 	movl   $0x8e,0x4(%esp)
c01051ab:	00 
c01051ac:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01051b3:	e8 36 b2 ff ff       	call   c01003ee <__panic>
    // 考虑边界情况，当n大于可以分配的内存数时，直接返回，确保分配不会超出范围，保证软件的鲁棒性
    if (n > nr_free) {
c01051b8:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c01051bd:	3b 45 08             	cmp    0x8(%ebp),%eax
c01051c0:	73 0a                	jae    c01051cc <default_alloc_pages+0x44>
        return NULL;
c01051c2:	b8 00 00 00 00       	mov    $0x0,%eax
c01051c7:	e9 68 01 00 00       	jmp    c0105334 <default_alloc_pages+0x1ac>
    }
    struct Page *page = NULL;
c01051cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
c01051d3:	c7 45 f0 40 93 1b c0 	movl   $0xc01b9340,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01051da:	eb 1c                	jmp    c01051f8 <default_alloc_pages+0x70>
        // 由链表元素获得对应的Page指针p
        struct Page *p = le2page(le, page_link);
c01051dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051df:	83 e8 0c             	sub    $0xc,%eax
c01051e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        // 如果当前页面的property大于等于n，说明空闲块的连续空页数大于等于n，可以分配，令page=p，直接退出
        if (p->property >= n) {
c01051e5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051e8:	8b 40 08             	mov    0x8(%eax),%eax
c01051eb:	3b 45 08             	cmp    0x8(%ebp),%eax
c01051ee:	72 08                	jb     c01051f8 <default_alloc_pages+0x70>
            page = p;
c01051f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c01051f6:	eb 18                	jmp    c0105210 <default_alloc_pages+0x88>
c01051f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051fb:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01051fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105201:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105204:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105207:	81 7d f0 40 93 1b c0 	cmpl   $0xc01b9340,-0x10(%ebp)
c010520e:	75 cc                	jne    c01051dc <default_alloc_pages+0x54>
            page = p;
            break;
        }
    }
    // 如果找到了空闲块，进行重新组织，否则直接返回NULL
    if (page != NULL) {
c0105210:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105214:	0f 84 17 01 00 00    	je     c0105331 <default_alloc_pages+0x1a9>
        // 在空闲页链表中删除刚刚分配的空闲块
        list_del(&(page->page_link));
c010521a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010521d:	83 c0 0c             	add    $0xc,%eax
c0105220:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0105223:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105226:	8b 40 04             	mov    0x4(%eax),%eax
c0105229:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010522c:	8b 12                	mov    (%edx),%edx
c010522e:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105231:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0105234:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105237:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010523a:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010523d:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105240:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105243:	89 10                	mov    %edx,(%eax)
        // 如果可以分配的空闲块的连续空页数大于n
        if (page->property > n) {
c0105245:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105248:	8b 40 08             	mov    0x8(%eax),%eax
c010524b:	3b 45 08             	cmp    0x8(%ebp),%eax
c010524e:	0f 86 8c 00 00 00    	jbe    c01052e0 <default_alloc_pages+0x158>
            // 创建一个地址为page+n的新物理页
            struct Page *p = page + n;
c0105254:	8b 55 08             	mov    0x8(%ebp),%edx
c0105257:	89 d0                	mov    %edx,%eax
c0105259:	c1 e0 02             	shl    $0x2,%eax
c010525c:	01 d0                	add    %edx,%eax
c010525e:	c1 e0 02             	shl    $0x2,%eax
c0105261:	89 c2                	mov    %eax,%edx
c0105263:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105266:	01 d0                	add    %edx,%eax
c0105268:	89 45 e0             	mov    %eax,-0x20(%ebp)
            // 页面的property设置为page多出来的空闲连续页数
            p->property = page->property - n;
c010526b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010526e:	8b 40 08             	mov    0x8(%eax),%eax
c0105271:	2b 45 08             	sub    0x8(%ebp),%eax
c0105274:	89 c2                	mov    %eax,%edx
c0105276:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105279:	89 50 08             	mov    %edx,0x8(%eax)
            // 设置p的Page_property位，表示为新的空闲块的起始页
            SetPageProperty(p);
c010527c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010527f:	83 c0 04             	add    $0x4,%eax
c0105282:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
c0105289:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c010528c:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010528f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105292:	0f ab 10             	bts    %edx,(%eax)
            // 将新的空闲块的页插入到空闲链表的后面
            list_add_after(&(page->page_link), &(p->page_link));
c0105295:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105298:	83 c0 0c             	add    $0xc,%eax
c010529b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010529e:	83 c2 0c             	add    $0xc,%edx
c01052a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01052a4:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01052a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052aa:	8b 40 04             	mov    0x4(%eax),%eax
c01052ad:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01052b0:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01052b3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052b6:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01052b9:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01052bc:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01052bf:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01052c2:	89 10                	mov    %edx,(%eax)
c01052c4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01052c7:	8b 10                	mov    (%eax),%edx
c01052c9:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01052cc:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01052cf:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01052d2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c01052d5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01052d8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01052db:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01052de:	89 10                	mov    %edx,(%eax)
    }
        list_del(&(page->page_link));
c01052e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052e3:	83 c0 0c             	add    $0xc,%eax
c01052e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01052e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01052ec:	8b 40 04             	mov    0x4(%eax),%eax
c01052ef:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01052f2:	8b 12                	mov    (%edx),%edx
c01052f4:	89 55 ac             	mov    %edx,-0x54(%ebp)
c01052f7:	89 45 a8             	mov    %eax,-0x58(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01052fa:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01052fd:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0105300:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105303:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0105306:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0105309:	89 10                	mov    %edx,(%eax)
        // 剩余空闲页的数目减n
        nr_free -= n;
c010530b:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c0105310:	2b 45 08             	sub    0x8(%ebp),%eax
c0105313:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
        // 清除page的Page_property位，表示page已经被分配
        ClearPageProperty(page);
c0105318:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010531b:	83 c0 04             	add    $0x4,%eax
c010531e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0105325:	89 45 b0             	mov    %eax,-0x50(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105328:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010532b:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010532e:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0105331:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105334:	c9                   	leave  
c0105335:	c3                   	ret    

c0105336 <default_free_pages>:

// default_alloc_pages的逆过程，但是需要考虑空闲块的合并问题。
// 将页面重新链接到空闲列表中，可以将小的空闲块合并到大的空闲块中。
static void
default_free_pages(struct Page *base, size_t n) {
c0105336:	55                   	push   %ebp
c0105337:	89 e5                	mov    %esp,%ebp
c0105339:	81 ec 98 00 00 00    	sub    $0x98,%esp
    // n要大于0
    assert(n > 0);
c010533f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105343:	75 24                	jne    c0105369 <default_free_pages+0x33>
c0105345:	c7 44 24 0c 7c 7c 10 	movl   $0xc0107c7c,0xc(%esp)
c010534c:	c0 
c010534d:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105354:	c0 
c0105355:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c010535c:	00 
c010535d:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105364:	e8 85 b0 ff ff       	call   c01003ee <__panic>
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
c0105369:	8b 45 08             	mov    0x8(%ebp),%eax
c010536c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
c010536f:	e9 9d 00 00 00       	jmp    c0105411 <default_free_pages+0xdb>
        // 检查每一页的Page_reserved位和Pager_property位是否都未被设置
        assert(!PageReserved(p) && !PageProperty(p));
c0105374:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105377:	83 c0 04             	add    $0x4,%eax
c010537a:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0105381:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105384:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0105387:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010538a:	0f a3 10             	bt     %edx,(%eax)
c010538d:	19 c0                	sbb    %eax,%eax
c010538f:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0105392:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0105396:	0f 95 c0             	setne  %al
c0105399:	0f b6 c0             	movzbl %al,%eax
c010539c:	85 c0                	test   %eax,%eax
c010539e:	75 2c                	jne    c01053cc <default_free_pages+0x96>
c01053a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053a3:	83 c0 04             	add    $0x4,%eax
c01053a6:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c01053ad:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053b0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01053b6:	0f a3 10             	bt     %edx,(%eax)
c01053b9:	19 c0                	sbb    %eax,%eax
c01053bb:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c01053be:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c01053c2:	0f 95 c0             	setne  %al
c01053c5:	0f b6 c0             	movzbl %al,%eax
c01053c8:	85 c0                	test   %eax,%eax
c01053ca:	74 24                	je     c01053f0 <default_free_pages+0xba>
c01053cc:	c7 44 24 0c c0 7c 10 	movl   $0xc0107cc0,0xc(%esp)
c01053d3:	c0 
c01053d4:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01053db:	c0 
c01053dc:	c7 44 24 04 c2 00 00 	movl   $0xc2,0x4(%esp)
c01053e3:	00 
c01053e4:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01053eb:	e8 fe af ff ff       	call   c01003ee <__panic>
        // 设置每一页的flags都为0，表示可以分配
        p->flags = 0;
c01053f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053f3:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
c01053fa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0105401:	00 
c0105402:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105405:	89 04 24             	mov    %eax,(%esp)
c0105408:	e8 e3 fb ff ff       	call   c0104ff0 <set_page_ref>
    // n要大于0
    assert(n > 0);
    // 令p为连续地址的释放块的起始页
    struct Page *p = base;
    // 将这个释放块的每个页面初始化
    for (; p != base + n; p ++) {
c010540d:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0105411:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105414:	89 d0                	mov    %edx,%eax
c0105416:	c1 e0 02             	shl    $0x2,%eax
c0105419:	01 d0                	add    %edx,%eax
c010541b:	c1 e0 02             	shl    $0x2,%eax
c010541e:	89 c2                	mov    %eax,%edx
c0105420:	8b 45 08             	mov    0x8(%ebp),%eax
c0105423:	01 d0                	add    %edx,%eax
c0105425:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105428:	0f 85 46 ff ff ff    	jne    c0105374 <default_free_pages+0x3e>
        p->flags = 0;
        // 设置每一页的ref都为0，表示这页空闲
        set_page_ref(p, 0);
    }
    // 释放块起始页的property连续空页数设置为n
    base->property = n;
c010542e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105431:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105434:	89 50 08             	mov    %edx,0x8(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
c0105437:	8b 45 08             	mov    0x8(%ebp),%eax
c010543a:	83 c0 04             	add    $0x4,%eax
c010543d:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0105444:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0105447:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010544a:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010544d:	0f ab 10             	bts    %edx,(%eax)
c0105450:	c7 45 e8 40 93 1b c0 	movl   $0xc01b9340,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105457:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010545a:	8b 40 04             	mov    0x4(%eax),%eax
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = list_next(&free_list);
c010545d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while (le != &free_list) {
c0105460:	e9 08 01 00 00       	jmp    c010556d <default_free_pages+0x237>
        // 由链表元素获得对应Page指针p
        p = le2page(le, page_link);
c0105465:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105468:	83 e8 0c             	sub    $0xc,%eax
c010546b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010546e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105471:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105477:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010547a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // 如果释放块在下一个空闲块起始页的前面，那么进行合并
        if (base + base->property == p) {
c010547d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105480:	8b 50 08             	mov    0x8(%eax),%edx
c0105483:	89 d0                	mov    %edx,%eax
c0105485:	c1 e0 02             	shl    $0x2,%eax
c0105488:	01 d0                	add    %edx,%eax
c010548a:	c1 e0 02             	shl    $0x2,%eax
c010548d:	89 c2                	mov    %eax,%edx
c010548f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105492:	01 d0                	add    %edx,%eax
c0105494:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105497:	75 5a                	jne    c01054f3 <default_free_pages+0x1bd>
            // 释放块的连续空页数要加上空闲块起始页p的连续空页数
            base->property += p->property;
c0105499:	8b 45 08             	mov    0x8(%ebp),%eax
c010549c:	8b 50 08             	mov    0x8(%eax),%edx
c010549f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054a2:	8b 40 08             	mov    0x8(%eax),%eax
c01054a5:	01 c2                	add    %eax,%edx
c01054a7:	8b 45 08             	mov    0x8(%ebp),%eax
c01054aa:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除p的Page_property位，表示p不再是新的空闲块的起始页
            ClearPageProperty(p);
c01054ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054b0:	83 c0 04             	add    $0x4,%eax
c01054b3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c01054ba:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01054bd:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01054c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01054c3:	0f b3 10             	btr    %edx,(%eax)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
c01054c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054c9:	83 c0 0c             	add    $0xc,%eax
c01054cc:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01054cf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054d2:	8b 40 04             	mov    0x4(%eax),%eax
c01054d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01054d8:	8b 12                	mov    (%edx),%edx
c01054da:	89 55 a8             	mov    %edx,-0x58(%ebp)
c01054dd:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01054e0:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01054e3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01054e6:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01054e9:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01054ec:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01054ef:	89 10                	mov    %edx,(%eax)
c01054f1:	eb 7a                	jmp    c010556d <default_free_pages+0x237>
        }
        // 如果释放块的起始页在上一个空闲块的后面，那么进行合并
        else if (p + p->property == base) {
c01054f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054f6:	8b 50 08             	mov    0x8(%eax),%edx
c01054f9:	89 d0                	mov    %edx,%eax
c01054fb:	c1 e0 02             	shl    $0x2,%eax
c01054fe:	01 d0                	add    %edx,%eax
c0105500:	c1 e0 02             	shl    $0x2,%eax
c0105503:	89 c2                	mov    %eax,%edx
c0105505:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105508:	01 d0                	add    %edx,%eax
c010550a:	3b 45 08             	cmp    0x8(%ebp),%eax
c010550d:	75 5e                	jne    c010556d <default_free_pages+0x237>
            // 空闲块的连续空页数要加上释放块起始页base的连续空页数
            p->property += base->property;
c010550f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105512:	8b 50 08             	mov    0x8(%eax),%edx
c0105515:	8b 45 08             	mov    0x8(%ebp),%eax
c0105518:	8b 40 08             	mov    0x8(%eax),%eax
c010551b:	01 c2                	add    %eax,%edx
c010551d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105520:	89 50 08             	mov    %edx,0x8(%eax)
            // 清除base的Page_property位，表示base不再是起始页
            ClearPageProperty(base);
c0105523:	8b 45 08             	mov    0x8(%ebp),%eax
c0105526:	83 c0 04             	add    $0x4,%eax
c0105529:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0105530:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0105533:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105536:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0105539:	0f b3 10             	btr    %edx,(%eax)
            // 新的空闲块的起始页变成p
            base = p;
c010553c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010553f:	89 45 08             	mov    %eax,0x8(%ebp)
            // 将原来的空闲块删除
            list_del(&(p->page_link));
c0105542:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105545:	83 c0 0c             	add    $0xc,%eax
c0105548:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010554b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010554e:	8b 40 04             	mov    0x4(%eax),%eax
c0105551:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0105554:	8b 12                	mov    (%edx),%edx
c0105556:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0105559:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010555c:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010555f:	8b 55 98             	mov    -0x68(%ebp),%edx
c0105562:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0105565:	8b 45 98             	mov    -0x68(%ebp),%eax
c0105568:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010556b:	89 10                	mov    %edx,(%eax)
    // 设置起始页的Page_property位
    SetPageProperty(base);
    // 指针le指向空闲链表头，开始查找最小的地址
    list_entry_t *le = list_next(&free_list);
    // 遍历空闲链表，查看能否将释放块合并到合适的页块中
    while (le != &free_list) {
c010556d:	81 7d f0 40 93 1b c0 	cmpl   $0xc01b9340,-0x10(%ebp)
c0105574:	0f 85 eb fe ff ff    	jne    c0105465 <default_free_pages+0x12f>
            // 将原来的空闲块删除
            list_del(&(p->page_link));
        }
    }
    // 将空闲页的数目加n
    nr_free += n;
c010557a:	8b 15 48 93 1b c0    	mov    0xc01b9348,%edx
c0105580:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105583:	01 d0                	add    %edx,%eax
c0105585:	a3 48 93 1b c0       	mov    %eax,0xc01b9348
c010558a:	c7 45 d0 40 93 1b c0 	movl   $0xc01b9340,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105591:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105594:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0105597:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while (le != &free_list) {
c010559a:	eb 74                	jmp    c0105610 <default_free_pages+0x2da>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
c010559c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010559f:	83 e8 0c             	sub    $0xc,%eax
c01055a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 找到能够新城新的合并块的位置
        if (base + base->property <= p) {
c01055a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01055a8:	8b 50 08             	mov    0x8(%eax),%edx
c01055ab:	89 d0                	mov    %edx,%eax
c01055ad:	c1 e0 02             	shl    $0x2,%eax
c01055b0:	01 d0                	add    %edx,%eax
c01055b2:	c1 e0 02             	shl    $0x2,%eax
c01055b5:	89 c2                	mov    %eax,%edx
c01055b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01055ba:	01 d0                	add    %edx,%eax
c01055bc:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01055bf:	77 40                	ja     c0105601 <default_free_pages+0x2cb>
            assert(base + base->property != p);
c01055c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01055c4:	8b 50 08             	mov    0x8(%eax),%edx
c01055c7:	89 d0                	mov    %edx,%eax
c01055c9:	c1 e0 02             	shl    $0x2,%eax
c01055cc:	01 d0                	add    %edx,%eax
c01055ce:	c1 e0 02             	shl    $0x2,%eax
c01055d1:	89 c2                	mov    %eax,%edx
c01055d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01055d6:	01 d0                	add    %edx,%eax
c01055d8:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01055db:	75 3e                	jne    c010561b <default_free_pages+0x2e5>
c01055dd:	c7 44 24 0c e5 7c 10 	movl   $0xc0107ce5,0xc(%esp)
c01055e4:	c0 
c01055e5:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01055ec:	c0 
c01055ed:	c7 44 24 04 f1 00 00 	movl   $0xf1,0x4(%esp)
c01055f4:	00 
c01055f5:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01055fc:	e8 ed ad ff ff       	call   c01003ee <__panic>
c0105601:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105604:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0105607:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010560a:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c010560d:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    // 将空闲页的数目加n
    nr_free += n;
    le = list_next(&free_list);
    // 遍历空闲链表，将合并好之后的页块加回空闲链表
    while (le != &free_list) {
c0105610:	81 7d f0 40 93 1b c0 	cmpl   $0xc01b9340,-0x10(%ebp)
c0105617:	75 83                	jne    c010559c <default_free_pages+0x266>
c0105619:	eb 01                	jmp    c010561c <default_free_pages+0x2e6>
        // 由链表元素获得对应的Page指针p
        p = le2page(le, page_link);
        // 找到能够新城新的合并块的位置
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c010561b:	90                   	nop
        }
        le = list_next(le);
    }
    // 将base->page_link此页链接到le中，插入到合适位置
    list_add_before(le, &(base->page_link));
c010561c:	8b 45 08             	mov    0x8(%ebp),%eax
c010561f:	8d 50 0c             	lea    0xc(%eax),%edx
c0105622:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105625:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105628:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010562b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010562e:	8b 00                	mov    (%eax),%eax
c0105630:	8b 55 90             	mov    -0x70(%ebp),%edx
c0105633:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0105636:	89 45 88             	mov    %eax,-0x78(%ebp)
c0105639:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010563c:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010563f:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0105642:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0105645:	89 10                	mov    %edx,(%eax)
c0105647:	8b 45 84             	mov    -0x7c(%ebp),%eax
c010564a:	8b 10                	mov    (%eax),%edx
c010564c:	8b 45 88             	mov    -0x78(%ebp),%eax
c010564f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0105652:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105655:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0105658:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c010565b:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010565e:	8b 55 88             	mov    -0x78(%ebp),%edx
c0105661:	89 10                	mov    %edx,(%eax)
}
c0105663:	90                   	nop
c0105664:	c9                   	leave  
c0105665:	c3                   	ret    

c0105666 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0105666:	55                   	push   %ebp
c0105667:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0105669:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
}
c010566e:	5d                   	pop    %ebp
c010566f:	c3                   	ret    

c0105670 <basic_check>:

static void
basic_check(void) {
c0105670:	55                   	push   %ebp
c0105671:	89 e5                	mov    %esp,%ebp
c0105673:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0105676:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010567d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105680:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105683:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105686:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0105689:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105690:	e8 db d4 ff ff       	call   c0102b70 <alloc_pages>
c0105695:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105698:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010569c:	75 24                	jne    c01056c2 <basic_check+0x52>
c010569e:	c7 44 24 0c 00 7d 10 	movl   $0xc0107d00,0xc(%esp)
c01056a5:	c0 
c01056a6:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01056ad:	c0 
c01056ae:	c7 44 24 04 03 01 00 	movl   $0x103,0x4(%esp)
c01056b5:	00 
c01056b6:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01056bd:	e8 2c ad ff ff       	call   c01003ee <__panic>
    assert((p1 = alloc_page()) != NULL);
c01056c2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01056c9:	e8 a2 d4 ff ff       	call   c0102b70 <alloc_pages>
c01056ce:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01056d1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01056d5:	75 24                	jne    c01056fb <basic_check+0x8b>
c01056d7:	c7 44 24 0c 1c 7d 10 	movl   $0xc0107d1c,0xc(%esp)
c01056de:	c0 
c01056df:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01056e6:	c0 
c01056e7:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c01056ee:	00 
c01056ef:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01056f6:	e8 f3 ac ff ff       	call   c01003ee <__panic>
    assert((p2 = alloc_page()) != NULL);
c01056fb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105702:	e8 69 d4 ff ff       	call   c0102b70 <alloc_pages>
c0105707:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010570a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010570e:	75 24                	jne    c0105734 <basic_check+0xc4>
c0105710:	c7 44 24 0c 38 7d 10 	movl   $0xc0107d38,0xc(%esp)
c0105717:	c0 
c0105718:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c010571f:	c0 
c0105720:	c7 44 24 04 05 01 00 	movl   $0x105,0x4(%esp)
c0105727:	00 
c0105728:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c010572f:	e8 ba ac ff ff       	call   c01003ee <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0105734:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105737:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010573a:	74 10                	je     c010574c <basic_check+0xdc>
c010573c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010573f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105742:	74 08                	je     c010574c <basic_check+0xdc>
c0105744:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105747:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010574a:	75 24                	jne    c0105770 <basic_check+0x100>
c010574c:	c7 44 24 0c 54 7d 10 	movl   $0xc0107d54,0xc(%esp)
c0105753:	c0 
c0105754:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c010575b:	c0 
c010575c:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c0105763:	00 
c0105764:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c010576b:	e8 7e ac ff ff       	call   c01003ee <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0105770:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105773:	89 04 24             	mov    %eax,(%esp)
c0105776:	e8 6b f8 ff ff       	call   c0104fe6 <page_ref>
c010577b:	85 c0                	test   %eax,%eax
c010577d:	75 1e                	jne    c010579d <basic_check+0x12d>
c010577f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105782:	89 04 24             	mov    %eax,(%esp)
c0105785:	e8 5c f8 ff ff       	call   c0104fe6 <page_ref>
c010578a:	85 c0                	test   %eax,%eax
c010578c:	75 0f                	jne    c010579d <basic_check+0x12d>
c010578e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105791:	89 04 24             	mov    %eax,(%esp)
c0105794:	e8 4d f8 ff ff       	call   c0104fe6 <page_ref>
c0105799:	85 c0                	test   %eax,%eax
c010579b:	74 24                	je     c01057c1 <basic_check+0x151>
c010579d:	c7 44 24 0c 78 7d 10 	movl   $0xc0107d78,0xc(%esp)
c01057a4:	c0 
c01057a5:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01057ac:	c0 
c01057ad:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c01057b4:	00 
c01057b5:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01057bc:	e8 2d ac ff ff       	call   c01003ee <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c01057c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01057c4:	89 04 24             	mov    %eax,(%esp)
c01057c7:	e8 04 f8 ff ff       	call   c0104fd0 <page2pa>
c01057cc:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c01057d2:	c1 e2 0c             	shl    $0xc,%edx
c01057d5:	39 d0                	cmp    %edx,%eax
c01057d7:	72 24                	jb     c01057fd <basic_check+0x18d>
c01057d9:	c7 44 24 0c b4 7d 10 	movl   $0xc0107db4,0xc(%esp)
c01057e0:	c0 
c01057e1:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01057e8:	c0 
c01057e9:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01057f0:	00 
c01057f1:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01057f8:	e8 f1 ab ff ff       	call   c01003ee <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01057fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105800:	89 04 24             	mov    %eax,(%esp)
c0105803:	e8 c8 f7 ff ff       	call   c0104fd0 <page2pa>
c0105808:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c010580e:	c1 e2 0c             	shl    $0xc,%edx
c0105811:	39 d0                	cmp    %edx,%eax
c0105813:	72 24                	jb     c0105839 <basic_check+0x1c9>
c0105815:	c7 44 24 0c d1 7d 10 	movl   $0xc0107dd1,0xc(%esp)
c010581c:	c0 
c010581d:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105824:	c0 
c0105825:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
c010582c:	00 
c010582d:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105834:	e8 b5 ab ff ff       	call   c01003ee <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0105839:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010583c:	89 04 24             	mov    %eax,(%esp)
c010583f:	e8 8c f7 ff ff       	call   c0104fd0 <page2pa>
c0105844:	8b 15 80 ce 11 c0    	mov    0xc011ce80,%edx
c010584a:	c1 e2 0c             	shl    $0xc,%edx
c010584d:	39 d0                	cmp    %edx,%eax
c010584f:	72 24                	jb     c0105875 <basic_check+0x205>
c0105851:	c7 44 24 0c ee 7d 10 	movl   $0xc0107dee,0xc(%esp)
c0105858:	c0 
c0105859:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105860:	c0 
c0105861:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c0105868:	00 
c0105869:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105870:	e8 79 ab ff ff       	call   c01003ee <__panic>

    list_entry_t free_list_store = free_list;
c0105875:	a1 40 93 1b c0       	mov    0xc01b9340,%eax
c010587a:	8b 15 44 93 1b c0    	mov    0xc01b9344,%edx
c0105880:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105883:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105886:	c7 45 e4 40 93 1b c0 	movl   $0xc01b9340,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010588d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105893:	89 50 04             	mov    %edx,0x4(%eax)
c0105896:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105899:	8b 50 04             	mov    0x4(%eax),%edx
c010589c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010589f:	89 10                	mov    %edx,(%eax)
c01058a1:	c7 45 d8 40 93 1b c0 	movl   $0xc01b9340,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01058a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058ab:	8b 40 04             	mov    0x4(%eax),%eax
c01058ae:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c01058b1:	0f 94 c0             	sete   %al
c01058b4:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c01058b7:	85 c0                	test   %eax,%eax
c01058b9:	75 24                	jne    c01058df <basic_check+0x26f>
c01058bb:	c7 44 24 0c 0b 7e 10 	movl   $0xc0107e0b,0xc(%esp)
c01058c2:	c0 
c01058c3:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01058ca:	c0 
c01058cb:	c7 44 24 04 10 01 00 	movl   $0x110,0x4(%esp)
c01058d2:	00 
c01058d3:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01058da:	e8 0f ab ff ff       	call   c01003ee <__panic>

    unsigned int nr_free_store = nr_free;
c01058df:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c01058e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c01058e7:	c7 05 48 93 1b c0 00 	movl   $0x0,0xc01b9348
c01058ee:	00 00 00 

    assert(alloc_page() == NULL);
c01058f1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01058f8:	e8 73 d2 ff ff       	call   c0102b70 <alloc_pages>
c01058fd:	85 c0                	test   %eax,%eax
c01058ff:	74 24                	je     c0105925 <basic_check+0x2b5>
c0105901:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c0105908:	c0 
c0105909:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105910:	c0 
c0105911:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0105918:	00 
c0105919:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105920:	e8 c9 aa ff ff       	call   c01003ee <__panic>

    free_page(p0);
c0105925:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010592c:	00 
c010592d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105930:	89 04 24             	mov    %eax,(%esp)
c0105933:	e8 70 d2 ff ff       	call   c0102ba8 <free_pages>
    free_page(p1);
c0105938:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010593f:	00 
c0105940:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105943:	89 04 24             	mov    %eax,(%esp)
c0105946:	e8 5d d2 ff ff       	call   c0102ba8 <free_pages>
    free_page(p2);
c010594b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105952:	00 
c0105953:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105956:	89 04 24             	mov    %eax,(%esp)
c0105959:	e8 4a d2 ff ff       	call   c0102ba8 <free_pages>
    assert(nr_free == 3);
c010595e:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c0105963:	83 f8 03             	cmp    $0x3,%eax
c0105966:	74 24                	je     c010598c <basic_check+0x31c>
c0105968:	c7 44 24 0c 37 7e 10 	movl   $0xc0107e37,0xc(%esp)
c010596f:	c0 
c0105970:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105977:	c0 
c0105978:	c7 44 24 04 1a 01 00 	movl   $0x11a,0x4(%esp)
c010597f:	00 
c0105980:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105987:	e8 62 aa ff ff       	call   c01003ee <__panic>

    assert((p0 = alloc_page()) != NULL);
c010598c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105993:	e8 d8 d1 ff ff       	call   c0102b70 <alloc_pages>
c0105998:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010599b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010599f:	75 24                	jne    c01059c5 <basic_check+0x355>
c01059a1:	c7 44 24 0c 00 7d 10 	movl   $0xc0107d00,0xc(%esp)
c01059a8:	c0 
c01059a9:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01059b0:	c0 
c01059b1:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01059b8:	00 
c01059b9:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01059c0:	e8 29 aa ff ff       	call   c01003ee <__panic>
    assert((p1 = alloc_page()) != NULL);
c01059c5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01059cc:	e8 9f d1 ff ff       	call   c0102b70 <alloc_pages>
c01059d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01059d4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01059d8:	75 24                	jne    c01059fe <basic_check+0x38e>
c01059da:	c7 44 24 0c 1c 7d 10 	movl   $0xc0107d1c,0xc(%esp)
c01059e1:	c0 
c01059e2:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01059e9:	c0 
c01059ea:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c01059f1:	00 
c01059f2:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01059f9:	e8 f0 a9 ff ff       	call   c01003ee <__panic>
    assert((p2 = alloc_page()) != NULL);
c01059fe:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a05:	e8 66 d1 ff ff       	call   c0102b70 <alloc_pages>
c0105a0a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a0d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105a11:	75 24                	jne    c0105a37 <basic_check+0x3c7>
c0105a13:	c7 44 24 0c 38 7d 10 	movl   $0xc0107d38,0xc(%esp)
c0105a1a:	c0 
c0105a1b:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105a22:	c0 
c0105a23:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0105a2a:	00 
c0105a2b:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105a32:	e8 b7 a9 ff ff       	call   c01003ee <__panic>

    assert(alloc_page() == NULL);
c0105a37:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105a3e:	e8 2d d1 ff ff       	call   c0102b70 <alloc_pages>
c0105a43:	85 c0                	test   %eax,%eax
c0105a45:	74 24                	je     c0105a6b <basic_check+0x3fb>
c0105a47:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c0105a4e:	c0 
c0105a4f:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105a56:	c0 
c0105a57:	c7 44 24 04 20 01 00 	movl   $0x120,0x4(%esp)
c0105a5e:	00 
c0105a5f:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105a66:	e8 83 a9 ff ff       	call   c01003ee <__panic>

    free_page(p0);
c0105a6b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105a72:	00 
c0105a73:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a76:	89 04 24             	mov    %eax,(%esp)
c0105a79:	e8 2a d1 ff ff       	call   c0102ba8 <free_pages>
c0105a7e:	c7 45 e8 40 93 1b c0 	movl   $0xc01b9340,-0x18(%ebp)
c0105a85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a88:	8b 40 04             	mov    0x4(%eax),%eax
c0105a8b:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0105a8e:	0f 94 c0             	sete   %al
c0105a91:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0105a94:	85 c0                	test   %eax,%eax
c0105a96:	74 24                	je     c0105abc <basic_check+0x44c>
c0105a98:	c7 44 24 0c 44 7e 10 	movl   $0xc0107e44,0xc(%esp)
c0105a9f:	c0 
c0105aa0:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105aa7:	c0 
c0105aa8:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0105aaf:	00 
c0105ab0:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105ab7:	e8 32 a9 ff ff       	call   c01003ee <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0105abc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ac3:	e8 a8 d0 ff ff       	call   c0102b70 <alloc_pages>
c0105ac8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105acb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ace:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105ad1:	74 24                	je     c0105af7 <basic_check+0x487>
c0105ad3:	c7 44 24 0c 5c 7e 10 	movl   $0xc0107e5c,0xc(%esp)
c0105ada:	c0 
c0105adb:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105ae2:	c0 
c0105ae3:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c0105aea:	00 
c0105aeb:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105af2:	e8 f7 a8 ff ff       	call   c01003ee <__panic>
    assert(alloc_page() == NULL);
c0105af7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105afe:	e8 6d d0 ff ff       	call   c0102b70 <alloc_pages>
c0105b03:	85 c0                	test   %eax,%eax
c0105b05:	74 24                	je     c0105b2b <basic_check+0x4bb>
c0105b07:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c0105b0e:	c0 
c0105b0f:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105b16:	c0 
c0105b17:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0105b1e:	00 
c0105b1f:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105b26:	e8 c3 a8 ff ff       	call   c01003ee <__panic>

    assert(nr_free == 0);
c0105b2b:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c0105b30:	85 c0                	test   %eax,%eax
c0105b32:	74 24                	je     c0105b58 <basic_check+0x4e8>
c0105b34:	c7 44 24 0c 75 7e 10 	movl   $0xc0107e75,0xc(%esp)
c0105b3b:	c0 
c0105b3c:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105b43:	c0 
c0105b44:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0105b4b:	00 
c0105b4c:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105b53:	e8 96 a8 ff ff       	call   c01003ee <__panic>
    free_list = free_list_store;
c0105b58:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105b5b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105b5e:	a3 40 93 1b c0       	mov    %eax,0xc01b9340
c0105b63:	89 15 44 93 1b c0    	mov    %edx,0xc01b9344
    nr_free = nr_free_store;
c0105b69:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b6c:	a3 48 93 1b c0       	mov    %eax,0xc01b9348

    free_page(p);
c0105b71:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b78:	00 
c0105b79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105b7c:	89 04 24             	mov    %eax,(%esp)
c0105b7f:	e8 24 d0 ff ff       	call   c0102ba8 <free_pages>
    free_page(p1);
c0105b84:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b8b:	00 
c0105b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b8f:	89 04 24             	mov    %eax,(%esp)
c0105b92:	e8 11 d0 ff ff       	call   c0102ba8 <free_pages>
    free_page(p2);
c0105b97:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105b9e:	00 
c0105b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105ba2:	89 04 24             	mov    %eax,(%esp)
c0105ba5:	e8 fe cf ff ff       	call   c0102ba8 <free_pages>
}
c0105baa:	90                   	nop
c0105bab:	c9                   	leave  
c0105bac:	c3                   	ret    

c0105bad <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0105bad:	55                   	push   %ebp
c0105bae:	89 e5                	mov    %esp,%ebp
c0105bb0:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0105bb6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105bbd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0105bc4:	c7 45 ec 40 93 1b c0 	movl   $0xc01b9340,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105bcb:	eb 6a                	jmp    c0105c37 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0105bcd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bd0:	83 e8 0c             	sub    $0xc,%eax
c0105bd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c0105bd6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105bd9:	83 c0 04             	add    $0x4,%eax
c0105bdc:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105be3:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105be6:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105be9:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0105bec:	0f a3 10             	bt     %edx,(%eax)
c0105bef:	19 c0                	sbb    %eax,%eax
c0105bf1:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105bf4:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0105bf8:	0f 95 c0             	setne  %al
c0105bfb:	0f b6 c0             	movzbl %al,%eax
c0105bfe:	85 c0                	test   %eax,%eax
c0105c00:	75 24                	jne    c0105c26 <default_check+0x79>
c0105c02:	c7 44 24 0c 82 7e 10 	movl   $0xc0107e82,0xc(%esp)
c0105c09:	c0 
c0105c0a:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105c11:	c0 
c0105c12:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
c0105c19:	00 
c0105c1a:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105c21:	e8 c8 a7 ff ff       	call   c01003ee <__panic>
        count ++, total += p->property;
c0105c26:	ff 45 f4             	incl   -0xc(%ebp)
c0105c29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105c2c:	8b 50 08             	mov    0x8(%eax),%edx
c0105c2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c32:	01 d0                	add    %edx,%eax
c0105c34:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105c37:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105c3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0105c3d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105c40:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105c43:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105c46:	81 7d ec 40 93 1b c0 	cmpl   $0xc01b9340,-0x14(%ebp)
c0105c4d:	0f 85 7a ff ff ff    	jne    c0105bcd <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105c53:	e8 83 cf ff ff       	call   c0102bdb <nr_free_pages>
c0105c58:	89 c2                	mov    %eax,%edx
c0105c5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c5d:	39 c2                	cmp    %eax,%edx
c0105c5f:	74 24                	je     c0105c85 <default_check+0xd8>
c0105c61:	c7 44 24 0c 92 7e 10 	movl   $0xc0107e92,0xc(%esp)
c0105c68:	c0 
c0105c69:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105c70:	c0 
c0105c71:	c7 44 24 04 3d 01 00 	movl   $0x13d,0x4(%esp)
c0105c78:	00 
c0105c79:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105c80:	e8 69 a7 ff ff       	call   c01003ee <__panic>

    basic_check();
c0105c85:	e8 e6 f9 ff ff       	call   c0105670 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0105c8a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0105c91:	e8 da ce ff ff       	call   c0102b70 <alloc_pages>
c0105c96:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c0105c99:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105c9d:	75 24                	jne    c0105cc3 <default_check+0x116>
c0105c9f:	c7 44 24 0c ab 7e 10 	movl   $0xc0107eab,0xc(%esp)
c0105ca6:	c0 
c0105ca7:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105cae:	c0 
c0105caf:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
c0105cb6:	00 
c0105cb7:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105cbe:	e8 2b a7 ff ff       	call   c01003ee <__panic>
    assert(!PageProperty(p0));
c0105cc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cc6:	83 c0 04             	add    $0x4,%eax
c0105cc9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0105cd0:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105cd3:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0105cd6:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105cd9:	0f a3 10             	bt     %edx,(%eax)
c0105cdc:	19 c0                	sbb    %eax,%eax
c0105cde:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0105ce1:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0105ce5:	0f 95 c0             	setne  %al
c0105ce8:	0f b6 c0             	movzbl %al,%eax
c0105ceb:	85 c0                	test   %eax,%eax
c0105ced:	74 24                	je     c0105d13 <default_check+0x166>
c0105cef:	c7 44 24 0c b6 7e 10 	movl   $0xc0107eb6,0xc(%esp)
c0105cf6:	c0 
c0105cf7:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105cfe:	c0 
c0105cff:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
c0105d06:	00 
c0105d07:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105d0e:	e8 db a6 ff ff       	call   c01003ee <__panic>

    list_entry_t free_list_store = free_list;
c0105d13:	a1 40 93 1b c0       	mov    0xc01b9340,%eax
c0105d18:	8b 15 44 93 1b c0    	mov    0xc01b9344,%edx
c0105d1e:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105d21:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105d24:	c7 45 d0 40 93 1b c0 	movl   $0xc01b9340,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0105d2b:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d2e:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105d31:	89 50 04             	mov    %edx,0x4(%eax)
c0105d34:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d37:	8b 50 04             	mov    0x4(%eax),%edx
c0105d3a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105d3d:	89 10                	mov    %edx,(%eax)
c0105d3f:	c7 45 d8 40 93 1b c0 	movl   $0xc01b9340,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105d46:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105d49:	8b 40 04             	mov    0x4(%eax),%eax
c0105d4c:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0105d4f:	0f 94 c0             	sete   %al
c0105d52:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105d55:	85 c0                	test   %eax,%eax
c0105d57:	75 24                	jne    c0105d7d <default_check+0x1d0>
c0105d59:	c7 44 24 0c 0b 7e 10 	movl   $0xc0107e0b,0xc(%esp)
c0105d60:	c0 
c0105d61:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105d68:	c0 
c0105d69:	c7 44 24 04 47 01 00 	movl   $0x147,0x4(%esp)
c0105d70:	00 
c0105d71:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105d78:	e8 71 a6 ff ff       	call   c01003ee <__panic>
    assert(alloc_page() == NULL);
c0105d7d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105d84:	e8 e7 cd ff ff       	call   c0102b70 <alloc_pages>
c0105d89:	85 c0                	test   %eax,%eax
c0105d8b:	74 24                	je     c0105db1 <default_check+0x204>
c0105d8d:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c0105d94:	c0 
c0105d95:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105d9c:	c0 
c0105d9d:	c7 44 24 04 48 01 00 	movl   $0x148,0x4(%esp)
c0105da4:	00 
c0105da5:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105dac:	e8 3d a6 ff ff       	call   c01003ee <__panic>

    unsigned int nr_free_store = nr_free;
c0105db1:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c0105db6:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0105db9:	c7 05 48 93 1b c0 00 	movl   $0x0,0xc01b9348
c0105dc0:	00 00 00 

    free_pages(p0 + 2, 3);
c0105dc3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105dc6:	83 c0 28             	add    $0x28,%eax
c0105dc9:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105dd0:	00 
c0105dd1:	89 04 24             	mov    %eax,(%esp)
c0105dd4:	e8 cf cd ff ff       	call   c0102ba8 <free_pages>
    assert(alloc_pages(4) == NULL);
c0105dd9:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0105de0:	e8 8b cd ff ff       	call   c0102b70 <alloc_pages>
c0105de5:	85 c0                	test   %eax,%eax
c0105de7:	74 24                	je     c0105e0d <default_check+0x260>
c0105de9:	c7 44 24 0c c8 7e 10 	movl   $0xc0107ec8,0xc(%esp)
c0105df0:	c0 
c0105df1:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105df8:	c0 
c0105df9:	c7 44 24 04 4e 01 00 	movl   $0x14e,0x4(%esp)
c0105e00:	00 
c0105e01:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105e08:	e8 e1 a5 ff ff       	call   c01003ee <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0105e0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e10:	83 c0 28             	add    $0x28,%eax
c0105e13:	83 c0 04             	add    $0x4,%eax
c0105e16:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0105e1d:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105e20:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105e23:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e26:	0f a3 10             	bt     %edx,(%eax)
c0105e29:	19 c0                	sbb    %eax,%eax
c0105e2b:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0105e2e:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105e32:	0f 95 c0             	setne  %al
c0105e35:	0f b6 c0             	movzbl %al,%eax
c0105e38:	85 c0                	test   %eax,%eax
c0105e3a:	74 0e                	je     c0105e4a <default_check+0x29d>
c0105e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e3f:	83 c0 28             	add    $0x28,%eax
c0105e42:	8b 40 08             	mov    0x8(%eax),%eax
c0105e45:	83 f8 03             	cmp    $0x3,%eax
c0105e48:	74 24                	je     c0105e6e <default_check+0x2c1>
c0105e4a:	c7 44 24 0c e0 7e 10 	movl   $0xc0107ee0,0xc(%esp)
c0105e51:	c0 
c0105e52:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105e59:	c0 
c0105e5a:	c7 44 24 04 4f 01 00 	movl   $0x14f,0x4(%esp)
c0105e61:	00 
c0105e62:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105e69:	e8 80 a5 ff ff       	call   c01003ee <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0105e6e:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105e75:	e8 f6 cc ff ff       	call   c0102b70 <alloc_pages>
c0105e7a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0105e7d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0105e81:	75 24                	jne    c0105ea7 <default_check+0x2fa>
c0105e83:	c7 44 24 0c 0c 7f 10 	movl   $0xc0107f0c,0xc(%esp)
c0105e8a:	c0 
c0105e8b:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105e92:	c0 
c0105e93:	c7 44 24 04 50 01 00 	movl   $0x150,0x4(%esp)
c0105e9a:	00 
c0105e9b:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105ea2:	e8 47 a5 ff ff       	call   c01003ee <__panic>
    assert(alloc_page() == NULL);
c0105ea7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105eae:	e8 bd cc ff ff       	call   c0102b70 <alloc_pages>
c0105eb3:	85 c0                	test   %eax,%eax
c0105eb5:	74 24                	je     c0105edb <default_check+0x32e>
c0105eb7:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c0105ebe:	c0 
c0105ebf:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105ec6:	c0 
c0105ec7:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
c0105ece:	00 
c0105ecf:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105ed6:	e8 13 a5 ff ff       	call   c01003ee <__panic>
    assert(p0 + 2 == p1);
c0105edb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105ede:	83 c0 28             	add    $0x28,%eax
c0105ee1:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0105ee4:	74 24                	je     c0105f0a <default_check+0x35d>
c0105ee6:	c7 44 24 0c 2a 7f 10 	movl   $0xc0107f2a,0xc(%esp)
c0105eed:	c0 
c0105eee:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105ef5:	c0 
c0105ef6:	c7 44 24 04 52 01 00 	movl   $0x152,0x4(%esp)
c0105efd:	00 
c0105efe:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105f05:	e8 e4 a4 ff ff       	call   c01003ee <__panic>

    p2 = p0 + 1;
c0105f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f0d:	83 c0 14             	add    $0x14,%eax
c0105f10:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0105f13:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105f1a:	00 
c0105f1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f1e:	89 04 24             	mov    %eax,(%esp)
c0105f21:	e8 82 cc ff ff       	call   c0102ba8 <free_pages>
    free_pages(p1, 3);
c0105f26:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0105f2d:	00 
c0105f2e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105f31:	89 04 24             	mov    %eax,(%esp)
c0105f34:	e8 6f cc ff ff       	call   c0102ba8 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105f39:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f3c:	83 c0 04             	add    $0x4,%eax
c0105f3f:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105f46:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105f49:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0105f4c:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105f4f:	0f a3 10             	bt     %edx,(%eax)
c0105f52:	19 c0                	sbb    %eax,%eax
c0105f54:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0105f57:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0105f5b:	0f 95 c0             	setne  %al
c0105f5e:	0f b6 c0             	movzbl %al,%eax
c0105f61:	85 c0                	test   %eax,%eax
c0105f63:	74 0b                	je     c0105f70 <default_check+0x3c3>
c0105f65:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105f68:	8b 40 08             	mov    0x8(%eax),%eax
c0105f6b:	83 f8 01             	cmp    $0x1,%eax
c0105f6e:	74 24                	je     c0105f94 <default_check+0x3e7>
c0105f70:	c7 44 24 0c 38 7f 10 	movl   $0xc0107f38,0xc(%esp)
c0105f77:	c0 
c0105f78:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105f7f:	c0 
c0105f80:	c7 44 24 04 57 01 00 	movl   $0x157,0x4(%esp)
c0105f87:	00 
c0105f88:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105f8f:	e8 5a a4 ff ff       	call   c01003ee <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0105f94:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105f97:	83 c0 04             	add    $0x4,%eax
c0105f9a:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0105fa1:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105fa4:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0105fa7:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0105faa:	0f a3 10             	bt     %edx,(%eax)
c0105fad:	19 c0                	sbb    %eax,%eax
c0105faf:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0105fb2:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0105fb6:	0f 95 c0             	setne  %al
c0105fb9:	0f b6 c0             	movzbl %al,%eax
c0105fbc:	85 c0                	test   %eax,%eax
c0105fbe:	74 0b                	je     c0105fcb <default_check+0x41e>
c0105fc0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105fc3:	8b 40 08             	mov    0x8(%eax),%eax
c0105fc6:	83 f8 03             	cmp    $0x3,%eax
c0105fc9:	74 24                	je     c0105fef <default_check+0x442>
c0105fcb:	c7 44 24 0c 60 7f 10 	movl   $0xc0107f60,0xc(%esp)
c0105fd2:	c0 
c0105fd3:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0105fda:	c0 
c0105fdb:	c7 44 24 04 58 01 00 	movl   $0x158,0x4(%esp)
c0105fe2:	00 
c0105fe3:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0105fea:	e8 ff a3 ff ff       	call   c01003ee <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0105fef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105ff6:	e8 75 cb ff ff       	call   c0102b70 <alloc_pages>
c0105ffb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0105ffe:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106001:	83 e8 14             	sub    $0x14,%eax
c0106004:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106007:	74 24                	je     c010602d <default_check+0x480>
c0106009:	c7 44 24 0c 86 7f 10 	movl   $0xc0107f86,0xc(%esp)
c0106010:	c0 
c0106011:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0106018:	c0 
c0106019:	c7 44 24 04 5a 01 00 	movl   $0x15a,0x4(%esp)
c0106020:	00 
c0106021:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0106028:	e8 c1 a3 ff ff       	call   c01003ee <__panic>
    free_page(p0);
c010602d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106034:	00 
c0106035:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106038:	89 04 24             	mov    %eax,(%esp)
c010603b:	e8 68 cb ff ff       	call   c0102ba8 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0106040:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0106047:	e8 24 cb ff ff       	call   c0102b70 <alloc_pages>
c010604c:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010604f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106052:	83 c0 14             	add    $0x14,%eax
c0106055:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0106058:	74 24                	je     c010607e <default_check+0x4d1>
c010605a:	c7 44 24 0c a4 7f 10 	movl   $0xc0107fa4,0xc(%esp)
c0106061:	c0 
c0106062:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0106069:	c0 
c010606a:	c7 44 24 04 5c 01 00 	movl   $0x15c,0x4(%esp)
c0106071:	00 
c0106072:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0106079:	e8 70 a3 ff ff       	call   c01003ee <__panic>

    free_pages(p0, 2);
c010607e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0106085:	00 
c0106086:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106089:	89 04 24             	mov    %eax,(%esp)
c010608c:	e8 17 cb ff ff       	call   c0102ba8 <free_pages>
    free_page(p2);
c0106091:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0106098:	00 
c0106099:	8b 45 c0             	mov    -0x40(%ebp),%eax
c010609c:	89 04 24             	mov    %eax,(%esp)
c010609f:	e8 04 cb ff ff       	call   c0102ba8 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01060a4:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01060ab:	e8 c0 ca ff ff       	call   c0102b70 <alloc_pages>
c01060b0:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01060b3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01060b7:	75 24                	jne    c01060dd <default_check+0x530>
c01060b9:	c7 44 24 0c c4 7f 10 	movl   $0xc0107fc4,0xc(%esp)
c01060c0:	c0 
c01060c1:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01060c8:	c0 
c01060c9:	c7 44 24 04 61 01 00 	movl   $0x161,0x4(%esp)
c01060d0:	00 
c01060d1:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01060d8:	e8 11 a3 ff ff       	call   c01003ee <__panic>
    assert(alloc_page() == NULL);
c01060dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01060e4:	e8 87 ca ff ff       	call   c0102b70 <alloc_pages>
c01060e9:	85 c0                	test   %eax,%eax
c01060eb:	74 24                	je     c0106111 <default_check+0x564>
c01060ed:	c7 44 24 0c 22 7e 10 	movl   $0xc0107e22,0xc(%esp)
c01060f4:	c0 
c01060f5:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01060fc:	c0 
c01060fd:	c7 44 24 04 62 01 00 	movl   $0x162,0x4(%esp)
c0106104:	00 
c0106105:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c010610c:	e8 dd a2 ff ff       	call   c01003ee <__panic>

    assert(nr_free == 0);
c0106111:	a1 48 93 1b c0       	mov    0xc01b9348,%eax
c0106116:	85 c0                	test   %eax,%eax
c0106118:	74 24                	je     c010613e <default_check+0x591>
c010611a:	c7 44 24 0c 75 7e 10 	movl   $0xc0107e75,0xc(%esp)
c0106121:	c0 
c0106122:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0106129:	c0 
c010612a:	c7 44 24 04 64 01 00 	movl   $0x164,0x4(%esp)
c0106131:	00 
c0106132:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0106139:	e8 b0 a2 ff ff       	call   c01003ee <__panic>
    nr_free = nr_free_store;
c010613e:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106141:	a3 48 93 1b c0       	mov    %eax,0xc01b9348

    free_list = free_list_store;
c0106146:	8b 45 80             	mov    -0x80(%ebp),%eax
c0106149:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010614c:	a3 40 93 1b c0       	mov    %eax,0xc01b9340
c0106151:	89 15 44 93 1b c0    	mov    %edx,0xc01b9344
    free_pages(p0, 5);
c0106157:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010615e:	00 
c010615f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106162:	89 04 24             	mov    %eax,(%esp)
c0106165:	e8 3e ca ff ff       	call   c0102ba8 <free_pages>

    le = &free_list;
c010616a:	c7 45 ec 40 93 1b c0 	movl   $0xc01b9340,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0106171:	eb 5a                	jmp    c01061cd <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0106173:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106176:	8b 40 04             	mov    0x4(%eax),%eax
c0106179:	8b 00                	mov    (%eax),%eax
c010617b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010617e:	75 0d                	jne    c010618d <default_check+0x5e0>
c0106180:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106183:	8b 00                	mov    (%eax),%eax
c0106185:	8b 40 04             	mov    0x4(%eax),%eax
c0106188:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010618b:	74 24                	je     c01061b1 <default_check+0x604>
c010618d:	c7 44 24 0c e4 7f 10 	movl   $0xc0107fe4,0xc(%esp)
c0106194:	c0 
c0106195:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c010619c:	c0 
c010619d:	c7 44 24 04 6c 01 00 	movl   $0x16c,0x4(%esp)
c01061a4:	00 
c01061a5:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c01061ac:	e8 3d a2 ff ff       	call   c01003ee <__panic>
        struct Page *p = le2page(le, page_link);
c01061b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061b4:	83 e8 0c             	sub    $0xc,%eax
c01061b7:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c01061ba:	ff 4d f4             	decl   -0xc(%ebp)
c01061bd:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01061c0:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01061c3:	8b 40 08             	mov    0x8(%eax),%eax
c01061c6:	29 c2                	sub    %eax,%edx
c01061c8:	89 d0                	mov    %edx,%eax
c01061ca:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01061cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01061d0:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01061d3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01061d6:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01061d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01061dc:	81 7d ec 40 93 1b c0 	cmpl   $0xc01b9340,-0x14(%ebp)
c01061e3:	75 8e                	jne    c0106173 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c01061e5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01061e9:	74 24                	je     c010620f <default_check+0x662>
c01061eb:	c7 44 24 0c 11 80 10 	movl   $0xc0108011,0xc(%esp)
c01061f2:	c0 
c01061f3:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c01061fa:	c0 
c01061fb:	c7 44 24 04 70 01 00 	movl   $0x170,0x4(%esp)
c0106202:	00 
c0106203:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c010620a:	e8 df a1 ff ff       	call   c01003ee <__panic>
    assert(total == 0);
c010620f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0106213:	74 24                	je     c0106239 <default_check+0x68c>
c0106215:	c7 44 24 0c 1c 80 10 	movl   $0xc010801c,0xc(%esp)
c010621c:	c0 
c010621d:	c7 44 24 08 82 7c 10 	movl   $0xc0107c82,0x8(%esp)
c0106224:	c0 
c0106225:	c7 44 24 04 71 01 00 	movl   $0x171,0x4(%esp)
c010622c:	00 
c010622d:	c7 04 24 97 7c 10 c0 	movl   $0xc0107c97,(%esp)
c0106234:	e8 b5 a1 ff ff       	call   c01003ee <__panic>
}
c0106239:	90                   	nop
c010623a:	c9                   	leave  
c010623b:	c3                   	ret    

c010623c <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010623c:	55                   	push   %ebp
c010623d:	89 e5                	mov    %esp,%ebp
c010623f:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106242:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0106249:	eb 03                	jmp    c010624e <strlen+0x12>
        cnt ++;
c010624b:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010624e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106251:	8d 50 01             	lea    0x1(%eax),%edx
c0106254:	89 55 08             	mov    %edx,0x8(%ebp)
c0106257:	0f b6 00             	movzbl (%eax),%eax
c010625a:	84 c0                	test   %al,%al
c010625c:	75 ed                	jne    c010624b <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010625e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106261:	c9                   	leave  
c0106262:	c3                   	ret    

c0106263 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0106263:	55                   	push   %ebp
c0106264:	89 e5                	mov    %esp,%ebp
c0106266:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0106269:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0106270:	eb 03                	jmp    c0106275 <strnlen+0x12>
        cnt ++;
c0106272:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0106275:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106278:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010627b:	73 10                	jae    c010628d <strnlen+0x2a>
c010627d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106280:	8d 50 01             	lea    0x1(%eax),%edx
c0106283:	89 55 08             	mov    %edx,0x8(%ebp)
c0106286:	0f b6 00             	movzbl (%eax),%eax
c0106289:	84 c0                	test   %al,%al
c010628b:	75 e5                	jne    c0106272 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010628d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0106290:	c9                   	leave  
c0106291:	c3                   	ret    

c0106292 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0106292:	55                   	push   %ebp
c0106293:	89 e5                	mov    %esp,%ebp
c0106295:	57                   	push   %edi
c0106296:	56                   	push   %esi
c0106297:	83 ec 20             	sub    $0x20,%esp
c010629a:	8b 45 08             	mov    0x8(%ebp),%eax
c010629d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01062a0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01062a6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01062a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01062ac:	89 d1                	mov    %edx,%ecx
c01062ae:	89 c2                	mov    %eax,%edx
c01062b0:	89 ce                	mov    %ecx,%esi
c01062b2:	89 d7                	mov    %edx,%edi
c01062b4:	ac                   	lods   %ds:(%esi),%al
c01062b5:	aa                   	stos   %al,%es:(%edi)
c01062b6:	84 c0                	test   %al,%al
c01062b8:	75 fa                	jne    c01062b4 <strcpy+0x22>
c01062ba:	89 fa                	mov    %edi,%edx
c01062bc:	89 f1                	mov    %esi,%ecx
c01062be:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01062c1:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01062c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01062c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01062ca:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01062cb:	83 c4 20             	add    $0x20,%esp
c01062ce:	5e                   	pop    %esi
c01062cf:	5f                   	pop    %edi
c01062d0:	5d                   	pop    %ebp
c01062d1:	c3                   	ret    

c01062d2 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01062d2:	55                   	push   %ebp
c01062d3:	89 e5                	mov    %esp,%ebp
c01062d5:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01062d8:	8b 45 08             	mov    0x8(%ebp),%eax
c01062db:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01062de:	eb 1e                	jmp    c01062fe <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c01062e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062e3:	0f b6 10             	movzbl (%eax),%edx
c01062e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01062e9:	88 10                	mov    %dl,(%eax)
c01062eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01062ee:	0f b6 00             	movzbl (%eax),%eax
c01062f1:	84 c0                	test   %al,%al
c01062f3:	74 03                	je     c01062f8 <strncpy+0x26>
            src ++;
c01062f5:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c01062f8:	ff 45 fc             	incl   -0x4(%ebp)
c01062fb:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c01062fe:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106302:	75 dc                	jne    c01062e0 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0106304:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106307:	c9                   	leave  
c0106308:	c3                   	ret    

c0106309 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0106309:	55                   	push   %ebp
c010630a:	89 e5                	mov    %esp,%ebp
c010630c:	57                   	push   %edi
c010630d:	56                   	push   %esi
c010630e:	83 ec 20             	sub    $0x20,%esp
c0106311:	8b 45 08             	mov    0x8(%ebp),%eax
c0106314:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010631a:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c010631d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106320:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106323:	89 d1                	mov    %edx,%ecx
c0106325:	89 c2                	mov    %eax,%edx
c0106327:	89 ce                	mov    %ecx,%esi
c0106329:	89 d7                	mov    %edx,%edi
c010632b:	ac                   	lods   %ds:(%esi),%al
c010632c:	ae                   	scas   %es:(%edi),%al
c010632d:	75 08                	jne    c0106337 <strcmp+0x2e>
c010632f:	84 c0                	test   %al,%al
c0106331:	75 f8                	jne    c010632b <strcmp+0x22>
c0106333:	31 c0                	xor    %eax,%eax
c0106335:	eb 04                	jmp    c010633b <strcmp+0x32>
c0106337:	19 c0                	sbb    %eax,%eax
c0106339:	0c 01                	or     $0x1,%al
c010633b:	89 fa                	mov    %edi,%edx
c010633d:	89 f1                	mov    %esi,%ecx
c010633f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106342:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106345:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0106348:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c010634b:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c010634c:	83 c4 20             	add    $0x20,%esp
c010634f:	5e                   	pop    %esi
c0106350:	5f                   	pop    %edi
c0106351:	5d                   	pop    %ebp
c0106352:	c3                   	ret    

c0106353 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0106353:	55                   	push   %ebp
c0106354:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106356:	eb 09                	jmp    c0106361 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0106358:	ff 4d 10             	decl   0x10(%ebp)
c010635b:	ff 45 08             	incl   0x8(%ebp)
c010635e:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0106361:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106365:	74 1a                	je     c0106381 <strncmp+0x2e>
c0106367:	8b 45 08             	mov    0x8(%ebp),%eax
c010636a:	0f b6 00             	movzbl (%eax),%eax
c010636d:	84 c0                	test   %al,%al
c010636f:	74 10                	je     c0106381 <strncmp+0x2e>
c0106371:	8b 45 08             	mov    0x8(%ebp),%eax
c0106374:	0f b6 10             	movzbl (%eax),%edx
c0106377:	8b 45 0c             	mov    0xc(%ebp),%eax
c010637a:	0f b6 00             	movzbl (%eax),%eax
c010637d:	38 c2                	cmp    %al,%dl
c010637f:	74 d7                	je     c0106358 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0106381:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106385:	74 18                	je     c010639f <strncmp+0x4c>
c0106387:	8b 45 08             	mov    0x8(%ebp),%eax
c010638a:	0f b6 00             	movzbl (%eax),%eax
c010638d:	0f b6 d0             	movzbl %al,%edx
c0106390:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106393:	0f b6 00             	movzbl (%eax),%eax
c0106396:	0f b6 c0             	movzbl %al,%eax
c0106399:	29 c2                	sub    %eax,%edx
c010639b:	89 d0                	mov    %edx,%eax
c010639d:	eb 05                	jmp    c01063a4 <strncmp+0x51>
c010639f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063a4:	5d                   	pop    %ebp
c01063a5:	c3                   	ret    

c01063a6 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c01063a6:	55                   	push   %ebp
c01063a7:	89 e5                	mov    %esp,%ebp
c01063a9:	83 ec 04             	sub    $0x4,%esp
c01063ac:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063af:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01063b2:	eb 13                	jmp    c01063c7 <strchr+0x21>
        if (*s == c) {
c01063b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01063b7:	0f b6 00             	movzbl (%eax),%eax
c01063ba:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01063bd:	75 05                	jne    c01063c4 <strchr+0x1e>
            return (char *)s;
c01063bf:	8b 45 08             	mov    0x8(%ebp),%eax
c01063c2:	eb 12                	jmp    c01063d6 <strchr+0x30>
        }
        s ++;
c01063c4:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c01063c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01063ca:	0f b6 00             	movzbl (%eax),%eax
c01063cd:	84 c0                	test   %al,%al
c01063cf:	75 e3                	jne    c01063b4 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c01063d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01063d6:	c9                   	leave  
c01063d7:	c3                   	ret    

c01063d8 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c01063d8:	55                   	push   %ebp
c01063d9:	89 e5                	mov    %esp,%ebp
c01063db:	83 ec 04             	sub    $0x4,%esp
c01063de:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063e1:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c01063e4:	eb 0e                	jmp    c01063f4 <strfind+0x1c>
        if (*s == c) {
c01063e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01063e9:	0f b6 00             	movzbl (%eax),%eax
c01063ec:	3a 45 fc             	cmp    -0x4(%ebp),%al
c01063ef:	74 0f                	je     c0106400 <strfind+0x28>
            break;
        }
        s ++;
c01063f1:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c01063f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01063f7:	0f b6 00             	movzbl (%eax),%eax
c01063fa:	84 c0                	test   %al,%al
c01063fc:	75 e8                	jne    c01063e6 <strfind+0xe>
c01063fe:	eb 01                	jmp    c0106401 <strfind+0x29>
        if (*s == c) {
            break;
c0106400:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0106401:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0106404:	c9                   	leave  
c0106405:	c3                   	ret    

c0106406 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0106406:	55                   	push   %ebp
c0106407:	89 e5                	mov    %esp,%ebp
c0106409:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c010640c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0106413:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010641a:	eb 03                	jmp    c010641f <strtol+0x19>
        s ++;
c010641c:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c010641f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106422:	0f b6 00             	movzbl (%eax),%eax
c0106425:	3c 20                	cmp    $0x20,%al
c0106427:	74 f3                	je     c010641c <strtol+0x16>
c0106429:	8b 45 08             	mov    0x8(%ebp),%eax
c010642c:	0f b6 00             	movzbl (%eax),%eax
c010642f:	3c 09                	cmp    $0x9,%al
c0106431:	74 e9                	je     c010641c <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0106433:	8b 45 08             	mov    0x8(%ebp),%eax
c0106436:	0f b6 00             	movzbl (%eax),%eax
c0106439:	3c 2b                	cmp    $0x2b,%al
c010643b:	75 05                	jne    c0106442 <strtol+0x3c>
        s ++;
c010643d:	ff 45 08             	incl   0x8(%ebp)
c0106440:	eb 14                	jmp    c0106456 <strtol+0x50>
    }
    else if (*s == '-') {
c0106442:	8b 45 08             	mov    0x8(%ebp),%eax
c0106445:	0f b6 00             	movzbl (%eax),%eax
c0106448:	3c 2d                	cmp    $0x2d,%al
c010644a:	75 0a                	jne    c0106456 <strtol+0x50>
        s ++, neg = 1;
c010644c:	ff 45 08             	incl   0x8(%ebp)
c010644f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0106456:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010645a:	74 06                	je     c0106462 <strtol+0x5c>
c010645c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0106460:	75 22                	jne    c0106484 <strtol+0x7e>
c0106462:	8b 45 08             	mov    0x8(%ebp),%eax
c0106465:	0f b6 00             	movzbl (%eax),%eax
c0106468:	3c 30                	cmp    $0x30,%al
c010646a:	75 18                	jne    c0106484 <strtol+0x7e>
c010646c:	8b 45 08             	mov    0x8(%ebp),%eax
c010646f:	40                   	inc    %eax
c0106470:	0f b6 00             	movzbl (%eax),%eax
c0106473:	3c 78                	cmp    $0x78,%al
c0106475:	75 0d                	jne    c0106484 <strtol+0x7e>
        s += 2, base = 16;
c0106477:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c010647b:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0106482:	eb 29                	jmp    c01064ad <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0106484:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0106488:	75 16                	jne    c01064a0 <strtol+0x9a>
c010648a:	8b 45 08             	mov    0x8(%ebp),%eax
c010648d:	0f b6 00             	movzbl (%eax),%eax
c0106490:	3c 30                	cmp    $0x30,%al
c0106492:	75 0c                	jne    c01064a0 <strtol+0x9a>
        s ++, base = 8;
c0106494:	ff 45 08             	incl   0x8(%ebp)
c0106497:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010649e:	eb 0d                	jmp    c01064ad <strtol+0xa7>
    }
    else if (base == 0) {
c01064a0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01064a4:	75 07                	jne    c01064ad <strtol+0xa7>
        base = 10;
c01064a6:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c01064ad:	8b 45 08             	mov    0x8(%ebp),%eax
c01064b0:	0f b6 00             	movzbl (%eax),%eax
c01064b3:	3c 2f                	cmp    $0x2f,%al
c01064b5:	7e 1b                	jle    c01064d2 <strtol+0xcc>
c01064b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01064ba:	0f b6 00             	movzbl (%eax),%eax
c01064bd:	3c 39                	cmp    $0x39,%al
c01064bf:	7f 11                	jg     c01064d2 <strtol+0xcc>
            dig = *s - '0';
c01064c1:	8b 45 08             	mov    0x8(%ebp),%eax
c01064c4:	0f b6 00             	movzbl (%eax),%eax
c01064c7:	0f be c0             	movsbl %al,%eax
c01064ca:	83 e8 30             	sub    $0x30,%eax
c01064cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01064d0:	eb 48                	jmp    c010651a <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c01064d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01064d5:	0f b6 00             	movzbl (%eax),%eax
c01064d8:	3c 60                	cmp    $0x60,%al
c01064da:	7e 1b                	jle    c01064f7 <strtol+0xf1>
c01064dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01064df:	0f b6 00             	movzbl (%eax),%eax
c01064e2:	3c 7a                	cmp    $0x7a,%al
c01064e4:	7f 11                	jg     c01064f7 <strtol+0xf1>
            dig = *s - 'a' + 10;
c01064e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01064e9:	0f b6 00             	movzbl (%eax),%eax
c01064ec:	0f be c0             	movsbl %al,%eax
c01064ef:	83 e8 57             	sub    $0x57,%eax
c01064f2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01064f5:	eb 23                	jmp    c010651a <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c01064f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01064fa:	0f b6 00             	movzbl (%eax),%eax
c01064fd:	3c 40                	cmp    $0x40,%al
c01064ff:	7e 3b                	jle    c010653c <strtol+0x136>
c0106501:	8b 45 08             	mov    0x8(%ebp),%eax
c0106504:	0f b6 00             	movzbl (%eax),%eax
c0106507:	3c 5a                	cmp    $0x5a,%al
c0106509:	7f 31                	jg     c010653c <strtol+0x136>
            dig = *s - 'A' + 10;
c010650b:	8b 45 08             	mov    0x8(%ebp),%eax
c010650e:	0f b6 00             	movzbl (%eax),%eax
c0106511:	0f be c0             	movsbl %al,%eax
c0106514:	83 e8 37             	sub    $0x37,%eax
c0106517:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010651a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010651d:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106520:	7d 19                	jge    c010653b <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106522:	ff 45 08             	incl   0x8(%ebp)
c0106525:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106528:	0f af 45 10          	imul   0x10(%ebp),%eax
c010652c:	89 c2                	mov    %eax,%edx
c010652e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106531:	01 d0                	add    %edx,%eax
c0106533:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0106536:	e9 72 ff ff ff       	jmp    c01064ad <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c010653b:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c010653c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106540:	74 08                	je     c010654a <strtol+0x144>
        *endptr = (char *) s;
c0106542:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106545:	8b 55 08             	mov    0x8(%ebp),%edx
c0106548:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010654a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c010654e:	74 07                	je     c0106557 <strtol+0x151>
c0106550:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106553:	f7 d8                	neg    %eax
c0106555:	eb 03                	jmp    c010655a <strtol+0x154>
c0106557:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010655a:	c9                   	leave  
c010655b:	c3                   	ret    

c010655c <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c010655c:	55                   	push   %ebp
c010655d:	89 e5                	mov    %esp,%ebp
c010655f:	57                   	push   %edi
c0106560:	83 ec 24             	sub    $0x24,%esp
c0106563:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106566:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106569:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010656d:	8b 55 08             	mov    0x8(%ebp),%edx
c0106570:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0106573:	88 45 f7             	mov    %al,-0x9(%ebp)
c0106576:	8b 45 10             	mov    0x10(%ebp),%eax
c0106579:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010657c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010657f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0106583:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0106586:	89 d7                	mov    %edx,%edi
c0106588:	f3 aa                	rep stos %al,%es:(%edi)
c010658a:	89 fa                	mov    %edi,%edx
c010658c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010658f:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0106592:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106595:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0106596:	83 c4 24             	add    $0x24,%esp
c0106599:	5f                   	pop    %edi
c010659a:	5d                   	pop    %ebp
c010659b:	c3                   	ret    

c010659c <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010659c:	55                   	push   %ebp
c010659d:	89 e5                	mov    %esp,%ebp
c010659f:	57                   	push   %edi
c01065a0:	56                   	push   %esi
c01065a1:	53                   	push   %ebx
c01065a2:	83 ec 30             	sub    $0x30,%esp
c01065a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01065a8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01065ab:	8b 45 0c             	mov    0xc(%ebp),%eax
c01065ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01065b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01065b4:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01065b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065ba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01065bd:	73 42                	jae    c0106601 <memmove+0x65>
c01065bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01065c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01065c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065c8:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01065cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01065ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01065d1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01065d4:	c1 e8 02             	shr    $0x2,%eax
c01065d7:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01065d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01065dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01065df:	89 d7                	mov    %edx,%edi
c01065e1:	89 c6                	mov    %eax,%esi
c01065e3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01065e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01065e8:	83 e1 03             	and    $0x3,%ecx
c01065eb:	74 02                	je     c01065ef <memmove+0x53>
c01065ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01065ef:	89 f0                	mov    %esi,%eax
c01065f1:	89 fa                	mov    %edi,%edx
c01065f3:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c01065f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c01065f9:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c01065fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c01065ff:	eb 36                	jmp    c0106637 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106601:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106604:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106607:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010660a:	01 c2                	add    %eax,%edx
c010660c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010660f:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106612:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106615:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0106618:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010661b:	89 c1                	mov    %eax,%ecx
c010661d:	89 d8                	mov    %ebx,%eax
c010661f:	89 d6                	mov    %edx,%esi
c0106621:	89 c7                	mov    %eax,%edi
c0106623:	fd                   	std    
c0106624:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106626:	fc                   	cld    
c0106627:	89 f8                	mov    %edi,%eax
c0106629:	89 f2                	mov    %esi,%edx
c010662b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c010662e:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106631:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0106634:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0106637:	83 c4 30             	add    $0x30,%esp
c010663a:	5b                   	pop    %ebx
c010663b:	5e                   	pop    %esi
c010663c:	5f                   	pop    %edi
c010663d:	5d                   	pop    %ebp
c010663e:	c3                   	ret    

c010663f <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c010663f:	55                   	push   %ebp
c0106640:	89 e5                	mov    %esp,%ebp
c0106642:	57                   	push   %edi
c0106643:	56                   	push   %esi
c0106644:	83 ec 20             	sub    $0x20,%esp
c0106647:	8b 45 08             	mov    0x8(%ebp),%eax
c010664a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010664d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106650:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106653:	8b 45 10             	mov    0x10(%ebp),%eax
c0106656:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106659:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010665c:	c1 e8 02             	shr    $0x2,%eax
c010665f:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0106661:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106664:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106667:	89 d7                	mov    %edx,%edi
c0106669:	89 c6                	mov    %eax,%esi
c010666b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c010666d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106670:	83 e1 03             	and    $0x3,%ecx
c0106673:	74 02                	je     c0106677 <memcpy+0x38>
c0106675:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106677:	89 f0                	mov    %esi,%eax
c0106679:	89 fa                	mov    %edi,%edx
c010667b:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c010667e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106681:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0106684:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0106687:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0106688:	83 c4 20             	add    $0x20,%esp
c010668b:	5e                   	pop    %esi
c010668c:	5f                   	pop    %edi
c010668d:	5d                   	pop    %ebp
c010668e:	c3                   	ret    

c010668f <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c010668f:	55                   	push   %ebp
c0106690:	89 e5                	mov    %esp,%ebp
c0106692:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0106695:	8b 45 08             	mov    0x8(%ebp),%eax
c0106698:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c010669b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010669e:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01066a1:	eb 2e                	jmp    c01066d1 <memcmp+0x42>
        if (*s1 != *s2) {
c01066a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066a6:	0f b6 10             	movzbl (%eax),%edx
c01066a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01066ac:	0f b6 00             	movzbl (%eax),%eax
c01066af:	38 c2                	cmp    %al,%dl
c01066b1:	74 18                	je     c01066cb <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01066b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01066b6:	0f b6 00             	movzbl (%eax),%eax
c01066b9:	0f b6 d0             	movzbl %al,%edx
c01066bc:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01066bf:	0f b6 00             	movzbl (%eax),%eax
c01066c2:	0f b6 c0             	movzbl %al,%eax
c01066c5:	29 c2                	sub    %eax,%edx
c01066c7:	89 d0                	mov    %edx,%eax
c01066c9:	eb 18                	jmp    c01066e3 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01066cb:	ff 45 fc             	incl   -0x4(%ebp)
c01066ce:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c01066d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01066d4:	8d 50 ff             	lea    -0x1(%eax),%edx
c01066d7:	89 55 10             	mov    %edx,0x10(%ebp)
c01066da:	85 c0                	test   %eax,%eax
c01066dc:	75 c5                	jne    c01066a3 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c01066de:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01066e3:	c9                   	leave  
c01066e4:	c3                   	ret    

c01066e5 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01066e5:	55                   	push   %ebp
c01066e6:	89 e5                	mov    %esp,%ebp
c01066e8:	83 ec 58             	sub    $0x58,%esp
c01066eb:	8b 45 10             	mov    0x10(%ebp),%eax
c01066ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01066f1:	8b 45 14             	mov    0x14(%ebp),%eax
c01066f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01066f7:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01066fa:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01066fd:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106700:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0106703:	8b 45 18             	mov    0x18(%ebp),%eax
c0106706:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106709:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010670c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010670f:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106712:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0106715:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106718:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010671b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010671f:	74 1c                	je     c010673d <printnum+0x58>
c0106721:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106724:	ba 00 00 00 00       	mov    $0x0,%edx
c0106729:	f7 75 e4             	divl   -0x1c(%ebp)
c010672c:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010672f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106732:	ba 00 00 00 00       	mov    $0x0,%edx
c0106737:	f7 75 e4             	divl   -0x1c(%ebp)
c010673a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010673d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106740:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106743:	f7 75 e4             	divl   -0x1c(%ebp)
c0106746:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0106749:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010674c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010674f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106752:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106755:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106758:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010675b:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010675e:	8b 45 18             	mov    0x18(%ebp),%eax
c0106761:	ba 00 00 00 00       	mov    $0x0,%edx
c0106766:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0106769:	77 56                	ja     c01067c1 <printnum+0xdc>
c010676b:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c010676e:	72 05                	jb     c0106775 <printnum+0x90>
c0106770:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0106773:	77 4c                	ja     c01067c1 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0106775:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0106778:	8d 50 ff             	lea    -0x1(%eax),%edx
c010677b:	8b 45 20             	mov    0x20(%ebp),%eax
c010677e:	89 44 24 18          	mov    %eax,0x18(%esp)
c0106782:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106786:	8b 45 18             	mov    0x18(%ebp),%eax
c0106789:	89 44 24 10          	mov    %eax,0x10(%esp)
c010678d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106790:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106793:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106797:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010679b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010679e:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01067a5:	89 04 24             	mov    %eax,(%esp)
c01067a8:	e8 38 ff ff ff       	call   c01066e5 <printnum>
c01067ad:	eb 1b                	jmp    c01067ca <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c01067af:	8b 45 0c             	mov    0xc(%ebp),%eax
c01067b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01067b6:	8b 45 20             	mov    0x20(%ebp),%eax
c01067b9:	89 04 24             	mov    %eax,(%esp)
c01067bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01067bf:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c01067c1:	ff 4d 1c             	decl   0x1c(%ebp)
c01067c4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01067c8:	7f e5                	jg     c01067af <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01067ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01067cd:	05 d8 80 10 c0       	add    $0xc01080d8,%eax
c01067d2:	0f b6 00             	movzbl (%eax),%eax
c01067d5:	0f be c0             	movsbl %al,%eax
c01067d8:	8b 55 0c             	mov    0xc(%ebp),%edx
c01067db:	89 54 24 04          	mov    %edx,0x4(%esp)
c01067df:	89 04 24             	mov    %eax,(%esp)
c01067e2:	8b 45 08             	mov    0x8(%ebp),%eax
c01067e5:	ff d0                	call   *%eax
}
c01067e7:	90                   	nop
c01067e8:	c9                   	leave  
c01067e9:	c3                   	ret    

c01067ea <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01067ea:	55                   	push   %ebp
c01067eb:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01067ed:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01067f1:	7e 14                	jle    c0106807 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01067f3:	8b 45 08             	mov    0x8(%ebp),%eax
c01067f6:	8b 00                	mov    (%eax),%eax
c01067f8:	8d 48 08             	lea    0x8(%eax),%ecx
c01067fb:	8b 55 08             	mov    0x8(%ebp),%edx
c01067fe:	89 0a                	mov    %ecx,(%edx)
c0106800:	8b 50 04             	mov    0x4(%eax),%edx
c0106803:	8b 00                	mov    (%eax),%eax
c0106805:	eb 30                	jmp    c0106837 <getuint+0x4d>
    }
    else if (lflag) {
c0106807:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010680b:	74 16                	je     c0106823 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c010680d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106810:	8b 00                	mov    (%eax),%eax
c0106812:	8d 48 04             	lea    0x4(%eax),%ecx
c0106815:	8b 55 08             	mov    0x8(%ebp),%edx
c0106818:	89 0a                	mov    %ecx,(%edx)
c010681a:	8b 00                	mov    (%eax),%eax
c010681c:	ba 00 00 00 00       	mov    $0x0,%edx
c0106821:	eb 14                	jmp    c0106837 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0106823:	8b 45 08             	mov    0x8(%ebp),%eax
c0106826:	8b 00                	mov    (%eax),%eax
c0106828:	8d 48 04             	lea    0x4(%eax),%ecx
c010682b:	8b 55 08             	mov    0x8(%ebp),%edx
c010682e:	89 0a                	mov    %ecx,(%edx)
c0106830:	8b 00                	mov    (%eax),%eax
c0106832:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0106837:	5d                   	pop    %ebp
c0106838:	c3                   	ret    

c0106839 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0106839:	55                   	push   %ebp
c010683a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c010683c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0106840:	7e 14                	jle    c0106856 <getint+0x1d>
        return va_arg(*ap, long long);
c0106842:	8b 45 08             	mov    0x8(%ebp),%eax
c0106845:	8b 00                	mov    (%eax),%eax
c0106847:	8d 48 08             	lea    0x8(%eax),%ecx
c010684a:	8b 55 08             	mov    0x8(%ebp),%edx
c010684d:	89 0a                	mov    %ecx,(%edx)
c010684f:	8b 50 04             	mov    0x4(%eax),%edx
c0106852:	8b 00                	mov    (%eax),%eax
c0106854:	eb 28                	jmp    c010687e <getint+0x45>
    }
    else if (lflag) {
c0106856:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010685a:	74 12                	je     c010686e <getint+0x35>
        return va_arg(*ap, long);
c010685c:	8b 45 08             	mov    0x8(%ebp),%eax
c010685f:	8b 00                	mov    (%eax),%eax
c0106861:	8d 48 04             	lea    0x4(%eax),%ecx
c0106864:	8b 55 08             	mov    0x8(%ebp),%edx
c0106867:	89 0a                	mov    %ecx,(%edx)
c0106869:	8b 00                	mov    (%eax),%eax
c010686b:	99                   	cltd   
c010686c:	eb 10                	jmp    c010687e <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c010686e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106871:	8b 00                	mov    (%eax),%eax
c0106873:	8d 48 04             	lea    0x4(%eax),%ecx
c0106876:	8b 55 08             	mov    0x8(%ebp),%edx
c0106879:	89 0a                	mov    %ecx,(%edx)
c010687b:	8b 00                	mov    (%eax),%eax
c010687d:	99                   	cltd   
    }
}
c010687e:	5d                   	pop    %ebp
c010687f:	c3                   	ret    

c0106880 <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0106880:	55                   	push   %ebp
c0106881:	89 e5                	mov    %esp,%ebp
c0106883:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0106886:	8d 45 14             	lea    0x14(%ebp),%eax
c0106889:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c010688c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010688f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106893:	8b 45 10             	mov    0x10(%ebp),%eax
c0106896:	89 44 24 08          	mov    %eax,0x8(%esp)
c010689a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010689d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01068a4:	89 04 24             	mov    %eax,(%esp)
c01068a7:	e8 03 00 00 00       	call   c01068af <vprintfmt>
    va_end(ap);
}
c01068ac:	90                   	nop
c01068ad:	c9                   	leave  
c01068ae:	c3                   	ret    

c01068af <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c01068af:	55                   	push   %ebp
c01068b0:	89 e5                	mov    %esp,%ebp
c01068b2:	56                   	push   %esi
c01068b3:	53                   	push   %ebx
c01068b4:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01068b7:	eb 17                	jmp    c01068d0 <vprintfmt+0x21>
            if (ch == '\0') {
c01068b9:	85 db                	test   %ebx,%ebx
c01068bb:	0f 84 bf 03 00 00    	je     c0106c80 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01068c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01068c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01068c8:	89 1c 24             	mov    %ebx,(%esp)
c01068cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01068ce:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01068d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01068d3:	8d 50 01             	lea    0x1(%eax),%edx
c01068d6:	89 55 10             	mov    %edx,0x10(%ebp)
c01068d9:	0f b6 00             	movzbl (%eax),%eax
c01068dc:	0f b6 d8             	movzbl %al,%ebx
c01068df:	83 fb 25             	cmp    $0x25,%ebx
c01068e2:	75 d5                	jne    c01068b9 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c01068e4:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01068e8:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01068ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01068f2:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01068f5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01068fc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01068ff:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106902:	8b 45 10             	mov    0x10(%ebp),%eax
c0106905:	8d 50 01             	lea    0x1(%eax),%edx
c0106908:	89 55 10             	mov    %edx,0x10(%ebp)
c010690b:	0f b6 00             	movzbl (%eax),%eax
c010690e:	0f b6 d8             	movzbl %al,%ebx
c0106911:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106914:	83 f8 55             	cmp    $0x55,%eax
c0106917:	0f 87 37 03 00 00    	ja     c0106c54 <vprintfmt+0x3a5>
c010691d:	8b 04 85 fc 80 10 c0 	mov    -0x3fef7f04(,%eax,4),%eax
c0106924:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106926:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c010692a:	eb d6                	jmp    c0106902 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010692c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0106930:	eb d0                	jmp    c0106902 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106932:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106939:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010693c:	89 d0                	mov    %edx,%eax
c010693e:	c1 e0 02             	shl    $0x2,%eax
c0106941:	01 d0                	add    %edx,%eax
c0106943:	01 c0                	add    %eax,%eax
c0106945:	01 d8                	add    %ebx,%eax
c0106947:	83 e8 30             	sub    $0x30,%eax
c010694a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010694d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106950:	0f b6 00             	movzbl (%eax),%eax
c0106953:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106956:	83 fb 2f             	cmp    $0x2f,%ebx
c0106959:	7e 38                	jle    c0106993 <vprintfmt+0xe4>
c010695b:	83 fb 39             	cmp    $0x39,%ebx
c010695e:	7f 33                	jg     c0106993 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106960:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0106963:	eb d4                	jmp    c0106939 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106965:	8b 45 14             	mov    0x14(%ebp),%eax
c0106968:	8d 50 04             	lea    0x4(%eax),%edx
c010696b:	89 55 14             	mov    %edx,0x14(%ebp)
c010696e:	8b 00                	mov    (%eax),%eax
c0106970:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106973:	eb 1f                	jmp    c0106994 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106975:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106979:	79 87                	jns    c0106902 <vprintfmt+0x53>
                width = 0;
c010697b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0106982:	e9 7b ff ff ff       	jmp    c0106902 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0106987:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010698e:	e9 6f ff ff ff       	jmp    c0106902 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0106993:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0106994:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106998:	0f 89 64 ff ff ff    	jns    c0106902 <vprintfmt+0x53>
                width = precision, precision = -1;
c010699e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01069a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01069a4:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01069ab:	e9 52 ff ff ff       	jmp    c0106902 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01069b0:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01069b3:	e9 4a ff ff ff       	jmp    c0106902 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01069b8:	8b 45 14             	mov    0x14(%ebp),%eax
c01069bb:	8d 50 04             	lea    0x4(%eax),%edx
c01069be:	89 55 14             	mov    %edx,0x14(%ebp)
c01069c1:	8b 00                	mov    (%eax),%eax
c01069c3:	8b 55 0c             	mov    0xc(%ebp),%edx
c01069c6:	89 54 24 04          	mov    %edx,0x4(%esp)
c01069ca:	89 04 24             	mov    %eax,(%esp)
c01069cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01069d0:	ff d0                	call   *%eax
            break;
c01069d2:	e9 a4 02 00 00       	jmp    c0106c7b <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01069d7:	8b 45 14             	mov    0x14(%ebp),%eax
c01069da:	8d 50 04             	lea    0x4(%eax),%edx
c01069dd:	89 55 14             	mov    %edx,0x14(%ebp)
c01069e0:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01069e2:	85 db                	test   %ebx,%ebx
c01069e4:	79 02                	jns    c01069e8 <vprintfmt+0x139>
                err = -err;
c01069e6:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01069e8:	83 fb 06             	cmp    $0x6,%ebx
c01069eb:	7f 0b                	jg     c01069f8 <vprintfmt+0x149>
c01069ed:	8b 34 9d bc 80 10 c0 	mov    -0x3fef7f44(,%ebx,4),%esi
c01069f4:	85 f6                	test   %esi,%esi
c01069f6:	75 23                	jne    c0106a1b <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01069f8:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01069fc:	c7 44 24 08 e9 80 10 	movl   $0xc01080e9,0x8(%esp)
c0106a03:	c0 
c0106a04:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a07:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a0e:	89 04 24             	mov    %eax,(%esp)
c0106a11:	e8 6a fe ff ff       	call   c0106880 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106a16:	e9 60 02 00 00       	jmp    c0106c7b <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0106a1b:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0106a1f:	c7 44 24 08 f2 80 10 	movl   $0xc01080f2,0x8(%esp)
c0106a26:	c0 
c0106a27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106a2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a2e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a31:	89 04 24             	mov    %eax,(%esp)
c0106a34:	e8 47 fe ff ff       	call   c0106880 <printfmt>
            }
            break;
c0106a39:	e9 3d 02 00 00       	jmp    c0106c7b <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0106a3e:	8b 45 14             	mov    0x14(%ebp),%eax
c0106a41:	8d 50 04             	lea    0x4(%eax),%edx
c0106a44:	89 55 14             	mov    %edx,0x14(%ebp)
c0106a47:	8b 30                	mov    (%eax),%esi
c0106a49:	85 f6                	test   %esi,%esi
c0106a4b:	75 05                	jne    c0106a52 <vprintfmt+0x1a3>
                p = "(null)";
c0106a4d:	be f5 80 10 c0       	mov    $0xc01080f5,%esi
            }
            if (width > 0 && padc != '-') {
c0106a52:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a56:	7e 76                	jle    c0106ace <vprintfmt+0x21f>
c0106a58:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0106a5c:	74 70                	je     c0106ace <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106a61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106a65:	89 34 24             	mov    %esi,(%esp)
c0106a68:	e8 f6 f7 ff ff       	call   c0106263 <strnlen>
c0106a6d:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106a70:	29 c2                	sub    %eax,%edx
c0106a72:	89 d0                	mov    %edx,%eax
c0106a74:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106a77:	eb 16                	jmp    c0106a8f <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106a79:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0106a7d:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106a80:	89 54 24 04          	mov    %edx,0x4(%esp)
c0106a84:	89 04 24             	mov    %eax,(%esp)
c0106a87:	8b 45 08             	mov    0x8(%ebp),%eax
c0106a8a:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0106a8c:	ff 4d e8             	decl   -0x18(%ebp)
c0106a8f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106a93:	7f e4                	jg     c0106a79 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106a95:	eb 37                	jmp    c0106ace <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0106a97:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0106a9b:	74 1f                	je     c0106abc <vprintfmt+0x20d>
c0106a9d:	83 fb 1f             	cmp    $0x1f,%ebx
c0106aa0:	7e 05                	jle    c0106aa7 <vprintfmt+0x1f8>
c0106aa2:	83 fb 7e             	cmp    $0x7e,%ebx
c0106aa5:	7e 15                	jle    c0106abc <vprintfmt+0x20d>
                    putch('?', putdat);
c0106aa7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106aaa:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106aae:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0106ab5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ab8:	ff d0                	call   *%eax
c0106aba:	eb 0f                	jmp    c0106acb <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0106abc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106abf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106ac3:	89 1c 24             	mov    %ebx,(%esp)
c0106ac6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ac9:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0106acb:	ff 4d e8             	decl   -0x18(%ebp)
c0106ace:	89 f0                	mov    %esi,%eax
c0106ad0:	8d 70 01             	lea    0x1(%eax),%esi
c0106ad3:	0f b6 00             	movzbl (%eax),%eax
c0106ad6:	0f be d8             	movsbl %al,%ebx
c0106ad9:	85 db                	test   %ebx,%ebx
c0106adb:	74 27                	je     c0106b04 <vprintfmt+0x255>
c0106add:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106ae1:	78 b4                	js     c0106a97 <vprintfmt+0x1e8>
c0106ae3:	ff 4d e4             	decl   -0x1c(%ebp)
c0106ae6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106aea:	79 ab                	jns    c0106a97 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106aec:	eb 16                	jmp    c0106b04 <vprintfmt+0x255>
                putch(' ', putdat);
c0106aee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106af1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106af5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0106afc:	8b 45 08             	mov    0x8(%ebp),%eax
c0106aff:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106b01:	ff 4d e8             	decl   -0x18(%ebp)
c0106b04:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106b08:	7f e4                	jg     c0106aee <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0106b0a:	e9 6c 01 00 00       	jmp    c0106c7b <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0106b0f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b16:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b19:	89 04 24             	mov    %eax,(%esp)
c0106b1c:	e8 18 fd ff ff       	call   c0106839 <getint>
c0106b21:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b24:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106b27:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b2d:	85 d2                	test   %edx,%edx
c0106b2f:	79 26                	jns    c0106b57 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106b31:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106b34:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b38:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0106b3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106b42:	ff d0                	call   *%eax
                num = -(long long)num;
c0106b44:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106b47:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106b4a:	f7 d8                	neg    %eax
c0106b4c:	83 d2 00             	adc    $0x0,%edx
c0106b4f:	f7 da                	neg    %edx
c0106b51:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b54:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106b57:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b5e:	e9 a8 00 00 00       	jmp    c0106c0b <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106b63:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b66:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b6a:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b6d:	89 04 24             	mov    %eax,(%esp)
c0106b70:	e8 75 fc ff ff       	call   c01067ea <getuint>
c0106b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b78:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0106b7b:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0106b82:	e9 84 00 00 00       	jmp    c0106c0b <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0106b87:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106b8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106b8e:	8d 45 14             	lea    0x14(%ebp),%eax
c0106b91:	89 04 24             	mov    %eax,(%esp)
c0106b94:	e8 51 fc ff ff       	call   c01067ea <getuint>
c0106b99:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106b9c:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0106b9f:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0106ba6:	eb 63                	jmp    c0106c0b <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0106ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106baf:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0106bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bb9:	ff d0                	call   *%eax
            putch('x', putdat);
c0106bbb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106bbe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bc2:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0106bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0106bcc:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0106bce:	8b 45 14             	mov    0x14(%ebp),%eax
c0106bd1:	8d 50 04             	lea    0x4(%eax),%edx
c0106bd4:	89 55 14             	mov    %edx,0x14(%ebp)
c0106bd7:	8b 00                	mov    (%eax),%eax
c0106bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106bdc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106be3:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106bea:	eb 1f                	jmp    c0106c0b <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0106bec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106bef:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106bf3:	8d 45 14             	lea    0x14(%ebp),%eax
c0106bf6:	89 04 24             	mov    %eax,(%esp)
c0106bf9:	e8 ec fb ff ff       	call   c01067ea <getuint>
c0106bfe:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106c01:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106c04:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0106c0b:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0106c0f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106c12:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106c16:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106c19:	89 54 24 14          	mov    %edx,0x14(%esp)
c0106c1d:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106c21:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106c24:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106c27:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106c2b:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0106c2f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c32:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c36:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c39:	89 04 24             	mov    %eax,(%esp)
c0106c3c:	e8 a4 fa ff ff       	call   c01066e5 <printnum>
            break;
c0106c41:	eb 38                	jmp    c0106c7b <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106c43:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c46:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c4a:	89 1c 24             	mov    %ebx,(%esp)
c0106c4d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c50:	ff d0                	call   *%eax
            break;
c0106c52:	eb 27                	jmp    c0106c7b <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106c54:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106c5b:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106c62:	8b 45 08             	mov    0x8(%ebp),%eax
c0106c65:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106c67:	ff 4d 10             	decl   0x10(%ebp)
c0106c6a:	eb 03                	jmp    c0106c6f <vprintfmt+0x3c0>
c0106c6c:	ff 4d 10             	decl   0x10(%ebp)
c0106c6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0106c72:	48                   	dec    %eax
c0106c73:	0f b6 00             	movzbl (%eax),%eax
c0106c76:	3c 25                	cmp    $0x25,%al
c0106c78:	75 f2                	jne    c0106c6c <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106c7a:	90                   	nop
        }
    }
c0106c7b:	e9 37 fc ff ff       	jmp    c01068b7 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c0106c80:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c0106c81:	83 c4 40             	add    $0x40,%esp
c0106c84:	5b                   	pop    %ebx
c0106c85:	5e                   	pop    %esi
c0106c86:	5d                   	pop    %ebp
c0106c87:	c3                   	ret    

c0106c88 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0106c88:	55                   	push   %ebp
c0106c89:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0106c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c8e:	8b 40 08             	mov    0x8(%eax),%eax
c0106c91:	8d 50 01             	lea    0x1(%eax),%edx
c0106c94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c97:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0106c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106c9d:	8b 10                	mov    (%eax),%edx
c0106c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106ca2:	8b 40 04             	mov    0x4(%eax),%eax
c0106ca5:	39 c2                	cmp    %eax,%edx
c0106ca7:	73 12                	jae    c0106cbb <sprintputch+0x33>
        *b->buf ++ = ch;
c0106ca9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cac:	8b 00                	mov    (%eax),%eax
c0106cae:	8d 48 01             	lea    0x1(%eax),%ecx
c0106cb1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106cb4:	89 0a                	mov    %ecx,(%edx)
c0106cb6:	8b 55 08             	mov    0x8(%ebp),%edx
c0106cb9:	88 10                	mov    %dl,(%eax)
    }
}
c0106cbb:	90                   	nop
c0106cbc:	5d                   	pop    %ebp
c0106cbd:	c3                   	ret    

c0106cbe <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0106cbe:	55                   	push   %ebp
c0106cbf:	89 e5                	mov    %esp,%ebp
c0106cc1:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0106cc4:	8d 45 14             	lea    0x14(%ebp),%eax
c0106cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0106cca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106ccd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106cd1:	8b 45 10             	mov    0x10(%ebp),%eax
c0106cd4:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106cdb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce2:	89 04 24             	mov    %eax,(%esp)
c0106ce5:	e8 08 00 00 00       	call   c0106cf2 <vsnprintf>
c0106cea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0106ced:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106cf0:	c9                   	leave  
c0106cf1:	c3                   	ret    

c0106cf2 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106cf2:	55                   	push   %ebp
c0106cf3:	89 e5                	mov    %esp,%ebp
c0106cf5:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106cf8:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cfb:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106cfe:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106d01:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106d04:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d07:	01 d0                	add    %edx,%eax
c0106d09:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106d0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106d13:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106d17:	74 0a                	je     c0106d23 <vsnprintf+0x31>
c0106d19:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106d1f:	39 c2                	cmp    %eax,%edx
c0106d21:	76 07                	jbe    c0106d2a <vsnprintf+0x38>
        return -E_INVAL;
c0106d23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106d28:	eb 2a                	jmp    c0106d54 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106d2a:	8b 45 14             	mov    0x14(%ebp),%eax
c0106d2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106d31:	8b 45 10             	mov    0x10(%ebp),%eax
c0106d34:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106d38:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0106d3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106d3f:	c7 04 24 88 6c 10 c0 	movl   $0xc0106c88,(%esp)
c0106d46:	e8 64 fb ff ff       	call   c01068af <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0106d4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106d4e:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106d51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106d54:	c9                   	leave  
c0106d55:	c3                   	ret    
