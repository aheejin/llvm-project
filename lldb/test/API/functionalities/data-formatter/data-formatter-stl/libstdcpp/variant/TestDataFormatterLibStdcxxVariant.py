"""
Test lldb data formatter for LibStdC++ std::variant.
"""

import lldb
from lldbsuite.test.decorators import *
from lldbsuite.test.lldbtest import *
from lldbsuite.test import lldbutil


class LibStdcxxVariantDataFormatterTestCase(TestBase):
    @add_test_categories(["libstdcxx"])
    def test_with_run_command(self):
        """Test LibStdC++ std::variant data formatter works correctly."""
        self.build()

        (self.target, self.process, _, bkpt) = lldbutil.run_to_source_breakpoint(
            self, "// break here", lldb.SBFileSpec("main.cpp", False)
        )

        lldbutil.continue_to_breakpoint(self.process, bkpt)

        for name in ["v1", "v1_typedef"]:
            self.expect(
                "frame variable " + name,
                substrs=[name + " =  Active Type = int  {", "Value = 12", "}"],
            )

        for name in ["v1_ref", "v1_typedef_ref"]:
            self.expect(
                "frame variable " + name,
                patterns=[name + " = 0x.*  Active Type = int : {", "Value = 12", "}"],
            )

        self.expect(
            "frame variable v_v1",
            substrs=[
                "v_v1 =  Active Type = std::variant<int, double, char>  {",
                "Value =  Active Type = int  {",
                "Value = 12",
                "}",
                "}",
            ],
        )

        lldbutil.continue_to_breakpoint(self.process, bkpt)

        self.expect(
            "frame variable v1",
            substrs=["v1 =  Active Type = double  {", "Value = 2", "}"],
        )

        lldbutil.continue_to_breakpoint(self.process, bkpt)

        self.expect(
            "frame variable v2",
            substrs=["v2 =  Active Type = double  {", "Value = 2", "}"],
        )

        self.expect(
            "frame variable v3",
            substrs=["v3 =  Active Type = char  {", "Value = 'A'", "}"],
        )

        self.expect("frame variable v_valueless", substrs=["v_valueless =  No Value"])

        self.expect(
            "frame variable v_many_types_valueless",
            substrs=["v_many_types_valueless =  No Value"],
        )

    @add_test_categories(["libstdcxx"])
    def test_invalid_variant_index(self):
        """Test LibStdC++ data formatter for std::variant with invalid index."""
        self.build()

        (self.target, self.process, thread, bkpt) = lldbutil.run_to_source_breakpoint(
            self, "// break here", lldb.SBFileSpec("main.cpp", False)
        )

        lldbutil.continue_to_breakpoint(self.process, bkpt)

        self.expect(
            "frame variable v1",
            substrs=["v1 =  Active Type = int  {", "Value = 12", "}"],
        )

        var_v1 = thread.frames[0].FindVariable("v1")
        var_v1_raw_obj = var_v1.GetNonSyntheticValue()
        index_obj = var_v1_raw_obj.GetChildMemberWithName("_M_index")
        self.assertTrue(index_obj and index_obj.IsValid())

        INVALID_INDEX = "100"
        index_obj.SetValueFromCString(INVALID_INDEX)

        self.expect("frame variable v1", substrs=["v1 =  <Invalid>"])
