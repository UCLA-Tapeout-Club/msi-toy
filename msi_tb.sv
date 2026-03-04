module msi_tb;

logic clk = 0;
logic rst_n = 1;

// clk period of 10 ns
always #5 clk = ~clk;

logic bus_read = 0;
logic bus_write = 0;
logic read = 0;
logic write = 0;

logic issue_bus_rd;
logic issue_bus_rdx;
logic issue_bus_upgrade;
logic issue_bus_wb;

msi_controller DUT (
    .clk(clk),
    .rst_n(rst_n),

    .bus_read(bus_read),
    .bus_write(bus_write),
    .write(write),
    .read(read),

    .issue_bus_rd(issue_bus_rd),
    .issue_bus_rdx(issue_bus_rdx),
    .issue_bus_upgrade(issue_bus_upgrade),
    .issue_bus_wb(issue_bus_wb)
);

initial begin
    rst_n = 0;

    // deassert reset synchronous
    @(posedge clk) rst_n = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // I -> I, should have no outputs
    bus_read = 1;
    #2; 
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; bus_read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // I -> I (bus write), should have no outputs
    bus_write = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; bus_write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // I -> S (read), should output issue_bus_rd
    read = 1;
    #2;
    assert(issue_bus_rd === 1);
    assert((issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // S -> S (read), should have no outputs
    read = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // S -> S (bus read), should have no outputs
    bus_read = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; bus_read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // S -> I (bus_write), should have no outputs (clean data)
    bus_write = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; bus_write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // I -> M (write), should output issue_bus_rdx
    write = 1;
    #2;
    assert(issue_bus_rdx === 1);
    assert((issue_bus_rd | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // M -> M (write), should have no outputs
    write = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // M -> M (read), should have no outputs
    read = 1;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    @(posedge clk) #1ps; read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // M -> S (bus_read), should output issue_bus_wb
    bus_read = 1;
    #2;
    assert(issue_bus_wb === 1);
    assert((issue_bus_rd | issue_bus_upgrade | issue_bus_rdx) === 0);

    @(posedge clk) #1ps; bus_read = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // S -> M (write), should output issue_bus_upgrade
    write = 1;
    #2;
    assert(issue_bus_upgrade === 1);
    assert((issue_bus_rd | issue_bus_wb | issue_bus_rdx) === 0);

    @(posedge clk) #1ps; write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    // M -> I (bus write), should output issue_bus_wb
    bus_write = 1;
    #2;
    assert(issue_bus_wb === 1);
    assert((issue_bus_rd | issue_bus_upgrade | issue_bus_rdx) === 0);

    @(posedge clk) #1ps; bus_write = 0;
    #2;
    assert((issue_bus_rd | issue_bus_rdx | issue_bus_upgrade | issue_bus_wb) === 0);

    $finish;
end

endmodule