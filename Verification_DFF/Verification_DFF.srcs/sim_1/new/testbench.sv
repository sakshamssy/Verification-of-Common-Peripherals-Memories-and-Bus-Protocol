//`timescale 1ns / 1ps



class transaction;
//2-bit : bit
//4 state: logic
    rand bit din;
    bit dout;
    
    //No constraints addded because very simple case 
    
    function void display(input string tag);
        $display("[%0s] : din : %0b dout : %0b",tag,din,dout);
    endfunction
    
    function transaction copy();
    copy = new();
    copy.din = this.din;
    copy.dout = this.dout;
    endfunction
    
endclass

////////////////Generator Class////////
class generator;
    transaction tr;
    mailbox #(transaction) mbx;
    int count=0;
    event sconext;
    event done;
    
    function new (mailbox #(transaction) mbx);
        this.mbx=mbx;
        tr = new();
     endfunction
    task run();
        repeat(count) begin
        assert(tr.randomize) else $error ("[GEN] : RANDOMIZATION FAILED");
        //using mailbox to send the ready randomized data
        mbx.put(tr.copy);
        tr.display("GEN");
        @(sconext); //Wait till scoreboard completes its task
        end
    -> done; //GEnerator completed task
    endtask
endclass 



//////////Driver CLass//////////

class driver;
    transaction tr;
    mailbox #(transaction) mbx;
    //access to interface in driver
    //So use Virtual keyword
    virtual dff_if vif;
    function new (mailbox #(transaction) mbx);
        this.mbx=mbx;
     endfunction
     
     task reset();
        vif.rst<=1'b1;
        repeat(5) @(posedge vif.clk);
        vif.rst <=1'b0;
        repeat(2) @(posedge vif.clk);
        $display("[DRV]: DUT RESET DONE");
      endtask

      task run();
      //will use forever for driver,monitor or scoreboard
          forever begin
          mbx.get(tr);
          @(posedge vif.clk);        
              vif.din <= tr.din;
              tr.display("DRV");
          end
      endtask
      
endclass


///////MOnitor Class


class monitor;
    transaction tr;
    mailbox #(transaction) mbx;
    virtual dff_if vif;
  
  function new( mailbox #(transaction) mbx);
    this.mbx = mbx;
  endfunction
  
    task run();
        tr=new();
        forever begin
            @(posedge vif.clk);
            //NOn-Blocking assignment operator not allowed 
            //when updating the transaction data member
            tr.din=vif.din;
            tr.dout = vif.dout;
            mbx.put(tr);
            tr.display("MON");
        end
    
    endtask
endclass

//////////SCOre Board//////////////////

class scoreboard;
    transaction tr;
    mailbox #(transaction) mbx;
    
    event sconext;
    
    function new (mailbox #(transaction) mbx);
        this.mbx=mbx;
     endfunction
     
     task run();
        forever begin
            mbx.get(tr);
            tr.display("SCO");
            if(tr.din == tr.dout)
                $display("[SCO] : DATA MATCHED");
             else
                $display("[SCO] : DATA MISMATCHED");   
             -> sconext;
                
        end
     endtask
endclass



////////ENVironment Class////////////


class environment;
    generator gen; 
    driver drv;
    monitor mon;
    scoreboard sco;
    
    event nextgs;
    
    mailbox #(transaction) mbxgd;
    mailbox #(transaction) mbxms;
    
    virtual dff_if vif;
    
    function new(virtual dff_if vif);
        mbxgd=new();
        gen = new(mbxgd);
        drv =new (mbxgd);
        
        mbxms =new();
        mon=new(mbxms);
        sco=new(mbxms);
        
        //Connect all the interfaces in env, mon,driver
        this.vif = vif;
        mon.vif=this.vif;
        drv.vif= this.vif;
        
        gen.sconext =nextgs;
        sco.sconext = nextgs;      
        
     endfunction
        
    task pre_test;
        drv.reset();
    endtask
    
    task test;
        fork
            gen.run;
            drv.run;
            mon.run;
            sco.run;   
         join_any
    endtask
    
    task post_test();
        wait(gen.done.triggered);  
        $finish();     
     endtask
     
     task run();
        pre_test();
        test();
        post_test();
     endtask
     
endclass


//////////TESTBENCH MODULE/////////////////

module tb;
    dff_if vif();
    
    dff dut(vif);
    
    initial begin
        vif.clk<=1'b0;    
    end
    
    always #10 vif.clk <= ~vif.clk;
    
    environment env;
    
    initial begin
        env = new(vif);
        env.gen.count=20;
        env.run();
    end
    
    initial begin 
        $dumpfile("dump.vcd");
        $dumpvars;
    end

endmodule