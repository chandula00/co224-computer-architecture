loadi 4 0x05   // r4 = 5
loadi 1 0x09   // r1 = 9
bne 4 4 1       // offset 4 if r4 != r1




mov 2 1        // r2 = r1           (9)
add 3 2 4      // r3 = r2 + r0      (14)
sub 4 3 1      // r4 = r3 - r1      (5)
mult 5 1 2      // r5 = r1 * r2     (81)
loadi 1 0x92   // r1 = 0x92         (92)
srl 6 1 0x02    // r6 = r1>>2       (23)
sll 7 6 0x03    // r7 = r6<<3       (184)
sra 8 7 0x02    // r8 = r7>>2(signed)(142)
ror 9 8 0x02    // rotate right     (163)
and 5 1 4      // r5 = r1 & r4      (12)
or 6 5 2       // r6 = r5 | r2      (13)
