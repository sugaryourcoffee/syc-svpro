require 'sycsvpro/spread_sheet_builder'

module Sycsvpro

  describe SpreadSheetBuilder do

    it "should execute a spread sheet operation" do
      file1 = File.join(File.dirname(__FILE__), "files/spread_sheet1.csv")
      file2 = File.join(File.dirname(__FILE__), "files/spread_sheet2.csv")
      resfile = File.join(File.dirname(__FILE__), "files/spread_sheet_res.csv")

      operation = "(a*b).transpose"

      SpreadSheetBuilder.new(outfile:   resfile,
                             files:     [file1,file2].join(','),
                             rlabels:   "true,false",
                             clabels:   "true,false",
                             aliases:   "a,b",
                             operation: operation).execute

      s1  = SpreadSheet.new(['Alpha','Beta','Gamma'],
                            ['A',NotAvailable,2,3],
                            ['B',4,5,NotAvailable],
                            ['C',7,NotAvailable,9], r: true, c: true)
      s2  = SpreadSheet.new([1,2,3],[3,2,1])
      res = SpreadSheet.new(file: resfile, r: true, c: true)
      
      res2 = (s1 * s2).transpose
      
      expect { (s1 * s2).transpose == res }.to be_true
    end

  end

end
