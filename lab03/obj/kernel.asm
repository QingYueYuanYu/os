
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 20 12 00       	mov    $0x122000,%eax
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
c0100020:	a3 00 20 12 c0       	mov    %eax,0xc0122000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 10 12 c0       	mov    $0xc0121000,%esp
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
c010003c:	ba 18 51 12 c0       	mov    $0xc0125118,%edx
c0100041:	b8 00 40 12 c0       	mov    $0xc0124000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 40 12 c0 	movl   $0xc0124000,(%esp)
c010005d:	e8 98 88 00 00       	call   c01088fa <memset>

    cons_init();                // init the console
c0100062:	e8 eb 1d 00 00       	call   c0101e52 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 e0 91 10 c0 	movl   $0xc01091e0,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 fc 91 10 c0 	movl   $0xc01091fc,(%esp)
c010007c:	e8 20 02 00 00       	call   c01002a1 <cprintf>

    print_kerninfo();
c0100081:	e8 c1 08 00 00       	call   c0100947 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 98 00 00 00       	call   c0100123 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 85 3a 00 00       	call   c0103b15 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 21 1f 00 00       	call   c0101fb6 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 7a 20 00 00       	call   c0102114 <idt_init>

    vmm_init();                 // init virtual memory management
c010009a:	e8 70 51 00 00       	call   c010520f <vmm_init>

    ide_init();                 // init ide devices
c010009f:	e8 52 0d 00 00       	call   c0100df6 <ide_init>
    swap_init();                // init swap
c01000a4:	e8 65 5b 00 00       	call   c0105c0e <swap_init>

    clock_init();               // init clock interrupt
c01000a9:	e8 57 15 00 00       	call   c0101605 <clock_init>
    intr_enable();              // enable irq interrupt
c01000ae:	e8 36 20 00 00       	call   c01020e9 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000b3:	eb fe                	jmp    c01000b3 <kern_init+0x7d>

c01000b5 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000b5:	55                   	push   %ebp
c01000b6:	89 e5                	mov    %esp,%ebp
c01000b8:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000bb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000c2:	00 
c01000c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000ca:	00 
c01000cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000d2:	e8 b4 0c 00 00       	call   c0100d8b <mon_backtrace>
}
c01000d7:	90                   	nop
c01000d8:	c9                   	leave  
c01000d9:	c3                   	ret    

c01000da <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000da:	55                   	push   %ebp
c01000db:	89 e5                	mov    %esp,%ebp
c01000dd:	53                   	push   %ebx
c01000de:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000e1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000e4:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000e7:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01000ed:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000f1:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000f9:	89 04 24             	mov    %eax,(%esp)
c01000fc:	e8 b4 ff ff ff       	call   c01000b5 <grade_backtrace2>
}
c0100101:	90                   	nop
c0100102:	83 c4 14             	add    $0x14,%esp
c0100105:	5b                   	pop    %ebx
c0100106:	5d                   	pop    %ebp
c0100107:	c3                   	ret    

c0100108 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c0100108:	55                   	push   %ebp
c0100109:	89 e5                	mov    %esp,%ebp
c010010b:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c010010e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100111:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100115:	8b 45 08             	mov    0x8(%ebp),%eax
c0100118:	89 04 24             	mov    %eax,(%esp)
c010011b:	e8 ba ff ff ff       	call   c01000da <grade_backtrace1>
}
c0100120:	90                   	nop
c0100121:	c9                   	leave  
c0100122:	c3                   	ret    

c0100123 <grade_backtrace>:

void
grade_backtrace(void) {
c0100123:	55                   	push   %ebp
c0100124:	89 e5                	mov    %esp,%ebp
c0100126:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c0100129:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010012e:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100135:	ff 
c0100136:	89 44 24 04          	mov    %eax,0x4(%esp)
c010013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100141:	e8 c2 ff ff ff       	call   c0100108 <grade_backtrace0>
}
c0100146:	90                   	nop
c0100147:	c9                   	leave  
c0100148:	c3                   	ret    

c0100149 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c0100149:	55                   	push   %ebp
c010014a:	89 e5                	mov    %esp,%ebp
c010014c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c010014f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100152:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100155:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100158:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010015b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010015f:	83 e0 03             	and    $0x3,%eax
c0100162:	89 c2                	mov    %eax,%edx
c0100164:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c0100169:	89 54 24 08          	mov    %edx,0x8(%esp)
c010016d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100171:	c7 04 24 01 92 10 c0 	movl   $0xc0109201,(%esp)
c0100178:	e8 24 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010017d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100181:	89 c2                	mov    %eax,%edx
c0100183:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c0100188:	89 54 24 08          	mov    %edx,0x8(%esp)
c010018c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100190:	c7 04 24 0f 92 10 c0 	movl   $0xc010920f,(%esp)
c0100197:	e8 05 01 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010019c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c01001a0:	89 c2                	mov    %eax,%edx
c01001a2:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c01001a7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001af:	c7 04 24 1d 92 10 c0 	movl   $0xc010921d,(%esp)
c01001b6:	e8 e6 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001bb:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001bf:	89 c2                	mov    %eax,%edx
c01001c1:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c01001c6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ce:	c7 04 24 2b 92 10 c0 	movl   $0xc010922b,(%esp)
c01001d5:	e8 c7 00 00 00       	call   c01002a1 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001da:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001de:	89 c2                	mov    %eax,%edx
c01001e0:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c01001e5:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001ed:	c7 04 24 39 92 10 c0 	movl   $0xc0109239,(%esp)
c01001f4:	e8 a8 00 00 00       	call   c01002a1 <cprintf>
    round ++;
c01001f9:	a1 00 40 12 c0       	mov    0xc0124000,%eax
c01001fe:	40                   	inc    %eax
c01001ff:	a3 00 40 12 c0       	mov    %eax,0xc0124000
}
c0100204:	90                   	nop
c0100205:	c9                   	leave  
c0100206:	c3                   	ret    

c0100207 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c0100207:	55                   	push   %ebp
c0100208:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c010020a:	90                   	nop
c010020b:	5d                   	pop    %ebp
c010020c:	c3                   	ret    

c010020d <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c010020d:	55                   	push   %ebp
c010020e:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100210:	90                   	nop
c0100211:	5d                   	pop    %ebp
c0100212:	c3                   	ret    

c0100213 <lab1_switch_test>:

static void
lab1_switch_test(void) {
c0100213:	55                   	push   %ebp
c0100214:	89 e5                	mov    %esp,%ebp
c0100216:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100219:	e8 2b ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021e:	c7 04 24 48 92 10 c0 	movl   $0xc0109248,(%esp)
c0100225:	e8 77 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_user();
c010022a:	e8 d8 ff ff ff       	call   c0100207 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022f:	e8 15 ff ff ff       	call   c0100149 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100234:	c7 04 24 68 92 10 c0 	movl   $0xc0109268,(%esp)
c010023b:	e8 61 00 00 00       	call   c01002a1 <cprintf>
    lab1_switch_to_kernel();
c0100240:	e8 c8 ff ff ff       	call   c010020d <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100245:	e8 ff fe ff ff       	call   c0100149 <lab1_print_cur_status>
}
c010024a:	90                   	nop
c010024b:	c9                   	leave  
c010024c:	c3                   	ret    

c010024d <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c010024d:	55                   	push   %ebp
c010024e:	89 e5                	mov    %esp,%ebp
c0100250:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 04 24             	mov    %eax,(%esp)
c0100259:	e8 21 1c 00 00       	call   c0101e7f <cons_putc>
    (*cnt) ++;
c010025e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100261:	8b 00                	mov    (%eax),%eax
c0100263:	8d 50 01             	lea    0x1(%eax),%edx
c0100266:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100269:	89 10                	mov    %edx,(%eax)
}
c010026b:	90                   	nop
c010026c:	c9                   	leave  
c010026d:	c3                   	ret    

c010026e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026e:	55                   	push   %ebp
c010026f:	89 e5                	mov    %esp,%ebp
c0100271:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100274:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010027b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100282:	8b 45 08             	mov    0x8(%ebp),%eax
c0100285:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100289:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010028c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100290:	c7 04 24 4d 02 10 c0 	movl   $0xc010024d,(%esp)
c0100297:	e8 b1 89 00 00       	call   c0108c4d <vprintfmt>
    return cnt;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010029f:	c9                   	leave  
c01002a0:	c3                   	ret    

c01002a1 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c01002a1:	55                   	push   %ebp
c01002a2:	89 e5                	mov    %esp,%ebp
c01002a4:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a7:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002b0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b4:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b7:	89 04 24             	mov    %eax,(%esp)
c01002ba:	e8 af ff ff ff       	call   c010026e <vcprintf>
c01002bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c5:	c9                   	leave  
c01002c6:	c3                   	ret    

c01002c7 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c7:	55                   	push   %ebp
c01002c8:	89 e5                	mov    %esp,%ebp
c01002ca:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002cd:	8b 45 08             	mov    0x8(%ebp),%eax
c01002d0:	89 04 24             	mov    %eax,(%esp)
c01002d3:	e8 a7 1b 00 00       	call   c0101e7f <cons_putc>
}
c01002d8:	90                   	nop
c01002d9:	c9                   	leave  
c01002da:	c3                   	ret    

c01002db <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002db:	55                   	push   %ebp
c01002dc:	89 e5                	mov    %esp,%ebp
c01002de:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002e1:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e8:	eb 13                	jmp    c01002fd <cputs+0x22>
        cputch(c, &cnt);
c01002ea:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ee:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002f1:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f5:	89 04 24             	mov    %eax,(%esp)
c01002f8:	e8 50 ff ff ff       	call   c010024d <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100300:	8d 50 01             	lea    0x1(%eax),%edx
c0100303:	89 55 08             	mov    %edx,0x8(%ebp)
c0100306:	0f b6 00             	movzbl (%eax),%eax
c0100309:	88 45 f7             	mov    %al,-0x9(%ebp)
c010030c:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c0100310:	75 d8                	jne    c01002ea <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c0100312:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100315:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100319:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c0100320:	e8 28 ff ff ff       	call   c010024d <cputch>
    return cnt;
c0100325:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100328:	c9                   	leave  
c0100329:	c3                   	ret    

c010032a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c010032a:	55                   	push   %ebp
c010032b:	89 e5                	mov    %esp,%ebp
c010032d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c0100330:	e8 87 1b 00 00       	call   c0101ebc <cons_getc>
c0100335:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100338:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010033c:	74 f2                	je     c0100330 <getchar+0x6>
        /* do nothing */;
    return c;
c010033e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100341:	c9                   	leave  
c0100342:	c3                   	ret    

c0100343 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100343:	55                   	push   %ebp
c0100344:	89 e5                	mov    %esp,%ebp
c0100346:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100349:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010034d:	74 13                	je     c0100362 <readline+0x1f>
        cprintf("%s", prompt);
c010034f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100352:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100356:	c7 04 24 87 92 10 c0 	movl   $0xc0109287,(%esp)
c010035d:	e8 3f ff ff ff       	call   c01002a1 <cprintf>
    }
    int i = 0, c;
c0100362:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100369:	e8 bc ff ff ff       	call   c010032a <getchar>
c010036e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100371:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100375:	79 07                	jns    c010037e <readline+0x3b>
            return NULL;
c0100377:	b8 00 00 00 00       	mov    $0x0,%eax
c010037c:	eb 78                	jmp    c01003f6 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037e:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100382:	7e 28                	jle    c01003ac <readline+0x69>
c0100384:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010038b:	7f 1f                	jg     c01003ac <readline+0x69>
            cputchar(c);
c010038d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100390:	89 04 24             	mov    %eax,(%esp)
c0100393:	e8 2f ff ff ff       	call   c01002c7 <cputchar>
            buf[i ++] = c;
c0100398:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010039b:	8d 50 01             	lea    0x1(%eax),%edx
c010039e:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01003a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a4:	88 90 20 40 12 c0    	mov    %dl,-0x3fedbfe0(%eax)
c01003aa:	eb 45                	jmp    c01003f1 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003ac:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003b0:	75 16                	jne    c01003c8 <readline+0x85>
c01003b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b6:	7e 10                	jle    c01003c8 <readline+0x85>
            cputchar(c);
c01003b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003bb:	89 04 24             	mov    %eax,(%esp)
c01003be:	e8 04 ff ff ff       	call   c01002c7 <cputchar>
            i --;
c01003c3:	ff 4d f4             	decl   -0xc(%ebp)
c01003c6:	eb 29                	jmp    c01003f1 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003c8:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003cc:	74 06                	je     c01003d4 <readline+0x91>
c01003ce:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003d2:	75 95                	jne    c0100369 <readline+0x26>
            cputchar(c);
c01003d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d7:	89 04 24             	mov    %eax,(%esp)
c01003da:	e8 e8 fe ff ff       	call   c01002c7 <cputchar>
            buf[i] = '\0';
c01003df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003e2:	05 20 40 12 c0       	add    $0xc0124020,%eax
c01003e7:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003ea:	b8 20 40 12 c0       	mov    $0xc0124020,%eax
c01003ef:	eb 05                	jmp    c01003f6 <readline+0xb3>
        }
    }
c01003f1:	e9 73 ff ff ff       	jmp    c0100369 <readline+0x26>
}
c01003f6:	c9                   	leave  
c01003f7:	c3                   	ret    

c01003f8 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f8:	55                   	push   %ebp
c01003f9:	89 e5                	mov    %esp,%ebp
c01003fb:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003fe:	a1 20 44 12 c0       	mov    0xc0124420,%eax
c0100403:	85 c0                	test   %eax,%eax
c0100405:	75 5b                	jne    c0100462 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100407:	c7 05 20 44 12 c0 01 	movl   $0x1,0xc0124420
c010040e:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100411:	8d 45 14             	lea    0x14(%ebp),%eax
c0100414:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100417:	8b 45 0c             	mov    0xc(%ebp),%eax
c010041a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010041e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100421:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100425:	c7 04 24 8a 92 10 c0 	movl   $0xc010928a,(%esp)
c010042c:	e8 70 fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c0100431:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100434:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100438:	8b 45 10             	mov    0x10(%ebp),%eax
c010043b:	89 04 24             	mov    %eax,(%esp)
c010043e:	e8 2b fe ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c0100443:	c7 04 24 a6 92 10 c0 	movl   $0xc01092a6,(%esp)
c010044a:	e8 52 fe ff ff       	call   c01002a1 <cprintf>
    
    cprintf("stack trackback:\n");
c010044f:	c7 04 24 a8 92 10 c0 	movl   $0xc01092a8,(%esp)
c0100456:	e8 46 fe ff ff       	call   c01002a1 <cprintf>
    print_stackframe();
c010045b:	e8 32 06 00 00       	call   c0100a92 <print_stackframe>
c0100460:	eb 01                	jmp    c0100463 <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c0100462:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100463:	e8 88 1c 00 00       	call   c01020f0 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100468:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010046f:	e8 4a 08 00 00       	call   c0100cbe <kmonitor>
    }
c0100474:	eb f2                	jmp    c0100468 <__panic+0x70>

c0100476 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100476:	55                   	push   %ebp
c0100477:	89 e5                	mov    %esp,%ebp
c0100479:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c010047c:	8d 45 14             	lea    0x14(%ebp),%eax
c010047f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100482:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100485:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100489:	8b 45 08             	mov    0x8(%ebp),%eax
c010048c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100490:	c7 04 24 ba 92 10 c0 	movl   $0xc01092ba,(%esp)
c0100497:	e8 05 fe ff ff       	call   c01002a1 <cprintf>
    vcprintf(fmt, ap);
c010049c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010049f:	89 44 24 04          	mov    %eax,0x4(%esp)
c01004a3:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a6:	89 04 24             	mov    %eax,(%esp)
c01004a9:	e8 c0 fd ff ff       	call   c010026e <vcprintf>
    cprintf("\n");
c01004ae:	c7 04 24 a6 92 10 c0 	movl   $0xc01092a6,(%esp)
c01004b5:	e8 e7 fd ff ff       	call   c01002a1 <cprintf>
    va_end(ap);
}
c01004ba:	90                   	nop
c01004bb:	c9                   	leave  
c01004bc:	c3                   	ret    

c01004bd <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004bd:	55                   	push   %ebp
c01004be:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004c0:	a1 20 44 12 c0       	mov    0xc0124420,%eax
}
c01004c5:	5d                   	pop    %ebp
c01004c6:	c3                   	ret    

c01004c7 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c7:	55                   	push   %ebp
c01004c8:	89 e5                	mov    %esp,%ebp
c01004ca:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004d0:	8b 00                	mov    (%eax),%eax
c01004d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d5:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d8:	8b 00                	mov    (%eax),%eax
c01004da:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e4:	e9 ca 00 00 00       	jmp    c01005b3 <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004e9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004ec:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004ef:	01 d0                	add    %edx,%eax
c01004f1:	89 c2                	mov    %eax,%edx
c01004f3:	c1 ea 1f             	shr    $0x1f,%edx
c01004f6:	01 d0                	add    %edx,%eax
c01004f8:	d1 f8                	sar    %eax
c01004fa:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100500:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100503:	eb 03                	jmp    c0100508 <stab_binsearch+0x41>
            m --;
c0100505:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100508:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010050b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050e:	7c 1f                	jl     c010052f <stab_binsearch+0x68>
c0100510:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100513:	89 d0                	mov    %edx,%eax
c0100515:	01 c0                	add    %eax,%eax
c0100517:	01 d0                	add    %edx,%eax
c0100519:	c1 e0 02             	shl    $0x2,%eax
c010051c:	89 c2                	mov    %eax,%edx
c010051e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100521:	01 d0                	add    %edx,%eax
c0100523:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100527:	0f b6 c0             	movzbl %al,%eax
c010052a:	3b 45 14             	cmp    0x14(%ebp),%eax
c010052d:	75 d6                	jne    c0100505 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010052f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100532:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100535:	7d 09                	jge    c0100540 <stab_binsearch+0x79>
            l = true_m + 1;
c0100537:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010053a:	40                   	inc    %eax
c010053b:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053e:	eb 73                	jmp    c01005b3 <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c0100540:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100547:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010054a:	89 d0                	mov    %edx,%eax
c010054c:	01 c0                	add    %eax,%eax
c010054e:	01 d0                	add    %edx,%eax
c0100550:	c1 e0 02             	shl    $0x2,%eax
c0100553:	89 c2                	mov    %eax,%edx
c0100555:	8b 45 08             	mov    0x8(%ebp),%eax
c0100558:	01 d0                	add    %edx,%eax
c010055a:	8b 40 08             	mov    0x8(%eax),%eax
c010055d:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100560:	73 11                	jae    c0100573 <stab_binsearch+0xac>
            *region_left = m;
c0100562:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100565:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100568:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c010056a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010056d:	40                   	inc    %eax
c010056e:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100571:	eb 40                	jmp    c01005b3 <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c0100573:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100576:	89 d0                	mov    %edx,%eax
c0100578:	01 c0                	add    %eax,%eax
c010057a:	01 d0                	add    %edx,%eax
c010057c:	c1 e0 02             	shl    $0x2,%eax
c010057f:	89 c2                	mov    %eax,%edx
c0100581:	8b 45 08             	mov    0x8(%ebp),%eax
c0100584:	01 d0                	add    %edx,%eax
c0100586:	8b 40 08             	mov    0x8(%eax),%eax
c0100589:	3b 45 18             	cmp    0x18(%ebp),%eax
c010058c:	76 14                	jbe    c01005a2 <stab_binsearch+0xdb>
            *region_right = m - 1;
c010058e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100591:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100594:	8b 45 10             	mov    0x10(%ebp),%eax
c0100597:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100599:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010059c:	48                   	dec    %eax
c010059d:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01005a0:	eb 11                	jmp    c01005b3 <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01005a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a8:	89 10                	mov    %edx,(%eax)
            l = m;
c01005aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005ad:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005b0:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b6:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b9:	0f 8e 2a ff ff ff    	jle    c01004e9 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005bf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005c3:	75 0f                	jne    c01005d4 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005c5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c8:	8b 00                	mov    (%eax),%eax
c01005ca:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005cd:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d0:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005d2:	eb 3e                	jmp    c0100612 <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005d4:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d7:	8b 00                	mov    (%eax),%eax
c01005d9:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005dc:	eb 03                	jmp    c01005e1 <stab_binsearch+0x11a>
c01005de:	ff 4d fc             	decl   -0x4(%ebp)
c01005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e4:	8b 00                	mov    (%eax),%eax
c01005e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005e9:	7d 1f                	jge    c010060a <stab_binsearch+0x143>
c01005eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ee:	89 d0                	mov    %edx,%eax
c01005f0:	01 c0                	add    %eax,%eax
c01005f2:	01 d0                	add    %edx,%eax
c01005f4:	c1 e0 02             	shl    $0x2,%eax
c01005f7:	89 c2                	mov    %eax,%edx
c01005f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01005fc:	01 d0                	add    %edx,%eax
c01005fe:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100602:	0f b6 c0             	movzbl %al,%eax
c0100605:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100608:	75 d4                	jne    c01005de <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c010060a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010060d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100610:	89 10                	mov    %edx,(%eax)
    }
}
c0100612:	90                   	nop
c0100613:	c9                   	leave  
c0100614:	c3                   	ret    

c0100615 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100615:	55                   	push   %ebp
c0100616:	89 e5                	mov    %esp,%ebp
c0100618:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c010061b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061e:	c7 00 d8 92 10 c0    	movl   $0xc01092d8,(%eax)
    info->eip_line = 0;
c0100624:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100627:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100631:	c7 40 08 d8 92 10 c0 	movl   $0xc01092d8,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100638:	8b 45 0c             	mov    0xc(%ebp),%eax
c010063b:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c0100642:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100645:	8b 55 08             	mov    0x8(%ebp),%edx
c0100648:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c010064b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100655:	c7 45 f4 b8 b3 10 c0 	movl   $0xc010b3b8,-0xc(%ebp)
    stab_end = __STAB_END__;
c010065c:	c7 45 f0 a8 ad 11 c0 	movl   $0xc011ada8,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c0100663:	c7 45 ec a9 ad 11 c0 	movl   $0xc011ada9,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c010066a:	c7 45 e8 b8 e7 11 c0 	movl   $0xc011e7b8,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c0100671:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100674:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100677:	76 0b                	jbe    c0100684 <debuginfo_eip+0x6f>
c0100679:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010067c:	48                   	dec    %eax
c010067d:	0f b6 00             	movzbl (%eax),%eax
c0100680:	84 c0                	test   %al,%al
c0100682:	74 0a                	je     c010068e <debuginfo_eip+0x79>
        return -1;
c0100684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100689:	e9 b7 02 00 00       	jmp    c0100945 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100695:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100698:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010069b:	29 c2                	sub    %eax,%edx
c010069d:	89 d0                	mov    %edx,%eax
c010069f:	c1 f8 02             	sar    $0x2,%eax
c01006a2:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a8:	48                   	dec    %eax
c01006a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01006af:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006b3:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006ba:	00 
c01006bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006be:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006c2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006cc:	89 04 24             	mov    %eax,(%esp)
c01006cf:	e8 f3 fd ff ff       	call   c01004c7 <stab_binsearch>
    if (lfile == 0)
c01006d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d7:	85 c0                	test   %eax,%eax
c01006d9:	75 0a                	jne    c01006e5 <debuginfo_eip+0xd0>
        return -1;
c01006db:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006e0:	e9 60 02 00 00       	jmp    c0100945 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006f1:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f4:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f8:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006ff:	00 
c0100700:	8d 45 d8             	lea    -0x28(%ebp),%eax
c0100703:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100707:	8d 45 dc             	lea    -0x24(%ebp),%eax
c010070a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100711:	89 04 24             	mov    %eax,(%esp)
c0100714:	e8 ae fd ff ff       	call   c01004c7 <stab_binsearch>

    if (lfun <= rfun) {
c0100719:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071f:	39 c2                	cmp    %eax,%edx
c0100721:	7f 7c                	jg     c010079f <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c0100723:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100726:	89 c2                	mov    %eax,%edx
c0100728:	89 d0                	mov    %edx,%eax
c010072a:	01 c0                	add    %eax,%eax
c010072c:	01 d0                	add    %edx,%eax
c010072e:	c1 e0 02             	shl    $0x2,%eax
c0100731:	89 c2                	mov    %eax,%edx
c0100733:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100736:	01 d0                	add    %edx,%eax
c0100738:	8b 00                	mov    (%eax),%eax
c010073a:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c010073d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100740:	29 d1                	sub    %edx,%ecx
c0100742:	89 ca                	mov    %ecx,%edx
c0100744:	39 d0                	cmp    %edx,%eax
c0100746:	73 22                	jae    c010076a <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100748:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010074b:	89 c2                	mov    %eax,%edx
c010074d:	89 d0                	mov    %edx,%eax
c010074f:	01 c0                	add    %eax,%eax
c0100751:	01 d0                	add    %edx,%eax
c0100753:	c1 e0 02             	shl    $0x2,%eax
c0100756:	89 c2                	mov    %eax,%edx
c0100758:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010075b:	01 d0                	add    %edx,%eax
c010075d:	8b 10                	mov    (%eax),%edx
c010075f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100762:	01 c2                	add    %eax,%edx
c0100764:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100767:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010076a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010076d:	89 c2                	mov    %eax,%edx
c010076f:	89 d0                	mov    %edx,%eax
c0100771:	01 c0                	add    %eax,%eax
c0100773:	01 d0                	add    %edx,%eax
c0100775:	c1 e0 02             	shl    $0x2,%eax
c0100778:	89 c2                	mov    %eax,%edx
c010077a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010077d:	01 d0                	add    %edx,%eax
c010077f:	8b 50 08             	mov    0x8(%eax),%edx
c0100782:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100785:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100788:	8b 45 0c             	mov    0xc(%ebp),%eax
c010078b:	8b 40 10             	mov    0x10(%eax),%eax
c010078e:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c0100791:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100794:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100797:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010079a:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010079d:	eb 15                	jmp    c01007b4 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010079f:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007a2:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a5:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007ab:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007b4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b7:	8b 40 08             	mov    0x8(%eax),%eax
c01007ba:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007c1:	00 
c01007c2:	89 04 24             	mov    %eax,(%esp)
c01007c5:	e8 ac 7f 00 00       	call   c0108776 <strfind>
c01007ca:	89 c2                	mov    %eax,%edx
c01007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cf:	8b 40 08             	mov    0x8(%eax),%eax
c01007d2:	29 c2                	sub    %eax,%edx
c01007d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d7:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007da:	8b 45 08             	mov    0x8(%ebp),%eax
c01007dd:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007e1:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e8:	00 
c01007e9:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007ec:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007f0:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007f3:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007fa:	89 04 24             	mov    %eax,(%esp)
c01007fd:	e8 c5 fc ff ff       	call   c01004c7 <stab_binsearch>
    if (lline <= rline) {
c0100802:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100805:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100808:	39 c2                	cmp    %eax,%edx
c010080a:	7f 23                	jg     c010082f <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c010080c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010080f:	89 c2                	mov    %eax,%edx
c0100811:	89 d0                	mov    %edx,%eax
c0100813:	01 c0                	add    %eax,%eax
c0100815:	01 d0                	add    %edx,%eax
c0100817:	c1 e0 02             	shl    $0x2,%eax
c010081a:	89 c2                	mov    %eax,%edx
c010081c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081f:	01 d0                	add    %edx,%eax
c0100821:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100825:	89 c2                	mov    %eax,%edx
c0100827:	8b 45 0c             	mov    0xc(%ebp),%eax
c010082a:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010082d:	eb 11                	jmp    c0100840 <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010082f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100834:	e9 0c 01 00 00       	jmp    c0100945 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100839:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010083c:	48                   	dec    %eax
c010083d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100840:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100843:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100846:	39 c2                	cmp    %eax,%edx
c0100848:	7c 56                	jl     c01008a0 <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c010084a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010084d:	89 c2                	mov    %eax,%edx
c010084f:	89 d0                	mov    %edx,%eax
c0100851:	01 c0                	add    %eax,%eax
c0100853:	01 d0                	add    %edx,%eax
c0100855:	c1 e0 02             	shl    $0x2,%eax
c0100858:	89 c2                	mov    %eax,%edx
c010085a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010085d:	01 d0                	add    %edx,%eax
c010085f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100863:	3c 84                	cmp    $0x84,%al
c0100865:	74 39                	je     c01008a0 <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100867:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010086a:	89 c2                	mov    %eax,%edx
c010086c:	89 d0                	mov    %edx,%eax
c010086e:	01 c0                	add    %eax,%eax
c0100870:	01 d0                	add    %edx,%eax
c0100872:	c1 e0 02             	shl    $0x2,%eax
c0100875:	89 c2                	mov    %eax,%edx
c0100877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010087a:	01 d0                	add    %edx,%eax
c010087c:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100880:	3c 64                	cmp    $0x64,%al
c0100882:	75 b5                	jne    c0100839 <debuginfo_eip+0x224>
c0100884:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100887:	89 c2                	mov    %eax,%edx
c0100889:	89 d0                	mov    %edx,%eax
c010088b:	01 c0                	add    %eax,%eax
c010088d:	01 d0                	add    %edx,%eax
c010088f:	c1 e0 02             	shl    $0x2,%eax
c0100892:	89 c2                	mov    %eax,%edx
c0100894:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100897:	01 d0                	add    %edx,%eax
c0100899:	8b 40 08             	mov    0x8(%eax),%eax
c010089c:	85 c0                	test   %eax,%eax
c010089e:	74 99                	je     c0100839 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01008a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01008a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a6:	39 c2                	cmp    %eax,%edx
c01008a8:	7c 46                	jl     c01008f0 <debuginfo_eip+0x2db>
c01008aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ad:	89 c2                	mov    %eax,%edx
c01008af:	89 d0                	mov    %edx,%eax
c01008b1:	01 c0                	add    %eax,%eax
c01008b3:	01 d0                	add    %edx,%eax
c01008b5:	c1 e0 02             	shl    $0x2,%eax
c01008b8:	89 c2                	mov    %eax,%edx
c01008ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008bd:	01 d0                	add    %edx,%eax
c01008bf:	8b 00                	mov    (%eax),%eax
c01008c1:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008c7:	29 d1                	sub    %edx,%ecx
c01008c9:	89 ca                	mov    %ecx,%edx
c01008cb:	39 d0                	cmp    %edx,%eax
c01008cd:	73 21                	jae    c01008f0 <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008d2:	89 c2                	mov    %eax,%edx
c01008d4:	89 d0                	mov    %edx,%eax
c01008d6:	01 c0                	add    %eax,%eax
c01008d8:	01 d0                	add    %edx,%eax
c01008da:	c1 e0 02             	shl    $0x2,%eax
c01008dd:	89 c2                	mov    %eax,%edx
c01008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008e2:	01 d0                	add    %edx,%eax
c01008e4:	8b 10                	mov    (%eax),%edx
c01008e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008e9:	01 c2                	add    %eax,%edx
c01008eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ee:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008f3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f6:	39 c2                	cmp    %eax,%edx
c01008f8:	7d 46                	jge    c0100940 <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008fd:	40                   	inc    %eax
c01008fe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100901:	eb 16                	jmp    c0100919 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100903:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100906:	8b 40 14             	mov    0x14(%eax),%eax
c0100909:	8d 50 01             	lea    0x1(%eax),%edx
c010090c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090f:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c0100912:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100915:	40                   	inc    %eax
c0100916:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100919:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010091c:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010091f:	39 c2                	cmp    %eax,%edx
c0100921:	7d 1d                	jge    c0100940 <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100923:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100926:	89 c2                	mov    %eax,%edx
c0100928:	89 d0                	mov    %edx,%eax
c010092a:	01 c0                	add    %eax,%eax
c010092c:	01 d0                	add    %edx,%eax
c010092e:	c1 e0 02             	shl    $0x2,%eax
c0100931:	89 c2                	mov    %eax,%edx
c0100933:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100936:	01 d0                	add    %edx,%eax
c0100938:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010093c:	3c a0                	cmp    $0xa0,%al
c010093e:	74 c3                	je     c0100903 <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c0100940:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100945:	c9                   	leave  
c0100946:	c3                   	ret    

c0100947 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100947:	55                   	push   %ebp
c0100948:	89 e5                	mov    %esp,%ebp
c010094a:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010094d:	c7 04 24 e2 92 10 c0 	movl   $0xc01092e2,(%esp)
c0100954:	e8 48 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100959:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100960:	c0 
c0100961:	c7 04 24 fb 92 10 c0 	movl   $0xc01092fb,(%esp)
c0100968:	e8 34 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010096d:	c7 44 24 04 cc 91 10 	movl   $0xc01091cc,0x4(%esp)
c0100974:	c0 
c0100975:	c7 04 24 13 93 10 c0 	movl   $0xc0109313,(%esp)
c010097c:	e8 20 f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c0100981:	c7 44 24 04 00 40 12 	movl   $0xc0124000,0x4(%esp)
c0100988:	c0 
c0100989:	c7 04 24 2b 93 10 c0 	movl   $0xc010932b,(%esp)
c0100990:	e8 0c f9 ff ff       	call   c01002a1 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100995:	c7 44 24 04 18 51 12 	movl   $0xc0125118,0x4(%esp)
c010099c:	c0 
c010099d:	c7 04 24 43 93 10 c0 	movl   $0xc0109343,(%esp)
c01009a4:	e8 f8 f8 ff ff       	call   c01002a1 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009a9:	b8 18 51 12 c0       	mov    $0xc0125118,%eax
c01009ae:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b4:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009b9:	29 c2                	sub    %eax,%edx
c01009bb:	89 d0                	mov    %edx,%eax
c01009bd:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009c3:	85 c0                	test   %eax,%eax
c01009c5:	0f 48 c2             	cmovs  %edx,%eax
c01009c8:	c1 f8 0a             	sar    $0xa,%eax
c01009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009cf:	c7 04 24 5c 93 10 c0 	movl   $0xc010935c,(%esp)
c01009d6:	e8 c6 f8 ff ff       	call   c01002a1 <cprintf>
}
c01009db:	90                   	nop
c01009dc:	c9                   	leave  
c01009dd:	c3                   	ret    

c01009de <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009de:	55                   	push   %ebp
c01009df:	89 e5                	mov    %esp,%ebp
c01009e1:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e7:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01009f1:	89 04 24             	mov    %eax,(%esp)
c01009f4:	e8 1c fc ff ff       	call   c0100615 <debuginfo_eip>
c01009f9:	85 c0                	test   %eax,%eax
c01009fb:	74 15                	je     c0100a12 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009fd:	8b 45 08             	mov    0x8(%ebp),%eax
c0100a00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a04:	c7 04 24 86 93 10 c0 	movl   $0xc0109386,(%esp)
c0100a0b:	e8 91 f8 ff ff       	call   c01002a1 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a10:	eb 6c                	jmp    c0100a7e <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a12:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a19:	eb 1b                	jmp    c0100a36 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a1b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a21:	01 d0                	add    %edx,%eax
c0100a23:	0f b6 00             	movzbl (%eax),%eax
c0100a26:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a2f:	01 ca                	add    %ecx,%edx
c0100a31:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a33:	ff 45 f4             	incl   -0xc(%ebp)
c0100a36:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a39:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a3c:	7f dd                	jg     c0100a1b <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a3e:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a47:	01 d0                	add    %edx,%eax
c0100a49:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a4f:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a52:	89 d1                	mov    %edx,%ecx
c0100a54:	29 c1                	sub    %eax,%ecx
c0100a56:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a59:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a5c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a60:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a66:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a6a:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a72:	c7 04 24 a2 93 10 c0 	movl   $0xc01093a2,(%esp)
c0100a79:	e8 23 f8 ff ff       	call   c01002a1 <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a7e:	90                   	nop
c0100a7f:	c9                   	leave  
c0100a80:	c3                   	ret    

c0100a81 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a81:	55                   	push   %ebp
c0100a82:	89 e5                	mov    %esp,%ebp
c0100a84:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a87:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a8a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a8d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a90:	c9                   	leave  
c0100a91:	c3                   	ret    

c0100a92 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a92:	55                   	push   %ebp
c0100a93:	89 e5                	mov    %esp,%ebp
c0100a95:	83 ec 38             	sub    $0x38,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a98:	89 e8                	mov    %ebp,%eax
c0100a9a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return ebp;
c0100a9d:	8b 45 e0             	mov    -0x20(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();
c0100aa0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100aa3:	e8 d9 ff ff ff       	call   c0100a81 <read_eip>
c0100aa8:	89 45 f0             	mov    %eax,-0x10(%ebp)

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100aab:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100ab2:	e9 84 00 00 00       	jmp    c0100b3b <print_stackframe+0xa9>
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
c0100ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100aba:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac5:	c7 04 24 b4 93 10 c0 	movl   $0xc01093b4,(%esp)
c0100acc:	e8 d0 f7 ff ff       	call   c01002a1 <cprintf>
        uint32_t *args = (uint32_t *)ebp + 2;
c0100ad1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad4:	83 c0 08             	add    $0x8,%eax
c0100ad7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        for (j = 0; j < 4; j ++) {
c0100ada:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0100ae1:	eb 24                	jmp    c0100b07 <print_stackframe+0x75>
            cprintf("0x%08x ", args[j]);
c0100ae3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100ae6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100aed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100af0:	01 d0                	add    %edx,%eax
c0100af2:	8b 00                	mov    (%eax),%eax
c0100af4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100af8:	c7 04 24 d0 93 10 c0 	movl   $0xc01093d0,(%esp)
c0100aff:	e8 9d f7 ff ff       	call   c01002a1 <cprintf>

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
        cprintf("ebp:0x%08x eip:0x%08x args:", ebp, eip);
        uint32_t *args = (uint32_t *)ebp + 2;
        for (j = 0; j < 4; j ++) {
c0100b04:	ff 45 e8             	incl   -0x18(%ebp)
c0100b07:	83 7d e8 03          	cmpl   $0x3,-0x18(%ebp)
c0100b0b:	7e d6                	jle    c0100ae3 <print_stackframe+0x51>
            cprintf("0x%08x ", args[j]);
        }
        cprintf("\n");
c0100b0d:	c7 04 24 d8 93 10 c0 	movl   $0xc01093d8,(%esp)
c0100b14:	e8 88 f7 ff ff       	call   c01002a1 <cprintf>
        print_debuginfo(eip - 1);
c0100b19:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b1c:	48                   	dec    %eax
c0100b1d:	89 04 24             	mov    %eax,(%esp)
c0100b20:	e8 b9 fe ff ff       	call   c01009de <print_debuginfo>
        eip = ((uint32_t *)ebp)[1];
c0100b25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b28:	83 c0 04             	add    $0x4,%eax
c0100b2b:	8b 00                	mov    (%eax),%eax
c0100b2d:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = ((uint32_t *)ebp)[0];
c0100b30:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b33:	8b 00                	mov    (%eax),%eax
c0100b35:	89 45 f4             	mov    %eax,-0xc(%ebp)
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp(), eip = read_eip();

    int i, j;
    for (i = 0; ebp != 0 && i < STACKFRAME_DEPTH; i ++) {
c0100b38:	ff 45 ec             	incl   -0x14(%ebp)
c0100b3b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b3f:	74 0a                	je     c0100b4b <print_stackframe+0xb9>
c0100b41:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b45:	0f 8e 6c ff ff ff    	jle    c0100ab7 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip - 1);
        eip = ((uint32_t *)ebp)[1];
        ebp = ((uint32_t *)ebp)[0];
    }
}
c0100b4b:	90                   	nop
c0100b4c:	c9                   	leave  
c0100b4d:	c3                   	ret    

c0100b4e <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b4e:	55                   	push   %ebp
c0100b4f:	89 e5                	mov    %esp,%ebp
c0100b51:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b5b:	eb 0c                	jmp    c0100b69 <parse+0x1b>
            *buf ++ = '\0';
c0100b5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b60:	8d 50 01             	lea    0x1(%eax),%edx
c0100b63:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b66:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b69:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b6c:	0f b6 00             	movzbl (%eax),%eax
c0100b6f:	84 c0                	test   %al,%al
c0100b71:	74 1d                	je     c0100b90 <parse+0x42>
c0100b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b76:	0f b6 00             	movzbl (%eax),%eax
c0100b79:	0f be c0             	movsbl %al,%eax
c0100b7c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b80:	c7 04 24 5c 94 10 c0 	movl   $0xc010945c,(%esp)
c0100b87:	e8 b8 7b 00 00       	call   c0108744 <strchr>
c0100b8c:	85 c0                	test   %eax,%eax
c0100b8e:	75 cd                	jne    c0100b5d <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100b90:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b93:	0f b6 00             	movzbl (%eax),%eax
c0100b96:	84 c0                	test   %al,%al
c0100b98:	74 69                	je     c0100c03 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100b9a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100b9e:	75 14                	jne    c0100bb4 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ba0:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ba7:	00 
c0100ba8:	c7 04 24 61 94 10 c0 	movl   $0xc0109461,(%esp)
c0100baf:	e8 ed f6 ff ff       	call   c01002a1 <cprintf>
        }
        argv[argc ++] = buf;
c0100bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bb7:	8d 50 01             	lea    0x1(%eax),%edx
c0100bba:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bbd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bc7:	01 c2                	add    %eax,%edx
c0100bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bcc:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bce:	eb 03                	jmp    c0100bd3 <parse+0x85>
            buf ++;
c0100bd0:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100bd3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bd6:	0f b6 00             	movzbl (%eax),%eax
c0100bd9:	84 c0                	test   %al,%al
c0100bdb:	0f 84 7a ff ff ff    	je     c0100b5b <parse+0xd>
c0100be1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be4:	0f b6 00             	movzbl (%eax),%eax
c0100be7:	0f be c0             	movsbl %al,%eax
c0100bea:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bee:	c7 04 24 5c 94 10 c0 	movl   $0xc010945c,(%esp)
c0100bf5:	e8 4a 7b 00 00       	call   c0108744 <strchr>
c0100bfa:	85 c0                	test   %eax,%eax
c0100bfc:	74 d2                	je     c0100bd0 <parse+0x82>
            buf ++;
        }
    }
c0100bfe:	e9 58 ff ff ff       	jmp    c0100b5b <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100c03:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c04:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c07:	c9                   	leave  
c0100c08:	c3                   	ret    

c0100c09 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c09:	55                   	push   %ebp
c0100c0a:	89 e5                	mov    %esp,%ebp
c0100c0c:	53                   	push   %ebx
c0100c0d:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c10:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c13:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c17:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c1a:	89 04 24             	mov    %eax,(%esp)
c0100c1d:	e8 2c ff ff ff       	call   c0100b4e <parse>
c0100c22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c29:	75 0a                	jne    c0100c35 <runcmd+0x2c>
        return 0;
c0100c2b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c30:	e9 83 00 00 00       	jmp    c0100cb8 <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c35:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c3c:	eb 5a                	jmp    c0100c98 <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c3e:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c41:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c44:	89 d0                	mov    %edx,%eax
c0100c46:	01 c0                	add    %eax,%eax
c0100c48:	01 d0                	add    %edx,%eax
c0100c4a:	c1 e0 02             	shl    $0x2,%eax
c0100c4d:	05 00 10 12 c0       	add    $0xc0121000,%eax
c0100c52:	8b 00                	mov    (%eax),%eax
c0100c54:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c58:	89 04 24             	mov    %eax,(%esp)
c0100c5b:	e8 47 7a 00 00       	call   c01086a7 <strcmp>
c0100c60:	85 c0                	test   %eax,%eax
c0100c62:	75 31                	jne    c0100c95 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c64:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c67:	89 d0                	mov    %edx,%eax
c0100c69:	01 c0                	add    %eax,%eax
c0100c6b:	01 d0                	add    %edx,%eax
c0100c6d:	c1 e0 02             	shl    $0x2,%eax
c0100c70:	05 08 10 12 c0       	add    $0xc0121008,%eax
c0100c75:	8b 10                	mov    (%eax),%edx
c0100c77:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c7a:	83 c0 04             	add    $0x4,%eax
c0100c7d:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c80:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c86:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c8e:	89 1c 24             	mov    %ebx,(%esp)
c0100c91:	ff d2                	call   *%edx
c0100c93:	eb 23                	jmp    c0100cb8 <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c95:	ff 45 f4             	incl   -0xc(%ebp)
c0100c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c9b:	83 f8 02             	cmp    $0x2,%eax
c0100c9e:	76 9e                	jbe    c0100c3e <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100ca0:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100ca3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca7:	c7 04 24 7f 94 10 c0 	movl   $0xc010947f,(%esp)
c0100cae:	e8 ee f5 ff ff       	call   c01002a1 <cprintf>
    return 0;
c0100cb3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cb8:	83 c4 64             	add    $0x64,%esp
c0100cbb:	5b                   	pop    %ebx
c0100cbc:	5d                   	pop    %ebp
c0100cbd:	c3                   	ret    

c0100cbe <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cbe:	55                   	push   %ebp
c0100cbf:	89 e5                	mov    %esp,%ebp
c0100cc1:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cc4:	c7 04 24 98 94 10 c0 	movl   $0xc0109498,(%esp)
c0100ccb:	e8 d1 f5 ff ff       	call   c01002a1 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100cd0:	c7 04 24 c0 94 10 c0 	movl   $0xc01094c0,(%esp)
c0100cd7:	e8 c5 f5 ff ff       	call   c01002a1 <cprintf>

    if (tf != NULL) {
c0100cdc:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100ce0:	74 0b                	je     c0100ced <kmonitor+0x2f>
        print_trapframe(tf);
c0100ce2:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ce5:	89 04 24             	mov    %eax,(%esp)
c0100ce8:	e8 61 15 00 00       	call   c010224e <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100ced:	c7 04 24 e5 94 10 c0 	movl   $0xc01094e5,(%esp)
c0100cf4:	e8 4a f6 ff ff       	call   c0100343 <readline>
c0100cf9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100cfc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d00:	74 eb                	je     c0100ced <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d02:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d05:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d09:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d0c:	89 04 24             	mov    %eax,(%esp)
c0100d0f:	e8 f5 fe ff ff       	call   c0100c09 <runcmd>
c0100d14:	85 c0                	test   %eax,%eax
c0100d16:	78 02                	js     c0100d1a <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d18:	eb d3                	jmp    c0100ced <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d1a:	90                   	nop
            }
        }
    }
}
c0100d1b:	90                   	nop
c0100d1c:	c9                   	leave  
c0100d1d:	c3                   	ret    

c0100d1e <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d1e:	55                   	push   %ebp
c0100d1f:	89 e5                	mov    %esp,%ebp
c0100d21:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d2b:	eb 3d                	jmp    c0100d6a <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d30:	89 d0                	mov    %edx,%eax
c0100d32:	01 c0                	add    %eax,%eax
c0100d34:	01 d0                	add    %edx,%eax
c0100d36:	c1 e0 02             	shl    $0x2,%eax
c0100d39:	05 04 10 12 c0       	add    $0xc0121004,%eax
c0100d3e:	8b 08                	mov    (%eax),%ecx
c0100d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d43:	89 d0                	mov    %edx,%eax
c0100d45:	01 c0                	add    %eax,%eax
c0100d47:	01 d0                	add    %edx,%eax
c0100d49:	c1 e0 02             	shl    $0x2,%eax
c0100d4c:	05 00 10 12 c0       	add    $0xc0121000,%eax
c0100d51:	8b 00                	mov    (%eax),%eax
c0100d53:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d57:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d5b:	c7 04 24 e9 94 10 c0 	movl   $0xc01094e9,(%esp)
c0100d62:	e8 3a f5 ff ff       	call   c01002a1 <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d67:	ff 45 f4             	incl   -0xc(%ebp)
c0100d6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d6d:	83 f8 02             	cmp    $0x2,%eax
c0100d70:	76 bb                	jbe    c0100d2d <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d72:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d77:	c9                   	leave  
c0100d78:	c3                   	ret    

c0100d79 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d79:	55                   	push   %ebp
c0100d7a:	89 e5                	mov    %esp,%ebp
c0100d7c:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d7f:	e8 c3 fb ff ff       	call   c0100947 <print_kerninfo>
    return 0;
c0100d84:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d89:	c9                   	leave  
c0100d8a:	c3                   	ret    

c0100d8b <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d8b:	55                   	push   %ebp
c0100d8c:	89 e5                	mov    %esp,%ebp
c0100d8e:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100d91:	e8 fc fc ff ff       	call   c0100a92 <print_stackframe>
    return 0;
c0100d96:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d9b:	c9                   	leave  
c0100d9c:	c3                   	ret    

c0100d9d <ide_wait_ready>:
    unsigned int size;          // Size in Sectors
    unsigned char model[41];    // Model in String
} ide_devices[MAX_IDE];

static int
ide_wait_ready(unsigned short iobase, bool check_error) {
c0100d9d:	55                   	push   %ebp
c0100d9e:	89 e5                	mov    %esp,%ebp
c0100da0:	83 ec 14             	sub    $0x14,%esp
c0100da3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100da6:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    int r;
    while ((r = inb(iobase + ISA_STATUS)) & IDE_BSY)
c0100daa:	90                   	nop
c0100dab:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100dae:	83 c0 07             	add    $0x7,%eax
c0100db1:	0f b7 c0             	movzwl %ax,%eax
c0100db4:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100db8:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100dbc:	89 c2                	mov    %eax,%edx
c0100dbe:	ec                   	in     (%dx),%al
c0100dbf:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0100dc2:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0100dc6:	0f b6 c0             	movzbl %al,%eax
c0100dc9:	89 45 fc             	mov    %eax,-0x4(%ebp)
c0100dcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100dcf:	25 80 00 00 00       	and    $0x80,%eax
c0100dd4:	85 c0                	test   %eax,%eax
c0100dd6:	75 d3                	jne    c0100dab <ide_wait_ready+0xe>
        /* nothing */;
    if (check_error && (r & (IDE_DF | IDE_ERR)) != 0) {
c0100dd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0100ddc:	74 11                	je     c0100def <ide_wait_ready+0x52>
c0100dde:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100de1:	83 e0 21             	and    $0x21,%eax
c0100de4:	85 c0                	test   %eax,%eax
c0100de6:	74 07                	je     c0100def <ide_wait_ready+0x52>
        return -1;
c0100de8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100ded:	eb 05                	jmp    c0100df4 <ide_wait_ready+0x57>
    }
    return 0;
c0100def:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100df4:	c9                   	leave  
c0100df5:	c3                   	ret    

c0100df6 <ide_init>:

void
ide_init(void) {
c0100df6:	55                   	push   %ebp
c0100df7:	89 e5                	mov    %esp,%ebp
c0100df9:	57                   	push   %edi
c0100dfa:	53                   	push   %ebx
c0100dfb:	81 ec 50 02 00 00    	sub    $0x250,%esp
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c0100e01:	66 c7 45 f6 00 00    	movw   $0x0,-0xa(%ebp)
c0100e07:	e9 d4 02 00 00       	jmp    c01010e0 <ide_init+0x2ea>
        /* assume that no device here */
        ide_devices[ideno].valid = 0;
c0100e0c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e10:	c1 e0 03             	shl    $0x3,%eax
c0100e13:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100e1a:	29 c2                	sub    %eax,%edx
c0100e1c:	89 d0                	mov    %edx,%eax
c0100e1e:	05 40 44 12 c0       	add    $0xc0124440,%eax
c0100e23:	c6 00 00             	movb   $0x0,(%eax)

        iobase = IO_BASE(ideno);
c0100e26:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e2a:	d1 e8                	shr    %eax
c0100e2c:	0f b7 c0             	movzwl %ax,%eax
c0100e2f:	8b 04 85 f4 94 10 c0 	mov    -0x3fef6b0c(,%eax,4),%eax
c0100e36:	66 89 45 ea          	mov    %ax,-0x16(%ebp)

        /* wait device ready */
        ide_wait_ready(iobase, 0);
c0100e3a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e3e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e45:	00 
c0100e46:	89 04 24             	mov    %eax,(%esp)
c0100e49:	e8 4f ff ff ff       	call   c0100d9d <ide_wait_ready>

        /* step1: select drive */
        outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4));
c0100e4e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e52:	83 e0 01             	and    $0x1,%eax
c0100e55:	c1 e0 04             	shl    $0x4,%eax
c0100e58:	0c e0                	or     $0xe0,%al
c0100e5a:	0f b6 c0             	movzbl %al,%eax
c0100e5d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0100e61:	83 c2 06             	add    $0x6,%edx
c0100e64:	0f b7 d2             	movzwl %dx,%edx
c0100e67:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0100e6b:	88 45 c7             	mov    %al,-0x39(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100e6e:	0f b6 45 c7          	movzbl -0x39(%ebp),%eax
c0100e72:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100e76:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100e77:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e7b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100e82:	00 
c0100e83:	89 04 24             	mov    %eax,(%esp)
c0100e86:	e8 12 ff ff ff       	call   c0100d9d <ide_wait_ready>

        /* step2: send ATA identify command */
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
c0100e8b:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100e8f:	83 c0 07             	add    $0x7,%eax
c0100e92:	0f b7 c0             	movzwl %ax,%eax
c0100e95:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
c0100e99:	c6 45 c8 ec          	movb   $0xec,-0x38(%ebp)
c0100e9d:	0f b6 45 c8          	movzbl -0x38(%ebp),%eax
c0100ea1:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100ea4:	ee                   	out    %al,(%dx)
        ide_wait_ready(iobase, 0);
c0100ea5:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ea9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100eb0:	00 
c0100eb1:	89 04 24             	mov    %eax,(%esp)
c0100eb4:	e8 e4 fe ff ff       	call   c0100d9d <ide_wait_ready>

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
c0100eb9:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ebd:	83 c0 07             	add    $0x7,%eax
c0100ec0:	0f b7 c0             	movzwl %ax,%eax
c0100ec3:	66 89 45 ca          	mov    %ax,-0x36(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100ec7:	0f b7 45 ca          	movzwl -0x36(%ebp),%eax
c0100ecb:	89 c2                	mov    %eax,%edx
c0100ecd:	ec                   	in     (%dx),%al
c0100ece:	88 45 c9             	mov    %al,-0x37(%ebp)
    return data;
c0100ed1:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c0100ed5:	84 c0                	test   %al,%al
c0100ed7:	0f 84 f9 01 00 00    	je     c01010d6 <ide_init+0x2e0>
c0100edd:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100ee1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0100ee8:	00 
c0100ee9:	89 04 24             	mov    %eax,(%esp)
c0100eec:	e8 ac fe ff ff       	call   c0100d9d <ide_wait_ready>
c0100ef1:	85 c0                	test   %eax,%eax
c0100ef3:	0f 85 dd 01 00 00    	jne    c01010d6 <ide_init+0x2e0>
            continue ;
        }

        /* device is ok */
        ide_devices[ideno].valid = 1;
c0100ef9:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100efd:	c1 e0 03             	shl    $0x3,%eax
c0100f00:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f07:	29 c2                	sub    %eax,%edx
c0100f09:	89 d0                	mov    %edx,%eax
c0100f0b:	05 40 44 12 c0       	add    $0xc0124440,%eax
c0100f10:	c6 00 01             	movb   $0x1,(%eax)

        /* read identification space of the device */
        unsigned int buffer[128];
        insl(iobase + ISA_DATA, buffer, sizeof(buffer) / sizeof(unsigned int));
c0100f13:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0100f1a:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f20:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0100f23:	c7 45 bc 80 00 00 00 	movl   $0x80,-0x44(%ebp)
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0100f2a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100f2d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
c0100f30:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0100f33:	89 cb                	mov    %ecx,%ebx
c0100f35:	89 df                	mov    %ebx,%edi
c0100f37:	89 c1                	mov    %eax,%ecx
c0100f39:	fc                   	cld    
c0100f3a:	f2 6d                	repnz insl (%dx),%es:(%edi)
c0100f3c:	89 c8                	mov    %ecx,%eax
c0100f3e:	89 fb                	mov    %edi,%ebx
c0100f40:	89 5d c0             	mov    %ebx,-0x40(%ebp)
c0100f43:	89 45 bc             	mov    %eax,-0x44(%ebp)

        unsigned char *ident = (unsigned char *)buffer;
c0100f46:	8d 85 bc fd ff ff    	lea    -0x244(%ebp),%eax
c0100f4c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        unsigned int sectors;
        unsigned int cmdsets = *(unsigned int *)(ident + IDE_IDENT_CMDSETS);
c0100f4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f52:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
c0100f58:	89 45 d8             	mov    %eax,-0x28(%ebp)
        /* device use 48-bits or 28-bits addressing */
        if (cmdsets & (1 << 26)) {
c0100f5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f5e:	25 00 00 00 04       	and    $0x4000000,%eax
c0100f63:	85 c0                	test   %eax,%eax
c0100f65:	74 0e                	je     c0100f75 <ide_init+0x17f>
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA_EXT);
c0100f67:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f6a:	8b 80 c8 00 00 00    	mov    0xc8(%eax),%eax
c0100f70:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0100f73:	eb 09                	jmp    c0100f7e <ide_init+0x188>
        }
        else {
            sectors = *(unsigned int *)(ident + IDE_IDENT_MAX_LBA);
c0100f75:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100f78:	8b 40 78             	mov    0x78(%eax),%eax
c0100f7b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        }
        ide_devices[ideno].sets = cmdsets;
c0100f7e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f82:	c1 e0 03             	shl    $0x3,%eax
c0100f85:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100f8c:	29 c2                	sub    %eax,%edx
c0100f8e:	89 d0                	mov    %edx,%eax
c0100f90:	8d 90 44 44 12 c0    	lea    -0x3fedbbbc(%eax),%edx
c0100f96:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100f99:	89 02                	mov    %eax,(%edx)
        ide_devices[ideno].size = sectors;
c0100f9b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100f9f:	c1 e0 03             	shl    $0x3,%eax
c0100fa2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100fa9:	29 c2                	sub    %eax,%edx
c0100fab:	89 d0                	mov    %edx,%eax
c0100fad:	8d 90 48 44 12 c0    	lea    -0x3fedbbb8(%eax),%edx
c0100fb3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100fb6:	89 02                	mov    %eax,(%edx)

        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);
c0100fb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100fbb:	83 c0 62             	add    $0x62,%eax
c0100fbe:	0f b7 00             	movzwl (%eax),%eax
c0100fc1:	25 00 02 00 00       	and    $0x200,%eax
c0100fc6:	85 c0                	test   %eax,%eax
c0100fc8:	75 24                	jne    c0100fee <ide_init+0x1f8>
c0100fca:	c7 44 24 0c fc 94 10 	movl   $0xc01094fc,0xc(%esp)
c0100fd1:	c0 
c0100fd2:	c7 44 24 08 3f 95 10 	movl   $0xc010953f,0x8(%esp)
c0100fd9:	c0 
c0100fda:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0100fe1:	00 
c0100fe2:	c7 04 24 54 95 10 c0 	movl   $0xc0109554,(%esp)
c0100fe9:	e8 0a f4 ff ff       	call   c01003f8 <__panic>

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
c0100fee:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100ff2:	c1 e0 03             	shl    $0x3,%eax
c0100ff5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0100ffc:	29 c2                	sub    %eax,%edx
c0100ffe:	8d 82 40 44 12 c0    	lea    -0x3fedbbc0(%edx),%eax
c0101004:	83 c0 0c             	add    $0xc,%eax
c0101007:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010100a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010100d:	83 c0 36             	add    $0x36,%eax
c0101010:	89 45 d0             	mov    %eax,-0x30(%ebp)
        unsigned int i, length = 40;
c0101013:	c7 45 cc 28 00 00 00 	movl   $0x28,-0x34(%ebp)
        for (i = 0; i < length; i += 2) {
c010101a:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0101021:	eb 34                	jmp    c0101057 <ide_init+0x261>
            model[i] = data[i + 1], model[i + 1] = data[i];
c0101023:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101026:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101029:	01 c2                	add    %eax,%edx
c010102b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010102e:	8d 48 01             	lea    0x1(%eax),%ecx
c0101031:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0101034:	01 c8                	add    %ecx,%eax
c0101036:	0f b6 00             	movzbl (%eax),%eax
c0101039:	88 02                	mov    %al,(%edx)
c010103b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010103e:	8d 50 01             	lea    0x1(%eax),%edx
c0101041:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0101044:	01 c2                	add    %eax,%edx
c0101046:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101049:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010104c:	01 c8                	add    %ecx,%eax
c010104e:	0f b6 00             	movzbl (%eax),%eax
c0101051:	88 02                	mov    %al,(%edx)
        /* check if supports LBA */
        assert((*(unsigned short *)(ident + IDE_IDENT_CAPABILITIES) & 0x200) != 0);

        unsigned char *model = ide_devices[ideno].model, *data = ident + IDE_IDENT_MODEL;
        unsigned int i, length = 40;
        for (i = 0; i < length; i += 2) {
c0101053:	83 45 ec 02          	addl   $0x2,-0x14(%ebp)
c0101057:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010105a:	3b 45 cc             	cmp    -0x34(%ebp),%eax
c010105d:	72 c4                	jb     c0101023 <ide_init+0x22d>
            model[i] = data[i + 1], model[i + 1] = data[i];
        }
        do {
            model[i] = '\0';
c010105f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0101062:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101065:	01 d0                	add    %edx,%eax
c0101067:	c6 00 00             	movb   $0x0,(%eax)
        } while (i -- > 0 && model[i] == ' ');
c010106a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010106d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0101070:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0101073:	85 c0                	test   %eax,%eax
c0101075:	74 0f                	je     c0101086 <ide_init+0x290>
c0101077:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010107a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010107d:	01 d0                	add    %edx,%eax
c010107f:	0f b6 00             	movzbl (%eax),%eax
c0101082:	3c 20                	cmp    $0x20,%al
c0101084:	74 d9                	je     c010105f <ide_init+0x269>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
c0101086:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010108a:	c1 e0 03             	shl    $0x3,%eax
c010108d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101094:	29 c2                	sub    %eax,%edx
c0101096:	8d 82 40 44 12 c0    	lea    -0x3fedbbc0(%edx),%eax
c010109c:	8d 48 0c             	lea    0xc(%eax),%ecx
c010109f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010a3:	c1 e0 03             	shl    $0x3,%eax
c01010a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01010ad:	29 c2                	sub    %eax,%edx
c01010af:	89 d0                	mov    %edx,%eax
c01010b1:	05 48 44 12 c0       	add    $0xc0124448,%eax
c01010b6:	8b 10                	mov    (%eax),%edx
c01010b8:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010bc:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01010c0:	89 54 24 08          	mov    %edx,0x8(%esp)
c01010c4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01010c8:	c7 04 24 66 95 10 c0 	movl   $0xc0109566,(%esp)
c01010cf:	e8 cd f1 ff ff       	call   c01002a1 <cprintf>
c01010d4:	eb 01                	jmp    c01010d7 <ide_init+0x2e1>
        outb(iobase + ISA_COMMAND, IDE_CMD_IDENTIFY);
        ide_wait_ready(iobase, 0);

        /* step3: polling */
        if (inb(iobase + ISA_STATUS) == 0 || ide_wait_ready(iobase, 1) != 0) {
            continue ;
c01010d6:	90                   	nop

void
ide_init(void) {
    static_assert((SECTSIZE % 4) == 0);
    unsigned short ideno, iobase;
    for (ideno = 0; ideno < MAX_IDE; ideno ++) {
c01010d7:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010db:	40                   	inc    %eax
c01010dc:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
c01010e0:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c01010e4:	83 f8 03             	cmp    $0x3,%eax
c01010e7:	0f 86 1f fd ff ff    	jbe    c0100e0c <ide_init+0x16>

        cprintf("ide %d: %10u(sectors), '%s'.\n", ideno, ide_devices[ideno].size, ide_devices[ideno].model);
    }

    // enable ide interrupt
    pic_enable(IRQ_IDE1);
c01010ed:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
c01010f4:	e8 8a 0e 00 00       	call   c0101f83 <pic_enable>
    pic_enable(IRQ_IDE2);
c01010f9:	c7 04 24 0f 00 00 00 	movl   $0xf,(%esp)
c0101100:	e8 7e 0e 00 00       	call   c0101f83 <pic_enable>
}
c0101105:	90                   	nop
c0101106:	81 c4 50 02 00 00    	add    $0x250,%esp
c010110c:	5b                   	pop    %ebx
c010110d:	5f                   	pop    %edi
c010110e:	5d                   	pop    %ebp
c010110f:	c3                   	ret    

c0101110 <ide_device_valid>:

bool
ide_device_valid(unsigned short ideno) {
c0101110:	55                   	push   %ebp
c0101111:	89 e5                	mov    %esp,%ebp
c0101113:	83 ec 04             	sub    $0x4,%esp
c0101116:	8b 45 08             	mov    0x8(%ebp),%eax
c0101119:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    return VALID_IDE(ideno);
c010111d:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101121:	83 f8 03             	cmp    $0x3,%eax
c0101124:	77 25                	ja     c010114b <ide_device_valid+0x3b>
c0101126:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c010112a:	c1 e0 03             	shl    $0x3,%eax
c010112d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c0101134:	29 c2                	sub    %eax,%edx
c0101136:	89 d0                	mov    %edx,%eax
c0101138:	05 40 44 12 c0       	add    $0xc0124440,%eax
c010113d:	0f b6 00             	movzbl (%eax),%eax
c0101140:	84 c0                	test   %al,%al
c0101142:	74 07                	je     c010114b <ide_device_valid+0x3b>
c0101144:	b8 01 00 00 00       	mov    $0x1,%eax
c0101149:	eb 05                	jmp    c0101150 <ide_device_valid+0x40>
c010114b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101150:	c9                   	leave  
c0101151:	c3                   	ret    

c0101152 <ide_device_size>:

size_t
ide_device_size(unsigned short ideno) {
c0101152:	55                   	push   %ebp
c0101153:	89 e5                	mov    %esp,%ebp
c0101155:	83 ec 08             	sub    $0x8,%esp
c0101158:	8b 45 08             	mov    0x8(%ebp),%eax
c010115b:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
    if (ide_device_valid(ideno)) {
c010115f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101163:	89 04 24             	mov    %eax,(%esp)
c0101166:	e8 a5 ff ff ff       	call   c0101110 <ide_device_valid>
c010116b:	85 c0                	test   %eax,%eax
c010116d:	74 1b                	je     c010118a <ide_device_size+0x38>
        return ide_devices[ideno].size;
c010116f:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
c0101173:	c1 e0 03             	shl    $0x3,%eax
c0101176:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c010117d:	29 c2                	sub    %eax,%edx
c010117f:	89 d0                	mov    %edx,%eax
c0101181:	05 48 44 12 c0       	add    $0xc0124448,%eax
c0101186:	8b 00                	mov    (%eax),%eax
c0101188:	eb 05                	jmp    c010118f <ide_device_size+0x3d>
    }
    return 0;
c010118a:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010118f:	c9                   	leave  
c0101190:	c3                   	ret    

c0101191 <ide_read_secs>:

int
ide_read_secs(unsigned short ideno, uint32_t secno, void *dst, size_t nsecs) {
c0101191:	55                   	push   %ebp
c0101192:	89 e5                	mov    %esp,%ebp
c0101194:	57                   	push   %edi
c0101195:	53                   	push   %ebx
c0101196:	83 ec 50             	sub    $0x50,%esp
c0101199:	8b 45 08             	mov    0x8(%ebp),%eax
c010119c:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01011a0:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01011a7:	77 27                	ja     c01011d0 <ide_read_secs+0x3f>
c01011a9:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011ad:	83 f8 03             	cmp    $0x3,%eax
c01011b0:	77 1e                	ja     c01011d0 <ide_read_secs+0x3f>
c01011b2:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01011b6:	c1 e0 03             	shl    $0x3,%eax
c01011b9:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01011c0:	29 c2                	sub    %eax,%edx
c01011c2:	89 d0                	mov    %edx,%eax
c01011c4:	05 40 44 12 c0       	add    $0xc0124440,%eax
c01011c9:	0f b6 00             	movzbl (%eax),%eax
c01011cc:	84 c0                	test   %al,%al
c01011ce:	75 24                	jne    c01011f4 <ide_read_secs+0x63>
c01011d0:	c7 44 24 0c 84 95 10 	movl   $0xc0109584,0xc(%esp)
c01011d7:	c0 
c01011d8:	c7 44 24 08 3f 95 10 	movl   $0xc010953f,0x8(%esp)
c01011df:	c0 
c01011e0:	c7 44 24 04 9f 00 00 	movl   $0x9f,0x4(%esp)
c01011e7:	00 
c01011e8:	c7 04 24 54 95 10 c0 	movl   $0xc0109554,(%esp)
c01011ef:	e8 04 f2 ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c01011f4:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c01011fb:	77 0f                	ja     c010120c <ide_read_secs+0x7b>
c01011fd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0101200:	8b 45 14             	mov    0x14(%ebp),%eax
c0101203:	01 d0                	add    %edx,%eax
c0101205:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c010120a:	76 24                	jbe    c0101230 <ide_read_secs+0x9f>
c010120c:	c7 44 24 0c ac 95 10 	movl   $0xc01095ac,0xc(%esp)
c0101213:	c0 
c0101214:	c7 44 24 08 3f 95 10 	movl   $0xc010953f,0x8(%esp)
c010121b:	c0 
c010121c:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c0101223:	00 
c0101224:	c7 04 24 54 95 10 c0 	movl   $0xc0109554,(%esp)
c010122b:	e8 c8 f1 ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c0101230:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101234:	d1 e8                	shr    %eax
c0101236:	0f b7 c0             	movzwl %ax,%eax
c0101239:	8b 04 85 f4 94 10 c0 	mov    -0x3fef6b0c(,%eax,4),%eax
c0101240:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101244:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101248:	d1 e8                	shr    %eax
c010124a:	0f b7 c0             	movzwl %ax,%eax
c010124d:	0f b7 04 85 f6 94 10 	movzwl -0x3fef6b0a(,%eax,4),%eax
c0101254:	c0 
c0101255:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101259:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010125d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0101264:	00 
c0101265:	89 04 24             	mov    %eax,(%esp)
c0101268:	e8 30 fb ff ff       	call   c0100d9d <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c010126d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101270:	83 c0 02             	add    $0x2,%eax
c0101273:	0f b7 c0             	movzwl %ax,%eax
c0101276:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c010127a:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010127e:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101282:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101286:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c0101287:	8b 45 14             	mov    0x14(%ebp),%eax
c010128a:	0f b6 c0             	movzbl %al,%eax
c010128d:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101291:	83 c2 02             	add    $0x2,%edx
c0101294:	0f b7 d2             	movzwl %dx,%edx
c0101297:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c010129b:	88 45 d8             	mov    %al,-0x28(%ebp)
c010129e:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01012a2:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01012a5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01012a6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012a9:	0f b6 c0             	movzbl %al,%eax
c01012ac:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012b0:	83 c2 03             	add    $0x3,%edx
c01012b3:	0f b7 d2             	movzwl %dx,%edx
c01012b6:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01012ba:	88 45 d9             	mov    %al,-0x27(%ebp)
c01012bd:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01012c1:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012c5:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c01012c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012c9:	c1 e8 08             	shr    $0x8,%eax
c01012cc:	0f b6 c0             	movzbl %al,%eax
c01012cf:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012d3:	83 c2 04             	add    $0x4,%edx
c01012d6:	0f b7 d2             	movzwl %dx,%edx
c01012d9:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c01012dd:	88 45 da             	mov    %al,-0x26(%ebp)
c01012e0:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01012e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01012e7:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c01012e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01012eb:	c1 e8 10             	shr    $0x10,%eax
c01012ee:	0f b6 c0             	movzbl %al,%eax
c01012f1:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01012f5:	83 c2 05             	add    $0x5,%edx
c01012f8:	0f b7 d2             	movzwl %dx,%edx
c01012fb:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c01012ff:	88 45 db             	mov    %al,-0x25(%ebp)
c0101302:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101306:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c010130a:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c010130b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010130e:	24 01                	and    $0x1,%al
c0101310:	c0 e0 04             	shl    $0x4,%al
c0101313:	88 c2                	mov    %al,%dl
c0101315:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101318:	c1 e8 18             	shr    $0x18,%eax
c010131b:	24 0f                	and    $0xf,%al
c010131d:	08 d0                	or     %dl,%al
c010131f:	0c e0                	or     $0xe0,%al
c0101321:	0f b6 c0             	movzbl %al,%eax
c0101324:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101328:	83 c2 06             	add    $0x6,%edx
c010132b:	0f b7 d2             	movzwl %dx,%edx
c010132e:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c0101332:	88 45 dc             	mov    %al,-0x24(%ebp)
c0101335:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101339:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010133c:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);
c010133d:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101341:	83 c0 07             	add    $0x7,%eax
c0101344:	0f b7 c0             	movzwl %ax,%eax
c0101347:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c010134b:	c6 45 dd 20          	movb   $0x20,-0x23(%ebp)
c010134f:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101353:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101357:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101358:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c010135f:	eb 57                	jmp    c01013b8 <ide_read_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c0101361:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101365:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010136c:	00 
c010136d:	89 04 24             	mov    %eax,(%esp)
c0101370:	e8 28 fa ff ff       	call   c0100d9d <ide_wait_ready>
c0101375:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101378:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010137c:	75 42                	jne    c01013c0 <ide_read_secs+0x22f>
            goto out;
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
c010137e:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101382:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0101385:	8b 45 10             	mov    0x10(%ebp),%eax
c0101388:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010138b:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    return data;
}

static inline void
insl(uint32_t port, void *addr, int cnt) {
    asm volatile (
c0101392:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101395:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c0101398:	8b 45 cc             	mov    -0x34(%ebp),%eax
c010139b:	89 cb                	mov    %ecx,%ebx
c010139d:	89 df                	mov    %ebx,%edi
c010139f:	89 c1                	mov    %eax,%ecx
c01013a1:	fc                   	cld    
c01013a2:	f2 6d                	repnz insl (%dx),%es:(%edi)
c01013a4:	89 c8                	mov    %ecx,%eax
c01013a6:	89 fb                	mov    %edi,%ebx
c01013a8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01013ab:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_READ);

    int ret = 0;
    for (; nsecs > 0; nsecs --, dst += SECTSIZE) {
c01013ae:	ff 4d 14             	decl   0x14(%ebp)
c01013b1:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01013b8:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01013bc:	75 a3                	jne    c0101361 <ide_read_secs+0x1d0>
c01013be:	eb 01                	jmp    c01013c1 <ide_read_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01013c0:	90                   	nop
        }
        insl(iobase, dst, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01013c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01013c4:	83 c4 50             	add    $0x50,%esp
c01013c7:	5b                   	pop    %ebx
c01013c8:	5f                   	pop    %edi
c01013c9:	5d                   	pop    %ebp
c01013ca:	c3                   	ret    

c01013cb <ide_write_secs>:

int
ide_write_secs(unsigned short ideno, uint32_t secno, const void *src, size_t nsecs) {
c01013cb:	55                   	push   %ebp
c01013cc:	89 e5                	mov    %esp,%ebp
c01013ce:	56                   	push   %esi
c01013cf:	53                   	push   %ebx
c01013d0:	83 ec 50             	sub    $0x50,%esp
c01013d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01013d6:	66 89 45 c4          	mov    %ax,-0x3c(%ebp)
    assert(nsecs <= MAX_NSECS && VALID_IDE(ideno));
c01013da:	81 7d 14 80 00 00 00 	cmpl   $0x80,0x14(%ebp)
c01013e1:	77 27                	ja     c010140a <ide_write_secs+0x3f>
c01013e3:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013e7:	83 f8 03             	cmp    $0x3,%eax
c01013ea:	77 1e                	ja     c010140a <ide_write_secs+0x3f>
c01013ec:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c01013f0:	c1 e0 03             	shl    $0x3,%eax
c01013f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
c01013fa:	29 c2                	sub    %eax,%edx
c01013fc:	89 d0                	mov    %edx,%eax
c01013fe:	05 40 44 12 c0       	add    $0xc0124440,%eax
c0101403:	0f b6 00             	movzbl (%eax),%eax
c0101406:	84 c0                	test   %al,%al
c0101408:	75 24                	jne    c010142e <ide_write_secs+0x63>
c010140a:	c7 44 24 0c 84 95 10 	movl   $0xc0109584,0xc(%esp)
c0101411:	c0 
c0101412:	c7 44 24 08 3f 95 10 	movl   $0xc010953f,0x8(%esp)
c0101419:	c0 
c010141a:	c7 44 24 04 bc 00 00 	movl   $0xbc,0x4(%esp)
c0101421:	00 
c0101422:	c7 04 24 54 95 10 c0 	movl   $0xc0109554,(%esp)
c0101429:	e8 ca ef ff ff       	call   c01003f8 <__panic>
    assert(secno < MAX_DISK_NSECS && secno + nsecs <= MAX_DISK_NSECS);
c010142e:	81 7d 0c ff ff ff 0f 	cmpl   $0xfffffff,0xc(%ebp)
c0101435:	77 0f                	ja     c0101446 <ide_write_secs+0x7b>
c0101437:	8b 55 0c             	mov    0xc(%ebp),%edx
c010143a:	8b 45 14             	mov    0x14(%ebp),%eax
c010143d:	01 d0                	add    %edx,%eax
c010143f:	3d 00 00 00 10       	cmp    $0x10000000,%eax
c0101444:	76 24                	jbe    c010146a <ide_write_secs+0x9f>
c0101446:	c7 44 24 0c ac 95 10 	movl   $0xc01095ac,0xc(%esp)
c010144d:	c0 
c010144e:	c7 44 24 08 3f 95 10 	movl   $0xc010953f,0x8(%esp)
c0101455:	c0 
c0101456:	c7 44 24 04 bd 00 00 	movl   $0xbd,0x4(%esp)
c010145d:	00 
c010145e:	c7 04 24 54 95 10 c0 	movl   $0xc0109554,(%esp)
c0101465:	e8 8e ef ff ff       	call   c01003f8 <__panic>
    unsigned short iobase = IO_BASE(ideno), ioctrl = IO_CTRL(ideno);
c010146a:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c010146e:	d1 e8                	shr    %eax
c0101470:	0f b7 c0             	movzwl %ax,%eax
c0101473:	8b 04 85 f4 94 10 c0 	mov    -0x3fef6b0c(,%eax,4),%eax
c010147a:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c010147e:	0f b7 45 c4          	movzwl -0x3c(%ebp),%eax
c0101482:	d1 e8                	shr    %eax
c0101484:	0f b7 c0             	movzwl %ax,%eax
c0101487:	0f b7 04 85 f6 94 10 	movzwl -0x3fef6b0a(,%eax,4),%eax
c010148e:	c0 
c010148f:	66 89 45 f0          	mov    %ax,-0x10(%ebp)

    ide_wait_ready(iobase, 0);
c0101493:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101497:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010149e:	00 
c010149f:	89 04 24             	mov    %eax,(%esp)
c01014a2:	e8 f6 f8 ff ff       	call   c0100d9d <ide_wait_ready>

    // generate interrupt
    outb(ioctrl + ISA_CTRL, 0);
c01014a7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014aa:	83 c0 02             	add    $0x2,%eax
c01014ad:	0f b7 c0             	movzwl %ax,%eax
c01014b0:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
c01014b4:	c6 45 d7 00          	movb   $0x0,-0x29(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01014b8:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c01014bc:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01014c0:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECCNT, nsecs);
c01014c1:	8b 45 14             	mov    0x14(%ebp),%eax
c01014c4:	0f b6 c0             	movzbl %al,%eax
c01014c7:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014cb:	83 c2 02             	add    $0x2,%edx
c01014ce:	0f b7 d2             	movzwl %dx,%edx
c01014d1:	66 89 55 e8          	mov    %dx,-0x18(%ebp)
c01014d5:	88 45 d8             	mov    %al,-0x28(%ebp)
c01014d8:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01014dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01014df:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SECTOR, secno & 0xFF);
c01014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01014e3:	0f b6 c0             	movzbl %al,%eax
c01014e6:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01014ea:	83 c2 03             	add    $0x3,%edx
c01014ed:	0f b7 d2             	movzwl %dx,%edx
c01014f0:	66 89 55 e6          	mov    %dx,-0x1a(%ebp)
c01014f4:	88 45 d9             	mov    %al,-0x27(%ebp)
c01014f7:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01014fb:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01014ff:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_LO, (secno >> 8) & 0xFF);
c0101500:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101503:	c1 e8 08             	shr    $0x8,%eax
c0101506:	0f b6 c0             	movzbl %al,%eax
c0101509:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010150d:	83 c2 04             	add    $0x4,%edx
c0101510:	0f b7 d2             	movzwl %dx,%edx
c0101513:	66 89 55 e4          	mov    %dx,-0x1c(%ebp)
c0101517:	88 45 da             	mov    %al,-0x26(%ebp)
c010151a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010151e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101521:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
c0101522:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101525:	c1 e8 10             	shr    $0x10,%eax
c0101528:	0f b6 c0             	movzbl %al,%eax
c010152b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010152f:	83 c2 05             	add    $0x5,%edx
c0101532:	0f b7 d2             	movzwl %dx,%edx
c0101535:	66 89 55 e2          	mov    %dx,-0x1e(%ebp)
c0101539:	88 45 db             	mov    %al,-0x25(%ebp)
c010153c:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0101540:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101544:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
c0101545:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0101548:	24 01                	and    $0x1,%al
c010154a:	c0 e0 04             	shl    $0x4,%al
c010154d:	88 c2                	mov    %al,%dl
c010154f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0101552:	c1 e8 18             	shr    $0x18,%eax
c0101555:	24 0f                	and    $0xf,%al
c0101557:	08 d0                	or     %dl,%al
c0101559:	0c e0                	or     $0xe0,%al
c010155b:	0f b6 c0             	movzbl %al,%eax
c010155e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101562:	83 c2 06             	add    $0x6,%edx
c0101565:	0f b7 d2             	movzwl %dx,%edx
c0101568:	66 89 55 e0          	mov    %dx,-0x20(%ebp)
c010156c:	88 45 dc             	mov    %al,-0x24(%ebp)
c010156f:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101573:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0101576:	ee                   	out    %al,(%dx)
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);
c0101577:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010157b:	83 c0 07             	add    $0x7,%eax
c010157e:	0f b7 c0             	movzwl %ax,%eax
c0101581:	66 89 45 de          	mov    %ax,-0x22(%ebp)
c0101585:	c6 45 dd 30          	movb   $0x30,-0x23(%ebp)
c0101589:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010158d:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101591:	ee                   	out    %al,(%dx)

    int ret = 0;
c0101592:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c0101599:	eb 57                	jmp    c01015f2 <ide_write_secs+0x227>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
c010159b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010159f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01015a6:	00 
c01015a7:	89 04 24             	mov    %eax,(%esp)
c01015aa:	e8 ee f7 ff ff       	call   c0100d9d <ide_wait_ready>
c01015af:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01015b2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01015b6:	75 42                	jne    c01015fa <ide_write_secs+0x22f>
            goto out;
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
c01015b8:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01015bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01015bf:	8b 45 10             	mov    0x10(%ebp),%eax
c01015c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01015c5:	c7 45 cc 80 00 00 00 	movl   $0x80,-0x34(%ebp)
    asm volatile ("outw %0, %1" :: "a" (data), "d" (port) : "memory");
}

static inline void
outsl(uint32_t port, const void *addr, int cnt) {
    asm volatile (
c01015cc:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01015cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
c01015d2:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01015d5:	89 cb                	mov    %ecx,%ebx
c01015d7:	89 de                	mov    %ebx,%esi
c01015d9:	89 c1                	mov    %eax,%ecx
c01015db:	fc                   	cld    
c01015dc:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
c01015de:	89 c8                	mov    %ecx,%eax
c01015e0:	89 f3                	mov    %esi,%ebx
c01015e2:	89 5d d0             	mov    %ebx,-0x30(%ebp)
c01015e5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    outb(iobase + ISA_CYL_HI, (secno >> 16) & 0xFF);
    outb(iobase + ISA_SDH, 0xE0 | ((ideno & 1) << 4) | ((secno >> 24) & 0xF));
    outb(iobase + ISA_COMMAND, IDE_CMD_WRITE);

    int ret = 0;
    for (; nsecs > 0; nsecs --, src += SECTSIZE) {
c01015e8:	ff 4d 14             	decl   0x14(%ebp)
c01015eb:	81 45 10 00 02 00 00 	addl   $0x200,0x10(%ebp)
c01015f2:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
c01015f6:	75 a3                	jne    c010159b <ide_write_secs+0x1d0>
c01015f8:	eb 01                	jmp    c01015fb <ide_write_secs+0x230>
        if ((ret = ide_wait_ready(iobase, 1)) != 0) {
            goto out;
c01015fa:	90                   	nop
        }
        outsl(iobase, src, SECTSIZE / sizeof(uint32_t));
    }

out:
    return ret;
c01015fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015fe:	83 c4 50             	add    $0x50,%esp
c0101601:	5b                   	pop    %ebx
c0101602:	5e                   	pop    %esi
c0101603:	5d                   	pop    %ebp
c0101604:	c3                   	ret    

c0101605 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0101605:	55                   	push   %ebp
c0101606:	89 e5                	mov    %esp,%ebp
c0101608:	83 ec 28             	sub    $0x28,%esp
c010160b:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0101611:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101615:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0101619:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010161d:	ee                   	out    %al,(%dx)
c010161e:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0101624:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0101628:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c010162c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010162f:	ee                   	out    %al,(%dx)
c0101630:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0101636:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c010163a:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010163e:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101642:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0101643:	c7 05 1c 50 12 c0 00 	movl   $0x0,0xc012501c
c010164a:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c010164d:	c7 04 24 e6 95 10 c0 	movl   $0xc01095e6,(%esp)
c0101654:	e8 48 ec ff ff       	call   c01002a1 <cprintf>
    pic_enable(IRQ_TIMER);
c0101659:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0101660:	e8 1e 09 00 00       	call   c0101f83 <pic_enable>
}
c0101665:	90                   	nop
c0101666:	c9                   	leave  
c0101667:	c3                   	ret    

c0101668 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0101668:	55                   	push   %ebp
c0101669:	89 e5                	mov    %esp,%ebp
c010166b:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c010166e:	9c                   	pushf  
c010166f:	58                   	pop    %eax
c0101670:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0101673:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0101676:	25 00 02 00 00       	and    $0x200,%eax
c010167b:	85 c0                	test   %eax,%eax
c010167d:	74 0c                	je     c010168b <__intr_save+0x23>
        intr_disable();
c010167f:	e8 6c 0a 00 00       	call   c01020f0 <intr_disable>
        return 1;
c0101684:	b8 01 00 00 00       	mov    $0x1,%eax
c0101689:	eb 05                	jmp    c0101690 <__intr_save+0x28>
    }
    return 0;
c010168b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0101690:	c9                   	leave  
c0101691:	c3                   	ret    

c0101692 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0101692:	55                   	push   %ebp
c0101693:	89 e5                	mov    %esp,%ebp
c0101695:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0101698:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c010169c:	74 05                	je     c01016a3 <__intr_restore+0x11>
        intr_enable();
c010169e:	e8 46 0a 00 00       	call   c01020e9 <intr_enable>
    }
}
c01016a3:	90                   	nop
c01016a4:	c9                   	leave  
c01016a5:	c3                   	ret    

c01016a6 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c01016a6:	55                   	push   %ebp
c01016a7:	89 e5                	mov    %esp,%ebp
c01016a9:	83 ec 10             	sub    $0x10,%esp
c01016ac:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01016b2:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01016b6:	89 c2                	mov    %eax,%edx
c01016b8:	ec                   	in     (%dx),%al
c01016b9:	88 45 f4             	mov    %al,-0xc(%ebp)
c01016bc:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c01016c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016c5:	89 c2                	mov    %eax,%edx
c01016c7:	ec                   	in     (%dx),%al
c01016c8:	88 45 f5             	mov    %al,-0xb(%ebp)
c01016cb:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c01016d1:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01016d5:	89 c2                	mov    %eax,%edx
c01016d7:	ec                   	in     (%dx),%al
c01016d8:	88 45 f6             	mov    %al,-0xa(%ebp)
c01016db:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c01016e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01016e4:	89 c2                	mov    %eax,%edx
c01016e6:	ec                   	in     (%dx),%al
c01016e7:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c01016ea:	90                   	nop
c01016eb:	c9                   	leave  
c01016ec:	c3                   	ret    

c01016ed <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c01016ed:	55                   	push   %ebp
c01016ee:	89 e5                	mov    %esp,%ebp
c01016f0:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c01016f3:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c01016fa:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01016fd:	0f b7 00             	movzwl (%eax),%eax
c0101700:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0101704:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101707:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c010170c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010170f:	0f b7 00             	movzwl (%eax),%eax
c0101712:	0f b7 c0             	movzwl %ax,%eax
c0101715:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c010171a:	74 12                	je     c010172e <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c010171c:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0101723:	66 c7 05 26 45 12 c0 	movw   $0x3b4,0xc0124526
c010172a:	b4 03 
c010172c:	eb 13                	jmp    c0101741 <cga_init+0x54>
    } else {
        *cp = was;
c010172e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101731:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101735:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0101738:	66 c7 05 26 45 12 c0 	movw   $0x3d4,0xc0124526
c010173f:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0101741:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c0101748:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c010174c:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101750:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101754:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0101757:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0101758:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c010175f:	40                   	inc    %eax
c0101760:	0f b7 c0             	movzwl %ax,%eax
c0101763:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101767:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c010176b:	89 c2                	mov    %eax,%edx
c010176d:	ec                   	in     (%dx),%al
c010176e:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101771:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101775:	0f b6 c0             	movzbl %al,%eax
c0101778:	c1 e0 08             	shl    $0x8,%eax
c010177b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c010177e:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c0101785:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0101789:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010178d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0101791:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101794:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0101795:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c010179c:	40                   	inc    %eax
c010179d:	0f b7 c0             	movzwl %ax,%eax
c01017a0:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01017a4:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c01017a8:	89 c2                	mov    %eax,%edx
c01017aa:	ec                   	in     (%dx),%al
c01017ab:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c01017ae:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01017b2:	0f b6 c0             	movzbl %al,%eax
c01017b5:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c01017b8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01017bb:	a3 20 45 12 c0       	mov    %eax,0xc0124520
    crt_pos = pos;
c01017c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01017c3:	0f b7 c0             	movzwl %ax,%eax
c01017c6:	66 a3 24 45 12 c0    	mov    %ax,0xc0124524
}
c01017cc:	90                   	nop
c01017cd:	c9                   	leave  
c01017ce:	c3                   	ret    

c01017cf <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c01017cf:	55                   	push   %ebp
c01017d0:	89 e5                	mov    %esp,%ebp
c01017d2:	83 ec 38             	sub    $0x38,%esp
c01017d5:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c01017db:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017df:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017e3:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017e7:	ee                   	out    %al,(%dx)
c01017e8:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c01017ee:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c01017f2:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017f9:	ee                   	out    %al,(%dx)
c01017fa:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0101800:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0101804:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0101808:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010180c:	ee                   	out    %al,(%dx)
c010180d:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0101813:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0101817:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010181b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010181e:	ee                   	out    %al,(%dx)
c010181f:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0101825:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0101829:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c010182d:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101831:	ee                   	out    %al,(%dx)
c0101832:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0101838:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c010183c:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101840:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101843:	ee                   	out    %al,(%dx)
c0101844:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010184a:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c010184e:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101852:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101856:	ee                   	out    %al,(%dx)
c0101857:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010185d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0101860:	89 c2                	mov    %eax,%edx
c0101862:	ec                   	in     (%dx),%al
c0101863:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0101866:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010186a:	3c ff                	cmp    $0xff,%al
c010186c:	0f 95 c0             	setne  %al
c010186f:	0f b6 c0             	movzbl %al,%eax
c0101872:	a3 28 45 12 c0       	mov    %eax,0xc0124528
c0101877:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010187d:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c0101881:	89 c2                	mov    %eax,%edx
c0101883:	ec                   	in     (%dx),%al
c0101884:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101887:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c010188d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0101890:	89 c2                	mov    %eax,%edx
c0101892:	ec                   	in     (%dx),%al
c0101893:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101896:	a1 28 45 12 c0       	mov    0xc0124528,%eax
c010189b:	85 c0                	test   %eax,%eax
c010189d:	74 0c                	je     c01018ab <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c010189f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01018a6:	e8 d8 06 00 00       	call   c0101f83 <pic_enable>
    }
}
c01018ab:	90                   	nop
c01018ac:	c9                   	leave  
c01018ad:	c3                   	ret    

c01018ae <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c01018ae:	55                   	push   %ebp
c01018af:	89 e5                	mov    %esp,%ebp
c01018b1:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018b4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018bb:	eb 08                	jmp    c01018c5 <lpt_putc_sub+0x17>
        delay();
c01018bd:	e8 e4 fd ff ff       	call   c01016a6 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c01018c2:	ff 45 fc             	incl   -0x4(%ebp)
c01018c5:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c01018cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01018ce:	89 c2                	mov    %eax,%edx
c01018d0:	ec                   	in     (%dx),%al
c01018d1:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c01018d4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01018d8:	84 c0                	test   %al,%al
c01018da:	78 09                	js     c01018e5 <lpt_putc_sub+0x37>
c01018dc:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01018e3:	7e d8                	jle    c01018bd <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c01018e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01018e8:	0f b6 c0             	movzbl %al,%eax
c01018eb:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c01018f1:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018f4:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01018f8:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01018fb:	ee                   	out    %al,(%dx)
c01018fc:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c0101902:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c0101906:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010190a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010190e:	ee                   	out    %al,(%dx)
c010190f:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c0101915:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c0101919:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c010191d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101921:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c0101922:	90                   	nop
c0101923:	c9                   	leave  
c0101924:	c3                   	ret    

c0101925 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101925:	55                   	push   %ebp
c0101926:	89 e5                	mov    %esp,%ebp
c0101928:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010192b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010192f:	74 0d                	je     c010193e <lpt_putc+0x19>
        lpt_putc_sub(c);
c0101931:	8b 45 08             	mov    0x8(%ebp),%eax
c0101934:	89 04 24             	mov    %eax,(%esp)
c0101937:	e8 72 ff ff ff       	call   c01018ae <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c010193c:	eb 24                	jmp    c0101962 <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c010193e:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101945:	e8 64 ff ff ff       	call   c01018ae <lpt_putc_sub>
        lpt_putc_sub(' ');
c010194a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101951:	e8 58 ff ff ff       	call   c01018ae <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101956:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c010195d:	e8 4c ff ff ff       	call   c01018ae <lpt_putc_sub>
    }
}
c0101962:	90                   	nop
c0101963:	c9                   	leave  
c0101964:	c3                   	ret    

c0101965 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101965:	55                   	push   %ebp
c0101966:	89 e5                	mov    %esp,%ebp
c0101968:	53                   	push   %ebx
c0101969:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c010196c:	8b 45 08             	mov    0x8(%ebp),%eax
c010196f:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101974:	85 c0                	test   %eax,%eax
c0101976:	75 07                	jne    c010197f <cga_putc+0x1a>
        c |= 0x0700;
c0101978:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010197f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101982:	0f b6 c0             	movzbl %al,%eax
c0101985:	83 f8 0a             	cmp    $0xa,%eax
c0101988:	74 54                	je     c01019de <cga_putc+0x79>
c010198a:	83 f8 0d             	cmp    $0xd,%eax
c010198d:	74 62                	je     c01019f1 <cga_putc+0x8c>
c010198f:	83 f8 08             	cmp    $0x8,%eax
c0101992:	0f 85 93 00 00 00    	jne    c0101a2b <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101998:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c010199f:	85 c0                	test   %eax,%eax
c01019a1:	0f 84 ae 00 00 00    	je     c0101a55 <cga_putc+0xf0>
            crt_pos --;
c01019a7:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c01019ae:	48                   	dec    %eax
c01019af:	0f b7 c0             	movzwl %ax,%eax
c01019b2:	66 a3 24 45 12 c0    	mov    %ax,0xc0124524
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01019b8:	a1 20 45 12 c0       	mov    0xc0124520,%eax
c01019bd:	0f b7 15 24 45 12 c0 	movzwl 0xc0124524,%edx
c01019c4:	01 d2                	add    %edx,%edx
c01019c6:	01 c2                	add    %eax,%edx
c01019c8:	8b 45 08             	mov    0x8(%ebp),%eax
c01019cb:	98                   	cwtl   
c01019cc:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01019d1:	98                   	cwtl   
c01019d2:	83 c8 20             	or     $0x20,%eax
c01019d5:	98                   	cwtl   
c01019d6:	0f b7 c0             	movzwl %ax,%eax
c01019d9:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01019dc:	eb 77                	jmp    c0101a55 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c01019de:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c01019e5:	83 c0 50             	add    $0x50,%eax
c01019e8:	0f b7 c0             	movzwl %ax,%eax
c01019eb:	66 a3 24 45 12 c0    	mov    %ax,0xc0124524
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01019f1:	0f b7 1d 24 45 12 c0 	movzwl 0xc0124524,%ebx
c01019f8:	0f b7 0d 24 45 12 c0 	movzwl 0xc0124524,%ecx
c01019ff:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c0101a04:	89 c8                	mov    %ecx,%eax
c0101a06:	f7 e2                	mul    %edx
c0101a08:	c1 ea 06             	shr    $0x6,%edx
c0101a0b:	89 d0                	mov    %edx,%eax
c0101a0d:	c1 e0 02             	shl    $0x2,%eax
c0101a10:	01 d0                	add    %edx,%eax
c0101a12:	c1 e0 04             	shl    $0x4,%eax
c0101a15:	29 c1                	sub    %eax,%ecx
c0101a17:	89 c8                	mov    %ecx,%eax
c0101a19:	0f b7 c0             	movzwl %ax,%eax
c0101a1c:	29 c3                	sub    %eax,%ebx
c0101a1e:	89 d8                	mov    %ebx,%eax
c0101a20:	0f b7 c0             	movzwl %ax,%eax
c0101a23:	66 a3 24 45 12 c0    	mov    %ax,0xc0124524
        break;
c0101a29:	eb 2b                	jmp    c0101a56 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101a2b:	8b 0d 20 45 12 c0    	mov    0xc0124520,%ecx
c0101a31:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c0101a38:	8d 50 01             	lea    0x1(%eax),%edx
c0101a3b:	0f b7 d2             	movzwl %dx,%edx
c0101a3e:	66 89 15 24 45 12 c0 	mov    %dx,0xc0124524
c0101a45:	01 c0                	add    %eax,%eax
c0101a47:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101a4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101a4d:	0f b7 c0             	movzwl %ax,%eax
c0101a50:	66 89 02             	mov    %ax,(%edx)
        break;
c0101a53:	eb 01                	jmp    c0101a56 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101a55:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101a56:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c0101a5d:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c0101a62:	76 5d                	jbe    c0101ac1 <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c0101a64:	a1 20 45 12 c0       	mov    0xc0124520,%eax
c0101a69:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c0101a6f:	a1 20 45 12 c0       	mov    0xc0124520,%eax
c0101a74:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101a7b:	00 
c0101a7c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101a80:	89 04 24             	mov    %eax,(%esp)
c0101a83:	e8 b2 6e 00 00       	call   c010893a <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101a88:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c0101a8f:	eb 14                	jmp    c0101aa5 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c0101a91:	a1 20 45 12 c0       	mov    0xc0124520,%eax
c0101a96:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101a99:	01 d2                	add    %edx,%edx
c0101a9b:	01 d0                	add    %edx,%eax
c0101a9d:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101aa2:	ff 45 f4             	incl   -0xc(%ebp)
c0101aa5:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101aac:	7e e3                	jle    c0101a91 <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101aae:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c0101ab5:	83 e8 50             	sub    $0x50,%eax
c0101ab8:	0f b7 c0             	movzwl %ax,%eax
c0101abb:	66 a3 24 45 12 c0    	mov    %ax,0xc0124524
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c0101ac1:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c0101ac8:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101acc:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c0101ad0:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c0101ad4:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101ad8:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101ad9:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c0101ae0:	c1 e8 08             	shr    $0x8,%eax
c0101ae3:	0f b7 c0             	movzwl %ax,%eax
c0101ae6:	0f b6 c0             	movzbl %al,%eax
c0101ae9:	0f b7 15 26 45 12 c0 	movzwl 0xc0124526,%edx
c0101af0:	42                   	inc    %edx
c0101af1:	0f b7 d2             	movzwl %dx,%edx
c0101af4:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c0101af8:	88 45 e9             	mov    %al,-0x17(%ebp)
c0101afb:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101aff:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101b02:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c0101b03:	0f b7 05 26 45 12 c0 	movzwl 0xc0124526,%eax
c0101b0a:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0101b0e:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c0101b12:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0101b16:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101b1a:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c0101b1b:	0f b7 05 24 45 12 c0 	movzwl 0xc0124524,%eax
c0101b22:	0f b6 c0             	movzbl %al,%eax
c0101b25:	0f b7 15 26 45 12 c0 	movzwl 0xc0124526,%edx
c0101b2c:	42                   	inc    %edx
c0101b2d:	0f b7 d2             	movzwl %dx,%edx
c0101b30:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c0101b34:	88 45 eb             	mov    %al,-0x15(%ebp)
c0101b37:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0101b3b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101b3e:	ee                   	out    %al,(%dx)
}
c0101b3f:	90                   	nop
c0101b40:	83 c4 24             	add    $0x24,%esp
c0101b43:	5b                   	pop    %ebx
c0101b44:	5d                   	pop    %ebp
c0101b45:	c3                   	ret    

c0101b46 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101b46:	55                   	push   %ebp
c0101b47:	89 e5                	mov    %esp,%ebp
c0101b49:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b4c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101b53:	eb 08                	jmp    c0101b5d <serial_putc_sub+0x17>
        delay();
c0101b55:	e8 4c fb ff ff       	call   c01016a6 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101b5a:	ff 45 fc             	incl   -0x4(%ebp)
c0101b5d:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101b63:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b66:	89 c2                	mov    %eax,%edx
c0101b68:	ec                   	in     (%dx),%al
c0101b69:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101b6c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0101b70:	0f b6 c0             	movzbl %al,%eax
c0101b73:	83 e0 20             	and    $0x20,%eax
c0101b76:	85 c0                	test   %eax,%eax
c0101b78:	75 09                	jne    c0101b83 <serial_putc_sub+0x3d>
c0101b7a:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101b81:	7e d2                	jle    c0101b55 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c0101b83:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b86:	0f b6 c0             	movzbl %al,%eax
c0101b89:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c0101b8f:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101b92:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101b96:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101b9a:	ee                   	out    %al,(%dx)
}
c0101b9b:	90                   	nop
c0101b9c:	c9                   	leave  
c0101b9d:	c3                   	ret    

c0101b9e <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101b9e:	55                   	push   %ebp
c0101b9f:	89 e5                	mov    %esp,%ebp
c0101ba1:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101ba4:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101ba8:	74 0d                	je     c0101bb7 <serial_putc+0x19>
        serial_putc_sub(c);
c0101baa:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bad:	89 04 24             	mov    %eax,(%esp)
c0101bb0:	e8 91 ff ff ff       	call   c0101b46 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101bb5:	eb 24                	jmp    c0101bdb <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101bb7:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bbe:	e8 83 ff ff ff       	call   c0101b46 <serial_putc_sub>
        serial_putc_sub(' ');
c0101bc3:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101bca:	e8 77 ff ff ff       	call   c0101b46 <serial_putc_sub>
        serial_putc_sub('\b');
c0101bcf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101bd6:	e8 6b ff ff ff       	call   c0101b46 <serial_putc_sub>
    }
}
c0101bdb:	90                   	nop
c0101bdc:	c9                   	leave  
c0101bdd:	c3                   	ret    

c0101bde <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101bde:	55                   	push   %ebp
c0101bdf:	89 e5                	mov    %esp,%ebp
c0101be1:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c0101be4:	eb 33                	jmp    c0101c19 <cons_intr+0x3b>
        if (c != 0) {
c0101be6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101bea:	74 2d                	je     c0101c19 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101bec:	a1 44 47 12 c0       	mov    0xc0124744,%eax
c0101bf1:	8d 50 01             	lea    0x1(%eax),%edx
c0101bf4:	89 15 44 47 12 c0    	mov    %edx,0xc0124744
c0101bfa:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101bfd:	88 90 40 45 12 c0    	mov    %dl,-0x3fedbac0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c0101c03:	a1 44 47 12 c0       	mov    0xc0124744,%eax
c0101c08:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101c0d:	75 0a                	jne    c0101c19 <cons_intr+0x3b>
                cons.wpos = 0;
c0101c0f:	c7 05 44 47 12 c0 00 	movl   $0x0,0xc0124744
c0101c16:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c0101c19:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1c:	ff d0                	call   *%eax
c0101c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0101c21:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c0101c25:	75 bf                	jne    c0101be6 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c0101c27:	90                   	nop
c0101c28:	c9                   	leave  
c0101c29:	c3                   	ret    

c0101c2a <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101c2a:	55                   	push   %ebp
c0101c2b:	89 e5                	mov    %esp,%ebp
c0101c2d:	83 ec 10             	sub    $0x10,%esp
c0101c30:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c36:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101c39:	89 c2                	mov    %eax,%edx
c0101c3b:	ec                   	in     (%dx),%al
c0101c3c:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101c3f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101c43:	0f b6 c0             	movzbl %al,%eax
c0101c46:	83 e0 01             	and    $0x1,%eax
c0101c49:	85 c0                	test   %eax,%eax
c0101c4b:	75 07                	jne    c0101c54 <serial_proc_data+0x2a>
        return -1;
c0101c4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101c52:	eb 2a                	jmp    c0101c7e <serial_proc_data+0x54>
c0101c54:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101c5a:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101c5e:	89 c2                	mov    %eax,%edx
c0101c60:	ec                   	in     (%dx),%al
c0101c61:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c0101c64:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101c68:	0f b6 c0             	movzbl %al,%eax
c0101c6b:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101c6e:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c0101c72:	75 07                	jne    c0101c7b <serial_proc_data+0x51>
        c = '\b';
c0101c74:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101c7b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101c7e:	c9                   	leave  
c0101c7f:	c3                   	ret    

c0101c80 <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c0101c80:	55                   	push   %ebp
c0101c81:	89 e5                	mov    %esp,%ebp
c0101c83:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101c86:	a1 28 45 12 c0       	mov    0xc0124528,%eax
c0101c8b:	85 c0                	test   %eax,%eax
c0101c8d:	74 0c                	je     c0101c9b <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c0101c8f:	c7 04 24 2a 1c 10 c0 	movl   $0xc0101c2a,(%esp)
c0101c96:	e8 43 ff ff ff       	call   c0101bde <cons_intr>
    }
}
c0101c9b:	90                   	nop
c0101c9c:	c9                   	leave  
c0101c9d:	c3                   	ret    

c0101c9e <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101c9e:	55                   	push   %ebp
c0101c9f:	89 e5                	mov    %esp,%ebp
c0101ca1:	83 ec 28             	sub    $0x28,%esp
c0101ca4:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101caa:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101cad:	89 c2                	mov    %eax,%edx
c0101caf:	ec                   	in     (%dx),%al
c0101cb0:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0101cb3:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101cb7:	0f b6 c0             	movzbl %al,%eax
c0101cba:	83 e0 01             	and    $0x1,%eax
c0101cbd:	85 c0                	test   %eax,%eax
c0101cbf:	75 0a                	jne    c0101ccb <kbd_proc_data+0x2d>
        return -1;
c0101cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101cc6:	e9 56 01 00 00       	jmp    c0101e21 <kbd_proc_data+0x183>
c0101ccb:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101cd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cd4:	89 c2                	mov    %eax,%edx
c0101cd6:	ec                   	in     (%dx),%al
c0101cd7:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101cda:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101cde:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c0101ce1:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101ce5:	75 17                	jne    c0101cfe <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101ce7:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101cec:	83 c8 40             	or     $0x40,%eax
c0101cef:	a3 48 47 12 c0       	mov    %eax,0xc0124748
        return 0;
c0101cf4:	b8 00 00 00 00       	mov    $0x0,%eax
c0101cf9:	e9 23 01 00 00       	jmp    c0101e21 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c0101cfe:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d02:	84 c0                	test   %al,%al
c0101d04:	79 45                	jns    c0101d4b <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101d06:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d0b:	83 e0 40             	and    $0x40,%eax
c0101d0e:	85 c0                	test   %eax,%eax
c0101d10:	75 08                	jne    c0101d1a <kbd_proc_data+0x7c>
c0101d12:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d16:	24 7f                	and    $0x7f,%al
c0101d18:	eb 04                	jmp    c0101d1e <kbd_proc_data+0x80>
c0101d1a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d1e:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101d21:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d25:	0f b6 80 40 10 12 c0 	movzbl -0x3fedefc0(%eax),%eax
c0101d2c:	0c 40                	or     $0x40,%al
c0101d2e:	0f b6 c0             	movzbl %al,%eax
c0101d31:	f7 d0                	not    %eax
c0101d33:	89 c2                	mov    %eax,%edx
c0101d35:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d3a:	21 d0                	and    %edx,%eax
c0101d3c:	a3 48 47 12 c0       	mov    %eax,0xc0124748
        return 0;
c0101d41:	b8 00 00 00 00       	mov    $0x0,%eax
c0101d46:	e9 d6 00 00 00       	jmp    c0101e21 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c0101d4b:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d50:	83 e0 40             	and    $0x40,%eax
c0101d53:	85 c0                	test   %eax,%eax
c0101d55:	74 11                	je     c0101d68 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101d57:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101d5b:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d60:	83 e0 bf             	and    $0xffffffbf,%eax
c0101d63:	a3 48 47 12 c0       	mov    %eax,0xc0124748
    }

    shift |= shiftcode[data];
c0101d68:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d6c:	0f b6 80 40 10 12 c0 	movzbl -0x3fedefc0(%eax),%eax
c0101d73:	0f b6 d0             	movzbl %al,%edx
c0101d76:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d7b:	09 d0                	or     %edx,%eax
c0101d7d:	a3 48 47 12 c0       	mov    %eax,0xc0124748
    shift ^= togglecode[data];
c0101d82:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101d86:	0f b6 80 40 11 12 c0 	movzbl -0x3fedeec0(%eax),%eax
c0101d8d:	0f b6 d0             	movzbl %al,%edx
c0101d90:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101d95:	31 d0                	xor    %edx,%eax
c0101d97:	a3 48 47 12 c0       	mov    %eax,0xc0124748

    c = charcode[shift & (CTL | SHIFT)][data];
c0101d9c:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101da1:	83 e0 03             	and    $0x3,%eax
c0101da4:	8b 14 85 40 15 12 c0 	mov    -0x3fedeac0(,%eax,4),%edx
c0101dab:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101daf:	01 d0                	add    %edx,%eax
c0101db1:	0f b6 00             	movzbl (%eax),%eax
c0101db4:	0f b6 c0             	movzbl %al,%eax
c0101db7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101dba:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101dbf:	83 e0 08             	and    $0x8,%eax
c0101dc2:	85 c0                	test   %eax,%eax
c0101dc4:	74 22                	je     c0101de8 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101dc6:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101dca:	7e 0c                	jle    c0101dd8 <kbd_proc_data+0x13a>
c0101dcc:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c0101dd0:	7f 06                	jg     c0101dd8 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c0101dd2:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101dd6:	eb 10                	jmp    c0101de8 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101dd8:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101ddc:	7e 0a                	jle    c0101de8 <kbd_proc_data+0x14a>
c0101dde:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c0101de2:	7f 04                	jg     c0101de8 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c0101de4:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101de8:	a1 48 47 12 c0       	mov    0xc0124748,%eax
c0101ded:	f7 d0                	not    %eax
c0101def:	83 e0 06             	and    $0x6,%eax
c0101df2:	85 c0                	test   %eax,%eax
c0101df4:	75 28                	jne    c0101e1e <kbd_proc_data+0x180>
c0101df6:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c0101dfd:	75 1f                	jne    c0101e1e <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101dff:	c7 04 24 01 96 10 c0 	movl   $0xc0109601,(%esp)
c0101e06:	e8 96 e4 ff ff       	call   c01002a1 <cprintf>
c0101e0b:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c0101e11:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101e15:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101e19:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101e1d:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c0101e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101e21:	c9                   	leave  
c0101e22:	c3                   	ret    

c0101e23 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101e23:	55                   	push   %ebp
c0101e24:	89 e5                	mov    %esp,%ebp
c0101e26:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c0101e29:	c7 04 24 9e 1c 10 c0 	movl   $0xc0101c9e,(%esp)
c0101e30:	e8 a9 fd ff ff       	call   c0101bde <cons_intr>
}
c0101e35:	90                   	nop
c0101e36:	c9                   	leave  
c0101e37:	c3                   	ret    

c0101e38 <kbd_init>:

static void
kbd_init(void) {
c0101e38:	55                   	push   %ebp
c0101e39:	89 e5                	mov    %esp,%ebp
c0101e3b:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101e3e:	e8 e0 ff ff ff       	call   c0101e23 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101e43:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0101e4a:	e8 34 01 00 00       	call   c0101f83 <pic_enable>
}
c0101e4f:	90                   	nop
c0101e50:	c9                   	leave  
c0101e51:	c3                   	ret    

c0101e52 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101e52:	55                   	push   %ebp
c0101e53:	89 e5                	mov    %esp,%ebp
c0101e55:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101e58:	e8 90 f8 ff ff       	call   c01016ed <cga_init>
    serial_init();
c0101e5d:	e8 6d f9 ff ff       	call   c01017cf <serial_init>
    kbd_init();
c0101e62:	e8 d1 ff ff ff       	call   c0101e38 <kbd_init>
    if (!serial_exists) {
c0101e67:	a1 28 45 12 c0       	mov    0xc0124528,%eax
c0101e6c:	85 c0                	test   %eax,%eax
c0101e6e:	75 0c                	jne    c0101e7c <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101e70:	c7 04 24 0d 96 10 c0 	movl   $0xc010960d,(%esp)
c0101e77:	e8 25 e4 ff ff       	call   c01002a1 <cprintf>
    }
}
c0101e7c:	90                   	nop
c0101e7d:	c9                   	leave  
c0101e7e:	c3                   	ret    

c0101e7f <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101e7f:	55                   	push   %ebp
c0101e80:	89 e5                	mov    %esp,%ebp
c0101e82:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101e85:	e8 de f7 ff ff       	call   c0101668 <__intr_save>
c0101e8a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101e8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e90:	89 04 24             	mov    %eax,(%esp)
c0101e93:	e8 8d fa ff ff       	call   c0101925 <lpt_putc>
        cga_putc(c);
c0101e98:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e9b:	89 04 24             	mov    %eax,(%esp)
c0101e9e:	e8 c2 fa ff ff       	call   c0101965 <cga_putc>
        serial_putc(c);
c0101ea3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ea6:	89 04 24             	mov    %eax,(%esp)
c0101ea9:	e8 f0 fc ff ff       	call   c0101b9e <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101eb1:	89 04 24             	mov    %eax,(%esp)
c0101eb4:	e8 d9 f7 ff ff       	call   c0101692 <__intr_restore>
}
c0101eb9:	90                   	nop
c0101eba:	c9                   	leave  
c0101ebb:	c3                   	ret    

c0101ebc <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101ebc:	55                   	push   %ebp
c0101ebd:	89 e5                	mov    %esp,%ebp
c0101ebf:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c0101ec2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101ec9:	e8 9a f7 ff ff       	call   c0101668 <__intr_save>
c0101ece:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c0101ed1:	e8 aa fd ff ff       	call   c0101c80 <serial_intr>
        kbd_intr();
c0101ed6:	e8 48 ff ff ff       	call   c0101e23 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101edb:	8b 15 40 47 12 c0    	mov    0xc0124740,%edx
c0101ee1:	a1 44 47 12 c0       	mov    0xc0124744,%eax
c0101ee6:	39 c2                	cmp    %eax,%edx
c0101ee8:	74 31                	je     c0101f1b <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101eea:	a1 40 47 12 c0       	mov    0xc0124740,%eax
c0101eef:	8d 50 01             	lea    0x1(%eax),%edx
c0101ef2:	89 15 40 47 12 c0    	mov    %edx,0xc0124740
c0101ef8:	0f b6 80 40 45 12 c0 	movzbl -0x3fedbac0(%eax),%eax
c0101eff:	0f b6 c0             	movzbl %al,%eax
c0101f02:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101f05:	a1 40 47 12 c0       	mov    0xc0124740,%eax
c0101f0a:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101f0f:	75 0a                	jne    c0101f1b <cons_getc+0x5f>
                cons.rpos = 0;
c0101f11:	c7 05 40 47 12 c0 00 	movl   $0x0,0xc0124740
c0101f18:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101f1b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101f1e:	89 04 24             	mov    %eax,(%esp)
c0101f21:	e8 6c f7 ff ff       	call   c0101692 <__intr_restore>
    return c;
c0101f26:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101f29:	c9                   	leave  
c0101f2a:	c3                   	ret    

c0101f2b <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101f2b:	55                   	push   %ebp
c0101f2c:	89 e5                	mov    %esp,%ebp
c0101f2e:	83 ec 14             	sub    $0x14,%esp
c0101f31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f34:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101f38:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f3b:	66 a3 50 15 12 c0    	mov    %ax,0xc0121550
    if (did_init) {
c0101f41:	a1 4c 47 12 c0       	mov    0xc012474c,%eax
c0101f46:	85 c0                	test   %eax,%eax
c0101f48:	74 36                	je     c0101f80 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c0101f4a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101f4d:	0f b6 c0             	movzbl %al,%eax
c0101f50:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101f56:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101f59:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101f5d:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101f61:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c0101f62:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101f66:	c1 e8 08             	shr    $0x8,%eax
c0101f69:	0f b7 c0             	movzwl %ax,%eax
c0101f6c:	0f b6 c0             	movzbl %al,%eax
c0101f6f:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101f75:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101f78:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101f7c:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101f7f:	ee                   	out    %al,(%dx)
    }
}
c0101f80:	90                   	nop
c0101f81:	c9                   	leave  
c0101f82:	c3                   	ret    

c0101f83 <pic_enable>:

void
pic_enable(unsigned int irq) {
c0101f83:	55                   	push   %ebp
c0101f84:	89 e5                	mov    %esp,%ebp
c0101f86:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101f89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f8c:	ba 01 00 00 00       	mov    $0x1,%edx
c0101f91:	88 c1                	mov    %al,%cl
c0101f93:	d3 e2                	shl    %cl,%edx
c0101f95:	89 d0                	mov    %edx,%eax
c0101f97:	98                   	cwtl   
c0101f98:	f7 d0                	not    %eax
c0101f9a:	0f bf d0             	movswl %ax,%edx
c0101f9d:	0f b7 05 50 15 12 c0 	movzwl 0xc0121550,%eax
c0101fa4:	98                   	cwtl   
c0101fa5:	21 d0                	and    %edx,%eax
c0101fa7:	98                   	cwtl   
c0101fa8:	0f b7 c0             	movzwl %ax,%eax
c0101fab:	89 04 24             	mov    %eax,(%esp)
c0101fae:	e8 78 ff ff ff       	call   c0101f2b <pic_setmask>
}
c0101fb3:	90                   	nop
c0101fb4:	c9                   	leave  
c0101fb5:	c3                   	ret    

c0101fb6 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101fb6:	55                   	push   %ebp
c0101fb7:	89 e5                	mov    %esp,%ebp
c0101fb9:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101fbc:	c7 05 4c 47 12 c0 01 	movl   $0x1,0xc012474c
c0101fc3:	00 00 00 
c0101fc6:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101fcc:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c0101fd0:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c0101fd4:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101fd8:	ee                   	out    %al,(%dx)
c0101fd9:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101fdf:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c0101fe3:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101fe7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101fea:	ee                   	out    %al,(%dx)
c0101feb:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c0101ff1:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c0101ff5:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c0101ff9:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101ffd:	ee                   	out    %al,(%dx)
c0101ffe:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c0102004:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c0102008:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c010200c:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010200f:	ee                   	out    %al,(%dx)
c0102010:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c0102016:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c010201a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c010201e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0102022:	ee                   	out    %al,(%dx)
c0102023:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c0102029:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c010202d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0102031:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102034:	ee                   	out    %al,(%dx)
c0102035:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c010203b:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c010203f:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0102043:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0102047:	ee                   	out    %al,(%dx)
c0102048:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c010204e:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c0102052:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0102056:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102059:	ee                   	out    %al,(%dx)
c010205a:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c0102060:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c0102064:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0102068:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c010206c:	ee                   	out    %al,(%dx)
c010206d:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c0102073:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0102077:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c010207b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010207e:	ee                   	out    %al,(%dx)
c010207f:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0102085:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0102089:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c010208d:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0102091:	ee                   	out    %al,(%dx)
c0102092:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0102098:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c010209c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c01020a0:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01020a3:	ee                   	out    %al,(%dx)
c01020a4:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c01020aa:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c01020ae:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c01020b2:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01020b6:	ee                   	out    %al,(%dx)
c01020b7:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c01020bd:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c01020c1:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c01020c5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01020c8:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c01020c9:	0f b7 05 50 15 12 c0 	movzwl 0xc0121550,%eax
c01020d0:	3d ff ff 00 00       	cmp    $0xffff,%eax
c01020d5:	74 0f                	je     c01020e6 <pic_init+0x130>
        pic_setmask(irq_mask);
c01020d7:	0f b7 05 50 15 12 c0 	movzwl 0xc0121550,%eax
c01020de:	89 04 24             	mov    %eax,(%esp)
c01020e1:	e8 45 fe ff ff       	call   c0101f2b <pic_setmask>
    }
}
c01020e6:	90                   	nop
c01020e7:	c9                   	leave  
c01020e8:	c3                   	ret    

c01020e9 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c01020e9:	55                   	push   %ebp
c01020ea:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c01020ec:	fb                   	sti    
    sti();
}
c01020ed:	90                   	nop
c01020ee:	5d                   	pop    %ebp
c01020ef:	c3                   	ret    

c01020f0 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c01020f0:	55                   	push   %ebp
c01020f1:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c01020f3:	fa                   	cli    
    cli();
}
c01020f4:	90                   	nop
c01020f5:	5d                   	pop    %ebp
c01020f6:	c3                   	ret    

c01020f7 <print_ticks>:
#include <swap.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01020f7:	55                   	push   %ebp
c01020f8:	89 e5                	mov    %esp,%ebp
c01020fa:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01020fd:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0102104:	00 
c0102105:	c7 04 24 40 96 10 c0 	movl   $0xc0109640,(%esp)
c010210c:	e8 90 e1 ff ff       	call   c01002a1 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c0102111:	90                   	nop
c0102112:	c9                   	leave  
c0102113:	c3                   	ret    

c0102114 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0102114:	55                   	push   %ebp
c0102115:	89 e5                	mov    %esp,%ebp
c0102117:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010211a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0102121:	e9 c4 00 00 00       	jmp    c01021ea <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0102126:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102129:	8b 04 85 e0 15 12 c0 	mov    -0x3fedea20(,%eax,4),%eax
c0102130:	0f b7 d0             	movzwl %ax,%edx
c0102133:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102136:	66 89 14 c5 60 47 12 	mov    %dx,-0x3fedb8a0(,%eax,8)
c010213d:	c0 
c010213e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102141:	66 c7 04 c5 62 47 12 	movw   $0x8,-0x3fedb89e(,%eax,8)
c0102148:	c0 08 00 
c010214b:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010214e:	0f b6 14 c5 64 47 12 	movzbl -0x3fedb89c(,%eax,8),%edx
c0102155:	c0 
c0102156:	80 e2 e0             	and    $0xe0,%dl
c0102159:	88 14 c5 64 47 12 c0 	mov    %dl,-0x3fedb89c(,%eax,8)
c0102160:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102163:	0f b6 14 c5 64 47 12 	movzbl -0x3fedb89c(,%eax,8),%edx
c010216a:	c0 
c010216b:	80 e2 1f             	and    $0x1f,%dl
c010216e:	88 14 c5 64 47 12 c0 	mov    %dl,-0x3fedb89c(,%eax,8)
c0102175:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102178:	0f b6 14 c5 65 47 12 	movzbl -0x3fedb89b(,%eax,8),%edx
c010217f:	c0 
c0102180:	80 e2 f0             	and    $0xf0,%dl
c0102183:	80 ca 0e             	or     $0xe,%dl
c0102186:	88 14 c5 65 47 12 c0 	mov    %dl,-0x3fedb89b(,%eax,8)
c010218d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102190:	0f b6 14 c5 65 47 12 	movzbl -0x3fedb89b(,%eax,8),%edx
c0102197:	c0 
c0102198:	80 e2 ef             	and    $0xef,%dl
c010219b:	88 14 c5 65 47 12 c0 	mov    %dl,-0x3fedb89b(,%eax,8)
c01021a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021a5:	0f b6 14 c5 65 47 12 	movzbl -0x3fedb89b(,%eax,8),%edx
c01021ac:	c0 
c01021ad:	80 e2 9f             	and    $0x9f,%dl
c01021b0:	88 14 c5 65 47 12 c0 	mov    %dl,-0x3fedb89b(,%eax,8)
c01021b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ba:	0f b6 14 c5 65 47 12 	movzbl -0x3fedb89b(,%eax,8),%edx
c01021c1:	c0 
c01021c2:	80 ca 80             	or     $0x80,%dl
c01021c5:	88 14 c5 65 47 12 c0 	mov    %dl,-0x3fedb89b(,%eax,8)
c01021cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021cf:	8b 04 85 e0 15 12 c0 	mov    -0x3fedea20(,%eax,4),%eax
c01021d6:	c1 e8 10             	shr    $0x10,%eax
c01021d9:	0f b7 d0             	movzwl %ax,%edx
c01021dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021df:	66 89 14 c5 66 47 12 	mov    %dx,-0x3fedb89a(,%eax,8)
c01021e6:	c0 
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c01021e7:	ff 45 fc             	incl   -0x4(%ebp)
c01021ea:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01021ed:	3d ff 00 00 00       	cmp    $0xff,%eax
c01021f2:	0f 86 2e ff ff ff    	jbe    c0102126 <idt_init+0x12>
c01021f8:	c7 45 f8 60 15 12 c0 	movl   $0xc0121560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c01021ff:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0102202:	0f 01 18             	lidtl  (%eax)
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    lidt(&idt_pd);
}
c0102205:	90                   	nop
c0102206:	c9                   	leave  
c0102207:	c3                   	ret    

c0102208 <trapname>:

static const char *
trapname(int trapno) {
c0102208:	55                   	push   %ebp
c0102209:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c010220b:	8b 45 08             	mov    0x8(%ebp),%eax
c010220e:	83 f8 13             	cmp    $0x13,%eax
c0102211:	77 0c                	ja     c010221f <trapname+0x17>
        return excnames[trapno];
c0102213:	8b 45 08             	mov    0x8(%ebp),%eax
c0102216:	8b 04 85 20 9a 10 c0 	mov    -0x3fef65e0(,%eax,4),%eax
c010221d:	eb 18                	jmp    c0102237 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c010221f:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0102223:	7e 0d                	jle    c0102232 <trapname+0x2a>
c0102225:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0102229:	7f 07                	jg     c0102232 <trapname+0x2a>
        return "Hardware Interrupt";
c010222b:	b8 4a 96 10 c0       	mov    $0xc010964a,%eax
c0102230:	eb 05                	jmp    c0102237 <trapname+0x2f>
    }
    return "(unknown trap)";
c0102232:	b8 5d 96 10 c0       	mov    $0xc010965d,%eax
}
c0102237:	5d                   	pop    %ebp
c0102238:	c3                   	ret    

c0102239 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0102239:	55                   	push   %ebp
c010223a:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c010223c:	8b 45 08             	mov    0x8(%ebp),%eax
c010223f:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102243:	83 f8 08             	cmp    $0x8,%eax
c0102246:	0f 94 c0             	sete   %al
c0102249:	0f b6 c0             	movzbl %al,%eax
}
c010224c:	5d                   	pop    %ebp
c010224d:	c3                   	ret    

c010224e <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c010224e:	55                   	push   %ebp
c010224f:	89 e5                	mov    %esp,%ebp
c0102251:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0102254:	8b 45 08             	mov    0x8(%ebp),%eax
c0102257:	89 44 24 04          	mov    %eax,0x4(%esp)
c010225b:	c7 04 24 9e 96 10 c0 	movl   $0xc010969e,(%esp)
c0102262:	e8 3a e0 ff ff       	call   c01002a1 <cprintf>
    print_regs(&tf->tf_regs);
c0102267:	8b 45 08             	mov    0x8(%ebp),%eax
c010226a:	89 04 24             	mov    %eax,(%esp)
c010226d:	e8 91 01 00 00       	call   c0102403 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0102272:	8b 45 08             	mov    0x8(%ebp),%eax
c0102275:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0102279:	89 44 24 04          	mov    %eax,0x4(%esp)
c010227d:	c7 04 24 af 96 10 c0 	movl   $0xc01096af,(%esp)
c0102284:	e8 18 e0 ff ff       	call   c01002a1 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0102289:	8b 45 08             	mov    0x8(%ebp),%eax
c010228c:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0102290:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102294:	c7 04 24 c2 96 10 c0 	movl   $0xc01096c2,(%esp)
c010229b:	e8 01 e0 ff ff       	call   c01002a1 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c01022a0:	8b 45 08             	mov    0x8(%ebp),%eax
c01022a3:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c01022a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022ab:	c7 04 24 d5 96 10 c0 	movl   $0xc01096d5,(%esp)
c01022b2:	e8 ea df ff ff       	call   c01002a1 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c01022b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01022ba:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c01022be:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022c2:	c7 04 24 e8 96 10 c0 	movl   $0xc01096e8,(%esp)
c01022c9:	e8 d3 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c01022ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01022d1:	8b 40 30             	mov    0x30(%eax),%eax
c01022d4:	89 04 24             	mov    %eax,(%esp)
c01022d7:	e8 2c ff ff ff       	call   c0102208 <trapname>
c01022dc:	89 c2                	mov    %eax,%edx
c01022de:	8b 45 08             	mov    0x8(%ebp),%eax
c01022e1:	8b 40 30             	mov    0x30(%eax),%eax
c01022e4:	89 54 24 08          	mov    %edx,0x8(%esp)
c01022e8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01022ec:	c7 04 24 fb 96 10 c0 	movl   $0xc01096fb,(%esp)
c01022f3:	e8 a9 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c01022f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01022fb:	8b 40 34             	mov    0x34(%eax),%eax
c01022fe:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102302:	c7 04 24 0d 97 10 c0 	movl   $0xc010970d,(%esp)
c0102309:	e8 93 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c010230e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102311:	8b 40 38             	mov    0x38(%eax),%eax
c0102314:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102318:	c7 04 24 1c 97 10 c0 	movl   $0xc010971c,(%esp)
c010231f:	e8 7d df ff ff       	call   c01002a1 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0102324:	8b 45 08             	mov    0x8(%ebp),%eax
c0102327:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c010232b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010232f:	c7 04 24 2b 97 10 c0 	movl   $0xc010972b,(%esp)
c0102336:	e8 66 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c010233b:	8b 45 08             	mov    0x8(%ebp),%eax
c010233e:	8b 40 40             	mov    0x40(%eax),%eax
c0102341:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102345:	c7 04 24 3e 97 10 c0 	movl   $0xc010973e,(%esp)
c010234c:	e8 50 df ff ff       	call   c01002a1 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102351:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0102358:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c010235f:	eb 3d                	jmp    c010239e <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0102361:	8b 45 08             	mov    0x8(%ebp),%eax
c0102364:	8b 50 40             	mov    0x40(%eax),%edx
c0102367:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010236a:	21 d0                	and    %edx,%eax
c010236c:	85 c0                	test   %eax,%eax
c010236e:	74 28                	je     c0102398 <print_trapframe+0x14a>
c0102370:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102373:	8b 04 85 80 15 12 c0 	mov    -0x3fedea80(,%eax,4),%eax
c010237a:	85 c0                	test   %eax,%eax
c010237c:	74 1a                	je     c0102398 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c010237e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102381:	8b 04 85 80 15 12 c0 	mov    -0x3fedea80(,%eax,4),%eax
c0102388:	89 44 24 04          	mov    %eax,0x4(%esp)
c010238c:	c7 04 24 4d 97 10 c0 	movl   $0xc010974d,(%esp)
c0102393:	e8 09 df ff ff       	call   c01002a1 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0102398:	ff 45 f4             	incl   -0xc(%ebp)
c010239b:	d1 65 f0             	shll   -0x10(%ebp)
c010239e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01023a1:	83 f8 17             	cmp    $0x17,%eax
c01023a4:	76 bb                	jbe    c0102361 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c01023a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01023a9:	8b 40 40             	mov    0x40(%eax),%eax
c01023ac:	25 00 30 00 00       	and    $0x3000,%eax
c01023b1:	c1 e8 0c             	shr    $0xc,%eax
c01023b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023b8:	c7 04 24 51 97 10 c0 	movl   $0xc0109751,(%esp)
c01023bf:	e8 dd de ff ff       	call   c01002a1 <cprintf>

    if (!trap_in_kernel(tf)) {
c01023c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01023c7:	89 04 24             	mov    %eax,(%esp)
c01023ca:	e8 6a fe ff ff       	call   c0102239 <trap_in_kernel>
c01023cf:	85 c0                	test   %eax,%eax
c01023d1:	75 2d                	jne    c0102400 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c01023d3:	8b 45 08             	mov    0x8(%ebp),%eax
c01023d6:	8b 40 44             	mov    0x44(%eax),%eax
c01023d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023dd:	c7 04 24 5a 97 10 c0 	movl   $0xc010975a,(%esp)
c01023e4:	e8 b8 de ff ff       	call   c01002a1 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c01023e9:	8b 45 08             	mov    0x8(%ebp),%eax
c01023ec:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c01023f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01023f4:	c7 04 24 69 97 10 c0 	movl   $0xc0109769,(%esp)
c01023fb:	e8 a1 de ff ff       	call   c01002a1 <cprintf>
    }
}
c0102400:	90                   	nop
c0102401:	c9                   	leave  
c0102402:	c3                   	ret    

c0102403 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0102403:	55                   	push   %ebp
c0102404:	89 e5                	mov    %esp,%ebp
c0102406:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0102409:	8b 45 08             	mov    0x8(%ebp),%eax
c010240c:	8b 00                	mov    (%eax),%eax
c010240e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102412:	c7 04 24 7c 97 10 c0 	movl   $0xc010977c,(%esp)
c0102419:	e8 83 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c010241e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102421:	8b 40 04             	mov    0x4(%eax),%eax
c0102424:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102428:	c7 04 24 8b 97 10 c0 	movl   $0xc010978b,(%esp)
c010242f:	e8 6d de ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0102434:	8b 45 08             	mov    0x8(%ebp),%eax
c0102437:	8b 40 08             	mov    0x8(%eax),%eax
c010243a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010243e:	c7 04 24 9a 97 10 c0 	movl   $0xc010979a,(%esp)
c0102445:	e8 57 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c010244a:	8b 45 08             	mov    0x8(%ebp),%eax
c010244d:	8b 40 0c             	mov    0xc(%eax),%eax
c0102450:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102454:	c7 04 24 a9 97 10 c0 	movl   $0xc01097a9,(%esp)
c010245b:	e8 41 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0102460:	8b 45 08             	mov    0x8(%ebp),%eax
c0102463:	8b 40 10             	mov    0x10(%eax),%eax
c0102466:	89 44 24 04          	mov    %eax,0x4(%esp)
c010246a:	c7 04 24 b8 97 10 c0 	movl   $0xc01097b8,(%esp)
c0102471:	e8 2b de ff ff       	call   c01002a1 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0102476:	8b 45 08             	mov    0x8(%ebp),%eax
c0102479:	8b 40 14             	mov    0x14(%eax),%eax
c010247c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102480:	c7 04 24 c7 97 10 c0 	movl   $0xc01097c7,(%esp)
c0102487:	e8 15 de ff ff       	call   c01002a1 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c010248c:	8b 45 08             	mov    0x8(%ebp),%eax
c010248f:	8b 40 18             	mov    0x18(%eax),%eax
c0102492:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102496:	c7 04 24 d6 97 10 c0 	movl   $0xc01097d6,(%esp)
c010249d:	e8 ff dd ff ff       	call   c01002a1 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c01024a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024a5:	8b 40 1c             	mov    0x1c(%eax),%eax
c01024a8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01024ac:	c7 04 24 e5 97 10 c0 	movl   $0xc01097e5,(%esp)
c01024b3:	e8 e9 dd ff ff       	call   c01002a1 <cprintf>
}
c01024b8:	90                   	nop
c01024b9:	c9                   	leave  
c01024ba:	c3                   	ret    

c01024bb <print_pgfault>:

static inline void
print_pgfault(struct trapframe *tf) {
c01024bb:	55                   	push   %ebp
c01024bc:	89 e5                	mov    %esp,%ebp
c01024be:	53                   	push   %ebx
c01024bf:	83 ec 34             	sub    $0x34,%esp
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
c01024c2:	8b 45 08             	mov    0x8(%ebp),%eax
c01024c5:	8b 40 34             	mov    0x34(%eax),%eax
c01024c8:	83 e0 01             	and    $0x1,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024cb:	85 c0                	test   %eax,%eax
c01024cd:	74 07                	je     c01024d6 <print_pgfault+0x1b>
c01024cf:	bb f4 97 10 c0       	mov    $0xc01097f4,%ebx
c01024d4:	eb 05                	jmp    c01024db <print_pgfault+0x20>
c01024d6:	bb 05 98 10 c0       	mov    $0xc0109805,%ebx
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
c01024db:	8b 45 08             	mov    0x8(%ebp),%eax
c01024de:	8b 40 34             	mov    0x34(%eax),%eax
c01024e1:	83 e0 02             	and    $0x2,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024e4:	85 c0                	test   %eax,%eax
c01024e6:	74 07                	je     c01024ef <print_pgfault+0x34>
c01024e8:	b9 57 00 00 00       	mov    $0x57,%ecx
c01024ed:	eb 05                	jmp    c01024f4 <print_pgfault+0x39>
c01024ef:	b9 52 00 00 00       	mov    $0x52,%ecx
            (tf->tf_err & 4) ? 'U' : 'K',
c01024f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01024f7:	8b 40 34             	mov    0x34(%eax),%eax
c01024fa:	83 e0 04             	and    $0x4,%eax
    /* error_code:
     * bit 0 == 0 means no page found, 1 means protection fault
     * bit 1 == 0 means read, 1 means write
     * bit 2 == 0 means kernel, 1 means user
     * */
    cprintf("page fault at 0x%08x: %c/%c [%s].\n", rcr2(),
c01024fd:	85 c0                	test   %eax,%eax
c01024ff:	74 07                	je     c0102508 <print_pgfault+0x4d>
c0102501:	ba 55 00 00 00       	mov    $0x55,%edx
c0102506:	eb 05                	jmp    c010250d <print_pgfault+0x52>
c0102508:	ba 4b 00 00 00       	mov    $0x4b,%edx
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c010250d:	0f 20 d0             	mov    %cr2,%eax
c0102510:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102513:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102516:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c010251a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c010251e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0102522:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102526:	c7 04 24 14 98 10 c0 	movl   $0xc0109814,(%esp)
c010252d:	e8 6f dd ff ff       	call   c01002a1 <cprintf>
            (tf->tf_err & 4) ? 'U' : 'K',
            (tf->tf_err & 2) ? 'W' : 'R',
            (tf->tf_err & 1) ? "protection fault" : "no page found");
}
c0102532:	90                   	nop
c0102533:	83 c4 34             	add    $0x34,%esp
c0102536:	5b                   	pop    %ebx
c0102537:	5d                   	pop    %ebp
c0102538:	c3                   	ret    

c0102539 <pgfault_handler>:

static int
pgfault_handler(struct trapframe *tf) {
c0102539:	55                   	push   %ebp
c010253a:	89 e5                	mov    %esp,%ebp
c010253c:	83 ec 28             	sub    $0x28,%esp
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
c010253f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102542:	89 04 24             	mov    %eax,(%esp)
c0102545:	e8 71 ff ff ff       	call   c01024bb <print_pgfault>
    if (check_mm_struct != NULL) {
c010254a:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c010254f:	85 c0                	test   %eax,%eax
c0102551:	74 26                	je     c0102579 <pgfault_handler+0x40>
}

static inline uintptr_t
rcr2(void) {
    uintptr_t cr2;
    asm volatile ("mov %%cr2, %0" : "=r" (cr2) :: "memory");
c0102553:	0f 20 d0             	mov    %cr2,%eax
c0102556:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return cr2;
c0102559:	8b 4d f4             	mov    -0xc(%ebp),%ecx
        return do_pgfault(check_mm_struct, tf->tf_err, rcr2());
c010255c:	8b 45 08             	mov    0x8(%ebp),%eax
c010255f:	8b 50 34             	mov    0x34(%eax),%edx
c0102562:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c0102567:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c010256b:	89 54 24 04          	mov    %edx,0x4(%esp)
c010256f:	89 04 24             	mov    %eax,(%esp)
c0102572:	e8 ff 33 00 00       	call   c0105976 <do_pgfault>
c0102577:	eb 1c                	jmp    c0102595 <pgfault_handler+0x5c>
    }
    panic("unhandled page fault.\n");
c0102579:	c7 44 24 08 37 98 10 	movl   $0xc0109837,0x8(%esp)
c0102580:	c0 
c0102581:	c7 44 24 04 a5 00 00 	movl   $0xa5,0x4(%esp)
c0102588:	00 
c0102589:	c7 04 24 4e 98 10 c0 	movl   $0xc010984e,(%esp)
c0102590:	e8 63 de ff ff       	call   c01003f8 <__panic>
}
c0102595:	c9                   	leave  
c0102596:	c3                   	ret    

c0102597 <trap_dispatch>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

static void
trap_dispatch(struct trapframe *tf) {
c0102597:	55                   	push   %ebp
c0102598:	89 e5                	mov    %esp,%ebp
c010259a:	83 ec 28             	sub    $0x28,%esp
    char c;

    int ret;

    switch (tf->tf_trapno) {
c010259d:	8b 45 08             	mov    0x8(%ebp),%eax
c01025a0:	8b 40 30             	mov    0x30(%eax),%eax
c01025a3:	83 f8 24             	cmp    $0x24,%eax
c01025a6:	0f 84 cc 00 00 00    	je     c0102678 <trap_dispatch+0xe1>
c01025ac:	83 f8 24             	cmp    $0x24,%eax
c01025af:	77 18                	ja     c01025c9 <trap_dispatch+0x32>
c01025b1:	83 f8 20             	cmp    $0x20,%eax
c01025b4:	74 7c                	je     c0102632 <trap_dispatch+0x9b>
c01025b6:	83 f8 21             	cmp    $0x21,%eax
c01025b9:	0f 84 df 00 00 00    	je     c010269e <trap_dispatch+0x107>
c01025bf:	83 f8 0e             	cmp    $0xe,%eax
c01025c2:	74 28                	je     c01025ec <trap_dispatch+0x55>
c01025c4:	e9 17 01 00 00       	jmp    c01026e0 <trap_dispatch+0x149>
c01025c9:	83 f8 2e             	cmp    $0x2e,%eax
c01025cc:	0f 82 0e 01 00 00    	jb     c01026e0 <trap_dispatch+0x149>
c01025d2:	83 f8 2f             	cmp    $0x2f,%eax
c01025d5:	0f 86 3a 01 00 00    	jbe    c0102715 <trap_dispatch+0x17e>
c01025db:	83 e8 78             	sub    $0x78,%eax
c01025de:	83 f8 01             	cmp    $0x1,%eax
c01025e1:	0f 87 f9 00 00 00    	ja     c01026e0 <trap_dispatch+0x149>
c01025e7:	e9 d8 00 00 00       	jmp    c01026c4 <trap_dispatch+0x12d>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
c01025ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01025ef:	89 04 24             	mov    %eax,(%esp)
c01025f2:	e8 42 ff ff ff       	call   c0102539 <pgfault_handler>
c01025f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01025fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01025fe:	0f 84 14 01 00 00    	je     c0102718 <trap_dispatch+0x181>
            print_trapframe(tf);
c0102604:	8b 45 08             	mov    0x8(%ebp),%eax
c0102607:	89 04 24             	mov    %eax,(%esp)
c010260a:	e8 3f fc ff ff       	call   c010224e <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
c010260f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102612:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102616:	c7 44 24 08 5f 98 10 	movl   $0xc010985f,0x8(%esp)
c010261d:	c0 
c010261e:	c7 44 24 04 b5 00 00 	movl   $0xb5,0x4(%esp)
c0102625:	00 
c0102626:	c7 04 24 4e 98 10 c0 	movl   $0xc010984e,(%esp)
c010262d:	e8 c6 dd ff ff       	call   c01003f8 <__panic>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0102632:	a1 1c 50 12 c0       	mov    0xc012501c,%eax
c0102637:	40                   	inc    %eax
c0102638:	a3 1c 50 12 c0       	mov    %eax,0xc012501c
        if (ticks % TICK_NUM == 0) {
c010263d:	8b 0d 1c 50 12 c0    	mov    0xc012501c,%ecx
c0102643:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0102648:	89 c8                	mov    %ecx,%eax
c010264a:	f7 e2                	mul    %edx
c010264c:	c1 ea 05             	shr    $0x5,%edx
c010264f:	89 d0                	mov    %edx,%eax
c0102651:	c1 e0 02             	shl    $0x2,%eax
c0102654:	01 d0                	add    %edx,%eax
c0102656:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010265d:	01 d0                	add    %edx,%eax
c010265f:	c1 e0 02             	shl    $0x2,%eax
c0102662:	29 c1                	sub    %eax,%ecx
c0102664:	89 ca                	mov    %ecx,%edx
c0102666:	85 d2                	test   %edx,%edx
c0102668:	0f 85 ad 00 00 00    	jne    c010271b <trap_dispatch+0x184>
            print_ticks();
c010266e:	e8 84 fa ff ff       	call   c01020f7 <print_ticks>
        }
        break;
c0102673:	e9 a3 00 00 00       	jmp    c010271b <trap_dispatch+0x184>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0102678:	e8 3f f8 ff ff       	call   c0101ebc <cons_getc>
c010267d:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0102680:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c0102684:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c0102688:	89 54 24 08          	mov    %edx,0x8(%esp)
c010268c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102690:	c7 04 24 7a 98 10 c0 	movl   $0xc010987a,(%esp)
c0102697:	e8 05 dc ff ff       	call   c01002a1 <cprintf>
        break;
c010269c:	eb 7e                	jmp    c010271c <trap_dispatch+0x185>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c010269e:	e8 19 f8 ff ff       	call   c0101ebc <cons_getc>
c01026a3:	88 45 f3             	mov    %al,-0xd(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c01026a6:	0f be 55 f3          	movsbl -0xd(%ebp),%edx
c01026aa:	0f be 45 f3          	movsbl -0xd(%ebp),%eax
c01026ae:	89 54 24 08          	mov    %edx,0x8(%esp)
c01026b2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01026b6:	c7 04 24 8c 98 10 c0 	movl   $0xc010988c,(%esp)
c01026bd:	e8 df db ff ff       	call   c01002a1 <cprintf>
        break;
c01026c2:	eb 58                	jmp    c010271c <trap_dispatch+0x185>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
    case T_SWITCH_TOK:
        panic("T_SWITCH_** ??\n");
c01026c4:	c7 44 24 08 9b 98 10 	movl   $0xc010989b,0x8(%esp)
c01026cb:	c0 
c01026cc:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c01026d3:	00 
c01026d4:	c7 04 24 4e 98 10 c0 	movl   $0xc010984e,(%esp)
c01026db:	e8 18 dd ff ff       	call   c01003f8 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c01026e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01026e3:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01026e7:	83 e0 03             	and    $0x3,%eax
c01026ea:	85 c0                	test   %eax,%eax
c01026ec:	75 2e                	jne    c010271c <trap_dispatch+0x185>
            print_trapframe(tf);
c01026ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01026f1:	89 04 24             	mov    %eax,(%esp)
c01026f4:	e8 55 fb ff ff       	call   c010224e <print_trapframe>
            panic("unexpected trap in kernel.\n");
c01026f9:	c7 44 24 08 ab 98 10 	movl   $0xc01098ab,0x8(%esp)
c0102700:	c0 
c0102701:	c7 44 24 04 dd 00 00 	movl   $0xdd,0x4(%esp)
c0102708:	00 
c0102709:	c7 04 24 4e 98 10 c0 	movl   $0xc010984e,(%esp)
c0102710:	e8 e3 dc ff ff       	call   c01003f8 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102715:	90                   	nop
c0102716:	eb 04                	jmp    c010271c <trap_dispatch+0x185>
    case T_PGFLT:  //page fault
        if ((ret = pgfault_handler(tf)) != 0) {
            print_trapframe(tf);
            panic("handle pgfault failed. %e\n", ret);
        }
        break;
c0102718:	90                   	nop
c0102719:	eb 01                	jmp    c010271c <trap_dispatch+0x185>
         */
        ticks ++;
        if (ticks % TICK_NUM == 0) {
            print_ticks();
        }
        break;
c010271b:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c010271c:	90                   	nop
c010271d:	c9                   	leave  
c010271e:	c3                   	ret    

c010271f <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c010271f:	55                   	push   %ebp
c0102720:	89 e5                	mov    %esp,%ebp
c0102722:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0102725:	8b 45 08             	mov    0x8(%ebp),%eax
c0102728:	89 04 24             	mov    %eax,(%esp)
c010272b:	e8 67 fe ff ff       	call   c0102597 <trap_dispatch>
}
c0102730:	90                   	nop
c0102731:	c9                   	leave  
c0102732:	c3                   	ret    

c0102733 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c0102733:	6a 00                	push   $0x0
  pushl $0
c0102735:	6a 00                	push   $0x0
  jmp __alltraps
c0102737:	e9 69 0a 00 00       	jmp    c01031a5 <__alltraps>

c010273c <vector1>:
.globl vector1
vector1:
  pushl $0
c010273c:	6a 00                	push   $0x0
  pushl $1
c010273e:	6a 01                	push   $0x1
  jmp __alltraps
c0102740:	e9 60 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102745 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102745:	6a 00                	push   $0x0
  pushl $2
c0102747:	6a 02                	push   $0x2
  jmp __alltraps
c0102749:	e9 57 0a 00 00       	jmp    c01031a5 <__alltraps>

c010274e <vector3>:
.globl vector3
vector3:
  pushl $0
c010274e:	6a 00                	push   $0x0
  pushl $3
c0102750:	6a 03                	push   $0x3
  jmp __alltraps
c0102752:	e9 4e 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102757 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102757:	6a 00                	push   $0x0
  pushl $4
c0102759:	6a 04                	push   $0x4
  jmp __alltraps
c010275b:	e9 45 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102760 <vector5>:
.globl vector5
vector5:
  pushl $0
c0102760:	6a 00                	push   $0x0
  pushl $5
c0102762:	6a 05                	push   $0x5
  jmp __alltraps
c0102764:	e9 3c 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102769 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102769:	6a 00                	push   $0x0
  pushl $6
c010276b:	6a 06                	push   $0x6
  jmp __alltraps
c010276d:	e9 33 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102772 <vector7>:
.globl vector7
vector7:
  pushl $0
c0102772:	6a 00                	push   $0x0
  pushl $7
c0102774:	6a 07                	push   $0x7
  jmp __alltraps
c0102776:	e9 2a 0a 00 00       	jmp    c01031a5 <__alltraps>

c010277b <vector8>:
.globl vector8
vector8:
  pushl $8
c010277b:	6a 08                	push   $0x8
  jmp __alltraps
c010277d:	e9 23 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102782 <vector9>:
.globl vector9
vector9:
  pushl $0
c0102782:	6a 00                	push   $0x0
  pushl $9
c0102784:	6a 09                	push   $0x9
  jmp __alltraps
c0102786:	e9 1a 0a 00 00       	jmp    c01031a5 <__alltraps>

c010278b <vector10>:
.globl vector10
vector10:
  pushl $10
c010278b:	6a 0a                	push   $0xa
  jmp __alltraps
c010278d:	e9 13 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102792 <vector11>:
.globl vector11
vector11:
  pushl $11
c0102792:	6a 0b                	push   $0xb
  jmp __alltraps
c0102794:	e9 0c 0a 00 00       	jmp    c01031a5 <__alltraps>

c0102799 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102799:	6a 0c                	push   $0xc
  jmp __alltraps
c010279b:	e9 05 0a 00 00       	jmp    c01031a5 <__alltraps>

c01027a0 <vector13>:
.globl vector13
vector13:
  pushl $13
c01027a0:	6a 0d                	push   $0xd
  jmp __alltraps
c01027a2:	e9 fe 09 00 00       	jmp    c01031a5 <__alltraps>

c01027a7 <vector14>:
.globl vector14
vector14:
  pushl $14
c01027a7:	6a 0e                	push   $0xe
  jmp __alltraps
c01027a9:	e9 f7 09 00 00       	jmp    c01031a5 <__alltraps>

c01027ae <vector15>:
.globl vector15
vector15:
  pushl $0
c01027ae:	6a 00                	push   $0x0
  pushl $15
c01027b0:	6a 0f                	push   $0xf
  jmp __alltraps
c01027b2:	e9 ee 09 00 00       	jmp    c01031a5 <__alltraps>

c01027b7 <vector16>:
.globl vector16
vector16:
  pushl $0
c01027b7:	6a 00                	push   $0x0
  pushl $16
c01027b9:	6a 10                	push   $0x10
  jmp __alltraps
c01027bb:	e9 e5 09 00 00       	jmp    c01031a5 <__alltraps>

c01027c0 <vector17>:
.globl vector17
vector17:
  pushl $17
c01027c0:	6a 11                	push   $0x11
  jmp __alltraps
c01027c2:	e9 de 09 00 00       	jmp    c01031a5 <__alltraps>

c01027c7 <vector18>:
.globl vector18
vector18:
  pushl $0
c01027c7:	6a 00                	push   $0x0
  pushl $18
c01027c9:	6a 12                	push   $0x12
  jmp __alltraps
c01027cb:	e9 d5 09 00 00       	jmp    c01031a5 <__alltraps>

c01027d0 <vector19>:
.globl vector19
vector19:
  pushl $0
c01027d0:	6a 00                	push   $0x0
  pushl $19
c01027d2:	6a 13                	push   $0x13
  jmp __alltraps
c01027d4:	e9 cc 09 00 00       	jmp    c01031a5 <__alltraps>

c01027d9 <vector20>:
.globl vector20
vector20:
  pushl $0
c01027d9:	6a 00                	push   $0x0
  pushl $20
c01027db:	6a 14                	push   $0x14
  jmp __alltraps
c01027dd:	e9 c3 09 00 00       	jmp    c01031a5 <__alltraps>

c01027e2 <vector21>:
.globl vector21
vector21:
  pushl $0
c01027e2:	6a 00                	push   $0x0
  pushl $21
c01027e4:	6a 15                	push   $0x15
  jmp __alltraps
c01027e6:	e9 ba 09 00 00       	jmp    c01031a5 <__alltraps>

c01027eb <vector22>:
.globl vector22
vector22:
  pushl $0
c01027eb:	6a 00                	push   $0x0
  pushl $22
c01027ed:	6a 16                	push   $0x16
  jmp __alltraps
c01027ef:	e9 b1 09 00 00       	jmp    c01031a5 <__alltraps>

c01027f4 <vector23>:
.globl vector23
vector23:
  pushl $0
c01027f4:	6a 00                	push   $0x0
  pushl $23
c01027f6:	6a 17                	push   $0x17
  jmp __alltraps
c01027f8:	e9 a8 09 00 00       	jmp    c01031a5 <__alltraps>

c01027fd <vector24>:
.globl vector24
vector24:
  pushl $0
c01027fd:	6a 00                	push   $0x0
  pushl $24
c01027ff:	6a 18                	push   $0x18
  jmp __alltraps
c0102801:	e9 9f 09 00 00       	jmp    c01031a5 <__alltraps>

c0102806 <vector25>:
.globl vector25
vector25:
  pushl $0
c0102806:	6a 00                	push   $0x0
  pushl $25
c0102808:	6a 19                	push   $0x19
  jmp __alltraps
c010280a:	e9 96 09 00 00       	jmp    c01031a5 <__alltraps>

c010280f <vector26>:
.globl vector26
vector26:
  pushl $0
c010280f:	6a 00                	push   $0x0
  pushl $26
c0102811:	6a 1a                	push   $0x1a
  jmp __alltraps
c0102813:	e9 8d 09 00 00       	jmp    c01031a5 <__alltraps>

c0102818 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102818:	6a 00                	push   $0x0
  pushl $27
c010281a:	6a 1b                	push   $0x1b
  jmp __alltraps
c010281c:	e9 84 09 00 00       	jmp    c01031a5 <__alltraps>

c0102821 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102821:	6a 00                	push   $0x0
  pushl $28
c0102823:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102825:	e9 7b 09 00 00       	jmp    c01031a5 <__alltraps>

c010282a <vector29>:
.globl vector29
vector29:
  pushl $0
c010282a:	6a 00                	push   $0x0
  pushl $29
c010282c:	6a 1d                	push   $0x1d
  jmp __alltraps
c010282e:	e9 72 09 00 00       	jmp    c01031a5 <__alltraps>

c0102833 <vector30>:
.globl vector30
vector30:
  pushl $0
c0102833:	6a 00                	push   $0x0
  pushl $30
c0102835:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102837:	e9 69 09 00 00       	jmp    c01031a5 <__alltraps>

c010283c <vector31>:
.globl vector31
vector31:
  pushl $0
c010283c:	6a 00                	push   $0x0
  pushl $31
c010283e:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102840:	e9 60 09 00 00       	jmp    c01031a5 <__alltraps>

c0102845 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102845:	6a 00                	push   $0x0
  pushl $32
c0102847:	6a 20                	push   $0x20
  jmp __alltraps
c0102849:	e9 57 09 00 00       	jmp    c01031a5 <__alltraps>

c010284e <vector33>:
.globl vector33
vector33:
  pushl $0
c010284e:	6a 00                	push   $0x0
  pushl $33
c0102850:	6a 21                	push   $0x21
  jmp __alltraps
c0102852:	e9 4e 09 00 00       	jmp    c01031a5 <__alltraps>

c0102857 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102857:	6a 00                	push   $0x0
  pushl $34
c0102859:	6a 22                	push   $0x22
  jmp __alltraps
c010285b:	e9 45 09 00 00       	jmp    c01031a5 <__alltraps>

c0102860 <vector35>:
.globl vector35
vector35:
  pushl $0
c0102860:	6a 00                	push   $0x0
  pushl $35
c0102862:	6a 23                	push   $0x23
  jmp __alltraps
c0102864:	e9 3c 09 00 00       	jmp    c01031a5 <__alltraps>

c0102869 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102869:	6a 00                	push   $0x0
  pushl $36
c010286b:	6a 24                	push   $0x24
  jmp __alltraps
c010286d:	e9 33 09 00 00       	jmp    c01031a5 <__alltraps>

c0102872 <vector37>:
.globl vector37
vector37:
  pushl $0
c0102872:	6a 00                	push   $0x0
  pushl $37
c0102874:	6a 25                	push   $0x25
  jmp __alltraps
c0102876:	e9 2a 09 00 00       	jmp    c01031a5 <__alltraps>

c010287b <vector38>:
.globl vector38
vector38:
  pushl $0
c010287b:	6a 00                	push   $0x0
  pushl $38
c010287d:	6a 26                	push   $0x26
  jmp __alltraps
c010287f:	e9 21 09 00 00       	jmp    c01031a5 <__alltraps>

c0102884 <vector39>:
.globl vector39
vector39:
  pushl $0
c0102884:	6a 00                	push   $0x0
  pushl $39
c0102886:	6a 27                	push   $0x27
  jmp __alltraps
c0102888:	e9 18 09 00 00       	jmp    c01031a5 <__alltraps>

c010288d <vector40>:
.globl vector40
vector40:
  pushl $0
c010288d:	6a 00                	push   $0x0
  pushl $40
c010288f:	6a 28                	push   $0x28
  jmp __alltraps
c0102891:	e9 0f 09 00 00       	jmp    c01031a5 <__alltraps>

c0102896 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102896:	6a 00                	push   $0x0
  pushl $41
c0102898:	6a 29                	push   $0x29
  jmp __alltraps
c010289a:	e9 06 09 00 00       	jmp    c01031a5 <__alltraps>

c010289f <vector42>:
.globl vector42
vector42:
  pushl $0
c010289f:	6a 00                	push   $0x0
  pushl $42
c01028a1:	6a 2a                	push   $0x2a
  jmp __alltraps
c01028a3:	e9 fd 08 00 00       	jmp    c01031a5 <__alltraps>

c01028a8 <vector43>:
.globl vector43
vector43:
  pushl $0
c01028a8:	6a 00                	push   $0x0
  pushl $43
c01028aa:	6a 2b                	push   $0x2b
  jmp __alltraps
c01028ac:	e9 f4 08 00 00       	jmp    c01031a5 <__alltraps>

c01028b1 <vector44>:
.globl vector44
vector44:
  pushl $0
c01028b1:	6a 00                	push   $0x0
  pushl $44
c01028b3:	6a 2c                	push   $0x2c
  jmp __alltraps
c01028b5:	e9 eb 08 00 00       	jmp    c01031a5 <__alltraps>

c01028ba <vector45>:
.globl vector45
vector45:
  pushl $0
c01028ba:	6a 00                	push   $0x0
  pushl $45
c01028bc:	6a 2d                	push   $0x2d
  jmp __alltraps
c01028be:	e9 e2 08 00 00       	jmp    c01031a5 <__alltraps>

c01028c3 <vector46>:
.globl vector46
vector46:
  pushl $0
c01028c3:	6a 00                	push   $0x0
  pushl $46
c01028c5:	6a 2e                	push   $0x2e
  jmp __alltraps
c01028c7:	e9 d9 08 00 00       	jmp    c01031a5 <__alltraps>

c01028cc <vector47>:
.globl vector47
vector47:
  pushl $0
c01028cc:	6a 00                	push   $0x0
  pushl $47
c01028ce:	6a 2f                	push   $0x2f
  jmp __alltraps
c01028d0:	e9 d0 08 00 00       	jmp    c01031a5 <__alltraps>

c01028d5 <vector48>:
.globl vector48
vector48:
  pushl $0
c01028d5:	6a 00                	push   $0x0
  pushl $48
c01028d7:	6a 30                	push   $0x30
  jmp __alltraps
c01028d9:	e9 c7 08 00 00       	jmp    c01031a5 <__alltraps>

c01028de <vector49>:
.globl vector49
vector49:
  pushl $0
c01028de:	6a 00                	push   $0x0
  pushl $49
c01028e0:	6a 31                	push   $0x31
  jmp __alltraps
c01028e2:	e9 be 08 00 00       	jmp    c01031a5 <__alltraps>

c01028e7 <vector50>:
.globl vector50
vector50:
  pushl $0
c01028e7:	6a 00                	push   $0x0
  pushl $50
c01028e9:	6a 32                	push   $0x32
  jmp __alltraps
c01028eb:	e9 b5 08 00 00       	jmp    c01031a5 <__alltraps>

c01028f0 <vector51>:
.globl vector51
vector51:
  pushl $0
c01028f0:	6a 00                	push   $0x0
  pushl $51
c01028f2:	6a 33                	push   $0x33
  jmp __alltraps
c01028f4:	e9 ac 08 00 00       	jmp    c01031a5 <__alltraps>

c01028f9 <vector52>:
.globl vector52
vector52:
  pushl $0
c01028f9:	6a 00                	push   $0x0
  pushl $52
c01028fb:	6a 34                	push   $0x34
  jmp __alltraps
c01028fd:	e9 a3 08 00 00       	jmp    c01031a5 <__alltraps>

c0102902 <vector53>:
.globl vector53
vector53:
  pushl $0
c0102902:	6a 00                	push   $0x0
  pushl $53
c0102904:	6a 35                	push   $0x35
  jmp __alltraps
c0102906:	e9 9a 08 00 00       	jmp    c01031a5 <__alltraps>

c010290b <vector54>:
.globl vector54
vector54:
  pushl $0
c010290b:	6a 00                	push   $0x0
  pushl $54
c010290d:	6a 36                	push   $0x36
  jmp __alltraps
c010290f:	e9 91 08 00 00       	jmp    c01031a5 <__alltraps>

c0102914 <vector55>:
.globl vector55
vector55:
  pushl $0
c0102914:	6a 00                	push   $0x0
  pushl $55
c0102916:	6a 37                	push   $0x37
  jmp __alltraps
c0102918:	e9 88 08 00 00       	jmp    c01031a5 <__alltraps>

c010291d <vector56>:
.globl vector56
vector56:
  pushl $0
c010291d:	6a 00                	push   $0x0
  pushl $56
c010291f:	6a 38                	push   $0x38
  jmp __alltraps
c0102921:	e9 7f 08 00 00       	jmp    c01031a5 <__alltraps>

c0102926 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102926:	6a 00                	push   $0x0
  pushl $57
c0102928:	6a 39                	push   $0x39
  jmp __alltraps
c010292a:	e9 76 08 00 00       	jmp    c01031a5 <__alltraps>

c010292f <vector58>:
.globl vector58
vector58:
  pushl $0
c010292f:	6a 00                	push   $0x0
  pushl $58
c0102931:	6a 3a                	push   $0x3a
  jmp __alltraps
c0102933:	e9 6d 08 00 00       	jmp    c01031a5 <__alltraps>

c0102938 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102938:	6a 00                	push   $0x0
  pushl $59
c010293a:	6a 3b                	push   $0x3b
  jmp __alltraps
c010293c:	e9 64 08 00 00       	jmp    c01031a5 <__alltraps>

c0102941 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102941:	6a 00                	push   $0x0
  pushl $60
c0102943:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102945:	e9 5b 08 00 00       	jmp    c01031a5 <__alltraps>

c010294a <vector61>:
.globl vector61
vector61:
  pushl $0
c010294a:	6a 00                	push   $0x0
  pushl $61
c010294c:	6a 3d                	push   $0x3d
  jmp __alltraps
c010294e:	e9 52 08 00 00       	jmp    c01031a5 <__alltraps>

c0102953 <vector62>:
.globl vector62
vector62:
  pushl $0
c0102953:	6a 00                	push   $0x0
  pushl $62
c0102955:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102957:	e9 49 08 00 00       	jmp    c01031a5 <__alltraps>

c010295c <vector63>:
.globl vector63
vector63:
  pushl $0
c010295c:	6a 00                	push   $0x0
  pushl $63
c010295e:	6a 3f                	push   $0x3f
  jmp __alltraps
c0102960:	e9 40 08 00 00       	jmp    c01031a5 <__alltraps>

c0102965 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102965:	6a 00                	push   $0x0
  pushl $64
c0102967:	6a 40                	push   $0x40
  jmp __alltraps
c0102969:	e9 37 08 00 00       	jmp    c01031a5 <__alltraps>

c010296e <vector65>:
.globl vector65
vector65:
  pushl $0
c010296e:	6a 00                	push   $0x0
  pushl $65
c0102970:	6a 41                	push   $0x41
  jmp __alltraps
c0102972:	e9 2e 08 00 00       	jmp    c01031a5 <__alltraps>

c0102977 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102977:	6a 00                	push   $0x0
  pushl $66
c0102979:	6a 42                	push   $0x42
  jmp __alltraps
c010297b:	e9 25 08 00 00       	jmp    c01031a5 <__alltraps>

c0102980 <vector67>:
.globl vector67
vector67:
  pushl $0
c0102980:	6a 00                	push   $0x0
  pushl $67
c0102982:	6a 43                	push   $0x43
  jmp __alltraps
c0102984:	e9 1c 08 00 00       	jmp    c01031a5 <__alltraps>

c0102989 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102989:	6a 00                	push   $0x0
  pushl $68
c010298b:	6a 44                	push   $0x44
  jmp __alltraps
c010298d:	e9 13 08 00 00       	jmp    c01031a5 <__alltraps>

c0102992 <vector69>:
.globl vector69
vector69:
  pushl $0
c0102992:	6a 00                	push   $0x0
  pushl $69
c0102994:	6a 45                	push   $0x45
  jmp __alltraps
c0102996:	e9 0a 08 00 00       	jmp    c01031a5 <__alltraps>

c010299b <vector70>:
.globl vector70
vector70:
  pushl $0
c010299b:	6a 00                	push   $0x0
  pushl $70
c010299d:	6a 46                	push   $0x46
  jmp __alltraps
c010299f:	e9 01 08 00 00       	jmp    c01031a5 <__alltraps>

c01029a4 <vector71>:
.globl vector71
vector71:
  pushl $0
c01029a4:	6a 00                	push   $0x0
  pushl $71
c01029a6:	6a 47                	push   $0x47
  jmp __alltraps
c01029a8:	e9 f8 07 00 00       	jmp    c01031a5 <__alltraps>

c01029ad <vector72>:
.globl vector72
vector72:
  pushl $0
c01029ad:	6a 00                	push   $0x0
  pushl $72
c01029af:	6a 48                	push   $0x48
  jmp __alltraps
c01029b1:	e9 ef 07 00 00       	jmp    c01031a5 <__alltraps>

c01029b6 <vector73>:
.globl vector73
vector73:
  pushl $0
c01029b6:	6a 00                	push   $0x0
  pushl $73
c01029b8:	6a 49                	push   $0x49
  jmp __alltraps
c01029ba:	e9 e6 07 00 00       	jmp    c01031a5 <__alltraps>

c01029bf <vector74>:
.globl vector74
vector74:
  pushl $0
c01029bf:	6a 00                	push   $0x0
  pushl $74
c01029c1:	6a 4a                	push   $0x4a
  jmp __alltraps
c01029c3:	e9 dd 07 00 00       	jmp    c01031a5 <__alltraps>

c01029c8 <vector75>:
.globl vector75
vector75:
  pushl $0
c01029c8:	6a 00                	push   $0x0
  pushl $75
c01029ca:	6a 4b                	push   $0x4b
  jmp __alltraps
c01029cc:	e9 d4 07 00 00       	jmp    c01031a5 <__alltraps>

c01029d1 <vector76>:
.globl vector76
vector76:
  pushl $0
c01029d1:	6a 00                	push   $0x0
  pushl $76
c01029d3:	6a 4c                	push   $0x4c
  jmp __alltraps
c01029d5:	e9 cb 07 00 00       	jmp    c01031a5 <__alltraps>

c01029da <vector77>:
.globl vector77
vector77:
  pushl $0
c01029da:	6a 00                	push   $0x0
  pushl $77
c01029dc:	6a 4d                	push   $0x4d
  jmp __alltraps
c01029de:	e9 c2 07 00 00       	jmp    c01031a5 <__alltraps>

c01029e3 <vector78>:
.globl vector78
vector78:
  pushl $0
c01029e3:	6a 00                	push   $0x0
  pushl $78
c01029e5:	6a 4e                	push   $0x4e
  jmp __alltraps
c01029e7:	e9 b9 07 00 00       	jmp    c01031a5 <__alltraps>

c01029ec <vector79>:
.globl vector79
vector79:
  pushl $0
c01029ec:	6a 00                	push   $0x0
  pushl $79
c01029ee:	6a 4f                	push   $0x4f
  jmp __alltraps
c01029f0:	e9 b0 07 00 00       	jmp    c01031a5 <__alltraps>

c01029f5 <vector80>:
.globl vector80
vector80:
  pushl $0
c01029f5:	6a 00                	push   $0x0
  pushl $80
c01029f7:	6a 50                	push   $0x50
  jmp __alltraps
c01029f9:	e9 a7 07 00 00       	jmp    c01031a5 <__alltraps>

c01029fe <vector81>:
.globl vector81
vector81:
  pushl $0
c01029fe:	6a 00                	push   $0x0
  pushl $81
c0102a00:	6a 51                	push   $0x51
  jmp __alltraps
c0102a02:	e9 9e 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a07 <vector82>:
.globl vector82
vector82:
  pushl $0
c0102a07:	6a 00                	push   $0x0
  pushl $82
c0102a09:	6a 52                	push   $0x52
  jmp __alltraps
c0102a0b:	e9 95 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a10 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102a10:	6a 00                	push   $0x0
  pushl $83
c0102a12:	6a 53                	push   $0x53
  jmp __alltraps
c0102a14:	e9 8c 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a19 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102a19:	6a 00                	push   $0x0
  pushl $84
c0102a1b:	6a 54                	push   $0x54
  jmp __alltraps
c0102a1d:	e9 83 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a22 <vector85>:
.globl vector85
vector85:
  pushl $0
c0102a22:	6a 00                	push   $0x0
  pushl $85
c0102a24:	6a 55                	push   $0x55
  jmp __alltraps
c0102a26:	e9 7a 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a2b <vector86>:
.globl vector86
vector86:
  pushl $0
c0102a2b:	6a 00                	push   $0x0
  pushl $86
c0102a2d:	6a 56                	push   $0x56
  jmp __alltraps
c0102a2f:	e9 71 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a34 <vector87>:
.globl vector87
vector87:
  pushl $0
c0102a34:	6a 00                	push   $0x0
  pushl $87
c0102a36:	6a 57                	push   $0x57
  jmp __alltraps
c0102a38:	e9 68 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a3d <vector88>:
.globl vector88
vector88:
  pushl $0
c0102a3d:	6a 00                	push   $0x0
  pushl $88
c0102a3f:	6a 58                	push   $0x58
  jmp __alltraps
c0102a41:	e9 5f 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a46 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102a46:	6a 00                	push   $0x0
  pushl $89
c0102a48:	6a 59                	push   $0x59
  jmp __alltraps
c0102a4a:	e9 56 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a4f <vector90>:
.globl vector90
vector90:
  pushl $0
c0102a4f:	6a 00                	push   $0x0
  pushl $90
c0102a51:	6a 5a                	push   $0x5a
  jmp __alltraps
c0102a53:	e9 4d 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a58 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102a58:	6a 00                	push   $0x0
  pushl $91
c0102a5a:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102a5c:	e9 44 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a61 <vector92>:
.globl vector92
vector92:
  pushl $0
c0102a61:	6a 00                	push   $0x0
  pushl $92
c0102a63:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102a65:	e9 3b 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a6a <vector93>:
.globl vector93
vector93:
  pushl $0
c0102a6a:	6a 00                	push   $0x0
  pushl $93
c0102a6c:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102a6e:	e9 32 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a73 <vector94>:
.globl vector94
vector94:
  pushl $0
c0102a73:	6a 00                	push   $0x0
  pushl $94
c0102a75:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102a77:	e9 29 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a7c <vector95>:
.globl vector95
vector95:
  pushl $0
c0102a7c:	6a 00                	push   $0x0
  pushl $95
c0102a7e:	6a 5f                	push   $0x5f
  jmp __alltraps
c0102a80:	e9 20 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a85 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102a85:	6a 00                	push   $0x0
  pushl $96
c0102a87:	6a 60                	push   $0x60
  jmp __alltraps
c0102a89:	e9 17 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a8e <vector97>:
.globl vector97
vector97:
  pushl $0
c0102a8e:	6a 00                	push   $0x0
  pushl $97
c0102a90:	6a 61                	push   $0x61
  jmp __alltraps
c0102a92:	e9 0e 07 00 00       	jmp    c01031a5 <__alltraps>

c0102a97 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102a97:	6a 00                	push   $0x0
  pushl $98
c0102a99:	6a 62                	push   $0x62
  jmp __alltraps
c0102a9b:	e9 05 07 00 00       	jmp    c01031a5 <__alltraps>

c0102aa0 <vector99>:
.globl vector99
vector99:
  pushl $0
c0102aa0:	6a 00                	push   $0x0
  pushl $99
c0102aa2:	6a 63                	push   $0x63
  jmp __alltraps
c0102aa4:	e9 fc 06 00 00       	jmp    c01031a5 <__alltraps>

c0102aa9 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102aa9:	6a 00                	push   $0x0
  pushl $100
c0102aab:	6a 64                	push   $0x64
  jmp __alltraps
c0102aad:	e9 f3 06 00 00       	jmp    c01031a5 <__alltraps>

c0102ab2 <vector101>:
.globl vector101
vector101:
  pushl $0
c0102ab2:	6a 00                	push   $0x0
  pushl $101
c0102ab4:	6a 65                	push   $0x65
  jmp __alltraps
c0102ab6:	e9 ea 06 00 00       	jmp    c01031a5 <__alltraps>

c0102abb <vector102>:
.globl vector102
vector102:
  pushl $0
c0102abb:	6a 00                	push   $0x0
  pushl $102
c0102abd:	6a 66                	push   $0x66
  jmp __alltraps
c0102abf:	e9 e1 06 00 00       	jmp    c01031a5 <__alltraps>

c0102ac4 <vector103>:
.globl vector103
vector103:
  pushl $0
c0102ac4:	6a 00                	push   $0x0
  pushl $103
c0102ac6:	6a 67                	push   $0x67
  jmp __alltraps
c0102ac8:	e9 d8 06 00 00       	jmp    c01031a5 <__alltraps>

c0102acd <vector104>:
.globl vector104
vector104:
  pushl $0
c0102acd:	6a 00                	push   $0x0
  pushl $104
c0102acf:	6a 68                	push   $0x68
  jmp __alltraps
c0102ad1:	e9 cf 06 00 00       	jmp    c01031a5 <__alltraps>

c0102ad6 <vector105>:
.globl vector105
vector105:
  pushl $0
c0102ad6:	6a 00                	push   $0x0
  pushl $105
c0102ad8:	6a 69                	push   $0x69
  jmp __alltraps
c0102ada:	e9 c6 06 00 00       	jmp    c01031a5 <__alltraps>

c0102adf <vector106>:
.globl vector106
vector106:
  pushl $0
c0102adf:	6a 00                	push   $0x0
  pushl $106
c0102ae1:	6a 6a                	push   $0x6a
  jmp __alltraps
c0102ae3:	e9 bd 06 00 00       	jmp    c01031a5 <__alltraps>

c0102ae8 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102ae8:	6a 00                	push   $0x0
  pushl $107
c0102aea:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102aec:	e9 b4 06 00 00       	jmp    c01031a5 <__alltraps>

c0102af1 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102af1:	6a 00                	push   $0x0
  pushl $108
c0102af3:	6a 6c                	push   $0x6c
  jmp __alltraps
c0102af5:	e9 ab 06 00 00       	jmp    c01031a5 <__alltraps>

c0102afa <vector109>:
.globl vector109
vector109:
  pushl $0
c0102afa:	6a 00                	push   $0x0
  pushl $109
c0102afc:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102afe:	e9 a2 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b03 <vector110>:
.globl vector110
vector110:
  pushl $0
c0102b03:	6a 00                	push   $0x0
  pushl $110
c0102b05:	6a 6e                	push   $0x6e
  jmp __alltraps
c0102b07:	e9 99 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b0c <vector111>:
.globl vector111
vector111:
  pushl $0
c0102b0c:	6a 00                	push   $0x0
  pushl $111
c0102b0e:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102b10:	e9 90 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b15 <vector112>:
.globl vector112
vector112:
  pushl $0
c0102b15:	6a 00                	push   $0x0
  pushl $112
c0102b17:	6a 70                	push   $0x70
  jmp __alltraps
c0102b19:	e9 87 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b1e <vector113>:
.globl vector113
vector113:
  pushl $0
c0102b1e:	6a 00                	push   $0x0
  pushl $113
c0102b20:	6a 71                	push   $0x71
  jmp __alltraps
c0102b22:	e9 7e 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b27 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102b27:	6a 00                	push   $0x0
  pushl $114
c0102b29:	6a 72                	push   $0x72
  jmp __alltraps
c0102b2b:	e9 75 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b30 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102b30:	6a 00                	push   $0x0
  pushl $115
c0102b32:	6a 73                	push   $0x73
  jmp __alltraps
c0102b34:	e9 6c 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b39 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102b39:	6a 00                	push   $0x0
  pushl $116
c0102b3b:	6a 74                	push   $0x74
  jmp __alltraps
c0102b3d:	e9 63 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b42 <vector117>:
.globl vector117
vector117:
  pushl $0
c0102b42:	6a 00                	push   $0x0
  pushl $117
c0102b44:	6a 75                	push   $0x75
  jmp __alltraps
c0102b46:	e9 5a 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b4b <vector118>:
.globl vector118
vector118:
  pushl $0
c0102b4b:	6a 00                	push   $0x0
  pushl $118
c0102b4d:	6a 76                	push   $0x76
  jmp __alltraps
c0102b4f:	e9 51 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b54 <vector119>:
.globl vector119
vector119:
  pushl $0
c0102b54:	6a 00                	push   $0x0
  pushl $119
c0102b56:	6a 77                	push   $0x77
  jmp __alltraps
c0102b58:	e9 48 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b5d <vector120>:
.globl vector120
vector120:
  pushl $0
c0102b5d:	6a 00                	push   $0x0
  pushl $120
c0102b5f:	6a 78                	push   $0x78
  jmp __alltraps
c0102b61:	e9 3f 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b66 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102b66:	6a 00                	push   $0x0
  pushl $121
c0102b68:	6a 79                	push   $0x79
  jmp __alltraps
c0102b6a:	e9 36 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b6f <vector122>:
.globl vector122
vector122:
  pushl $0
c0102b6f:	6a 00                	push   $0x0
  pushl $122
c0102b71:	6a 7a                	push   $0x7a
  jmp __alltraps
c0102b73:	e9 2d 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b78 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102b78:	6a 00                	push   $0x0
  pushl $123
c0102b7a:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102b7c:	e9 24 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b81 <vector124>:
.globl vector124
vector124:
  pushl $0
c0102b81:	6a 00                	push   $0x0
  pushl $124
c0102b83:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102b85:	e9 1b 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b8a <vector125>:
.globl vector125
vector125:
  pushl $0
c0102b8a:	6a 00                	push   $0x0
  pushl $125
c0102b8c:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102b8e:	e9 12 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b93 <vector126>:
.globl vector126
vector126:
  pushl $0
c0102b93:	6a 00                	push   $0x0
  pushl $126
c0102b95:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102b97:	e9 09 06 00 00       	jmp    c01031a5 <__alltraps>

c0102b9c <vector127>:
.globl vector127
vector127:
  pushl $0
c0102b9c:	6a 00                	push   $0x0
  pushl $127
c0102b9e:	6a 7f                	push   $0x7f
  jmp __alltraps
c0102ba0:	e9 00 06 00 00       	jmp    c01031a5 <__alltraps>

c0102ba5 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102ba5:	6a 00                	push   $0x0
  pushl $128
c0102ba7:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102bac:	e9 f4 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bb1 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102bb1:	6a 00                	push   $0x0
  pushl $129
c0102bb3:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102bb8:	e9 e8 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bbd <vector130>:
.globl vector130
vector130:
  pushl $0
c0102bbd:	6a 00                	push   $0x0
  pushl $130
c0102bbf:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c0102bc4:	e9 dc 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bc9 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102bc9:	6a 00                	push   $0x0
  pushl $131
c0102bcb:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102bd0:	e9 d0 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bd5 <vector132>:
.globl vector132
vector132:
  pushl $0
c0102bd5:	6a 00                	push   $0x0
  pushl $132
c0102bd7:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102bdc:	e9 c4 05 00 00       	jmp    c01031a5 <__alltraps>

c0102be1 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102be1:	6a 00                	push   $0x0
  pushl $133
c0102be3:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102be8:	e9 b8 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bed <vector134>:
.globl vector134
vector134:
  pushl $0
c0102bed:	6a 00                	push   $0x0
  pushl $134
c0102bef:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c0102bf4:	e9 ac 05 00 00       	jmp    c01031a5 <__alltraps>

c0102bf9 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102bf9:	6a 00                	push   $0x0
  pushl $135
c0102bfb:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102c00:	e9 a0 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c05 <vector136>:
.globl vector136
vector136:
  pushl $0
c0102c05:	6a 00                	push   $0x0
  pushl $136
c0102c07:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102c0c:	e9 94 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c11 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102c11:	6a 00                	push   $0x0
  pushl $137
c0102c13:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102c18:	e9 88 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c1d <vector138>:
.globl vector138
vector138:
  pushl $0
c0102c1d:	6a 00                	push   $0x0
  pushl $138
c0102c1f:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c0102c24:	e9 7c 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c29 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102c29:	6a 00                	push   $0x0
  pushl $139
c0102c2b:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102c30:	e9 70 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c35 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102c35:	6a 00                	push   $0x0
  pushl $140
c0102c37:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102c3c:	e9 64 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c41 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102c41:	6a 00                	push   $0x0
  pushl $141
c0102c43:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102c48:	e9 58 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c4d <vector142>:
.globl vector142
vector142:
  pushl $0
c0102c4d:	6a 00                	push   $0x0
  pushl $142
c0102c4f:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c0102c54:	e9 4c 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c59 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102c59:	6a 00                	push   $0x0
  pushl $143
c0102c5b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c0102c60:	e9 40 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c65 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102c65:	6a 00                	push   $0x0
  pushl $144
c0102c67:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102c6c:	e9 34 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c71 <vector145>:
.globl vector145
vector145:
  pushl $0
c0102c71:	6a 00                	push   $0x0
  pushl $145
c0102c73:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102c78:	e9 28 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c7d <vector146>:
.globl vector146
vector146:
  pushl $0
c0102c7d:	6a 00                	push   $0x0
  pushl $146
c0102c7f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c0102c84:	e9 1c 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c89 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102c89:	6a 00                	push   $0x0
  pushl $147
c0102c8b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c0102c90:	e9 10 05 00 00       	jmp    c01031a5 <__alltraps>

c0102c95 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102c95:	6a 00                	push   $0x0
  pushl $148
c0102c97:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102c9c:	e9 04 05 00 00       	jmp    c01031a5 <__alltraps>

c0102ca1 <vector149>:
.globl vector149
vector149:
  pushl $0
c0102ca1:	6a 00                	push   $0x0
  pushl $149
c0102ca3:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102ca8:	e9 f8 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cad <vector150>:
.globl vector150
vector150:
  pushl $0
c0102cad:	6a 00                	push   $0x0
  pushl $150
c0102caf:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c0102cb4:	e9 ec 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cb9 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102cb9:	6a 00                	push   $0x0
  pushl $151
c0102cbb:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102cc0:	e9 e0 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cc5 <vector152>:
.globl vector152
vector152:
  pushl $0
c0102cc5:	6a 00                	push   $0x0
  pushl $152
c0102cc7:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102ccc:	e9 d4 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cd1 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102cd1:	6a 00                	push   $0x0
  pushl $153
c0102cd3:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102cd8:	e9 c8 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cdd <vector154>:
.globl vector154
vector154:
  pushl $0
c0102cdd:	6a 00                	push   $0x0
  pushl $154
c0102cdf:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c0102ce4:	e9 bc 04 00 00       	jmp    c01031a5 <__alltraps>

c0102ce9 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102ce9:	6a 00                	push   $0x0
  pushl $155
c0102ceb:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102cf0:	e9 b0 04 00 00       	jmp    c01031a5 <__alltraps>

c0102cf5 <vector156>:
.globl vector156
vector156:
  pushl $0
c0102cf5:	6a 00                	push   $0x0
  pushl $156
c0102cf7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102cfc:	e9 a4 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d01 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102d01:	6a 00                	push   $0x0
  pushl $157
c0102d03:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102d08:	e9 98 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d0d <vector158>:
.globl vector158
vector158:
  pushl $0
c0102d0d:	6a 00                	push   $0x0
  pushl $158
c0102d0f:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c0102d14:	e9 8c 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d19 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102d19:	6a 00                	push   $0x0
  pushl $159
c0102d1b:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102d20:	e9 80 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d25 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102d25:	6a 00                	push   $0x0
  pushl $160
c0102d27:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102d2c:	e9 74 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d31 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102d31:	6a 00                	push   $0x0
  pushl $161
c0102d33:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102d38:	e9 68 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d3d <vector162>:
.globl vector162
vector162:
  pushl $0
c0102d3d:	6a 00                	push   $0x0
  pushl $162
c0102d3f:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c0102d44:	e9 5c 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d49 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102d49:	6a 00                	push   $0x0
  pushl $163
c0102d4b:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c0102d50:	e9 50 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d55 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102d55:	6a 00                	push   $0x0
  pushl $164
c0102d57:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102d5c:	e9 44 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d61 <vector165>:
.globl vector165
vector165:
  pushl $0
c0102d61:	6a 00                	push   $0x0
  pushl $165
c0102d63:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102d68:	e9 38 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d6d <vector166>:
.globl vector166
vector166:
  pushl $0
c0102d6d:	6a 00                	push   $0x0
  pushl $166
c0102d6f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c0102d74:	e9 2c 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d79 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102d79:	6a 00                	push   $0x0
  pushl $167
c0102d7b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c0102d80:	e9 20 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d85 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102d85:	6a 00                	push   $0x0
  pushl $168
c0102d87:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102d8c:	e9 14 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d91 <vector169>:
.globl vector169
vector169:
  pushl $0
c0102d91:	6a 00                	push   $0x0
  pushl $169
c0102d93:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102d98:	e9 08 04 00 00       	jmp    c01031a5 <__alltraps>

c0102d9d <vector170>:
.globl vector170
vector170:
  pushl $0
c0102d9d:	6a 00                	push   $0x0
  pushl $170
c0102d9f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c0102da4:	e9 fc 03 00 00       	jmp    c01031a5 <__alltraps>

c0102da9 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102da9:	6a 00                	push   $0x0
  pushl $171
c0102dab:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102db0:	e9 f0 03 00 00       	jmp    c01031a5 <__alltraps>

c0102db5 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102db5:	6a 00                	push   $0x0
  pushl $172
c0102db7:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102dbc:	e9 e4 03 00 00       	jmp    c01031a5 <__alltraps>

c0102dc1 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102dc1:	6a 00                	push   $0x0
  pushl $173
c0102dc3:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102dc8:	e9 d8 03 00 00       	jmp    c01031a5 <__alltraps>

c0102dcd <vector174>:
.globl vector174
vector174:
  pushl $0
c0102dcd:	6a 00                	push   $0x0
  pushl $174
c0102dcf:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c0102dd4:	e9 cc 03 00 00       	jmp    c01031a5 <__alltraps>

c0102dd9 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102dd9:	6a 00                	push   $0x0
  pushl $175
c0102ddb:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102de0:	e9 c0 03 00 00       	jmp    c01031a5 <__alltraps>

c0102de5 <vector176>:
.globl vector176
vector176:
  pushl $0
c0102de5:	6a 00                	push   $0x0
  pushl $176
c0102de7:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102dec:	e9 b4 03 00 00       	jmp    c01031a5 <__alltraps>

c0102df1 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102df1:	6a 00                	push   $0x0
  pushl $177
c0102df3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102df8:	e9 a8 03 00 00       	jmp    c01031a5 <__alltraps>

c0102dfd <vector178>:
.globl vector178
vector178:
  pushl $0
c0102dfd:	6a 00                	push   $0x0
  pushl $178
c0102dff:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c0102e04:	e9 9c 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e09 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102e09:	6a 00                	push   $0x0
  pushl $179
c0102e0b:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102e10:	e9 90 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e15 <vector180>:
.globl vector180
vector180:
  pushl $0
c0102e15:	6a 00                	push   $0x0
  pushl $180
c0102e17:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102e1c:	e9 84 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e21 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102e21:	6a 00                	push   $0x0
  pushl $181
c0102e23:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102e28:	e9 78 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e2d <vector182>:
.globl vector182
vector182:
  pushl $0
c0102e2d:	6a 00                	push   $0x0
  pushl $182
c0102e2f:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c0102e34:	e9 6c 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e39 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102e39:	6a 00                	push   $0x0
  pushl $183
c0102e3b:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102e40:	e9 60 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e45 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102e45:	6a 00                	push   $0x0
  pushl $184
c0102e47:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102e4c:	e9 54 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e51 <vector185>:
.globl vector185
vector185:
  pushl $0
c0102e51:	6a 00                	push   $0x0
  pushl $185
c0102e53:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102e58:	e9 48 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e5d <vector186>:
.globl vector186
vector186:
  pushl $0
c0102e5d:	6a 00                	push   $0x0
  pushl $186
c0102e5f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c0102e64:	e9 3c 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e69 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102e69:	6a 00                	push   $0x0
  pushl $187
c0102e6b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c0102e70:	e9 30 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e75 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102e75:	6a 00                	push   $0x0
  pushl $188
c0102e77:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102e7c:	e9 24 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e81 <vector189>:
.globl vector189
vector189:
  pushl $0
c0102e81:	6a 00                	push   $0x0
  pushl $189
c0102e83:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102e88:	e9 18 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e8d <vector190>:
.globl vector190
vector190:
  pushl $0
c0102e8d:	6a 00                	push   $0x0
  pushl $190
c0102e8f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c0102e94:	e9 0c 03 00 00       	jmp    c01031a5 <__alltraps>

c0102e99 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102e99:	6a 00                	push   $0x0
  pushl $191
c0102e9b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c0102ea0:	e9 00 03 00 00       	jmp    c01031a5 <__alltraps>

c0102ea5 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102ea5:	6a 00                	push   $0x0
  pushl $192
c0102ea7:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102eac:	e9 f4 02 00 00       	jmp    c01031a5 <__alltraps>

c0102eb1 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102eb1:	6a 00                	push   $0x0
  pushl $193
c0102eb3:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102eb8:	e9 e8 02 00 00       	jmp    c01031a5 <__alltraps>

c0102ebd <vector194>:
.globl vector194
vector194:
  pushl $0
c0102ebd:	6a 00                	push   $0x0
  pushl $194
c0102ebf:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c0102ec4:	e9 dc 02 00 00       	jmp    c01031a5 <__alltraps>

c0102ec9 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102ec9:	6a 00                	push   $0x0
  pushl $195
c0102ecb:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102ed0:	e9 d0 02 00 00       	jmp    c01031a5 <__alltraps>

c0102ed5 <vector196>:
.globl vector196
vector196:
  pushl $0
c0102ed5:	6a 00                	push   $0x0
  pushl $196
c0102ed7:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102edc:	e9 c4 02 00 00       	jmp    c01031a5 <__alltraps>

c0102ee1 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102ee1:	6a 00                	push   $0x0
  pushl $197
c0102ee3:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102ee8:	e9 b8 02 00 00       	jmp    c01031a5 <__alltraps>

c0102eed <vector198>:
.globl vector198
vector198:
  pushl $0
c0102eed:	6a 00                	push   $0x0
  pushl $198
c0102eef:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c0102ef4:	e9 ac 02 00 00       	jmp    c01031a5 <__alltraps>

c0102ef9 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102ef9:	6a 00                	push   $0x0
  pushl $199
c0102efb:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102f00:	e9 a0 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f05 <vector200>:
.globl vector200
vector200:
  pushl $0
c0102f05:	6a 00                	push   $0x0
  pushl $200
c0102f07:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102f0c:	e9 94 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f11 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102f11:	6a 00                	push   $0x0
  pushl $201
c0102f13:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102f18:	e9 88 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f1d <vector202>:
.globl vector202
vector202:
  pushl $0
c0102f1d:	6a 00                	push   $0x0
  pushl $202
c0102f1f:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c0102f24:	e9 7c 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f29 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102f29:	6a 00                	push   $0x0
  pushl $203
c0102f2b:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102f30:	e9 70 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f35 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102f35:	6a 00                	push   $0x0
  pushl $204
c0102f37:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102f3c:	e9 64 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f41 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102f41:	6a 00                	push   $0x0
  pushl $205
c0102f43:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102f48:	e9 58 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f4d <vector206>:
.globl vector206
vector206:
  pushl $0
c0102f4d:	6a 00                	push   $0x0
  pushl $206
c0102f4f:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c0102f54:	e9 4c 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f59 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102f59:	6a 00                	push   $0x0
  pushl $207
c0102f5b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c0102f60:	e9 40 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f65 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102f65:	6a 00                	push   $0x0
  pushl $208
c0102f67:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102f6c:	e9 34 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f71 <vector209>:
.globl vector209
vector209:
  pushl $0
c0102f71:	6a 00                	push   $0x0
  pushl $209
c0102f73:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102f78:	e9 28 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f7d <vector210>:
.globl vector210
vector210:
  pushl $0
c0102f7d:	6a 00                	push   $0x0
  pushl $210
c0102f7f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c0102f84:	e9 1c 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f89 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102f89:	6a 00                	push   $0x0
  pushl $211
c0102f8b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c0102f90:	e9 10 02 00 00       	jmp    c01031a5 <__alltraps>

c0102f95 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102f95:	6a 00                	push   $0x0
  pushl $212
c0102f97:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102f9c:	e9 04 02 00 00       	jmp    c01031a5 <__alltraps>

c0102fa1 <vector213>:
.globl vector213
vector213:
  pushl $0
c0102fa1:	6a 00                	push   $0x0
  pushl $213
c0102fa3:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102fa8:	e9 f8 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fad <vector214>:
.globl vector214
vector214:
  pushl $0
c0102fad:	6a 00                	push   $0x0
  pushl $214
c0102faf:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102fb4:	e9 ec 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fb9 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102fb9:	6a 00                	push   $0x0
  pushl $215
c0102fbb:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102fc0:	e9 e0 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fc5 <vector216>:
.globl vector216
vector216:
  pushl $0
c0102fc5:	6a 00                	push   $0x0
  pushl $216
c0102fc7:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102fcc:	e9 d4 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fd1 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102fd1:	6a 00                	push   $0x0
  pushl $217
c0102fd3:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102fd8:	e9 c8 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fdd <vector218>:
.globl vector218
vector218:
  pushl $0
c0102fdd:	6a 00                	push   $0x0
  pushl $218
c0102fdf:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102fe4:	e9 bc 01 00 00       	jmp    c01031a5 <__alltraps>

c0102fe9 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102fe9:	6a 00                	push   $0x0
  pushl $219
c0102feb:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102ff0:	e9 b0 01 00 00       	jmp    c01031a5 <__alltraps>

c0102ff5 <vector220>:
.globl vector220
vector220:
  pushl $0
c0102ff5:	6a 00                	push   $0x0
  pushl $220
c0102ff7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102ffc:	e9 a4 01 00 00       	jmp    c01031a5 <__alltraps>

c0103001 <vector221>:
.globl vector221
vector221:
  pushl $0
c0103001:	6a 00                	push   $0x0
  pushl $221
c0103003:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0103008:	e9 98 01 00 00       	jmp    c01031a5 <__alltraps>

c010300d <vector222>:
.globl vector222
vector222:
  pushl $0
c010300d:	6a 00                	push   $0x0
  pushl $222
c010300f:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0103014:	e9 8c 01 00 00       	jmp    c01031a5 <__alltraps>

c0103019 <vector223>:
.globl vector223
vector223:
  pushl $0
c0103019:	6a 00                	push   $0x0
  pushl $223
c010301b:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0103020:	e9 80 01 00 00       	jmp    c01031a5 <__alltraps>

c0103025 <vector224>:
.globl vector224
vector224:
  pushl $0
c0103025:	6a 00                	push   $0x0
  pushl $224
c0103027:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c010302c:	e9 74 01 00 00       	jmp    c01031a5 <__alltraps>

c0103031 <vector225>:
.globl vector225
vector225:
  pushl $0
c0103031:	6a 00                	push   $0x0
  pushl $225
c0103033:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0103038:	e9 68 01 00 00       	jmp    c01031a5 <__alltraps>

c010303d <vector226>:
.globl vector226
vector226:
  pushl $0
c010303d:	6a 00                	push   $0x0
  pushl $226
c010303f:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0103044:	e9 5c 01 00 00       	jmp    c01031a5 <__alltraps>

c0103049 <vector227>:
.globl vector227
vector227:
  pushl $0
c0103049:	6a 00                	push   $0x0
  pushl $227
c010304b:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0103050:	e9 50 01 00 00       	jmp    c01031a5 <__alltraps>

c0103055 <vector228>:
.globl vector228
vector228:
  pushl $0
c0103055:	6a 00                	push   $0x0
  pushl $228
c0103057:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c010305c:	e9 44 01 00 00       	jmp    c01031a5 <__alltraps>

c0103061 <vector229>:
.globl vector229
vector229:
  pushl $0
c0103061:	6a 00                	push   $0x0
  pushl $229
c0103063:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0103068:	e9 38 01 00 00       	jmp    c01031a5 <__alltraps>

c010306d <vector230>:
.globl vector230
vector230:
  pushl $0
c010306d:	6a 00                	push   $0x0
  pushl $230
c010306f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0103074:	e9 2c 01 00 00       	jmp    c01031a5 <__alltraps>

c0103079 <vector231>:
.globl vector231
vector231:
  pushl $0
c0103079:	6a 00                	push   $0x0
  pushl $231
c010307b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0103080:	e9 20 01 00 00       	jmp    c01031a5 <__alltraps>

c0103085 <vector232>:
.globl vector232
vector232:
  pushl $0
c0103085:	6a 00                	push   $0x0
  pushl $232
c0103087:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c010308c:	e9 14 01 00 00       	jmp    c01031a5 <__alltraps>

c0103091 <vector233>:
.globl vector233
vector233:
  pushl $0
c0103091:	6a 00                	push   $0x0
  pushl $233
c0103093:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0103098:	e9 08 01 00 00       	jmp    c01031a5 <__alltraps>

c010309d <vector234>:
.globl vector234
vector234:
  pushl $0
c010309d:	6a 00                	push   $0x0
  pushl $234
c010309f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c01030a4:	e9 fc 00 00 00       	jmp    c01031a5 <__alltraps>

c01030a9 <vector235>:
.globl vector235
vector235:
  pushl $0
c01030a9:	6a 00                	push   $0x0
  pushl $235
c01030ab:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c01030b0:	e9 f0 00 00 00       	jmp    c01031a5 <__alltraps>

c01030b5 <vector236>:
.globl vector236
vector236:
  pushl $0
c01030b5:	6a 00                	push   $0x0
  pushl $236
c01030b7:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c01030bc:	e9 e4 00 00 00       	jmp    c01031a5 <__alltraps>

c01030c1 <vector237>:
.globl vector237
vector237:
  pushl $0
c01030c1:	6a 00                	push   $0x0
  pushl $237
c01030c3:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01030c8:	e9 d8 00 00 00       	jmp    c01031a5 <__alltraps>

c01030cd <vector238>:
.globl vector238
vector238:
  pushl $0
c01030cd:	6a 00                	push   $0x0
  pushl $238
c01030cf:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01030d4:	e9 cc 00 00 00       	jmp    c01031a5 <__alltraps>

c01030d9 <vector239>:
.globl vector239
vector239:
  pushl $0
c01030d9:	6a 00                	push   $0x0
  pushl $239
c01030db:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01030e0:	e9 c0 00 00 00       	jmp    c01031a5 <__alltraps>

c01030e5 <vector240>:
.globl vector240
vector240:
  pushl $0
c01030e5:	6a 00                	push   $0x0
  pushl $240
c01030e7:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01030ec:	e9 b4 00 00 00       	jmp    c01031a5 <__alltraps>

c01030f1 <vector241>:
.globl vector241
vector241:
  pushl $0
c01030f1:	6a 00                	push   $0x0
  pushl $241
c01030f3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01030f8:	e9 a8 00 00 00       	jmp    c01031a5 <__alltraps>

c01030fd <vector242>:
.globl vector242
vector242:
  pushl $0
c01030fd:	6a 00                	push   $0x0
  pushl $242
c01030ff:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0103104:	e9 9c 00 00 00       	jmp    c01031a5 <__alltraps>

c0103109 <vector243>:
.globl vector243
vector243:
  pushl $0
c0103109:	6a 00                	push   $0x0
  pushl $243
c010310b:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0103110:	e9 90 00 00 00       	jmp    c01031a5 <__alltraps>

c0103115 <vector244>:
.globl vector244
vector244:
  pushl $0
c0103115:	6a 00                	push   $0x0
  pushl $244
c0103117:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c010311c:	e9 84 00 00 00       	jmp    c01031a5 <__alltraps>

c0103121 <vector245>:
.globl vector245
vector245:
  pushl $0
c0103121:	6a 00                	push   $0x0
  pushl $245
c0103123:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0103128:	e9 78 00 00 00       	jmp    c01031a5 <__alltraps>

c010312d <vector246>:
.globl vector246
vector246:
  pushl $0
c010312d:	6a 00                	push   $0x0
  pushl $246
c010312f:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0103134:	e9 6c 00 00 00       	jmp    c01031a5 <__alltraps>

c0103139 <vector247>:
.globl vector247
vector247:
  pushl $0
c0103139:	6a 00                	push   $0x0
  pushl $247
c010313b:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0103140:	e9 60 00 00 00       	jmp    c01031a5 <__alltraps>

c0103145 <vector248>:
.globl vector248
vector248:
  pushl $0
c0103145:	6a 00                	push   $0x0
  pushl $248
c0103147:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c010314c:	e9 54 00 00 00       	jmp    c01031a5 <__alltraps>

c0103151 <vector249>:
.globl vector249
vector249:
  pushl $0
c0103151:	6a 00                	push   $0x0
  pushl $249
c0103153:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0103158:	e9 48 00 00 00       	jmp    c01031a5 <__alltraps>

c010315d <vector250>:
.globl vector250
vector250:
  pushl $0
c010315d:	6a 00                	push   $0x0
  pushl $250
c010315f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0103164:	e9 3c 00 00 00       	jmp    c01031a5 <__alltraps>

c0103169 <vector251>:
.globl vector251
vector251:
  pushl $0
c0103169:	6a 00                	push   $0x0
  pushl $251
c010316b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0103170:	e9 30 00 00 00       	jmp    c01031a5 <__alltraps>

c0103175 <vector252>:
.globl vector252
vector252:
  pushl $0
c0103175:	6a 00                	push   $0x0
  pushl $252
c0103177:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c010317c:	e9 24 00 00 00       	jmp    c01031a5 <__alltraps>

c0103181 <vector253>:
.globl vector253
vector253:
  pushl $0
c0103181:	6a 00                	push   $0x0
  pushl $253
c0103183:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0103188:	e9 18 00 00 00       	jmp    c01031a5 <__alltraps>

c010318d <vector254>:
.globl vector254
vector254:
  pushl $0
c010318d:	6a 00                	push   $0x0
  pushl $254
c010318f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0103194:	e9 0c 00 00 00       	jmp    c01031a5 <__alltraps>

c0103199 <vector255>:
.globl vector255
vector255:
  pushl $0
c0103199:	6a 00                	push   $0x0
  pushl $255
c010319b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c01031a0:	e9 00 00 00 00       	jmp    c01031a5 <__alltraps>

c01031a5 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c01031a5:	1e                   	push   %ds
    pushl %es
c01031a6:	06                   	push   %es
    pushl %fs
c01031a7:	0f a0                	push   %fs
    pushl %gs
c01031a9:	0f a8                	push   %gs
    pushal
c01031ab:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c01031ac:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c01031b1:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c01031b3:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c01031b5:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c01031b6:	e8 64 f5 ff ff       	call   c010271f <trap>

    # pop the pushed stack pointer
    popl %esp
c01031bb:	5c                   	pop    %esp

c01031bc <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c01031bc:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c01031bd:	0f a9                	pop    %gs
    popl %fs
c01031bf:	0f a1                	pop    %fs
    popl %es
c01031c1:	07                   	pop    %es
    popl %ds
c01031c2:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c01031c3:	83 c4 08             	add    $0x8,%esp
    iret
c01031c6:	cf                   	iret   

c01031c7 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c01031c7:	55                   	push   %ebp
c01031c8:	89 e5                	mov    %esp,%ebp
    return page - pages;
c01031ca:	8b 45 08             	mov    0x8(%ebp),%eax
c01031cd:	8b 15 28 50 12 c0    	mov    0xc0125028,%edx
c01031d3:	29 d0                	sub    %edx,%eax
c01031d5:	c1 f8 05             	sar    $0x5,%eax
}
c01031d8:	5d                   	pop    %ebp
c01031d9:	c3                   	ret    

c01031da <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c01031da:	55                   	push   %ebp
c01031db:	89 e5                	mov    %esp,%ebp
c01031dd:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c01031e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01031e3:	89 04 24             	mov    %eax,(%esp)
c01031e6:	e8 dc ff ff ff       	call   c01031c7 <page2ppn>
c01031eb:	c1 e0 0c             	shl    $0xc,%eax
}
c01031ee:	c9                   	leave  
c01031ef:	c3                   	ret    

c01031f0 <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c01031f0:	55                   	push   %ebp
c01031f1:	89 e5                	mov    %esp,%ebp
c01031f3:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c01031f6:	8b 45 08             	mov    0x8(%ebp),%eax
c01031f9:	c1 e8 0c             	shr    $0xc,%eax
c01031fc:	89 c2                	mov    %eax,%edx
c01031fe:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0103203:	39 c2                	cmp    %eax,%edx
c0103205:	72 1c                	jb     c0103223 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103207:	c7 44 24 08 70 9a 10 	movl   $0xc0109a70,0x8(%esp)
c010320e:	c0 
c010320f:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0103216:	00 
c0103217:	c7 04 24 8f 9a 10 c0 	movl   $0xc0109a8f,(%esp)
c010321e:	e8 d5 d1 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c0103223:	a1 28 50 12 c0       	mov    0xc0125028,%eax
c0103228:	8b 55 08             	mov    0x8(%ebp),%edx
c010322b:	c1 ea 0c             	shr    $0xc,%edx
c010322e:	c1 e2 05             	shl    $0x5,%edx
c0103231:	01 d0                	add    %edx,%eax
}
c0103233:	c9                   	leave  
c0103234:	c3                   	ret    

c0103235 <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0103235:	55                   	push   %ebp
c0103236:	89 e5                	mov    %esp,%ebp
c0103238:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010323b:	8b 45 08             	mov    0x8(%ebp),%eax
c010323e:	89 04 24             	mov    %eax,(%esp)
c0103241:	e8 94 ff ff ff       	call   c01031da <page2pa>
c0103246:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103249:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010324c:	c1 e8 0c             	shr    $0xc,%eax
c010324f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103252:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0103257:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010325a:	72 23                	jb     c010327f <page2kva+0x4a>
c010325c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010325f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103263:	c7 44 24 08 a0 9a 10 	movl   $0xc0109aa0,0x8(%esp)
c010326a:	c0 
c010326b:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0103272:	00 
c0103273:	c7 04 24 8f 9a 10 c0 	movl   $0xc0109a8f,(%esp)
c010327a:	e8 79 d1 ff ff       	call   c01003f8 <__panic>
c010327f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103282:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103287:	c9                   	leave  
c0103288:	c3                   	ret    

c0103289 <kva2page>:

static inline struct Page *
kva2page(void *kva) {
c0103289:	55                   	push   %ebp
c010328a:	89 e5                	mov    %esp,%ebp
c010328c:	83 ec 28             	sub    $0x28,%esp
    return pa2page(PADDR(kva));
c010328f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103292:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103295:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c010329c:	77 23                	ja     c01032c1 <kva2page+0x38>
c010329e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01032a5:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c01032ac:	c0 
c01032ad:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c01032b4:	00 
c01032b5:	c7 04 24 8f 9a 10 c0 	movl   $0xc0109a8f,(%esp)
c01032bc:	e8 37 d1 ff ff       	call   c01003f8 <__panic>
c01032c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032c4:	05 00 00 00 40       	add    $0x40000000,%eax
c01032c9:	89 04 24             	mov    %eax,(%esp)
c01032cc:	e8 1f ff ff ff       	call   c01031f0 <pa2page>
}
c01032d1:	c9                   	leave  
c01032d2:	c3                   	ret    

c01032d3 <pte2page>:

static inline struct Page *
pte2page(pte_t pte) {
c01032d3:	55                   	push   %ebp
c01032d4:	89 e5                	mov    %esp,%ebp
c01032d6:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c01032d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01032dc:	83 e0 01             	and    $0x1,%eax
c01032df:	85 c0                	test   %eax,%eax
c01032e1:	75 1c                	jne    c01032ff <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c01032e3:	c7 44 24 08 e8 9a 10 	movl   $0xc0109ae8,0x8(%esp)
c01032ea:	c0 
c01032eb:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c01032f2:	00 
c01032f3:	c7 04 24 8f 9a 10 c0 	movl   $0xc0109a8f,(%esp)
c01032fa:	e8 f9 d0 ff ff       	call   c01003f8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c01032ff:	8b 45 08             	mov    0x8(%ebp),%eax
c0103302:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103307:	89 04 24             	mov    %eax,(%esp)
c010330a:	e8 e1 fe ff ff       	call   c01031f0 <pa2page>
}
c010330f:	c9                   	leave  
c0103310:	c3                   	ret    

c0103311 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0103311:	55                   	push   %ebp
c0103312:	89 e5                	mov    %esp,%ebp
c0103314:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103317:	8b 45 08             	mov    0x8(%ebp),%eax
c010331a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c010331f:	89 04 24             	mov    %eax,(%esp)
c0103322:	e8 c9 fe ff ff       	call   c01031f0 <pa2page>
}
c0103327:	c9                   	leave  
c0103328:	c3                   	ret    

c0103329 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0103329:	55                   	push   %ebp
c010332a:	89 e5                	mov    %esp,%ebp
    return page->ref;
c010332c:	8b 45 08             	mov    0x8(%ebp),%eax
c010332f:	8b 00                	mov    (%eax),%eax
}
c0103331:	5d                   	pop    %ebp
c0103332:	c3                   	ret    

c0103333 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0103333:	55                   	push   %ebp
c0103334:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103336:	8b 45 08             	mov    0x8(%ebp),%eax
c0103339:	8b 55 0c             	mov    0xc(%ebp),%edx
c010333c:	89 10                	mov    %edx,(%eax)
}
c010333e:	90                   	nop
c010333f:	5d                   	pop    %ebp
c0103340:	c3                   	ret    

c0103341 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103341:	55                   	push   %ebp
c0103342:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103344:	8b 45 08             	mov    0x8(%ebp),%eax
c0103347:	8b 00                	mov    (%eax),%eax
c0103349:	8d 50 01             	lea    0x1(%eax),%edx
c010334c:	8b 45 08             	mov    0x8(%ebp),%eax
c010334f:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103351:	8b 45 08             	mov    0x8(%ebp),%eax
c0103354:	8b 00                	mov    (%eax),%eax
}
c0103356:	5d                   	pop    %ebp
c0103357:	c3                   	ret    

c0103358 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103358:	55                   	push   %ebp
c0103359:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c010335b:	8b 45 08             	mov    0x8(%ebp),%eax
c010335e:	8b 00                	mov    (%eax),%eax
c0103360:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103363:	8b 45 08             	mov    0x8(%ebp),%eax
c0103366:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103368:	8b 45 08             	mov    0x8(%ebp),%eax
c010336b:	8b 00                	mov    (%eax),%eax
}
c010336d:	5d                   	pop    %ebp
c010336e:	c3                   	ret    

c010336f <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c010336f:	55                   	push   %ebp
c0103370:	89 e5                	mov    %esp,%ebp
c0103372:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103375:	9c                   	pushf  
c0103376:	58                   	pop    %eax
c0103377:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c010337a:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c010337d:	25 00 02 00 00       	and    $0x200,%eax
c0103382:	85 c0                	test   %eax,%eax
c0103384:	74 0c                	je     c0103392 <__intr_save+0x23>
        intr_disable();
c0103386:	e8 65 ed ff ff       	call   c01020f0 <intr_disable>
        return 1;
c010338b:	b8 01 00 00 00       	mov    $0x1,%eax
c0103390:	eb 05                	jmp    c0103397 <__intr_save+0x28>
    }
    return 0;
c0103392:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103397:	c9                   	leave  
c0103398:	c3                   	ret    

c0103399 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0103399:	55                   	push   %ebp
c010339a:	89 e5                	mov    %esp,%ebp
c010339c:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c010339f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01033a3:	74 05                	je     c01033aa <__intr_restore+0x11>
        intr_enable();
c01033a5:	e8 3f ed ff ff       	call   c01020e9 <intr_enable>
    }
}
c01033aa:	90                   	nop
c01033ab:	c9                   	leave  
c01033ac:	c3                   	ret    

c01033ad <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c01033ad:	55                   	push   %ebp
c01033ae:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c01033b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01033b3:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c01033b6:	b8 23 00 00 00       	mov    $0x23,%eax
c01033bb:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c01033bd:	b8 23 00 00 00       	mov    $0x23,%eax
c01033c2:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c01033c4:	b8 10 00 00 00       	mov    $0x10,%eax
c01033c9:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c01033cb:	b8 10 00 00 00       	mov    $0x10,%eax
c01033d0:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c01033d2:	b8 10 00 00 00       	mov    $0x10,%eax
c01033d7:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c01033d9:	ea e0 33 10 c0 08 00 	ljmp   $0x8,$0xc01033e0
}
c01033e0:	90                   	nop
c01033e1:	5d                   	pop    %ebp
c01033e2:	c3                   	ret    

c01033e3 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c01033e3:	55                   	push   %ebp
c01033e4:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c01033e6:	8b 45 08             	mov    0x8(%ebp),%eax
c01033e9:	a3 a4 4f 12 c0       	mov    %eax,0xc0124fa4
}
c01033ee:	90                   	nop
c01033ef:	5d                   	pop    %ebp
c01033f0:	c3                   	ret    

c01033f1 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c01033f1:	55                   	push   %ebp
c01033f2:	89 e5                	mov    %esp,%ebp
c01033f4:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c01033f7:	b8 00 10 12 c0       	mov    $0xc0121000,%eax
c01033fc:	89 04 24             	mov    %eax,(%esp)
c01033ff:	e8 df ff ff ff       	call   c01033e3 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103404:	66 c7 05 a8 4f 12 c0 	movw   $0x10,0xc0124fa8
c010340b:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c010340d:	66 c7 05 28 1a 12 c0 	movw   $0x68,0xc0121a28
c0103414:	68 00 
c0103416:	b8 a0 4f 12 c0       	mov    $0xc0124fa0,%eax
c010341b:	0f b7 c0             	movzwl %ax,%eax
c010341e:	66 a3 2a 1a 12 c0    	mov    %ax,0xc0121a2a
c0103424:	b8 a0 4f 12 c0       	mov    $0xc0124fa0,%eax
c0103429:	c1 e8 10             	shr    $0x10,%eax
c010342c:	a2 2c 1a 12 c0       	mov    %al,0xc0121a2c
c0103431:	0f b6 05 2d 1a 12 c0 	movzbl 0xc0121a2d,%eax
c0103438:	24 f0                	and    $0xf0,%al
c010343a:	0c 09                	or     $0x9,%al
c010343c:	a2 2d 1a 12 c0       	mov    %al,0xc0121a2d
c0103441:	0f b6 05 2d 1a 12 c0 	movzbl 0xc0121a2d,%eax
c0103448:	24 ef                	and    $0xef,%al
c010344a:	a2 2d 1a 12 c0       	mov    %al,0xc0121a2d
c010344f:	0f b6 05 2d 1a 12 c0 	movzbl 0xc0121a2d,%eax
c0103456:	24 9f                	and    $0x9f,%al
c0103458:	a2 2d 1a 12 c0       	mov    %al,0xc0121a2d
c010345d:	0f b6 05 2d 1a 12 c0 	movzbl 0xc0121a2d,%eax
c0103464:	0c 80                	or     $0x80,%al
c0103466:	a2 2d 1a 12 c0       	mov    %al,0xc0121a2d
c010346b:	0f b6 05 2e 1a 12 c0 	movzbl 0xc0121a2e,%eax
c0103472:	24 f0                	and    $0xf0,%al
c0103474:	a2 2e 1a 12 c0       	mov    %al,0xc0121a2e
c0103479:	0f b6 05 2e 1a 12 c0 	movzbl 0xc0121a2e,%eax
c0103480:	24 ef                	and    $0xef,%al
c0103482:	a2 2e 1a 12 c0       	mov    %al,0xc0121a2e
c0103487:	0f b6 05 2e 1a 12 c0 	movzbl 0xc0121a2e,%eax
c010348e:	24 df                	and    $0xdf,%al
c0103490:	a2 2e 1a 12 c0       	mov    %al,0xc0121a2e
c0103495:	0f b6 05 2e 1a 12 c0 	movzbl 0xc0121a2e,%eax
c010349c:	0c 40                	or     $0x40,%al
c010349e:	a2 2e 1a 12 c0       	mov    %al,0xc0121a2e
c01034a3:	0f b6 05 2e 1a 12 c0 	movzbl 0xc0121a2e,%eax
c01034aa:	24 7f                	and    $0x7f,%al
c01034ac:	a2 2e 1a 12 c0       	mov    %al,0xc0121a2e
c01034b1:	b8 a0 4f 12 c0       	mov    $0xc0124fa0,%eax
c01034b6:	c1 e8 18             	shr    $0x18,%eax
c01034b9:	a2 2f 1a 12 c0       	mov    %al,0xc0121a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c01034be:	c7 04 24 30 1a 12 c0 	movl   $0xc0121a30,(%esp)
c01034c5:	e8 e3 fe ff ff       	call   c01033ad <lgdt>
c01034ca:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c01034d0:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c01034d4:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c01034d7:	90                   	nop
c01034d8:	c9                   	leave  
c01034d9:	c3                   	ret    

c01034da <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c01034da:	55                   	push   %ebp
c01034db:	89 e5                	mov    %esp,%ebp
c01034dd:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c01034e0:	c7 05 20 50 12 c0 4c 	movl   $0xc010af4c,0xc0125020
c01034e7:	af 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c01034ea:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c01034ef:	8b 00                	mov    (%eax),%eax
c01034f1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01034f5:	c7 04 24 14 9b 10 c0 	movl   $0xc0109b14,(%esp)
c01034fc:	e8 a0 cd ff ff       	call   c01002a1 <cprintf>
    pmm_manager->init();
c0103501:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c0103506:	8b 40 04             	mov    0x4(%eax),%eax
c0103509:	ff d0                	call   *%eax
}
c010350b:	90                   	nop
c010350c:	c9                   	leave  
c010350d:	c3                   	ret    

c010350e <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010350e:	55                   	push   %ebp
c010350f:	89 e5                	mov    %esp,%ebp
c0103511:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0103514:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c0103519:	8b 40 08             	mov    0x8(%eax),%eax
c010351c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010351f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103523:	8b 55 08             	mov    0x8(%ebp),%edx
c0103526:	89 14 24             	mov    %edx,(%esp)
c0103529:	ff d0                	call   *%eax
}
c010352b:	90                   	nop
c010352c:	c9                   	leave  
c010352d:	c3                   	ret    

c010352e <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010352e:	55                   	push   %ebp
c010352f:	89 e5                	mov    %esp,%ebp
c0103531:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103534:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    
    while (1)
    {
         local_intr_save(intr_flag);
c010353b:	e8 2f fe ff ff       	call   c010336f <__intr_save>
c0103540:	89 45 f0             	mov    %eax,-0x10(%ebp)
         {
              page = pmm_manager->alloc_pages(n);
c0103543:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c0103548:	8b 40 0c             	mov    0xc(%eax),%eax
c010354b:	8b 55 08             	mov    0x8(%ebp),%edx
c010354e:	89 14 24             	mov    %edx,(%esp)
c0103551:	ff d0                	call   *%eax
c0103553:	89 45 f4             	mov    %eax,-0xc(%ebp)
         }
         local_intr_restore(intr_flag);
c0103556:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103559:	89 04 24             	mov    %eax,(%esp)
c010355c:	e8 38 fe ff ff       	call   c0103399 <__intr_restore>

         if (page != NULL || n > 1 || swap_init_ok == 0) break;
c0103561:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103565:	75 2d                	jne    c0103594 <alloc_pages+0x66>
c0103567:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
c010356b:	77 27                	ja     c0103594 <alloc_pages+0x66>
c010356d:	a1 10 50 12 c0       	mov    0xc0125010,%eax
c0103572:	85 c0                	test   %eax,%eax
c0103574:	74 1e                	je     c0103594 <alloc_pages+0x66>
         
         extern struct mm_struct *check_mm_struct;
         //cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
         swap_out(check_mm_struct, n, 0);
c0103576:	8b 55 08             	mov    0x8(%ebp),%edx
c0103579:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c010357e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103585:	00 
c0103586:	89 54 24 04          	mov    %edx,0x4(%esp)
c010358a:	89 04 24             	mov    %eax,(%esp)
c010358d:	e8 88 27 00 00       	call   c0105d1a <swap_out>
    }
c0103592:	eb a7                	jmp    c010353b <alloc_pages+0xd>
    //cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
c0103594:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103597:	c9                   	leave  
c0103598:	c3                   	ret    

c0103599 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103599:	55                   	push   %ebp
c010359a:	89 e5                	mov    %esp,%ebp
c010359c:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010359f:	e8 cb fd ff ff       	call   c010336f <__intr_save>
c01035a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c01035a7:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c01035ac:	8b 40 10             	mov    0x10(%eax),%eax
c01035af:	8b 55 0c             	mov    0xc(%ebp),%edx
c01035b2:	89 54 24 04          	mov    %edx,0x4(%esp)
c01035b6:	8b 55 08             	mov    0x8(%ebp),%edx
c01035b9:	89 14 24             	mov    %edx,(%esp)
c01035bc:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c01035be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035c1:	89 04 24             	mov    %eax,(%esp)
c01035c4:	e8 d0 fd ff ff       	call   c0103399 <__intr_restore>
}
c01035c9:	90                   	nop
c01035ca:	c9                   	leave  
c01035cb:	c3                   	ret    

c01035cc <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01035cc:	55                   	push   %ebp
c01035cd:	89 e5                	mov    %esp,%ebp
c01035cf:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01035d2:	e8 98 fd ff ff       	call   c010336f <__intr_save>
c01035d7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01035da:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c01035df:	8b 40 14             	mov    0x14(%eax),%eax
c01035e2:	ff d0                	call   *%eax
c01035e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01035ea:	89 04 24             	mov    %eax,(%esp)
c01035ed:	e8 a7 fd ff ff       	call   c0103399 <__intr_restore>
    return ret;
c01035f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01035f5:	c9                   	leave  
c01035f6:	c3                   	ret    

c01035f7 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01035f7:	55                   	push   %ebp
c01035f8:	89 e5                	mov    %esp,%ebp
c01035fa:	57                   	push   %edi
c01035fb:	56                   	push   %esi
c01035fc:	53                   	push   %ebx
c01035fd:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c0103603:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c010360a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c0103611:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c0103618:	c7 04 24 2b 9b 10 c0 	movl   $0xc0109b2b,(%esp)
c010361f:	e8 7d cc ff ff       	call   c01002a1 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0103624:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010362b:	e9 22 01 00 00       	jmp    c0103752 <page_init+0x15b>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103630:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103633:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103636:	89 d0                	mov    %edx,%eax
c0103638:	c1 e0 02             	shl    $0x2,%eax
c010363b:	01 d0                	add    %edx,%eax
c010363d:	c1 e0 02             	shl    $0x2,%eax
c0103640:	01 c8                	add    %ecx,%eax
c0103642:	8b 50 08             	mov    0x8(%eax),%edx
c0103645:	8b 40 04             	mov    0x4(%eax),%eax
c0103648:	89 45 b8             	mov    %eax,-0x48(%ebp)
c010364b:	89 55 bc             	mov    %edx,-0x44(%ebp)
c010364e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103654:	89 d0                	mov    %edx,%eax
c0103656:	c1 e0 02             	shl    $0x2,%eax
c0103659:	01 d0                	add    %edx,%eax
c010365b:	c1 e0 02             	shl    $0x2,%eax
c010365e:	01 c8                	add    %ecx,%eax
c0103660:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103663:	8b 58 10             	mov    0x10(%eax),%ebx
c0103666:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103669:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010366c:	01 c8                	add    %ecx,%eax
c010366e:	11 da                	adc    %ebx,%edx
c0103670:	89 45 b0             	mov    %eax,-0x50(%ebp)
c0103673:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0103676:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103679:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010367c:	89 d0                	mov    %edx,%eax
c010367e:	c1 e0 02             	shl    $0x2,%eax
c0103681:	01 d0                	add    %edx,%eax
c0103683:	c1 e0 02             	shl    $0x2,%eax
c0103686:	01 c8                	add    %ecx,%eax
c0103688:	83 c0 14             	add    $0x14,%eax
c010368b:	8b 00                	mov    (%eax),%eax
c010368d:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0103690:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103693:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103696:	83 c0 ff             	add    $0xffffffff,%eax
c0103699:	83 d2 ff             	adc    $0xffffffff,%edx
c010369c:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c01036a2:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c01036a8:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01036ab:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01036ae:	89 d0                	mov    %edx,%eax
c01036b0:	c1 e0 02             	shl    $0x2,%eax
c01036b3:	01 d0                	add    %edx,%eax
c01036b5:	c1 e0 02             	shl    $0x2,%eax
c01036b8:	01 c8                	add    %ecx,%eax
c01036ba:	8b 48 0c             	mov    0xc(%eax),%ecx
c01036bd:	8b 58 10             	mov    0x10(%eax),%ebx
c01036c0:	8b 55 84             	mov    -0x7c(%ebp),%edx
c01036c3:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c01036c7:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c01036cd:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c01036d3:	89 44 24 14          	mov    %eax,0x14(%esp)
c01036d7:	89 54 24 18          	mov    %edx,0x18(%esp)
c01036db:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01036de:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01036e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01036e5:	89 54 24 10          	mov    %edx,0x10(%esp)
c01036e9:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01036ed:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01036f1:	c7 04 24 38 9b 10 c0 	movl   $0xc0109b38,(%esp)
c01036f8:	e8 a4 cb ff ff       	call   c01002a1 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01036fd:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103700:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103703:	89 d0                	mov    %edx,%eax
c0103705:	c1 e0 02             	shl    $0x2,%eax
c0103708:	01 d0                	add    %edx,%eax
c010370a:	c1 e0 02             	shl    $0x2,%eax
c010370d:	01 c8                	add    %ecx,%eax
c010370f:	83 c0 14             	add    $0x14,%eax
c0103712:	8b 00                	mov    (%eax),%eax
c0103714:	83 f8 01             	cmp    $0x1,%eax
c0103717:	75 36                	jne    c010374f <page_init+0x158>
            if (maxpa < end && begin < KMEMSIZE) {
c0103719:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010371c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010371f:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103722:	77 2b                	ja     c010374f <page_init+0x158>
c0103724:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103727:	72 05                	jb     c010372e <page_init+0x137>
c0103729:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c010372c:	73 21                	jae    c010374f <page_init+0x158>
c010372e:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103732:	77 1b                	ja     c010374f <page_init+0x158>
c0103734:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103738:	72 09                	jb     c0103743 <page_init+0x14c>
c010373a:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c0103741:	77 0c                	ja     c010374f <page_init+0x158>
                maxpa = end;
c0103743:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103746:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103749:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010374c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010374f:	ff 45 dc             	incl   -0x24(%ebp)
c0103752:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103755:	8b 00                	mov    (%eax),%eax
c0103757:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c010375a:	0f 8f d0 fe ff ff    	jg     c0103630 <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c0103760:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103764:	72 1d                	jb     c0103783 <page_init+0x18c>
c0103766:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c010376a:	77 09                	ja     c0103775 <page_init+0x17e>
c010376c:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c0103773:	76 0e                	jbe    c0103783 <page_init+0x18c>
        maxpa = KMEMSIZE;
c0103775:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c010377c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c0103783:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103786:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103789:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c010378d:	c1 ea 0c             	shr    $0xc,%edx
c0103790:	a3 80 4f 12 c0       	mov    %eax,0xc0124f80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103795:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c010379c:	b8 18 51 12 c0       	mov    $0xc0125118,%eax
c01037a1:	8d 50 ff             	lea    -0x1(%eax),%edx
c01037a4:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01037a7:	01 d0                	add    %edx,%eax
c01037a9:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01037ac:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01037af:	ba 00 00 00 00       	mov    $0x0,%edx
c01037b4:	f7 75 ac             	divl   -0x54(%ebp)
c01037b7:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01037ba:	29 d0                	sub    %edx,%eax
c01037bc:	a3 28 50 12 c0       	mov    %eax,0xc0125028

    for (i = 0; i < npage; i ++) {
c01037c1:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01037c8:	eb 26                	jmp    c01037f0 <page_init+0x1f9>
        SetPageReserved(pages + i);
c01037ca:	a1 28 50 12 c0       	mov    0xc0125028,%eax
c01037cf:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037d2:	c1 e2 05             	shl    $0x5,%edx
c01037d5:	01 d0                	add    %edx,%eax
c01037d7:	83 c0 04             	add    $0x4,%eax
c01037da:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01037e1:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01037e4:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01037e7:	8b 55 90             	mov    -0x70(%ebp),%edx
c01037ea:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01037ed:	ff 45 dc             	incl   -0x24(%ebp)
c01037f0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01037f3:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c01037f8:	39 c2                	cmp    %eax,%edx
c01037fa:	72 ce                	jb     c01037ca <page_init+0x1d3>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01037fc:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0103801:	c1 e0 05             	shl    $0x5,%eax
c0103804:	89 c2                	mov    %eax,%edx
c0103806:	a1 28 50 12 c0       	mov    0xc0125028,%eax
c010380b:	01 d0                	add    %edx,%eax
c010380d:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c0103810:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0103817:	77 23                	ja     c010383c <page_init+0x245>
c0103819:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010381c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103820:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c0103827:	c0 
c0103828:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c010382f:	00 
c0103830:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103837:	e8 bc cb ff ff       	call   c01003f8 <__panic>
c010383c:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010383f:	05 00 00 00 40       	add    $0x40000000,%eax
c0103844:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103847:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010384e:	e9 61 01 00 00       	jmp    c01039b4 <page_init+0x3bd>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0103853:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103856:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103859:	89 d0                	mov    %edx,%eax
c010385b:	c1 e0 02             	shl    $0x2,%eax
c010385e:	01 d0                	add    %edx,%eax
c0103860:	c1 e0 02             	shl    $0x2,%eax
c0103863:	01 c8                	add    %ecx,%eax
c0103865:	8b 50 08             	mov    0x8(%eax),%edx
c0103868:	8b 40 04             	mov    0x4(%eax),%eax
c010386b:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010386e:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103871:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103874:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103877:	89 d0                	mov    %edx,%eax
c0103879:	c1 e0 02             	shl    $0x2,%eax
c010387c:	01 d0                	add    %edx,%eax
c010387e:	c1 e0 02             	shl    $0x2,%eax
c0103881:	01 c8                	add    %ecx,%eax
c0103883:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103886:	8b 58 10             	mov    0x10(%eax),%ebx
c0103889:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010388c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010388f:	01 c8                	add    %ecx,%eax
c0103891:	11 da                	adc    %ebx,%edx
c0103893:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0103896:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0103899:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010389c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010389f:	89 d0                	mov    %edx,%eax
c01038a1:	c1 e0 02             	shl    $0x2,%eax
c01038a4:	01 d0                	add    %edx,%eax
c01038a6:	c1 e0 02             	shl    $0x2,%eax
c01038a9:	01 c8                	add    %ecx,%eax
c01038ab:	83 c0 14             	add    $0x14,%eax
c01038ae:	8b 00                	mov    (%eax),%eax
c01038b0:	83 f8 01             	cmp    $0x1,%eax
c01038b3:	0f 85 f8 00 00 00    	jne    c01039b1 <page_init+0x3ba>
            if (begin < freemem) {
c01038b9:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01038bc:	ba 00 00 00 00       	mov    $0x0,%edx
c01038c1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01038c4:	72 17                	jb     c01038dd <page_init+0x2e6>
c01038c6:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01038c9:	77 05                	ja     c01038d0 <page_init+0x2d9>
c01038cb:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01038ce:	76 0d                	jbe    c01038dd <page_init+0x2e6>
                begin = freemem;
c01038d0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01038d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01038d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01038dd:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01038e1:	72 1d                	jb     c0103900 <page_init+0x309>
c01038e3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01038e7:	77 09                	ja     c01038f2 <page_init+0x2fb>
c01038e9:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01038f0:	76 0e                	jbe    c0103900 <page_init+0x309>
                end = KMEMSIZE;
c01038f2:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01038f9:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c0103900:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103903:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103906:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103909:	0f 87 a2 00 00 00    	ja     c01039b1 <page_init+0x3ba>
c010390f:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103912:	72 09                	jb     c010391d <page_init+0x326>
c0103914:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103917:	0f 83 94 00 00 00    	jae    c01039b1 <page_init+0x3ba>
                begin = ROUNDUP(begin, PGSIZE);
c010391d:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0103924:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103927:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010392a:	01 d0                	add    %edx,%eax
c010392c:	48                   	dec    %eax
c010392d:	89 45 98             	mov    %eax,-0x68(%ebp)
c0103930:	8b 45 98             	mov    -0x68(%ebp),%eax
c0103933:	ba 00 00 00 00       	mov    $0x0,%edx
c0103938:	f7 75 9c             	divl   -0x64(%ebp)
c010393b:	8b 45 98             	mov    -0x68(%ebp),%eax
c010393e:	29 d0                	sub    %edx,%eax
c0103940:	ba 00 00 00 00       	mov    $0x0,%edx
c0103945:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103948:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c010394b:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010394e:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0103951:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103954:	ba 00 00 00 00       	mov    $0x0,%edx
c0103959:	89 c3                	mov    %eax,%ebx
c010395b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c0103961:	89 de                	mov    %ebx,%esi
c0103963:	89 d0                	mov    %edx,%eax
c0103965:	83 e0 00             	and    $0x0,%eax
c0103968:	89 c7                	mov    %eax,%edi
c010396a:	89 75 c8             	mov    %esi,-0x38(%ebp)
c010396d:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c0103970:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103973:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103976:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103979:	77 36                	ja     c01039b1 <page_init+0x3ba>
c010397b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010397e:	72 05                	jb     c0103985 <page_init+0x38e>
c0103980:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103983:	73 2c                	jae    c01039b1 <page_init+0x3ba>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103985:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103988:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010398b:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010398e:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c0103991:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103995:	c1 ea 0c             	shr    $0xc,%edx
c0103998:	89 c3                	mov    %eax,%ebx
c010399a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010399d:	89 04 24             	mov    %eax,(%esp)
c01039a0:	e8 4b f8 ff ff       	call   c01031f0 <pa2page>
c01039a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01039a9:	89 04 24             	mov    %eax,(%esp)
c01039ac:	e8 5d fb ff ff       	call   c010350e <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01039b1:	ff 45 dc             	incl   -0x24(%ebp)
c01039b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01039b7:	8b 00                	mov    (%eax),%eax
c01039b9:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01039bc:	0f 8f 91 fe ff ff    	jg     c0103853 <page_init+0x25c>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01039c2:	90                   	nop
c01039c3:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01039c9:	5b                   	pop    %ebx
c01039ca:	5e                   	pop    %esi
c01039cb:	5f                   	pop    %edi
c01039cc:	5d                   	pop    %ebp
c01039cd:	c3                   	ret    

c01039ce <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01039ce:	55                   	push   %ebp
c01039cf:	89 e5                	mov    %esp,%ebp
c01039d1:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01039d4:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039d7:	33 45 14             	xor    0x14(%ebp),%eax
c01039da:	25 ff 0f 00 00       	and    $0xfff,%eax
c01039df:	85 c0                	test   %eax,%eax
c01039e1:	74 24                	je     c0103a07 <boot_map_segment+0x39>
c01039e3:	c7 44 24 0c 76 9b 10 	movl   $0xc0109b76,0xc(%esp)
c01039ea:	c0 
c01039eb:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01039f2:	c0 
c01039f3:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01039fa:	00 
c01039fb:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103a02:	e8 f1 c9 ff ff       	call   c01003f8 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103a07:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c0103a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a11:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103a16:	89 c2                	mov    %eax,%edx
c0103a18:	8b 45 10             	mov    0x10(%ebp),%eax
c0103a1b:	01 c2                	add    %eax,%edx
c0103a1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a20:	01 d0                	add    %edx,%eax
c0103a22:	48                   	dec    %eax
c0103a23:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103a26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a29:	ba 00 00 00 00       	mov    $0x0,%edx
c0103a2e:	f7 75 f0             	divl   -0x10(%ebp)
c0103a31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103a34:	29 d0                	sub    %edx,%eax
c0103a36:	c1 e8 0c             	shr    $0xc,%eax
c0103a39:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103a42:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a4a:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103a4d:	8b 45 14             	mov    0x14(%ebp),%eax
c0103a50:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103a53:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103a56:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103a5b:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103a5e:	eb 68                	jmp    c0103ac8 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c0103a60:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103a67:	00 
c0103a68:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103a6f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a72:	89 04 24             	mov    %eax,(%esp)
c0103a75:	e8 81 01 00 00       	call   c0103bfb <get_pte>
c0103a7a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103a7d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0103a81:	75 24                	jne    c0103aa7 <boot_map_segment+0xd9>
c0103a83:	c7 44 24 0c a2 9b 10 	movl   $0xc0109ba2,0xc(%esp)
c0103a8a:	c0 
c0103a8b:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0103a92:	c0 
c0103a93:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c0103a9a:	00 
c0103a9b:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103aa2:	e8 51 c9 ff ff       	call   c01003f8 <__panic>
        *ptep = pa | PTE_P | perm;
c0103aa7:	8b 45 14             	mov    0x14(%ebp),%eax
c0103aaa:	0b 45 18             	or     0x18(%ebp),%eax
c0103aad:	83 c8 01             	or     $0x1,%eax
c0103ab0:	89 c2                	mov    %eax,%edx
c0103ab2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ab5:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0103ab7:	ff 4d f4             	decl   -0xc(%ebp)
c0103aba:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c0103ac1:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0103ac8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103acc:	75 92                	jne    c0103a60 <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c0103ace:	90                   	nop
c0103acf:	c9                   	leave  
c0103ad0:	c3                   	ret    

c0103ad1 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c0103ad1:	55                   	push   %ebp
c0103ad2:	89 e5                	mov    %esp,%ebp
c0103ad4:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c0103ad7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ade:	e8 4b fa ff ff       	call   c010352e <alloc_pages>
c0103ae3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c0103ae6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103aea:	75 1c                	jne    c0103b08 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c0103aec:	c7 44 24 08 af 9b 10 	movl   $0xc0109baf,0x8(%esp)
c0103af3:	c0 
c0103af4:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0103afb:	00 
c0103afc:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103b03:	e8 f0 c8 ff ff       	call   c01003f8 <__panic>
    }
    return page2kva(p);
c0103b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b0b:	89 04 24             	mov    %eax,(%esp)
c0103b0e:	e8 22 f7 ff ff       	call   c0103235 <page2kva>
}
c0103b13:	c9                   	leave  
c0103b14:	c3                   	ret    

c0103b15 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103b15:	55                   	push   %ebp
c0103b16:	89 e5                	mov    %esp,%ebp
c0103b18:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103b1b:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0103b20:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103b23:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103b2a:	77 23                	ja     c0103b4f <pmm_init+0x3a>
c0103b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b33:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c0103b3a:	c0 
c0103b3b:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0103b42:	00 
c0103b43:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103b4a:	e8 a9 c8 ff ff       	call   c01003f8 <__panic>
c0103b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103b52:	05 00 00 00 40       	add    $0x40000000,%eax
c0103b57:	a3 24 50 12 c0       	mov    %eax,0xc0125024
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103b5c:	e8 79 f9 ff ff       	call   c01034da <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0103b61:	e8 91 fa ff ff       	call   c01035f7 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103b66:	e8 a9 04 00 00       	call   c0104014 <check_alloc_page>

    check_pgdir();
c0103b6b:	e8 c3 04 00 00       	call   c0104033 <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0103b70:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0103b75:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0103b7b:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0103b80:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103b83:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103b8a:	77 23                	ja     c0103baf <pmm_init+0x9a>
c0103b8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103b8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103b93:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c0103b9a:	c0 
c0103b9b:	c7 44 24 04 39 01 00 	movl   $0x139,0x4(%esp)
c0103ba2:	00 
c0103ba3:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103baa:	e8 49 c8 ff ff       	call   c01003f8 <__panic>
c0103baf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bb2:	05 00 00 00 40       	add    $0x40000000,%eax
c0103bb7:	83 c8 03             	or     $0x3,%eax
c0103bba:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c0103bbc:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0103bc1:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c0103bc8:	00 
c0103bc9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103bd0:	00 
c0103bd1:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c0103bd8:	38 
c0103bd9:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c0103be0:	c0 
c0103be1:	89 04 24             	mov    %eax,(%esp)
c0103be4:	e8 e5 fd ff ff       	call   c01039ce <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c0103be9:	e8 03 f8 ff ff       	call   c01033f1 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c0103bee:	e8 dc 0a 00 00       	call   c01046cf <check_boot_pgdir>

    print_pgdir();
c0103bf3:	e8 55 0f 00 00       	call   c0104b4d <print_pgdir>

}
c0103bf8:	90                   	nop
c0103bf9:	c9                   	leave  
c0103bfa:	c3                   	ret    

c0103bfb <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103bfb:	55                   	push   %ebp
c0103bfc:	89 e5                	mov    %esp,%ebp
c0103bfe:	83 ec 38             	sub    $0x38,%esp
                          // (6) clear page content using memset
                          // (7) set page directory entry's permission
    }
    return NULL;          // (8) return page table entry
#endif
    pde_t *pdep = &pgdir[PDX(la)];
c0103c01:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103c04:	c1 e8 16             	shr    $0x16,%eax
c0103c07:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0103c0e:	8b 45 08             	mov    0x8(%ebp),%eax
c0103c11:	01 d0                	add    %edx,%eax
c0103c13:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (!(*pdep & PTE_P)) {
c0103c16:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c19:	8b 00                	mov    (%eax),%eax
c0103c1b:	83 e0 01             	and    $0x1,%eax
c0103c1e:	85 c0                	test   %eax,%eax
c0103c20:	0f 85 af 00 00 00    	jne    c0103cd5 <get_pte+0xda>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c0103c26:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103c2a:	74 15                	je     c0103c41 <get_pte+0x46>
c0103c2c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103c33:	e8 f6 f8 ff ff       	call   c010352e <alloc_pages>
c0103c38:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103c3f:	75 0a                	jne    c0103c4b <get_pte+0x50>
            return NULL;
c0103c41:	b8 00 00 00 00       	mov    $0x0,%eax
c0103c46:	e9 e7 00 00 00       	jmp    c0103d32 <get_pte+0x137>
        }
        set_page_ref(page, 1);
c0103c4b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103c52:	00 
c0103c53:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c56:	89 04 24             	mov    %eax,(%esp)
c0103c59:	e8 d5 f6 ff ff       	call   c0103333 <set_page_ref>
        uintptr_t pa = page2pa(page);
c0103c5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103c61:	89 04 24             	mov    %eax,(%esp)
c0103c64:	e8 71 f5 ff ff       	call   c01031da <page2pa>
c0103c69:	89 45 ec             	mov    %eax,-0x14(%ebp)
        memset(KADDR(pa), 0, PGSIZE);
c0103c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c6f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c72:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c75:	c1 e8 0c             	shr    $0xc,%eax
c0103c78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103c7b:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0103c80:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0103c83:	72 23                	jb     c0103ca8 <get_pte+0xad>
c0103c85:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c88:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c8c:	c7 44 24 08 a0 9a 10 	movl   $0xc0109aa0,0x8(%esp)
c0103c93:	c0 
c0103c94:	c7 44 24 04 7f 01 00 	movl   $0x17f,0x4(%esp)
c0103c9b:	00 
c0103c9c:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103ca3:	e8 50 c7 ff ff       	call   c01003f8 <__panic>
c0103ca8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103cab:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103cb0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103cb7:	00 
c0103cb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103cbf:	00 
c0103cc0:	89 04 24             	mov    %eax,(%esp)
c0103cc3:	e8 32 4c 00 00       	call   c01088fa <memset>
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c0103cc8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103ccb:	83 c8 07             	or     $0x7,%eax
c0103cce:	89 c2                	mov    %eax,%edx
c0103cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd3:	89 10                	mov    %edx,(%eax)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c0103cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103cd8:	8b 00                	mov    (%eax),%eax
c0103cda:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103cdf:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103ce2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103ce5:	c1 e8 0c             	shr    $0xc,%eax
c0103ce8:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0103ceb:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0103cf0:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103cf3:	72 23                	jb     c0103d18 <get_pte+0x11d>
c0103cf5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103cf8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103cfc:	c7 44 24 08 a0 9a 10 	movl   $0xc0109aa0,0x8(%esp)
c0103d03:	c0 
c0103d04:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0103d0b:	00 
c0103d0c:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103d13:	e8 e0 c6 ff ff       	call   c01003f8 <__panic>
c0103d18:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103d1b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103d20:	89 c2                	mov    %eax,%edx
c0103d22:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d25:	c1 e8 0c             	shr    $0xc,%eax
c0103d28:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103d2d:	c1 e0 02             	shl    $0x2,%eax
c0103d30:	01 d0                	add    %edx,%eax
}
c0103d32:	c9                   	leave  
c0103d33:	c3                   	ret    

c0103d34 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103d34:	55                   	push   %ebp
c0103d35:	89 e5                	mov    %esp,%ebp
c0103d37:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103d3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d41:	00 
c0103d42:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103d45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103d49:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d4c:	89 04 24             	mov    %eax,(%esp)
c0103d4f:	e8 a7 fe ff ff       	call   c0103bfb <get_pte>
c0103d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c0103d57:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0103d5b:	74 08                	je     c0103d65 <get_page+0x31>
        *ptep_store = ptep;
c0103d5d:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d60:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103d63:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103d65:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103d69:	74 1b                	je     c0103d86 <get_page+0x52>
c0103d6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d6e:	8b 00                	mov    (%eax),%eax
c0103d70:	83 e0 01             	and    $0x1,%eax
c0103d73:	85 c0                	test   %eax,%eax
c0103d75:	74 0f                	je     c0103d86 <get_page+0x52>
        return pte2page(*ptep);
c0103d77:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d7a:	8b 00                	mov    (%eax),%eax
c0103d7c:	89 04 24             	mov    %eax,(%esp)
c0103d7f:	e8 4f f5 ff ff       	call   c01032d3 <pte2page>
c0103d84:	eb 05                	jmp    c0103d8b <get_page+0x57>
    }
    return NULL;
c0103d86:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103d8b:	c9                   	leave  
c0103d8c:	c3                   	ret    

c0103d8d <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0103d8d:	55                   	push   %ebp
c0103d8e:	89 e5                	mov    %esp,%ebp
c0103d90:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c0103d93:	8b 45 10             	mov    0x10(%ebp),%eax
c0103d96:	8b 00                	mov    (%eax),%eax
c0103d98:	83 e0 01             	and    $0x1,%eax
c0103d9b:	85 c0                	test   %eax,%eax
c0103d9d:	74 4d                	je     c0103dec <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c0103d9f:	8b 45 10             	mov    0x10(%ebp),%eax
c0103da2:	8b 00                	mov    (%eax),%eax
c0103da4:	89 04 24             	mov    %eax,(%esp)
c0103da7:	e8 27 f5 ff ff       	call   c01032d3 <pte2page>
c0103dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (page_ref_dec(page) == 0) {
c0103daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103db2:	89 04 24             	mov    %eax,(%esp)
c0103db5:	e8 9e f5 ff ff       	call   c0103358 <page_ref_dec>
c0103dba:	85 c0                	test   %eax,%eax
c0103dbc:	75 13                	jne    c0103dd1 <page_remove_pte+0x44>
            free_page(page);
c0103dbe:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103dc5:	00 
c0103dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dc9:	89 04 24             	mov    %eax,(%esp)
c0103dcc:	e8 c8 f7 ff ff       	call   c0103599 <free_pages>
        }
        *ptep = 0;
c0103dd1:	8b 45 10             	mov    0x10(%ebp),%eax
c0103dd4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c0103dda:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ddd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103de1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103de4:	89 04 24             	mov    %eax,(%esp)
c0103de7:	e8 01 01 00 00       	call   c0103eed <tlb_invalidate>
    }
}
c0103dec:	90                   	nop
c0103ded:	c9                   	leave  
c0103dee:	c3                   	ret    

c0103def <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103def:	55                   	push   %ebp
c0103df0:	89 e5                	mov    %esp,%ebp
c0103df2:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103df5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103dfc:	00 
c0103dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e00:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e04:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e07:	89 04 24             	mov    %eax,(%esp)
c0103e0a:	e8 ec fd ff ff       	call   c0103bfb <get_pte>
c0103e0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0103e12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e16:	74 19                	je     c0103e31 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c0103e18:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e1b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103e1f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e22:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e26:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e29:	89 04 24             	mov    %eax,(%esp)
c0103e2c:	e8 5c ff ff ff       	call   c0103d8d <page_remove_pte>
    }
}
c0103e31:	90                   	nop
c0103e32:	c9                   	leave  
c0103e33:	c3                   	ret    

c0103e34 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103e34:	55                   	push   %ebp
c0103e35:	89 e5                	mov    %esp,%ebp
c0103e37:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0103e3a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103e41:	00 
c0103e42:	8b 45 10             	mov    0x10(%ebp),%eax
c0103e45:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e4c:	89 04 24             	mov    %eax,(%esp)
c0103e4f:	e8 a7 fd ff ff       	call   c0103bfb <get_pte>
c0103e54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0103e57:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103e5b:	75 0a                	jne    c0103e67 <page_insert+0x33>
        return -E_NO_MEM;
c0103e5d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103e62:	e9 84 00 00 00       	jmp    c0103eeb <page_insert+0xb7>
    }
    page_ref_inc(page);
c0103e67:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e6a:	89 04 24             	mov    %eax,(%esp)
c0103e6d:	e8 cf f4 ff ff       	call   c0103341 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103e72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e75:	8b 00                	mov    (%eax),%eax
c0103e77:	83 e0 01             	and    $0x1,%eax
c0103e7a:	85 c0                	test   %eax,%eax
c0103e7c:	74 3e                	je     c0103ebc <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0103e7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e81:	8b 00                	mov    (%eax),%eax
c0103e83:	89 04 24             	mov    %eax,(%esp)
c0103e86:	e8 48 f4 ff ff       	call   c01032d3 <pte2page>
c0103e8b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c0103e8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103e91:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0103e94:	75 0d                	jne    c0103ea3 <page_insert+0x6f>
            page_ref_dec(page);
c0103e96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103e99:	89 04 24             	mov    %eax,(%esp)
c0103e9c:	e8 b7 f4 ff ff       	call   c0103358 <page_ref_dec>
c0103ea1:	eb 19                	jmp    c0103ebc <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0103ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ea6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103eaa:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ead:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103eb1:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eb4:	89 04 24             	mov    %eax,(%esp)
c0103eb7:	e8 d1 fe ff ff       	call   c0103d8d <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0103ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103ebf:	89 04 24             	mov    %eax,(%esp)
c0103ec2:	e8 13 f3 ff ff       	call   c01031da <page2pa>
c0103ec7:	0b 45 14             	or     0x14(%ebp),%eax
c0103eca:	83 c8 01             	or     $0x1,%eax
c0103ecd:	89 c2                	mov    %eax,%edx
c0103ecf:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103ed2:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c0103ed4:	8b 45 10             	mov    0x10(%ebp),%eax
c0103ed7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ede:	89 04 24             	mov    %eax,(%esp)
c0103ee1:	e8 07 00 00 00       	call   c0103eed <tlb_invalidate>
    return 0;
c0103ee6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103eeb:	c9                   	leave  
c0103eec:	c3                   	ret    

c0103eed <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103eed:	55                   	push   %ebp
c0103eee:	89 e5                	mov    %esp,%ebp
c0103ef0:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103ef3:	0f 20 d8             	mov    %cr3,%eax
c0103ef6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0103ef9:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103efc:	8b 45 08             	mov    0x8(%ebp),%eax
c0103eff:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f02:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103f09:	77 23                	ja     c0103f2e <tlb_invalidate+0x41>
c0103f0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f12:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c0103f19:	c0 
c0103f1a:	c7 44 24 04 e4 01 00 	movl   $0x1e4,0x4(%esp)
c0103f21:	00 
c0103f22:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0103f29:	e8 ca c4 ff ff       	call   c01003f8 <__panic>
c0103f2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f31:	05 00 00 00 40       	add    $0x40000000,%eax
c0103f36:	39 c2                	cmp    %eax,%edx
c0103f38:	75 0c                	jne    c0103f46 <tlb_invalidate+0x59>
        invlpg((void *)la);
c0103f3a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103f40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f43:	0f 01 38             	invlpg (%eax)
    }
}
c0103f46:	90                   	nop
c0103f47:	c9                   	leave  
c0103f48:	c3                   	ret    

c0103f49 <pgdir_alloc_page>:

// pgdir_alloc_page - call alloc_page & page_insert functions to 
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
struct Page *
pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
c0103f49:	55                   	push   %ebp
c0103f4a:	89 e5                	mov    %esp,%ebp
c0103f4c:	83 ec 28             	sub    $0x28,%esp
    struct Page *page = alloc_page();
c0103f4f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103f56:	e8 d3 f5 ff ff       	call   c010352e <alloc_pages>
c0103f5b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (page != NULL) {
c0103f5e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103f62:	0f 84 a7 00 00 00    	je     c010400f <pgdir_alloc_page+0xc6>
        // page_insert - build the map of phy addr of an Page with the linear addr la
        // page_insert：always return 0
        if (page_insert(pgdir, page, la, perm) != 0) {
c0103f68:	8b 45 10             	mov    0x10(%ebp),%eax
c0103f6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103f6f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103f72:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103f7d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103f80:	89 04 24             	mov    %eax,(%esp)
c0103f83:	e8 ac fe ff ff       	call   c0103e34 <page_insert>
c0103f88:	85 c0                	test   %eax,%eax
c0103f8a:	74 1a                	je     c0103fa6 <pgdir_alloc_page+0x5d>
            free_page(page);
c0103f8c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103f93:	00 
c0103f94:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103f97:	89 04 24             	mov    %eax,(%esp)
c0103f9a:	e8 fa f5 ff ff       	call   c0103599 <free_pages>
            return NULL;
c0103f9f:	b8 00 00 00 00       	mov    $0x0,%eax
c0103fa4:	eb 6c                	jmp    c0104012 <pgdir_alloc_page+0xc9>
        }
        if (swap_init_ok){
c0103fa6:	a1 10 50 12 c0       	mov    0xc0125010,%eax
c0103fab:	85 c0                	test   %eax,%eax
c0103fad:	74 60                	je     c010400f <pgdir_alloc_page+0xc6>
            swap_map_swappable(check_mm_struct, la, page, 0);
c0103faf:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c0103fb4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103fbb:	00 
c0103fbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103fbf:	89 54 24 08          	mov    %edx,0x8(%esp)
c0103fc3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fc6:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103fca:	89 04 24             	mov    %eax,(%esp)
c0103fcd:	e8 fc 1c 00 00       	call   c0105cce <swap_map_swappable>
            page->pra_vaddr=la;
c0103fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fd5:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103fd8:	89 50 1c             	mov    %edx,0x1c(%eax)
            assert(page_ref(page) == 1);
c0103fdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fde:	89 04 24             	mov    %eax,(%esp)
c0103fe1:	e8 43 f3 ff ff       	call   c0103329 <page_ref>
c0103fe6:	83 f8 01             	cmp    $0x1,%eax
c0103fe9:	74 24                	je     c010400f <pgdir_alloc_page+0xc6>
c0103feb:	c7 44 24 0c c8 9b 10 	movl   $0xc0109bc8,0xc(%esp)
c0103ff2:	c0 
c0103ff3:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0103ffa:	c0 
c0103ffb:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0104002:	00 
c0104003:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010400a:	e8 e9 c3 ff ff       	call   c01003f8 <__panic>
            //cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x, pra_link_next %x in pgdir_alloc_page\n", (page-pages), page->pra_vaddr,page->pra_page_link.prev, page->pra_page_link.next);
        }

    }

    return page;
c010400f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104012:	c9                   	leave  
c0104013:	c3                   	ret    

c0104014 <check_alloc_page>:

static void
check_alloc_page(void) {
c0104014:	55                   	push   %ebp
c0104015:	89 e5                	mov    %esp,%ebp
c0104017:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c010401a:	a1 20 50 12 c0       	mov    0xc0125020,%eax
c010401f:	8b 40 18             	mov    0x18(%eax),%eax
c0104022:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104024:	c7 04 24 dc 9b 10 c0 	movl   $0xc0109bdc,(%esp)
c010402b:	e8 71 c2 ff ff       	call   c01002a1 <cprintf>
}
c0104030:	90                   	nop
c0104031:	c9                   	leave  
c0104032:	c3                   	ret    

c0104033 <check_pgdir>:

static void
check_pgdir(void) {
c0104033:	55                   	push   %ebp
c0104034:	89 e5                	mov    %esp,%ebp
c0104036:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104039:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c010403e:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104043:	76 24                	jbe    c0104069 <check_pgdir+0x36>
c0104045:	c7 44 24 0c fb 9b 10 	movl   $0xc0109bfb,0xc(%esp)
c010404c:	c0 
c010404d:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104054:	c0 
c0104055:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
c010405c:	00 
c010405d:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104064:	e8 8f c3 ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104069:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c010406e:	85 c0                	test   %eax,%eax
c0104070:	74 0e                	je     c0104080 <check_pgdir+0x4d>
c0104072:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104077:	25 ff 0f 00 00       	and    $0xfff,%eax
c010407c:	85 c0                	test   %eax,%eax
c010407e:	74 24                	je     c01040a4 <check_pgdir+0x71>
c0104080:	c7 44 24 0c 18 9c 10 	movl   $0xc0109c18,0xc(%esp)
c0104087:	c0 
c0104088:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010408f:	c0 
c0104090:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104097:	00 
c0104098:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010409f:	e8 54 c3 ff ff       	call   c01003f8 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c01040a4:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01040a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01040b0:	00 
c01040b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01040b8:	00 
c01040b9:	89 04 24             	mov    %eax,(%esp)
c01040bc:	e8 73 fc ff ff       	call   c0103d34 <get_page>
c01040c1:	85 c0                	test   %eax,%eax
c01040c3:	74 24                	je     c01040e9 <check_pgdir+0xb6>
c01040c5:	c7 44 24 0c 50 9c 10 	movl   $0xc0109c50,0xc(%esp)
c01040cc:	c0 
c01040cd:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01040d4:	c0 
c01040d5:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c01040dc:	00 
c01040dd:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01040e4:	e8 0f c3 ff ff       	call   c01003f8 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c01040e9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01040f0:	e8 39 f4 ff ff       	call   c010352e <alloc_pages>
c01040f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c01040f8:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01040fd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104104:	00 
c0104105:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010410c:	00 
c010410d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104110:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104114:	89 04 24             	mov    %eax,(%esp)
c0104117:	e8 18 fd ff ff       	call   c0103e34 <page_insert>
c010411c:	85 c0                	test   %eax,%eax
c010411e:	74 24                	je     c0104144 <check_pgdir+0x111>
c0104120:	c7 44 24 0c 78 9c 10 	movl   $0xc0109c78,0xc(%esp)
c0104127:	c0 
c0104128:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010412f:	c0 
c0104130:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0104137:	00 
c0104138:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010413f:	e8 b4 c2 ff ff       	call   c01003f8 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104144:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104149:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104150:	00 
c0104151:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104158:	00 
c0104159:	89 04 24             	mov    %eax,(%esp)
c010415c:	e8 9a fa ff ff       	call   c0103bfb <get_pte>
c0104161:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104164:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104168:	75 24                	jne    c010418e <check_pgdir+0x15b>
c010416a:	c7 44 24 0c a4 9c 10 	movl   $0xc0109ca4,0xc(%esp)
c0104171:	c0 
c0104172:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104179:	c0 
c010417a:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104181:	00 
c0104182:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104189:	e8 6a c2 ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c010418e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104191:	8b 00                	mov    (%eax),%eax
c0104193:	89 04 24             	mov    %eax,(%esp)
c0104196:	e8 38 f1 ff ff       	call   c01032d3 <pte2page>
c010419b:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010419e:	74 24                	je     c01041c4 <check_pgdir+0x191>
c01041a0:	c7 44 24 0c d1 9c 10 	movl   $0xc0109cd1,0xc(%esp)
c01041a7:	c0 
c01041a8:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01041af:	c0 
c01041b0:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c01041b7:	00 
c01041b8:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01041bf:	e8 34 c2 ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 1);
c01041c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041c7:	89 04 24             	mov    %eax,(%esp)
c01041ca:	e8 5a f1 ff ff       	call   c0103329 <page_ref>
c01041cf:	83 f8 01             	cmp    $0x1,%eax
c01041d2:	74 24                	je     c01041f8 <check_pgdir+0x1c5>
c01041d4:	c7 44 24 0c e7 9c 10 	movl   $0xc0109ce7,0xc(%esp)
c01041db:	c0 
c01041dc:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01041e3:	c0 
c01041e4:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c01041eb:	00 
c01041ec:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01041f3:	e8 00 c2 ff ff       	call   c01003f8 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c01041f8:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01041fd:	8b 00                	mov    (%eax),%eax
c01041ff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104204:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104207:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010420a:	c1 e8 0c             	shr    $0xc,%eax
c010420d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104210:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0104215:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104218:	72 23                	jb     c010423d <check_pgdir+0x20a>
c010421a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010421d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104221:	c7 44 24 08 a0 9a 10 	movl   $0xc0109aa0,0x8(%esp)
c0104228:	c0 
c0104229:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104230:	00 
c0104231:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104238:	e8 bb c1 ff ff       	call   c01003f8 <__panic>
c010423d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104240:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104245:	83 c0 04             	add    $0x4,%eax
c0104248:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c010424b:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104250:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104257:	00 
c0104258:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010425f:	00 
c0104260:	89 04 24             	mov    %eax,(%esp)
c0104263:	e8 93 f9 ff ff       	call   c0103bfb <get_pte>
c0104268:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c010426b:	74 24                	je     c0104291 <check_pgdir+0x25e>
c010426d:	c7 44 24 0c fc 9c 10 	movl   $0xc0109cfc,0xc(%esp)
c0104274:	c0 
c0104275:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010427c:	c0 
c010427d:	c7 44 24 04 18 02 00 	movl   $0x218,0x4(%esp)
c0104284:	00 
c0104285:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010428c:	e8 67 c1 ff ff       	call   c01003f8 <__panic>

    p2 = alloc_page();
c0104291:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104298:	e8 91 f2 ff ff       	call   c010352e <alloc_pages>
c010429d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c01042a0:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01042a5:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c01042ac:	00 
c01042ad:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01042b4:	00 
c01042b5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01042b8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042bc:	89 04 24             	mov    %eax,(%esp)
c01042bf:	e8 70 fb ff ff       	call   c0103e34 <page_insert>
c01042c4:	85 c0                	test   %eax,%eax
c01042c6:	74 24                	je     c01042ec <check_pgdir+0x2b9>
c01042c8:	c7 44 24 0c 24 9d 10 	movl   $0xc0109d24,0xc(%esp)
c01042cf:	c0 
c01042d0:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01042d7:	c0 
c01042d8:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c01042df:	00 
c01042e0:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01042e7:	e8 0c c1 ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01042ec:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01042f1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01042f8:	00 
c01042f9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104300:	00 
c0104301:	89 04 24             	mov    %eax,(%esp)
c0104304:	e8 f2 f8 ff ff       	call   c0103bfb <get_pte>
c0104309:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010430c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104310:	75 24                	jne    c0104336 <check_pgdir+0x303>
c0104312:	c7 44 24 0c 5c 9d 10 	movl   $0xc0109d5c,0xc(%esp)
c0104319:	c0 
c010431a:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104321:	c0 
c0104322:	c7 44 24 04 1c 02 00 	movl   $0x21c,0x4(%esp)
c0104329:	00 
c010432a:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104331:	e8 c2 c0 ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_U);
c0104336:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104339:	8b 00                	mov    (%eax),%eax
c010433b:	83 e0 04             	and    $0x4,%eax
c010433e:	85 c0                	test   %eax,%eax
c0104340:	75 24                	jne    c0104366 <check_pgdir+0x333>
c0104342:	c7 44 24 0c 8c 9d 10 	movl   $0xc0109d8c,0xc(%esp)
c0104349:	c0 
c010434a:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104351:	c0 
c0104352:	c7 44 24 04 1d 02 00 	movl   $0x21d,0x4(%esp)
c0104359:	00 
c010435a:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104361:	e8 92 c0 ff ff       	call   c01003f8 <__panic>
    assert(*ptep & PTE_W);
c0104366:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104369:	8b 00                	mov    (%eax),%eax
c010436b:	83 e0 02             	and    $0x2,%eax
c010436e:	85 c0                	test   %eax,%eax
c0104370:	75 24                	jne    c0104396 <check_pgdir+0x363>
c0104372:	c7 44 24 0c 9a 9d 10 	movl   $0xc0109d9a,0xc(%esp)
c0104379:	c0 
c010437a:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104381:	c0 
c0104382:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c0104389:	00 
c010438a:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104391:	e8 62 c0 ff ff       	call   c01003f8 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104396:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c010439b:	8b 00                	mov    (%eax),%eax
c010439d:	83 e0 04             	and    $0x4,%eax
c01043a0:	85 c0                	test   %eax,%eax
c01043a2:	75 24                	jne    c01043c8 <check_pgdir+0x395>
c01043a4:	c7 44 24 0c a8 9d 10 	movl   $0xc0109da8,0xc(%esp)
c01043ab:	c0 
c01043ac:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01043b3:	c0 
c01043b4:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c01043bb:	00 
c01043bc:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01043c3:	e8 30 c0 ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 1);
c01043c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01043cb:	89 04 24             	mov    %eax,(%esp)
c01043ce:	e8 56 ef ff ff       	call   c0103329 <page_ref>
c01043d3:	83 f8 01             	cmp    $0x1,%eax
c01043d6:	74 24                	je     c01043fc <check_pgdir+0x3c9>
c01043d8:	c7 44 24 0c be 9d 10 	movl   $0xc0109dbe,0xc(%esp)
c01043df:	c0 
c01043e0:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01043e7:	c0 
c01043e8:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01043ef:	00 
c01043f0:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01043f7:	e8 fc bf ff ff       	call   c01003f8 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c01043fc:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104401:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104408:	00 
c0104409:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104410:	00 
c0104411:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104414:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104418:	89 04 24             	mov    %eax,(%esp)
c010441b:	e8 14 fa ff ff       	call   c0103e34 <page_insert>
c0104420:	85 c0                	test   %eax,%eax
c0104422:	74 24                	je     c0104448 <check_pgdir+0x415>
c0104424:	c7 44 24 0c d0 9d 10 	movl   $0xc0109dd0,0xc(%esp)
c010442b:	c0 
c010442c:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104433:	c0 
c0104434:	c7 44 24 04 22 02 00 	movl   $0x222,0x4(%esp)
c010443b:	00 
c010443c:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104443:	e8 b0 bf ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p1) == 2);
c0104448:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010444b:	89 04 24             	mov    %eax,(%esp)
c010444e:	e8 d6 ee ff ff       	call   c0103329 <page_ref>
c0104453:	83 f8 02             	cmp    $0x2,%eax
c0104456:	74 24                	je     c010447c <check_pgdir+0x449>
c0104458:	c7 44 24 0c fc 9d 10 	movl   $0xc0109dfc,0xc(%esp)
c010445f:	c0 
c0104460:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104467:	c0 
c0104468:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c010446f:	00 
c0104470:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104477:	e8 7c bf ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c010447c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010447f:	89 04 24             	mov    %eax,(%esp)
c0104482:	e8 a2 ee ff ff       	call   c0103329 <page_ref>
c0104487:	85 c0                	test   %eax,%eax
c0104489:	74 24                	je     c01044af <check_pgdir+0x47c>
c010448b:	c7 44 24 0c 0e 9e 10 	movl   $0xc0109e0e,0xc(%esp)
c0104492:	c0 
c0104493:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010449a:	c0 
c010449b:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
c01044a2:	00 
c01044a3:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01044aa:	e8 49 bf ff ff       	call   c01003f8 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c01044af:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01044b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01044bb:	00 
c01044bc:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01044c3:	00 
c01044c4:	89 04 24             	mov    %eax,(%esp)
c01044c7:	e8 2f f7 ff ff       	call   c0103bfb <get_pte>
c01044cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01044cf:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01044d3:	75 24                	jne    c01044f9 <check_pgdir+0x4c6>
c01044d5:	c7 44 24 0c 5c 9d 10 	movl   $0xc0109d5c,0xc(%esp)
c01044dc:	c0 
c01044dd:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01044e4:	c0 
c01044e5:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c01044ec:	00 
c01044ed:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01044f4:	e8 ff be ff ff       	call   c01003f8 <__panic>
    assert(pte2page(*ptep) == p1);
c01044f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044fc:	8b 00                	mov    (%eax),%eax
c01044fe:	89 04 24             	mov    %eax,(%esp)
c0104501:	e8 cd ed ff ff       	call   c01032d3 <pte2page>
c0104506:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104509:	74 24                	je     c010452f <check_pgdir+0x4fc>
c010450b:	c7 44 24 0c d1 9c 10 	movl   $0xc0109cd1,0xc(%esp)
c0104512:	c0 
c0104513:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010451a:	c0 
c010451b:	c7 44 24 04 26 02 00 	movl   $0x226,0x4(%esp)
c0104522:	00 
c0104523:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010452a:	e8 c9 be ff ff       	call   c01003f8 <__panic>
    assert((*ptep & PTE_U) == 0);
c010452f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104532:	8b 00                	mov    (%eax),%eax
c0104534:	83 e0 04             	and    $0x4,%eax
c0104537:	85 c0                	test   %eax,%eax
c0104539:	74 24                	je     c010455f <check_pgdir+0x52c>
c010453b:	c7 44 24 0c 20 9e 10 	movl   $0xc0109e20,0xc(%esp)
c0104542:	c0 
c0104543:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010454a:	c0 
c010454b:	c7 44 24 04 27 02 00 	movl   $0x227,0x4(%esp)
c0104552:	00 
c0104553:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010455a:	e8 99 be ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, 0x0);
c010455f:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104564:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010456b:	00 
c010456c:	89 04 24             	mov    %eax,(%esp)
c010456f:	e8 7b f8 ff ff       	call   c0103def <page_remove>
    assert(page_ref(p1) == 1);
c0104574:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104577:	89 04 24             	mov    %eax,(%esp)
c010457a:	e8 aa ed ff ff       	call   c0103329 <page_ref>
c010457f:	83 f8 01             	cmp    $0x1,%eax
c0104582:	74 24                	je     c01045a8 <check_pgdir+0x575>
c0104584:	c7 44 24 0c e7 9c 10 	movl   $0xc0109ce7,0xc(%esp)
c010458b:	c0 
c010458c:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104593:	c0 
c0104594:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c010459b:	00 
c010459c:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01045a3:	e8 50 be ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c01045a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045ab:	89 04 24             	mov    %eax,(%esp)
c01045ae:	e8 76 ed ff ff       	call   c0103329 <page_ref>
c01045b3:	85 c0                	test   %eax,%eax
c01045b5:	74 24                	je     c01045db <check_pgdir+0x5a8>
c01045b7:	c7 44 24 0c 0e 9e 10 	movl   $0xc0109e0e,0xc(%esp)
c01045be:	c0 
c01045bf:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01045c6:	c0 
c01045c7:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c01045ce:	00 
c01045cf:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01045d6:	e8 1d be ff ff       	call   c01003f8 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c01045db:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01045e0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c01045e7:	00 
c01045e8:	89 04 24             	mov    %eax,(%esp)
c01045eb:	e8 ff f7 ff ff       	call   c0103def <page_remove>
    assert(page_ref(p1) == 0);
c01045f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045f3:	89 04 24             	mov    %eax,(%esp)
c01045f6:	e8 2e ed ff ff       	call   c0103329 <page_ref>
c01045fb:	85 c0                	test   %eax,%eax
c01045fd:	74 24                	je     c0104623 <check_pgdir+0x5f0>
c01045ff:	c7 44 24 0c 35 9e 10 	movl   $0xc0109e35,0xc(%esp)
c0104606:	c0 
c0104607:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010460e:	c0 
c010460f:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c0104616:	00 
c0104617:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010461e:	e8 d5 bd ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p2) == 0);
c0104623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104626:	89 04 24             	mov    %eax,(%esp)
c0104629:	e8 fb ec ff ff       	call   c0103329 <page_ref>
c010462e:	85 c0                	test   %eax,%eax
c0104630:	74 24                	je     c0104656 <check_pgdir+0x623>
c0104632:	c7 44 24 0c 0e 9e 10 	movl   $0xc0109e0e,0xc(%esp)
c0104639:	c0 
c010463a:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104641:	c0 
c0104642:	c7 44 24 04 2f 02 00 	movl   $0x22f,0x4(%esp)
c0104649:	00 
c010464a:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104651:	e8 a2 bd ff ff       	call   c01003f8 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c0104656:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c010465b:	8b 00                	mov    (%eax),%eax
c010465d:	89 04 24             	mov    %eax,(%esp)
c0104660:	e8 ac ec ff ff       	call   c0103311 <pde2page>
c0104665:	89 04 24             	mov    %eax,(%esp)
c0104668:	e8 bc ec ff ff       	call   c0103329 <page_ref>
c010466d:	83 f8 01             	cmp    $0x1,%eax
c0104670:	74 24                	je     c0104696 <check_pgdir+0x663>
c0104672:	c7 44 24 0c 48 9e 10 	movl   $0xc0109e48,0xc(%esp)
c0104679:	c0 
c010467a:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104681:	c0 
c0104682:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0104689:	00 
c010468a:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104691:	e8 62 bd ff ff       	call   c01003f8 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c0104696:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c010469b:	8b 00                	mov    (%eax),%eax
c010469d:	89 04 24             	mov    %eax,(%esp)
c01046a0:	e8 6c ec ff ff       	call   c0103311 <pde2page>
c01046a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01046ac:	00 
c01046ad:	89 04 24             	mov    %eax,(%esp)
c01046b0:	e8 e4 ee ff ff       	call   c0103599 <free_pages>
    boot_pgdir[0] = 0;
c01046b5:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01046ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01046c0:	c7 04 24 6f 9e 10 c0 	movl   $0xc0109e6f,(%esp)
c01046c7:	e8 d5 bb ff ff       	call   c01002a1 <cprintf>
}
c01046cc:	90                   	nop
c01046cd:	c9                   	leave  
c01046ce:	c3                   	ret    

c01046cf <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01046cf:	55                   	push   %ebp
c01046d0:	89 e5                	mov    %esp,%ebp
c01046d2:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01046d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01046dc:	e9 ca 00 00 00       	jmp    c01047ab <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01046e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01046e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046ea:	c1 e8 0c             	shr    $0xc,%eax
c01046ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01046f0:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c01046f5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c01046f8:	72 23                	jb     c010471d <check_boot_pgdir+0x4e>
c01046fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01046fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104701:	c7 44 24 08 a0 9a 10 	movl   $0xc0109aa0,0x8(%esp)
c0104708:	c0 
c0104709:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0104710:	00 
c0104711:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104718:	e8 db bc ff ff       	call   c01003f8 <__panic>
c010471d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104720:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104725:	89 c2                	mov    %eax,%edx
c0104727:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c010472c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104733:	00 
c0104734:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104738:	89 04 24             	mov    %eax,(%esp)
c010473b:	e8 bb f4 ff ff       	call   c0103bfb <get_pte>
c0104740:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104743:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0104747:	75 24                	jne    c010476d <check_boot_pgdir+0x9e>
c0104749:	c7 44 24 0c 8c 9e 10 	movl   $0xc0109e8c,0xc(%esp)
c0104750:	c0 
c0104751:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104758:	c0 
c0104759:	c7 44 24 04 3d 02 00 	movl   $0x23d,0x4(%esp)
c0104760:	00 
c0104761:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104768:	e8 8b bc ff ff       	call   c01003f8 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c010476d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104770:	8b 00                	mov    (%eax),%eax
c0104772:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104777:	89 c2                	mov    %eax,%edx
c0104779:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010477c:	39 c2                	cmp    %eax,%edx
c010477e:	74 24                	je     c01047a4 <check_boot_pgdir+0xd5>
c0104780:	c7 44 24 0c c9 9e 10 	movl   $0xc0109ec9,0xc(%esp)
c0104787:	c0 
c0104788:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010478f:	c0 
c0104790:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c0104797:	00 
c0104798:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010479f:	e8 54 bc ff ff       	call   c01003f8 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01047a4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01047ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01047ae:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c01047b3:	39 c2                	cmp    %eax,%edx
c01047b5:	0f 82 26 ff ff ff    	jb     c01046e1 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01047bb:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01047c0:	05 ac 0f 00 00       	add    $0xfac,%eax
c01047c5:	8b 00                	mov    (%eax),%eax
c01047c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047cc:	89 c2                	mov    %eax,%edx
c01047ce:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01047d3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01047d6:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c01047dd:	77 23                	ja     c0104802 <check_boot_pgdir+0x133>
c01047df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047e6:	c7 44 24 08 c4 9a 10 	movl   $0xc0109ac4,0x8(%esp)
c01047ed:	c0 
c01047ee:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c01047f5:	00 
c01047f6:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01047fd:	e8 f6 bb ff ff       	call   c01003f8 <__panic>
c0104802:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104805:	05 00 00 00 40       	add    $0x40000000,%eax
c010480a:	39 c2                	cmp    %eax,%edx
c010480c:	74 24                	je     c0104832 <check_boot_pgdir+0x163>
c010480e:	c7 44 24 0c e0 9e 10 	movl   $0xc0109ee0,0xc(%esp)
c0104815:	c0 
c0104816:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010481d:	c0 
c010481e:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c0104825:	00 
c0104826:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010482d:	e8 c6 bb ff ff       	call   c01003f8 <__panic>

    assert(boot_pgdir[0] == 0);
c0104832:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104837:	8b 00                	mov    (%eax),%eax
c0104839:	85 c0                	test   %eax,%eax
c010483b:	74 24                	je     c0104861 <check_boot_pgdir+0x192>
c010483d:	c7 44 24 0c 14 9f 10 	movl   $0xc0109f14,0xc(%esp)
c0104844:	c0 
c0104845:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010484c:	c0 
c010484d:	c7 44 24 04 43 02 00 	movl   $0x243,0x4(%esp)
c0104854:	00 
c0104855:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010485c:	e8 97 bb ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    p = alloc_page();
c0104861:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104868:	e8 c1 ec ff ff       	call   c010352e <alloc_pages>
c010486d:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c0104870:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104875:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c010487c:	00 
c010487d:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c0104884:	00 
c0104885:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104888:	89 54 24 04          	mov    %edx,0x4(%esp)
c010488c:	89 04 24             	mov    %eax,(%esp)
c010488f:	e8 a0 f5 ff ff       	call   c0103e34 <page_insert>
c0104894:	85 c0                	test   %eax,%eax
c0104896:	74 24                	je     c01048bc <check_boot_pgdir+0x1ed>
c0104898:	c7 44 24 0c 28 9f 10 	movl   $0xc0109f28,0xc(%esp)
c010489f:	c0 
c01048a0:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01048a7:	c0 
c01048a8:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
c01048af:	00 
c01048b0:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01048b7:	e8 3c bb ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 1);
c01048bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01048bf:	89 04 24             	mov    %eax,(%esp)
c01048c2:	e8 62 ea ff ff       	call   c0103329 <page_ref>
c01048c7:	83 f8 01             	cmp    $0x1,%eax
c01048ca:	74 24                	je     c01048f0 <check_boot_pgdir+0x221>
c01048cc:	c7 44 24 0c 56 9f 10 	movl   $0xc0109f56,0xc(%esp)
c01048d3:	c0 
c01048d4:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01048db:	c0 
c01048dc:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
c01048e3:	00 
c01048e4:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01048eb:	e8 08 bb ff ff       	call   c01003f8 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c01048f0:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c01048f5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01048fc:	00 
c01048fd:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c0104904:	00 
c0104905:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104908:	89 54 24 04          	mov    %edx,0x4(%esp)
c010490c:	89 04 24             	mov    %eax,(%esp)
c010490f:	e8 20 f5 ff ff       	call   c0103e34 <page_insert>
c0104914:	85 c0                	test   %eax,%eax
c0104916:	74 24                	je     c010493c <check_boot_pgdir+0x26d>
c0104918:	c7 44 24 0c 68 9f 10 	movl   $0xc0109f68,0xc(%esp)
c010491f:	c0 
c0104920:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104927:	c0 
c0104928:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
c010492f:	00 
c0104930:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104937:	e8 bc ba ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p) == 2);
c010493c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010493f:	89 04 24             	mov    %eax,(%esp)
c0104942:	e8 e2 e9 ff ff       	call   c0103329 <page_ref>
c0104947:	83 f8 02             	cmp    $0x2,%eax
c010494a:	74 24                	je     c0104970 <check_boot_pgdir+0x2a1>
c010494c:	c7 44 24 0c 9f 9f 10 	movl   $0xc0109f9f,0xc(%esp)
c0104953:	c0 
c0104954:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c010495b:	c0 
c010495c:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
c0104963:	00 
c0104964:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c010496b:	e8 88 ba ff ff       	call   c01003f8 <__panic>

    const char *str = "ucore: Hello world!!";
c0104970:	c7 45 dc b0 9f 10 c0 	movl   $0xc0109fb0,-0x24(%ebp)
    strcpy((void *)0x100, str);
c0104977:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010497a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010497e:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104985:	e8 a6 3c 00 00       	call   c0108630 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c010498a:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c0104991:	00 
c0104992:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104999:	e8 09 3d 00 00       	call   c01086a7 <strcmp>
c010499e:	85 c0                	test   %eax,%eax
c01049a0:	74 24                	je     c01049c6 <check_boot_pgdir+0x2f7>
c01049a2:	c7 44 24 0c c8 9f 10 	movl   $0xc0109fc8,0xc(%esp)
c01049a9:	c0 
c01049aa:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01049b1:	c0 
c01049b2:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
c01049b9:	00 
c01049ba:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c01049c1:	e8 32 ba ff ff       	call   c01003f8 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01049c6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01049c9:	89 04 24             	mov    %eax,(%esp)
c01049cc:	e8 64 e8 ff ff       	call   c0103235 <page2kva>
c01049d1:	05 00 01 00 00       	add    $0x100,%eax
c01049d6:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01049d9:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01049e0:	e8 f5 3b 00 00       	call   c01085da <strlen>
c01049e5:	85 c0                	test   %eax,%eax
c01049e7:	74 24                	je     c0104a0d <check_boot_pgdir+0x33e>
c01049e9:	c7 44 24 0c 00 a0 10 	movl   $0xc010a000,0xc(%esp)
c01049f0:	c0 
c01049f1:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c01049f8:	c0 
c01049f9:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
c0104a00:	00 
c0104a01:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104a08:	e8 eb b9 ff ff       	call   c01003f8 <__panic>

    free_page(p);
c0104a0d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a14:	00 
c0104a15:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104a18:	89 04 24             	mov    %eax,(%esp)
c0104a1b:	e8 79 eb ff ff       	call   c0103599 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104a20:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104a25:	8b 00                	mov    (%eax),%eax
c0104a27:	89 04 24             	mov    %eax,(%esp)
c0104a2a:	e8 e2 e8 ff ff       	call   c0103311 <pde2page>
c0104a2f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104a36:	00 
c0104a37:	89 04 24             	mov    %eax,(%esp)
c0104a3a:	e8 5a eb ff ff       	call   c0103599 <free_pages>
    boot_pgdir[0] = 0;
c0104a3f:	a1 e0 19 12 c0       	mov    0xc01219e0,%eax
c0104a44:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104a4a:	c7 04 24 24 a0 10 c0 	movl   $0xc010a024,(%esp)
c0104a51:	e8 4b b8 ff ff       	call   c01002a1 <cprintf>
}
c0104a56:	90                   	nop
c0104a57:	c9                   	leave  
c0104a58:	c3                   	ret    

c0104a59 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0104a59:	55                   	push   %ebp
c0104a5a:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0104a5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a5f:	83 e0 04             	and    $0x4,%eax
c0104a62:	85 c0                	test   %eax,%eax
c0104a64:	74 04                	je     c0104a6a <perm2str+0x11>
c0104a66:	b0 75                	mov    $0x75,%al
c0104a68:	eb 02                	jmp    c0104a6c <perm2str+0x13>
c0104a6a:	b0 2d                	mov    $0x2d,%al
c0104a6c:	a2 08 50 12 c0       	mov    %al,0xc0125008
    str[1] = 'r';
c0104a71:	c6 05 09 50 12 c0 72 	movb   $0x72,0xc0125009
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0104a78:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a7b:	83 e0 02             	and    $0x2,%eax
c0104a7e:	85 c0                	test   %eax,%eax
c0104a80:	74 04                	je     c0104a86 <perm2str+0x2d>
c0104a82:	b0 77                	mov    $0x77,%al
c0104a84:	eb 02                	jmp    c0104a88 <perm2str+0x2f>
c0104a86:	b0 2d                	mov    $0x2d,%al
c0104a88:	a2 0a 50 12 c0       	mov    %al,0xc012500a
    str[3] = '\0';
c0104a8d:	c6 05 0b 50 12 c0 00 	movb   $0x0,0xc012500b
    return str;
c0104a94:	b8 08 50 12 c0       	mov    $0xc0125008,%eax
}
c0104a99:	5d                   	pop    %ebp
c0104a9a:	c3                   	ret    

c0104a9b <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c0104a9b:	55                   	push   %ebp
c0104a9c:	89 e5                	mov    %esp,%ebp
c0104a9e:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c0104aa1:	8b 45 10             	mov    0x10(%ebp),%eax
c0104aa4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104aa7:	72 0d                	jb     c0104ab6 <get_pgtable_items+0x1b>
        return 0;
c0104aa9:	b8 00 00 00 00       	mov    $0x0,%eax
c0104aae:	e9 98 00 00 00       	jmp    c0104b4b <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c0104ab3:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c0104ab6:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ab9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104abc:	73 18                	jae    c0104ad6 <get_pgtable_items+0x3b>
c0104abe:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ac1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104ac8:	8b 45 14             	mov    0x14(%ebp),%eax
c0104acb:	01 d0                	add    %edx,%eax
c0104acd:	8b 00                	mov    (%eax),%eax
c0104acf:	83 e0 01             	and    $0x1,%eax
c0104ad2:	85 c0                	test   %eax,%eax
c0104ad4:	74 dd                	je     c0104ab3 <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c0104ad6:	8b 45 10             	mov    0x10(%ebp),%eax
c0104ad9:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104adc:	73 68                	jae    c0104b46 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0104ade:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c0104ae2:	74 08                	je     c0104aec <get_pgtable_items+0x51>
            *left_store = start;
c0104ae4:	8b 45 18             	mov    0x18(%ebp),%eax
c0104ae7:	8b 55 10             	mov    0x10(%ebp),%edx
c0104aea:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0104aec:	8b 45 10             	mov    0x10(%ebp),%eax
c0104aef:	8d 50 01             	lea    0x1(%eax),%edx
c0104af2:	89 55 10             	mov    %edx,0x10(%ebp)
c0104af5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104afc:	8b 45 14             	mov    0x14(%ebp),%eax
c0104aff:	01 d0                	add    %edx,%eax
c0104b01:	8b 00                	mov    (%eax),%eax
c0104b03:	83 e0 07             	and    $0x7,%eax
c0104b06:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104b09:	eb 03                	jmp    c0104b0e <get_pgtable_items+0x73>
            start ++;
c0104b0b:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104b0e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b11:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104b14:	73 1d                	jae    c0104b33 <get_pgtable_items+0x98>
c0104b16:	8b 45 10             	mov    0x10(%ebp),%eax
c0104b19:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104b20:	8b 45 14             	mov    0x14(%ebp),%eax
c0104b23:	01 d0                	add    %edx,%eax
c0104b25:	8b 00                	mov    (%eax),%eax
c0104b27:	83 e0 07             	and    $0x7,%eax
c0104b2a:	89 c2                	mov    %eax,%edx
c0104b2c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104b2f:	39 c2                	cmp    %eax,%edx
c0104b31:	74 d8                	je     c0104b0b <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c0104b33:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0104b37:	74 08                	je     c0104b41 <get_pgtable_items+0xa6>
            *right_store = start;
c0104b39:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104b3c:	8b 55 10             	mov    0x10(%ebp),%edx
c0104b3f:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104b41:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104b44:	eb 05                	jmp    c0104b4b <get_pgtable_items+0xb0>
    }
    return 0;
c0104b46:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104b4b:	c9                   	leave  
c0104b4c:	c3                   	ret    

c0104b4d <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104b4d:	55                   	push   %ebp
c0104b4e:	89 e5                	mov    %esp,%ebp
c0104b50:	57                   	push   %edi
c0104b51:	56                   	push   %esi
c0104b52:	53                   	push   %ebx
c0104b53:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0104b56:	c7 04 24 44 a0 10 c0 	movl   $0xc010a044,(%esp)
c0104b5d:	e8 3f b7 ff ff       	call   c01002a1 <cprintf>
    size_t left, right = 0, perm;
c0104b62:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104b69:	e9 fa 00 00 00       	jmp    c0104c68 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104b6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b71:	89 04 24             	mov    %eax,(%esp)
c0104b74:	e8 e0 fe ff ff       	call   c0104a59 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0104b79:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0104b7c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b7f:	29 d1                	sub    %edx,%ecx
c0104b81:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c0104b83:	89 d6                	mov    %edx,%esi
c0104b85:	c1 e6 16             	shl    $0x16,%esi
c0104b88:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104b8b:	89 d3                	mov    %edx,%ebx
c0104b8d:	c1 e3 16             	shl    $0x16,%ebx
c0104b90:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b93:	89 d1                	mov    %edx,%ecx
c0104b95:	c1 e1 16             	shl    $0x16,%ecx
c0104b98:	8b 7d dc             	mov    -0x24(%ebp),%edi
c0104b9b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b9e:	29 d7                	sub    %edx,%edi
c0104ba0:	89 fa                	mov    %edi,%edx
c0104ba2:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104ba6:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104baa:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104bae:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104bb2:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104bb6:	c7 04 24 75 a0 10 c0 	movl   $0xc010a075,(%esp)
c0104bbd:	e8 df b6 ff ff       	call   c01002a1 <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c0104bc2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104bc5:	c1 e0 0a             	shl    $0xa,%eax
c0104bc8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104bcb:	eb 54                	jmp    c0104c21 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104bcd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104bd0:	89 04 24             	mov    %eax,(%esp)
c0104bd3:	e8 81 fe ff ff       	call   c0104a59 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104bd8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104bdb:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104bde:	29 d1                	sub    %edx,%ecx
c0104be0:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104be2:	89 d6                	mov    %edx,%esi
c0104be4:	c1 e6 0c             	shl    $0xc,%esi
c0104be7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104bea:	89 d3                	mov    %edx,%ebx
c0104bec:	c1 e3 0c             	shl    $0xc,%ebx
c0104bef:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104bf2:	89 d1                	mov    %edx,%ecx
c0104bf4:	c1 e1 0c             	shl    $0xc,%ecx
c0104bf7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104bfa:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104bfd:	29 d7                	sub    %edx,%edi
c0104bff:	89 fa                	mov    %edi,%edx
c0104c01:	89 44 24 14          	mov    %eax,0x14(%esp)
c0104c05:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104c09:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104c0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104c11:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104c15:	c7 04 24 94 a0 10 c0 	movl   $0xc010a094,(%esp)
c0104c1c:	e8 80 b6 ff ff       	call   c01002a1 <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104c21:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c0104c26:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104c29:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104c2c:	89 d3                	mov    %edx,%ebx
c0104c2e:	c1 e3 0a             	shl    $0xa,%ebx
c0104c31:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104c34:	89 d1                	mov    %edx,%ecx
c0104c36:	c1 e1 0a             	shl    $0xa,%ecx
c0104c39:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104c3c:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104c40:	8d 55 d8             	lea    -0x28(%ebp),%edx
c0104c43:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104c47:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104c4b:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c4f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104c53:	89 0c 24             	mov    %ecx,(%esp)
c0104c56:	e8 40 fe ff ff       	call   c0104a9b <get_pgtable_items>
c0104c5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c5e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104c62:	0f 85 65 ff ff ff    	jne    c0104bcd <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0104c68:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0104c6d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104c70:	8d 55 dc             	lea    -0x24(%ebp),%edx
c0104c73:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104c77:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0104c7a:	89 54 24 10          	mov    %edx,0x10(%esp)
c0104c7e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0104c82:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104c86:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c0104c8d:	00 
c0104c8e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0104c95:	e8 01 fe ff ff       	call   c0104a9b <get_pgtable_items>
c0104c9a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104c9d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0104ca1:	0f 85 c7 fe ff ff    	jne    c0104b6e <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c0104ca7:	c7 04 24 b8 a0 10 c0 	movl   $0xc010a0b8,(%esp)
c0104cae:	e8 ee b5 ff ff       	call   c01002a1 <cprintf>
}
c0104cb3:	90                   	nop
c0104cb4:	83 c4 4c             	add    $0x4c,%esp
c0104cb7:	5b                   	pop    %ebx
c0104cb8:	5e                   	pop    %esi
c0104cb9:	5f                   	pop    %edi
c0104cba:	5d                   	pop    %ebp
c0104cbb:	c3                   	ret    

c0104cbc <kmalloc>:

void *
kmalloc(size_t n) {
c0104cbc:	55                   	push   %ebp
c0104cbd:	89 e5                	mov    %esp,%ebp
c0104cbf:	83 ec 28             	sub    $0x28,%esp
    void * ptr=NULL;
c0104cc2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    struct Page *base=NULL;
c0104cc9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    assert(n > 0 && n < 1024*0124);
c0104cd0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104cd4:	74 09                	je     c0104cdf <kmalloc+0x23>
c0104cd6:	81 7d 08 ff 4f 01 00 	cmpl   $0x14fff,0x8(%ebp)
c0104cdd:	76 24                	jbe    c0104d03 <kmalloc+0x47>
c0104cdf:	c7 44 24 0c e9 a0 10 	movl   $0xc010a0e9,0xc(%esp)
c0104ce6:	c0 
c0104ce7:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104cee:	c0 
c0104cef:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
c0104cf6:	00 
c0104cf7:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104cfe:	e8 f5 b6 ff ff       	call   c01003f8 <__panic>
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0104d03:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d06:	05 ff 0f 00 00       	add    $0xfff,%eax
c0104d0b:	c1 e8 0c             	shr    $0xc,%eax
c0104d0e:	89 45 ec             	mov    %eax,-0x14(%ebp)
    base = alloc_pages(num_pages);
c0104d11:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104d14:	89 04 24             	mov    %eax,(%esp)
c0104d17:	e8 12 e8 ff ff       	call   c010352e <alloc_pages>
c0104d1c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(base != NULL);
c0104d1f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d23:	75 24                	jne    c0104d49 <kmalloc+0x8d>
c0104d25:	c7 44 24 0c 00 a1 10 	movl   $0xc010a100,0xc(%esp)
c0104d2c:	c0 
c0104d2d:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104d34:	c0 
c0104d35:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
c0104d3c:	00 
c0104d3d:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104d44:	e8 af b6 ff ff       	call   c01003f8 <__panic>
    ptr=page2kva(base);
c0104d49:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d4c:	89 04 24             	mov    %eax,(%esp)
c0104d4f:	e8 e1 e4 ff ff       	call   c0103235 <page2kva>
c0104d54:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ptr;
c0104d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104d5a:	c9                   	leave  
c0104d5b:	c3                   	ret    

c0104d5c <kfree>:

void 
kfree(void *ptr, size_t n) {
c0104d5c:	55                   	push   %ebp
c0104d5d:	89 e5                	mov    %esp,%ebp
c0104d5f:	83 ec 28             	sub    $0x28,%esp
    assert(n > 0 && n < 1024*0124);
c0104d62:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104d66:	74 09                	je     c0104d71 <kfree+0x15>
c0104d68:	81 7d 0c ff 4f 01 00 	cmpl   $0x14fff,0xc(%ebp)
c0104d6f:	76 24                	jbe    c0104d95 <kfree+0x39>
c0104d71:	c7 44 24 0c e9 a0 10 	movl   $0xc010a0e9,0xc(%esp)
c0104d78:	c0 
c0104d79:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104d80:	c0 
c0104d81:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
c0104d88:	00 
c0104d89:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104d90:	e8 63 b6 ff ff       	call   c01003f8 <__panic>
    assert(ptr != NULL);
c0104d95:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104d99:	75 24                	jne    c0104dbf <kfree+0x63>
c0104d9b:	c7 44 24 0c 0d a1 10 	movl   $0xc010a10d,0xc(%esp)
c0104da2:	c0 
c0104da3:	c7 44 24 08 8d 9b 10 	movl   $0xc0109b8d,0x8(%esp)
c0104daa:	c0 
c0104dab:	c7 44 24 04 a8 02 00 	movl   $0x2a8,0x4(%esp)
c0104db2:	00 
c0104db3:	c7 04 24 68 9b 10 c0 	movl   $0xc0109b68,(%esp)
c0104dba:	e8 39 b6 ff ff       	call   c01003f8 <__panic>
    struct Page *base=NULL;
c0104dbf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    int num_pages=(n+PGSIZE-1)/PGSIZE;
c0104dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104dc9:	05 ff 0f 00 00       	add    $0xfff,%eax
c0104dce:	c1 e8 0c             	shr    $0xc,%eax
c0104dd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    base = kva2page(ptr);
c0104dd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104dd7:	89 04 24             	mov    %eax,(%esp)
c0104dda:	e8 aa e4 ff ff       	call   c0103289 <kva2page>
c0104ddf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    free_pages(base, num_pages);
c0104de2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104de5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104de9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104dec:	89 04 24             	mov    %eax,(%esp)
c0104def:	e8 a5 e7 ff ff       	call   c0103599 <free_pages>
}
c0104df4:	90                   	nop
c0104df5:	c9                   	leave  
c0104df6:	c3                   	ret    

c0104df7 <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0104df7:	55                   	push   %ebp
c0104df8:	89 e5                	mov    %esp,%ebp
c0104dfa:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0104dfd:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e00:	c1 e8 0c             	shr    $0xc,%eax
c0104e03:	89 c2                	mov    %eax,%edx
c0104e05:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0104e0a:	39 c2                	cmp    %eax,%edx
c0104e0c:	72 1c                	jb     c0104e2a <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0104e0e:	c7 44 24 08 1c a1 10 	movl   $0xc010a11c,0x8(%esp)
c0104e15:	c0 
c0104e16:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0104e1d:	00 
c0104e1e:	c7 04 24 3b a1 10 c0 	movl   $0xc010a13b,(%esp)
c0104e25:	e8 ce b5 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c0104e2a:	a1 28 50 12 c0       	mov    0xc0125028,%eax
c0104e2f:	8b 55 08             	mov    0x8(%ebp),%edx
c0104e32:	c1 ea 0c             	shr    $0xc,%edx
c0104e35:	c1 e2 05             	shl    $0x5,%edx
c0104e38:	01 d0                	add    %edx,%eax
}
c0104e3a:	c9                   	leave  
c0104e3b:	c3                   	ret    

c0104e3c <pde2page>:
    }
    return pa2page(PTE_ADDR(pte));
}

static inline struct Page *
pde2page(pde_t pde) {
c0104e3c:	55                   	push   %ebp
c0104e3d:	89 e5                	mov    %esp,%ebp
c0104e3f:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0104e42:	8b 45 08             	mov    0x8(%ebp),%eax
c0104e45:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104e4a:	89 04 24             	mov    %eax,(%esp)
c0104e4d:	e8 a5 ff ff ff       	call   c0104df7 <pa2page>
}
c0104e52:	c9                   	leave  
c0104e53:	c3                   	ret    

c0104e54 <mm_create>:
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
struct mm_struct *
mm_create(void) {
c0104e54:	55                   	push   %ebp
c0104e55:	89 e5                	mov    %esp,%ebp
c0104e57:	83 ec 28             	sub    $0x28,%esp
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
c0104e5a:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104e61:	e8 56 fe ff ff       	call   c0104cbc <kmalloc>
c0104e66:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (mm != NULL) {
c0104e69:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e6d:	74 58                	je     c0104ec7 <mm_create+0x73>
        list_init(&(mm->mmap_list));
c0104e6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e72:	89 45 f0             	mov    %eax,-0x10(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104e75:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e78:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0104e7b:	89 50 04             	mov    %edx,0x4(%eax)
c0104e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e81:	8b 50 04             	mov    0x4(%eax),%edx
c0104e84:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e87:	89 10                	mov    %edx,(%eax)
        mm->mmap_cache = NULL;
c0104e89:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e8c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        mm->pgdir = NULL;
c0104e93:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e96:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        mm->map_count = 0;
c0104e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ea0:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)

        if (swap_init_ok) swap_init_mm(mm);
c0104ea7:	a1 10 50 12 c0       	mov    0xc0125010,%eax
c0104eac:	85 c0                	test   %eax,%eax
c0104eae:	74 0d                	je     c0104ebd <mm_create+0x69>
c0104eb0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb3:	89 04 24             	mov    %eax,(%esp)
c0104eb6:	e8 e3 0d 00 00       	call   c0105c9e <swap_init_mm>
c0104ebb:	eb 0a                	jmp    c0104ec7 <mm_create+0x73>
        else mm->sm_priv = NULL;
c0104ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ec0:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
    }
    return mm;
c0104ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104eca:	c9                   	leave  
c0104ecb:	c3                   	ret    

c0104ecc <vma_create>:

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
c0104ecc:	55                   	push   %ebp
c0104ecd:	89 e5                	mov    %esp,%ebp
c0104ecf:	83 ec 28             	sub    $0x28,%esp
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
c0104ed2:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
c0104ed9:	e8 de fd ff ff       	call   c0104cbc <kmalloc>
c0104ede:	89 45 f4             	mov    %eax,-0xc(%ebp)

    if (vma != NULL) {
c0104ee1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104ee5:	74 1b                	je     c0104f02 <vma_create+0x36>
        vma->vm_start = vm_start;
c0104ee7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eea:	8b 55 08             	mov    0x8(%ebp),%edx
c0104eed:	89 50 04             	mov    %edx,0x4(%eax)
        vma->vm_end = vm_end;
c0104ef0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ef3:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104ef6:	89 50 08             	mov    %edx,0x8(%eax)
        vma->vm_flags = vm_flags;
c0104ef9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104efc:	8b 55 10             	mov    0x10(%ebp),%edx
c0104eff:	89 50 0c             	mov    %edx,0xc(%eax)
    }
    return vma;
c0104f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104f05:	c9                   	leave  
c0104f06:	c3                   	ret    

c0104f07 <find_vma>:


// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
c0104f07:	55                   	push   %ebp
c0104f08:	89 e5                	mov    %esp,%ebp
c0104f0a:	83 ec 20             	sub    $0x20,%esp
    struct vma_struct *vma = NULL;
c0104f0d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    if (mm != NULL) {
c0104f14:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0104f18:	0f 84 95 00 00 00    	je     c0104fb3 <find_vma+0xac>
        vma = mm->mmap_cache;
c0104f1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f21:	8b 40 08             	mov    0x8(%eax),%eax
c0104f24:	89 45 fc             	mov    %eax,-0x4(%ebp)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
c0104f27:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104f2b:	74 16                	je     c0104f43 <find_vma+0x3c>
c0104f2d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104f30:	8b 40 04             	mov    0x4(%eax),%eax
c0104f33:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104f36:	77 0b                	ja     c0104f43 <find_vma+0x3c>
c0104f38:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104f3b:	8b 40 08             	mov    0x8(%eax),%eax
c0104f3e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104f41:	77 61                	ja     c0104fa4 <find_vma+0x9d>
                bool found = 0;
c0104f43:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
                list_entry_t *list = &(mm->mmap_list), *le = list;
c0104f4a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104f4d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f53:	89 45 f4             	mov    %eax,-0xc(%ebp)
                while ((le = list_next(le)) != list) {
c0104f56:	eb 28                	jmp    c0104f80 <find_vma+0x79>
                    vma = le2vma(le, list_link);
c0104f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f5b:	83 e8 10             	sub    $0x10,%eax
c0104f5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
c0104f61:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104f64:	8b 40 04             	mov    0x4(%eax),%eax
c0104f67:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104f6a:	77 14                	ja     c0104f80 <find_vma+0x79>
c0104f6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104f6f:	8b 40 08             	mov    0x8(%eax),%eax
c0104f72:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104f75:	76 09                	jbe    c0104f80 <find_vma+0x79>
                        found = 1;
c0104f77:	c7 45 f8 01 00 00 00 	movl   $0x1,-0x8(%ebp)
                        break;
c0104f7e:	eb 17                	jmp    c0104f97 <find_vma+0x90>
c0104f80:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f83:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104f86:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104f89:	8b 40 04             	mov    0x4(%eax),%eax
    if (mm != NULL) {
        vma = mm->mmap_cache;
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
                bool found = 0;
                list_entry_t *list = &(mm->mmap_list), *le = list;
                while ((le = list_next(le)) != list) {
c0104f8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f92:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104f95:	75 c1                	jne    c0104f58 <find_vma+0x51>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
c0104f97:	83 7d f8 00          	cmpl   $0x0,-0x8(%ebp)
c0104f9b:	75 07                	jne    c0104fa4 <find_vma+0x9d>
                    vma = NULL;
c0104f9d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
                }
        }
        if (vma != NULL) {
c0104fa4:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0104fa8:	74 09                	je     c0104fb3 <find_vma+0xac>
            mm->mmap_cache = vma;
c0104faa:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fad:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0104fb0:	89 50 08             	mov    %edx,0x8(%eax)
        }
    }
    return vma;
c0104fb3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0104fb6:	c9                   	leave  
c0104fb7:	c3                   	ret    

c0104fb8 <check_vma_overlap>:


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
c0104fb8:	55                   	push   %ebp
c0104fb9:	89 e5                	mov    %esp,%ebp
c0104fbb:	83 ec 18             	sub    $0x18,%esp
    assert(prev->vm_start < prev->vm_end);
c0104fbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fc1:	8b 50 04             	mov    0x4(%eax),%edx
c0104fc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104fc7:	8b 40 08             	mov    0x8(%eax),%eax
c0104fca:	39 c2                	cmp    %eax,%edx
c0104fcc:	72 24                	jb     c0104ff2 <check_vma_overlap+0x3a>
c0104fce:	c7 44 24 0c 49 a1 10 	movl   $0xc010a149,0xc(%esp)
c0104fd5:	c0 
c0104fd6:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0104fdd:	c0 
c0104fde:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0104fe5:	00 
c0104fe6:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0104fed:	e8 06 b4 ff ff       	call   c01003f8 <__panic>
    assert(prev->vm_end <= next->vm_start);
c0104ff2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ff5:	8b 50 08             	mov    0x8(%eax),%edx
c0104ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ffb:	8b 40 04             	mov    0x4(%eax),%eax
c0104ffe:	39 c2                	cmp    %eax,%edx
c0105000:	76 24                	jbe    c0105026 <check_vma_overlap+0x6e>
c0105002:	c7 44 24 0c 8c a1 10 	movl   $0xc010a18c,0xc(%esp)
c0105009:	c0 
c010500a:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105011:	c0 
c0105012:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c0105019:	00 
c010501a:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105021:	e8 d2 b3 ff ff       	call   c01003f8 <__panic>
    assert(next->vm_start < next->vm_end);
c0105026:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105029:	8b 50 04             	mov    0x4(%eax),%edx
c010502c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010502f:	8b 40 08             	mov    0x8(%eax),%eax
c0105032:	39 c2                	cmp    %eax,%edx
c0105034:	72 24                	jb     c010505a <check_vma_overlap+0xa2>
c0105036:	c7 44 24 0c ab a1 10 	movl   $0xc010a1ab,0xc(%esp)
c010503d:	c0 
c010503e:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105045:	c0 
c0105046:	c7 44 24 04 69 00 00 	movl   $0x69,0x4(%esp)
c010504d:	00 
c010504e:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105055:	e8 9e b3 ff ff       	call   c01003f8 <__panic>
}
c010505a:	90                   	nop
c010505b:	c9                   	leave  
c010505c:	c3                   	ret    

c010505d <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
c010505d:	55                   	push   %ebp
c010505e:	89 e5                	mov    %esp,%ebp
c0105060:	83 ec 48             	sub    $0x48,%esp
    assert(vma->vm_start < vma->vm_end);
c0105063:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105066:	8b 50 04             	mov    0x4(%eax),%edx
c0105069:	8b 45 0c             	mov    0xc(%ebp),%eax
c010506c:	8b 40 08             	mov    0x8(%eax),%eax
c010506f:	39 c2                	cmp    %eax,%edx
c0105071:	72 24                	jb     c0105097 <insert_vma_struct+0x3a>
c0105073:	c7 44 24 0c c9 a1 10 	movl   $0xc010a1c9,0xc(%esp)
c010507a:	c0 
c010507b:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105082:	c0 
c0105083:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c010508a:	00 
c010508b:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105092:	e8 61 b3 ff ff       	call   c01003f8 <__panic>
    list_entry_t *list = &(mm->mmap_list);
c0105097:	8b 45 08             	mov    0x8(%ebp),%eax
c010509a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    list_entry_t *le_prev = list, *le_next;
c010509d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050a0:	89 45 f4             	mov    %eax,-0xc(%ebp)

        list_entry_t *le = list;
c01050a3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01050a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
        while ((le = list_next(le)) != list) {
c01050a9:	eb 1f                	jmp    c01050ca <insert_vma_struct+0x6d>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
c01050ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050ae:	83 e8 10             	sub    $0x10,%eax
c01050b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            if (mmap_prev->vm_start > vma->vm_start) {
c01050b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01050b7:	8b 50 04             	mov    0x4(%eax),%edx
c01050ba:	8b 45 0c             	mov    0xc(%ebp),%eax
c01050bd:	8b 40 04             	mov    0x4(%eax),%eax
c01050c0:	39 c2                	cmp    %eax,%edx
c01050c2:	77 1f                	ja     c01050e3 <insert_vma_struct+0x86>
                break;
            }
            le_prev = le;
c01050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01050ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01050d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01050d3:	8b 40 04             	mov    0x4(%eax),%eax
    assert(vma->vm_start < vma->vm_end);
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
c01050d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01050dc:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01050df:	75 ca                	jne    c01050ab <insert_vma_struct+0x4e>
c01050e1:	eb 01                	jmp    c01050e4 <insert_vma_struct+0x87>
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
                break;
c01050e3:	90                   	nop
c01050e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050e7:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01050ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01050ed:	8b 40 04             	mov    0x4(%eax),%eax
            }
            le_prev = le;
        }

    le_next = list_next(le_prev);
c01050f0:	89 45 dc             	mov    %eax,-0x24(%ebp)

    /* check overlap */
    if (le_prev != list) {
c01050f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050f6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01050f9:	74 15                	je     c0105110 <insert_vma_struct+0xb3>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
c01050fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050fe:	8d 50 f0             	lea    -0x10(%eax),%edx
c0105101:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105104:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105108:	89 14 24             	mov    %edx,(%esp)
c010510b:	e8 a8 fe ff ff       	call   c0104fb8 <check_vma_overlap>
    }
    if (le_next != list) {
c0105110:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105113:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105116:	74 15                	je     c010512d <insert_vma_struct+0xd0>
        check_vma_overlap(vma, le2vma(le_next, list_link));
c0105118:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010511b:	83 e8 10             	sub    $0x10,%eax
c010511e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105122:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105125:	89 04 24             	mov    %eax,(%esp)
c0105128:	e8 8b fe ff ff       	call   c0104fb8 <check_vma_overlap>
    }

    vma->vm_mm = mm;
c010512d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105130:	8b 55 08             	mov    0x8(%ebp),%edx
c0105133:	89 10                	mov    %edx,(%eax)
    list_add_after(le_prev, &(vma->list_link));
c0105135:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105138:	8d 50 10             	lea    0x10(%eax),%edx
c010513b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010513e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105141:	89 55 d4             	mov    %edx,-0x2c(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0105144:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105147:	8b 40 04             	mov    0x4(%eax),%eax
c010514a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010514d:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0105150:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105153:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0105156:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0105159:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010515c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c010515f:	89 10                	mov    %edx,(%eax)
c0105161:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105164:	8b 10                	mov    (%eax),%edx
c0105166:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105169:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010516c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010516f:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0105172:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0105175:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105178:	8b 55 cc             	mov    -0x34(%ebp),%edx
c010517b:	89 10                	mov    %edx,(%eax)

    mm->map_count ++;
c010517d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105180:	8b 40 10             	mov    0x10(%eax),%eax
c0105183:	8d 50 01             	lea    0x1(%eax),%edx
c0105186:	8b 45 08             	mov    0x8(%ebp),%eax
c0105189:	89 50 10             	mov    %edx,0x10(%eax)
}
c010518c:	90                   	nop
c010518d:	c9                   	leave  
c010518e:	c3                   	ret    

c010518f <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
c010518f:	55                   	push   %ebp
c0105190:	89 e5                	mov    %esp,%ebp
c0105192:	83 ec 38             	sub    $0x38,%esp

    list_entry_t *list = &(mm->mmap_list), *le;
c0105195:	8b 45 08             	mov    0x8(%ebp),%eax
c0105198:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while ((le = list_next(list)) != list) {
c010519b:	eb 3e                	jmp    c01051db <mm_destroy+0x4c>
c010519d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051a0:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c01051a3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051a6:	8b 40 04             	mov    0x4(%eax),%eax
c01051a9:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01051ac:	8b 12                	mov    (%edx),%edx
c01051ae:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01051b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01051b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01051b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01051ba:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01051bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01051c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01051c3:	89 10                	mov    %edx,(%eax)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
c01051c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051c8:	83 e8 10             	sub    $0x10,%eax
c01051cb:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01051d2:	00 
c01051d3:	89 04 24             	mov    %eax,(%esp)
c01051d6:	e8 81 fb ff ff       	call   c0104d5c <kfree>
c01051db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01051de:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01051e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01051e4:	8b 40 04             	mov    0x4(%eax),%eax
// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
c01051e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01051ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051ed:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01051f0:	75 ab                	jne    c010519d <mm_destroy+0xe>
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
c01051f2:	c7 44 24 04 18 00 00 	movl   $0x18,0x4(%esp)
c01051f9:	00 
c01051fa:	8b 45 08             	mov    0x8(%ebp),%eax
c01051fd:	89 04 24             	mov    %eax,(%esp)
c0105200:	e8 57 fb ff ff       	call   c0104d5c <kfree>
    mm=NULL;
c0105205:	c7 45 08 00 00 00 00 	movl   $0x0,0x8(%ebp)
}
c010520c:	90                   	nop
c010520d:	c9                   	leave  
c010520e:	c3                   	ret    

c010520f <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
c010520f:	55                   	push   %ebp
c0105210:	89 e5                	mov    %esp,%ebp
c0105212:	83 ec 08             	sub    $0x8,%esp
    check_vmm();
c0105215:	e8 03 00 00 00       	call   c010521d <check_vmm>
}
c010521a:	90                   	nop
c010521b:	c9                   	leave  
c010521c:	c3                   	ret    

c010521d <check_vmm>:

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
c010521d:	55                   	push   %ebp
c010521e:	89 e5                	mov    %esp,%ebp
c0105220:	83 ec 28             	sub    $0x28,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105223:	e8 a4 e3 ff ff       	call   c01035cc <nr_free_pages>
c0105228:	89 45 f4             	mov    %eax,-0xc(%ebp)
    
    check_vma_struct();
c010522b:	e8 42 00 00 00       	call   c0105272 <check_vma_struct>
    check_pgfault();
c0105230:	e8 fd 04 00 00       	call   c0105732 <check_pgfault>

    assert(nr_free_pages_store == nr_free_pages());
c0105235:	e8 92 e3 ff ff       	call   c01035cc <nr_free_pages>
c010523a:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010523d:	74 24                	je     c0105263 <check_vmm+0x46>
c010523f:	c7 44 24 0c e8 a1 10 	movl   $0xc010a1e8,0xc(%esp)
c0105246:	c0 
c0105247:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010524e:	c0 
c010524f:	c7 44 24 04 a9 00 00 	movl   $0xa9,0x4(%esp)
c0105256:	00 
c0105257:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010525e:	e8 95 b1 ff ff       	call   c01003f8 <__panic>

    cprintf("check_vmm() succeeded.\n");
c0105263:	c7 04 24 0f a2 10 c0 	movl   $0xc010a20f,(%esp)
c010526a:	e8 32 b0 ff ff       	call   c01002a1 <cprintf>
}
c010526f:	90                   	nop
c0105270:	c9                   	leave  
c0105271:	c3                   	ret    

c0105272 <check_vma_struct>:

static void
check_vma_struct(void) {
c0105272:	55                   	push   %ebp
c0105273:	89 e5                	mov    %esp,%ebp
c0105275:	83 ec 68             	sub    $0x68,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105278:	e8 4f e3 ff ff       	call   c01035cc <nr_free_pages>
c010527d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    struct mm_struct *mm = mm_create();
c0105280:	e8 cf fb ff ff       	call   c0104e54 <mm_create>
c0105285:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(mm != NULL);
c0105288:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010528c:	75 24                	jne    c01052b2 <check_vma_struct+0x40>
c010528e:	c7 44 24 0c 27 a2 10 	movl   $0xc010a227,0xc(%esp)
c0105295:	c0 
c0105296:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010529d:	c0 
c010529e:	c7 44 24 04 b3 00 00 	movl   $0xb3,0x4(%esp)
c01052a5:	00 
c01052a6:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01052ad:	e8 46 b1 ff ff       	call   c01003f8 <__panic>

    int step1 = 10, step2 = step1 * 10;
c01052b2:	c7 45 e4 0a 00 00 00 	movl   $0xa,-0x1c(%ebp)
c01052b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01052bc:	89 d0                	mov    %edx,%eax
c01052be:	c1 e0 02             	shl    $0x2,%eax
c01052c1:	01 d0                	add    %edx,%eax
c01052c3:	01 c0                	add    %eax,%eax
c01052c5:	89 45 e0             	mov    %eax,-0x20(%ebp)

    int i;
    for (i = step1; i >= 1; i --) {
c01052c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052cb:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01052ce:	eb 6f                	jmp    c010533f <check_vma_struct+0xcd>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c01052d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01052d3:	89 d0                	mov    %edx,%eax
c01052d5:	c1 e0 02             	shl    $0x2,%eax
c01052d8:	01 d0                	add    %edx,%eax
c01052da:	83 c0 02             	add    $0x2,%eax
c01052dd:	89 c1                	mov    %eax,%ecx
c01052df:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01052e2:	89 d0                	mov    %edx,%eax
c01052e4:	c1 e0 02             	shl    $0x2,%eax
c01052e7:	01 d0                	add    %edx,%eax
c01052e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01052f0:	00 
c01052f1:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01052f5:	89 04 24             	mov    %eax,(%esp)
c01052f8:	e8 cf fb ff ff       	call   c0104ecc <vma_create>
c01052fd:	89 45 dc             	mov    %eax,-0x24(%ebp)
        assert(vma != NULL);
c0105300:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105304:	75 24                	jne    c010532a <check_vma_struct+0xb8>
c0105306:	c7 44 24 0c 32 a2 10 	movl   $0xc010a232,0xc(%esp)
c010530d:	c0 
c010530e:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105315:	c0 
c0105316:	c7 44 24 04 ba 00 00 	movl   $0xba,0x4(%esp)
c010531d:	00 
c010531e:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105325:	e8 ce b0 ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c010532a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010532d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105331:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105334:	89 04 24             	mov    %eax,(%esp)
c0105337:	e8 21 fd ff ff       	call   c010505d <insert_vma_struct>
    assert(mm != NULL);

    int step1 = 10, step2 = step1 * 10;

    int i;
    for (i = step1; i >= 1; i --) {
c010533c:	ff 4d f4             	decl   -0xc(%ebp)
c010533f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105343:	7f 8b                	jg     c01052d0 <check_vma_struct+0x5e>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c0105345:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105348:	40                   	inc    %eax
c0105349:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010534c:	eb 6f                	jmp    c01053bd <check_vma_struct+0x14b>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
c010534e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105351:	89 d0                	mov    %edx,%eax
c0105353:	c1 e0 02             	shl    $0x2,%eax
c0105356:	01 d0                	add    %edx,%eax
c0105358:	83 c0 02             	add    $0x2,%eax
c010535b:	89 c1                	mov    %eax,%ecx
c010535d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105360:	89 d0                	mov    %edx,%eax
c0105362:	c1 e0 02             	shl    $0x2,%eax
c0105365:	01 d0                	add    %edx,%eax
c0105367:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010536e:	00 
c010536f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0105373:	89 04 24             	mov    %eax,(%esp)
c0105376:	e8 51 fb ff ff       	call   c0104ecc <vma_create>
c010537b:	89 45 d8             	mov    %eax,-0x28(%ebp)
        assert(vma != NULL);
c010537e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0105382:	75 24                	jne    c01053a8 <check_vma_struct+0x136>
c0105384:	c7 44 24 0c 32 a2 10 	movl   $0xc010a232,0xc(%esp)
c010538b:	c0 
c010538c:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105393:	c0 
c0105394:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
c010539b:	00 
c010539c:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01053a3:	e8 50 b0 ff ff       	call   c01003f8 <__panic>
        insert_vma_struct(mm, vma);
c01053a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01053ab:	89 44 24 04          	mov    %eax,0x4(%esp)
c01053af:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053b2:	89 04 24             	mov    %eax,(%esp)
c01053b5:	e8 a3 fc ff ff       	call   c010505d <insert_vma_struct>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    for (i = step1 + 1; i <= step2; i ++) {
c01053ba:	ff 45 f4             	incl   -0xc(%ebp)
c01053bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01053c0:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c01053c3:	7e 89                	jle    c010534e <check_vma_struct+0xdc>
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));
c01053c5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053c8:	89 45 b4             	mov    %eax,-0x4c(%ebp)
c01053cb:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01053ce:	8b 40 04             	mov    0x4(%eax),%eax
c01053d1:	89 45 f0             	mov    %eax,-0x10(%ebp)

    for (i = 1; i <= step2; i ++) {
c01053d4:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
c01053db:	e9 96 00 00 00       	jmp    c0105476 <check_vma_struct+0x204>
        assert(le != &(mm->mmap_list));
c01053e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01053e3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01053e6:	75 24                	jne    c010540c <check_vma_struct+0x19a>
c01053e8:	c7 44 24 0c 3e a2 10 	movl   $0xc010a23e,0xc(%esp)
c01053ef:	c0 
c01053f0:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01053f7:	c0 
c01053f8:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c01053ff:	00 
c0105400:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105407:	e8 ec af ff ff       	call   c01003f8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
c010540c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010540f:	83 e8 10             	sub    $0x10,%eax
c0105412:	89 45 d0             	mov    %eax,-0x30(%ebp)
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
c0105415:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105418:	8b 48 04             	mov    0x4(%eax),%ecx
c010541b:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010541e:	89 d0                	mov    %edx,%eax
c0105420:	c1 e0 02             	shl    $0x2,%eax
c0105423:	01 d0                	add    %edx,%eax
c0105425:	39 c1                	cmp    %eax,%ecx
c0105427:	75 17                	jne    c0105440 <check_vma_struct+0x1ce>
c0105429:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010542c:	8b 48 08             	mov    0x8(%eax),%ecx
c010542f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105432:	89 d0                	mov    %edx,%eax
c0105434:	c1 e0 02             	shl    $0x2,%eax
c0105437:	01 d0                	add    %edx,%eax
c0105439:	83 c0 02             	add    $0x2,%eax
c010543c:	39 c1                	cmp    %eax,%ecx
c010543e:	74 24                	je     c0105464 <check_vma_struct+0x1f2>
c0105440:	c7 44 24 0c 58 a2 10 	movl   $0xc010a258,0xc(%esp)
c0105447:	c0 
c0105448:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010544f:	c0 
c0105450:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0105457:	00 
c0105458:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010545f:	e8 94 af ff ff       	call   c01003f8 <__panic>
c0105464:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105467:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010546a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010546d:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0105470:	89 45 f0             	mov    %eax,-0x10(%ebp)
        insert_vma_struct(mm, vma);
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
c0105473:	ff 45 f4             	incl   -0xc(%ebp)
c0105476:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105479:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c010547c:	0f 8e 5e ff ff ff    	jle    c01053e0 <check_vma_struct+0x16e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0105482:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%ebp)
c0105489:	e9 cb 01 00 00       	jmp    c0105659 <check_vma_struct+0x3e7>
        struct vma_struct *vma1 = find_vma(mm, i);
c010548e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105491:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105495:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105498:	89 04 24             	mov    %eax,(%esp)
c010549b:	e8 67 fa ff ff       	call   c0104f07 <find_vma>
c01054a0:	89 45 cc             	mov    %eax,-0x34(%ebp)
        assert(vma1 != NULL);
c01054a3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01054a7:	75 24                	jne    c01054cd <check_vma_struct+0x25b>
c01054a9:	c7 44 24 0c 8d a2 10 	movl   $0xc010a28d,0xc(%esp)
c01054b0:	c0 
c01054b1:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01054b8:	c0 
c01054b9:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c01054c0:	00 
c01054c1:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01054c8:	e8 2b af ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma2 = find_vma(mm, i+1);
c01054cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01054d0:	40                   	inc    %eax
c01054d1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01054d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01054d8:	89 04 24             	mov    %eax,(%esp)
c01054db:	e8 27 fa ff ff       	call   c0104f07 <find_vma>
c01054e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
        assert(vma2 != NULL);
c01054e3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01054e7:	75 24                	jne    c010550d <check_vma_struct+0x29b>
c01054e9:	c7 44 24 0c 9a a2 10 	movl   $0xc010a29a,0xc(%esp)
c01054f0:	c0 
c01054f1:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01054f8:	c0 
c01054f9:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0105500:	00 
c0105501:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105508:	e8 eb ae ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma3 = find_vma(mm, i+2);
c010550d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105510:	83 c0 02             	add    $0x2,%eax
c0105513:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105517:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010551a:	89 04 24             	mov    %eax,(%esp)
c010551d:	e8 e5 f9 ff ff       	call   c0104f07 <find_vma>
c0105522:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        assert(vma3 == NULL);
c0105525:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0105529:	74 24                	je     c010554f <check_vma_struct+0x2dd>
c010552b:	c7 44 24 0c a7 a2 10 	movl   $0xc010a2a7,0xc(%esp)
c0105532:	c0 
c0105533:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010553a:	c0 
c010553b:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c0105542:	00 
c0105543:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010554a:	e8 a9 ae ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma4 = find_vma(mm, i+3);
c010554f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105552:	83 c0 03             	add    $0x3,%eax
c0105555:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105559:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010555c:	89 04 24             	mov    %eax,(%esp)
c010555f:	e8 a3 f9 ff ff       	call   c0104f07 <find_vma>
c0105564:	89 45 c0             	mov    %eax,-0x40(%ebp)
        assert(vma4 == NULL);
c0105567:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
c010556b:	74 24                	je     c0105591 <check_vma_struct+0x31f>
c010556d:	c7 44 24 0c b4 a2 10 	movl   $0xc010a2b4,0xc(%esp)
c0105574:	c0 
c0105575:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010557c:	c0 
c010557d:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0105584:	00 
c0105585:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010558c:	e8 67 ae ff ff       	call   c01003f8 <__panic>
        struct vma_struct *vma5 = find_vma(mm, i+4);
c0105591:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105594:	83 c0 04             	add    $0x4,%eax
c0105597:	89 44 24 04          	mov    %eax,0x4(%esp)
c010559b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010559e:	89 04 24             	mov    %eax,(%esp)
c01055a1:	e8 61 f9 ff ff       	call   c0104f07 <find_vma>
c01055a6:	89 45 bc             	mov    %eax,-0x44(%ebp)
        assert(vma5 == NULL);
c01055a9:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c01055ad:	74 24                	je     c01055d3 <check_vma_struct+0x361>
c01055af:	c7 44 24 0c c1 a2 10 	movl   $0xc010a2c1,0xc(%esp)
c01055b6:	c0 
c01055b7:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01055be:	c0 
c01055bf:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c01055c6:	00 
c01055c7:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01055ce:	e8 25 ae ff ff       	call   c01003f8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
c01055d3:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01055d6:	8b 50 04             	mov    0x4(%eax),%edx
c01055d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01055dc:	39 c2                	cmp    %eax,%edx
c01055de:	75 10                	jne    c01055f0 <check_vma_struct+0x37e>
c01055e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01055e3:	8b 40 08             	mov    0x8(%eax),%eax
c01055e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01055e9:	83 c2 02             	add    $0x2,%edx
c01055ec:	39 d0                	cmp    %edx,%eax
c01055ee:	74 24                	je     c0105614 <check_vma_struct+0x3a2>
c01055f0:	c7 44 24 0c d0 a2 10 	movl   $0xc010a2d0,0xc(%esp)
c01055f7:	c0 
c01055f8:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01055ff:	c0 
c0105600:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
c0105607:	00 
c0105608:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010560f:	e8 e4 ad ff ff       	call   c01003f8 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
c0105614:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105617:	8b 50 04             	mov    0x4(%eax),%edx
c010561a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010561d:	39 c2                	cmp    %eax,%edx
c010561f:	75 10                	jne    c0105631 <check_vma_struct+0x3bf>
c0105621:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0105624:	8b 40 08             	mov    0x8(%eax),%eax
c0105627:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010562a:	83 c2 02             	add    $0x2,%edx
c010562d:	39 d0                	cmp    %edx,%eax
c010562f:	74 24                	je     c0105655 <check_vma_struct+0x3e3>
c0105631:	c7 44 24 0c 00 a3 10 	movl   $0xc010a300,0xc(%esp)
c0105638:	c0 
c0105639:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105640:	c0 
c0105641:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0105648:	00 
c0105649:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105650:	e8 a3 ad ff ff       	call   c01003f8 <__panic>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
c0105655:	83 45 f4 05          	addl   $0x5,-0xc(%ebp)
c0105659:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010565c:	89 d0                	mov    %edx,%eax
c010565e:	c1 e0 02             	shl    $0x2,%eax
c0105661:	01 d0                	add    %edx,%eax
c0105663:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0105666:	0f 8d 22 fe ff ff    	jge    c010548e <check_vma_struct+0x21c>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c010566c:	c7 45 f4 04 00 00 00 	movl   $0x4,-0xc(%ebp)
c0105673:	eb 6f                	jmp    c01056e4 <check_vma_struct+0x472>
        struct vma_struct *vma_below_5= find_vma(mm,i);
c0105675:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105678:	89 44 24 04          	mov    %eax,0x4(%esp)
c010567c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010567f:	89 04 24             	mov    %eax,(%esp)
c0105682:	e8 80 f8 ff ff       	call   c0104f07 <find_vma>
c0105687:	89 45 b8             	mov    %eax,-0x48(%ebp)
        if (vma_below_5 != NULL ) {
c010568a:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010568e:	74 27                	je     c01056b7 <check_vma_struct+0x445>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
c0105690:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105693:	8b 50 08             	mov    0x8(%eax),%edx
c0105696:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0105699:	8b 40 04             	mov    0x4(%eax),%eax
c010569c:	89 54 24 0c          	mov    %edx,0xc(%esp)
c01056a0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01056a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01056a7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01056ab:	c7 04 24 30 a3 10 c0 	movl   $0xc010a330,(%esp)
c01056b2:	e8 ea ab ff ff       	call   c01002a1 <cprintf>
        }
        assert(vma_below_5 == NULL);
c01056b7:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01056bb:	74 24                	je     c01056e1 <check_vma_struct+0x46f>
c01056bd:	c7 44 24 0c 55 a3 10 	movl   $0xc010a355,0xc(%esp)
c01056c4:	c0 
c01056c5:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01056cc:	c0 
c01056cd:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c01056d4:	00 
c01056d5:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01056dc:	e8 17 ad ff ff       	call   c01003f8 <__panic>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
    }

    for (i =4; i>=0; i--) {
c01056e1:	ff 4d f4             	decl   -0xc(%ebp)
c01056e4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01056e8:	79 8b                	jns    c0105675 <check_vma_struct+0x403>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
c01056ea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056ed:	89 04 24             	mov    %eax,(%esp)
c01056f0:	e8 9a fa ff ff       	call   c010518f <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
c01056f5:	e8 d2 de ff ff       	call   c01035cc <nr_free_pages>
c01056fa:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01056fd:	74 24                	je     c0105723 <check_vma_struct+0x4b1>
c01056ff:	c7 44 24 0c e8 a1 10 	movl   $0xc010a1e8,0xc(%esp)
c0105706:	c0 
c0105707:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c010570e:	c0 
c010570f:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0105716:	00 
c0105717:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c010571e:	e8 d5 ac ff ff       	call   c01003f8 <__panic>

    cprintf("check_vma_struct() succeeded!\n");
c0105723:	c7 04 24 6c a3 10 c0 	movl   $0xc010a36c,(%esp)
c010572a:	e8 72 ab ff ff       	call   c01002a1 <cprintf>
}
c010572f:	90                   	nop
c0105730:	c9                   	leave  
c0105731:	c3                   	ret    

c0105732 <check_pgfault>:

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
c0105732:	55                   	push   %ebp
c0105733:	89 e5                	mov    %esp,%ebp
c0105735:	83 ec 38             	sub    $0x38,%esp
    size_t nr_free_pages_store = nr_free_pages();
c0105738:	e8 8f de ff ff       	call   c01035cc <nr_free_pages>
c010573d:	89 45 ec             	mov    %eax,-0x14(%ebp)

    check_mm_struct = mm_create();
c0105740:	e8 0f f7 ff ff       	call   c0104e54 <mm_create>
c0105745:	a3 2c 50 12 c0       	mov    %eax,0xc012502c
    assert(check_mm_struct != NULL);
c010574a:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c010574f:	85 c0                	test   %eax,%eax
c0105751:	75 24                	jne    c0105777 <check_pgfault+0x45>
c0105753:	c7 44 24 0c 8b a3 10 	movl   $0xc010a38b,0xc(%esp)
c010575a:	c0 
c010575b:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105762:	c0 
c0105763:	c7 44 24 04 f4 00 00 	movl   $0xf4,0x4(%esp)
c010576a:	00 
c010576b:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105772:	e8 81 ac ff ff       	call   c01003f8 <__panic>

    struct mm_struct *mm = check_mm_struct;
c0105777:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c010577c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
c010577f:	8b 15 e0 19 12 c0    	mov    0xc01219e0,%edx
c0105785:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105788:	89 50 0c             	mov    %edx,0xc(%eax)
c010578b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010578e:	8b 40 0c             	mov    0xc(%eax),%eax
c0105791:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(pgdir[0] == 0);
c0105794:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105797:	8b 00                	mov    (%eax),%eax
c0105799:	85 c0                	test   %eax,%eax
c010579b:	74 24                	je     c01057c1 <check_pgfault+0x8f>
c010579d:	c7 44 24 0c a3 a3 10 	movl   $0xc010a3a3,0xc(%esp)
c01057a4:	c0 
c01057a5:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01057ac:	c0 
c01057ad:	c7 44 24 04 f8 00 00 	movl   $0xf8,0x4(%esp)
c01057b4:	00 
c01057b5:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01057bc:	e8 37 ac ff ff       	call   c01003f8 <__panic>

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
c01057c1:	c7 44 24 08 02 00 00 	movl   $0x2,0x8(%esp)
c01057c8:	00 
c01057c9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
c01057d0:	00 
c01057d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01057d8:	e8 ef f6 ff ff       	call   c0104ecc <vma_create>
c01057dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(vma != NULL);
c01057e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01057e4:	75 24                	jne    c010580a <check_pgfault+0xd8>
c01057e6:	c7 44 24 0c 32 a2 10 	movl   $0xc010a232,0xc(%esp)
c01057ed:	c0 
c01057ee:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01057f5:	c0 
c01057f6:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c01057fd:	00 
c01057fe:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105805:	e8 ee ab ff ff       	call   c01003f8 <__panic>

    insert_vma_struct(mm, vma);
c010580a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010580d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105811:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105814:	89 04 24             	mov    %eax,(%esp)
c0105817:	e8 41 f8 ff ff       	call   c010505d <insert_vma_struct>

    uintptr_t addr = 0x100;
c010581c:	c7 45 dc 00 01 00 00 	movl   $0x100,-0x24(%ebp)
    assert(find_vma(mm, addr) == vma);
c0105823:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105826:	89 44 24 04          	mov    %eax,0x4(%esp)
c010582a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010582d:	89 04 24             	mov    %eax,(%esp)
c0105830:	e8 d2 f6 ff ff       	call   c0104f07 <find_vma>
c0105835:	3b 45 e0             	cmp    -0x20(%ebp),%eax
c0105838:	74 24                	je     c010585e <check_pgfault+0x12c>
c010583a:	c7 44 24 0c b1 a3 10 	movl   $0xc010a3b1,0xc(%esp)
c0105841:	c0 
c0105842:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105849:	c0 
c010584a:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0105851:	00 
c0105852:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105859:	e8 9a ab ff ff       	call   c01003f8 <__panic>

    int i, sum = 0;
c010585e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for (i = 0; i < 100; i ++) {
c0105865:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010586c:	eb 16                	jmp    c0105884 <check_pgfault+0x152>
        *(char *)(addr + i) = i;
c010586e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105871:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105874:	01 d0                	add    %edx,%eax
c0105876:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105879:	88 10                	mov    %dl,(%eax)
        sum += i;
c010587b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010587e:	01 45 f0             	add    %eax,-0x10(%ebp)

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
c0105881:	ff 45 f4             	incl   -0xc(%ebp)
c0105884:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c0105888:	7e e4                	jle    c010586e <check_pgfault+0x13c>
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c010588a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105891:	eb 14                	jmp    c01058a7 <check_pgfault+0x175>
        sum -= *(char *)(addr + i);
c0105893:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105896:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105899:	01 d0                	add    %edx,%eax
c010589b:	0f b6 00             	movzbl (%eax),%eax
c010589e:	0f be c0             	movsbl %al,%eax
c01058a1:	29 45 f0             	sub    %eax,-0x10(%ebp)
    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    for (i = 0; i < 100; i ++) {
c01058a4:	ff 45 f4             	incl   -0xc(%ebp)
c01058a7:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
c01058ab:	7e e6                	jle    c0105893 <check_pgfault+0x161>
        sum -= *(char *)(addr + i);
    }
    assert(sum == 0);
c01058ad:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01058b1:	74 24                	je     c01058d7 <check_pgfault+0x1a5>
c01058b3:	c7 44 24 0c cb a3 10 	movl   $0xc010a3cb,0xc(%esp)
c01058ba:	c0 
c01058bb:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c01058c2:	c0 
c01058c3:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01058ca:	00 
c01058cb:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c01058d2:	e8 21 ab ff ff       	call   c01003f8 <__panic>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
c01058d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058da:	89 45 d8             	mov    %eax,-0x28(%ebp)
c01058dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01058e0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01058e5:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058ec:	89 04 24             	mov    %eax,(%esp)
c01058ef:	e8 fb e4 ff ff       	call   c0103def <page_remove>
    free_page(pde2page(pgdir[0]));
c01058f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058f7:	8b 00                	mov    (%eax),%eax
c01058f9:	89 04 24             	mov    %eax,(%esp)
c01058fc:	e8 3b f5 ff ff       	call   c0104e3c <pde2page>
c0105901:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105908:	00 
c0105909:	89 04 24             	mov    %eax,(%esp)
c010590c:	e8 88 dc ff ff       	call   c0103599 <free_pages>
    pgdir[0] = 0;
c0105911:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105914:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    mm->pgdir = NULL;
c010591a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010591d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    mm_destroy(mm);
c0105924:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105927:	89 04 24             	mov    %eax,(%esp)
c010592a:	e8 60 f8 ff ff       	call   c010518f <mm_destroy>
    check_mm_struct = NULL;
c010592f:	c7 05 2c 50 12 c0 00 	movl   $0x0,0xc012502c
c0105936:	00 00 00 

    assert(nr_free_pages_store == nr_free_pages());
c0105939:	e8 8e dc ff ff       	call   c01035cc <nr_free_pages>
c010593e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105941:	74 24                	je     c0105967 <check_pgfault+0x235>
c0105943:	c7 44 24 0c e8 a1 10 	movl   $0xc010a1e8,0xc(%esp)
c010594a:	c0 
c010594b:	c7 44 24 08 67 a1 10 	movl   $0xc010a167,0x8(%esp)
c0105952:	c0 
c0105953:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c010595a:	00 
c010595b:	c7 04 24 7c a1 10 c0 	movl   $0xc010a17c,(%esp)
c0105962:	e8 91 aa ff ff       	call   c01003f8 <__panic>

    cprintf("check_pgfault() succeeded!\n");
c0105967:	c7 04 24 d4 a3 10 c0 	movl   $0xc010a3d4,(%esp)
c010596e:	e8 2e a9 ff ff       	call   c01002a1 <cprintf>
}
c0105973:	90                   	nop
c0105974:	c9                   	leave  
c0105975:	c3                   	ret    

c0105976 <do_pgfault>:
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
// mm:传入的vma控制器 error_code：错误类型 addr：发生错误的地址（线性地址）
int
do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
c0105976:	55                   	push   %ebp
c0105977:	89 e5                	mov    %esp,%ebp
c0105979:	83 ec 38             	sub    $0x38,%esp
    int ret = -E_INVAL;
c010597c:	c7 45 f4 fd ff ff ff 	movl   $0xfffffffd,-0xc(%ebp)
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
c0105983:	8b 45 10             	mov    0x10(%ebp),%eax
c0105986:	89 44 24 04          	mov    %eax,0x4(%esp)
c010598a:	8b 45 08             	mov    0x8(%ebp),%eax
c010598d:	89 04 24             	mov    %eax,(%esp)
c0105990:	e8 72 f5 ff ff       	call   c0104f07 <find_vma>
c0105995:	89 45 ec             	mov    %eax,-0x14(%ebp)

    pgfault_num++;
c0105998:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c010599d:	40                   	inc    %eax
c010599e:	a3 0c 50 12 c0       	mov    %eax,0xc012500c
    //If the addr is in the range of a mm's vma?
    // 传入的addr有错误
    if (vma == NULL || vma->vm_start > addr) {
c01059a3:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01059a7:	74 0b                	je     c01059b4 <do_pgfault+0x3e>
c01059a9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059ac:	8b 40 04             	mov    0x4(%eax),%eax
c01059af:	3b 45 10             	cmp    0x10(%ebp),%eax
c01059b2:	76 18                	jbe    c01059cc <do_pgfault+0x56>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
c01059b4:	8b 45 10             	mov    0x10(%ebp),%eax
c01059b7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059bb:	c7 04 24 f0 a3 10 c0 	movl   $0xc010a3f0,(%esp)
c01059c2:	e8 da a8 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c01059c7:	e9 ba 01 00 00       	jmp    c0105b86 <do_pgfault+0x210>
    }
    //check the error_code
    switch (error_code & 3) {
c01059cc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059cf:	83 e0 03             	and    $0x3,%eax
c01059d2:	85 c0                	test   %eax,%eax
c01059d4:	74 34                	je     c0105a0a <do_pgfault+0x94>
c01059d6:	83 f8 01             	cmp    $0x1,%eax
c01059d9:	74 1e                	je     c01059f9 <do_pgfault+0x83>
    default:
            /* error code flag : default is 3 ( W/R=1, P=1): write, present */
    case 2: /* error code flag : (W/R=1, P=0): write, not present */
        // 向一个不允许写的页中发起写操作，并且页不存在内存中
        if (!(vma->vm_flags & VM_WRITE)) {
c01059db:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01059de:	8b 40 0c             	mov    0xc(%eax),%eax
c01059e1:	83 e0 02             	and    $0x2,%eax
c01059e4:	85 c0                	test   %eax,%eax
c01059e6:	75 40                	jne    c0105a28 <do_pgfault+0xb2>
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
c01059e8:	c7 04 24 20 a4 10 c0 	movl   $0xc010a420,(%esp)
c01059ef:	e8 ad a8 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c01059f4:	e9 8d 01 00 00       	jmp    c0105b86 <do_pgfault+0x210>
        }
        break;
    case 1: /* error code flag : (W/R=0, P=1): read, present */
        // 向一个存在于内存的页发起读操作，说明是权限不够
        cprintf("do_pgfault failed: error code flag = read AND present\n");
c01059f9:	c7 04 24 80 a4 10 c0 	movl   $0xc010a480,(%esp)
c0105a00:	e8 9c a8 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0105a05:	e9 7c 01 00 00       	jmp    c0105b86 <do_pgfault+0x210>
    case 0: /* error code flag : (W/R=0, P=0): read, not present */
        // 向一个不允许读和执行的页发起读操作，并且也不存在内存中
        if (!(vma->vm_flags & (VM_READ | VM_EXEC))) {
c0105a0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a0d:	8b 40 0c             	mov    0xc(%eax),%eax
c0105a10:	83 e0 05             	and    $0x5,%eax
c0105a13:	85 c0                	test   %eax,%eax
c0105a15:	75 12                	jne    c0105a29 <do_pgfault+0xb3>
            cprintf("do_pgfault failed: error code flag = read AND not present, but the addr's vma cannot read or exec\n");
c0105a17:	c7 04 24 b8 a4 10 c0 	movl   $0xc010a4b8,(%esp)
c0105a1e:	e8 7e a8 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0105a23:	e9 5e 01 00 00       	jmp    c0105b86 <do_pgfault+0x210>
        // 向一个不允许写的页中发起写操作，并且页不存在内存中
        if (!(vma->vm_flags & VM_WRITE)) {
            cprintf("do_pgfault failed: error code flag = write AND not present, but the addr's vma cannot write\n");
            goto failed;
        }
        break;
c0105a28:	90                   	nop
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    // priviledge of the page
    uint32_t perm = PTE_U;
c0105a29:	c7 45 f0 04 00 00 00 	movl   $0x4,-0x10(%ebp)
    if (vma->vm_flags & VM_WRITE) {
c0105a30:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105a33:	8b 40 0c             	mov    0xc(%eax),%eax
c0105a36:	83 e0 02             	and    $0x2,%eax
c0105a39:	85 c0                	test   %eax,%eax
c0105a3b:	74 04                	je     c0105a41 <do_pgfault+0xcb>
        perm |= PTE_W;
c0105a3d:	83 4d f0 02          	orl    $0x2,-0x10(%ebp)
    }
    // 按页分配，向下取整
    addr = ROUNDDOWN(addr, PGSIZE);
c0105a41:	8b 45 10             	mov    0x10(%ebp),%eax
c0105a44:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a47:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a4a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105a4f:	89 45 10             	mov    %eax,0x10(%ebp)

    ret = -E_NO_MEM;
c0105a52:	c7 45 f4 fc ff ff ff 	movl   $0xfffffffc,-0xc(%ebp)

    pte_t *ptep=NULL;
c0105a59:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
            goto failed;
        }
   }
#endif
    // (1) try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
c0105a60:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a63:	8b 40 0c             	mov    0xc(%eax),%eax
c0105a66:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0105a6d:	00 
c0105a6e:	8b 55 10             	mov    0x10(%ebp),%edx
c0105a71:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a75:	89 04 24             	mov    %eax,(%esp)
c0105a78:	e8 7e e1 ff ff       	call   c0103bfb <get_pte>
c0105a7d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105a80:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105a84:	75 11                	jne    c0105a97 <do_pgfault+0x121>
        cprintf("get_pte in do_pgfault failed\n");
c0105a86:	c7 04 24 1b a5 10 c0 	movl   $0xc010a51b,(%esp)
c0105a8d:	e8 0f a8 ff ff       	call   c01002a1 <cprintf>
        goto failed;
c0105a92:	e9 ef 00 00 00       	jmp    c0105b86 <do_pgfault+0x210>
    }

    //(2) if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
    // it must be true if the condition of (1) is true
    if (*ptep == 0) {
c0105a97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a9a:	8b 00                	mov    (%eax),%eax
c0105a9c:	85 c0                	test   %eax,%eax
c0105a9e:	75 35                	jne    c0105ad5 <do_pgfault+0x15f>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
c0105aa0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa3:	8b 40 0c             	mov    0xc(%eax),%eax
c0105aa6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105aa9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105aad:	8b 55 10             	mov    0x10(%ebp),%edx
c0105ab0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ab4:	89 04 24             	mov    %eax,(%esp)
c0105ab7:	e8 8d e4 ff ff       	call   c0103f49 <pgdir_alloc_page>
c0105abc:	85 c0                	test   %eax,%eax
c0105abe:	0f 85 bb 00 00 00    	jne    c0105b7f <do_pgfault+0x209>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
c0105ac4:	c7 04 24 3c a5 10 c0 	movl   $0xc010a53c,(%esp)
c0105acb:	e8 d1 a7 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0105ad0:	e9 b1 00 00 00       	jmp    c0105b86 <do_pgfault+0x210>
        }
    }
    // if this pte is a swap entry, then load data from disk to a page with phy addr
    // and call page_insert to map the phy addr with logical addr
    else { 
        if(swap_init_ok) {
c0105ad5:	a1 10 50 12 c0       	mov    0xc0125010,%eax
c0105ada:	85 c0                	test   %eax,%eax
c0105adc:	0f 84 86 00 00 00    	je     c0105b68 <do_pgfault+0x1f2>
            struct Page *page=NULL;
c0105ae2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
            // (1）According to the mm AND addr, try to load the content of right disk page
            //     into the memory which page managed.
            // swap_in(mm, addr, &page) : alloc a memory page, then according to the swap entry in PTE for addr,
            // find the addr of disk page, read the content of disk page into this memroy page
            if ((ret = swap_in(mm, addr, &page)) != 0) {
c0105ae9:	8d 45 e0             	lea    -0x20(%ebp),%eax
c0105aec:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105af0:	8b 45 10             	mov    0x10(%ebp),%eax
c0105af3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105af7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105afa:	89 04 24             	mov    %eax,(%esp)
c0105afd:	e8 8e 03 00 00       	call   c0105e90 <swap_in>
c0105b02:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105b05:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105b09:	74 0e                	je     c0105b19 <do_pgfault+0x1a3>
                cprintf("swap_in in do_pgfault failed\n");
c0105b0b:	c7 04 24 63 a5 10 c0 	movl   $0xc010a563,(%esp)
c0105b12:	e8 8a a7 ff ff       	call   c01002a1 <cprintf>
c0105b17:	eb 6d                	jmp    c0105b86 <do_pgfault+0x210>
                goto failed;
            }
            // (2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr    
            // page_insert ： build the map of phy addr of an Page with the linear addr la
            page_insert(mm->pgdir, page, addr, perm);
c0105b19:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0105b1c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b1f:	8b 40 0c             	mov    0xc(%eax),%eax
c0105b22:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105b25:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0105b29:	8b 4d 10             	mov    0x10(%ebp),%ecx
c0105b2c:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105b30:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105b34:	89 04 24             	mov    %eax,(%esp)
c0105b37:	e8 f8 e2 ff ff       	call   c0103e34 <page_insert>
            // (3) make the page swappable.
            // swap_map_swappable ： set the page swappable
            swap_map_swappable(mm, addr, page, 1);
c0105b3c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b3f:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
c0105b46:	00 
c0105b47:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105b4b:	8b 45 10             	mov    0x10(%ebp),%eax
c0105b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b52:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b55:	89 04 24             	mov    %eax,(%esp)
c0105b58:	e8 71 01 00 00       	call   c0105cce <swap_map_swappable>
            page->pra_vaddr = addr;
c0105b5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b60:	8b 55 10             	mov    0x10(%ebp),%edx
c0105b63:	89 50 1c             	mov    %edx,0x1c(%eax)
c0105b66:	eb 17                	jmp    c0105b7f <do_pgfault+0x209>
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
c0105b68:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105b6b:	8b 00                	mov    (%eax),%eax
c0105b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b71:	c7 04 24 84 a5 10 c0 	movl   $0xc010a584,(%esp)
c0105b78:	e8 24 a7 ff ff       	call   c01002a1 <cprintf>
            goto failed;
c0105b7d:	eb 07                	jmp    c0105b86 <do_pgfault+0x210>
        }
   }


   ret = 0;
c0105b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
failed:
    return ret;
c0105b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105b89:	c9                   	leave  
c0105b8a:	c3                   	ret    

c0105b8b <pa2page>:
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

static inline struct Page *
pa2page(uintptr_t pa) {
c0105b8b:	55                   	push   %ebp
c0105b8c:	89 e5                	mov    %esp,%ebp
c0105b8e:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0105b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b94:	c1 e8 0c             	shr    $0xc,%eax
c0105b97:	89 c2                	mov    %eax,%edx
c0105b99:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c0105b9e:	39 c2                	cmp    %eax,%edx
c0105ba0:	72 1c                	jb     c0105bbe <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0105ba2:	c7 44 24 08 ac a5 10 	movl   $0xc010a5ac,0x8(%esp)
c0105ba9:	c0 
c0105baa:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0105bb1:	00 
c0105bb2:	c7 04 24 cb a5 10 c0 	movl   $0xc010a5cb,(%esp)
c0105bb9:	e8 3a a8 ff ff       	call   c01003f8 <__panic>
    }
    return &pages[PPN(pa)];
c0105bbe:	a1 28 50 12 c0       	mov    0xc0125028,%eax
c0105bc3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105bc6:	c1 ea 0c             	shr    $0xc,%edx
c0105bc9:	c1 e2 05             	shl    $0x5,%edx
c0105bcc:	01 d0                	add    %edx,%eax
}
c0105bce:	c9                   	leave  
c0105bcf:	c3                   	ret    

c0105bd0 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0105bd0:	55                   	push   %ebp
c0105bd1:	89 e5                	mov    %esp,%ebp
c0105bd3:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0105bd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd9:	83 e0 01             	and    $0x1,%eax
c0105bdc:	85 c0                	test   %eax,%eax
c0105bde:	75 1c                	jne    c0105bfc <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0105be0:	c7 44 24 08 dc a5 10 	movl   $0xc010a5dc,0x8(%esp)
c0105be7:	c0 
c0105be8:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0105bef:	00 
c0105bf0:	c7 04 24 cb a5 10 c0 	movl   $0xc010a5cb,(%esp)
c0105bf7:	e8 fc a7 ff ff       	call   c01003f8 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0105bfc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bff:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105c04:	89 04 24             	mov    %eax,(%esp)
c0105c07:	e8 7f ff ff ff       	call   c0105b8b <pa2page>
}
c0105c0c:	c9                   	leave  
c0105c0d:	c3                   	ret    

c0105c0e <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
c0105c0e:	55                   	push   %ebp
c0105c0f:	89 e5                	mov    %esp,%ebp
c0105c11:	83 ec 28             	sub    $0x28,%esp
     swapfs_init();
c0105c14:	e8 94 28 00 00       	call   c01084ad <swapfs_init>

     if (!(1024 <= max_swap_offset && max_swap_offset < MAX_SWAP_OFFSET_LIMIT))
c0105c19:	a1 dc 50 12 c0       	mov    0xc01250dc,%eax
c0105c1e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
c0105c23:	76 0c                	jbe    c0105c31 <swap_init+0x23>
c0105c25:	a1 dc 50 12 c0       	mov    0xc01250dc,%eax
c0105c2a:	3d ff ff ff 00       	cmp    $0xffffff,%eax
c0105c2f:	76 25                	jbe    c0105c56 <swap_init+0x48>
     {
          panic("bad max_swap_offset %08x.\n", max_swap_offset);
c0105c31:	a1 dc 50 12 c0       	mov    0xc01250dc,%eax
c0105c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105c3a:	c7 44 24 08 fd a5 10 	movl   $0xc010a5fd,0x8(%esp)
c0105c41:	c0 
c0105c42:	c7 44 24 04 26 00 00 	movl   $0x26,0x4(%esp)
c0105c49:	00 
c0105c4a:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105c51:	e8 a2 a7 ff ff       	call   c01003f8 <__panic>
     }
     

     sm = &swap_manager_clock;
c0105c56:	c7 05 18 50 12 c0 40 	movl   $0xc0121a40,0xc0125018
c0105c5d:	1a 12 c0 
     int r = sm->init();
c0105c60:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105c65:	8b 40 04             	mov    0x4(%eax),%eax
c0105c68:	ff d0                	call   *%eax
c0105c6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
     
     if (r == 0)
c0105c6d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105c71:	75 26                	jne    c0105c99 <swap_init+0x8b>
     {
          swap_init_ok = 1;
c0105c73:	c7 05 10 50 12 c0 01 	movl   $0x1,0xc0125010
c0105c7a:	00 00 00 
          cprintf("SWAP: manager = %s\n", sm->name);
c0105c7d:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105c82:	8b 00                	mov    (%eax),%eax
c0105c84:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c88:	c7 04 24 27 a6 10 c0 	movl   $0xc010a627,(%esp)
c0105c8f:	e8 0d a6 ff ff       	call   c01002a1 <cprintf>
          check_swap();
c0105c94:	e8 9e 04 00 00       	call   c0106137 <check_swap>
     }

     return r;
c0105c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105c9c:	c9                   	leave  
c0105c9d:	c3                   	ret    

c0105c9e <swap_init_mm>:

int
swap_init_mm(struct mm_struct *mm)
{
c0105c9e:	55                   	push   %ebp
c0105c9f:	89 e5                	mov    %esp,%ebp
c0105ca1:	83 ec 18             	sub    $0x18,%esp
     return sm->init_mm(mm);
c0105ca4:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105ca9:	8b 40 08             	mov    0x8(%eax),%eax
c0105cac:	8b 55 08             	mov    0x8(%ebp),%edx
c0105caf:	89 14 24             	mov    %edx,(%esp)
c0105cb2:	ff d0                	call   *%eax
}
c0105cb4:	c9                   	leave  
c0105cb5:	c3                   	ret    

c0105cb6 <swap_tick_event>:

int
swap_tick_event(struct mm_struct *mm)
{
c0105cb6:	55                   	push   %ebp
c0105cb7:	89 e5                	mov    %esp,%ebp
c0105cb9:	83 ec 18             	sub    $0x18,%esp
     return sm->tick_event(mm);
c0105cbc:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105cc1:	8b 40 0c             	mov    0xc(%eax),%eax
c0105cc4:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cc7:	89 14 24             	mov    %edx,(%esp)
c0105cca:	ff d0                	call   *%eax
}
c0105ccc:	c9                   	leave  
c0105ccd:	c3                   	ret    

c0105cce <swap_map_swappable>:

int
swap_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0105cce:	55                   	push   %ebp
c0105ccf:	89 e5                	mov    %esp,%ebp
c0105cd1:	83 ec 18             	sub    $0x18,%esp
     return sm->map_swappable(mm, addr, page, swap_in);
c0105cd4:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105cd9:	8b 40 10             	mov    0x10(%eax),%eax
c0105cdc:	8b 55 14             	mov    0x14(%ebp),%edx
c0105cdf:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105ce3:	8b 55 10             	mov    0x10(%ebp),%edx
c0105ce6:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105cea:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ced:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105cf1:	8b 55 08             	mov    0x8(%ebp),%edx
c0105cf4:	89 14 24             	mov    %edx,(%esp)
c0105cf7:	ff d0                	call   *%eax
}
c0105cf9:	c9                   	leave  
c0105cfa:	c3                   	ret    

c0105cfb <swap_set_unswappable>:

int
swap_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0105cfb:	55                   	push   %ebp
c0105cfc:	89 e5                	mov    %esp,%ebp
c0105cfe:	83 ec 18             	sub    $0x18,%esp
     return sm->set_unswappable(mm, addr);
c0105d01:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105d06:	8b 40 14             	mov    0x14(%eax),%eax
c0105d09:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105d0c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d10:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d13:	89 14 24             	mov    %edx,(%esp)
c0105d16:	ff d0                	call   *%eax
}
c0105d18:	c9                   	leave  
c0105d19:	c3                   	ret    

c0105d1a <swap_out>:

volatile unsigned int swap_out_num=0;

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
c0105d1a:	55                   	push   %ebp
c0105d1b:	89 e5                	mov    %esp,%ebp
c0105d1d:	83 ec 38             	sub    $0x38,%esp
     int i;
     for (i = 0; i != n; ++ i)
c0105d20:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0105d27:	e9 53 01 00 00       	jmp    c0105e7f <swap_out+0x165>
     {
          uintptr_t v;
          //struct Page **ptr_page=NULL;
          struct Page *page;
          // cprintf("i %d, SWAP: call swap_out_victim\n",i);
          int r = sm->swap_out_victim(mm, &page, in_tick);
c0105d2c:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105d31:	8b 40 18             	mov    0x18(%eax),%eax
c0105d34:	8b 55 10             	mov    0x10(%ebp),%edx
c0105d37:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105d3b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
c0105d3e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d42:	8b 55 08             	mov    0x8(%ebp),%edx
c0105d45:	89 14 24             	mov    %edx,(%esp)
c0105d48:	ff d0                	call   *%eax
c0105d4a:	89 45 f0             	mov    %eax,-0x10(%ebp)
          if (r != 0) {
c0105d4d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105d51:	74 18                	je     c0105d6b <swap_out+0x51>
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
c0105d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105d56:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d5a:	c7 04 24 3c a6 10 c0 	movl   $0xc010a63c,(%esp)
c0105d61:	e8 3b a5 ff ff       	call   c01002a1 <cprintf>
c0105d66:	e9 20 01 00 00       	jmp    c0105e8b <swap_out+0x171>
          }          
          //assert(!PageReserved(page));

          //cprintf("SWAP: choose victim page 0x%08x\n", page);
          
          v=page->pra_vaddr; 
c0105d6b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105d6e:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105d71:	89 45 ec             	mov    %eax,-0x14(%ebp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
c0105d74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d77:	8b 40 0c             	mov    0xc(%eax),%eax
c0105d7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105d81:	00 
c0105d82:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d85:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105d89:	89 04 24             	mov    %eax,(%esp)
c0105d8c:	e8 6a de ff ff       	call   c0103bfb <get_pte>
c0105d91:	89 45 e8             	mov    %eax,-0x18(%ebp)
          assert((*ptep & PTE_P) != 0);
c0105d94:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d97:	8b 00                	mov    (%eax),%eax
c0105d99:	83 e0 01             	and    $0x1,%eax
c0105d9c:	85 c0                	test   %eax,%eax
c0105d9e:	75 24                	jne    c0105dc4 <swap_out+0xaa>
c0105da0:	c7 44 24 0c 69 a6 10 	movl   $0xc010a669,0xc(%esp)
c0105da7:	c0 
c0105da8:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105daf:	c0 
c0105db0:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c0105db7:	00 
c0105db8:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105dbf:	e8 34 a6 ff ff       	call   c01003f8 <__panic>

          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
c0105dc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105dc7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105dca:	8b 52 1c             	mov    0x1c(%edx),%edx
c0105dcd:	c1 ea 0c             	shr    $0xc,%edx
c0105dd0:	42                   	inc    %edx
c0105dd1:	c1 e2 08             	shl    $0x8,%edx
c0105dd4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105dd8:	89 14 24             	mov    %edx,(%esp)
c0105ddb:	e8 88 27 00 00       	call   c0108568 <swapfs_write>
c0105de0:	85 c0                	test   %eax,%eax
c0105de2:	74 34                	je     c0105e18 <swap_out+0xfe>
                    cprintf("SWAP: failed to save\n");
c0105de4:	c7 04 24 93 a6 10 c0 	movl   $0xc010a693,(%esp)
c0105deb:	e8 b1 a4 ff ff       	call   c01002a1 <cprintf>
                    sm->map_swappable(mm, v, page, 0);
c0105df0:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c0105df5:	8b 40 10             	mov    0x10(%eax),%eax
c0105df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105dfb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0105e02:	00 
c0105e03:	89 54 24 08          	mov    %edx,0x8(%esp)
c0105e07:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e0a:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e0e:	8b 55 08             	mov    0x8(%ebp),%edx
c0105e11:	89 14 24             	mov    %edx,(%esp)
c0105e14:	ff d0                	call   *%eax
c0105e16:	eb 64                	jmp    c0105e7c <swap_out+0x162>
                    continue;
          }
          else {
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
c0105e18:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e1b:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105e1e:	c1 e8 0c             	shr    $0xc,%eax
c0105e21:	40                   	inc    %eax
c0105e22:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105e26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105e29:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105e2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e30:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105e34:	c7 04 24 ac a6 10 c0 	movl   $0xc010a6ac,(%esp)
c0105e3b:	e8 61 a4 ff ff       	call   c01002a1 <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
c0105e40:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e43:	8b 40 1c             	mov    0x1c(%eax),%eax
c0105e46:	c1 e8 0c             	shr    $0xc,%eax
c0105e49:	40                   	inc    %eax
c0105e4a:	c1 e0 08             	shl    $0x8,%eax
c0105e4d:	89 c2                	mov    %eax,%edx
c0105e4f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e52:	89 10                	mov    %edx,(%eax)
                    free_page(page);
c0105e54:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105e57:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105e5e:	00 
c0105e5f:	89 04 24             	mov    %eax,(%esp)
c0105e62:	e8 32 d7 ff ff       	call   c0103599 <free_pages>
          }
          
          tlb_invalidate(mm->pgdir, v);
c0105e67:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e6a:	8b 40 0c             	mov    0xc(%eax),%eax
c0105e6d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e70:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105e74:	89 04 24             	mov    %eax,(%esp)
c0105e77:	e8 71 e0 ff ff       	call   c0103eed <tlb_invalidate>

int
swap_out(struct mm_struct *mm, int n, int in_tick)
{
     int i;
     for (i = 0; i != n; ++ i)
c0105e7c:	ff 45 f4             	incl   -0xc(%ebp)
c0105e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105e82:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105e85:	0f 85 a1 fe ff ff    	jne    c0105d2c <swap_out+0x12>
                    free_page(page);
          }
          
          tlb_invalidate(mm->pgdir, v);
     }
     return i;
c0105e8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105e8e:	c9                   	leave  
c0105e8f:	c3                   	ret    

c0105e90 <swap_in>:
// swap_in(mm, addr, &page) : alloc a memory page, then according to the swap entry in PTE for addr,
// find the addr of disk page, read the content of disk page into this memroy page
int
swap_in(struct mm_struct *mm, uintptr_t addr, struct Page **ptr_result)
{
c0105e90:	55                   	push   %ebp
c0105e91:	89 e5                	mov    %esp,%ebp
c0105e93:	83 ec 28             	sub    $0x28,%esp
     struct Page *result = alloc_page();
c0105e96:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105e9d:	e8 8c d6 ff ff       	call   c010352e <alloc_pages>
c0105ea2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     assert(result!=NULL);
c0105ea5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105ea9:	75 24                	jne    c0105ecf <swap_in+0x3f>
c0105eab:	c7 44 24 0c ec a6 10 	movl   $0xc010a6ec,0xc(%esp)
c0105eb2:	c0 
c0105eb3:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105eba:	c0 
c0105ebb:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
c0105ec2:	00 
c0105ec3:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105eca:	e8 29 a5 ff ff       	call   c01003f8 <__panic>

     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
c0105ecf:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed2:	8b 40 0c             	mov    0xc(%eax),%eax
c0105ed5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0105edc:	00 
c0105edd:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ee0:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105ee4:	89 04 24             	mov    %eax,(%esp)
c0105ee7:	e8 0f dd ff ff       	call   c0103bfb <get_pte>
c0105eec:	89 45 f0             	mov    %eax,-0x10(%ebp)
     // cprintf("SWAP: load ptep %x swap entry %d to vaddr 0x%08x, page %x, No %d\n", ptep, (*ptep)>>8, addr, result, (result-pages));
    
     int r;
     if ((r = swapfs_read((*ptep), result)) != 0)
c0105eef:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ef2:	8b 00                	mov    (%eax),%eax
c0105ef4:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105ef7:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105efb:	89 04 24             	mov    %eax,(%esp)
c0105efe:	e8 f3 25 00 00       	call   c01084f6 <swapfs_read>
c0105f03:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105f06:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105f0a:	74 2a                	je     c0105f36 <swap_in+0xa6>
     {
        assert(r!=0);
c0105f0c:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0105f10:	75 24                	jne    c0105f36 <swap_in+0xa6>
c0105f12:	c7 44 24 0c f9 a6 10 	movl   $0xc010a6f9,0xc(%esp)
c0105f19:	c0 
c0105f1a:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105f21:	c0 
c0105f22:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
c0105f29:	00 
c0105f2a:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105f31:	e8 c2 a4 ff ff       	call   c01003f8 <__panic>
     }
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
c0105f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105f39:	8b 00                	mov    (%eax),%eax
c0105f3b:	c1 e8 08             	shr    $0x8,%eax
c0105f3e:	89 c2                	mov    %eax,%edx
c0105f40:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105f43:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105f47:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105f4b:	c7 04 24 00 a7 10 c0 	movl   $0xc010a700,(%esp)
c0105f52:	e8 4a a3 ff ff       	call   c01002a1 <cprintf>
     *ptr_result=result;
c0105f57:	8b 45 10             	mov    0x10(%ebp),%eax
c0105f5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105f5d:	89 10                	mov    %edx,(%eax)
     return 0;
c0105f5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105f64:	c9                   	leave  
c0105f65:	c3                   	ret    

c0105f66 <check_content_set>:



static inline void
check_content_set(void)
{
c0105f66:	55                   	push   %ebp
c0105f67:	89 e5                	mov    %esp,%ebp
c0105f69:	83 ec 18             	sub    $0x18,%esp
     *(unsigned char *)0x1000 = 0x0a;
c0105f6c:	b8 00 10 00 00       	mov    $0x1000,%eax
c0105f71:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105f74:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0105f79:	83 f8 01             	cmp    $0x1,%eax
c0105f7c:	74 24                	je     c0105fa2 <check_content_set+0x3c>
c0105f7e:	c7 44 24 0c 3e a7 10 	movl   $0xc010a73e,0xc(%esp)
c0105f85:	c0 
c0105f86:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105f8d:	c0 
c0105f8e:	c7 44 24 04 92 00 00 	movl   $0x92,0x4(%esp)
c0105f95:	00 
c0105f96:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105f9d:	e8 56 a4 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x1010 = 0x0a;
c0105fa2:	b8 10 10 00 00       	mov    $0x1010,%eax
c0105fa7:	c6 00 0a             	movb   $0xa,(%eax)
     assert(pgfault_num==1);
c0105faa:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0105faf:	83 f8 01             	cmp    $0x1,%eax
c0105fb2:	74 24                	je     c0105fd8 <check_content_set+0x72>
c0105fb4:	c7 44 24 0c 3e a7 10 	movl   $0xc010a73e,0xc(%esp)
c0105fbb:	c0 
c0105fbc:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105fc3:	c0 
c0105fc4:	c7 44 24 04 94 00 00 	movl   $0x94,0x4(%esp)
c0105fcb:	00 
c0105fcc:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0105fd3:	e8 20 a4 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2000 = 0x0b;
c0105fd8:	b8 00 20 00 00       	mov    $0x2000,%eax
c0105fdd:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0105fe0:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0105fe5:	83 f8 02             	cmp    $0x2,%eax
c0105fe8:	74 24                	je     c010600e <check_content_set+0xa8>
c0105fea:	c7 44 24 0c 4d a7 10 	movl   $0xc010a74d,0xc(%esp)
c0105ff1:	c0 
c0105ff2:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0105ff9:	c0 
c0105ffa:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
c0106001:	00 
c0106002:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106009:	e8 ea a3 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x2010 = 0x0b;
c010600e:	b8 10 20 00 00       	mov    $0x2010,%eax
c0106013:	c6 00 0b             	movb   $0xb,(%eax)
     assert(pgfault_num==2);
c0106016:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c010601b:	83 f8 02             	cmp    $0x2,%eax
c010601e:	74 24                	je     c0106044 <check_content_set+0xde>
c0106020:	c7 44 24 0c 4d a7 10 	movl   $0xc010a74d,0xc(%esp)
c0106027:	c0 
c0106028:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c010602f:	c0 
c0106030:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
c0106037:	00 
c0106038:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c010603f:	e8 b4 a3 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3000 = 0x0c;
c0106044:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106049:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c010604c:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106051:	83 f8 03             	cmp    $0x3,%eax
c0106054:	74 24                	je     c010607a <check_content_set+0x114>
c0106056:	c7 44 24 0c 5c a7 10 	movl   $0xc010a75c,0xc(%esp)
c010605d:	c0 
c010605e:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106065:	c0 
c0106066:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c010606d:	00 
c010606e:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106075:	e8 7e a3 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x3010 = 0x0c;
c010607a:	b8 10 30 00 00       	mov    $0x3010,%eax
c010607f:	c6 00 0c             	movb   $0xc,(%eax)
     assert(pgfault_num==3);
c0106082:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106087:	83 f8 03             	cmp    $0x3,%eax
c010608a:	74 24                	je     c01060b0 <check_content_set+0x14a>
c010608c:	c7 44 24 0c 5c a7 10 	movl   $0xc010a75c,0xc(%esp)
c0106093:	c0 
c0106094:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c010609b:	c0 
c010609c:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c01060a3:	00 
c01060a4:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01060ab:	e8 48 a3 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4000 = 0x0d;
c01060b0:	b8 00 40 00 00       	mov    $0x4000,%eax
c01060b5:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01060b8:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01060bd:	83 f8 04             	cmp    $0x4,%eax
c01060c0:	74 24                	je     c01060e6 <check_content_set+0x180>
c01060c2:	c7 44 24 0c 6b a7 10 	movl   $0xc010a76b,0xc(%esp)
c01060c9:	c0 
c01060ca:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01060d1:	c0 
c01060d2:	c7 44 24 04 9e 00 00 	movl   $0x9e,0x4(%esp)
c01060d9:	00 
c01060da:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01060e1:	e8 12 a3 ff ff       	call   c01003f8 <__panic>
     *(unsigned char *)0x4010 = 0x0d;
c01060e6:	b8 10 40 00 00       	mov    $0x4010,%eax
c01060eb:	c6 00 0d             	movb   $0xd,(%eax)
     assert(pgfault_num==4);
c01060ee:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01060f3:	83 f8 04             	cmp    $0x4,%eax
c01060f6:	74 24                	je     c010611c <check_content_set+0x1b6>
c01060f8:	c7 44 24 0c 6b a7 10 	movl   $0xc010a76b,0xc(%esp)
c01060ff:	c0 
c0106100:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106107:	c0 
c0106108:	c7 44 24 04 a0 00 00 	movl   $0xa0,0x4(%esp)
c010610f:	00 
c0106110:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106117:	e8 dc a2 ff ff       	call   c01003f8 <__panic>
}
c010611c:	90                   	nop
c010611d:	c9                   	leave  
c010611e:	c3                   	ret    

c010611f <check_content_access>:

static inline int
check_content_access(void)
{
c010611f:	55                   	push   %ebp
c0106120:	89 e5                	mov    %esp,%ebp
c0106122:	83 ec 18             	sub    $0x18,%esp
    int ret = sm->check_swap();
c0106125:	a1 18 50 12 c0       	mov    0xc0125018,%eax
c010612a:	8b 40 1c             	mov    0x1c(%eax),%eax
c010612d:	ff d0                	call   *%eax
c010612f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return ret;
c0106132:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106135:	c9                   	leave  
c0106136:	c3                   	ret    

c0106137 <check_swap>:
#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
check_swap(void)
{
c0106137:	55                   	push   %ebp
c0106138:	89 e5                	mov    %esp,%ebp
c010613a:	83 ec 78             	sub    $0x78,%esp
    //backup mem env
     int ret, count = 0, total = 0, i;
c010613d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0106144:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
     list_entry_t *le = &free_list;
c010614b:	c7 45 e8 0c 51 12 c0 	movl   $0xc012510c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106152:	eb 6a                	jmp    c01061be <check_swap+0x87>
        struct Page *p = le2page(le, page_link);
c0106154:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106157:	83 e8 0c             	sub    $0xc,%eax
c010615a:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(PageProperty(p));
c010615d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106160:	83 c0 04             	add    $0x4,%eax
c0106163:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c010616a:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010616d:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0106170:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0106173:	0f a3 10             	bt     %edx,(%eax)
c0106176:	19 c0                	sbb    %eax,%eax
c0106178:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c010617b:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c010617f:	0f 95 c0             	setne  %al
c0106182:	0f b6 c0             	movzbl %al,%eax
c0106185:	85 c0                	test   %eax,%eax
c0106187:	75 24                	jne    c01061ad <check_swap+0x76>
c0106189:	c7 44 24 0c 7a a7 10 	movl   $0xc010a77a,0xc(%esp)
c0106190:	c0 
c0106191:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106198:	c0 
c0106199:	c7 44 24 04 bb 00 00 	movl   $0xbb,0x4(%esp)
c01061a0:	00 
c01061a1:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01061a8:	e8 4b a2 ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c01061ad:	ff 45 f4             	incl   -0xc(%ebp)
c01061b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01061b3:	8b 50 08             	mov    0x8(%eax),%edx
c01061b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061b9:	01 d0                	add    %edx,%eax
c01061bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01061be:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01061c1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01061c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01061c7:	8b 40 04             	mov    0x4(%eax),%eax
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c01061ca:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01061cd:	81 7d e8 0c 51 12 c0 	cmpl   $0xc012510c,-0x18(%ebp)
c01061d4:	0f 85 7a ff ff ff    	jne    c0106154 <check_swap+0x1d>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
     }
     assert(total == nr_free_pages());
c01061da:	e8 ed d3 ff ff       	call   c01035cc <nr_free_pages>
c01061df:	89 c2                	mov    %eax,%edx
c01061e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01061e4:	39 c2                	cmp    %eax,%edx
c01061e6:	74 24                	je     c010620c <check_swap+0xd5>
c01061e8:	c7 44 24 0c 8a a7 10 	movl   $0xc010a78a,0xc(%esp)
c01061ef:	c0 
c01061f0:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01061f7:	c0 
c01061f8:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
c01061ff:	00 
c0106200:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106207:	e8 ec a1 ff ff       	call   c01003f8 <__panic>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
c010620c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010620f:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106213:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106216:	89 44 24 04          	mov    %eax,0x4(%esp)
c010621a:	c7 04 24 a4 a7 10 c0 	movl   $0xc010a7a4,(%esp)
c0106221:	e8 7b a0 ff ff       	call   c01002a1 <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
c0106226:	e8 29 ec ff ff       	call   c0104e54 <mm_create>
c010622b:	89 45 d8             	mov    %eax,-0x28(%ebp)
     assert(mm != NULL);
c010622e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0106232:	75 24                	jne    c0106258 <check_swap+0x121>
c0106234:	c7 44 24 0c ca a7 10 	movl   $0xc010a7ca,0xc(%esp)
c010623b:	c0 
c010623c:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106243:	c0 
c0106244:	c7 44 24 04 c3 00 00 	movl   $0xc3,0x4(%esp)
c010624b:	00 
c010624c:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106253:	e8 a0 a1 ff ff       	call   c01003f8 <__panic>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
c0106258:	a1 2c 50 12 c0       	mov    0xc012502c,%eax
c010625d:	85 c0                	test   %eax,%eax
c010625f:	74 24                	je     c0106285 <check_swap+0x14e>
c0106261:	c7 44 24 0c d5 a7 10 	movl   $0xc010a7d5,0xc(%esp)
c0106268:	c0 
c0106269:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106270:	c0 
c0106271:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
c0106278:	00 
c0106279:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106280:	e8 73 a1 ff ff       	call   c01003f8 <__panic>

     check_mm_struct = mm;
c0106285:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106288:	a3 2c 50 12 c0       	mov    %eax,0xc012502c

     pde_t *pgdir = mm->pgdir = boot_pgdir;
c010628d:	8b 15 e0 19 12 c0    	mov    0xc01219e0,%edx
c0106293:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106296:	89 50 0c             	mov    %edx,0xc(%eax)
c0106299:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010629c:	8b 40 0c             	mov    0xc(%eax),%eax
c010629f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
     assert(pgdir[0] == 0);
c01062a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01062a5:	8b 00                	mov    (%eax),%eax
c01062a7:	85 c0                	test   %eax,%eax
c01062a9:	74 24                	je     c01062cf <check_swap+0x198>
c01062ab:	c7 44 24 0c ed a7 10 	movl   $0xc010a7ed,0xc(%esp)
c01062b2:	c0 
c01062b3:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01062ba:	c0 
c01062bb:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01062c2:	00 
c01062c3:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01062ca:	e8 29 a1 ff ff       	call   c01003f8 <__panic>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
c01062cf:	c7 44 24 08 03 00 00 	movl   $0x3,0x8(%esp)
c01062d6:	00 
c01062d7:	c7 44 24 04 00 60 00 	movl   $0x6000,0x4(%esp)
c01062de:	00 
c01062df:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
c01062e6:	e8 e1 eb ff ff       	call   c0104ecc <vma_create>
c01062eb:	89 45 d0             	mov    %eax,-0x30(%ebp)
     assert(vma != NULL);
c01062ee:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
c01062f2:	75 24                	jne    c0106318 <check_swap+0x1e1>
c01062f4:	c7 44 24 0c fb a7 10 	movl   $0xc010a7fb,0xc(%esp)
c01062fb:	c0 
c01062fc:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106303:	c0 
c0106304:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c010630b:	00 
c010630c:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106313:	e8 e0 a0 ff ff       	call   c01003f8 <__panic>

     insert_vma_struct(mm, vma);
c0106318:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010631b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010631f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106322:	89 04 24             	mov    %eax,(%esp)
c0106325:	e8 33 ed ff ff       	call   c010505d <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
c010632a:	c7 04 24 08 a8 10 c0 	movl   $0xc010a808,(%esp)
c0106331:	e8 6b 9f ff ff       	call   c01002a1 <cprintf>
     pte_t *temp_ptep=NULL;
c0106336:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
c010633d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106340:	8b 40 0c             	mov    0xc(%eax),%eax
c0106343:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010634a:	00 
c010634b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0106352:	00 
c0106353:	89 04 24             	mov    %eax,(%esp)
c0106356:	e8 a0 d8 ff ff       	call   c0103bfb <get_pte>
c010635b:	89 45 cc             	mov    %eax,-0x34(%ebp)
     assert(temp_ptep!= NULL);
c010635e:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c0106362:	75 24                	jne    c0106388 <check_swap+0x251>
c0106364:	c7 44 24 0c 3c a8 10 	movl   $0xc010a83c,0xc(%esp)
c010636b:	c0 
c010636c:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106373:	c0 
c0106374:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
c010637b:	00 
c010637c:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106383:	e8 70 a0 ff ff       	call   c01003f8 <__panic>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
c0106388:	c7 04 24 50 a8 10 c0 	movl   $0xc010a850,(%esp)
c010638f:	e8 0d 9f ff ff       	call   c01002a1 <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106394:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c010639b:	e9 a4 00 00 00       	jmp    c0106444 <check_swap+0x30d>
          check_rp[i] = alloc_page();
c01063a0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01063a7:	e8 82 d1 ff ff       	call   c010352e <alloc_pages>
c01063ac:	89 c2                	mov    %eax,%edx
c01063ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063b1:	89 14 85 40 50 12 c0 	mov    %edx,-0x3fedafc0(,%eax,4)
          assert(check_rp[i] != NULL );
c01063b8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063bb:	8b 04 85 40 50 12 c0 	mov    -0x3fedafc0(,%eax,4),%eax
c01063c2:	85 c0                	test   %eax,%eax
c01063c4:	75 24                	jne    c01063ea <check_swap+0x2b3>
c01063c6:	c7 44 24 0c 74 a8 10 	movl   $0xc010a874,0xc(%esp)
c01063cd:	c0 
c01063ce:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01063d5:	c0 
c01063d6:	c7 44 24 04 db 00 00 	movl   $0xdb,0x4(%esp)
c01063dd:	00 
c01063de:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01063e5:	e8 0e a0 ff ff       	call   c01003f8 <__panic>
          assert(!PageProperty(check_rp[i]));
c01063ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01063ed:	8b 04 85 40 50 12 c0 	mov    -0x3fedafc0(,%eax,4),%eax
c01063f4:	83 c0 04             	add    $0x4,%eax
c01063f7:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
c01063fe:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106401:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0106404:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106407:	0f a3 10             	bt     %edx,(%eax)
c010640a:	19 c0                	sbb    %eax,%eax
c010640c:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c010640f:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0106413:	0f 95 c0             	setne  %al
c0106416:	0f b6 c0             	movzbl %al,%eax
c0106419:	85 c0                	test   %eax,%eax
c010641b:	74 24                	je     c0106441 <check_swap+0x30a>
c010641d:	c7 44 24 0c 88 a8 10 	movl   $0xc010a888,0xc(%esp)
c0106424:	c0 
c0106425:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c010642c:	c0 
c010642d:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c0106434:	00 
c0106435:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c010643c:	e8 b7 9f ff ff       	call   c01003f8 <__panic>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
     assert(temp_ptep!= NULL);
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106441:	ff 45 ec             	incl   -0x14(%ebp)
c0106444:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c0106448:	0f 8e 52 ff ff ff    	jle    c01063a0 <check_swap+0x269>
          check_rp[i] = alloc_page();
          assert(check_rp[i] != NULL );
          assert(!PageProperty(check_rp[i]));
     }
     list_entry_t free_list_store = free_list;
c010644e:	a1 0c 51 12 c0       	mov    0xc012510c,%eax
c0106453:	8b 15 10 51 12 c0    	mov    0xc0125110,%edx
c0106459:	89 45 98             	mov    %eax,-0x68(%ebp)
c010645c:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010645f:	c7 45 c0 0c 51 12 c0 	movl   $0xc012510c,-0x40(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106466:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106469:	8b 55 c0             	mov    -0x40(%ebp),%edx
c010646c:	89 50 04             	mov    %edx,0x4(%eax)
c010646f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106472:	8b 50 04             	mov    0x4(%eax),%edx
c0106475:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106478:	89 10                	mov    %edx,(%eax)
c010647a:	c7 45 c8 0c 51 12 c0 	movl   $0xc012510c,-0x38(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0106481:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106484:	8b 40 04             	mov    0x4(%eax),%eax
c0106487:	39 45 c8             	cmp    %eax,-0x38(%ebp)
c010648a:	0f 94 c0             	sete   %al
c010648d:	0f b6 c0             	movzbl %al,%eax
     list_init(&free_list);
     assert(list_empty(&free_list));
c0106490:	85 c0                	test   %eax,%eax
c0106492:	75 24                	jne    c01064b8 <check_swap+0x381>
c0106494:	c7 44 24 0c a3 a8 10 	movl   $0xc010a8a3,0xc(%esp)
c010649b:	c0 
c010649c:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01064a3:	c0 
c01064a4:	c7 44 24 04 e0 00 00 	movl   $0xe0,0x4(%esp)
c01064ab:	00 
c01064ac:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01064b3:	e8 40 9f ff ff       	call   c01003f8 <__panic>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
c01064b8:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c01064bd:	89 45 bc             	mov    %eax,-0x44(%ebp)
     nr_free = 0;
c01064c0:	c7 05 14 51 12 c0 00 	movl   $0x0,0xc0125114
c01064c7:	00 00 00 
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01064ca:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01064d1:	eb 1d                	jmp    c01064f0 <check_swap+0x3b9>
        free_pages(check_rp[i],1);
c01064d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01064d6:	8b 04 85 40 50 12 c0 	mov    -0x3fedafc0(,%eax,4),%eax
c01064dd:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01064e4:	00 
c01064e5:	89 04 24             	mov    %eax,(%esp)
c01064e8:	e8 ac d0 ff ff       	call   c0103599 <free_pages>
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01064ed:	ff 45 ec             	incl   -0x14(%ebp)
c01064f0:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c01064f4:	7e dd                	jle    c01064d3 <check_swap+0x39c>
        free_pages(check_rp[i],1);
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
c01064f6:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c01064fb:	83 f8 04             	cmp    $0x4,%eax
c01064fe:	74 24                	je     c0106524 <check_swap+0x3ed>
c0106500:	c7 44 24 0c bc a8 10 	movl   $0xc010a8bc,0xc(%esp)
c0106507:	c0 
c0106508:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c010650f:	c0 
c0106510:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
c0106517:	00 
c0106518:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c010651f:	e8 d4 9e ff ff       	call   c01003f8 <__panic>
     
     cprintf("set up init env for check_swap begin!\n");
c0106524:	c7 04 24 e0 a8 10 c0 	movl   $0xc010a8e0,(%esp)
c010652b:	e8 71 9d ff ff       	call   c01002a1 <cprintf>
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
c0106530:	c7 05 0c 50 12 c0 00 	movl   $0x0,0xc012500c
c0106537:	00 00 00 
     
     check_content_set();
c010653a:	e8 27 fa ff ff       	call   c0105f66 <check_content_set>
     assert( nr_free == 0);         
c010653f:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0106544:	85 c0                	test   %eax,%eax
c0106546:	74 24                	je     c010656c <check_swap+0x435>
c0106548:	c7 44 24 0c 07 a9 10 	movl   $0xc010a907,0xc(%esp)
c010654f:	c0 
c0106550:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106557:	c0 
c0106558:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
c010655f:	00 
c0106560:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106567:	e8 8c 9e ff ff       	call   c01003f8 <__panic>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c010656c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0106573:	eb 25                	jmp    c010659a <check_swap+0x463>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
c0106575:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106578:	c7 04 85 60 50 12 c0 	movl   $0xffffffff,-0x3fedafa0(,%eax,4)
c010657f:	ff ff ff ff 
c0106583:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106586:	8b 14 85 60 50 12 c0 	mov    -0x3fedafa0(,%eax,4),%edx
c010658d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106590:	89 14 85 a0 50 12 c0 	mov    %edx,-0x3fedaf60(,%eax,4)
     
     pgfault_num=0;
     
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
c0106597:	ff 45 ec             	incl   -0x14(%ebp)
c010659a:	83 7d ec 09          	cmpl   $0x9,-0x14(%ebp)
c010659e:	7e d5                	jle    c0106575 <check_swap+0x43e>
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01065a0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01065a7:	e9 ec 00 00 00       	jmp    c0106698 <check_swap+0x561>
         check_ptep[i]=0;
c01065ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065af:	c7 04 85 f4 50 12 c0 	movl   $0x0,-0x3fedaf0c(,%eax,4)
c01065b6:	00 00 00 00 
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
c01065ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065bd:	40                   	inc    %eax
c01065be:	c1 e0 0c             	shl    $0xc,%eax
c01065c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01065c8:	00 
c01065c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01065cd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01065d0:	89 04 24             	mov    %eax,(%esp)
c01065d3:	e8 23 d6 ff ff       	call   c0103bfb <get_pte>
c01065d8:	89 c2                	mov    %eax,%edx
c01065da:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065dd:	89 14 85 f4 50 12 c0 	mov    %edx,-0x3fedaf0c(,%eax,4)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
c01065e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01065e7:	8b 04 85 f4 50 12 c0 	mov    -0x3fedaf0c(,%eax,4),%eax
c01065ee:	85 c0                	test   %eax,%eax
c01065f0:	75 24                	jne    c0106616 <check_swap+0x4df>
c01065f2:	c7 44 24 0c 14 a9 10 	movl   $0xc010a914,0xc(%esp)
c01065f9:	c0 
c01065fa:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106601:	c0 
c0106602:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c0106609:	00 
c010660a:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106611:	e8 e2 9d ff ff       	call   c01003f8 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
c0106616:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106619:	8b 04 85 f4 50 12 c0 	mov    -0x3fedaf0c(,%eax,4),%eax
c0106620:	8b 00                	mov    (%eax),%eax
c0106622:	89 04 24             	mov    %eax,(%esp)
c0106625:	e8 a6 f5 ff ff       	call   c0105bd0 <pte2page>
c010662a:	89 c2                	mov    %eax,%edx
c010662c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010662f:	8b 04 85 40 50 12 c0 	mov    -0x3fedafc0(,%eax,4),%eax
c0106636:	39 c2                	cmp    %eax,%edx
c0106638:	74 24                	je     c010665e <check_swap+0x527>
c010663a:	c7 44 24 0c 2c a9 10 	movl   $0xc010a92c,0xc(%esp)
c0106641:	c0 
c0106642:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106649:	c0 
c010664a:	c7 44 24 04 fb 00 00 	movl   $0xfb,0x4(%esp)
c0106651:	00 
c0106652:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106659:	e8 9a 9d ff ff       	call   c01003f8 <__panic>
         assert((*check_ptep[i] & PTE_P));          
c010665e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106661:	8b 04 85 f4 50 12 c0 	mov    -0x3fedaf0c(,%eax,4),%eax
c0106668:	8b 00                	mov    (%eax),%eax
c010666a:	83 e0 01             	and    $0x1,%eax
c010666d:	85 c0                	test   %eax,%eax
c010666f:	75 24                	jne    c0106695 <check_swap+0x55e>
c0106671:	c7 44 24 0c 54 a9 10 	movl   $0xc010a954,0xc(%esp)
c0106678:	c0 
c0106679:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c0106680:	c0 
c0106681:	c7 44 24 04 fc 00 00 	movl   $0xfc,0x4(%esp)
c0106688:	00 
c0106689:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c0106690:	e8 63 9d ff ff       	call   c01003f8 <__panic>
     check_content_set();
     assert( nr_free == 0);         
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106695:	ff 45 ec             	incl   -0x14(%ebp)
c0106698:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010669c:	0f 8e 0a ff ff ff    	jle    c01065ac <check_swap+0x475>
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
         assert((*check_ptep[i] & PTE_P));          
     }
     cprintf("set up init env for check_swap over!\n");
c01066a2:	c7 04 24 70 a9 10 c0 	movl   $0xc010a970,(%esp)
c01066a9:	e8 f3 9b ff ff       	call   c01002a1 <cprintf>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
c01066ae:	e8 6c fa ff ff       	call   c010611f <check_content_access>
c01066b3:	89 45 b8             	mov    %eax,-0x48(%ebp)
     assert(ret==0);
c01066b6:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01066ba:	74 24                	je     c01066e0 <check_swap+0x5a9>
c01066bc:	c7 44 24 0c 96 a9 10 	movl   $0xc010a996,0xc(%esp)
c01066c3:	c0 
c01066c4:	c7 44 24 08 7e a6 10 	movl   $0xc010a67e,0x8(%esp)
c01066cb:	c0 
c01066cc:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01066d3:	00 
c01066d4:	c7 04 24 18 a6 10 c0 	movl   $0xc010a618,(%esp)
c01066db:	e8 18 9d ff ff       	call   c01003f8 <__panic>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c01066e0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01066e7:	eb 1d                	jmp    c0106706 <check_swap+0x5cf>
         free_pages(check_rp[i],1);
c01066e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01066ec:	8b 04 85 40 50 12 c0 	mov    -0x3fedafc0(,%eax,4),%eax
c01066f3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01066fa:	00 
c01066fb:	89 04 24             	mov    %eax,(%esp)
c01066fe:	e8 96 ce ff ff       	call   c0103599 <free_pages>
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
c0106703:	ff 45 ec             	incl   -0x14(%ebp)
c0106706:	83 7d ec 03          	cmpl   $0x3,-0x14(%ebp)
c010670a:	7e dd                	jle    c01066e9 <check_swap+0x5b2>
         free_pages(check_rp[i],1);
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
c010670c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010670f:	89 04 24             	mov    %eax,(%esp)
c0106712:	e8 78 ea ff ff       	call   c010518f <mm_destroy>
         
     nr_free = nr_free_store;
c0106717:	8b 45 bc             	mov    -0x44(%ebp),%eax
c010671a:	a3 14 51 12 c0       	mov    %eax,0xc0125114
     free_list = free_list_store;
c010671f:	8b 45 98             	mov    -0x68(%ebp),%eax
c0106722:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0106725:	a3 0c 51 12 c0       	mov    %eax,0xc012510c
c010672a:	89 15 10 51 12 c0    	mov    %edx,0xc0125110

     
     le = &free_list;
c0106730:	c7 45 e8 0c 51 12 c0 	movl   $0xc012510c,-0x18(%ebp)
     while ((le = list_next(le)) != &free_list) {
c0106737:	eb 1c                	jmp    c0106755 <check_swap+0x61e>
         struct Page *p = le2page(le, page_link);
c0106739:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010673c:	83 e8 0c             	sub    $0xc,%eax
c010673f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
         count --, total -= p->property;
c0106742:	ff 4d f4             	decl   -0xc(%ebp)
c0106745:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0106748:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010674b:	8b 40 08             	mov    0x8(%eax),%eax
c010674e:	29 c2                	sub    %eax,%edx
c0106750:	89 d0                	mov    %edx,%eax
c0106752:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106755:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106758:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010675b:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c010675e:	8b 40 04             	mov    0x4(%eax),%eax
     nr_free = nr_free_store;
     free_list = free_list_store;

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
c0106761:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106764:	81 7d e8 0c 51 12 c0 	cmpl   $0xc012510c,-0x18(%ebp)
c010676b:	75 cc                	jne    c0106739 <check_swap+0x602>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
     }
     cprintf("count is %d, total is %d\n",count,total);
c010676d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106770:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106774:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106777:	89 44 24 04          	mov    %eax,0x4(%esp)
c010677b:	c7 04 24 9d a9 10 c0 	movl   $0xc010a99d,(%esp)
c0106782:	e8 1a 9b ff ff       	call   c01002a1 <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
c0106787:	c7 04 24 b7 a9 10 c0 	movl   $0xc010a9b7,(%esp)
c010678e:	e8 0e 9b ff ff       	call   c01002a1 <cprintf>
}
c0106793:	90                   	nop
c0106794:	c9                   	leave  
c0106795:	c3                   	ret    

c0106796 <_fifo_init_mm>:
 * (2) _fifo_init_mm: init pra_list_head and let  mm->sm_priv point to the addr of pra_list_head.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
c0106796:	55                   	push   %ebp
c0106797:	89 e5                	mov    %esp,%ebp
c0106799:	83 ec 10             	sub    $0x10,%esp
c010679c:	c7 45 fc 04 51 12 c0 	movl   $0xc0125104,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01067a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067a6:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01067a9:	89 50 04             	mov    %edx,0x4(%eax)
c01067ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067af:	8b 50 04             	mov    0x4(%eax),%edx
c01067b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01067b5:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c01067b7:	8b 45 08             	mov    0x8(%ebp),%eax
c01067ba:	c7 40 14 04 51 12 c0 	movl   $0xc0125104,0x14(%eax)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
c01067c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01067c6:	c9                   	leave  
c01067c7:	c3                   	ret    

c01067c8 <_fifo_map_swappable>:
/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head qeueue
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c01067c8:	55                   	push   %ebp
c01067c9:	89 e5                	mov    %esp,%ebp
c01067cb:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c01067ce:	8b 45 08             	mov    0x8(%ebp),%eax
c01067d1:	8b 40 14             	mov    0x14(%eax),%eax
c01067d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c01067d7:	8b 45 10             	mov    0x10(%ebp),%eax
c01067da:	83 c0 14             	add    $0x14,%eax
c01067dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c01067e0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01067e4:	74 06                	je     c01067ec <_fifo_map_swappable+0x24>
c01067e6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01067ea:	75 24                	jne    c0106810 <_fifo_map_swappable+0x48>
c01067ec:	c7 44 24 0c d0 a9 10 	movl   $0xc010a9d0,0xc(%esp)
c01067f3:	c0 
c01067f4:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c01067fb:	c0 
c01067fc:	c7 44 24 04 32 00 00 	movl   $0x32,0x4(%esp)
c0106803:	00 
c0106804:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c010680b:	e8 e8 9b ff ff       	call   c01003f8 <__panic>
c0106810:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106813:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106816:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106819:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010681c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010681f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0106822:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106825:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106828:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010682b:	8b 40 04             	mov    0x4(%eax),%eax
c010682e:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106831:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0106834:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0106837:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010683a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c010683d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106840:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106843:	89 10                	mov    %edx,(%eax)
c0106845:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106848:	8b 10                	mov    (%eax),%edx
c010684a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010684d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106850:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0106853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106856:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106859:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010685c:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010685f:	89 10                	mov    %edx,(%eax)
    //record the page access situlation
    /*LAB3 EXERCISE 2: YOUR CODE*/ 
    //(1)link the most recent arrival page at the back of the pra_list_head qeueue.
    list_add(head, entry);
    return 0;
c0106861:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106866:	c9                   	leave  
c0106867:	c3                   	ret    

c0106868 <_fifo_swap_out_victim>:
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head qeueue,
 *                            then assign the value of *ptr_page to the addr of this page.
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0106868:	55                   	push   %ebp
c0106869:	89 e5                	mov    %esp,%ebp
c010686b:	83 ec 38             	sub    $0x38,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c010686e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106871:	8b 40 14             	mov    0x14(%eax),%eax
c0106874:	89 45 f4             	mov    %eax,-0xc(%ebp)
         assert(head != NULL);
c0106877:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010687b:	75 24                	jne    c01068a1 <_fifo_swap_out_victim+0x39>
c010687d:	c7 44 24 0c 17 aa 10 	movl   $0xc010aa17,0xc(%esp)
c0106884:	c0 
c0106885:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c010688c:	c0 
c010688d:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
c0106894:	00 
c0106895:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c010689c:	e8 57 9b ff ff       	call   c01003f8 <__panic>
     assert(in_tick==0);
c01068a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01068a5:	74 24                	je     c01068cb <_fifo_swap_out_victim+0x63>
c01068a7:	c7 44 24 0c 24 aa 10 	movl   $0xc010aa24,0xc(%esp)
c01068ae:	c0 
c01068af:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c01068b6:	c0 
c01068b7:	c7 44 24 04 42 00 00 	movl   $0x42,0x4(%esp)
c01068be:	00 
c01068bf:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c01068c6:	e8 2d 9b ff ff       	call   c01003f8 <__panic>
     /* Select the victim */
     /*LAB3 EXERCISE 2: YOUR CODE*/ 
     //(1)  unlink the  earliest arrival page in front of pra_list_head qeueue
     list_entry_t *le = head->prev;
c01068cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068ce:	8b 00                	mov    (%eax),%eax
c01068d0:	89 45 f0             	mov    %eax,-0x10(%ebp)
     assert(head!=le);
c01068d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01068d6:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01068d9:	75 24                	jne    c01068ff <_fifo_swap_out_victim+0x97>
c01068db:	c7 44 24 0c 2f aa 10 	movl   $0xc010aa2f,0xc(%esp)
c01068e2:	c0 
c01068e3:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c01068ea:	c0 
c01068eb:	c7 44 24 04 47 00 00 	movl   $0x47,0x4(%esp)
c01068f2:	00 
c01068f3:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c01068fa:	e8 f9 9a ff ff       	call   c01003f8 <__panic>
     // convert list entry to page
     struct Page *p = le2page(le, pra_page_link);
c01068ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106902:	83 e8 14             	sub    $0x14,%eax
c0106905:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0106908:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010690b:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010690e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106911:	8b 40 04             	mov    0x4(%eax),%eax
c0106914:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106917:	8b 12                	mov    (%edx),%edx
c0106919:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c010691c:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010691f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106922:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0106925:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106928:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010692b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010692e:	89 10                	mov    %edx,(%eax)
     list_del(le);
     assert(p !=NULL);
c0106930:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0106934:	75 24                	jne    c010695a <_fifo_swap_out_victim+0xf2>
c0106936:	c7 44 24 0c 38 aa 10 	movl   $0xc010aa38,0xc(%esp)
c010693d:	c0 
c010693e:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106945:	c0 
c0106946:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c010694d:	00 
c010694e:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106955:	e8 9e 9a ff ff       	call   c01003f8 <__panic>
     //(2)  assign the value of *ptr_page to the addr of this page
     *ptr_page = p;
c010695a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010695d:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106960:	89 10                	mov    %edx,(%eax)
     return 0;
c0106962:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106967:	c9                   	leave  
c0106968:	c3                   	ret    

c0106969 <_fifo_check_swap>:

static int
_fifo_check_swap(void) {
c0106969:	55                   	push   %ebp
c010696a:	89 e5                	mov    %esp,%ebp
c010696c:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c010696f:	c7 04 24 44 aa 10 c0 	movl   $0xc010aa44,(%esp)
c0106976:	e8 26 99 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c010697b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106980:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c0106983:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106988:	83 f8 04             	cmp    $0x4,%eax
c010698b:	74 24                	je     c01069b1 <_fifo_check_swap+0x48>
c010698d:	c7 44 24 0c 6a aa 10 	movl   $0xc010aa6a,0xc(%esp)
c0106994:	c0 
c0106995:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c010699c:	c0 
c010699d:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
c01069a4:	00 
c01069a5:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c01069ac:	e8 47 9a ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c01069b1:	c7 04 24 7c aa 10 c0 	movl   $0xc010aa7c,(%esp)
c01069b8:	e8 e4 98 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c01069bd:	b8 00 10 00 00       	mov    $0x1000,%eax
c01069c2:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c01069c5:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01069ca:	83 f8 04             	cmp    $0x4,%eax
c01069cd:	74 24                	je     c01069f3 <_fifo_check_swap+0x8a>
c01069cf:	c7 44 24 0c 6a aa 10 	movl   $0xc010aa6a,0xc(%esp)
c01069d6:	c0 
c01069d7:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c01069de:	c0 
c01069df:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
c01069e6:	00 
c01069e7:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c01069ee:	e8 05 9a ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c01069f3:	c7 04 24 a4 aa 10 c0 	movl   $0xc010aaa4,(%esp)
c01069fa:	e8 a2 98 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c01069ff:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106a04:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c0106a07:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106a0c:	83 f8 04             	cmp    $0x4,%eax
c0106a0f:	74 24                	je     c0106a35 <_fifo_check_swap+0xcc>
c0106a11:	c7 44 24 0c 6a aa 10 	movl   $0xc010aa6a,0xc(%esp)
c0106a18:	c0 
c0106a19:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106a20:	c0 
c0106a21:	c7 44 24 04 5b 00 00 	movl   $0x5b,0x4(%esp)
c0106a28:	00 
c0106a29:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106a30:	e8 c3 99 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106a35:	c7 04 24 cc aa 10 c0 	movl   $0xc010aacc,(%esp)
c0106a3c:	e8 60 98 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106a41:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106a46:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c0106a49:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106a4e:	83 f8 04             	cmp    $0x4,%eax
c0106a51:	74 24                	je     c0106a77 <_fifo_check_swap+0x10e>
c0106a53:	c7 44 24 0c 6a aa 10 	movl   $0xc010aa6a,0xc(%esp)
c0106a5a:	c0 
c0106a5b:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106a62:	c0 
c0106a63:	c7 44 24 04 5e 00 00 	movl   $0x5e,0x4(%esp)
c0106a6a:	00 
c0106a6b:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106a72:	e8 81 99 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106a77:	c7 04 24 f4 aa 10 c0 	movl   $0xc010aaf4,(%esp)
c0106a7e:	e8 1e 98 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0106a83:	b8 00 50 00 00       	mov    $0x5000,%eax
c0106a88:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c0106a8b:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106a90:	83 f8 05             	cmp    $0x5,%eax
c0106a93:	74 24                	je     c0106ab9 <_fifo_check_swap+0x150>
c0106a95:	c7 44 24 0c 1a ab 10 	movl   $0xc010ab1a,0xc(%esp)
c0106a9c:	c0 
c0106a9d:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106aa4:	c0 
c0106aa5:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0106aac:	00 
c0106aad:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106ab4:	e8 3f 99 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106ab9:	c7 04 24 cc aa 10 c0 	movl   $0xc010aacc,(%esp)
c0106ac0:	e8 dc 97 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106ac5:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106aca:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0106acd:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106ad2:	83 f8 05             	cmp    $0x5,%eax
c0106ad5:	74 24                	je     c0106afb <_fifo_check_swap+0x192>
c0106ad7:	c7 44 24 0c 1a ab 10 	movl   $0xc010ab1a,0xc(%esp)
c0106ade:	c0 
c0106adf:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106ae6:	c0 
c0106ae7:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0106aee:	00 
c0106aef:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106af6:	e8 fd 98 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106afb:	c7 04 24 7c aa 10 c0 	movl   $0xc010aa7c,(%esp)
c0106b02:	e8 9a 97 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0106b07:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106b0c:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0106b0f:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106b14:	83 f8 06             	cmp    $0x6,%eax
c0106b17:	74 24                	je     c0106b3d <_fifo_check_swap+0x1d4>
c0106b19:	c7 44 24 0c 29 ab 10 	movl   $0xc010ab29,0xc(%esp)
c0106b20:	c0 
c0106b21:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106b28:	c0 
c0106b29:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
c0106b30:	00 
c0106b31:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106b38:	e8 bb 98 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0106b3d:	c7 04 24 cc aa 10 c0 	movl   $0xc010aacc,(%esp)
c0106b44:	e8 58 97 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0106b49:	b8 00 20 00 00       	mov    $0x2000,%eax
c0106b4e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c0106b51:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106b56:	83 f8 07             	cmp    $0x7,%eax
c0106b59:	74 24                	je     c0106b7f <_fifo_check_swap+0x216>
c0106b5b:	c7 44 24 0c 38 ab 10 	movl   $0xc010ab38,0xc(%esp)
c0106b62:	c0 
c0106b63:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106b6a:	c0 
c0106b6b:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c0106b72:	00 
c0106b73:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106b7a:	e8 79 98 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c0106b7f:	c7 04 24 44 aa 10 c0 	movl   $0xc010aa44,(%esp)
c0106b86:	e8 16 97 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c0106b8b:	b8 00 30 00 00       	mov    $0x3000,%eax
c0106b90:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c0106b93:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106b98:	83 f8 08             	cmp    $0x8,%eax
c0106b9b:	74 24                	je     c0106bc1 <_fifo_check_swap+0x258>
c0106b9d:	c7 44 24 0c 47 ab 10 	movl   $0xc010ab47,0xc(%esp)
c0106ba4:	c0 
c0106ba5:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106bac:	c0 
c0106bad:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106bb4:	00 
c0106bb5:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106bbc:	e8 37 98 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0106bc1:	c7 04 24 a4 aa 10 c0 	movl   $0xc010aaa4,(%esp)
c0106bc8:	e8 d4 96 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0106bcd:	b8 00 40 00 00       	mov    $0x4000,%eax
c0106bd2:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0106bd5:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106bda:	83 f8 09             	cmp    $0x9,%eax
c0106bdd:	74 24                	je     c0106c03 <_fifo_check_swap+0x29a>
c0106bdf:	c7 44 24 0c 56 ab 10 	movl   $0xc010ab56,0xc(%esp)
c0106be6:	c0 
c0106be7:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106bee:	c0 
c0106bef:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106bf6:	00 
c0106bf7:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106bfe:	e8 f5 97 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0106c03:	c7 04 24 f4 aa 10 c0 	movl   $0xc010aaf4,(%esp)
c0106c0a:	e8 92 96 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0106c0f:	b8 00 50 00 00       	mov    $0x5000,%eax
c0106c14:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c0106c17:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106c1c:	83 f8 0a             	cmp    $0xa,%eax
c0106c1f:	74 24                	je     c0106c45 <_fifo_check_swap+0x2dc>
c0106c21:	c7 44 24 0c 65 ab 10 	movl   $0xc010ab65,0xc(%esp)
c0106c28:	c0 
c0106c29:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106c30:	c0 
c0106c31:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
c0106c38:	00 
c0106c39:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106c40:	e8 b3 97 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0106c45:	c7 04 24 7c aa 10 c0 	movl   $0xc010aa7c,(%esp)
c0106c4c:	e8 50 96 ff ff       	call   c01002a1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c0106c51:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106c56:	0f b6 00             	movzbl (%eax),%eax
c0106c59:	3c 0a                	cmp    $0xa,%al
c0106c5b:	74 24                	je     c0106c81 <_fifo_check_swap+0x318>
c0106c5d:	c7 44 24 0c 78 ab 10 	movl   $0xc010ab78,0xc(%esp)
c0106c64:	c0 
c0106c65:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106c6c:	c0 
c0106c6d:	c7 44 24 04 75 00 00 	movl   $0x75,0x4(%esp)
c0106c74:	00 
c0106c75:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106c7c:	e8 77 97 ff ff       	call   c01003f8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c0106c81:	b8 00 10 00 00       	mov    $0x1000,%eax
c0106c86:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c0106c89:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0106c8e:	83 f8 0b             	cmp    $0xb,%eax
c0106c91:	74 24                	je     c0106cb7 <_fifo_check_swap+0x34e>
c0106c93:	c7 44 24 0c 99 ab 10 	movl   $0xc010ab99,0xc(%esp)
c0106c9a:	c0 
c0106c9b:	c7 44 24 08 ee a9 10 	movl   $0xc010a9ee,0x8(%esp)
c0106ca2:	c0 
c0106ca3:	c7 44 24 04 77 00 00 	movl   $0x77,0x4(%esp)
c0106caa:	00 
c0106cab:	c7 04 24 03 aa 10 c0 	movl   $0xc010aa03,(%esp)
c0106cb2:	e8 41 97 ff ff       	call   c01003f8 <__panic>
    return 0;
c0106cb7:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106cbc:	c9                   	leave  
c0106cbd:	c3                   	ret    

c0106cbe <_fifo_init>:


static int
_fifo_init(void)
{
c0106cbe:	55                   	push   %ebp
c0106cbf:	89 e5                	mov    %esp,%ebp
    return 0;
c0106cc1:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106cc6:	5d                   	pop    %ebp
c0106cc7:	c3                   	ret    

c0106cc8 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c0106cc8:	55                   	push   %ebp
c0106cc9:	89 e5                	mov    %esp,%ebp
    return 0;
c0106ccb:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0106cd0:	5d                   	pop    %ebp
c0106cd1:	c3                   	ret    

c0106cd2 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
c0106cd2:	55                   	push   %ebp
c0106cd3:	89 e5                	mov    %esp,%ebp
c0106cd5:	b8 00 00 00 00       	mov    $0x0,%eax
c0106cda:	5d                   	pop    %ebp
c0106cdb:	c3                   	ret    

c0106cdc <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0106cdc:	55                   	push   %ebp
c0106cdd:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0106cdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0106ce2:	8b 15 28 50 12 c0    	mov    0xc0125028,%edx
c0106ce8:	29 d0                	sub    %edx,%eax
c0106cea:	c1 f8 05             	sar    $0x5,%eax
}
c0106ced:	5d                   	pop    %ebp
c0106cee:	c3                   	ret    

c0106cef <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0106cef:	55                   	push   %ebp
c0106cf0:	89 e5                	mov    %esp,%ebp
c0106cf2:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0106cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0106cf8:	89 04 24             	mov    %eax,(%esp)
c0106cfb:	e8 dc ff ff ff       	call   c0106cdc <page2ppn>
c0106d00:	c1 e0 0c             	shl    $0xc,%eax
}
c0106d03:	c9                   	leave  
c0106d04:	c3                   	ret    

c0106d05 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0106d05:	55                   	push   %ebp
c0106d06:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0106d08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d0b:	8b 00                	mov    (%eax),%eax
}
c0106d0d:	5d                   	pop    %ebp
c0106d0e:	c3                   	ret    

c0106d0f <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0106d0f:	55                   	push   %ebp
c0106d10:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0106d12:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d15:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106d18:	89 10                	mov    %edx,(%eax)
}
c0106d1a:	90                   	nop
c0106d1b:	5d                   	pop    %ebp
c0106d1c:	c3                   	ret    

c0106d1d <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0106d1d:	55                   	push   %ebp
c0106d1e:	89 e5                	mov    %esp,%ebp
c0106d20:	83 ec 10             	sub    $0x10,%esp
c0106d23:	c7 45 fc 0c 51 12 c0 	movl   $0xc012510c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0106d2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d2d:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0106d30:	89 50 04             	mov    %edx,0x4(%eax)
c0106d33:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d36:	8b 50 04             	mov    0x4(%eax),%edx
c0106d39:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0106d3c:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c0106d3e:	c7 05 14 51 12 c0 00 	movl   $0x0,0xc0125114
c0106d45:	00 00 00 
}
c0106d48:	90                   	nop
c0106d49:	c9                   	leave  
c0106d4a:	c3                   	ret    

c0106d4b <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0106d4b:	55                   	push   %ebp
c0106d4c:	89 e5                	mov    %esp,%ebp
c0106d4e:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c0106d51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106d55:	75 24                	jne    c0106d7b <default_init_memmap+0x30>
c0106d57:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c0106d5e:	c0 
c0106d5f:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0106d66:	c0 
c0106d67:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c0106d6e:	00 
c0106d6f:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0106d76:	e8 7d 96 ff ff       	call   c01003f8 <__panic>
    struct Page *p = base;
c0106d7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0106d7e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0106d81:	eb 7d                	jmp    c0106e00 <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0106d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106d86:	83 c0 04             	add    $0x4,%eax
c0106d89:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c0106d90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0106d93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106d96:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106d99:	0f a3 10             	bt     %edx,(%eax)
c0106d9c:	19 c0                	sbb    %eax,%eax
c0106d9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c0106da1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c0106da5:	0f 95 c0             	setne  %al
c0106da8:	0f b6 c0             	movzbl %al,%eax
c0106dab:	85 c0                	test   %eax,%eax
c0106dad:	75 24                	jne    c0106dd3 <default_init_memmap+0x88>
c0106daf:	c7 44 24 0c ed ab 10 	movl   $0xc010abed,0xc(%esp)
c0106db6:	c0 
c0106db7:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0106dbe:	c0 
c0106dbf:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c0106dc6:	00 
c0106dc7:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0106dce:	e8 25 96 ff ff       	call   c01003f8 <__panic>
        p->flags = p->property = 0;
c0106dd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106dd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0106ddd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106de0:	8b 50 08             	mov    0x8(%eax),%edx
c0106de3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106de6:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0106de9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0106df0:	00 
c0106df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106df4:	89 04 24             	mov    %eax,(%esp)
c0106df7:	e8 13 ff ff ff       	call   c0106d0f <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0106dfc:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c0106e00:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e03:	c1 e0 05             	shl    $0x5,%eax
c0106e06:	89 c2                	mov    %eax,%edx
c0106e08:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e0b:	01 d0                	add    %edx,%eax
c0106e0d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0106e10:	0f 85 6d ff ff ff    	jne    c0106d83 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0106e16:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e19:	8b 55 0c             	mov    0xc(%ebp),%edx
c0106e1c:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0106e1f:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e22:	83 c0 04             	add    $0x4,%eax
c0106e25:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0106e2c:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0106e2f:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106e32:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106e35:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c0106e38:	8b 15 14 51 12 c0    	mov    0xc0125114,%edx
c0106e3e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106e41:	01 d0                	add    %edx,%eax
c0106e43:	a3 14 51 12 c0       	mov    %eax,0xc0125114
    list_add_before(&free_list, &(base->page_link));
c0106e48:	8b 45 08             	mov    0x8(%ebp),%eax
c0106e4b:	83 c0 0c             	add    $0xc,%eax
c0106e4e:	c7 45 f0 0c 51 12 c0 	movl   $0xc012510c,-0x10(%ebp)
c0106e55:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0106e58:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e5b:	8b 00                	mov    (%eax),%eax
c0106e5d:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106e60:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0106e63:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0106e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106e69:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106e6c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106e6f:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106e72:	89 10                	mov    %edx,(%eax)
c0106e74:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0106e77:	8b 10                	mov    (%eax),%edx
c0106e79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106e7c:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106e7f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106e82:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106e85:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106e88:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106e8b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0106e8e:	89 10                	mov    %edx,(%eax)
}
c0106e90:	90                   	nop
c0106e91:	c9                   	leave  
c0106e92:	c3                   	ret    

c0106e93 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c0106e93:	55                   	push   %ebp
c0106e94:	89 e5                	mov    %esp,%ebp
c0106e96:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c0106e99:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106e9d:	75 24                	jne    c0106ec3 <default_alloc_pages+0x30>
c0106e9f:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c0106ea6:	c0 
c0106ea7:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0106eae:	c0 
c0106eaf:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c0106eb6:	00 
c0106eb7:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0106ebe:	e8 35 95 ff ff       	call   c01003f8 <__panic>
    if (n > nr_free) {
c0106ec3:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0106ec8:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106ecb:	73 0a                	jae    c0106ed7 <default_alloc_pages+0x44>
        return NULL;
c0106ecd:	b8 00 00 00 00       	mov    $0x0,%eax
c0106ed2:	e9 36 01 00 00       	jmp    c010700d <default_alloc_pages+0x17a>
    }
    struct Page *page = NULL;
c0106ed7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0106ede:	c7 45 f0 0c 51 12 c0 	movl   $0xc012510c,-0x10(%ebp)
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0106ee5:	eb 1c                	jmp    c0106f03 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c0106ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106eea:	83 e8 0c             	sub    $0xc,%eax
c0106eed:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0106ef0:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106ef3:	8b 40 08             	mov    0x8(%eax),%eax
c0106ef6:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106ef9:	72 08                	jb     c0106f03 <default_alloc_pages+0x70>
            page = p;
c0106efb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106efe:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0106f01:	eb 18                	jmp    c0106f1b <default_alloc_pages+0x88>
c0106f03:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106f06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0106f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0106f0c:	8b 40 04             	mov    0x4(%eax),%eax
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)
    while ((le = list_next(le)) != &free_list) {
c0106f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106f12:	81 7d f0 0c 51 12 c0 	cmpl   $0xc012510c,-0x10(%ebp)
c0106f19:	75 cc                	jne    c0106ee7 <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0106f1b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0106f1f:	0f 84 e5 00 00 00    	je     c010700a <default_alloc_pages+0x177>
        if (page->property > n) {
c0106f25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f28:	8b 40 08             	mov    0x8(%eax),%eax
c0106f2b:	3b 45 08             	cmp    0x8(%ebp),%eax
c0106f2e:	0f 86 85 00 00 00    	jbe    c0106fb9 <default_alloc_pages+0x126>
            struct Page *p = page + n;
c0106f34:	8b 45 08             	mov    0x8(%ebp),%eax
c0106f37:	c1 e0 05             	shl    $0x5,%eax
c0106f3a:	89 c2                	mov    %eax,%edx
c0106f3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f3f:	01 d0                	add    %edx,%eax
c0106f41:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0106f44:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106f47:	8b 40 08             	mov    0x8(%eax),%eax
c0106f4a:	2b 45 08             	sub    0x8(%ebp),%eax
c0106f4d:	89 c2                	mov    %eax,%edx
c0106f4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f52:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0106f55:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f58:	83 c0 04             	add    $0x4,%eax
c0106f5b:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c0106f62:	89 45 c0             	mov    %eax,-0x40(%ebp)
c0106f65:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0106f68:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0106f6b:	0f ab 10             	bts    %edx,(%eax)
            list_add_after(&(page->page_link), &(p->page_link));
c0106f6e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106f71:	83 c0 0c             	add    $0xc,%eax
c0106f74:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106f77:	83 c2 0c             	add    $0xc,%edx
c0106f7a:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0106f7d:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0106f80:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106f83:	8b 40 04             	mov    0x4(%eax),%eax
c0106f86:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0106f89:	89 55 cc             	mov    %edx,-0x34(%ebp)
c0106f8c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0106f8f:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106f92:	89 45 c4             	mov    %eax,-0x3c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0106f95:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106f98:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0106f9b:	89 10                	mov    %edx,(%eax)
c0106f9d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0106fa0:	8b 10                	mov    (%eax),%edx
c0106fa2:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0106fa5:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0106fa8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106fab:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0106fae:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0106fb1:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0106fb4:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0106fb7:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0106fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106fbc:	83 c0 0c             	add    $0xc,%eax
c0106fbf:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0106fc2:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0106fc5:	8b 40 04             	mov    0x4(%eax),%eax
c0106fc8:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0106fcb:	8b 12                	mov    (%edx),%edx
c0106fcd:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0106fd0:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0106fd3:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0106fd6:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0106fd9:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0106fdc:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0106fdf:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0106fe2:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0106fe4:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0106fe9:	2b 45 08             	sub    0x8(%ebp),%eax
c0106fec:	a3 14 51 12 c0       	mov    %eax,0xc0125114
        ClearPageProperty(page);
c0106ff1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106ff4:	83 c0 04             	add    $0x4,%eax
c0106ff7:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0106ffe:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107001:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107004:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0107007:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c010700a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010700d:	c9                   	leave  
c010700e:	c3                   	ret    

c010700f <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c010700f:	55                   	push   %ebp
c0107010:	89 e5                	mov    %esp,%ebp
c0107012:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0107018:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c010701c:	75 24                	jne    c0107042 <default_free_pages+0x33>
c010701e:	c7 44 24 0c bc ab 10 	movl   $0xc010abbc,0xc(%esp)
c0107025:	c0 
c0107026:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010702d:	c0 
c010702e:	c7 44 24 04 9a 00 00 	movl   $0x9a,0x4(%esp)
c0107035:	00 
c0107036:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c010703d:	e8 b6 93 ff ff       	call   c01003f8 <__panic>
    struct Page *p = base;
c0107042:	8b 45 08             	mov    0x8(%ebp),%eax
c0107045:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0107048:	e9 9d 00 00 00       	jmp    c01070ea <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c010704d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107050:	83 c0 04             	add    $0x4,%eax
c0107053:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c010705a:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010705d:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0107060:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0107063:	0f a3 10             	bt     %edx,(%eax)
c0107066:	19 c0                	sbb    %eax,%eax
c0107068:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010706b:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c010706f:	0f 95 c0             	setne  %al
c0107072:	0f b6 c0             	movzbl %al,%eax
c0107075:	85 c0                	test   %eax,%eax
c0107077:	75 2c                	jne    c01070a5 <default_free_pages+0x96>
c0107079:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010707c:	83 c0 04             	add    $0x4,%eax
c010707f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0107086:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107089:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c010708c:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010708f:	0f a3 10             	bt     %edx,(%eax)
c0107092:	19 c0                	sbb    %eax,%eax
c0107094:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0107097:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c010709b:	0f 95 c0             	setne  %al
c010709e:	0f b6 c0             	movzbl %al,%eax
c01070a1:	85 c0                	test   %eax,%eax
c01070a3:	74 24                	je     c01070c9 <default_free_pages+0xba>
c01070a5:	c7 44 24 0c 00 ac 10 	movl   $0xc010ac00,0xc(%esp)
c01070ac:	c0 
c01070ad:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01070b4:	c0 
c01070b5:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
c01070bc:	00 
c01070bd:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01070c4:	e8 2f 93 ff ff       	call   c01003f8 <__panic>
        p->flags = 0;
c01070c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070cc:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c01070d3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01070da:	00 
c01070db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01070de:	89 04 24             	mov    %eax,(%esp)
c01070e1:	e8 29 fc ff ff       	call   c0106d0f <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c01070e6:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
c01070ea:	8b 45 0c             	mov    0xc(%ebp),%eax
c01070ed:	c1 e0 05             	shl    $0x5,%eax
c01070f0:	89 c2                	mov    %eax,%edx
c01070f2:	8b 45 08             	mov    0x8(%ebp),%eax
c01070f5:	01 d0                	add    %edx,%eax
c01070f7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01070fa:	0f 85 4d ff ff ff    	jne    c010704d <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0107100:	8b 45 08             	mov    0x8(%ebp),%eax
c0107103:	8b 55 0c             	mov    0xc(%ebp),%edx
c0107106:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0107109:	8b 45 08             	mov    0x8(%ebp),%eax
c010710c:	83 c0 04             	add    $0x4,%eax
c010710f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0107116:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107119:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010711c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010711f:	0f ab 10             	bts    %edx,(%eax)
c0107122:	c7 45 e8 0c 51 12 c0 	movl   $0xc012510c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107129:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010712c:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c010712f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0107132:	e9 fa 00 00 00       	jmp    c0107231 <default_free_pages+0x222>
        p = le2page(le, page_link);
c0107137:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010713a:	83 e8 0c             	sub    $0xc,%eax
c010713d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0107140:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107143:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107146:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107149:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c010714c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c010714f:	8b 45 08             	mov    0x8(%ebp),%eax
c0107152:	8b 40 08             	mov    0x8(%eax),%eax
c0107155:	c1 e0 05             	shl    $0x5,%eax
c0107158:	89 c2                	mov    %eax,%edx
c010715a:	8b 45 08             	mov    0x8(%ebp),%eax
c010715d:	01 d0                	add    %edx,%eax
c010715f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107162:	75 5a                	jne    c01071be <default_free_pages+0x1af>
            base->property += p->property;
c0107164:	8b 45 08             	mov    0x8(%ebp),%eax
c0107167:	8b 50 08             	mov    0x8(%eax),%edx
c010716a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010716d:	8b 40 08             	mov    0x8(%eax),%eax
c0107170:	01 c2                	add    %eax,%edx
c0107172:	8b 45 08             	mov    0x8(%ebp),%eax
c0107175:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0107178:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010717b:	83 c0 04             	add    $0x4,%eax
c010717e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0107185:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0107188:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010718b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010718e:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0107191:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107194:	83 c0 0c             	add    $0xc,%eax
c0107197:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010719a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010719d:	8b 40 04             	mov    0x4(%eax),%eax
c01071a0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01071a3:	8b 12                	mov    (%edx),%edx
c01071a5:	89 55 a8             	mov    %edx,-0x58(%ebp)
c01071a8:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c01071ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01071ae:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01071b1:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01071b4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01071b7:	8b 55 a8             	mov    -0x58(%ebp),%edx
c01071ba:	89 10                	mov    %edx,(%eax)
c01071bc:	eb 73                	jmp    c0107231 <default_free_pages+0x222>
        }
        else if (p + p->property == base) {
c01071be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071c1:	8b 40 08             	mov    0x8(%eax),%eax
c01071c4:	c1 e0 05             	shl    $0x5,%eax
c01071c7:	89 c2                	mov    %eax,%edx
c01071c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071cc:	01 d0                	add    %edx,%eax
c01071ce:	3b 45 08             	cmp    0x8(%ebp),%eax
c01071d1:	75 5e                	jne    c0107231 <default_free_pages+0x222>
            p->property += base->property;
c01071d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071d6:	8b 50 08             	mov    0x8(%eax),%edx
c01071d9:	8b 45 08             	mov    0x8(%ebp),%eax
c01071dc:	8b 40 08             	mov    0x8(%eax),%eax
c01071df:	01 c2                	add    %eax,%edx
c01071e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01071e4:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c01071e7:	8b 45 08             	mov    0x8(%ebp),%eax
c01071ea:	83 c0 04             	add    $0x4,%eax
c01071ed:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c01071f4:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01071f7:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01071fa:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01071fd:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0107200:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107203:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0107206:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107209:	83 c0 0c             	add    $0xc,%eax
c010720c:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010720f:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107212:	8b 40 04             	mov    0x4(%eax),%eax
c0107215:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107218:	8b 12                	mov    (%edx),%edx
c010721a:	89 55 9c             	mov    %edx,-0x64(%ebp)
c010721d:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0107220:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107223:	8b 55 98             	mov    -0x68(%ebp),%edx
c0107226:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0107229:	8b 45 98             	mov    -0x68(%ebp),%eax
c010722c:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010722f:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0107231:	81 7d f0 0c 51 12 c0 	cmpl   $0xc012510c,-0x10(%ebp)
c0107238:	0f 85 f9 fe ff ff    	jne    c0107137 <default_free_pages+0x128>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c010723e:	8b 15 14 51 12 c0    	mov    0xc0125114,%edx
c0107244:	8b 45 0c             	mov    0xc(%ebp),%eax
c0107247:	01 d0                	add    %edx,%eax
c0107249:	a3 14 51 12 c0       	mov    %eax,0xc0125114
c010724e:	c7 45 d0 0c 51 12 c0 	movl   $0xc012510c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107255:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107258:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c010725b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c010725e:	eb 66                	jmp    c01072c6 <default_free_pages+0x2b7>
        p = le2page(le, page_link);
c0107260:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107263:	83 e8 0c             	sub    $0xc,%eax
c0107266:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0107269:	8b 45 08             	mov    0x8(%ebp),%eax
c010726c:	8b 40 08             	mov    0x8(%eax),%eax
c010726f:	c1 e0 05             	shl    $0x5,%eax
c0107272:	89 c2                	mov    %eax,%edx
c0107274:	8b 45 08             	mov    0x8(%ebp),%eax
c0107277:	01 d0                	add    %edx,%eax
c0107279:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c010727c:	77 39                	ja     c01072b7 <default_free_pages+0x2a8>
            assert(base + base->property != p);
c010727e:	8b 45 08             	mov    0x8(%ebp),%eax
c0107281:	8b 40 08             	mov    0x8(%eax),%eax
c0107284:	c1 e0 05             	shl    $0x5,%eax
c0107287:	89 c2                	mov    %eax,%edx
c0107289:	8b 45 08             	mov    0x8(%ebp),%eax
c010728c:	01 d0                	add    %edx,%eax
c010728e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107291:	75 3e                	jne    c01072d1 <default_free_pages+0x2c2>
c0107293:	c7 44 24 0c 25 ac 10 	movl   $0xc010ac25,0xc(%esp)
c010729a:	c0 
c010729b:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01072a2:	c0 
c01072a3:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
c01072aa:	00 
c01072ab:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01072b2:	e8 41 91 ff ff       	call   c01003f8 <__panic>
c01072b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072ba:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01072bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
c01072c0:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01072c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c01072c6:	81 7d f0 0c 51 12 c0 	cmpl   $0xc012510c,-0x10(%ebp)
c01072cd:	75 91                	jne    c0107260 <default_free_pages+0x251>
c01072cf:	eb 01                	jmp    c01072d2 <default_free_pages+0x2c3>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c01072d1:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c01072d2:	8b 45 08             	mov    0x8(%ebp),%eax
c01072d5:	8d 50 0c             	lea    0xc(%eax),%edx
c01072d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01072db:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c01072de:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c01072e1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01072e4:	8b 00                	mov    (%eax),%eax
c01072e6:	8b 55 90             	mov    -0x70(%ebp),%edx
c01072e9:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01072ec:	89 45 88             	mov    %eax,-0x78(%ebp)
c01072ef:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01072f2:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01072f5:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01072f8:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01072fb:	89 10                	mov    %edx,(%eax)
c01072fd:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0107300:	8b 10                	mov    (%eax),%edx
c0107302:	8b 45 88             	mov    -0x78(%ebp),%eax
c0107305:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107308:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010730b:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010730e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107311:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107314:	8b 55 88             	mov    -0x78(%ebp),%edx
c0107317:	89 10                	mov    %edx,(%eax)
}
c0107319:	90                   	nop
c010731a:	c9                   	leave  
c010731b:	c3                   	ret    

c010731c <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c010731c:	55                   	push   %ebp
c010731d:	89 e5                	mov    %esp,%ebp
    return nr_free;
c010731f:	a1 14 51 12 c0       	mov    0xc0125114,%eax
}
c0107324:	5d                   	pop    %ebp
c0107325:	c3                   	ret    

c0107326 <basic_check>:

static void
basic_check(void) {
c0107326:	55                   	push   %ebp
c0107327:	89 e5                	mov    %esp,%ebp
c0107329:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c010732c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107333:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107336:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107339:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010733c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c010733f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107346:	e8 e3 c1 ff ff       	call   c010352e <alloc_pages>
c010734b:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010734e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107352:	75 24                	jne    c0107378 <basic_check+0x52>
c0107354:	c7 44 24 0c 40 ac 10 	movl   $0xc010ac40,0xc(%esp)
c010735b:	c0 
c010735c:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107363:	c0 
c0107364:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c010736b:	00 
c010736c:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107373:	e8 80 90 ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0107378:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010737f:	e8 aa c1 ff ff       	call   c010352e <alloc_pages>
c0107384:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107387:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010738b:	75 24                	jne    c01073b1 <basic_check+0x8b>
c010738d:	c7 44 24 0c 5c ac 10 	movl   $0xc010ac5c,0xc(%esp)
c0107394:	c0 
c0107395:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010739c:	c0 
c010739d:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
c01073a4:	00 
c01073a5:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01073ac:	e8 47 90 ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01073b1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01073b8:	e8 71 c1 ff ff       	call   c010352e <alloc_pages>
c01073bd:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01073c0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01073c4:	75 24                	jne    c01073ea <basic_check+0xc4>
c01073c6:	c7 44 24 0c 78 ac 10 	movl   $0xc010ac78,0xc(%esp)
c01073cd:	c0 
c01073ce:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01073d5:	c0 
c01073d6:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c01073dd:	00 
c01073de:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01073e5:	e8 0e 90 ff ff       	call   c01003f8 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01073ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073ed:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01073f0:	74 10                	je     c0107402 <basic_check+0xdc>
c01073f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01073f5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01073f8:	74 08                	je     c0107402 <basic_check+0xdc>
c01073fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01073fd:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0107400:	75 24                	jne    c0107426 <basic_check+0x100>
c0107402:	c7 44 24 0c 94 ac 10 	movl   $0xc010ac94,0xc(%esp)
c0107409:	c0 
c010740a:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107411:	c0 
c0107412:	c7 44 24 04 ce 00 00 	movl   $0xce,0x4(%esp)
c0107419:	00 
c010741a:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107421:	e8 d2 8f ff ff       	call   c01003f8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0107426:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107429:	89 04 24             	mov    %eax,(%esp)
c010742c:	e8 d4 f8 ff ff       	call   c0106d05 <page_ref>
c0107431:	85 c0                	test   %eax,%eax
c0107433:	75 1e                	jne    c0107453 <basic_check+0x12d>
c0107435:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107438:	89 04 24             	mov    %eax,(%esp)
c010743b:	e8 c5 f8 ff ff       	call   c0106d05 <page_ref>
c0107440:	85 c0                	test   %eax,%eax
c0107442:	75 0f                	jne    c0107453 <basic_check+0x12d>
c0107444:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107447:	89 04 24             	mov    %eax,(%esp)
c010744a:	e8 b6 f8 ff ff       	call   c0106d05 <page_ref>
c010744f:	85 c0                	test   %eax,%eax
c0107451:	74 24                	je     c0107477 <basic_check+0x151>
c0107453:	c7 44 24 0c b8 ac 10 	movl   $0xc010acb8,0xc(%esp)
c010745a:	c0 
c010745b:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107462:	c0 
c0107463:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c010746a:	00 
c010746b:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107472:	e8 81 8f ff ff       	call   c01003f8 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0107477:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010747a:	89 04 24             	mov    %eax,(%esp)
c010747d:	e8 6d f8 ff ff       	call   c0106cef <page2pa>
c0107482:	8b 15 80 4f 12 c0    	mov    0xc0124f80,%edx
c0107488:	c1 e2 0c             	shl    $0xc,%edx
c010748b:	39 d0                	cmp    %edx,%eax
c010748d:	72 24                	jb     c01074b3 <basic_check+0x18d>
c010748f:	c7 44 24 0c f4 ac 10 	movl   $0xc010acf4,0xc(%esp)
c0107496:	c0 
c0107497:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010749e:	c0 
c010749f:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c01074a6:	00 
c01074a7:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01074ae:	e8 45 8f ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01074b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01074b6:	89 04 24             	mov    %eax,(%esp)
c01074b9:	e8 31 f8 ff ff       	call   c0106cef <page2pa>
c01074be:	8b 15 80 4f 12 c0    	mov    0xc0124f80,%edx
c01074c4:	c1 e2 0c             	shl    $0xc,%edx
c01074c7:	39 d0                	cmp    %edx,%eax
c01074c9:	72 24                	jb     c01074ef <basic_check+0x1c9>
c01074cb:	c7 44 24 0c 11 ad 10 	movl   $0xc010ad11,0xc(%esp)
c01074d2:	c0 
c01074d3:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01074da:	c0 
c01074db:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c01074e2:	00 
c01074e3:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01074ea:	e8 09 8f ff ff       	call   c01003f8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01074ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01074f2:	89 04 24             	mov    %eax,(%esp)
c01074f5:	e8 f5 f7 ff ff       	call   c0106cef <page2pa>
c01074fa:	8b 15 80 4f 12 c0    	mov    0xc0124f80,%edx
c0107500:	c1 e2 0c             	shl    $0xc,%edx
c0107503:	39 d0                	cmp    %edx,%eax
c0107505:	72 24                	jb     c010752b <basic_check+0x205>
c0107507:	c7 44 24 0c 2e ad 10 	movl   $0xc010ad2e,0xc(%esp)
c010750e:	c0 
c010750f:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107516:	c0 
c0107517:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
c010751e:	00 
c010751f:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107526:	e8 cd 8e ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c010752b:	a1 0c 51 12 c0       	mov    0xc012510c,%eax
c0107530:	8b 15 10 51 12 c0    	mov    0xc0125110,%edx
c0107536:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0107539:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010753c:	c7 45 e4 0c 51 12 c0 	movl   $0xc012510c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107543:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107546:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0107549:	89 50 04             	mov    %edx,0x4(%eax)
c010754c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010754f:	8b 50 04             	mov    0x4(%eax),%edx
c0107552:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107555:	89 10                	mov    %edx,(%eax)
c0107557:	c7 45 d8 0c 51 12 c0 	movl   $0xc012510c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c010755e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0107561:	8b 40 04             	mov    0x4(%eax),%eax
c0107564:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107567:	0f 94 c0             	sete   %al
c010756a:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c010756d:	85 c0                	test   %eax,%eax
c010756f:	75 24                	jne    c0107595 <basic_check+0x26f>
c0107571:	c7 44 24 0c 4b ad 10 	movl   $0xc010ad4b,0xc(%esp)
c0107578:	c0 
c0107579:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107580:	c0 
c0107581:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
c0107588:	00 
c0107589:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107590:	e8 63 8e ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c0107595:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c010759a:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c010759d:	c7 05 14 51 12 c0 00 	movl   $0x0,0xc0125114
c01075a4:	00 00 00 

    assert(alloc_page() == NULL);
c01075a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01075ae:	e8 7b bf ff ff       	call   c010352e <alloc_pages>
c01075b3:	85 c0                	test   %eax,%eax
c01075b5:	74 24                	je     c01075db <basic_check+0x2b5>
c01075b7:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c01075be:	c0 
c01075bf:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01075c6:	c0 
c01075c7:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c01075ce:	00 
c01075cf:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01075d6:	e8 1d 8e ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c01075db:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01075e2:	00 
c01075e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01075e6:	89 04 24             	mov    %eax,(%esp)
c01075e9:	e8 ab bf ff ff       	call   c0103599 <free_pages>
    free_page(p1);
c01075ee:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01075f5:	00 
c01075f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01075f9:	89 04 24             	mov    %eax,(%esp)
c01075fc:	e8 98 bf ff ff       	call   c0103599 <free_pages>
    free_page(p2);
c0107601:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107608:	00 
c0107609:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010760c:	89 04 24             	mov    %eax,(%esp)
c010760f:	e8 85 bf ff ff       	call   c0103599 <free_pages>
    assert(nr_free == 3);
c0107614:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0107619:	83 f8 03             	cmp    $0x3,%eax
c010761c:	74 24                	je     c0107642 <basic_check+0x31c>
c010761e:	c7 44 24 0c 77 ad 10 	movl   $0xc010ad77,0xc(%esp)
c0107625:	c0 
c0107626:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010762d:	c0 
c010762e:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c0107635:	00 
c0107636:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c010763d:	e8 b6 8d ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0107642:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107649:	e8 e0 be ff ff       	call   c010352e <alloc_pages>
c010764e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107651:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0107655:	75 24                	jne    c010767b <basic_check+0x355>
c0107657:	c7 44 24 0c 40 ac 10 	movl   $0xc010ac40,0xc(%esp)
c010765e:	c0 
c010765f:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107666:	c0 
c0107667:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c010766e:	00 
c010766f:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107676:	e8 7d 8d ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010767b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107682:	e8 a7 be ff ff       	call   c010352e <alloc_pages>
c0107687:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010768a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010768e:	75 24                	jne    c01076b4 <basic_check+0x38e>
c0107690:	c7 44 24 0c 5c ac 10 	movl   $0xc010ac5c,0xc(%esp)
c0107697:	c0 
c0107698:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010769f:	c0 
c01076a0:	c7 44 24 04 e4 00 00 	movl   $0xe4,0x4(%esp)
c01076a7:	00 
c01076a8:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01076af:	e8 44 8d ff ff       	call   c01003f8 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01076b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01076bb:	e8 6e be ff ff       	call   c010352e <alloc_pages>
c01076c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01076c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01076c7:	75 24                	jne    c01076ed <basic_check+0x3c7>
c01076c9:	c7 44 24 0c 78 ac 10 	movl   $0xc010ac78,0xc(%esp)
c01076d0:	c0 
c01076d1:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01076d8:	c0 
c01076d9:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c01076e0:	00 
c01076e1:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01076e8:	e8 0b 8d ff ff       	call   c01003f8 <__panic>

    assert(alloc_page() == NULL);
c01076ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01076f4:	e8 35 be ff ff       	call   c010352e <alloc_pages>
c01076f9:	85 c0                	test   %eax,%eax
c01076fb:	74 24                	je     c0107721 <basic_check+0x3fb>
c01076fd:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c0107704:	c0 
c0107705:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010770c:	c0 
c010770d:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
c0107714:	00 
c0107715:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c010771c:	e8 d7 8c ff ff       	call   c01003f8 <__panic>

    free_page(p0);
c0107721:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107728:	00 
c0107729:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010772c:	89 04 24             	mov    %eax,(%esp)
c010772f:	e8 65 be ff ff       	call   c0103599 <free_pages>
c0107734:	c7 45 e8 0c 51 12 c0 	movl   $0xc012510c,-0x18(%ebp)
c010773b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010773e:	8b 40 04             	mov    0x4(%eax),%eax
c0107741:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0107744:	0f 94 c0             	sete   %al
c0107747:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c010774a:	85 c0                	test   %eax,%eax
c010774c:	74 24                	je     c0107772 <basic_check+0x44c>
c010774e:	c7 44 24 0c 84 ad 10 	movl   $0xc010ad84,0xc(%esp)
c0107755:	c0 
c0107756:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c010775d:	c0 
c010775e:	c7 44 24 04 ea 00 00 	movl   $0xea,0x4(%esp)
c0107765:	00 
c0107766:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c010776d:	e8 86 8c ff ff       	call   c01003f8 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0107772:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107779:	e8 b0 bd ff ff       	call   c010352e <alloc_pages>
c010777e:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107781:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107784:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0107787:	74 24                	je     c01077ad <basic_check+0x487>
c0107789:	c7 44 24 0c 9c ad 10 	movl   $0xc010ad9c,0xc(%esp)
c0107790:	c0 
c0107791:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107798:	c0 
c0107799:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
c01077a0:	00 
c01077a1:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01077a8:	e8 4b 8c ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c01077ad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01077b4:	e8 75 bd ff ff       	call   c010352e <alloc_pages>
c01077b9:	85 c0                	test   %eax,%eax
c01077bb:	74 24                	je     c01077e1 <basic_check+0x4bb>
c01077bd:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c01077c4:	c0 
c01077c5:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01077cc:	c0 
c01077cd:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c01077d4:	00 
c01077d5:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01077dc:	e8 17 8c ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c01077e1:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c01077e6:	85 c0                	test   %eax,%eax
c01077e8:	74 24                	je     c010780e <basic_check+0x4e8>
c01077ea:	c7 44 24 0c b5 ad 10 	movl   $0xc010adb5,0xc(%esp)
c01077f1:	c0 
c01077f2:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01077f9:	c0 
c01077fa:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
c0107801:	00 
c0107802:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107809:	e8 ea 8b ff ff       	call   c01003f8 <__panic>
    free_list = free_list_store;
c010780e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107811:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107814:	a3 0c 51 12 c0       	mov    %eax,0xc012510c
c0107819:	89 15 10 51 12 c0    	mov    %edx,0xc0125110
    nr_free = nr_free_store;
c010781f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107822:	a3 14 51 12 c0       	mov    %eax,0xc0125114

    free_page(p);
c0107827:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010782e:	00 
c010782f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107832:	89 04 24             	mov    %eax,(%esp)
c0107835:	e8 5f bd ff ff       	call   c0103599 <free_pages>
    free_page(p1);
c010783a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107841:	00 
c0107842:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107845:	89 04 24             	mov    %eax,(%esp)
c0107848:	e8 4c bd ff ff       	call   c0103599 <free_pages>
    free_page(p2);
c010784d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107854:	00 
c0107855:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107858:	89 04 24             	mov    %eax,(%esp)
c010785b:	e8 39 bd ff ff       	call   c0103599 <free_pages>
}
c0107860:	90                   	nop
c0107861:	c9                   	leave  
c0107862:	c3                   	ret    

c0107863 <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c0107863:	55                   	push   %ebp
c0107864:	89 e5                	mov    %esp,%ebp
c0107866:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c010786c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0107873:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c010787a:	c7 45 ec 0c 51 12 c0 	movl   $0xc012510c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107881:	eb 6a                	jmp    c01078ed <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c0107883:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107886:	83 e8 0c             	sub    $0xc,%eax
c0107889:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c010788c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010788f:	83 c0 04             	add    $0x4,%eax
c0107892:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0107899:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010789c:	8b 45 ac             	mov    -0x54(%ebp),%eax
c010789f:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01078a2:	0f a3 10             	bt     %edx,(%eax)
c01078a5:	19 c0                	sbb    %eax,%eax
c01078a7:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c01078aa:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c01078ae:	0f 95 c0             	setne  %al
c01078b1:	0f b6 c0             	movzbl %al,%eax
c01078b4:	85 c0                	test   %eax,%eax
c01078b6:	75 24                	jne    c01078dc <default_check+0x79>
c01078b8:	c7 44 24 0c c2 ad 10 	movl   $0xc010adc2,0xc(%esp)
c01078bf:	c0 
c01078c0:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01078c7:	c0 
c01078c8:	c7 44 24 04 01 01 00 	movl   $0x101,0x4(%esp)
c01078cf:	00 
c01078d0:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01078d7:	e8 1c 8b ff ff       	call   c01003f8 <__panic>
        count ++, total += p->property;
c01078dc:	ff 45 f4             	incl   -0xc(%ebp)
c01078df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01078e2:	8b 50 08             	mov    0x8(%eax),%edx
c01078e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01078e8:	01 d0                	add    %edx,%eax
c01078ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01078ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01078f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01078f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01078f6:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01078f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01078fc:	81 7d ec 0c 51 12 c0 	cmpl   $0xc012510c,-0x14(%ebp)
c0107903:	0f 85 7a ff ff ff    	jne    c0107883 <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0107909:	e8 be bc ff ff       	call   c01035cc <nr_free_pages>
c010790e:	89 c2                	mov    %eax,%edx
c0107910:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107913:	39 c2                	cmp    %eax,%edx
c0107915:	74 24                	je     c010793b <default_check+0xd8>
c0107917:	c7 44 24 0c d2 ad 10 	movl   $0xc010add2,0xc(%esp)
c010791e:	c0 
c010791f:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107926:	c0 
c0107927:	c7 44 24 04 04 01 00 	movl   $0x104,0x4(%esp)
c010792e:	00 
c010792f:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107936:	e8 bd 8a ff ff       	call   c01003f8 <__panic>

    basic_check();
c010793b:	e8 e6 f9 ff ff       	call   c0107326 <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0107940:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107947:	e8 e2 bb ff ff       	call   c010352e <alloc_pages>
c010794c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c010794f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107953:	75 24                	jne    c0107979 <default_check+0x116>
c0107955:	c7 44 24 0c eb ad 10 	movl   $0xc010adeb,0xc(%esp)
c010795c:	c0 
c010795d:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107964:	c0 
c0107965:	c7 44 24 04 09 01 00 	movl   $0x109,0x4(%esp)
c010796c:	00 
c010796d:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107974:	e8 7f 8a ff ff       	call   c01003f8 <__panic>
    assert(!PageProperty(p0));
c0107979:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010797c:	83 c0 04             	add    $0x4,%eax
c010797f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c0107986:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107989:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010798c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010798f:	0f a3 10             	bt     %edx,(%eax)
c0107992:	19 c0                	sbb    %eax,%eax
c0107994:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0107997:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c010799b:	0f 95 c0             	setne  %al
c010799e:	0f b6 c0             	movzbl %al,%eax
c01079a1:	85 c0                	test   %eax,%eax
c01079a3:	74 24                	je     c01079c9 <default_check+0x166>
c01079a5:	c7 44 24 0c f6 ad 10 	movl   $0xc010adf6,0xc(%esp)
c01079ac:	c0 
c01079ad:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c01079b4:	c0 
c01079b5:	c7 44 24 04 0a 01 00 	movl   $0x10a,0x4(%esp)
c01079bc:	00 
c01079bd:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c01079c4:	e8 2f 8a ff ff       	call   c01003f8 <__panic>

    list_entry_t free_list_store = free_list;
c01079c9:	a1 0c 51 12 c0       	mov    0xc012510c,%eax
c01079ce:	8b 15 10 51 12 c0    	mov    0xc0125110,%edx
c01079d4:	89 45 80             	mov    %eax,-0x80(%ebp)
c01079d7:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01079da:	c7 45 d0 0c 51 12 c0 	movl   $0xc012510c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c01079e1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079e4:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01079e7:	89 50 04             	mov    %edx,0x4(%eax)
c01079ea:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079ed:	8b 50 04             	mov    0x4(%eax),%edx
c01079f0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01079f3:	89 10                	mov    %edx,(%eax)
c01079f5:	c7 45 d8 0c 51 12 c0 	movl   $0xc012510c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c01079fc:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01079ff:	8b 40 04             	mov    0x4(%eax),%eax
c0107a02:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0107a05:	0f 94 c0             	sete   %al
c0107a08:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0107a0b:	85 c0                	test   %eax,%eax
c0107a0d:	75 24                	jne    c0107a33 <default_check+0x1d0>
c0107a0f:	c7 44 24 0c 4b ad 10 	movl   $0xc010ad4b,0xc(%esp)
c0107a16:	c0 
c0107a17:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107a1e:	c0 
c0107a1f:	c7 44 24 04 0e 01 00 	movl   $0x10e,0x4(%esp)
c0107a26:	00 
c0107a27:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107a2e:	e8 c5 89 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0107a33:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107a3a:	e8 ef ba ff ff       	call   c010352e <alloc_pages>
c0107a3f:	85 c0                	test   %eax,%eax
c0107a41:	74 24                	je     c0107a67 <default_check+0x204>
c0107a43:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c0107a4a:	c0 
c0107a4b:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107a52:	c0 
c0107a53:	c7 44 24 04 0f 01 00 	movl   $0x10f,0x4(%esp)
c0107a5a:	00 
c0107a5b:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107a62:	e8 91 89 ff ff       	call   c01003f8 <__panic>

    unsigned int nr_free_store = nr_free;
c0107a67:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0107a6c:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c0107a6f:	c7 05 14 51 12 c0 00 	movl   $0x0,0xc0125114
c0107a76:	00 00 00 

    free_pages(p0 + 2, 3);
c0107a79:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107a7c:	83 c0 40             	add    $0x40,%eax
c0107a7f:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0107a86:	00 
c0107a87:	89 04 24             	mov    %eax,(%esp)
c0107a8a:	e8 0a bb ff ff       	call   c0103599 <free_pages>
    assert(alloc_pages(4) == NULL);
c0107a8f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0107a96:	e8 93 ba ff ff       	call   c010352e <alloc_pages>
c0107a9b:	85 c0                	test   %eax,%eax
c0107a9d:	74 24                	je     c0107ac3 <default_check+0x260>
c0107a9f:	c7 44 24 0c 08 ae 10 	movl   $0xc010ae08,0xc(%esp)
c0107aa6:	c0 
c0107aa7:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107aae:	c0 
c0107aaf:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c0107ab6:	00 
c0107ab7:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107abe:	e8 35 89 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c0107ac3:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107ac6:	83 c0 40             	add    $0x40,%eax
c0107ac9:	83 c0 04             	add    $0x4,%eax
c0107acc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0107ad3:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107ad6:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0107ad9:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107adc:	0f a3 10             	bt     %edx,(%eax)
c0107adf:	19 c0                	sbb    %eax,%eax
c0107ae1:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0107ae4:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0107ae8:	0f 95 c0             	setne  %al
c0107aeb:	0f b6 c0             	movzbl %al,%eax
c0107aee:	85 c0                	test   %eax,%eax
c0107af0:	74 0e                	je     c0107b00 <default_check+0x29d>
c0107af2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107af5:	83 c0 40             	add    $0x40,%eax
c0107af8:	8b 40 08             	mov    0x8(%eax),%eax
c0107afb:	83 f8 03             	cmp    $0x3,%eax
c0107afe:	74 24                	je     c0107b24 <default_check+0x2c1>
c0107b00:	c7 44 24 0c 20 ae 10 	movl   $0xc010ae20,0xc(%esp)
c0107b07:	c0 
c0107b08:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107b0f:	c0 
c0107b10:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0107b17:	00 
c0107b18:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107b1f:	e8 d4 88 ff ff       	call   c01003f8 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c0107b24:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0107b2b:	e8 fe b9 ff ff       	call   c010352e <alloc_pages>
c0107b30:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0107b33:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c0107b37:	75 24                	jne    c0107b5d <default_check+0x2fa>
c0107b39:	c7 44 24 0c 4c ae 10 	movl   $0xc010ae4c,0xc(%esp)
c0107b40:	c0 
c0107b41:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107b48:	c0 
c0107b49:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c0107b50:	00 
c0107b51:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107b58:	e8 9b 88 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0107b5d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107b64:	e8 c5 b9 ff ff       	call   c010352e <alloc_pages>
c0107b69:	85 c0                	test   %eax,%eax
c0107b6b:	74 24                	je     c0107b91 <default_check+0x32e>
c0107b6d:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c0107b74:	c0 
c0107b75:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107b7c:	c0 
c0107b7d:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
c0107b84:	00 
c0107b85:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107b8c:	e8 67 88 ff ff       	call   c01003f8 <__panic>
    assert(p0 + 2 == p1);
c0107b91:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107b94:	83 c0 40             	add    $0x40,%eax
c0107b97:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0107b9a:	74 24                	je     c0107bc0 <default_check+0x35d>
c0107b9c:	c7 44 24 0c 6a ae 10 	movl   $0xc010ae6a,0xc(%esp)
c0107ba3:	c0 
c0107ba4:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107bab:	c0 
c0107bac:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
c0107bb3:	00 
c0107bb4:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107bbb:	e8 38 88 ff ff       	call   c01003f8 <__panic>

    p2 = p0 + 1;
c0107bc0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bc3:	83 c0 20             	add    $0x20,%eax
c0107bc6:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0107bc9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107bd0:	00 
c0107bd1:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bd4:	89 04 24             	mov    %eax,(%esp)
c0107bd7:	e8 bd b9 ff ff       	call   c0103599 <free_pages>
    free_pages(p1, 3);
c0107bdc:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c0107be3:	00 
c0107be4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107be7:	89 04 24             	mov    %eax,(%esp)
c0107bea:	e8 aa b9 ff ff       	call   c0103599 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0107bef:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107bf2:	83 c0 04             	add    $0x4,%eax
c0107bf5:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0107bfc:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107bff:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0107c02:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0107c05:	0f a3 10             	bt     %edx,(%eax)
c0107c08:	19 c0                	sbb    %eax,%eax
c0107c0a:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0107c0d:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c0107c11:	0f 95 c0             	setne  %al
c0107c14:	0f b6 c0             	movzbl %al,%eax
c0107c17:	85 c0                	test   %eax,%eax
c0107c19:	74 0b                	je     c0107c26 <default_check+0x3c3>
c0107c1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107c1e:	8b 40 08             	mov    0x8(%eax),%eax
c0107c21:	83 f8 01             	cmp    $0x1,%eax
c0107c24:	74 24                	je     c0107c4a <default_check+0x3e7>
c0107c26:	c7 44 24 0c 78 ae 10 	movl   $0xc010ae78,0xc(%esp)
c0107c2d:	c0 
c0107c2e:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107c35:	c0 
c0107c36:	c7 44 24 04 1e 01 00 	movl   $0x11e,0x4(%esp)
c0107c3d:	00 
c0107c3e:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107c45:	e8 ae 87 ff ff       	call   c01003f8 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0107c4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c4d:	83 c0 04             	add    $0x4,%eax
c0107c50:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c0107c57:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0107c5a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0107c5d:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0107c60:	0f a3 10             	bt     %edx,(%eax)
c0107c63:	19 c0                	sbb    %eax,%eax
c0107c65:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c0107c68:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c0107c6c:	0f 95 c0             	setne  %al
c0107c6f:	0f b6 c0             	movzbl %al,%eax
c0107c72:	85 c0                	test   %eax,%eax
c0107c74:	74 0b                	je     c0107c81 <default_check+0x41e>
c0107c76:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0107c79:	8b 40 08             	mov    0x8(%eax),%eax
c0107c7c:	83 f8 03             	cmp    $0x3,%eax
c0107c7f:	74 24                	je     c0107ca5 <default_check+0x442>
c0107c81:	c7 44 24 0c a0 ae 10 	movl   $0xc010aea0,0xc(%esp)
c0107c88:	c0 
c0107c89:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107c90:	c0 
c0107c91:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c0107c98:	00 
c0107c99:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107ca0:	e8 53 87 ff ff       	call   c01003f8 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0107ca5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107cac:	e8 7d b8 ff ff       	call   c010352e <alloc_pages>
c0107cb1:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107cb4:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107cb7:	83 e8 20             	sub    $0x20,%eax
c0107cba:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107cbd:	74 24                	je     c0107ce3 <default_check+0x480>
c0107cbf:	c7 44 24 0c c6 ae 10 	movl   $0xc010aec6,0xc(%esp)
c0107cc6:	c0 
c0107cc7:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107cce:	c0 
c0107ccf:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0107cd6:	00 
c0107cd7:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107cde:	e8 15 87 ff ff       	call   c01003f8 <__panic>
    free_page(p0);
c0107ce3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107cea:	00 
c0107ceb:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107cee:	89 04 24             	mov    %eax,(%esp)
c0107cf1:	e8 a3 b8 ff ff       	call   c0103599 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0107cf6:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0107cfd:	e8 2c b8 ff ff       	call   c010352e <alloc_pages>
c0107d02:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107d05:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107d08:	83 c0 20             	add    $0x20,%eax
c0107d0b:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0107d0e:	74 24                	je     c0107d34 <default_check+0x4d1>
c0107d10:	c7 44 24 0c e4 ae 10 	movl   $0xc010aee4,0xc(%esp)
c0107d17:	c0 
c0107d18:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107d1f:	c0 
c0107d20:	c7 44 24 04 23 01 00 	movl   $0x123,0x4(%esp)
c0107d27:	00 
c0107d28:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107d2f:	e8 c4 86 ff ff       	call   c01003f8 <__panic>

    free_pages(p0, 2);
c0107d34:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0107d3b:	00 
c0107d3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107d3f:	89 04 24             	mov    %eax,(%esp)
c0107d42:	e8 52 b8 ff ff       	call   c0103599 <free_pages>
    free_page(p2);
c0107d47:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0107d4e:	00 
c0107d4f:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0107d52:	89 04 24             	mov    %eax,(%esp)
c0107d55:	e8 3f b8 ff ff       	call   c0103599 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0107d5a:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0107d61:	e8 c8 b7 ff ff       	call   c010352e <alloc_pages>
c0107d66:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107d69:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0107d6d:	75 24                	jne    c0107d93 <default_check+0x530>
c0107d6f:	c7 44 24 0c 04 af 10 	movl   $0xc010af04,0xc(%esp)
c0107d76:	c0 
c0107d77:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107d7e:	c0 
c0107d7f:	c7 44 24 04 28 01 00 	movl   $0x128,0x4(%esp)
c0107d86:	00 
c0107d87:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107d8e:	e8 65 86 ff ff       	call   c01003f8 <__panic>
    assert(alloc_page() == NULL);
c0107d93:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0107d9a:	e8 8f b7 ff ff       	call   c010352e <alloc_pages>
c0107d9f:	85 c0                	test   %eax,%eax
c0107da1:	74 24                	je     c0107dc7 <default_check+0x564>
c0107da3:	c7 44 24 0c 62 ad 10 	movl   $0xc010ad62,0xc(%esp)
c0107daa:	c0 
c0107dab:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107db2:	c0 
c0107db3:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0107dba:	00 
c0107dbb:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107dc2:	e8 31 86 ff ff       	call   c01003f8 <__panic>

    assert(nr_free == 0);
c0107dc7:	a1 14 51 12 c0       	mov    0xc0125114,%eax
c0107dcc:	85 c0                	test   %eax,%eax
c0107dce:	74 24                	je     c0107df4 <default_check+0x591>
c0107dd0:	c7 44 24 0c b5 ad 10 	movl   $0xc010adb5,0xc(%esp)
c0107dd7:	c0 
c0107dd8:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107ddf:	c0 
c0107de0:	c7 44 24 04 2b 01 00 	movl   $0x12b,0x4(%esp)
c0107de7:	00 
c0107de8:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107def:	e8 04 86 ff ff       	call   c01003f8 <__panic>
    nr_free = nr_free_store;
c0107df4:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107df7:	a3 14 51 12 c0       	mov    %eax,0xc0125114

    free_list = free_list_store;
c0107dfc:	8b 45 80             	mov    -0x80(%ebp),%eax
c0107dff:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0107e02:	a3 0c 51 12 c0       	mov    %eax,0xc012510c
c0107e07:	89 15 10 51 12 c0    	mov    %edx,0xc0125110
    free_pages(p0, 5);
c0107e0d:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0107e14:	00 
c0107e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107e18:	89 04 24             	mov    %eax,(%esp)
c0107e1b:	e8 79 b7 ff ff       	call   c0103599 <free_pages>

    le = &free_list;
c0107e20:	c7 45 ec 0c 51 12 c0 	movl   $0xc012510c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0107e27:	eb 1c                	jmp    c0107e45 <default_check+0x5e2>
        struct Page *p = le2page(le, page_link);
c0107e29:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e2c:	83 e8 0c             	sub    $0xc,%eax
c0107e2f:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c0107e32:	ff 4d f4             	decl   -0xc(%ebp)
c0107e35:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0107e38:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0107e3b:	8b 40 08             	mov    0x8(%eax),%eax
c0107e3e:	29 c2                	sub    %eax,%edx
c0107e40:	89 d0                	mov    %edx,%eax
c0107e42:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0107e45:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107e48:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0107e4b:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0107e4e:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0107e51:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0107e54:	81 7d ec 0c 51 12 c0 	cmpl   $0xc012510c,-0x14(%ebp)
c0107e5b:	75 cc                	jne    c0107e29 <default_check+0x5c6>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0107e5d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107e61:	74 24                	je     c0107e87 <default_check+0x624>
c0107e63:	c7 44 24 0c 22 af 10 	movl   $0xc010af22,0xc(%esp)
c0107e6a:	c0 
c0107e6b:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107e72:	c0 
c0107e73:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c0107e7a:	00 
c0107e7b:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107e82:	e8 71 85 ff ff       	call   c01003f8 <__panic>
    assert(total == 0);
c0107e87:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107e8b:	74 24                	je     c0107eb1 <default_check+0x64e>
c0107e8d:	c7 44 24 0c 2d af 10 	movl   $0xc010af2d,0xc(%esp)
c0107e94:	c0 
c0107e95:	c7 44 24 08 c2 ab 10 	movl   $0xc010abc2,0x8(%esp)
c0107e9c:	c0 
c0107e9d:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
c0107ea4:	00 
c0107ea5:	c7 04 24 d7 ab 10 c0 	movl   $0xc010abd7,(%esp)
c0107eac:	e8 47 85 ff ff       	call   c01003f8 <__panic>
}
c0107eb1:	90                   	nop
c0107eb2:	c9                   	leave  
c0107eb3:	c3                   	ret    

c0107eb4 <_clock_init_mm>:

list_entry_t pra_list_head;

static int
_clock_init_mm(struct mm_struct *mm)
{     
c0107eb4:	55                   	push   %ebp
c0107eb5:	89 e5                	mov    %esp,%ebp
c0107eb7:	83 ec 10             	sub    $0x10,%esp
c0107eba:	c7 45 fc 04 51 12 c0 	movl   $0xc0125104,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0107ec1:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ec4:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0107ec7:	89 50 04             	mov    %edx,0x4(%eax)
c0107eca:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ecd:	8b 50 04             	mov    0x4(%eax),%edx
c0107ed0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0107ed3:	89 10                	mov    %edx,(%eax)
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
c0107ed5:	8b 45 08             	mov    0x8(%ebp),%eax
c0107ed8:	c7 40 14 04 51 12 c0 	movl   $0xc0125104,0x14(%eax)
     return 0;
c0107edf:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107ee4:	c9                   	leave  
c0107ee5:	c3                   	ret    

c0107ee6 <_clock_map_swappable>:

static int
_clock_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
c0107ee6:	55                   	push   %ebp
c0107ee7:	89 e5                	mov    %esp,%ebp
c0107ee9:	83 ec 48             	sub    $0x48,%esp
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107eec:	8b 45 08             	mov    0x8(%ebp),%eax
c0107eef:	8b 40 14             	mov    0x14(%eax),%eax
c0107ef2:	89 45 f4             	mov    %eax,-0xc(%ebp)
    list_entry_t *entry=&(page->pra_page_link);
c0107ef5:	8b 45 10             	mov    0x10(%ebp),%eax
c0107ef8:	83 c0 14             	add    $0x14,%eax
c0107efb:	89 45 f0             	mov    %eax,-0x10(%ebp)
 
    assert(entry != NULL && head != NULL);
c0107efe:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107f02:	74 06                	je     c0107f0a <_clock_map_swappable+0x24>
c0107f04:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0107f08:	75 24                	jne    c0107f2e <_clock_map_swappable+0x48>
c0107f0a:	c7 44 24 0c 68 af 10 	movl   $0xc010af68,0xc(%esp)
c0107f11:	c0 
c0107f12:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0107f19:	c0 
c0107f1a:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
c0107f21:	00 
c0107f22:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0107f29:	e8 ca 84 ff ff       	call   c01003f8 <__panic>
    list_add(head -> prev, entry);
c0107f2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0107f31:	8b 00                	mov    (%eax),%eax
c0107f33:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0107f36:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f39:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0107f3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0107f3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0107f42:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0107f45:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0107f48:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0107f4b:	8b 40 04             	mov    0x4(%eax),%eax
c0107f4e:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0107f51:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0107f54:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0107f57:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0107f5a:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0107f5d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107f60:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0107f63:	89 10                	mov    %edx,(%eax)
c0107f65:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0107f68:	8b 10                	mov    (%eax),%edx
c0107f6a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0107f6d:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0107f70:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107f73:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0107f76:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0107f79:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0107f7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0107f7f:	89 10                	mov    %edx,(%eax)
    struct Page *ptr = le2page(entry, pra_page_link);
c0107f81:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0107f84:	83 e8 14             	sub    $0x14,%eax
c0107f87:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
c0107f8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0107f8d:	8b 50 1c             	mov    0x1c(%eax),%edx
c0107f90:	8b 45 08             	mov    0x8(%ebp),%eax
c0107f93:	8b 40 0c             	mov    0xc(%eax),%eax
c0107f96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0107f9d:	00 
c0107f9e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0107fa2:	89 04 24             	mov    %eax,(%esp)
c0107fa5:	e8 51 bc ff ff       	call   c0103bfb <get_pte>
c0107faa:	89 45 e8             	mov    %eax,-0x18(%ebp)
    // set the dirty bit to 0
    *pte &= ~PTE_D;
c0107fad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fb0:	8b 00                	mov    (%eax),%eax
c0107fb2:	83 e0 bf             	and    $0xffffffbf,%eax
c0107fb5:	89 c2                	mov    %eax,%edx
c0107fb7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0107fba:	89 10                	mov    %edx,(%eax)
    return 0;
c0107fbc:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0107fc1:	c9                   	leave  
c0107fc2:	c3                   	ret    

c0107fc3 <_clock_swap_out_victim>:

static int
_clock_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
c0107fc3:	55                   	push   %ebp
c0107fc4:	89 e5                	mov    %esp,%ebp
c0107fc6:	83 ec 48             	sub    $0x48,%esp
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
c0107fc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0107fcc:	8b 40 14             	mov    0x14(%eax),%eax
c0107fcf:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(head != NULL);
c0107fd2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0107fd6:	75 24                	jne    c0107ffc <_clock_swap_out_victim+0x39>
c0107fd8:	c7 44 24 0c b0 af 10 	movl   $0xc010afb0,0xc(%esp)
c0107fdf:	c0 
c0107fe0:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0107fe7:	c0 
c0107fe8:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
c0107fef:	00 
c0107ff0:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0107ff7:	e8 fc 83 ff ff       	call   c01003f8 <__panic>
    assert(in_tick==0);
c0107ffc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108000:	74 24                	je     c0108026 <_clock_swap_out_victim+0x63>
c0108002:	c7 44 24 0c bd af 10 	movl   $0xc010afbd,0xc(%esp)
c0108009:	c0 
c010800a:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108011:	c0 
c0108012:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
c0108019:	00 
c010801a:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108021:	e8 d2 83 ff ff       	call   c01003f8 <__panic>

    list_entry_t *p = head;
c0108026:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108029:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010802c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010802f:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0108032:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108035:	8b 40 04             	mov    0x4(%eax),%eax
    while(1){
        p = list_next(p);
c0108038:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(p == head){
c010803b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010803e:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0108041:	75 e9                	jne    c010802c <_clock_swap_out_victim+0x69>
c0108043:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108046:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0108049:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010804c:	8b 40 04             	mov    0x4(%eax),%eax
            p = list_next(p);
c010804f:	89 45 f4             	mov    %eax,-0xc(%ebp)
            struct Page *ptr = le2page(p, pra_page_link);
c0108052:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108055:	83 e8 14             	sub    $0x14,%eax
c0108058:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            pte_t *pte = get_pte(mm -> pgdir, ptr -> pra_vaddr, 0);
c010805b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010805e:	8b 50 1c             	mov    0x1c(%eax),%edx
c0108061:	8b 45 08             	mov    0x8(%ebp),%eax
c0108064:	8b 40 0c             	mov    0xc(%eax),%eax
c0108067:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010806e:	00 
c010806f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108073:	89 04 24             	mov    %eax,(%esp)
c0108076:	e8 80 bb ff ff       	call   c0103bfb <get_pte>
c010807b:	89 45 e0             	mov    %eax,-0x20(%ebp)
                *pte &= ~PTE_A;
            }else if( ((*pte&PTE_A)==0) && ((*pte&PTE_D)==1) ){
                *pte &= ~PTE_D;
            }
            else{
                *ptr_page = ptr;
c010807e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108081:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108084:	89 10                	mov    %edx,(%eax)
c0108086:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108089:	89 45 e8             	mov    %eax,-0x18(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c010808c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010808f:	8b 40 04             	mov    0x4(%eax),%eax
c0108092:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108095:	8b 12                	mov    (%edx),%edx
c0108097:	89 55 d8             	mov    %edx,-0x28(%ebp)
c010809a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c010809d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01080a0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01080a3:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c01080a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01080a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01080ac:	89 10                	mov    %edx,(%eax)
                list_del(p);
                *ptr_page = ptr;
c01080ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01080b1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01080b4:	89 10                	mov    %edx,(%eax)
                return 0;
c01080b6:	b8 00 00 00 00       	mov    $0x0,%eax
            }
        }
    }
     return 0;
}
c01080bb:	c9                   	leave  
c01080bc:	c3                   	ret    

c01080bd <_clock_check_swap>:

static int
_clock_check_swap(void) {
c01080bd:	55                   	push   %ebp
c01080be:	89 e5                	mov    %esp,%ebp
c01080c0:	83 ec 18             	sub    $0x18,%esp
    cprintf("write Virt Page c in fifo_check_swap\n");
c01080c3:	c7 04 24 c8 af 10 c0 	movl   $0xc010afc8,(%esp)
c01080ca:	e8 d2 81 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01080cf:	b8 00 30 00 00       	mov    $0x3000,%eax
c01080d4:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==4);
c01080d7:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01080dc:	83 f8 04             	cmp    $0x4,%eax
c01080df:	74 24                	je     c0108105 <_clock_check_swap+0x48>
c01080e1:	c7 44 24 0c ee af 10 	movl   $0xc010afee,0xc(%esp)
c01080e8:	c0 
c01080e9:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01080f0:	c0 
c01080f1:	c7 44 24 04 48 00 00 	movl   $0x48,0x4(%esp)
c01080f8:	00 
c01080f9:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108100:	e8 f3 82 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108105:	c7 04 24 00 b0 10 c0 	movl   $0xc010b000,(%esp)
c010810c:	e8 90 81 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c0108111:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108116:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==4);
c0108119:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c010811e:	83 f8 04             	cmp    $0x4,%eax
c0108121:	74 24                	je     c0108147 <_clock_check_swap+0x8a>
c0108123:	c7 44 24 0c ee af 10 	movl   $0xc010afee,0xc(%esp)
c010812a:	c0 
c010812b:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108132:	c0 
c0108133:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
c010813a:	00 
c010813b:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108142:	e8 b1 82 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0108147:	c7 04 24 28 b0 10 c0 	movl   $0xc010b028,(%esp)
c010814e:	e8 4e 81 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108153:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108158:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==4);
c010815b:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0108160:	83 f8 04             	cmp    $0x4,%eax
c0108163:	74 24                	je     c0108189 <_clock_check_swap+0xcc>
c0108165:	c7 44 24 0c ee af 10 	movl   $0xc010afee,0xc(%esp)
c010816c:	c0 
c010816d:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108174:	c0 
c0108175:	c7 44 24 04 4e 00 00 	movl   $0x4e,0x4(%esp)
c010817c:	00 
c010817d:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108184:	e8 6f 82 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108189:	c7 04 24 50 b0 10 c0 	movl   $0xc010b050,(%esp)
c0108190:	e8 0c 81 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108195:	b8 00 20 00 00       	mov    $0x2000,%eax
c010819a:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==4);
c010819d:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01081a2:	83 f8 04             	cmp    $0x4,%eax
c01081a5:	74 24                	je     c01081cb <_clock_check_swap+0x10e>
c01081a7:	c7 44 24 0c ee af 10 	movl   $0xc010afee,0xc(%esp)
c01081ae:	c0 
c01081af:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01081b6:	c0 
c01081b7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
c01081be:	00 
c01081bf:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c01081c6:	e8 2d 82 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c01081cb:	c7 04 24 78 b0 10 c0 	movl   $0xc010b078,(%esp)
c01081d2:	e8 ca 80 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c01081d7:	b8 00 50 00 00       	mov    $0x5000,%eax
c01081dc:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==5);
c01081df:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01081e4:	83 f8 05             	cmp    $0x5,%eax
c01081e7:	74 24                	je     c010820d <_clock_check_swap+0x150>
c01081e9:	c7 44 24 0c 9e b0 10 	movl   $0xc010b09e,0xc(%esp)
c01081f0:	c0 
c01081f1:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01081f8:	c0 
c01081f9:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
c0108200:	00 
c0108201:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108208:	e8 eb 81 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c010820d:	c7 04 24 50 b0 10 c0 	movl   $0xc010b050,(%esp)
c0108214:	e8 88 80 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c0108219:	b8 00 20 00 00       	mov    $0x2000,%eax
c010821e:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==5);
c0108221:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0108226:	83 f8 05             	cmp    $0x5,%eax
c0108229:	74 24                	je     c010824f <_clock_check_swap+0x192>
c010822b:	c7 44 24 0c 9e b0 10 	movl   $0xc010b09e,0xc(%esp)
c0108232:	c0 
c0108233:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c010823a:	c0 
c010823b:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
c0108242:	00 
c0108243:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c010824a:	e8 a9 81 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c010824f:	c7 04 24 00 b0 10 c0 	movl   $0xc010b000,(%esp)
c0108256:	e8 46 80 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
c010825b:	b8 00 10 00 00       	mov    $0x1000,%eax
c0108260:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==6);
c0108263:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0108268:	83 f8 06             	cmp    $0x6,%eax
c010826b:	74 24                	je     c0108291 <_clock_check_swap+0x1d4>
c010826d:	c7 44 24 0c ad b0 10 	movl   $0xc010b0ad,0xc(%esp)
c0108274:	c0 
c0108275:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c010827c:	c0 
c010827d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0108284:	00 
c0108285:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c010828c:	e8 67 81 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page b in fifo_check_swap\n");
c0108291:	c7 04 24 50 b0 10 c0 	movl   $0xc010b050,(%esp)
c0108298:	e8 04 80 ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
c010829d:	b8 00 20 00 00       	mov    $0x2000,%eax
c01082a2:	c6 00 0b             	movb   $0xb,(%eax)
    assert(pgfault_num==7);
c01082a5:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01082aa:	83 f8 07             	cmp    $0x7,%eax
c01082ad:	74 24                	je     c01082d3 <_clock_check_swap+0x216>
c01082af:	c7 44 24 0c bc b0 10 	movl   $0xc010b0bc,0xc(%esp)
c01082b6:	c0 
c01082b7:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01082be:	c0 
c01082bf:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
c01082c6:	00 
c01082c7:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c01082ce:	e8 25 81 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page c in fifo_check_swap\n");
c01082d3:	c7 04 24 c8 af 10 c0 	movl   $0xc010afc8,(%esp)
c01082da:	e8 c2 7f ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
c01082df:	b8 00 30 00 00       	mov    $0x3000,%eax
c01082e4:	c6 00 0c             	movb   $0xc,(%eax)
    assert(pgfault_num==8);
c01082e7:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01082ec:	83 f8 08             	cmp    $0x8,%eax
c01082ef:	74 24                	je     c0108315 <_clock_check_swap+0x258>
c01082f1:	c7 44 24 0c cb b0 10 	movl   $0xc010b0cb,0xc(%esp)
c01082f8:	c0 
c01082f9:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108300:	c0 
c0108301:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
c0108308:	00 
c0108309:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108310:	e8 e3 80 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page d in fifo_check_swap\n");
c0108315:	c7 04 24 28 b0 10 c0 	movl   $0xc010b028,(%esp)
c010831c:	e8 80 7f ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
c0108321:	b8 00 40 00 00       	mov    $0x4000,%eax
c0108326:	c6 00 0d             	movb   $0xd,(%eax)
    assert(pgfault_num==9);
c0108329:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c010832e:	83 f8 09             	cmp    $0x9,%eax
c0108331:	74 24                	je     c0108357 <_clock_check_swap+0x29a>
c0108333:	c7 44 24 0c da b0 10 	movl   $0xc010b0da,0xc(%esp)
c010833a:	c0 
c010833b:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108342:	c0 
c0108343:	c7 44 24 04 63 00 00 	movl   $0x63,0x4(%esp)
c010834a:	00 
c010834b:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108352:	e8 a1 80 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page e in fifo_check_swap\n");
c0108357:	c7 04 24 78 b0 10 c0 	movl   $0xc010b078,(%esp)
c010835e:	e8 3e 7f ff ff       	call   c01002a1 <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
c0108363:	b8 00 50 00 00       	mov    $0x5000,%eax
c0108368:	c6 00 0e             	movb   $0xe,(%eax)
    assert(pgfault_num==10);
c010836b:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c0108370:	83 f8 0a             	cmp    $0xa,%eax
c0108373:	74 24                	je     c0108399 <_clock_check_swap+0x2dc>
c0108375:	c7 44 24 0c e9 b0 10 	movl   $0xc010b0e9,0xc(%esp)
c010837c:	c0 
c010837d:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c0108384:	c0 
c0108385:	c7 44 24 04 66 00 00 	movl   $0x66,0x4(%esp)
c010838c:	00 
c010838d:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108394:	e8 5f 80 ff ff       	call   c01003f8 <__panic>
    cprintf("write Virt Page a in fifo_check_swap\n");
c0108399:	c7 04 24 00 b0 10 c0 	movl   $0xc010b000,(%esp)
c01083a0:	e8 fc 7e ff ff       	call   c01002a1 <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
c01083a5:	b8 00 10 00 00       	mov    $0x1000,%eax
c01083aa:	0f b6 00             	movzbl (%eax),%eax
c01083ad:	3c 0a                	cmp    $0xa,%al
c01083af:	74 24                	je     c01083d5 <_clock_check_swap+0x318>
c01083b1:	c7 44 24 0c fc b0 10 	movl   $0xc010b0fc,0xc(%esp)
c01083b8:	c0 
c01083b9:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01083c0:	c0 
c01083c1:	c7 44 24 04 68 00 00 	movl   $0x68,0x4(%esp)
c01083c8:	00 
c01083c9:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c01083d0:	e8 23 80 ff ff       	call   c01003f8 <__panic>
    *(unsigned char *)0x1000 = 0x0a;
c01083d5:	b8 00 10 00 00       	mov    $0x1000,%eax
c01083da:	c6 00 0a             	movb   $0xa,(%eax)
    assert(pgfault_num==11);
c01083dd:	a1 0c 50 12 c0       	mov    0xc012500c,%eax
c01083e2:	83 f8 0b             	cmp    $0xb,%eax
c01083e5:	74 24                	je     c010840b <_clock_check_swap+0x34e>
c01083e7:	c7 44 24 0c 1d b1 10 	movl   $0xc010b11d,0xc(%esp)
c01083ee:	c0 
c01083ef:	c7 44 24 08 86 af 10 	movl   $0xc010af86,0x8(%esp)
c01083f6:	c0 
c01083f7:	c7 44 24 04 6a 00 00 	movl   $0x6a,0x4(%esp)
c01083fe:	00 
c01083ff:	c7 04 24 9b af 10 c0 	movl   $0xc010af9b,(%esp)
c0108406:	e8 ed 7f ff ff       	call   c01003f8 <__panic>
    return 0;
c010840b:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108410:	c9                   	leave  
c0108411:	c3                   	ret    

c0108412 <_clock_init>:


static int
_clock_init(void)
{
c0108412:	55                   	push   %ebp
c0108413:	89 e5                	mov    %esp,%ebp
    return 0;
c0108415:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010841a:	5d                   	pop    %ebp
c010841b:	c3                   	ret    

c010841c <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
c010841c:	55                   	push   %ebp
c010841d:	89 e5                	mov    %esp,%ebp
    return 0;
c010841f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108424:	5d                   	pop    %ebp
c0108425:	c3                   	ret    

c0108426 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
c0108426:	55                   	push   %ebp
c0108427:	89 e5                	mov    %esp,%ebp
c0108429:	b8 00 00 00 00       	mov    $0x0,%eax
c010842e:	5d                   	pop    %ebp
c010842f:	c3                   	ret    

c0108430 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0108430:	55                   	push   %ebp
c0108431:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0108433:	8b 45 08             	mov    0x8(%ebp),%eax
c0108436:	8b 15 28 50 12 c0    	mov    0xc0125028,%edx
c010843c:	29 d0                	sub    %edx,%eax
c010843e:	c1 f8 05             	sar    $0x5,%eax
}
c0108441:	5d                   	pop    %ebp
c0108442:	c3                   	ret    

c0108443 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0108443:	55                   	push   %ebp
c0108444:	89 e5                	mov    %esp,%ebp
c0108446:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0108449:	8b 45 08             	mov    0x8(%ebp),%eax
c010844c:	89 04 24             	mov    %eax,(%esp)
c010844f:	e8 dc ff ff ff       	call   c0108430 <page2ppn>
c0108454:	c1 e0 0c             	shl    $0xc,%eax
}
c0108457:	c9                   	leave  
c0108458:	c3                   	ret    

c0108459 <page2kva>:
    }
    return &pages[PPN(pa)];
}

static inline void *
page2kva(struct Page *page) {
c0108459:	55                   	push   %ebp
c010845a:	89 e5                	mov    %esp,%ebp
c010845c:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c010845f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108462:	89 04 24             	mov    %eax,(%esp)
c0108465:	e8 d9 ff ff ff       	call   c0108443 <page2pa>
c010846a:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010846d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108470:	c1 e8 0c             	shr    $0xc,%eax
c0108473:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108476:	a1 80 4f 12 c0       	mov    0xc0124f80,%eax
c010847b:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c010847e:	72 23                	jb     c01084a3 <page2kva+0x4a>
c0108480:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108483:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108487:	c7 44 24 08 40 b1 10 	movl   $0xc010b140,0x8(%esp)
c010848e:	c0 
c010848f:	c7 44 24 04 62 00 00 	movl   $0x62,0x4(%esp)
c0108496:	00 
c0108497:	c7 04 24 63 b1 10 c0 	movl   $0xc010b163,(%esp)
c010849e:	e8 55 7f ff ff       	call   c01003f8 <__panic>
c01084a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01084a6:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c01084ab:	c9                   	leave  
c01084ac:	c3                   	ret    

c01084ad <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
c01084ad:	55                   	push   %ebp
c01084ae:	89 e5                	mov    %esp,%ebp
c01084b0:	83 ec 18             	sub    $0x18,%esp
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
c01084b3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084ba:	e8 51 8c ff ff       	call   c0101110 <ide_device_valid>
c01084bf:	85 c0                	test   %eax,%eax
c01084c1:	75 1c                	jne    c01084df <swapfs_init+0x32>
        panic("swap fs isn't available.\n");
c01084c3:	c7 44 24 08 71 b1 10 	movl   $0xc010b171,0x8(%esp)
c01084ca:	c0 
c01084cb:	c7 44 24 04 0d 00 00 	movl   $0xd,0x4(%esp)
c01084d2:	00 
c01084d3:	c7 04 24 8b b1 10 c0 	movl   $0xc010b18b,(%esp)
c01084da:	e8 19 7f ff ff       	call   c01003f8 <__panic>
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
c01084df:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01084e6:	e8 67 8c ff ff       	call   c0101152 <ide_device_size>
c01084eb:	c1 e8 03             	shr    $0x3,%eax
c01084ee:	a3 dc 50 12 c0       	mov    %eax,0xc01250dc
}
c01084f3:	90                   	nop
c01084f4:	c9                   	leave  
c01084f5:	c3                   	ret    

c01084f6 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
c01084f6:	55                   	push   %ebp
c01084f7:	89 e5                	mov    %esp,%ebp
c01084f9:	83 ec 28             	sub    $0x28,%esp
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c01084fc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01084ff:	89 04 24             	mov    %eax,(%esp)
c0108502:	e8 52 ff ff ff       	call   c0108459 <page2kva>
c0108507:	8b 55 08             	mov    0x8(%ebp),%edx
c010850a:	c1 ea 08             	shr    $0x8,%edx
c010850d:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108510:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108514:	74 0b                	je     c0108521 <swapfs_read+0x2b>
c0108516:	8b 15 dc 50 12 c0    	mov    0xc01250dc,%edx
c010851c:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c010851f:	72 23                	jb     c0108544 <swapfs_read+0x4e>
c0108521:	8b 45 08             	mov    0x8(%ebp),%eax
c0108524:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108528:	c7 44 24 08 9c b1 10 	movl   $0xc010b19c,0x8(%esp)
c010852f:	c0 
c0108530:	c7 44 24 04 14 00 00 	movl   $0x14,0x4(%esp)
c0108537:	00 
c0108538:	c7 04 24 8b b1 10 c0 	movl   $0xc010b18b,(%esp)
c010853f:	e8 b4 7e ff ff       	call   c01003f8 <__panic>
c0108544:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108547:	c1 e2 03             	shl    $0x3,%edx
c010854a:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c0108551:	00 
c0108552:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108556:	89 54 24 04          	mov    %edx,0x4(%esp)
c010855a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0108561:	e8 2b 8c ff ff       	call   c0101191 <ide_read_secs>
}
c0108566:	c9                   	leave  
c0108567:	c3                   	ret    

c0108568 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
c0108568:	55                   	push   %ebp
c0108569:	89 e5                	mov    %esp,%ebp
c010856b:	83 ec 28             	sub    $0x28,%esp
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
c010856e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108571:	89 04 24             	mov    %eax,(%esp)
c0108574:	e8 e0 fe ff ff       	call   c0108459 <page2kva>
c0108579:	8b 55 08             	mov    0x8(%ebp),%edx
c010857c:	c1 ea 08             	shr    $0x8,%edx
c010857f:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108582:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0108586:	74 0b                	je     c0108593 <swapfs_write+0x2b>
c0108588:	8b 15 dc 50 12 c0    	mov    0xc01250dc,%edx
c010858e:	39 55 f4             	cmp    %edx,-0xc(%ebp)
c0108591:	72 23                	jb     c01085b6 <swapfs_write+0x4e>
c0108593:	8b 45 08             	mov    0x8(%ebp),%eax
c0108596:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010859a:	c7 44 24 08 9c b1 10 	movl   $0xc010b19c,0x8(%esp)
c01085a1:	c0 
c01085a2:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
c01085a9:	00 
c01085aa:	c7 04 24 8b b1 10 c0 	movl   $0xc010b18b,(%esp)
c01085b1:	e8 42 7e ff ff       	call   c01003f8 <__panic>
c01085b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01085b9:	c1 e2 03             	shl    $0x3,%edx
c01085bc:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
c01085c3:	00 
c01085c4:	89 44 24 08          	mov    %eax,0x8(%esp)
c01085c8:	89 54 24 04          	mov    %edx,0x4(%esp)
c01085cc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01085d3:	e8 f3 8d ff ff       	call   c01013cb <ide_write_secs>
}
c01085d8:	c9                   	leave  
c01085d9:	c3                   	ret    

c01085da <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c01085da:	55                   	push   %ebp
c01085db:	89 e5                	mov    %esp,%ebp
c01085dd:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c01085e0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c01085e7:	eb 03                	jmp    c01085ec <strlen+0x12>
        cnt ++;
c01085e9:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c01085ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01085ef:	8d 50 01             	lea    0x1(%eax),%edx
c01085f2:	89 55 08             	mov    %edx,0x8(%ebp)
c01085f5:	0f b6 00             	movzbl (%eax),%eax
c01085f8:	84 c0                	test   %al,%al
c01085fa:	75 ed                	jne    c01085e9 <strlen+0xf>
        cnt ++;
    }
    return cnt;
c01085fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01085ff:	c9                   	leave  
c0108600:	c3                   	ret    

c0108601 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0108601:	55                   	push   %ebp
c0108602:	89 e5                	mov    %esp,%ebp
c0108604:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0108607:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010860e:	eb 03                	jmp    c0108613 <strnlen+0x12>
        cnt ++;
c0108610:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0108613:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108616:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0108619:	73 10                	jae    c010862b <strnlen+0x2a>
c010861b:	8b 45 08             	mov    0x8(%ebp),%eax
c010861e:	8d 50 01             	lea    0x1(%eax),%edx
c0108621:	89 55 08             	mov    %edx,0x8(%ebp)
c0108624:	0f b6 00             	movzbl (%eax),%eax
c0108627:	84 c0                	test   %al,%al
c0108629:	75 e5                	jne    c0108610 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c010862b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010862e:	c9                   	leave  
c010862f:	c3                   	ret    

c0108630 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0108630:	55                   	push   %ebp
c0108631:	89 e5                	mov    %esp,%ebp
c0108633:	57                   	push   %edi
c0108634:	56                   	push   %esi
c0108635:	83 ec 20             	sub    $0x20,%esp
c0108638:	8b 45 08             	mov    0x8(%ebp),%eax
c010863b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010863e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108641:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0108644:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108647:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010864a:	89 d1                	mov    %edx,%ecx
c010864c:	89 c2                	mov    %eax,%edx
c010864e:	89 ce                	mov    %ecx,%esi
c0108650:	89 d7                	mov    %edx,%edi
c0108652:	ac                   	lods   %ds:(%esi),%al
c0108653:	aa                   	stos   %al,%es:(%edi)
c0108654:	84 c0                	test   %al,%al
c0108656:	75 fa                	jne    c0108652 <strcpy+0x22>
c0108658:	89 fa                	mov    %edi,%edx
c010865a:	89 f1                	mov    %esi,%ecx
c010865c:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010865f:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0108662:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0108665:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c0108668:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0108669:	83 c4 20             	add    $0x20,%esp
c010866c:	5e                   	pop    %esi
c010866d:	5f                   	pop    %edi
c010866e:	5d                   	pop    %ebp
c010866f:	c3                   	ret    

c0108670 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0108670:	55                   	push   %ebp
c0108671:	89 e5                	mov    %esp,%ebp
c0108673:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0108676:	8b 45 08             	mov    0x8(%ebp),%eax
c0108679:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c010867c:	eb 1e                	jmp    c010869c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c010867e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108681:	0f b6 10             	movzbl (%eax),%edx
c0108684:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108687:	88 10                	mov    %dl,(%eax)
c0108689:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010868c:	0f b6 00             	movzbl (%eax),%eax
c010868f:	84 c0                	test   %al,%al
c0108691:	74 03                	je     c0108696 <strncpy+0x26>
            src ++;
c0108693:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0108696:	ff 45 fc             	incl   -0x4(%ebp)
c0108699:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c010869c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01086a0:	75 dc                	jne    c010867e <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c01086a2:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01086a5:	c9                   	leave  
c01086a6:	c3                   	ret    

c01086a7 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c01086a7:	55                   	push   %ebp
c01086a8:	89 e5                	mov    %esp,%ebp
c01086aa:	57                   	push   %edi
c01086ab:	56                   	push   %esi
c01086ac:	83 ec 20             	sub    $0x20,%esp
c01086af:	8b 45 08             	mov    0x8(%ebp),%eax
c01086b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01086b5:	8b 45 0c             	mov    0xc(%ebp),%eax
c01086b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c01086bb:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01086be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01086c1:	89 d1                	mov    %edx,%ecx
c01086c3:	89 c2                	mov    %eax,%edx
c01086c5:	89 ce                	mov    %ecx,%esi
c01086c7:	89 d7                	mov    %edx,%edi
c01086c9:	ac                   	lods   %ds:(%esi),%al
c01086ca:	ae                   	scas   %es:(%edi),%al
c01086cb:	75 08                	jne    c01086d5 <strcmp+0x2e>
c01086cd:	84 c0                	test   %al,%al
c01086cf:	75 f8                	jne    c01086c9 <strcmp+0x22>
c01086d1:	31 c0                	xor    %eax,%eax
c01086d3:	eb 04                	jmp    c01086d9 <strcmp+0x32>
c01086d5:	19 c0                	sbb    %eax,%eax
c01086d7:	0c 01                	or     $0x1,%al
c01086d9:	89 fa                	mov    %edi,%edx
c01086db:	89 f1                	mov    %esi,%ecx
c01086dd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01086e0:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c01086e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c01086e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c01086e9:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c01086ea:	83 c4 20             	add    $0x20,%esp
c01086ed:	5e                   	pop    %esi
c01086ee:	5f                   	pop    %edi
c01086ef:	5d                   	pop    %ebp
c01086f0:	c3                   	ret    

c01086f1 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c01086f1:	55                   	push   %ebp
c01086f2:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01086f4:	eb 09                	jmp    c01086ff <strncmp+0xe>
        n --, s1 ++, s2 ++;
c01086f6:	ff 4d 10             	decl   0x10(%ebp)
c01086f9:	ff 45 08             	incl   0x8(%ebp)
c01086fc:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c01086ff:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108703:	74 1a                	je     c010871f <strncmp+0x2e>
c0108705:	8b 45 08             	mov    0x8(%ebp),%eax
c0108708:	0f b6 00             	movzbl (%eax),%eax
c010870b:	84 c0                	test   %al,%al
c010870d:	74 10                	je     c010871f <strncmp+0x2e>
c010870f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108712:	0f b6 10             	movzbl (%eax),%edx
c0108715:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108718:	0f b6 00             	movzbl (%eax),%eax
c010871b:	38 c2                	cmp    %al,%dl
c010871d:	74 d7                	je     c01086f6 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c010871f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108723:	74 18                	je     c010873d <strncmp+0x4c>
c0108725:	8b 45 08             	mov    0x8(%ebp),%eax
c0108728:	0f b6 00             	movzbl (%eax),%eax
c010872b:	0f b6 d0             	movzbl %al,%edx
c010872e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108731:	0f b6 00             	movzbl (%eax),%eax
c0108734:	0f b6 c0             	movzbl %al,%eax
c0108737:	29 c2                	sub    %eax,%edx
c0108739:	89 d0                	mov    %edx,%eax
c010873b:	eb 05                	jmp    c0108742 <strncmp+0x51>
c010873d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108742:	5d                   	pop    %ebp
c0108743:	c3                   	ret    

c0108744 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0108744:	55                   	push   %ebp
c0108745:	89 e5                	mov    %esp,%ebp
c0108747:	83 ec 04             	sub    $0x4,%esp
c010874a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010874d:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108750:	eb 13                	jmp    c0108765 <strchr+0x21>
        if (*s == c) {
c0108752:	8b 45 08             	mov    0x8(%ebp),%eax
c0108755:	0f b6 00             	movzbl (%eax),%eax
c0108758:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010875b:	75 05                	jne    c0108762 <strchr+0x1e>
            return (char *)s;
c010875d:	8b 45 08             	mov    0x8(%ebp),%eax
c0108760:	eb 12                	jmp    c0108774 <strchr+0x30>
        }
        s ++;
c0108762:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0108765:	8b 45 08             	mov    0x8(%ebp),%eax
c0108768:	0f b6 00             	movzbl (%eax),%eax
c010876b:	84 c0                	test   %al,%al
c010876d:	75 e3                	jne    c0108752 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c010876f:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108774:	c9                   	leave  
c0108775:	c3                   	ret    

c0108776 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0108776:	55                   	push   %ebp
c0108777:	89 e5                	mov    %esp,%ebp
c0108779:	83 ec 04             	sub    $0x4,%esp
c010877c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010877f:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0108782:	eb 0e                	jmp    c0108792 <strfind+0x1c>
        if (*s == c) {
c0108784:	8b 45 08             	mov    0x8(%ebp),%eax
c0108787:	0f b6 00             	movzbl (%eax),%eax
c010878a:	3a 45 fc             	cmp    -0x4(%ebp),%al
c010878d:	74 0f                	je     c010879e <strfind+0x28>
            break;
        }
        s ++;
c010878f:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0108792:	8b 45 08             	mov    0x8(%ebp),%eax
c0108795:	0f b6 00             	movzbl (%eax),%eax
c0108798:	84 c0                	test   %al,%al
c010879a:	75 e8                	jne    c0108784 <strfind+0xe>
c010879c:	eb 01                	jmp    c010879f <strfind+0x29>
        if (*s == c) {
            break;
c010879e:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c010879f:	8b 45 08             	mov    0x8(%ebp),%eax
}
c01087a2:	c9                   	leave  
c01087a3:	c3                   	ret    

c01087a4 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c01087a4:	55                   	push   %ebp
c01087a5:	89 e5                	mov    %esp,%ebp
c01087a7:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c01087aa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c01087b1:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01087b8:	eb 03                	jmp    c01087bd <strtol+0x19>
        s ++;
c01087ba:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c01087bd:	8b 45 08             	mov    0x8(%ebp),%eax
c01087c0:	0f b6 00             	movzbl (%eax),%eax
c01087c3:	3c 20                	cmp    $0x20,%al
c01087c5:	74 f3                	je     c01087ba <strtol+0x16>
c01087c7:	8b 45 08             	mov    0x8(%ebp),%eax
c01087ca:	0f b6 00             	movzbl (%eax),%eax
c01087cd:	3c 09                	cmp    $0x9,%al
c01087cf:	74 e9                	je     c01087ba <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c01087d1:	8b 45 08             	mov    0x8(%ebp),%eax
c01087d4:	0f b6 00             	movzbl (%eax),%eax
c01087d7:	3c 2b                	cmp    $0x2b,%al
c01087d9:	75 05                	jne    c01087e0 <strtol+0x3c>
        s ++;
c01087db:	ff 45 08             	incl   0x8(%ebp)
c01087de:	eb 14                	jmp    c01087f4 <strtol+0x50>
    }
    else if (*s == '-') {
c01087e0:	8b 45 08             	mov    0x8(%ebp),%eax
c01087e3:	0f b6 00             	movzbl (%eax),%eax
c01087e6:	3c 2d                	cmp    $0x2d,%al
c01087e8:	75 0a                	jne    c01087f4 <strtol+0x50>
        s ++, neg = 1;
c01087ea:	ff 45 08             	incl   0x8(%ebp)
c01087ed:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c01087f4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01087f8:	74 06                	je     c0108800 <strtol+0x5c>
c01087fa:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c01087fe:	75 22                	jne    c0108822 <strtol+0x7e>
c0108800:	8b 45 08             	mov    0x8(%ebp),%eax
c0108803:	0f b6 00             	movzbl (%eax),%eax
c0108806:	3c 30                	cmp    $0x30,%al
c0108808:	75 18                	jne    c0108822 <strtol+0x7e>
c010880a:	8b 45 08             	mov    0x8(%ebp),%eax
c010880d:	40                   	inc    %eax
c010880e:	0f b6 00             	movzbl (%eax),%eax
c0108811:	3c 78                	cmp    $0x78,%al
c0108813:	75 0d                	jne    c0108822 <strtol+0x7e>
        s += 2, base = 16;
c0108815:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0108819:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0108820:	eb 29                	jmp    c010884b <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0108822:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108826:	75 16                	jne    c010883e <strtol+0x9a>
c0108828:	8b 45 08             	mov    0x8(%ebp),%eax
c010882b:	0f b6 00             	movzbl (%eax),%eax
c010882e:	3c 30                	cmp    $0x30,%al
c0108830:	75 0c                	jne    c010883e <strtol+0x9a>
        s ++, base = 8;
c0108832:	ff 45 08             	incl   0x8(%ebp)
c0108835:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c010883c:	eb 0d                	jmp    c010884b <strtol+0xa7>
    }
    else if (base == 0) {
c010883e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0108842:	75 07                	jne    c010884b <strtol+0xa7>
        base = 10;
c0108844:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c010884b:	8b 45 08             	mov    0x8(%ebp),%eax
c010884e:	0f b6 00             	movzbl (%eax),%eax
c0108851:	3c 2f                	cmp    $0x2f,%al
c0108853:	7e 1b                	jle    c0108870 <strtol+0xcc>
c0108855:	8b 45 08             	mov    0x8(%ebp),%eax
c0108858:	0f b6 00             	movzbl (%eax),%eax
c010885b:	3c 39                	cmp    $0x39,%al
c010885d:	7f 11                	jg     c0108870 <strtol+0xcc>
            dig = *s - '0';
c010885f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108862:	0f b6 00             	movzbl (%eax),%eax
c0108865:	0f be c0             	movsbl %al,%eax
c0108868:	83 e8 30             	sub    $0x30,%eax
c010886b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010886e:	eb 48                	jmp    c01088b8 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0108870:	8b 45 08             	mov    0x8(%ebp),%eax
c0108873:	0f b6 00             	movzbl (%eax),%eax
c0108876:	3c 60                	cmp    $0x60,%al
c0108878:	7e 1b                	jle    c0108895 <strtol+0xf1>
c010887a:	8b 45 08             	mov    0x8(%ebp),%eax
c010887d:	0f b6 00             	movzbl (%eax),%eax
c0108880:	3c 7a                	cmp    $0x7a,%al
c0108882:	7f 11                	jg     c0108895 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0108884:	8b 45 08             	mov    0x8(%ebp),%eax
c0108887:	0f b6 00             	movzbl (%eax),%eax
c010888a:	0f be c0             	movsbl %al,%eax
c010888d:	83 e8 57             	sub    $0x57,%eax
c0108890:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108893:	eb 23                	jmp    c01088b8 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0108895:	8b 45 08             	mov    0x8(%ebp),%eax
c0108898:	0f b6 00             	movzbl (%eax),%eax
c010889b:	3c 40                	cmp    $0x40,%al
c010889d:	7e 3b                	jle    c01088da <strtol+0x136>
c010889f:	8b 45 08             	mov    0x8(%ebp),%eax
c01088a2:	0f b6 00             	movzbl (%eax),%eax
c01088a5:	3c 5a                	cmp    $0x5a,%al
c01088a7:	7f 31                	jg     c01088da <strtol+0x136>
            dig = *s - 'A' + 10;
c01088a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01088ac:	0f b6 00             	movzbl (%eax),%eax
c01088af:	0f be c0             	movsbl %al,%eax
c01088b2:	83 e8 37             	sub    $0x37,%eax
c01088b5:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c01088b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088bb:	3b 45 10             	cmp    0x10(%ebp),%eax
c01088be:	7d 19                	jge    c01088d9 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c01088c0:	ff 45 08             	incl   0x8(%ebp)
c01088c3:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01088c6:	0f af 45 10          	imul   0x10(%ebp),%eax
c01088ca:	89 c2                	mov    %eax,%edx
c01088cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01088cf:	01 d0                	add    %edx,%eax
c01088d1:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c01088d4:	e9 72 ff ff ff       	jmp    c010884b <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c01088d9:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c01088da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01088de:	74 08                	je     c01088e8 <strtol+0x144>
        *endptr = (char *) s;
c01088e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01088e3:	8b 55 08             	mov    0x8(%ebp),%edx
c01088e6:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c01088e8:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c01088ec:	74 07                	je     c01088f5 <strtol+0x151>
c01088ee:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01088f1:	f7 d8                	neg    %eax
c01088f3:	eb 03                	jmp    c01088f8 <strtol+0x154>
c01088f5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c01088f8:	c9                   	leave  
c01088f9:	c3                   	ret    

c01088fa <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c01088fa:	55                   	push   %ebp
c01088fb:	89 e5                	mov    %esp,%ebp
c01088fd:	57                   	push   %edi
c01088fe:	83 ec 24             	sub    $0x24,%esp
c0108901:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108904:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0108907:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c010890b:	8b 55 08             	mov    0x8(%ebp),%edx
c010890e:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0108911:	88 45 f7             	mov    %al,-0x9(%ebp)
c0108914:	8b 45 10             	mov    0x10(%ebp),%eax
c0108917:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c010891a:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c010891d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0108921:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0108924:	89 d7                	mov    %edx,%edi
c0108926:	f3 aa                	rep stos %al,%es:(%edi)
c0108928:	89 fa                	mov    %edi,%edx
c010892a:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c010892d:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0108930:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108933:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0108934:	83 c4 24             	add    $0x24,%esp
c0108937:	5f                   	pop    %edi
c0108938:	5d                   	pop    %ebp
c0108939:	c3                   	ret    

c010893a <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c010893a:	55                   	push   %ebp
c010893b:	89 e5                	mov    %esp,%ebp
c010893d:	57                   	push   %edi
c010893e:	56                   	push   %esi
c010893f:	53                   	push   %ebx
c0108940:	83 ec 30             	sub    $0x30,%esp
c0108943:	8b 45 08             	mov    0x8(%ebp),%eax
c0108946:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108949:	8b 45 0c             	mov    0xc(%ebp),%eax
c010894c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010894f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108952:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0108955:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108958:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010895b:	73 42                	jae    c010899f <memmove+0x65>
c010895d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108960:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108963:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108966:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108969:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010896c:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c010896f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108972:	c1 e8 02             	shr    $0x2,%eax
c0108975:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0108977:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010897a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010897d:	89 d7                	mov    %edx,%edi
c010897f:	89 c6                	mov    %eax,%esi
c0108981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108983:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0108986:	83 e1 03             	and    $0x3,%ecx
c0108989:	74 02                	je     c010898d <memmove+0x53>
c010898b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010898d:	89 f0                	mov    %esi,%eax
c010898f:	89 fa                	mov    %edi,%edx
c0108991:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0108994:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0108997:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c010899a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c010899d:	eb 36                	jmp    c01089d5 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c010899f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089a2:	8d 50 ff             	lea    -0x1(%eax),%edx
c01089a5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089a8:	01 c2                	add    %eax,%edx
c01089aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089ad:	8d 48 ff             	lea    -0x1(%eax),%ecx
c01089b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01089b3:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c01089b6:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01089b9:	89 c1                	mov    %eax,%ecx
c01089bb:	89 d8                	mov    %ebx,%eax
c01089bd:	89 d6                	mov    %edx,%esi
c01089bf:	89 c7                	mov    %eax,%edi
c01089c1:	fd                   	std    
c01089c2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c01089c4:	fc                   	cld    
c01089c5:	89 f8                	mov    %edi,%eax
c01089c7:	89 f2                	mov    %esi,%edx
c01089c9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c01089cc:	89 55 c8             	mov    %edx,-0x38(%ebp)
c01089cf:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c01089d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c01089d5:	83 c4 30             	add    $0x30,%esp
c01089d8:	5b                   	pop    %ebx
c01089d9:	5e                   	pop    %esi
c01089da:	5f                   	pop    %edi
c01089db:	5d                   	pop    %ebp
c01089dc:	c3                   	ret    

c01089dd <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c01089dd:	55                   	push   %ebp
c01089de:	89 e5                	mov    %esp,%ebp
c01089e0:	57                   	push   %edi
c01089e1:	56                   	push   %esi
c01089e2:	83 ec 20             	sub    $0x20,%esp
c01089e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01089e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01089eb:	8b 45 0c             	mov    0xc(%ebp),%eax
c01089ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01089f1:	8b 45 10             	mov    0x10(%ebp),%eax
c01089f4:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01089f7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01089fa:	c1 e8 02             	shr    $0x2,%eax
c01089fd:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c01089ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108a02:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108a05:	89 d7                	mov    %edx,%edi
c0108a07:	89 c6                	mov    %eax,%esi
c0108a09:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0108a0b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0108a0e:	83 e1 03             	and    $0x3,%ecx
c0108a11:	74 02                	je     c0108a15 <memcpy+0x38>
c0108a13:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0108a15:	89 f0                	mov    %esi,%eax
c0108a17:	89 fa                	mov    %edi,%edx
c0108a19:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0108a1c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0108a1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0108a22:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0108a25:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0108a26:	83 c4 20             	add    $0x20,%esp
c0108a29:	5e                   	pop    %esi
c0108a2a:	5f                   	pop    %edi
c0108a2b:	5d                   	pop    %ebp
c0108a2c:	c3                   	ret    

c0108a2d <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0108a2d:	55                   	push   %ebp
c0108a2e:	89 e5                	mov    %esp,%ebp
c0108a30:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0108a33:	8b 45 08             	mov    0x8(%ebp),%eax
c0108a36:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0108a39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108a3c:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0108a3f:	eb 2e                	jmp    c0108a6f <memcmp+0x42>
        if (*s1 != *s2) {
c0108a41:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108a44:	0f b6 10             	movzbl (%eax),%edx
c0108a47:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a4a:	0f b6 00             	movzbl (%eax),%eax
c0108a4d:	38 c2                	cmp    %al,%dl
c0108a4f:	74 18                	je     c0108a69 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0108a51:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0108a54:	0f b6 00             	movzbl (%eax),%eax
c0108a57:	0f b6 d0             	movzbl %al,%edx
c0108a5a:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0108a5d:	0f b6 00             	movzbl (%eax),%eax
c0108a60:	0f b6 c0             	movzbl %al,%eax
c0108a63:	29 c2                	sub    %eax,%edx
c0108a65:	89 d0                	mov    %edx,%eax
c0108a67:	eb 18                	jmp    c0108a81 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0108a69:	ff 45 fc             	incl   -0x4(%ebp)
c0108a6c:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0108a6f:	8b 45 10             	mov    0x10(%ebp),%eax
c0108a72:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108a75:	89 55 10             	mov    %edx,0x10(%ebp)
c0108a78:	85 c0                	test   %eax,%eax
c0108a7a:	75 c5                	jne    c0108a41 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0108a7c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0108a81:	c9                   	leave  
c0108a82:	c3                   	ret    

c0108a83 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0108a83:	55                   	push   %ebp
c0108a84:	89 e5                	mov    %esp,%ebp
c0108a86:	83 ec 58             	sub    $0x58,%esp
c0108a89:	8b 45 10             	mov    0x10(%ebp),%eax
c0108a8c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0108a8f:	8b 45 14             	mov    0x14(%ebp),%eax
c0108a92:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0108a95:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0108a98:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0108a9b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108a9e:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0108aa1:	8b 45 18             	mov    0x18(%ebp),%eax
c0108aa4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0108aa7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108aaa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108aad:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108ab0:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0108ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ab6:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0108ab9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0108abd:	74 1c                	je     c0108adb <printnum+0x58>
c0108abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ac2:	ba 00 00 00 00       	mov    $0x0,%edx
c0108ac7:	f7 75 e4             	divl   -0x1c(%ebp)
c0108aca:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0108acd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ad0:	ba 00 00 00 00       	mov    $0x0,%edx
c0108ad5:	f7 75 e4             	divl   -0x1c(%ebp)
c0108ad8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108adb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108ade:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ae1:	f7 75 e4             	divl   -0x1c(%ebp)
c0108ae4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0108ae7:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0108aea:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108aed:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0108af0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108af3:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0108af6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108af9:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0108afc:	8b 45 18             	mov    0x18(%ebp),%eax
c0108aff:	ba 00 00 00 00       	mov    $0x0,%edx
c0108b04:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108b07:	77 56                	ja     c0108b5f <printnum+0xdc>
c0108b09:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0108b0c:	72 05                	jb     c0108b13 <printnum+0x90>
c0108b0e:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0108b11:	77 4c                	ja     c0108b5f <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0108b13:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0108b16:	8d 50 ff             	lea    -0x1(%eax),%edx
c0108b19:	8b 45 20             	mov    0x20(%ebp),%eax
c0108b1c:	89 44 24 18          	mov    %eax,0x18(%esp)
c0108b20:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108b24:	8b 45 18             	mov    0x18(%ebp),%eax
c0108b27:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108b2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0108b2e:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0108b31:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108b35:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108b39:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b3c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b40:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b43:	89 04 24             	mov    %eax,(%esp)
c0108b46:	e8 38 ff ff ff       	call   c0108a83 <printnum>
c0108b4b:	eb 1b                	jmp    c0108b68 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0108b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108b50:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108b54:	8b 45 20             	mov    0x20(%ebp),%eax
c0108b57:	89 04 24             	mov    %eax,(%esp)
c0108b5a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b5d:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0108b5f:	ff 4d 1c             	decl   0x1c(%ebp)
c0108b62:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0108b66:	7f e5                	jg     c0108b4d <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0108b68:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0108b6b:	05 3c b2 10 c0       	add    $0xc010b23c,%eax
c0108b70:	0f b6 00             	movzbl (%eax),%eax
c0108b73:	0f be c0             	movsbl %al,%eax
c0108b76:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108b79:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108b7d:	89 04 24             	mov    %eax,(%esp)
c0108b80:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b83:	ff d0                	call   *%eax
}
c0108b85:	90                   	nop
c0108b86:	c9                   	leave  
c0108b87:	c3                   	ret    

c0108b88 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0108b88:	55                   	push   %ebp
c0108b89:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108b8b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108b8f:	7e 14                	jle    c0108ba5 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0108b91:	8b 45 08             	mov    0x8(%ebp),%eax
c0108b94:	8b 00                	mov    (%eax),%eax
c0108b96:	8d 48 08             	lea    0x8(%eax),%ecx
c0108b99:	8b 55 08             	mov    0x8(%ebp),%edx
c0108b9c:	89 0a                	mov    %ecx,(%edx)
c0108b9e:	8b 50 04             	mov    0x4(%eax),%edx
c0108ba1:	8b 00                	mov    (%eax),%eax
c0108ba3:	eb 30                	jmp    c0108bd5 <getuint+0x4d>
    }
    else if (lflag) {
c0108ba5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108ba9:	74 16                	je     c0108bc1 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0108bab:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bae:	8b 00                	mov    (%eax),%eax
c0108bb0:	8d 48 04             	lea    0x4(%eax),%ecx
c0108bb3:	8b 55 08             	mov    0x8(%ebp),%edx
c0108bb6:	89 0a                	mov    %ecx,(%edx)
c0108bb8:	8b 00                	mov    (%eax),%eax
c0108bba:	ba 00 00 00 00       	mov    $0x0,%edx
c0108bbf:	eb 14                	jmp    c0108bd5 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0108bc1:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bc4:	8b 00                	mov    (%eax),%eax
c0108bc6:	8d 48 04             	lea    0x4(%eax),%ecx
c0108bc9:	8b 55 08             	mov    0x8(%ebp),%edx
c0108bcc:	89 0a                	mov    %ecx,(%edx)
c0108bce:	8b 00                	mov    (%eax),%eax
c0108bd0:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0108bd5:	5d                   	pop    %ebp
c0108bd6:	c3                   	ret    

c0108bd7 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0108bd7:	55                   	push   %ebp
c0108bd8:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0108bda:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0108bde:	7e 14                	jle    c0108bf4 <getint+0x1d>
        return va_arg(*ap, long long);
c0108be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0108be3:	8b 00                	mov    (%eax),%eax
c0108be5:	8d 48 08             	lea    0x8(%eax),%ecx
c0108be8:	8b 55 08             	mov    0x8(%ebp),%edx
c0108beb:	89 0a                	mov    %ecx,(%edx)
c0108bed:	8b 50 04             	mov    0x4(%eax),%edx
c0108bf0:	8b 00                	mov    (%eax),%eax
c0108bf2:	eb 28                	jmp    c0108c1c <getint+0x45>
    }
    else if (lflag) {
c0108bf4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0108bf8:	74 12                	je     c0108c0c <getint+0x35>
        return va_arg(*ap, long);
c0108bfa:	8b 45 08             	mov    0x8(%ebp),%eax
c0108bfd:	8b 00                	mov    (%eax),%eax
c0108bff:	8d 48 04             	lea    0x4(%eax),%ecx
c0108c02:	8b 55 08             	mov    0x8(%ebp),%edx
c0108c05:	89 0a                	mov    %ecx,(%edx)
c0108c07:	8b 00                	mov    (%eax),%eax
c0108c09:	99                   	cltd   
c0108c0a:	eb 10                	jmp    c0108c1c <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0108c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c0f:	8b 00                	mov    (%eax),%eax
c0108c11:	8d 48 04             	lea    0x4(%eax),%ecx
c0108c14:	8b 55 08             	mov    0x8(%ebp),%edx
c0108c17:	89 0a                	mov    %ecx,(%edx)
c0108c19:	8b 00                	mov    (%eax),%eax
c0108c1b:	99                   	cltd   
    }
}
c0108c1c:	5d                   	pop    %ebp
c0108c1d:	c3                   	ret    

c0108c1e <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0108c1e:	55                   	push   %ebp
c0108c1f:	89 e5                	mov    %esp,%ebp
c0108c21:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0108c24:	8d 45 14             	lea    0x14(%ebp),%eax
c0108c27:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0108c2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0108c2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0108c31:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c34:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108c38:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c3b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c3f:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c42:	89 04 24             	mov    %eax,(%esp)
c0108c45:	e8 03 00 00 00       	call   c0108c4d <vprintfmt>
    va_end(ap);
}
c0108c4a:	90                   	nop
c0108c4b:	c9                   	leave  
c0108c4c:	c3                   	ret    

c0108c4d <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0108c4d:	55                   	push   %ebp
c0108c4e:	89 e5                	mov    %esp,%ebp
c0108c50:	56                   	push   %esi
c0108c51:	53                   	push   %ebx
c0108c52:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108c55:	eb 17                	jmp    c0108c6e <vprintfmt+0x21>
            if (ch == '\0') {
c0108c57:	85 db                	test   %ebx,%ebx
c0108c59:	0f 84 bf 03 00 00    	je     c010901e <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0108c5f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108c62:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108c66:	89 1c 24             	mov    %ebx,(%esp)
c0108c69:	8b 45 08             	mov    0x8(%ebp),%eax
c0108c6c:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0108c6e:	8b 45 10             	mov    0x10(%ebp),%eax
c0108c71:	8d 50 01             	lea    0x1(%eax),%edx
c0108c74:	89 55 10             	mov    %edx,0x10(%ebp)
c0108c77:	0f b6 00             	movzbl (%eax),%eax
c0108c7a:	0f b6 d8             	movzbl %al,%ebx
c0108c7d:	83 fb 25             	cmp    $0x25,%ebx
c0108c80:	75 d5                	jne    c0108c57 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0108c82:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0108c86:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c0108c8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108c90:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0108c93:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0108c9a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0108c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0108ca0:	8b 45 10             	mov    0x10(%ebp),%eax
c0108ca3:	8d 50 01             	lea    0x1(%eax),%edx
c0108ca6:	89 55 10             	mov    %edx,0x10(%ebp)
c0108ca9:	0f b6 00             	movzbl (%eax),%eax
c0108cac:	0f b6 d8             	movzbl %al,%ebx
c0108caf:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0108cb2:	83 f8 55             	cmp    $0x55,%eax
c0108cb5:	0f 87 37 03 00 00    	ja     c0108ff2 <vprintfmt+0x3a5>
c0108cbb:	8b 04 85 60 b2 10 c0 	mov    -0x3fef4da0(,%eax,4),%eax
c0108cc2:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0108cc4:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0108cc8:	eb d6                	jmp    c0108ca0 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0108cca:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c0108cce:	eb d0                	jmp    c0108ca0 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108cd0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0108cd7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0108cda:	89 d0                	mov    %edx,%eax
c0108cdc:	c1 e0 02             	shl    $0x2,%eax
c0108cdf:	01 d0                	add    %edx,%eax
c0108ce1:	01 c0                	add    %eax,%eax
c0108ce3:	01 d8                	add    %ebx,%eax
c0108ce5:	83 e8 30             	sub    $0x30,%eax
c0108ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c0108ceb:	8b 45 10             	mov    0x10(%ebp),%eax
c0108cee:	0f b6 00             	movzbl (%eax),%eax
c0108cf1:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0108cf4:	83 fb 2f             	cmp    $0x2f,%ebx
c0108cf7:	7e 38                	jle    c0108d31 <vprintfmt+0xe4>
c0108cf9:	83 fb 39             	cmp    $0x39,%ebx
c0108cfc:	7f 33                	jg     c0108d31 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0108cfe:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0108d01:	eb d4                	jmp    c0108cd7 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0108d03:	8b 45 14             	mov    0x14(%ebp),%eax
c0108d06:	8d 50 04             	lea    0x4(%eax),%edx
c0108d09:	89 55 14             	mov    %edx,0x14(%ebp)
c0108d0c:	8b 00                	mov    (%eax),%eax
c0108d0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0108d11:	eb 1f                	jmp    c0108d32 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0108d13:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108d17:	79 87                	jns    c0108ca0 <vprintfmt+0x53>
                width = 0;
c0108d19:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c0108d20:	e9 7b ff ff ff       	jmp    c0108ca0 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0108d25:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c0108d2c:	e9 6f ff ff ff       	jmp    c0108ca0 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c0108d31:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c0108d32:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108d36:	0f 89 64 ff ff ff    	jns    c0108ca0 <vprintfmt+0x53>
                width = precision, precision = -1;
c0108d3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108d3f:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108d42:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0108d49:	e9 52 ff ff ff       	jmp    c0108ca0 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c0108d4e:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c0108d51:	e9 4a ff ff ff       	jmp    c0108ca0 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c0108d56:	8b 45 14             	mov    0x14(%ebp),%eax
c0108d59:	8d 50 04             	lea    0x4(%eax),%edx
c0108d5c:	89 55 14             	mov    %edx,0x14(%ebp)
c0108d5f:	8b 00                	mov    (%eax),%eax
c0108d61:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108d64:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108d68:	89 04 24             	mov    %eax,(%esp)
c0108d6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0108d6e:	ff d0                	call   *%eax
            break;
c0108d70:	e9 a4 02 00 00       	jmp    c0109019 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c0108d75:	8b 45 14             	mov    0x14(%ebp),%eax
c0108d78:	8d 50 04             	lea    0x4(%eax),%edx
c0108d7b:	89 55 14             	mov    %edx,0x14(%ebp)
c0108d7e:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0108d80:	85 db                	test   %ebx,%ebx
c0108d82:	79 02                	jns    c0108d86 <vprintfmt+0x139>
                err = -err;
c0108d84:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0108d86:	83 fb 06             	cmp    $0x6,%ebx
c0108d89:	7f 0b                	jg     c0108d96 <vprintfmt+0x149>
c0108d8b:	8b 34 9d 20 b2 10 c0 	mov    -0x3fef4de0(,%ebx,4),%esi
c0108d92:	85 f6                	test   %esi,%esi
c0108d94:	75 23                	jne    c0108db9 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0108d96:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0108d9a:	c7 44 24 08 4d b2 10 	movl   $0xc010b24d,0x8(%esp)
c0108da1:	c0 
c0108da2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108da5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dac:	89 04 24             	mov    %eax,(%esp)
c0108daf:	e8 6a fe ff ff       	call   c0108c1e <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0108db4:	e9 60 02 00 00       	jmp    c0109019 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c0108db9:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0108dbd:	c7 44 24 08 56 b2 10 	movl   $0xc010b256,0x8(%esp)
c0108dc4:	c0 
c0108dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108dc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108dcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0108dcf:	89 04 24             	mov    %eax,(%esp)
c0108dd2:	e8 47 fe ff ff       	call   c0108c1e <printfmt>
            }
            break;
c0108dd7:	e9 3d 02 00 00       	jmp    c0109019 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0108ddc:	8b 45 14             	mov    0x14(%ebp),%eax
c0108ddf:	8d 50 04             	lea    0x4(%eax),%edx
c0108de2:	89 55 14             	mov    %edx,0x14(%ebp)
c0108de5:	8b 30                	mov    (%eax),%esi
c0108de7:	85 f6                	test   %esi,%esi
c0108de9:	75 05                	jne    c0108df0 <vprintfmt+0x1a3>
                p = "(null)";
c0108deb:	be 59 b2 10 c0       	mov    $0xc010b259,%esi
            }
            if (width > 0 && padc != '-') {
c0108df0:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108df4:	7e 76                	jle    c0108e6c <vprintfmt+0x21f>
c0108df6:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0108dfa:	74 70                	je     c0108e6c <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108dfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0108dff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e03:	89 34 24             	mov    %esi,(%esp)
c0108e06:	e8 f6 f7 ff ff       	call   c0108601 <strnlen>
c0108e0b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108e0e:	29 c2                	sub    %eax,%edx
c0108e10:	89 d0                	mov    %edx,%eax
c0108e12:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0108e15:	eb 16                	jmp    c0108e2d <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0108e17:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0108e1b:	8b 55 0c             	mov    0xc(%ebp),%edx
c0108e1e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0108e22:	89 04 24             	mov    %eax,(%esp)
c0108e25:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e28:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c0108e2a:	ff 4d e8             	decl   -0x18(%ebp)
c0108e2d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108e31:	7f e4                	jg     c0108e17 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108e33:	eb 37                	jmp    c0108e6c <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0108e35:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0108e39:	74 1f                	je     c0108e5a <vprintfmt+0x20d>
c0108e3b:	83 fb 1f             	cmp    $0x1f,%ebx
c0108e3e:	7e 05                	jle    c0108e45 <vprintfmt+0x1f8>
c0108e40:	83 fb 7e             	cmp    $0x7e,%ebx
c0108e43:	7e 15                	jle    c0108e5a <vprintfmt+0x20d>
                    putch('?', putdat);
c0108e45:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e48:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e4c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0108e53:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e56:	ff d0                	call   *%eax
c0108e58:	eb 0f                	jmp    c0108e69 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0108e5a:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e5d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e61:	89 1c 24             	mov    %ebx,(%esp)
c0108e64:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e67:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0108e69:	ff 4d e8             	decl   -0x18(%ebp)
c0108e6c:	89 f0                	mov    %esi,%eax
c0108e6e:	8d 70 01             	lea    0x1(%eax),%esi
c0108e71:	0f b6 00             	movzbl (%eax),%eax
c0108e74:	0f be d8             	movsbl %al,%ebx
c0108e77:	85 db                	test   %ebx,%ebx
c0108e79:	74 27                	je     c0108ea2 <vprintfmt+0x255>
c0108e7b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108e7f:	78 b4                	js     c0108e35 <vprintfmt+0x1e8>
c0108e81:	ff 4d e4             	decl   -0x1c(%ebp)
c0108e84:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0108e88:	79 ab                	jns    c0108e35 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108e8a:	eb 16                	jmp    c0108ea2 <vprintfmt+0x255>
                putch(' ', putdat);
c0108e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108e8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108e93:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0108e9a:	8b 45 08             	mov    0x8(%ebp),%eax
c0108e9d:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0108e9f:	ff 4d e8             	decl   -0x18(%ebp)
c0108ea2:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0108ea6:	7f e4                	jg     c0108e8c <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0108ea8:	e9 6c 01 00 00       	jmp    c0109019 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0108ead:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108eb0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108eb4:	8d 45 14             	lea    0x14(%ebp),%eax
c0108eb7:	89 04 24             	mov    %eax,(%esp)
c0108eba:	e8 18 fd ff ff       	call   c0108bd7 <getint>
c0108ebf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ec2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0108ec5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ec8:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ecb:	85 d2                	test   %edx,%edx
c0108ecd:	79 26                	jns    c0108ef5 <vprintfmt+0x2a8>
                putch('-', putdat);
c0108ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ed2:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ed6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0108edd:	8b 45 08             	mov    0x8(%ebp),%eax
c0108ee0:	ff d0                	call   *%eax
                num = -(long long)num;
c0108ee2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108ee5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108ee8:	f7 d8                	neg    %eax
c0108eea:	83 d2 00             	adc    $0x0,%edx
c0108eed:	f7 da                	neg    %edx
c0108eef:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108ef2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0108ef5:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108efc:	e9 a8 00 00 00       	jmp    c0108fa9 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0108f01:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f04:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f08:	8d 45 14             	lea    0x14(%ebp),%eax
c0108f0b:	89 04 24             	mov    %eax,(%esp)
c0108f0e:	e8 75 fc ff ff       	call   c0108b88 <getuint>
c0108f13:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f16:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0108f19:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0108f20:	e9 84 00 00 00       	jmp    c0108fa9 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0108f25:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f28:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f2c:	8d 45 14             	lea    0x14(%ebp),%eax
c0108f2f:	89 04 24             	mov    %eax,(%esp)
c0108f32:	e8 51 fc ff ff       	call   c0108b88 <getuint>
c0108f37:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f3a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0108f3d:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0108f44:	eb 63                	jmp    c0108fa9 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0108f46:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f49:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f4d:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0108f54:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f57:	ff d0                	call   *%eax
            putch('x', putdat);
c0108f59:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108f5c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f60:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0108f67:	8b 45 08             	mov    0x8(%ebp),%eax
c0108f6a:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0108f6c:	8b 45 14             	mov    0x14(%ebp),%eax
c0108f6f:	8d 50 04             	lea    0x4(%eax),%edx
c0108f72:	89 55 14             	mov    %edx,0x14(%ebp)
c0108f75:	8b 00                	mov    (%eax),%eax
c0108f77:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f7a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0108f81:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0108f88:	eb 1f                	jmp    c0108fa9 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0108f8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0108f8d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108f91:	8d 45 14             	lea    0x14(%ebp),%eax
c0108f94:	89 04 24             	mov    %eax,(%esp)
c0108f97:	e8 ec fb ff ff       	call   c0108b88 <getuint>
c0108f9c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0108f9f:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0108fa2:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0108fa9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0108fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0108fb0:	89 54 24 18          	mov    %edx,0x18(%esp)
c0108fb4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0108fb7:	89 54 24 14          	mov    %edx,0x14(%esp)
c0108fbb:	89 44 24 10          	mov    %eax,0x10(%esp)
c0108fbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0108fc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0108fc5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0108fc9:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0108fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fd7:	89 04 24             	mov    %eax,(%esp)
c0108fda:	e8 a4 fa ff ff       	call   c0108a83 <printnum>
            break;
c0108fdf:	eb 38                	jmp    c0109019 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0108fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108fe4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108fe8:	89 1c 24             	mov    %ebx,(%esp)
c0108feb:	8b 45 08             	mov    0x8(%ebp),%eax
c0108fee:	ff d0                	call   *%eax
            break;
c0108ff0:	eb 27                	jmp    c0109019 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0108ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
c0108ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0108ff9:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0109000:	8b 45 08             	mov    0x8(%ebp),%eax
c0109003:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0109005:	ff 4d 10             	decl   0x10(%ebp)
c0109008:	eb 03                	jmp    c010900d <vprintfmt+0x3c0>
c010900a:	ff 4d 10             	decl   0x10(%ebp)
c010900d:	8b 45 10             	mov    0x10(%ebp),%eax
c0109010:	48                   	dec    %eax
c0109011:	0f b6 00             	movzbl (%eax),%eax
c0109014:	3c 25                	cmp    $0x25,%al
c0109016:	75 f2                	jne    c010900a <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0109018:	90                   	nop
        }
    }
c0109019:	e9 37 fc ff ff       	jmp    c0108c55 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c010901e:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c010901f:	83 c4 40             	add    $0x40,%esp
c0109022:	5b                   	pop    %ebx
c0109023:	5e                   	pop    %esi
c0109024:	5d                   	pop    %ebp
c0109025:	c3                   	ret    

c0109026 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0109026:	55                   	push   %ebp
c0109027:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0109029:	8b 45 0c             	mov    0xc(%ebp),%eax
c010902c:	8b 40 08             	mov    0x8(%eax),%eax
c010902f:	8d 50 01             	lea    0x1(%eax),%edx
c0109032:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109035:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0109038:	8b 45 0c             	mov    0xc(%ebp),%eax
c010903b:	8b 10                	mov    (%eax),%edx
c010903d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109040:	8b 40 04             	mov    0x4(%eax),%eax
c0109043:	39 c2                	cmp    %eax,%edx
c0109045:	73 12                	jae    c0109059 <sprintputch+0x33>
        *b->buf ++ = ch;
c0109047:	8b 45 0c             	mov    0xc(%ebp),%eax
c010904a:	8b 00                	mov    (%eax),%eax
c010904c:	8d 48 01             	lea    0x1(%eax),%ecx
c010904f:	8b 55 0c             	mov    0xc(%ebp),%edx
c0109052:	89 0a                	mov    %ecx,(%edx)
c0109054:	8b 55 08             	mov    0x8(%ebp),%edx
c0109057:	88 10                	mov    %dl,(%eax)
    }
}
c0109059:	90                   	nop
c010905a:	5d                   	pop    %ebp
c010905b:	c3                   	ret    

c010905c <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c010905c:	55                   	push   %ebp
c010905d:	89 e5                	mov    %esp,%ebp
c010905f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0109062:	8d 45 14             	lea    0x14(%ebp),%eax
c0109065:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0109068:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010906b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010906f:	8b 45 10             	mov    0x10(%ebp),%eax
c0109072:	89 44 24 08          	mov    %eax,0x8(%esp)
c0109076:	8b 45 0c             	mov    0xc(%ebp),%eax
c0109079:	89 44 24 04          	mov    %eax,0x4(%esp)
c010907d:	8b 45 08             	mov    0x8(%ebp),%eax
c0109080:	89 04 24             	mov    %eax,(%esp)
c0109083:	e8 08 00 00 00       	call   c0109090 <vsnprintf>
c0109088:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010908b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010908e:	c9                   	leave  
c010908f:	c3                   	ret    

c0109090 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0109090:	55                   	push   %ebp
c0109091:	89 e5                	mov    %esp,%ebp
c0109093:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0109096:	8b 45 08             	mov    0x8(%ebp),%eax
c0109099:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010909c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010909f:	8d 50 ff             	lea    -0x1(%eax),%edx
c01090a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01090a5:	01 d0                	add    %edx,%eax
c01090a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01090aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c01090b1:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01090b5:	74 0a                	je     c01090c1 <vsnprintf+0x31>
c01090b7:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01090ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01090bd:	39 c2                	cmp    %eax,%edx
c01090bf:	76 07                	jbe    c01090c8 <vsnprintf+0x38>
        return -E_INVAL;
c01090c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c01090c6:	eb 2a                	jmp    c01090f2 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c01090c8:	8b 45 14             	mov    0x14(%ebp),%eax
c01090cb:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01090cf:	8b 45 10             	mov    0x10(%ebp),%eax
c01090d2:	89 44 24 08          	mov    %eax,0x8(%esp)
c01090d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
c01090d9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01090dd:	c7 04 24 26 90 10 c0 	movl   $0xc0109026,(%esp)
c01090e4:	e8 64 fb ff ff       	call   c0108c4d <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c01090e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01090ec:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c01090ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01090f2:	c9                   	leave  
c01090f3:	c3                   	ret    

c01090f4 <rand>:
 * rand - returns a pseudo-random integer
 *
 * The rand() function return a value in the range [0, RAND_MAX].
 * */
int
rand(void) {
c01090f4:	55                   	push   %ebp
c01090f5:	89 e5                	mov    %esp,%ebp
c01090f7:	57                   	push   %edi
c01090f8:	56                   	push   %esi
c01090f9:	53                   	push   %ebx
c01090fa:	83 ec 24             	sub    $0x24,%esp
    next = (next * 0x5DEECE66DLL + 0xBLL) & ((1LL << 48) - 1);
c01090fd:	a1 80 1a 12 c0       	mov    0xc0121a80,%eax
c0109102:	8b 15 84 1a 12 c0    	mov    0xc0121a84,%edx
c0109108:	69 fa 6d e6 ec de    	imul   $0xdeece66d,%edx,%edi
c010910e:	6b f0 05             	imul   $0x5,%eax,%esi
c0109111:	01 fe                	add    %edi,%esi
c0109113:	bf 6d e6 ec de       	mov    $0xdeece66d,%edi
c0109118:	f7 e7                	mul    %edi
c010911a:	01 d6                	add    %edx,%esi
c010911c:	89 f2                	mov    %esi,%edx
c010911e:	83 c0 0b             	add    $0xb,%eax
c0109121:	83 d2 00             	adc    $0x0,%edx
c0109124:	89 c7                	mov    %eax,%edi
c0109126:	83 e7 ff             	and    $0xffffffff,%edi
c0109129:	89 f9                	mov    %edi,%ecx
c010912b:	0f b7 da             	movzwl %dx,%ebx
c010912e:	89 0d 80 1a 12 c0    	mov    %ecx,0xc0121a80
c0109134:	89 1d 84 1a 12 c0    	mov    %ebx,0xc0121a84
    unsigned long long result = (next >> 12);
c010913a:	a1 80 1a 12 c0       	mov    0xc0121a80,%eax
c010913f:	8b 15 84 1a 12 c0    	mov    0xc0121a84,%edx
c0109145:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0109149:	c1 ea 0c             	shr    $0xc,%edx
c010914c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010914f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return (int)do_div(result, RAND_MAX + 1);
c0109152:	c7 45 dc 00 00 00 80 	movl   $0x80000000,-0x24(%ebp)
c0109159:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010915c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010915f:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109162:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0109165:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109168:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010916b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010916f:	74 1c                	je     c010918d <rand+0x99>
c0109171:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109174:	ba 00 00 00 00       	mov    $0x0,%edx
c0109179:	f7 75 dc             	divl   -0x24(%ebp)
c010917c:	89 55 ec             	mov    %edx,-0x14(%ebp)
c010917f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0109182:	ba 00 00 00 00       	mov    $0x0,%edx
c0109187:	f7 75 dc             	divl   -0x24(%ebp)
c010918a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010918d:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0109190:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0109193:	f7 75 dc             	divl   -0x24(%ebp)
c0109196:	89 45 d8             	mov    %eax,-0x28(%ebp)
c0109199:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010919c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010919f:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01091a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01091a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c01091a8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
}
c01091ab:	83 c4 24             	add    $0x24,%esp
c01091ae:	5b                   	pop    %ebx
c01091af:	5e                   	pop    %esi
c01091b0:	5f                   	pop    %edi
c01091b1:	5d                   	pop    %ebp
c01091b2:	c3                   	ret    

c01091b3 <srand>:
/* *
 * srand - seed the random number generator with the given number
 * @seed:   the required seed number
 * */
void
srand(unsigned int seed) {
c01091b3:	55                   	push   %ebp
c01091b4:	89 e5                	mov    %esp,%ebp
    next = seed;
c01091b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01091b9:	ba 00 00 00 00       	mov    $0x0,%edx
c01091be:	a3 80 1a 12 c0       	mov    %eax,0xc0121a80
c01091c3:	89 15 84 1a 12 c0    	mov    %edx,0xc0121a84
}
c01091c9:	90                   	nop
c01091ca:	5d                   	pop    %ebp
c01091cb:	c3                   	ret    
