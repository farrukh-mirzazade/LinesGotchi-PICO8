pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- linesgotchi mvp

scr=0
menu_i=1
msg=""
result_reason=""
new_best=false

-- screens
s_pet=0
s_lines=1
s_result=2
s_stats=3
s_records=4

-- lines config
bs=8
cs=9
ox=2
oy=22
colors={8,10,11,12,14}
dxs={1,0,1,1}
dys={0,1,1,-1}

-- gotchi state
pet={
 hunger=15,
 happy=55,
 health=100,
 discipline=45,
 weight=10,
 age=0
}

-- records
hi_score=0
games_played=0
total_lines=0
best_line=0

-- lines state
b={}
cx=1
cy=1
sel=0
score=0
session_lines=0
session_best=0
moves=0
game_over=false

function _init()
 cartdata("linesgotchi")
 load_records()
 show_pet()
end

function _update()
 if scr==s_pet then update_pet()
 elseif scr==s_lines then update_lines()
 elseif scr==s_result then update_result()
 elseif scr==s_stats then update_back_screen()
 elseif scr==s_records then update_back_screen()
 end
end

function _draw()
 cls(1)
 if scr==s_pet then draw_pet_screen()
 elseif scr==s_lines then draw_lines_screen()
 elseif scr==s_result then draw_result_screen()
 elseif scr==s_stats then draw_stats_screen()
 elseif scr==s_records then draw_records_screen()
 end
end

function show_pet()
 scr=s_pet
 msg=""
end

function load_records()
 hi_score=dget(0)
 games_played=dget(1)
 total_lines=dget(2)
 best_line=dget(3)
end

function save_records()
 dset(0,hi_score)
 dset(1,games_played)
 dset(2,total_lines)
 dset(3,best_line)
end

function clamp(v,lo,hi)
 return max(lo,min(hi,v))
end

function update_pet()
 if btnp(0) then menu_i=max(1,menu_i-1) end
 if btnp(1) then menu_i=min(4,menu_i+1) end
 if btnp(4) then
  if menu_i==1 then feed_pet()
  elseif menu_i==2 then start_lines()
  elseif menu_i==3 then scr=s_stats
  elseif menu_i==4 then scr=s_records
  end
 end
end

function feed_pet()
 pet.hunger=clamp(pet.hunger-25,0,100)
 pet.weight=clamp(pet.weight+1,1,99)
 pet.happy=clamp(pet.happy+2,0,100)
 msg="fed +full +weight"
end

function start_lines()
 scr=s_lines
 cx=1
 cy=1
 sel=0
 score=0
 session_lines=0
 session_best=0
 moves=0
 game_over=false
 new_best=false
 for i=1,bs*bs do b[i]=0 end
 add_balls(5)
 clear_lines()
 msg=""
end

function update_lines()
 if game_over then
  finish_lines("game over")
  return
 end
 if btnp(0) then cx=max(1,cx-1) end
 if btnp(1) then cx=min(bs,cx+1) end
 if btnp(2) then cy=max(1,cy-1) end
 if btnp(3) then cy=min(bs,cy+1) end
 if btnp(5) then
  if sel>0 then
   sel=0
   msg="cancel"
  else
   finish_lines("quit")
   return
  end
 end
 if btnp(4) then lines_action() end
end

function lines_action()
 local i=idx(cx,cy)
 if sel==0 then
  if b[i]>0 then
   sel=i
   msg="selected"
  end
 else
  if i==sel then
   sel=0
   msg="cancel"
  elseif b[i]>0 then
   sel=i
   msg="selected"
  elseif can_reach(sel,i) then
   b[i]=b[sel]
   b[sel]=0
   sel=0
   moves+=1
   tick_pet_play()
   local cleared,best=clear_lines()
   if cleared==0 then
    add_balls(3)
    cleared,best=clear_lines()
   end
   game_over=is_full()
  else
   msg="no path"
  end
 end
end

function tick_pet_play()
 if moves%3==0 then
  pet.happy=clamp(pet.happy+1,0,100)
  pet.hunger=clamp(pet.hunger+2,0,100)
 end
 if moves%8==0 and pet.weight>8 then
  pet.weight-=1
 end
end

function finish_lines(reason)
 result_reason=reason
 games_played+=1
 new_best=score>hi_score
 if new_best then hi_score=score end
 total_lines+=session_lines
 if session_best>best_line then best_line=session_best end
 local gain=flr(session_lines/2)+2
 if pet.hunger>85 then gain=1 end
 pet.happy=clamp(pet.happy+gain,0,100)
 pet.hunger=clamp(pet.hunger+5,0,100)
 save_records()
 scr=s_result
 msg=""
end

function update_result()
 if btnp(4) or btnp(5) then show_pet() end
end

function update_back_screen()
 if btnp(4) or btnp(5) then show_pet() end
 if scr==s_stats then
  if btnp(1) then scr=s_records end
 elseif scr==s_records then
  if btnp(0) then scr=s_stats end
 end
end

function idx(x,y)
 return (y-1)*bs+x
end

function xy(i)
 local y=flr((i-1)/bs)+1
 local x=i-(y-1)*bs
 return x,y
end

function inb(x,y)
 return x>=1 and x<=bs and y>=1 and y<=bs
end

function add_balls(n)
 for k=1,n do
  local empties={}
  for i=1,bs*bs do
   if b[i]==0 then add(empties,i) end
  end
  if #empties==0 then
   game_over=true
   return
  end
  local spot=empties[flr(rnd(#empties))+1]
  b[spot]=flr(rnd(#colors))+1
 end
end

function can_reach(a,d)
 local q={a}
 local head=1
 local seen={}
 seen[a]=true
 while head<=#q do
  local i=q[head]
  head+=1
  if i==d then return true end
  local x,y=xy(i)
  for n=1,4 do
   local nx=x
   local ny=y
   if n==1 then nx=x-1
   elseif n==2 then nx=x+1
   elseif n==3 then ny=y-1
   else ny=y+1
   end
   if inb(nx,ny) then
    local ni=idx(nx,ny)
    if b[ni]==0 and not seen[ni] then
     seen[ni]=true
     add(q,ni)
    end
   end
  end
 end
 return false
end

function clear_lines()
 local mark={}
 local best=0
 for y=1,bs do
  for x=1,bs do
   local i=idx(x,y)
   local c=b[i]
   if c>0 then
    for d=1,4 do
     local px=x-dxs[d]
     local py=y-dys[d]
     if not inb(px,py) or b[idx(px,py)]~=c then
      local count=1
      local nx=x+dxs[d]
      local ny=y+dys[d]
      while inb(nx,ny) and b[idx(nx,ny)]==c do
       count+=1
       nx+=dxs[d]
       ny+=dys[d]
      end
      if count>=5 then
       best=max(best,count)
       for n=0,count-1 do
        mark[idx(x+dxs[d]*n,y+dys[d]*n)]=true
       end
      end
     end
    end
   end
  end
 end
 local cleared=0
 for i=1,bs*bs do
  if mark[i] then
   b[i]=0
   cleared+=1
  end
 end
 if cleared>0 then
  score+=cleared*10
  session_lines+=cleared
  session_best=max(session_best,best)
  msg="line +"..cleared
 end
 return cleared,best
end

function is_full()
 for i=1,bs*bs do
  if b[i]==0 then return false end
 end
 return true
end

function draw_pet_screen()
 title("linesgotchi")
 draw_pet(52,34)
 print("hunger "..pet.hunger,6,78,7)
 print("happy  "..pet.happy,6,86,7)
 draw_bar(58,78,54,4,pet.hunger,8)
 draw_bar(58,86,54,4,pet.happy,11)
 local items={"feed","play","stats","records"}
 for i=1,4 do
  local x=4+(i-1)*31
  rectfill(x,108,x+28,119,i==menu_i and 6 or 5)
  print(items[i],x+3,112,i==menu_i and 7 or 6)
 end
 if msg~="" then print(msg,8,96,10) end
 print("left/right  o:ok",20,123,13)
end

function draw_lines_screen()
 title("play lines")
 rectfill(0,116,127,127,0)
 print("score "..score,78,20,7)
 print("h"..pet.hunger,78,30,8)
 print("j"..pet.happy,78,38,11)
 draw_mini_pet(102,55)
 print("x:end",82,92,13)
 print(msg,78,104,10)
 for y=1,bs do
  for x=1,bs do
   local px=ox+(x-1)*cs
   local py=oy+(y-1)*cs
   rect(px,py,px+7,py+7,5)
   local i=idx(x,y)
   if b[i]>0 then
    circfill(px+4,py+4,3,colors[b[i]])
    circ(px+4,py+4,3,7)
   end
   if i==sel then rect(px-1,py-1,px+8,py+8,10) end
  end
 end
 local cp_x=ox+(cx-1)*cs
 local cp_y=oy+(cy-1)*cs
 rect(cp_x-2,cp_y-2,cp_x+9,cp_y+9,7)
 print("o:pick/move",2,120,7)
end

function draw_result_screen()
 title("result")
 print(result_reason,42,24,10)
 print("score      "..score,18,40,7)
 print("lines      "..session_lines,18,50,7)
 print("best line  "..session_best,18,60,7)
 print("hunger     "..pet.hunger,18,76,8)
 print("happy      "..pet.happy,18,86,11)
 if new_best then print("new/local best",28,100,10) end
 print("o/x: pet",42,118,13)
end

function draw_stats_screen()
 title("stats")
 print("< stats      records >",8,18,13)
 stat_line("hunger",pet.hunger,30,8)
 stat_line("happy",pet.happy,42,11)
 stat_line("health",pet.health,54,12)
 stat_line("discipline",pet.discipline,66,10)
 stat_line("weight",pet.weight,78,9)
 stat_line("age",pet.age,90,7)
 print("o/x: pet",42,118,13)
end

function draw_records_screen()
 title("records")
 print("< stats      records >",8,18,13)
 print("hi-score    "..hi_score,18,38,7)
 print("games       "..games_played,18,50,7)
 print("total lines "..total_lines,18,62,7)
 print("best line   "..best_line,18,74,7)
 print("hall/species later",22,94,13)
 print("o/x: pet",42,118,13)
end

function title(t)
 rectfill(0,0,127,12,0)
 print(t,4,4,7)
end

function draw_bar(x,y,w,h,v,col)
 rect(x,y,x+w,y+h,5)
 rectfill(x+1,y+1,x+1+flr((w-2)*v/100),y+h-1,col)
end

function stat_line(name,v,y,col)
 print(name,14,y,7)
 print(v,70,y,col)
 draw_bar(86,y,32,4,v,col)
end

function draw_pet(x,y)
 local sad=pet.hunger>75 or pet.happy<25
 circfill(x+12,y+12,12,12)
 circfill(x+8,y+10,2,0)
 circfill(x+16,y+10,2,0)
 if sad then
  line(x+8,y+18,x+16,y+18,0)
 else
  line(x+8,y+17,x+12,y+20,0)
  line(x+12,y+20,x+16,y+17,0)
 end
 rectfill(x+5,y+25,x+19,y+37,12)
 line(x+5,y+29,x,y+34,12)
 line(x+19,y+29,x+24,y+34,12)
end

function draw_mini_pet(x,y)
 local col=12
 if pet.hunger>80 then col=8 end
 circfill(x,y,8,col)
 circfill(x-3,y-2,1,0)
 circfill(x+3,y-2,1,0)
 if pet.hunger>80 then
  line(x-3,y+4,x+3,y+4,0)
 else
  line(x-4,y+3,x,y+5,0)
  line(x,y+5,x+4,y+3,0)
 end
end
