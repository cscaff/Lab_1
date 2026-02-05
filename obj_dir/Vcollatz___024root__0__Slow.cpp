// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vcollatz.h for the primary calling header

#include "Vcollatz__pch.h"

VL_ATTR_COLD void Vcollatz___024root___eval_static(Vcollatz___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___eval_static\n"); );
    Vcollatz__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__clk__0 = vlSelfRef.clk;
}

VL_ATTR_COLD void Vcollatz___024root___eval_initial(Vcollatz___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___eval_initial\n"); );
    Vcollatz__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vcollatz___024root___eval_final(Vcollatz___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___eval_final\n"); );
    Vcollatz__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

VL_ATTR_COLD void Vcollatz___024root___eval_settle(Vcollatz___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___eval_settle\n"); );
    Vcollatz__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

bool Vcollatz___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vcollatz___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vcollatz___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vcollatz___024root___ctor_var_reset(Vcollatz___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vcollatz___024root___ctor_var_reset\n"); );
    Vcollatz__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16707436170211756652ull);
    vlSelf->go = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9942418676787815235ull);
    vlSelf->n = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1489474827855109852ull);
    vlSelf->dout = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11474705599699299244ull);
    vlSelf->done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10296494685231209730ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
}
