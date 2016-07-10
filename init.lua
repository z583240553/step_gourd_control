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
--[[
-----------------------------------起升页面json--------------------------------------
local main_state = {
  [1] = "main_state",             --主钩的机构状态
  [2] = "main_fault",             --主钩的故障信息
  [3] = "main_ctrlmode",          --主钩的控制方式
  [4] = "main_rundir",            --主钩的运行方向
  [5] = "main_runspd",            --主钩的运行速度
  [6] = "main_uplimit",          --主钩的上限位
  [7] = "main_downlimit",        --主钩的下限位
  [8] = "main_hotfdk",           --主钩的热继反馈
  [9] = "main_forfdk",           --主钩的正转反馈
  [10] = "main_revfdk",           --主钩的反转反馈
  [11] = "main_hsfdk",            --主钩的高速反馈
  [12] = "main_lsfdk",            --主钩的低速反馈
  [13] = "main_l/hdelay",         --主钩的低/高延迟
  [14] = "main_h/ldelay",         --主钩的高/低延迟
  [15] = "main_liftheight",       --主钩的起升高度
  [16] = "main_height",            --主钩的离地高度
  [17] = "main_realpulse",        --主钩的实时脉冲数
  [18] = "main_brkdis",           --主钩的刹车距离
  [19] = "main_motorcur",         --主钩的电机电流
  [20] = "main_motorvolt",        --主钩的电机电压
  [21] = "main_bfknum",           --主钩的刹车次数
  [22] = "main_mruntime",         --主钩的电机运行时间
  [23] = "main_bruntime",         --主钩的抱闸运行时间
  [24] = "main_power",            --主钩的有功功率
  [25] = "main_mefficiency",      --主钩的电机效率
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
  [6] = "vice_uplimit",          --副钩的上限位
  [7] = "vice_downlimit",        --副钩的下限位
  [8] = "vice_hotfdk",           --副钩的热继反馈
  [9] = "vice_forfdk",           --副钩的正转反馈
  [10] = "vice_revfdk",           --副钩的反转反馈
  [11] = "vice_hsfdk",            --副钩的高速反馈
  [12] = "vice_lsfdk",            --副钩的低速反馈
  [13] = "vice_l/hdelay",         --副钩的低/高延迟
  [14] = "vice_h/ldelay",         --副钩的高/低延迟
  [15] = "vice_liftheight",       --副钩的起升高度
  [16] = "vice_height",           --副钩的离地高度
  [17] = "vice_realpulse",        --副钩的实时脉冲数
  [18] = "vice_brkdis",           --副钩的刹车距离
  [19] = "vice_motorcur",         --副钩的电机电流
  [20] = "vice_motorvolt",        --副钩的电机电压
  [21] = "vice_bfknum",           --副钩的刹车次数
  [22] = "vice_mruntime",         --副钩的电机运行时间
  [23] = "vice_bruntime",         --副钩的抱闸运行时间
  [24] = "vice_power",            --副钩的有功功率
  [25] = "vice_mefficiency",      --副钩的电机效率
  [26] = "vice_hook",              --副钩的钩载显示
  [27] = "vice_warn",              --副钩的预警值
  [28] = "vice_alarm",             --副钩的报警值
}
]]
--[[
-----------------------------------小车页面json--------------------------------------
local small1_state = {
  [1] = "small1_state",             --小车1的机构状态
  [2] = "small1_fault",             --小车1的故障信息
  [3] = "small1_rundir",            --小车1的运行方向
  [4] = "small1_runspd",            --小车1的运行速度
  [5] = "small1_forlimit",          --小车1的正转限位
  [6] = "small1_revlimit",          --小车1的反转限位
  [7] = "small1_hotfdk",            --小车1的热继反馈
  [8] = "small1_brkfdk",            --小车1的抱闸反馈
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
  [7] = "small2_hotfdk",            --小车2的热继反馈
  [8] = "small2_brkfdk",            --小车2的抱闸反馈
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
]]
--[[
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
]]
-----------------------------------控制器页面json--------------------------------------
for j=1,10,1 do
  ctrl_state[i] = "ctrl_x0"..(i-1)  --X00、、X09
end
for j=1,10,1 do
  ctrl_state[10+i] = "ctrl_x1"..(i-1) --X10、、X19
end
for j=1,10,1 do
  ctrl_state[20+i] = "ctrl_x2"..(i-1) --X20、、X29
end
for j=1,2,1 do
  ctrl_state[30+i] = "ctrl_x3"..(i-1) --X30、X31
end
for j=1,2,1 do
  ctrl_state[32+i] = "ctrl_x5"..(i-1) --X50、X51
end
for j=1,2,1 do
  ctrl_state[34+i] = "ctrl_x6"..(i-1) --X60、X61
end
for j=1,2,1 do
  ctrl_state[36+i] = "ctrl_x7"..(i-1) --X70、X71
end
for j=1,8,1 do
  ctrl_state[38+i] = "ctrl_k"..(i) --K1、、K8
end
for j=1,4,1 do
  ctrl_state[46+i] = "ctrl_y5"..(i-1) --Y50、、Y53
end
for j=1,4,1 do
  ctrl_state[50+i] = "ctrl_y6"..(i-1) --Y60、、Y63
end
for j=1,4,1 do
  ctrl_state[54+i] = "ctrl_y7"..(i-1) --Y70、、Y73
end

local ctrl_state ={
  [59] = "ctrl_cranetype",        --起重机类型
  [60] = "ctrl_weight",           --称重吨位
  [61] = "ctrl_signal",           --称重采集信号
  [62] = "ctrl_warn",             --称重预警值
  [63] = "ctrl_alarm",            --称重报警值
}
--[[
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
  [32] = "crn_v_flt",                 --副钩状态-故障信息
  [33] = "crn_v_fltcode",             --副钩状态-故障代码
  [34] = "crn_v_weight",              --副钩状态-钩载显示
  [35] = "crn_m_ctrl",                --主钩状态-控制方式
  [36] = "crn_m_rundis",              --主钩状态-运行方向
  [37] = "crn_m_height",              --主钩状态-离地高度
  [38] = "crn_m_runspd",              --主钩状态-运行速度
  [39] = "crn_m_invtstate",           --主钩状态-变频器状态
  [40] = "crn_m_uplimit",             --主钩状态-上限位
  [41] = "crn_m_downlimit",           --主钩状态-下限位
  [42] = "crn_m_flt",                 --主钩状态-故障信息
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
for j=1,4,1 do
  crane_state[56+i] = "crn_"..i.."_mainup"    --i档主钩上升
end
for j=1,4,1 do
  crane_state[60+i] = "crn_"..i.."_maindown"  --i档主钩下降
end
for j=1,4,1 do
  crane_state[64+i] = "crn_"..i.."_viceup"    --i档副钩上升
end
for j=1,4,1 do
  crane_state[68+i] = "crn_"..i.."_vicedown"  --i档副钩下降
end
for j=1,4,1 do
  crane_state[72+i] = "crn_"..i.."_small1for" --i档小车1正转
end
for j=1,4,1 do
  crane_state[76+i] = "crn_"..i.."_small1rev" --i档小车1反转
end
for j=1,4,1 do
  crane_state[80+i] = "crn_"..i.."_small2for" --i档小车2正转
end
for j=1,4,1 do
  crane_state[84+i] = "crn_"..i.."_small2rev" --i档小车2反转
end
for j=1,4,1 do
  crane_state[88+i] = "crn_"..i.."_largefor"  --i档大车正转
end
for j=1,4,1 do
  crane_state[92+i] = "crn_"..i.."_largerev"  --i档大车反转
end
]]

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
    packet['test0'] = 'in'
    if ( head1 == 0x3B and head2 == 0x31 ) then 
         packet['test1'] = 'head ok'
      
        local templen = bit.lshift( getnumber(3) , 8 ) + getnumber(4) --收到的数据长度
        --templen will be the important parameter in the next calculate
        --in different task some number mabey be changed 
        --to avoid unnecessary problem
        --packet[ cmds[0] ] = templen
        packet[ cmds[1] ] = bit.lshift( getnumber(5) , 8 ) + bit.lshift( getnumber(6) , 16 ) + bit.lshift( getnumber(7) , 8 ) + getnumber(8)

        local func = getnumber(10)  --数据类型功能码  
        packet['func'] = func
        if func == 0x01 then

            packet[ cmds[3] ] = 'func-controller'
            FCS_Value = bit.lshift(getnumber(44),8) + getnumber(45)

            packet[ ctrl_state[30] ] = 11
            packet[ ctrl_state[31] ] = 12
            packet[ ctrl_state[32] ] = 13
            
            for i=0,4,1 do  
                packet[ctrl_state[59+i]] =  bit.lshift( getnumber(34+i*2) , 8 ) + getnumber(35+i*2) --起重机类型、吨位、采集信号、预警值、报警值  
            end
            --和校验
            for i=1,43,1 do        
              table.insert(FCS_Array,getnumber(i))
            end

        end  --大if判断最后的结束end

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
