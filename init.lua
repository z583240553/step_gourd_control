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


local num = 1
local parameter_cmds = {}

for k,v in ipairs(para_0) do
  local l = para_1[v]
  for i=0,l-1,1 do
    if ("P71_" == v) then
      if(i<=25) then
        parameter_cmds[num] = v..string.format("%02d",i)
      else
        parameter_cmds[num] = v..string.format("%02d",i+7)
      end
    else
      parameter_cmds[num] = v..string.format("%02d",i)
    end
    num = num + 1
  end
end

local fault_cmds = {}
local faultcmds = {
    [1] = "real_speed",
    [2] = "given_speed",
    [3] = "bus_voltage",
    [4] = "current",
    [5] = "code",
}

for i=0,7,1 do
  for j=1,5,1 do
    fault_cmds[i*5+j] = "fault"..i.."_"..faultcmds[j] 
  end
end

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
      --templen will be the important parameter in the next calculate
      --in different task some number mabey be changed 
      --to avoid unnecessary problem
      --packet[ cmds[0] ] = templen
      packet[ cmds[1] ] = bit.lshift( getnumber(5) , 8 ) + bit.lshift( getnumber(6) , 16 ) + bit.lshift( getnumber(7) , 8 ) + getnumber(8)

      --local mode = getnumber(9)
      --if mode == 1 then
          --packet[ cmds[2] ] = 'Mode-485'
        --else
          --packet[ cmds[2] ] = 'Mode-232'
      --end

      local func = getnumber(10)  --数据类型功能码
      -------------------起升数据（有无副钩数据由起重机机构来判断）----------------------
      if func == 0x02 then
          packet[ cmds[3] ] = 'func-lifting'
          FCS_Value = bit.lshift( getnumber(templen+5) , 8 ) + getnumber(templen+6)
      
          packet["cranetype"] = bit.lshift( getnumber(12) , 8 ) + getnumber(13)  --起重机类型
          local cranetype = bit.lshift( getnumber(12) , 8 ) + getnumber(13)      --0：3机构:1：4机构:2：5机构
          
          for i=1,3,1 do  
          	  packet[main_state[i]] =  bit.lshift( getnumber(12+i*2) , 8 ) + getnumber(13+i*2) --状态、故障、控制方式   
          end
          --解析主起升数字量输入 bit0 1 2 4 5 13对应正转反转高速 正转限位反转限位抱闸状态
          local m = bit.band(getnumber(21),bit.lshift(1,0)) --主钩-运行方向
          if m~=0 then
            packet[main_state[4]] = 1
          end
          local m = bit.band(getnumber(21),bit.lshift(1,1))
          if m~=0 then
            packet[main_state[4]] = 0
          end
          local m = bit.band(getnumber(21),bit.lshift(1,2))  --主钩-运行速度
          if m==0 then
            packet[main_state[5]] = 0
          else
            packet[main_state[5]] = 1
          end
          for i=0,3 do
              local m = bit.band(getnumber(21),bit.lshift(1,(4+i))  --主钩-上限位
              if m==0 then
                packet[main_state[6+i]] = 0
              else
                packet[main_state[6+i]] = 1
              end
          end
          for i=0,4 do
              local m = bit.band(getnumber(20),bit.lshift(1,i))  --主钩-主钩的反转反馈
              if m==0 then
                packet[main_state[10+i]] = 0
              else
                packet[main_state[10+i]] = 1
              end
          end
          for i=1,14,1 do  
              packet[main_state[14+i]] =  bit.lshift( getnumber(22+i*2) , 8 ) + getnumber(23+i*2) --起升高度、离地距离、....、报警值   
          end

          if(cranetype>0) then   --副钩出现 4机构和5机构
              for i=1,3,1 do  
                  packet[vice_state[i]] =  bit.lshift( getnumber(50+i*2) , 8 ) + getnumber(51+i*2) --状态、故障、控制方式   
              end
              --解析副起升数字量输入 bit0 1 2 4 5 13对应正转反转高速 正转限位反转限位抱闸状态
              local m = bit.band(getnumber(59),bit.lshift(1,0)) --副钩-运行方向
              if m~=0 then
                packet[vice_state[4]] = 1
              end
              local m = bit.band(getnumber(59),bit.lshift(1,1))
              if m~=0 then
                packet[vice_state[4]] = 0
              end
              local m = bit.band(getnumber(59),bit.lshift(1,2))  --副钩-运行速度
              if m==0 then
                packet[vice_state[5]] = 0
              else
                packet[vice_state[5]] = 1
              end
              for i=0,3 do
                  local m = bit.band(getnumber(59),bit.lshift(1,(4+i))  --副钩-上限位
                  if m==0 then
                    packet[vice_state[6+i]] = 0
                  else
                    packet[vice_state[6+i]] = 1
                  end
              end
              for i=0,4 do
                  local m = bit.band(getnumber(58),bit.lshift(1,i))  --副钩-反转反馈
                  if m==0 then
                    packet[vice_state[10+i]] = 0
                  else
                    packet[vice_state[10+i]] = 1
                  end
              end
              for i=1,14,1 do  
                  packet[vice_state[14+i]] =  bit.lshift( getnumber(60+i*2) , 8 ) + getnumber(61+i*2) --起升高度、离地距离、....、报警值   
              end
          end
          --和校验
          for i=1,(templen+4),1 do        
          table.insert(FCS_Array,getnumber(i))
          end
      ---------------小车数据（有无2号小车数据由起重机机构来判断）---------------------
      else if func == 0x03 then
          packet[ cmds[3] ] = 'func-small'
          FCS_Value = bit.lshift( getnumber(106) , 8 ) + getnumber(107)  

          packet["cranetype"] = bit.lshift( getnumber(12) , 8 ) + getnumber(13)  --起重机类型
          local cranetype = bit.lshift( getnumber(12) , 8 ) + getnumber(13)      --0：3机构:1：4机构:2：5机构
            
          for i=1,2,1 do  
              packet[small1_state[i]] =  bit.lshift( getnumber(12+i*2) , 8 ) + getnumber(13+i*2) --状态、故障   
          end
          --解析小车数字量输入 bit0 1 2 4 5 6 7 8 对应正转反转高速 正转限位反转限位热继抱闸状态
          local m = bit.band(getnumber(21),bit.lshift(1,0)) --小车-运行方向
          if m~=0 then
            packet[small1_state[3]] = 1
          end
          local m = bit.band(getnumber(21),bit.lshift(1,1))
          if m~=0 then
            packet[small1_state[3]] = 0
          end
          local m = bit.band(getnumber(21),bit.lshift(1,2))  --小车-运行速度
          if m==0 then
            packet[small1_state[4]] = 0
          else
            packet[small1_state[4]] = 1
          end
          for i=0,3 do
              local m = bit.band(getnumber(21),bit.lshift(1,(5+i))  --小车-正转限位
              if m==0 then
                packet[small1_state[5+i]] = 0
              else
                packet[small1_state[5+i]] = 1
              end
          end
          for i=1,18,1 do  
              packet[small1_state[8+i]] =  bit.lshift( getnumber(22+i*2) , 8 ) + getnumber(23+i*2) --行程、位置信息、....、散热器温度  
          end

          if(cranetype>1) then   --2号小车出现 5机构
              for i=1,2,1 do  
                  packet[small2_state[i]] =  bit.lshift( getnumber(58+i*2) , 8 ) + getnumber(59+i*2) --状态、故障   
              end
              --解析2号小车数字量输入 bit0 1 2 4 5 6 7 8 对应正转反转高速 正转限位反转限位热继抱闸状态
              local m = bit.band(getnumber(67),bit.lshift(1,0)) --小车2-运行方向
              if m~=0 then
                packet[small2_state[3]] = 1
              end
              local m = bit.band(getnumber(67),bit.lshift(1,1))
              if m~=0 then
                packet[small2_state[3]] = 0
              end
              local m = bit.band(getnumber(67),bit.lshift(1,2))  --小车2-运行速度
              if m==0 then
                packet[small2_state[4]] = 0
              else
                packet[small2_state[4]] = 1
              end
              for i=0,3 do
                  local m = bit.band(getnumber(67),bit.lshift(1,(5+i))  --小车2-正转限位
                  if m==0 then
                    packet[small2_state[5+i]] = 0
                  else
                    packet[small2_state[5+i]] = 1
                  end
              end
              for i=1,18,1 do  
                  packet[small2_state[8+i]] =  bit.lshift( getnumber(68+i*2) , 8 ) + getnumber(69+i*2) --行程、位置信息、....、散热器温度 值   
              end

          end
          --和校验
          for i=1,105,1 do        
              table.insert(FCS_Array,getnumber(i))
          end
      ---------------------------------大车数据--------------------------------
      else if func == 0x04 then
          packet[ cmds[3] ] = 'func-large'
          FCS_Value = bit.lshift( getnumber(58) , 8 ) + getnumber(59)

          for i=1,2,1 do  
              packet[large_state[i]] =  bit.lshift( getnumber(10+i*2) , 8 ) + getnumber(11+i*2) --状态、故障   
          end
          --解析大车数字量输入 bit0 1 2 4 5 6 7 8 对应正转反转高速 正转限位反转限位热继抱闸状态
          local m = bit.band(getnumber(19),bit.lshift(1,0)) --大车-运行方向
          if m~=0 then
            packet[large_state[3]] = 1
          end
          local m = bit.band(getnumber(19),bit.lshift(1,1))
          if m~=0 then
            packet[large_state[3]] = 0
          end
          local m = bit.band(getnumber(19),bit.lshift(1,2))  --大车-运行速度
          if m==0 then
            packet[large_state[4]] = 0
          else
            packet[large_state[4]] = 1
          end
          for i=0,3 do
              local m = bit.band(getnumber(19),bit.lshift(1,(5+i))  --大车-正转限位
              if m==0 then
                packet[large_state[5+i]] = 0
              else
                packet[large_state[5+i]] = 1
              end
          end
          for i=1,18,1 do  
              packet[large_state[8+i]] =  bit.lshift( getnumber(20+i*2) , 8 ) + getnumber(21+i*2) --行程、位置信息、....、散热器温度  
          end
          --和校验
          for i=1,57,1 do        
            table.insert(FCS_Array,getnumber(i))
          end
      ----------------------------------控制器数据--------------------------------------
      else if func == 0x01 then
          packet[ cmds[3] ] = 'func-controller'
          FCS_Value = bit.lshift( getnumber(44) , 8 ) + getnumber(45)

          --解析每位bit
          for i=0,2 do
              for j=0,9 do    --X00组 X10组 X20组
                  local m = bit.band((bit.lshift(getnumber(12+i*2),8)+getnumber(13+i*2)),bit.lshift(1,i))
                  if m==0 then
                    packet[ctrl_state[j+1+i*10]] = 0
                  else
                    packet[ctrl_state[j+1+i*10]] = 1
                  end  
              end
          end
          for j=0,1 do    --X30组
              local m = bit.band(getnumber(33),bit.lshift(1,j))
              if m==0 then
                packet[ctrl_state[31+j]] = 0
              else
                packet[ctrl_state[31+j]] = 1
              end  
          end
          for i=0,2 do    --X50组 X60组 X70组
              for j=0,1 do    
                  local m = bit.band(getnumber(19+i*2),bit.lshift(1,j))
                  if m==0 then
                    packet[ctrl_state[33+j+i*2]] = 0
                  else
                    packet[ctrl_state[33+j+i*2]] = 1
                  end  
              end
          end
          for j=0,7 do     --K0组
              local m = bit.band((bit.lshift(getnumber(24),8)+getnumber(25)),bit.lshift(1,j))
              if m==0 then
                packet[ctrl_state[39+j]] = 0
              else
                packet[ctrl_state[39+j]] = 1
              end  
          end
          for i=0,2 do    --Y50组 Y60组 Y70组
              for j=0,3 do    
                  local m = bit.band(getnumber(27+i*2),bit.lshift(1,j))
                  if m==0 then
                    packet[ctrl_state[47+j+i*4]] = 0
                  else
                    packet[ctrl_state[47+j+i*4]] = 1
                  end  
              end
          end
          for i=0,4,1 do  
              packet[ctrl_state[59+i]] =  bit.lshift( getnumber(34+i*2) , 8 ) + getnumber(35+i*2) --起重机类型、吨位、采集信号、预警值、报警值  
          end

          --和校验
          for i=1,43,1 do        
            table.insert(FCS_Array,getnumber(i))
          end
      ----------------------------------起重主监控数据--------------------------------------
      else if func == 0x00 then
          packet[ cmds[3] ] = 'func-crane'
          FCS_Value = bit.lshift( getnumber(88) , 8 ) + getnumber(89)

          packet["cranetype"] = bit.lshift(getnumber(14),8) + getnumber(15)
          local cranetype = bit.lshift(getnumber(14),8) + getnumber(15)      --0：3机构:1：4机构:2：5机构

          packet[crane_state[45]] = bit.lshift(getnumber(20),8)+getnumber(21)    --整机状态
          if((bit.lshift(getnumber(22),8)+getnumber(23))>0) then
             packet[crane_state[45]] = 2                                         --整机状态
          end

          local x = bit.lshift(getnumber(26),8)+getnumber(27)                    --主起升机构状态
          if(x>0 and x<5 ) then
            packet[crane_state[46]] = 1
          else 
            packet[crane_state[46]] = 0
          end
          if((bit.lshift(getnumber(28),8)+getnumber(29))>0)
             packet[crane_state[46]] = 2                                         --主起升机构状态
          end
          packet[crane_state[35]] = bit.lshift(getnumber(30),8)+getnumber(31)  --主钩状态-控制方式
          packet[crane_state[37]] = bit.lshift(getnumber(34),8)+getnumber(35)  --主钩状态-离地高度
          packet[crane_state[44]] = bit.lshift(getnumber(36),8)+getnumber(37)    --主钩状态-钩载显示
          if((bit.lshift(getnumber(30),8)+getnumber(31))>0) then
            packet[crane_state[39]] = bit.lshift(getnumber(38),8)+getnumber(39)   --主钩状态-变频器状态
            packet[crane_state[43]] = bit.lshift(getnumber(40),8)+getnumber(41)    --主钩状态-故障代码  
          end
          --解析主起升数字量输入 bit0 1 2 4 5 13对应正转反转高速 正转限位反转限位抱闸状态
          local m = bit.band(getnumber(33),bit.lshift(1,0)) --主钩-运行方向
          if m~=0 then
            packet[crane_state[36]] = 1
          end
          local m = bit.band(getnumber(33),bit.lshift(1,1))
          if m~=0 then
            packet[crane_state[36]] = 0
          end
          local m = bit.band(getnumber(33),bit.lshift(1,2))  --主钩-运行速度
          if m==0 then
            packet[crane_state[38]] = 0
          else
            packet[crane_state[38]] = 1
          end
          local m = bit.band(getnumber(33),bit.lshift(1,4))  --主钩-上限位
          if m==0 then
            packet[crane_state[40]] = 0
          else
            packet[crane_state[40]] = 1
          end
          local m = bit.band(getnumber(33),bit.lshift(1,5))  --主钩-下限位
          if m==0 then
            packet[crane_state[41]] = 0
          else
            packet[crane_state[41]] = 1
          end
          local m = bit.band(getnumber(32),bit.lshift(1,5))  --主钩-抱闸状态
          if m==0 then
            packet[crane_state[42]] = 0
          else
            packet[crane_state[42]] = 1
          end
          
          if(cranetype >0)then
              local x = bit.lshift(getnumber(62),8)+getnumber(63)                    --副起升机构状态
              if(x>0 and x<5 ) then
                packet[crane_state[47]] = 1
              else 
                packet[crane_state[47]] = 0
              end
              if((bit.lshift(getnumber(64),8)+getnumber(65))>0)
                 packet[crane_state[47]] = 2                                         --副起升机构状态
              end 
              packet[crane_state[25]] = bit.lshift(getnumber(66),8)+getnumber(67)  --副钩状态-控制方式
              packet[crane_state[27]] = bit.lshift(getnumber(70),8)+getnumber(71)  --副钩状态-离地高度
              packet[crane_state[34]] = bit.lshift(getnumber(72),8)+getnumber(73)    --副钩状态-钩载显示
              if((bit.lshift(getnumber(66),8)+getnumber(67))>0) then
                packet[crane_state[29]] = bit.lshift(getnumber(74),8)+getnumber(75)   --副钩状态-变频器状态
                packet[crane_state[33]] = bit.lshift(getnumber(76),8)+getnumber(77)    --副钩状态-故障代码
              end
              --解析副起升数字量输入 bit0 1 2 4 5 13对应正转反转高速 正转限位反转限位抱闸状态
              local m = bit.band(getnumber(33),bit.lshift(1,0)) --副钩-运行方向
              if m~=0 then
                packet[crane_state[26]] = 1
              end
              local m = bit.band(getnumber(33),bit.lshift(1,1))
              if m~=0 then
                packet[crane_state[26]] = 0
              end
              local m = bit.band(getnumber(33),bit.lshift(1,2))  --副钩-运行速度
              if m==0 then
                packet[crane_state[28]] = 0
              else
                packet[crane_state[28]] = 1
              end
              local m = bit.band(getnumber(33),bit.lshift(1,4))  --副钩-上限位
              if m==0 then
                packet[crane_state[30]] = 0
              else
                packet[crane_state[30]] = 1
              end
              local m = bit.band(getnumber(33),bit.lshift(1,5))  --副钩-下限位
              if m==0 then
                packet[crane_state[31]] = 0
              else
                packet[crane_state[31]] = 1
              end
              local m = bit.band(getnumber(32),bit.lshift(1,5))  --副钩-抱闸状态
              if m==0 then
                packet[crane_state[32]] = 0
              else
                packet[crane_state[32]] = 1
              end
          end

          local x = bit.lshift(getnumber(42),8)+getnumber(43)                    --小车1机构状态
          if(x>2) then
            packet[crane_state[48]] = 1
          else 
            packet[crane_state[48]] = 0
          end
          if((bit.lshift(getnumber(88),8)+getnumber(89))>0)
             packet[crane_state[48]] = 2                                         --小车1机构状态
          end 
          --解析小车数字量输入 bit0 1 2 5 6 7对应正转反转高速 正转限位反转限位抱闸状态
          local m = bit.band(getnumber(45),bit.lshift(1,0)) --小车1状态-运行方向
          if m~=0 then
            packet[crane_state[17]] = 1
          end
          local m = bit.band(getnumber(45),bit.lshift(1,1))
          if m~=0 then
            packet[crane_state[17]] = 0
          end
          local m = bit.band(getnumber(45),bit.lshift(1,2))  --小车1状态-运行速度
          if m==0 then
            packet[crane_state[19]] = 0
          else
            packet[crane_state[19]] = 1
          end
          local m = bit.band(getnumber(45),bit.lshift(1,5))  --小车1状态-正转限位
          if m==0 then
            packet[crane_state[21]] = 0
          else
            packet[crane_state[21]] = 1
          end
          local m = bit.band(getnumber(45),bit.lshift(1,6))  --小车1状态-反转限位
          if m==0 then
            packet[crane_state[22]] = 0
          else
            packet[crane_state[22]] = 1
          end
          local m = bit.band(getnumber(45),bit.lshift(1,7))  --小车1状态-抱闸状态
          if m==0 then
            packet[crane_state[23]] = 0
          else
            packet[crane_state[23]] = 1
          end
          packet[crane_state[18]] = bit.lshift(getnumber(46),8)+getnumber(47) --小车1状态-位置信息
          packet[crane_state[20]] = bit.lshift(getnumber(50),8)+getnumber(51) --小车1状态-变频器状态
          packet[crane_state[24]] = bit.lshift(getnumber(48),8)+getnumber(49) --小车1状态-故障代码            
           
          if(cranetype >1)then 
              local x = bit.lshift(getnumber(78),8)+getnumber(79)                    --小车2机构状态
              if(x>2) then
                packet[crane_state[49]] = 1
              else 
                packet[crane_state[49]] = 0
              end
              if((bit.lshift(getnumber(90),8)+getnumber(91))>0)
                 packet[crane_state[49]] = 2                                         --小车2机构状态
              end  
              --解析2号小车数字量输入 bit0 1 2 5 6 7对应正转反转高速 正转限位反转限位抱闸状态
              local m = bit.band(getnumber(81),bit.lshift(1,0)) --小车2状态-运行方向
              if m~=0 then
                packet[crane_state[9]] = 1
              end
              local m = bit.band(getnumber(81),bit.lshift(1,1))
              if m~=0 then
                packet[crane_state[9]] = 0
              end
              local m = bit.band(getnumber(81),bit.lshift(1,2))  --小车2状态-运行速度
              if m==0 then
                packet[crane_state[11]] = 0
              else
                packet[crane_state[11]] = 1
              end
              local m = bit.band(getnumber(81),bit.lshift(1,5))  --小车2状态-正转限位
              if m==0 then
                packet[crane_state[13]] = 0
              else
                packet[crane_state[13]] = 1
              end
              local m = bit.band(getnumber(81),bit.lshift(1,6))  --小车2状态-反转限位
              if m==0 then
                packet[crane_state[14]] = 0
              else
                packet[crane_state[14]] = 1
              end
              local m = bit.band(getnumber(81),bit.lshift(1,7))  --小车2状态-抱闸状态
              if m==0 then
                packet[crane_state[15]] = 0
              else
                packet[crane_state[15]] = 1
              end
              packet[crane_state[10]] = bit.lshift(getnumber(46),8)+getnumber(47) --小车2状态-位置信息
              packet[crane_state[12]] = bit.lshift(getnumber(50),8)+getnumber(51) --小车2状态-变频器状态
              packet[crane_state[16]] = bit.lshift(getnumber(48),8)+getnumber(49) --小车2状态-故障代码 
          end

          local x = bit.lshift(getnumber(52),8)+getnumber(53)                    --大车机构状态
          if(x>2) then
            packet[crane_state[50]] = 1
          else 
            packet[crane_state[50]] = 0
          end
          if((bit.lshift(getnumber(92),8)+getnumber(93))>0)
             packet[crane_state[50]] = 2                                         --大车机构状态
          end  
            --解析大车数字量输入 bit0 1 2 5 6 7对应正转反转高速 正转限位反转限位抱闸状态
          local m = bit.band(getnumber(55),bit.lshift(1,0))
          if m~=0 then
            packet[crane_state[1]] = 1
          end
          local m = bit.band(getnumber(55),bit.lshift(1,1))
          if m~=0 then
            packet[crane_state[1]] = 0
          end
          local m = bit.band(getnumber(55),bit.lshift(1,2))
          if m==0 then
            packet[crane_state[3]] = 0
          else
            packet[crane_state[3]] = 1
          end
          local m = bit.band(getnumber(55),bit.lshift(1,5))
          if m==0 then
            packet[crane_state[5]] = 0
          else
            packet[crane_state[5]] = 1
          end
          local m = bit.band(getnumber(55),bit.lshift(1,6))
          if m==0 then
            packet[crane_state[6]] = 0
          else
            packet[crane_state[6]] = 1
          end
          local m = bit.band(getnumber(55),bit.lshift(1,7))
          if m==0 then
            packet[crane_state[7]] = 0
          else
            packet[crane_state[7]] = 1
          end
          packet[crane_state[2]] = bit.lshift(getnumber(56),8)+getnumber(57)
          packet[crane_state[4]] = bit.lshift(getnumber(60),8)+getnumber(61)
          packet[crane_state[8]] = bit.lshift(getnumber(59),8)+getnumber(60)

          if((bit.lshift(getnumber(12),8)+getnumber(13))==4) then  --电源状态
              packet[crane_state[51]] = 1
          else 
              packet[crane_state[51]] = 0
          end
          --解析系统输入 bit0 1 2 3 4启动 复位 急停相序错误 主接触器
          for i=0,4 do
              local m = bit.band(getnumber(17),bit.lshift(1,i))
              if m==0 then
                packet[crane_state[52+i]] = 0
              else
                packet[crane_state[52+i]] = 1
              end
          end
          --和校验
          for i=1,93,1 do        
            table.insert(FCS_Array,getnumber(i))
          end

      end  --大if判断最后的结束end

     -- packet[ cmds[4] ] = getnumber(11)

      if(utilCalcFCS(FCS_Array,#FCS_Array) == FCS_Value) then
        packet['status'] = 'SUCCESS'
      else
        packet = {}
        packet['status'] = 'FCS-ERROR'
      end

    end 

    return Json(packet)
end

return _M
