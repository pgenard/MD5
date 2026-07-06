module md5(input clk,
           input nrst,
           input start,
           input enc,
           output eoc,
           input[511:0] message, 
	   input[31:0] length, 
           output[127:0] hash);

reg[31:0] s[64];
reg[31:0] K[64];

reg[31:0] a0, b0, c0, d0;
reg[31:0] A, B, C, D;

reg[31:0] F, g, tmp;

reg[7:0] digest[16];
reg[6:0] round = 0;

reg[511:0] m;

// Rotate Left function
function [31:0] RL (input[31:0] value, shift);
begin
  return ((value) << shift) | ((value) >> (32 - shift));
end 
endfunction
  
initial begin

a0 = 32'h67452301;
b0 = 32'hefcdab89;
c0 = 32'h98badcfe; 
d0 = 32'h10325476;

s[0] = 32'd7; s[1] = 32'd12; s[2] = 32'd17; s[3] = 32'd22;
s[4] = 32'd7; s[5] = 32'd12; s[6] = 32'd17; s[7] = 32'd22;
s[8] = 32'd7; s[9] = 32'd12; s[10] = 32'd17; s[11] = 32'd22;
s[12] = 32'd7; s[13] = 32'd12; s[14] = 32'd17; s[15] = 32'd22;

s[16] = 32'd5; s[17] = 32'd9; s[18] = 32'd14; s[19] = 32'd20;
s[20] = 32'd5; s[21] = 32'd9; s[22] = 32'd14; s[23] = 32'd20;
s[24] = 32'd5; s[25] = 32'd9; s[26] = 32'd14; s[27] = 32'd20;
s[28] = 32'd5; s[29] = 32'd9; s[30] = 32'd14; s[31] = 32'd20;

s[32] = 32'd4; s[33] = 32'd11; s[34] = 32'd16; s[35] = 32'd23;
s[36] = 32'd4; s[37] = 32'd11; s[38] = 32'd16; s[39] = 32'd23;
s[40] = 32'd4; s[41] = 32'd11; s[42] = 32'd16; s[43] = 32'd23;
s[44] = 32'd4; s[45] = 32'd11; s[46] = 32'd16; s[47] = 32'd23;

s[48] = 32'd6; s[49] = 32'd10; s[50] = 32'd15; s[51] = 32'd21;
s[52] = 32'd6; s[53] = 32'd10; s[54] = 32'd15; s[55] = 32'd21;
s[56] = 32'd6; s[57] = 32'd10; s[58] = 32'd15; s[59] = 32'd21;
s[60] = 32'd6; s[61] = 32'd10; s[62] = 32'd15; s[63] = 32'd21;

K[0] = 32'hd76aa478; K[1] = 32'he8c7b756; K[2] = 32'h242070db; K[3] = 32'hc1bdceee;
K[4] = 32'hf57c0faf; K[5] = 32'h4787c62a; K[6] = 32'ha8304613; K[7] = 32'hfd469501;
K[8] = 32'h698098d8; K[9] = 32'h8b44f7af; K[10] = 32'hffff5bb1; K[11] = 32'h895cd7be;
K[12] = 32'h6b901122; K[13] = 32'hfd987193; K[14] = 32'ha679438e; K[15] = 32'h49b40821;

K[16] = 32'hf61e2562; K[17] = 32'hc040b340; K[18] = 32'h265e5a51; K[19] = 32'he9b6c7aa;
K[20] = 32'hd62f105d; K[21] = 32'h02441453; K[22] = 32'hd8a1e681; K[23] = 32'he7d3fbc8;
K[24] = 32'h21e1cde6; K[25] = 32'hc33707d6; K[26] = 32'hf4d50d87; K[27] = 32'h455a14ed;
K[28] = 32'ha9e3e905; K[29] = 32'hfcefa3f8; K[30] = 32'h676f02d9; K[31] = 32'h8d2a4c8a;

K[32] = 32'hfffa3942; K[33] = 32'h8771f681; K[34] = 32'h6d9d6122; K[35] = 32'hfde5380c;
K[36] = 32'ha4beea44; K[37] = 32'h4bdecfa9; K[38] = 32'hf6bb4b60; K[39] = 32'hbebfbc70;
K[40] = 32'h289b7ec6; K[41] = 32'heaa127fa; K[42] = 32'hd4ef3085; K[43] = 32'h04881d05;
K[44] = 32'hd9d4d039; K[45] = 32'he6db99e5; K[46] = 32'h1fa27cf8; K[47] = 32'hc4ac5665;

K[48] = 32'hf4292244; K[49] = 32'h432aff97; K[50] = 32'hab9423a7; K[51] = 32'hfc93a039;
K[52] = 32'h655b59c3; K[53] = 32'h8f0ccc92; K[54] = 32'hffeff47d; K[55] = 32'h85845dd1;
K[56] = 32'h6fa87e4f; K[57] = 32'hfe2ce6e0; K[58] = 32'ha3014314; K[59] = 32'h4e0811a1;
K[60] = 32'hf7537e82; K[61] = 32'hbd3af235; K[62] = 32'h2ad7d2bb; K[63] = 32'heb86d391;

A = a0; B = b0; C = c0; D = d0;

m = message;

end // initial begin

always @(posedge clk) begin
  if (start) 
    begin
      round <= 7'b0;

      m = {72'h0, message[439:0]};

      if ((length % 32'd8) == 0) begin
        m[length + 7] = 1;
      end

      m[479:448] = length; // m[451] = 1; for "a"

      F = 0; g = 0;
    end
  else begin
    if (round < 7'd64)
      begin
	if (round <= 15) begin
          F = ((B & C) | ((~B) & D)); 
          g = 32'(round);
	end
	else begin
	  if (round <= 31) begin
             F = (D & B) | ((~D) & C);
             g = ((5 * round) + 1) % 32'd16; 
	  end
	  else begin
	    if (round <= 47) begin
               F = B ^ C ^ D;
	       g = ((3 * round) + 5) % 32'd16;      
	    end
	    else begin
	      if (round <= 63) begin
                F = C ^ (B | (~D));
                g = (7 * round) % 32'd16; 
	      end
	      else begin end
	    end
	  end
        end

        tmp = D; D = C; C = B;

	case (g)
	  0: begin B = RL((A + F + K[round[5:0]] + m[31:0]), s[round[5:0]]) + B; end
	  1: begin B = RL((A + F + K[round[5:0]] + m[63:32]), s[round[5:0]]) + B; end
	  2: begin B = RL((A + F + K[round[5:0]] + m[95:64]), s[round[5:0]]) + B; end
	  3: begin B = RL((A + F + K[round[5:0]] + m[127:96]), s[round[5:0]]) + B; end
	  4: begin B = RL((A + F + K[round[5:0]] + m[159:128]), s[round[5:0]]) + B; end
	  5: begin B = RL((A + F + K[round[5:0]] + m[191:160]), s[round[5:0]]) + B; end
	  6: begin B = RL((A + F + K[round[5:0]] + m[223:192]), s[round[5:0]]) + B; end
	  7: begin B = RL((A + F + K[round[5:0]] + m[255:224]), s[round[5:0]]) + B; end
          8: begin B = RL((A + F + K[round[5:0]] + m[287:256]), s[round[5:0]]) + B; end
          9: begin B = RL((A + F + K[round[5:0]] + m[319:288]), s[round[5:0]]) + B; end
          10: begin B = RL((A + F + K[round[5:0]] + m[351:320]), s[round[5:0]]) + B; end
	  11: begin B = RL((A + F + K[round[5:0]] + m[383:352]), s[round[5:0]]) + B; end
	  12: begin B = RL((A + F + K[round[5:0]] + m[415:384]), s[round[5:0]]) + B; end
          13: begin B = RL((A + F + K[round[5:0]] + m[447:416]), s[round[5:0]]) + B; end
          14: begin B = RL((A + F + K[round[5:0]] + m[479:448]), s[round[5:0]]) + B; end
          15: begin B = RL((A + F + K[round[5:0]] + m[511:480]), s[round[5:0]]) + B; end
          default: begin end
	endcase // case (g)

	A = tmp; 
        round <= round + 1'b1;
      end
    else
      begin
	if (round == 64) begin
	  a0 = a0 + A;
	  b0 = b0 + B;
	  c0 = c0 + C;
	  d0 = d0 + D;

	  digest[15] = a0[7:0]; digest[14] = a0[15:8]; digest[13] = a0[23:16]; digest[12] = a0[31:24];
          digest[11] = b0[7:0]; digest[10] = b0[15:8]; digest[9] = b0[23:16]; digest[8] = b0[31:24];	   
          digest[7] = c0[7:0]; digest[6] = c0[15:8]; digest[5] = c0[23:16]; digest[4] = c0[31:24];
          digest[3] = d0[7:0]; digest[2] = d0[15:8]; digest[1] = d0[23:16]; digest[0] = d0[31:24];

	  round <= round + 1'b1;
	end
	else begin end
      end
    end // else: !if(start)
end

assign hash = {digest[15], digest[14], digest[13], digest[12], digest[11], digest[10], digest[9], digest[8], digest[7], digest[6], digest[5], digest[4], digest[3], digest[2], digest[1], digest[0]};

endmodule // md5

/*** Test Vectors ***/
/* 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef */ // message
/* 4fe130598d47f17c19a7c493b4ce0cf1 */ // hash
