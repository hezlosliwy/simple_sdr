package logger_pkg;

  typedef enum {DEBUG = 400, INFO = 300, WARNING = 200, ERROR = 100, FATAL = 0} e_msg_type;

  class logger;
    
    static int print_enable;
    static int num_fatals;
    static int num_errors;
    static int num_warnings;
    static int num_infos;

    function init(int print_enable = 300);
      $timeformat(-9, 0, " ns", 20);
      logger::print_enable = print_enable;
    endfunction
    
    function void log(input string msg, e_msg_type msg_type = INFO);
      msg = $sformatf("%t, %8s :\t%s\n", $time, msg_type.name, msg);
      if (msg_type <= print_enable) begin
        $write(msg);
      end
      
      case(msg_type)
        INFO:     num_infos++;
        WARNING:  num_warnings++;
        ERROR:    num_errors++;
        FATAL:    num_fatals++;
      endcase
      
      if(msg_type == FATAL) begin
        summary();
        $finish();
      end
    endfunction
    
    function void debug(input string msg);
      log(msg, DEBUG);
    endfunction
    
    function void warning(input string msg);
      log(msg, WARNING);
    endfunction
    
    function void error(input string msg);
      log(msg, ERROR);
    endfunction
    
    function void fatal(input string msg);
      log(msg, FATAL);
    endfunction
    
    function void summary();      
      log($sformatf("----====  End of test. ====----"));
    //   log($sformatf("-- Fatals   = %8d", num_fatals));
    //   log($sformatf("-- Errors   = %8d", num_errors));
    //   log($sformatf("-- Warnings = %8d", num_warnings));
    //   log($sformatf("----=======================----"));
    //   if(num_errors == 0 && num_fatals == 0)
    //     log("-- Test PASSED");
    //   else
    //     log("-- Test FAILED");
    endfunction
  
  endclass

endpackage
