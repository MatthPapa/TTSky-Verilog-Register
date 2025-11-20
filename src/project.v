/*
 * Tri-state output register with single R/W* control.
 * ui_in[0] = R_nW  (1 = READ: drive bus; 0 = WRITE: capture uio_in on clk)
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // [0]=R_nW
    output wire [7:0] uo_out,   // mirrors internal register
    input  wire [7:0] uio_in,   // shared data bus (into DUT)
    output wire [7:0] uio_out,  // shared data bus (from DUT)
    output wire [7:0] uio_oe,   // bus OE (1=drive, 0=Z)
    input  wire       ena,      // unused
    input  wire       clk,
    input  wire       rst_n
);

  localparam RnW = 0;           // 1=READ, 0=WRITE

  reg [7:0] reg_q;

  // Async reset; WRITE when RnW==0
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      reg_q <= 8'd0;
    end else if (!ui_in[RnW]) begin
      reg_q <= uio_in;          // WRITE: capture bus
    end
  end

  // Dedicated outputs always driven
  assign uo_out  = reg_q;

  // READ drives the bus; WRITE tri-states the bus
  assign uio_out = reg_q;
  assign uio_oe  = ui_in[RnW] ? 8'hFF : 8'h00;

  // tie off unused to silence warnings (ui_in[7:1] & ena unused)
  wire _unused = &{ena, ui_in[7:1], 1'b0};

endmodule

`default_nettype wire
