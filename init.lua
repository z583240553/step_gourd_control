local _M = {}
local bit = require "bit"
local cjson = require "cjson.safe"

local Json = cjson.encode

local insert = table.insert
local concat = table.concat

local strload

local cmds = {
  [0] = "length",
  [1] = "DTU_time",
  [2] = "DTU_status",
  [3] = "DTU_function",
  [4] = "device_address"
}
--  "cranetype",             --起重机类型
-----------------------------------起升页面json--------------------------------------
local main_state = {
  [1] = "main_state",             --主钩的机构状态
  [2] = "main_fault",             --主钩的故障信息
  [3] = "main_ctrlmode",          --主钩的控制方式
  [4] = "main_rundir",            --主钩的运行方向
  [5] = "main_runspd",            --主钩的运行速度
  [6] = "main_motorhot",           --主钩的电机过热
  [7] = "main_uplimit",          --主钩的上限位
  [8] = "main_downlimit",        --主钩的下限位
  [9] = "main_forfdk",           --主钩的正转反馈
  [10] = "main_revfdk",           --主钩的反转反馈
  [11] = "main_hsfdk",            --主钩的高速反馈
  [12] = "main_lsfdk",            --主钩的低速反馈
  [13] = "main_liftheight",       --主钩的起升高度
  [14] = "main_height",            --主钩的离地高度
  [15] = "main_realpulse",        --主钩的实时脉冲数
  [16] = "main_brkdis",           --主钩的刹车距离
  [17] = "main_motorcur",         --主钩的电机电流
  [18] = "main_motorvolt",        --主钩的电机电压
  [19] = "main_bfknum",           --主钩的刹车次数
  [20] = "main_mruntime",         --主钩的电机运行时间
  [21] = "main_bruntime",         --主钩的抱闸运行时间
  [22] = "main_power",            --主钩的有功功率
  [23] = "main_mefficiency",      --主钩的电机效率
  [24] = "main_lhdelay",         --主钩的低/高延迟 加速
  [25] = "main_hldelay",         --主钩的高/低延迟 减速
  [26] = "main_hook",              --主钩的钩载显示
  [27] = "main_warn",              --主钩的预警值
  [28] = "main_alarm",             --主钩的报警值
}
local vice_state = {
  [1] = "vice_state",             --副钩的机构状态
  [2] = "vice_fault",             --副钩的故障信息
  [3] = "vice_ctrlmode",          --副钩的控制方式
  [4] = "vice_rundir",            --副钩的运行方向
  [5] = "vice_runspd",            --副钩的运行速度
  [6] = "vice_motorhot",           --副钩的电机过热
  [7] = "vice_uplimit",          --副钩的上限位
  [8] = "vice_downlimit",        --副钩的下限位
  [9] = "vice_forfdk",           --副钩的正转反馈
  [10] = "vice_revfdk",           --副钩的反转反馈
  [11] = "vice_hsfdk",            --副钩的高速反馈
  [12] = "vice_lsfdk",            --副钩的低速反馈
  [13] = "vice_liftheight",       --副钩的起升高度
  [14] = "vice_height",           --副钩的离地高度
  [15] = "vice_realpulse",        --副钩的实时脉冲数
  [16] = "vice_brkdis",           --副钩的刹车距离
  [17] = "vice_motorcur",         --副钩的电机电流
  [18] = "vice_motorvolt",        --副钩的电机电压
  [19] = "vice_bfknum",           --副钩的刹车次数
  [20] = "vice_mruntime",         --副钩的电机运行时间
  [21] = "vice_bruntime",         --副钩的抱闸运行时间
  [22] = "vice_power",            --副钩的有功功率
  [23] = "vice_mefficiency",      --副钩的电机效率
  [24] = "vice_lhdelay",         --副钩的低/高延迟
  [25] = "vice_hldelay",         --副钩的高/低延迟
  [26] = "vice_hook",              --副钩的钩载显示
  [27] = "vice_warn",              --副钩的预警值
  [28] = "vice_alarm",             --副钩的报警值
}
local main_dot = {
["main_liftheight"]=2,["main_height"]=2,["main_realpulse"]=0,["main_brkdis"]=2,["main_motorcur"]=1,["main_motorvolt"]=1,
["main_bfknum"]=0,["main_mruntime"]=0,["main_bruntime"]=1,["main_power"]=2,["main_mefficiency"]=0,["main_lhdelay"]=2,
["main_hldelay"]=2,["main_hook"]=2,["main_warn"]=0,["main_alarm"]=0,
}
local vice_dot = {
["vice_liftheight"]=2,["vice_height"]=2,["vice_realpulse"]=0,["vice_brkdis"]=2,["vice_motorcur"]=1,["vice_motorvolt"]=1,
["vice_bfknum"]=0,["vice_mruntime"]=0,["vice_bruntime"]=1,["vice_power"]=2,["vice_mefficiency"]=0,["vice_lhdelay"]=2,
["vice_hldelay"]=2,["vice_hook"]=2,["vice_warn"]=0,["vice_alarm"]=0,
}
-----------------------------------小车页面json--------------------------------------
local small1_state = {
  [1] = "small1_state",             --小车1的机构状态
  [2] = "small1_fault",             --小车1的故障信息
  [3] = "small1_rundir",            --小车1的运行方向
  [4] = "small1_runspd",            --小车1的运行速度
  [5] = "small1_forlimit",          --小车1的正转限位
  [6] = "small1_revlimit",          --小车1的反转限位
  [7] = "small1_brkfdk",            --小车1的抱闸反馈
  [8] = "small1_motorhot",          --小车1的电机过热
  [9] = "small1_trip",              --小车1的小车行程
  [10] = "small1_position",         --小车1的位置信息
  [11] = "small1_realpulse",        --小车1的实时脉冲数
  [12] = "small1_brkdis",           --小车1的刹车距离
  [13] = "small1_motorcur",         --小车1的电机电流
  [14] = "small1_motorvolt",        --小车1的电机电压
  [15] = "small1_bfknum",           --小车1的抱闸次数
  [16] = "small1_mruntime",         --小车1的电机运行时间
  [17] = "small1_bruntime",         --小车1的抱闸运行时间
  [18] = "small1_power",            --小车1的有功功率
  [19] = "small1_givfrq",           --小车1的目标频率
  [20] = "small1_fdkfrq",           --小车1的反馈频率
  [21] = "small1_outcur",           --小车1的输出电流
  [22] = "small1_outvolt",          --小车1的输出电压
  [23] = "small1_busvolt",          --小车1的母线电压
  [24] = "small1_outtorq",          --小车1的输出转矩
  [25] = "small1_outpower",         --小车1的输出功率
  [26] = "small1_temp",             --小车1的散热器温度
}
local small2_state = {
  [1] = "small2_state",             --小车2的机构状态
  [2] = "small2_fault",             --小车2的故障信息
  [3] = "small2_rundir",            --小车2的运行方向
  [4] = "small2_runspd",            --小车2的运行速度
  [5] = "small2_forlimit",          --小车2的正转限位
  [6] = "small2_revlimit",          --小车2的反转限位
  [7] = "small2_brkfdk",            --小车2的抱闸反馈
  [8] = "small2_motorhot",          --小车2的电机过热
  [9] = "small2_trip",              --小车2的小车行程
  [10] = "small2_position",         --小车2的位置信息
  [11] = "small2_realpulse",        --小车2的实时脉冲数
  [12] = "small2_brkdis",           --小车2的刹车距离
  [13] = "small2_motorcur",         --小车2的电机电流
  [14] = "small2_motorvolt",        --小车2的电机电压
  [15] = "small2_bfknum",           --小车2的抱闸次数
  [16] = "small2_mruntime",         --小车2的电机运行时间
  [17] = "small2_bruntime",         --小车2的抱闸运行时间
  [18] = "small2_power",            --小车2的有功功率
  [19] = "small2_givfrq",           --小车2的目标频率
  [20] = "small2_fdkfrq",           --小车2的反馈频率
  [21] = "small2_outcur",           --小车2的输出电流
  [22] = "small2_outvolt",          --小车2的输出电压
  [23] = "small2_busvolt",          --小车2的母线电压
  [24] = "small2_outtorq",          --小车2的输出转矩
  [25] = "small2_outpower",         --小车2的输出功率
  [26] = "small2_temp",             --小车2的散热器温度
}
local small1_dot = {
["small1_trip"]=2,["small1_position"]=2,["small1_realpulse"]=0,["small1_brkdis"]=2,["small1_motorcur"]=1,["small1_motorvolt"]=1,
["small1_bfknum"]=0,["small1_mruntime"]=0,["small1_bruntime"]=1,["small1_power"]=2,["small1_givfrq"]=2,["small1_fdkfrq"]=2,
["small1_outcur"]=2,["small1_outvolt"]=1,["small1_busvolt"]=0,["small1_outtorq"]=1,["small1_outpower"]=2,["small1_temp"]=1,
}
local small2_dot = {
["small2_trip"]=2,["small2_position"]=2,["small2_realpulse"]=0,["small2_brkdis"]=2,["small2_motorcur"]=1,["small2_motorvolt"]=1,
["small2_bfknum"]=0,["small2_mruntime"]=0,["small2_bruntime"]=1,["small2_power"]=2,["small2_givfrq"]=2,["small2_fdkfrq"]=2,
["small2_outcur"]=2,["small2_outvolt"]=1,["small2_busvolt"]=0,["small2_outtorq"]=1,["small2_outpower"]=2,["small2_temp"]=1,
}
-----------------------------------大车页面json--------------------------------------
local large_state = {
  [1] = "large_state",             --大车的机构状态
  [2] = "large_fault",             --大车的故障信息
  [3] = "large_rundir",            --大车的运行方向
  [4] = "large_runspd",            --大车的运行速度
  [5] = "large_forlimit",          --大车的正转限位
  [6] = "large_revlimit",          --大车的反转限位
  [7] = "large_hotfdk",            --大车的热继反馈
  [8] = "large_brkfdk",            --大车的抱闸反馈
  [9] = "large_trip",              --大车的大车行程
  [10] = "large_position",         --大车的位置信息
  [11] = "large_realpulse",        --大车的实时脉冲数
  [12] = "large_brkdis",           --大车的刹车距离
  [13] = "large_motorcur",         --大车的电机电流
  [14] = "large_motorvolt",        --大车的电机电压
  [15] = "large_bfknum",           --大车的抱闸次数
  [16] = "large_mruntime",         --大车的电机运行时间
  [17] = "large_bruntime",         --大车的抱闸运行时间
  [18] = "large_power",            --大车的有功功率
  [19] = "large_givfrq",           --大车的目标频率
  [20] = "large_fdkfrq",           --大车的反馈频率
  [21] = "large_outcur",           --大车的输出电流
  [22] = "large_outvolt",          --大车的输出电压
  [23] = "large_busvolt",          --大车的母线电压
  [24] = "large_outtorq",          --大车的输出转矩
  [25] = "large_outpower",         --大车的输出功率
  [26] = "large_temp",             --大车的散热器温度
}
local large_dot = {
["large_trip"]=2,["large_position"]=2,["large_realpulse"]=0,["large_brkdis"]=2,["large_motorcur"]=1,["large_motorvolt"]=1,
["large_bfknum"]=0,["large_mruntime"]=0,["large_bruntime"]=1,["large_power"]=2,["large_givfrq"]=2,["large_fdkfrq"]=2,
["large_outcur"]=2,["large_outvolt"]=1,["large_busvolt"]=0,["large_outtorq"]=1,["large_outpower"]=2,["large_temp"]=1,
}
-----------------------------------控制器页面json--------------------------------------
local ctrl_state = {}
for i=1,10,1 do
  ctrl_state[i] = "ctrl_x0"..(i-1)  --X00、、X09
end
for i=1,10,1 do
  ctrl_state[10+i] = "ctrl_x1"..(i-1) --X10、、X19
end
for i=1,10,1 do
  ctrl_state[20+i] = "ctrl_x2"..(i-1) --X20、、X29
end
for i=1,2,1 do
  ctrl_state[30+i] = "ctrl_x3"..(i-1) --X30、X31
end
for i=1,2,1 do
  ctrl_state[32+i] = "ctrl_x5"..(i-1) --X50、X51
end
for i=1,2,1 do
  ctrl_state[34+i] = "ctrl_x6"..(i-1) --X60、X61
end
for i=1,2,1 do
  ctrl_state[36+i] = "ctrl_x7"..(i-1) --X70、X71
end
for i=1,8,1 do
  ctrl_state[38+i] = "ctrl_k"..(i) --K1、、K8
end
for i=1,4,1 do
  ctrl_state[46+i] = "ctrl_y5"..(i-1) --Y50、、Y53
end
for i=1,4,1 do
  ctrl_state[50+i] = "ctrl_y6"..(i-1) --Y60、、Y63
end
for i=1,4,1 do
  ctrl_state[54+i] = "ctrl_y7"..(i-1) --Y70、、Y73
end
ctrl_state[59] = "ctrl_cranetype"        --起重机类型
ctrl_state[60] = "ctrl_weight"           --称重吨位
ctrl_state[61] = "ctrl_signal"           --称重采集信号
ctrl_state[62] = "ctrl_warn"             --称重预警值
ctrl_state[63] = "ctrl_alarm"            --称重报警值
-----------------------------------起重主监控页面json--------------------------------------
local crane_state = {
  [1] = "crn_l_rundis",             --大车状态-运行方向
  [2] = "crn_l_position",           --大车状态-位置信息
  [3] = "crn_l_runspd",             --大车状态-运行速度
  [4] = "crn_l_invtstate",          --大车状态-变频器状态
  [5] = "crn_l_forlimit",           --大车状态-正转限位
  [6] = "crn_l_revlimit",           --大车状态-反转限位
  [7] = "crn_l_brkstate",           --大车状态-抱闸状态
  [8] = "crn_l_fltcode",            --大车状态-故障代码
  [9] = "crn_s2_rundis",             --小车2状态-运行方向
  [10] = "crn_s2_position",           --小车2状态-位置信息
  [11] = "crn_s2_runspd",             --小车2状态-运行速度
  [12] = "crn_s2_invtstate",          --小车2状态-变频器状态
  [13] = "crn_s2_forlimit",           --小车2状态-正转限位
  [14] = "crn_s2_revlimit",           --小车2状态-反转限位
  [15] = "crn_s2_brkstate",           --小车2状态-抱闸状态
  [16] = "crn_s2_fltcode",            --小车2状态-故障代码
  [17] = "crn_s1_rundis",             --小车1状态-运行方向
  [18] = "crn_s1_position",           --小车1状态-位置信息
  [19] = "crn_s1_runspd",             --小车1状态-运行速度
  [20] = "crn_s1_invtstate",          --小车1状态-变频器状态
  [21] = "crn_s1_forlimit",           --小车1状态-正转限位
  [22] = "crn_s1_revlimit",           --小车1状态-反转限位
  [23] = "crn_s1_brkstate",           --小车1状态-抱闸状态
  [24] = "crn_s1_fltcode",            --小车1状态-故障代码
  [25] = "crn_v_ctrl",                --副钩状态-控制方式
  [26] = "crn_v_rundis",              --副钩状态-运行方向
  [27] = "crn_v_height",              --副钩状态-离地高度
  [28] = "crn_v_runspd",              --副钩状态-运行速度
  [29] = "crn_v_invtstate",           --副钩状态-变频器状态
  [30] = "crn_v_uplimit",             --副钩状态-上限位
  [31] = "crn_v_downlimit",           --副钩状态-下限位
  [32] = "crn_v_brkstate",            --副钩状态-抱闸状态
  [33] = "crn_v_fltcode",             --副钩状态-故障代码
  [34] = "crn_v_weight",              --副钩状态-钩载显示
  [35] = "crn_m_ctrl",                --主钩状态-控制方式
  [36] = "crn_m_rundis",              --主钩状态-运行方向
  [37] = "crn_m_height",              --主钩状态-离地高度
  [38] = "crn_m_runspd",              --主钩状态-运行速度
  [39] = "crn_m_invtstate",           --主钩状态-变频器状态
  [40] = "crn_m_uplimit",             --主钩状态-上限位
  [41] = "crn_m_downlimit",           --主钩状态-下限位
  [42] = "crn_m_brkstate",            --主钩状态-抱闸状态
  [43] = "crn_m_fltcode",             --主钩状态-故障代码
  [44] = "crn_m_weight",              --主钩状态-钩载显示

  [45] = "crn_wholestate",            --整机状态
  [46] = "crn_mainstate",             --主起升机构状态
  [47] = "crn_vicestate",             --副起升机构状态
  [48] = "crn_samll1state",           --小车1机构状态
  [49] = "crn_small2state",           --小车2机构状态
  [50] = "crn_largestate",            --大车机构状态

  [51] = "crn_power",                 --电源状态
  [52] = "crn_open",                  --启动
  [53] = "crn_reset",                 --复位
  [54] = "crn_stop",                  --急停
  [55] = "crn_phase",                 --相序错误
  [56] = "crn_contactor",             --主接触器
}
--[[
for i=1,4,1 do
  crane_state[56+i] = "crn_"..i.."_mainup"    --i档主钩上升
end
for i=1,4,1 do
  crane_state[60+i] = "crn_"..i.."_maindown"  --i档主钩下降
end
for i=1,4,1 do
  crane_state[64+i] = "crn_"..i.."_viceup"    --i档副钩上升
end
for i=1,4,1 do
  crane_state[68+i] = "crn_"..i.."_vicedown"  --i档副钩下降
end
for i=1,4,1 do
  crane_state[72+i] = "crn_"..i.."_small1for" --i档小车1正转
end
for i=1,4,1 do
  crane_state[76+i] = "crn_"..i.."_small1rev" --i档小车1反转
end
for i=1,4,1 do
  crane_state[80+i] = "crn_"..i.."_small2for" --i档小车2正转
end
for i=1,4,1 do
  crane_state[84+i] = "crn_"..i.."_small2rev" --i档小车2反转
end
for i=1,4,1 do
  crane_state[88+i] = "crn_"..i.."_largefor"  --i档大车正转
end
for i=1,4,1 do
  crane_state[92+i] = "crn_"..i.."_largerev"  --i档大车反转
end
]]
-----------------------------------故障表json--------------------------------------
local fault_state = {}
local faultstate = {
    [1] = "code",
    [2] = "grade",
    [3] = "state",
    [4] = "time",
}
for i=1,20,1 do
  for j=1,4,1 do
    fault_state[(i-1)*4+j] = "flt"..i.."_"..faultstate[j] 
  end
end
-----------------------------------变频信息json-----------------------------------
local invertstate = {
    [1] = "givfrq",
    [2] = "fdkfrq",
    [3] = "outcur",
    [4] = "outvolt",
    [5] = "busvolt",
    [6] = "outtorq",
    [7] = "yunstate",
    [8] = "temp",
    [9] = "uvolt",
    [10] = "vvolt",
    [11] = "wvolt",
    [12] = "ucur",
    [13] = "vcur",
    [14] = "wcur",
    [15] = "m_brand",
    [16] = "m_model",
    [17] = "m_volt",
    [18] = "m_cur",
    [19] = "m_frq",
    [20] = "m_spd",
    [21] = "m_pole",
    [22] = "m_pwr",  --将原来的额定转矩改成额定功率
    [23] = "v_brand",
    [24] = "v_model",
    [25] = "v_volt",
    [26] = "v_cur",
    [27] = "v_frq",
    [28] = "v_hver",
    [29] = "v_sver",
    [30] = "v_pwr",   --将原来的版本号改成额定功率
}
local invert_dot = {
["givfrq"]=2,["fdkfrq"]=2,["outcur"]=2,["outvolt"]=1,["busvolt"]=0,["outtorq"]=1,
["yunstate"]=0,["temp"]=1,["uvolt"]=1,["vvolt"]=1,["wvolt"]=1,["ucur"]=1,
["vcur"]=1,["wcur"]=1,["m_brand"]=0,["m_model"]=0,["m_volt"]=0,["m_cur"]=1,
["m_frq"]=2,["m_spd"]=0,["m_pole"]=0,["m_pwr"]=2,["v_brand"]=0,["v_model"]=0,
["v_volt"]=0,["v_cur"]=1,["v_frq"]=2,["v_hver"]=2,["v_sver"]=2,["v_pwr"]=2,
}

--[[
for j=1,30,1 do
  invert_state[j] = "invt_m_"..invertstate[j] 
end
for j=1,30,1 do
  invert_state[30+j] = "invt_v_"..invertstate[j] 
end
  for j=1,30,1 do
  invert_state[(i-1)*4+j] = "invt_s1_"..invertstate[j] 
end
  for j=1,30,1 do
  invert_state[(i-1)*4+j] = "invt_s2_"..invertstate[j] 
end
  for j=1,30,1 do
  invert_state[(i-1)*4+j] = "invt_l_"..invertstate[j] 
end
]]
------------------------------------------
function utilCalcFCS( pBuf , len )
	local rtrn = 0
	local l = len

	while (len ~= 0)
		do
		len = len - 1
		rtrn = bit.bxor( rtrn , pBuf[l-len] )
	end

	return rtrn
end

function getnumber( index )
   return string.byte(strload,index)
end

function _M.encode(payload)
  return payload
end

function _M.decode(payload)
    local packet = {['status']='not'}
    local FCS_Array = {}
    local FCS_Value = 0

    strload = payload

    local head1 = getnumber(1)
    local head2 = getnumber(2)
    if ( head1 == 0x3B and head2 == 0x31 ) then 
        local templen = bit.lshift( getnumber(3) , 8 ) + getnumber(4) --收到的数据长度

        FCS_Value = bit.lshift(getnumber(templen+5),8) + getnumber(templen+6)
        --templen will be the important parameter in the next calculate
        --in different task some number mabey be changed 
        --to avoid unnecessary problem
        --packet[ cmds[0] ] = templen
        packet[ cmds[1] ] = bit.lshift( getnumber(5) , 8 ) + bit.lshift( getnumber(6) , 16 ) + bit.lshift( getnumber(7) , 8 ) + getnumber(8)
        
        local func = getnumber(10)  --数据类型功能码 
        ----------------------------控制器数据--------------------------------
        if func == 0x01 then
            packet[ cmds[3] ] = 'func-controller'
           
            --解析每位bit
            for i=0,2 do
                for j=0,9 do    --X00组 X10组 X20组
                    local m = bit.band( (bit.lshift(getnumber(12+i*2),8)+getnumber(13+i*2)) , bit.lshift(1,j) )
                    if m==0 then
                      packet[ ctrl_state[j+1+i*10] ] = 0
                    else
                      packet[ ctrl_state[j+1+i*10] ] = 1
                    end  
                end
            end
            for j=0,1 do    --X30组
                local m = bit.band(getnumber(33),bit.lshift(1,j))
                if m==0 then
                  packet[ ctrl_state[31+j] ] = 0
                else
                  packet[ ctrl_state[31+j] ] = 1
                end  
            end
            for i=0,2 do    --X50组 X60组 X70组
                for j=0,1 do    
                    local m = bit.band(getnumber(19+i*2),bit.lshift(1,j))
                    if m==0 then
                      packet[ ctrl_state[33+j+i*2] ] = 0
                    else
                      packet[ ctrl_state[33+j+i*2] ] = 1
                    end  
                end
            end
            for j=0,7 do     --K0组
                local m = bit.band((bit.lshift(getnumber(24),8)+getnumber(25)),bit.lshift(1,j))
                if m==0 then
                  packet[ ctrl_state[39+j] ] = 0
                else
                  packet[ ctrl_state[39+j] ] = 1
                end  
            end
            for i=0,2 do    --Y50组 Y60组 Y70组
                for j=0,3 do    
                    local m = bit.band(getnumber(27+i*2),bit.lshift(1,j))
                    if m==0 then
                      packet[ ctrl_state[47+j+i*4] ] = 0
                    else
                      packet[ ctrl_state[47+j+i*4] ] = 1
                    end  
                end
            end
            
            for i=0,4,1 do  
                packet[ ctrl_state[59+i] ] =  bit.lshift( getnumber(34+i*2) , 8 ) + getnumber(35+i*2) --起重机类型、吨位、采集信号、预警值、报警值  
            end
            packet[ ctrl_state[60] ] = packet[ ctrl_state[60] ]/100
            packet[ ctrl_state[61] ] = packet[ ctrl_state[61] ]/1000
        ------------------------------大车数据--------------------------------
        elseif func==0x04 then
            packet[ cmds[3] ] = 'func-large'
          
            for i=1,2,1 do  
                packet[ large_state[i] ] =  bit.lshift( getnumber(10+i*2) , 8 ) + getnumber(11+i*2) --状态、故障   
            end
            
            --通过大车状态判断运行方向和运行速度
            if packet[ large_state[1] ]==2 or packet[ large_state[1] ]==4 then  
                packet[ large_state[3] ] = 1
            elseif packet[ large_state[1] ]==3 or packet[ large_state[1] ]==5 then
                packet[ large_state[3] ] = 0
            end
            if packet[ large_state[1] ]==2 or packet[ large_state[1] ]==3 then  
                packet[ large_state[4] ] = 0
            elseif packet[ large_state[1] ]==4 or packet[ large_state[1] ]==5 then
                packet[ large_state[4] ] = 1
            end
            
            --解析大车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
            for i=0,2 do
                local m = bit.band(getnumber(19),bit.lshift(1,(5+i)))  --大车-正转限位 反转限位 抱闸反馈
                if m==0 then
                  packet[ large_state[5+i] ] = 0
                else
                  packet[ large_state[5+i] ] = 1
                end
            end
          
            for i=1,18,1 do   --行程、位置信息、....、散热器温度  
                local dot = large_dot[ large_state[8+i] ]
                if dot >=0 then
                  local paranum = (bit.lshift(getnumber(20+i*2),8) + getnumber(21+i*2)) / ( 10^dot )
                 -- local parastrformat = "%0."..dot.."f"
                 -- packet[ large_state[8+i] ] = string.format(parastrformat,paranum)
                 packet[ large_state[8+i] ] = paranum
                end
            end 
        ------------------------------小车数据--------------------------------
        elseif func==0x03 then
            packet[ cmds[3] ] = 'func-small'
            packet[ 'cranetype' ] = bit.lshift(getnumber(12),8) + getnumber(13)  --起重机类型  

            for i=1,2,1 do  
                packet[ small1_state[i] ] =  bit.lshift(getnumber(12+i*2),8) + getnumber(13+i*2) --状态、故障   
            end
            
            --通过小车状态判断运行方向和运行速度
            if packet[ small1_state[1] ]==2 or packet[ small1_state[1] ]==4 then  
                packet[ small1_state[3] ] = 1
            elseif packet[ small1_state[1] ]==3 or packet[ small1_state[1] ]==5 then
                packet[ small1_state[3] ] = 0
            end
            if packet[ small1_state[1] ]==2 or packet[ small1_state[1] ]==3 then  
                packet[ small1_state[4] ] = 0
            elseif packet[ small1_state[1] ]==4 or packet[ small1_state[1] ]==5 then
                packet[ small1_state[4] ] = 1
            end
            
            --解析小车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
            for i=0,2 do
                local m = bit.band(getnumber(21),bit.lshift(1,(5+i)))  --小车-正转限位 反转限位 抱闸反馈
                if m==0 then
                  packet[ small1_state[5+i] ] = 0
                else
                  packet[ small1_state[5+i] ] = 1
                end
            end
          
            for i=1,18,1 do  
                local dot = small1_dot[ small1_state[8+i] ]
                if dot >=0 then
                  local paranum = (bit.lshift(getnumber(22+i*2),8) + getnumber(23+i*2)) / ( 10^dot )
                  local parastrformat = "%0."..dot.."f"
                  packet[ small1_state[8+i] ] = string.format(parastrformat,paranum)
                end
            end

            if packet[ 'cranetype' ] >1 then   --5机构 有2号小车
                for i=1,2,1 do  
                    packet[ small2_state[i] ] =  bit.lshift(getnumber(58+i*2),8) + getnumber(59+i*2) --状态、故障   
                end
                
                --通过小状态判断运行方向和运行速度
                if packet[ small2_state[1] ]==2 or packet[ small2_state[1] ]==4 then  
                    packet[ small2_state[3] ] = 1
                elseif packet[ small2_state[1] ]==3 or packet[ small2_state[1] ]==5 then
                    packet[ small2_state[3] ] = 0
                end
                if packet[ small2_state[1] ]==2 or packet[ small2_state[1] ]==3 then  
                    packet[ small2_state[4] ] = 0
                elseif packet[ small2_state[1] ]==4 or packet[ small2_state[1] ]==5 then
                    packet[ small2_state[4] ] = 1
                end
                
                --解析2号小车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
                for i=0,2 do
                    local m = bit.band(getnumber(67),bit.lshift(1,(5+i)))  --小车-正转限位 反转限位 抱闸反馈
                    if m==0 then
                      packet[ small2_state[5+i] ] = 0
                    else
                      packet[ small2_state[5+i] ] = 1
                    end
                end
              
                for i=1,18,1 do  
                    local dot = small2_dot[ small2_state[8+i] ]
                    if dot >=0 then
                      local paranum = (bit.lshift(getnumber(68+i*2),8) + getnumber(69+i*2)) / ( 10^dot )
                      local parastrformat = "%0."..dot.."f"
                      packet[ small2_state[8+i] ] = string.format(parastrformat,paranum)
                    end
                end
            end --2号小车结束end
          -------------------起升数据（有无副钩数据由起重机机构来判断）----------------------
        elseif func == 0x02 then
            packet[ cmds[3] ] = 'func-lifting'
        
            packet['cranetype'] = bit.lshift(getnumber(12),8) + getnumber(13)  --起重机类型

            for i=1,3,1 do  
                packet[ main_state[i] ] =  bit.lshift(getnumber(12+i*2),8) + getnumber(13+i*2) --状态、故障、控制方式   
            end
   
            --通过起升状态判断运行方向和运行速度
            if packet[ main_state[1] ]==1 or packet[ main_state[1] ]==2 then  
                packet[ main_state[4] ] = 1
            elseif packet[ main_state[1] ]==3 or packet[ main_state[1] ]==4 then
                packet[ main_state[4] ] = 0
            end
            if packet[ main_state[1] ]==1 or packet[ main_state[1] ]==3 then  
                packet[ main_state[5] ] = 0
            elseif packet[ main_state[1] ]==2 or packet[ main_state[1] ]==4 then
                packet[ main_state[5] ] = 1
            end
            --解析主起升数字量输入 bit3 4 5 7 8 9 10对应电机过热 上 下限位 正转 反转反馈 高速 低速反馈
            local input = bit.lshift(getnumber(20),8) + getnumber(21) 
            for i=0,2 do
                local m = bit.band( input,bit.lshift(1,(3+i)) )  --主钩-电机过热 上 下限位
                if m==0 then
                  packet[ main_state[6+i] ] = 0
                else
                  packet[ main_state[6+i] ] = 1
                end
            end
            for i=0,3 do
                local m = bit.band( input,bit.lshift(1,(7+i)) )  --主钩-正转 反转反馈 高速 低速反馈
                if m==0 then
                  packet[ main_state[9+i] ] = 0
                else
                  packet[ main_state[9+i] ] = 1
                end
            end

           -- for i=1,16,1 do  
               -- packet[ main_state[12+i] ] =  bit.lshift( getnumber(22+i*2) , 8 ) + getnumber(23+i*2) --起升高度、离地距离、....、报警值、低高延时、高低延时   
            --end
            for i=1,16,1 do  
                local dot = main_dot[ main_state[12+i] ]
                if dot >=0 then
                  local paranum = (bit.lshift(getnumber(22+i*2),8) + getnumber(23+i*2)) / ( 10^dot )
                  local parastrformat = "%0."..dot.."f"
                  packet[ main_state[12+i] ] = string.format(parastrformat,paranum)
                end
            end
            
            if packet['cranetype']>0 then   -- 4机构和5机构 副钩出现

                for i=1,3,1 do  
                    packet[ vice_state[i] ] =  bit.lshift(getnumber(54+i*2),8) + getnumber(55+i*2) --状态、故障、控制方式   
                end
       
                --通过起升状态判断运行方向和运行速度
                if packet[ vice_state[1] ]==1 or packet[ vice_state[1] ]==2 then  
                    packet[ vice_state[4] ] = 1
                elseif packet[ vice_state[1] ]==3 or packet[ vice_state[1] ]==4 then
                    packet[ vice_state[4] ] = 0
                end
                if packet[ vice_state[1] ]==1 or packet[ vice_state[1] ]==3 then  
                    packet[ vice_state[5] ] = 0
                elseif packet[ vice_state[1] ]==2 or packet[ vice_state[1] ]==4 then
                    packet[ vice_state[5] ] = 1
                end
                --解析主起升数字量输入 bit3 4 5 7 8 9 10对应电机过热 上 下限位 正转 反转反馈 高速 低速反馈
                local input = bit.lshift(getnumber(62),8) + getnumber(63) 
                for i=0,2 do
                    local m = bit.band( input,bit.lshift(1,(3+i)) )  --主钩-电机过热 上 下限位
                    if m==0 then
                      packet[ vice_state[6+i] ] = 0
                    else
                      packet[ vice_state[6+i] ] = 1
                    end
                end
                for i=0,3 do
                    local m = bit.band( input,bit.lshift(1,(7+i)) )  --主钩-正转 反转反馈 高速 低速反馈
                    if m==0 then
                      packet[ vice_state[9+i] ] = 0
                    else
                      packet[ vice_state[9+i] ] = 1
                    end
                end

                for i=1,16,1 do  
                    local dot = vice_dot[ vice_state[12+i] ]
                    if dot >=0 then
                      local paranum = (bit.lshift(getnumber(64+i*2),8) + getnumber(65+i*2)) / ( 10^dot )
                      local parastrformat = "%0."..dot.."f"
                      packet[ vice_state[12+i] ] = string.format(parastrformat,paranum)
                    end
                end
            end --副钩结束end

        ----------------------------------起重主监控数据--------------------------------------
        elseif func == 0x00 then
          
            packet[ cmds[3] ] = 'func-crane'

            packet['cranetype'] = bit.lshift(getnumber(14),8) + getnumber(15) --0：3机构:1：4机构:2：5机构  

            packet[ crane_state[45] ] = bit.lshift(getnumber(20),8)+getnumber(21)    --整机状态
            if (bit.lshift(getnumber(22),8)+getnumber(23))>0 then
               packet[ crane_state[45] ] = 2                                         --整机状态
            end
            
            local liftstate = bit.lshift(getnumber(26),8)+getnumber(27)                    --主起升机构状态
            if liftstate>0 and liftstate<5 then
              packet[ crane_state[46] ] = 1
            else 
              packet[ crane_state[46] ] = 0
            end

            if (bit.lshift(getnumber(28),8)+getnumber(29))>0 then
               packet[ crane_state[46] ] = 2                                         --主起升机构状态
            end

            packet[ crane_state[35] ] = bit.lshift(getnumber(30),8)+getnumber(31)   --主钩状态-控制方式
            packet[ crane_state[37] ] = (bit.lshift(getnumber(34),8)+getnumber(35))/100    --主钩状态-离地高度
            packet[ crane_state[44] ] = (bit.lshift(getnumber(36),8)+getnumber(37))/100    --主钩状态-钩载显示
            if(packet[ crane_state[35] ]>0) then
              packet[ crane_state[39] ] = bit.lshift(getnumber(38),8)+getnumber(39)   --主钩状态-变频器状态
              packet[ crane_state[43] ] = bit.lshift(getnumber(40),8)+getnumber(41)    --主钩状态-故障代码  
            end
            
            --通过起升状态判断运行方向和运行速度
            if liftstate==1 or liftstate==2 then  
                packet[ crane_state[36] ] = 1
            elseif liftstate==3 or liftstate==4 then
                packet[ crane_state[36] ] = 0
            end
            if liftstate==1 or liftstate==3 then  
                packet[ crane_state[38] ] = 0
            elseif liftstate==2 or liftstate==4 then
                packet[ crane_state[38] ] = 1
            end
    
            --解析主起升数字量输入 bit4 5 13对应上下限位 抱闸反馈状态
            local input = bit.lshift(getnumber(32),8) + getnumber(33) 
            for i=0,1 do
                local m = bit.band(input,bit.lshift(1,(4+i)))  --主钩-上 下限位
                if m==0 then
                  packet[ crane_state[40+i] ] = 0
                else
                  packet[ crane_state[40+i] ] = 1
                end
            end
            local m = bit.band(input,bit.lshift(1,13))  --主钩-抱闸状态
            if m==0 then
              packet[ crane_state[42] ] = 0
            else
              packet[ crane_state[42] ] = 1
            end
            
            if packet["cranetype"]>0 then
                local viceliftstate = bit.lshift(getnumber(62),8)+getnumber(63)                    --副起升机构状态
                if viceliftstate>0 and viceliftstate<5 then
                  packet[ crane_state[47] ] = 1
                else 
                  packet[ crane_state[47] ] = 0
                end
                if (bit.lshift(getnumber(64),8)+getnumber(65))>0 then
                   packet[ crane_state[47] ] = 2                                         --副起升机构状态
                end 
                packet[ crane_state[25] ] = bit.lshift(getnumber(66),8)+getnumber(67)  --副钩状态-控制方式
                packet[ crane_state[27] ] = (bit.lshift(getnumber(70),8)+getnumber(71))/100  --副钩状态-离地高度
                packet[ crane_state[34] ] = (bit.lshift(getnumber(72),8)+getnumber(73))/100    --副钩状态-钩载显示
                if packet[ crane_state[25] ]>0 then
                  packet[ crane_state[29] ] = bit.lshift(getnumber(74),8)+getnumber(75)   --副钩状态-变频器状态
                  packet[ crane_state[33] ] = bit.lshift(getnumber(76),8)+getnumber(77)    --副钩状态-故障代码
                end
                --通过起升状态判断运行方向和运行速度
                if viceliftstate==1 or viceliftstate==2 then  
                    packet[ crane_state[26] ] = 1
                elseif viceliftstate==3 or viceliftstate==4 then
                    packet[ crane_state[26] ] = 0
                end
                if viceliftstate==1 or viceliftstate==3 then  
                    packet[ crane_state[28] ] = 0
                elseif viceliftstate==2 or viceliftstate==4 then
                    packet[ crane_state[28] ] = 1
                end
                --解析副钩数字量输入 bit4 5 13对应上下限位 抱闸反馈状态
                local input = bit.lshift(getnumber(68),8) + getnumber(69) 
                for i=0,1 do
                    local m = bit.band(input,bit.lshift(1,(4+i)))  --副钩-上 下限位
                    if m==0 then
                      packet[ crane_state[30+i] ] = 0
                    else
                      packet[ crane_state[30+i] ] = 1
                    end
                end
                local m = bit.band(input,bit.lshift(1,13))  --副钩-抱闸状态
                if m==0 then
                  packet[ crane_state[32] ] = 0
                else
                  packet[ crane_state[32] ] = 1
                end
            end --副钩end
            
            local small1state = bit.lshift(getnumber(42),8)+getnumber(43)                    --小车1机构状态
            if small1state>1 then
              packet[ crane_state[48] ] = 1
            else 
              packet[ crane_state[48] ] = 0
            end
            if (bit.lshift(getnumber(88),8)+getnumber(89))>0 then
               packet[ crane_state[48] ] = 2                                         --小车1机构状态
            end 

            --通过小车状态判断运行方向和运行速度
            if small1state==2 or small1state==4 then  
                packet[ crane_state[17] ] = 1
            elseif small1state==3 or small1state==5 then
                packet[ crane_state[17] ] = 0
            end
            if small1state==2 or small1state==3 then  
                packet[ crane_state[19] ] = 0
            elseif small1state==4 or small1state==5 then
                packet[ crane_state[19] ] = 1
            end

            --解析小车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
            for i=0,2 do
                local m = bit.band(getnumber(45),bit.lshift(1,(5+i)))  --小车-正转限位 反转限位 抱闸反馈
                if m==0 then
                  packet[ crane_state[21+i] ] = 0
                else
                  packet[ crane_state[21+i] ] = 1
                end
            end

            packet[ crane_state[18] ] = (bit.lshift(getnumber(46),8)+getnumber(47))/100--小车1状态-位置信息
            packet[ crane_state[20] ] = bit.lshift(getnumber(50),8)+getnumber(51) --小车1状态-变频器状态
            packet[ crane_state[24] ] = bit.lshift(getnumber(48),8)+getnumber(49) --小车1状态-故障代码            
             
            if packet["cranetype"]>1 then 
                local small2state = bit.lshift(getnumber(78),8)+getnumber(79)                    --小车2机构状态
                if(small2state>1) then
                  packet[ crane_state[49] ] = 1
                else 
                  packet[ crane_state[49] ] = 0
                end
                if (bit.lshift(getnumber(90),8)+getnumber(91))>0 then
                   packet[ crane_state[49] ] = 2                                         --小车2机构状态
                end  

                --通过小车状态判断运行方向和运行速度
                if small2state==2 or small2state==4 then  
                    packet[ crane_state[9] ] = 1
                elseif small2state==3 or small2state==5 then
                    packet[ crane_state[9] ] = 0
                end
                if small2state==2 or small2state==3 then  
                    packet[ crane_state[11] ] = 0
                elseif small2state==4 or small2state==5 then
                    packet[ crane_state[11] ] = 1
                end

                --解析小车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
                for i=0,2 do
                    local m = bit.band(getnumber(81),bit.lshift(1,(5+i)))  --小车-正转限位 反转限位 抱闸反馈
                    if m==0 then
                      packet[ crane_state[13+i] ] = 0
                    else
                      packet[ crane_state[13+i] ] = 1
                    end
                end

                packet[ crane_state[10] ] = (bit.lshift(getnumber(82),8)+getnumber(83))/100 --小车2状态-位置信息
                packet[ crane_state[12] ] = bit.lshift(getnumber(86),8)+getnumber(87) --小车2状态-变频器状态
                packet[ crane_state[16] ] = bit.lshift(getnumber(84),8)+getnumber(85) --小车2状态-故障代码 
            end

            local largestate = bit.lshift(getnumber(52),8)+getnumber(53)                    --大车机构状态
            if largestate>1 then
              packet[ crane_state[50] ] = 1
            else 
              packet[ crane_state[50] ] = 0
            end
            if (bit.lshift(getnumber(92),8)+getnumber(93))>0 then
               packet[ crane_state[50] ] = 2                                         --大车机构状态
            end 

            --通过大车状态判断运行方向和运行速度
            if largestate==2 or largestate==4 then  
                packet[ crane_state[1] ] = 1
            elseif largestate==3 or largestate==5 then
                packet[ crane_state[1] ] = 0
            end
            if largestate==2 or largestate==3 then  
                packet[ crane_state[3] ] = 0
            elseif largestate==4 or largestate==5 then
                packet[ crane_state[3] ] = 1
            end

            --解析小车数字量输入 bit5 6 7对应正转反转高速 正转限位反转限位抱闸反馈（电机过热暂时没有数据）
            for i=0,2 do
                local m = bit.band(getnumber(55),bit.lshift(1,(5+i)))  --大车-正转限位 反转限位 抱闸反馈
                if m==0 then
                  packet[ crane_state[5+i] ] = 0
                else
                  packet[ crane_state[5+i] ] = 1
                end
            end

            packet[ crane_state[2] ] = (bit.lshift(getnumber(56),8)+getnumber(57))/100  --大车状态-位置信息
            packet[ crane_state[4] ] = bit.lshift(getnumber(60),8)+getnumber(61)  --大车状态-变频器状态
            packet[ crane_state[8] ] = bit.lshift(getnumber(58),8)+getnumber(59)  --大车状态-故障代码 

            if((bit.lshift(getnumber(12),8)+getnumber(13))==4) then  --电源状态
                packet[ crane_state[51] ] = 1
            else 
                packet[ crane_state[51] ] = 0
            end
            --解析系统输入 bit0 1 2 3 4启动 复位 急停相序错误 主接触器
            for i=0,4 do
                local m = bit.band(getnumber(17),bit.lshift(1,i))
                if m==0 then
                  packet[ crane_state[52+i] ] = 0
                else
                  packet[ crane_state[52+i] ] = 1
                end
            end
         ------------------------------------------------   到这个地方 转码都ok
        ------------------------------故障表数据--------------------------------
        elseif func==0x06 then
            packet[ cmds[3] ] = 'func-fault'

            packet['faultnum'] = bit.lshift(getnumber(12),8)+getnumber(13) --故障个数
            local faultnum = bit.lshift(getnumber(12),8)+getnumber(13) --故障个数
            if faultnum>20 then
               faultnum = 20
            end
            local buff = {}
            for i=1,faultnum do
                for j=1,9 do
                    buff[(i-1)*9+j] = bit.lshift(getnumber(14+(j-1)*2+(i-1)*18),8)+getnumber(15+(j-1)*2+(i-1)*18)
                end
                packet[ fault_state[1+(i-1)*4] ] = buff[(i-1)*9+1]
                packet[ fault_state[2+(i-1)*4] ] = buff[(i-1)*9+2]
                packet[ fault_state[3+(i-1)*4] ] = buff[(i-1)*9+3]
                packet[ fault_state[4+(i-1)*4] ] = buff[(i-1)*9+4]..'-'..buff[(i-1)*9+5]..'-'..buff[(i-1)*9+6]..'-'..buff[(i-1)*9+7]..'-'..buff[(i-1)*9+8]..'-'..buff[(i-1)*9+9]
            end
            
          ------------------------------变频器数据--------------------------------  
        elseif func==0x05 then
            packet[ cmds[3] ] = 'func-invert'

            packet[ 'cranetype' ] = bit.lshift(getnumber(12),8)+getnumber(13)
            ----小车变频----
            for i=1,6 do   --目标速度 反馈速度 输出电流 输出电压 母线电压 输出转矩
              packet['invt_s1_'..invertstate[i] ] = bit.lshift(getnumber(14+(i-1)*2),8)+getnumber(15+(i-1)*2)
            end
            packet['invt_s1_'..invertstate[7] ] = bit.lshift(getnumber(80),8)+getnumber(81) --运行状态
            packet['invt_s1_'..invertstate[8] ] = bit.lshift(getnumber(28),8)+getnumber(29) --散热器温度
            for i=1,6 do   --u v w相瞬时电压 u v w相瞬时电流
              packet['invt_s1_'..invertstate[8+i] ] = bit.lshift(getnumber(30+(i-1)*2),8)+getnumber(31+(i-1)*2)
            end
            for i=0,7 do  --数字量输入x0.....x7
                local m = bit.band(getnumber(43),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_s1_x'..i ] = 0
                else
                  packet[ 'invt_s1_x'..i ] = 1
                end
            end
            for i=0,5 do  --数字量输出y0.....y5
                local m = bit.band(getnumber(45),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_s1_y'..i ] = 0
                else
                  packet[ 'invt_s1_y'..i ] = 1
                end
            end
            for i=15,30 do   --电机信息  变频器信息
              packet['invt_s1_'..invertstate[i] ] = bit.lshift(getnumber(48+(i-15)*2),8)+getnumber(49+(i-15)*2)
            end
            for i=1,30,1 do  
                local dot = invert_dot[ invertstate[i] ]
                if dot >=0 then
                  packet['invt_s1_'..invertstate[i] ] = packet['invt_s1_'..invertstate[i] ] / ( 10^dot )
                end
            end
            ----大车变频---- +68
            for i=1,6 do   --目标速度 反馈速度 输出电流 输出电压 母线电压 输出转矩
              packet['invt_l_'..invertstate[i] ] = bit.lshift(getnumber(82+(i-1)*2),8)+getnumber(83+(i-1)*2)
            end
            packet['invt_l_'..invertstate[7] ] = bit.lshift(getnumber(148),8)+getnumber(149) --运行状态
            packet['invt_l_'..invertstate[8] ] = bit.lshift(getnumber(96),8)+getnumber(97) --散热器温度
            for i=1,6 do   --u v w相瞬时电压 u v w相瞬时电流
              packet['invt_l_'..invertstate[8+i] ] = bit.lshift(getnumber(98+(i-1)*2),8)+getnumber(99+(i-1)*2)
            end
            for i=0,7 do  --数字量输入x0.....x7
                local m = bit.band(getnumber(111),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_l_x'..i ] = 0
                else
                  packet[ 'invt_l_x'..i ] = 1
                end
            end
            for i=0,5 do  --数字量输出y0.....y5
                local m = bit.band(getnumber(113),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_l_y'..i ] = 0
                else
                  packet[ 'invt_l_y'..i ] = 1
                end
            end
            for i=15,30 do   --电机信息  变频器信息
              packet['invt_l_'..invertstate[i] ] = bit.lshift(getnumber(116+(i-15)*2),8)+getnumber(117+(i-15)*2)
            end
            for i=1,30,1 do  
                local dot = invert_dot[ invertstate[i] ]
                if dot >=0 then
                  packet['invt_l_'..invertstate[i] ] = packet['invt_l_'..invertstate[i] ] / ( 10^dot )
                end
            end
            ----主钩变频----68*2=136
            for i=1,6 do   --目标速度 反馈速度 输出电流 输出电压 母线电压 输出转矩
              packet['invt_m_'..invertstate[i] ] = bit.lshift(getnumber(150+(i-1)*2),8)+getnumber(151+(i-1)*2)
            end
            packet['invt_m_'..invertstate[7] ] = bit.lshift(getnumber(216),8)+getnumber(217) --运行状态
            packet['invt_m_'..invertstate[8] ] = bit.lshift(getnumber(164),8)+getnumber(165) --散热器温度
            for i=1,6 do   --u v w相瞬时电压 u v w相瞬时电流
              packet['invt_m_'..invertstate[8+i] ] = bit.lshift(getnumber(166+(i-1)*2),8)+getnumber(167+(i-1)*2)
            end
            for i=0,7 do  --数字量输入x0.....x7
                local m = bit.band(getnumber(179),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_m_x'..i ] = 0
                else
                  packet[ 'invt_m_x'..i ] = 1
                end
            end
            for i=0,5 do  --数字量输出y0.....y5
                local m = bit.band(getnumber(181),bit.lshift(1,i))  
                if m==0 then
                  packet[ 'invt_m_y'..i ] = 0
                else
                  packet[ 'invt_m_y'..i ] = 1
                end
            end
            for i=15,30 do   --电机信息  变频器信息
              packet['invt_m_'..invertstate[i] ] = bit.lshift(getnumber(184+(i-15)*2),8)+getnumber(185+(i-15)*2)
            end
            for i=1,30,1 do  
                local dot = invert_dot[ invertstate[i] ]
                if dot >=0 then
                  packet['invt_m_'..invertstate[i] ] = packet['invt_m_'..invertstate[i] ] / ( 10^dot )
                end
            end
            ----副钩变频----68*3=204
            if packet[ 'cranetype' ]>0 then
                for i=1,6 do   --目标速度 反馈速度 输出电流 输出电压 母线电压 输出转矩
                  packet['invt_v_'..invertstate[i] ] = bit.lshift(getnumber(218+(i-1)*2),8)+getnumber(219+(i-1)*2)
                end
                packet['invt_v_'..invertstate[7] ] = bit.lshift(getnumber(284),8)+getnumber(285) --运行状态
                packet['invt_v_'..invertstate[8] ] = bit.lshift(getnumber(232),8)+getnumber(233) --散热器温度
                for i=1,6 do   --u v w相瞬时电压 u v w相瞬时电流
                  packet['invt_v_'..invertstate[8+i] ] = bit.lshift(getnumber(234+(i-1)*2),8)+getnumber(235+(i-1)*2)
                end
                for i=0,7 do  --数字量输入x0.....x7
                    local m = bit.band(getnumber(247),bit.lshift(1,i))  
                    if m==0 then
                      packet[ 'invt_v_x'..i ] = 0
                    else
                      packet[ 'invt_v_x'..i ] = 1
                    end
                end
                for i=0,5 do  --数字量输出y0.....y5
                    local m = bit.band(getnumber(249),bit.lshift(1,i))  
                    if m==0 then
                      packet[ 'invt_v_y'..i ] = 0
                    else
                      packet[ 'invt_v_y'..i ] = 1
                    end
                end
                for i=15,30 do   --电机信息  变频器信息
                  packet['invt_v_'..invertstate[i] ] = bit.lshift(getnumber(252+(i-15)*2),8)+getnumber(253+(i-15)*2)
                end
                for i=1,30,1 do  
                local dot = invert_dot[ invertstate[i] ]
                if dot >=0 then
                  packet['invt_v_'..invertstate[i] ] = packet['invt_v_'..invertstate[i] ] / ( 10^dot )
                end
            end
            end
            ----2号小车变频---- 68*4=272
            if packet[ 'cranetype' ]>1 then
                for i=1,6 do   --目标速度 反馈速度 输出电流 输出电压 母线电压 输出转矩
                  packet['invt_s2_'..invertstate[i] ] = bit.lshift(getnumber(286+(i-1)*2),8)+getnumber(287+(i-1)*2)
                end
                packet['invt_s2_'..invertstate[7] ] = bit.lshift(getnumber(352),8)+getnumber(353) --运行状态
                packet['invt_s2_'..invertstate[8] ] = bit.lshift(getnumber(300),8)+getnumber(301) --散热器温度
                for i=1,6 do   --u v w相瞬时电压 u v w相瞬时电流
                  packet['invt_s2_'..invertstate[8+i] ] = bit.lshift(getnumber(302+(i-1)*2),8)+getnumber(303+(i-1)*2)
                end
                for i=0,7 do  --数字量输入x0.....x7
                    local m = bit.band(getnumber(315),bit.lshift(1,i))  
                    if m==0 then
                      packet[ 'invt_s2_x'..i ] = 0
                    else
                      packet[ 'invt_s2_x'..i ] = 1
                    end
                end
                for i=0,5 do  --数字量输出y0.....y5
                    local m = bit.band(getnumber(317),bit.lshift(1,i))  
                    if m==0 then
                      packet[ 'invt_s2_y'..i ] = 0
                    else
                      packet[ 'invt_s2_y'..i ] = 1
                    end
                end
                for i=15,30 do   --电机信息  变频器信息
                  packet['invt_s2_'..invertstate[i] ] = bit.lshift(getnumber(320+(i-15)*2),8)+getnumber(321+(i-15)*2)
                end
                for i=1,30,1 do  
                local dot = invert_dot[ invertstate[i] ]
                if dot >=0 then
                  packet['invt_s2_'..invertstate[i] ] = packet['invt_s2_'..invertstate[i] ] / ( 10^dot )
                end
            end
            end
     
        end  --判断数据类型最后的结束end

        --和校验
        for i=1,(templen+4),1 do        
          table.insert(FCS_Array,getnumber(i))
        end

        if(utilCalcFCS(FCS_Array,#FCS_Array) == FCS_Value) then
          packet['status'] = 'SUCCESS'
        else
          packet = {}
          packet['status'] = 'FCS-ERROR'
        end

    end --判断头是否正确的end

    return Json(packet)
end

return _M
