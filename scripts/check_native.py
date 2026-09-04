#!/usr/bin/env python3
"""Run isolated PICO-8 regressions and capture the actual cartridge renderer."""
import hashlib
import os
from pathlib import Path
import subprocess
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "build" / "native-review"
OUT.mkdir(parents=True, exist_ok=True)
source = (ROOT / "carts/linesgotchi.p8").read_text()
baseline = subprocess.check_output(
    ["git", "show", "f45a081:carts/linesgotchi.p8"], cwd=ROOT, text=True
)
for name in ("can_reach", "clear_lines"):
    def function(text):
        return text.split("function " + name + "(", 1)[1].split("\nfunction ", 1)[0]
    assert function(source) == function(baseline), name + " changed"
    print(name, hashlib.sha256(function(source).encode()).hexdigest())

# No real cartdata is opened or written. Input and save storage are isolated.
test = r"""
local original_init=_init
local storage={}
cartdata=function() end
dset=function(k,v) storage[k]=v end
dget=function(k) return storage[k] or 0 end
local key=-1
btnp=function(k) return k==key end
local passed=0
function check(ok,label)
 if not ok then
  printh("FAIL: "..label)
  extcmd("shutdown")
  return
 end
 passed+=1
end
function empty_board()
 for i=1,64 do b[i]=0 end
end
function snap(name)
 _draw()
 flip()
 extcmd("set_filename",name)
 extcmd("screen",4)
end
function _init()
 original_init()
 sound_on=false
 local h=pet.hunger
 for i=1,30 do key=4 update_pet() end
 check(pet.hunger==h,"home does not feed")
 for screen in all({s_pet,s_lines,s_result,s_stats,s_records,s_settings}) do
  start_lines()
  scr=screen care_clock=0 menu_i=1
  pet.hunger=60 pet.tomatoes=10 pet.eating_t=0
  key=5
  for i=1,120 do _update() end
  check(pet.hunger==60 and pet.tomatoes==10 and pet.eating_t==0,
        "repeated x never feeds from screen "..screen)
 end
 -- Care actions are available only through their focused Stats controls.
 pet.hunger=60 pet.tomatoes=3 pet.eating_t=0 pet.sleeping_t=0
 scr=s_pet menu_i=3 key=4
 _update()
 check(scr==s_stats and stats_i==0 and pet.hunger==60,
       "opening care does not feed")
 _update()
 check(pet.hunger==40 and pet.tomatoes==2 and pet.eating_t>0,
       "confirm tomato feeds once")
 _update()
 check(pet.hunger==40 and pet.tomatoes==2,"eating blocks repeat")
 pet.eating_t=0 pet.tomatoes=0
 _update()
 check(pet.hunger==40,"no food blocks feeding")
 pet.tomatoes=3 pet.hunger=0
 _update()
 check(pet.tomatoes==3,"full pet keeps food")
 pet.hunger=60 pet.sleeping_t=100
 _update()
 check(pet.hunger==60 and pet.tomatoes==3,"sleep blocks feeding")
 pet.sleeping_t=0
 key=3 _update()
 check(stats_i==1,"down selects toilet")
 pet.toilet_ok=false key=4 _update()
 check(pet.toilet_ok and pet.hunger==60,"toilet does not feed")
 key=3 _update()
 check(stats_i==2,"down selects sleep")
 pet.sleep_ready=true pet.eating_t=10 key=4 _update()
 check(pet.sleeping_t==0,"eating blocks sleep")
 pet.eating_t=0 _update()
 check(pet.sleeping_t>0 and pet.hunger==60,"sleep works without feeding")
 pet.sleeping_t=0
 key=2 _update() _update() _update()
 check(stats_i==0,"up stops at feeding")
 key=-1 pet.eating_t=0 pet.sleeping_t=0
 pet.energy=80 care_clock=899 scr=s_pet
 _update()
 check(pet.energy==79,"awake time consumes energy")
 moves=1 tick_pet_play()
 check(pet.energy==78,"successful move consumes energy")
 pet.energy=0 tick_pet_play()
 check(pet.energy==0,"energy never negative")
 scr=s_pet start_lines()
 check(scr==s_pet,"empty energy blocks new session")
 pet.energy=80 pet.health=60 pet.happy=50
 put_pet_to_sleep()
 check(pet.sleeping_t==300 and pet.energy==80 and pet.health==60
       and pet.happy==50,"sleep starts without instant reward")
 start_lines()
 check(scr==s_pet,"sleep blocks new session")
 for i=1,29 do update_sleep() end
 check(pet.energy==80,"recovery waits one second")
 update_sleep()
 check(pet.energy==82 and pet.sleeping_t==270,"sleep recovers gradually")
 put_pet_to_sleep()
 check(pet.sleeping_t==270 and pet.energy==82,"repeat sleep cannot speed recovery")
 for i=1,7 do update_sleep() end
 save_state()
 pet.energy=1 pet.sleeping_t=0
 load_save()
 check(pet.energy==82 and pet.sleeping_t==263,"sleep phase survives reload")
 for i=1,263 do update_sleep() end
 check(pet.energy==100 and pet.sleeping_t==0,"sleep completes at full energy")
 put_pet_to_sleep()
 check(pet.sleeping_t==0,"rested pet cannot farm sleep")
 pet.energy=99 put_pet_to_sleep()
 for i=1,30 do update_sleep() end
 check(pet.energy==100 and pet.sleeping_t==0,"odd deficit clamps correctly")
 storage[23]=nil
 pet.energy=0 pet.sleeping_t=99
 load_save()
 check(pet.energy==80 and pet.sleeping_t==0,"legacy save gets safe defaults")
 storage[23]=1 storage[21]=-9 storage[22]=9999
 load_save()
 check(pet.energy==0 and pet.sleeping_t==1500,"damaged save is clamped")
 storage[22]=1
 load_save()
 check(pet.sleeping_t==1471,"short corrupted sleep cannot wake unrested")
 storage[21]=200
 load_save()
 check(pet.energy==100 and pet.sleeping_t==0,"full energy cancels stale sleep")
 pet.energy=80 pet.sleeping_t=0
 save_state()
 key=-1
 start_lines()
 check(#next_balls==3,"next count")
 local count=0
 for v in all(b) do if v>0 then count+=1 end end
 check(count==5,"initial balls")
 empty_board()
 b[1]=1
 check(can_reach(1,64),"open path")
 b[2]=1 b[9]=1
 check(not can_reach(1,64),"blocked path")
 for direction=1,4 do
  empty_board()
  for j=0,4 do
   local x=direction==2 and 2 or j+1
   local y=direction==1 and 2 or direction==4 and 8-j or j+1
   b[idx(x,y)]=1
  end
  local n=clear_lines()
  check(n==5,"five in direction "..direction)
 end
 empty_board()
 b[1]=1 b[2]=1 b[3]=1 b[4]=1
 check(clear_lines()==0,"four do not clear")
 empty_board()
 next_balls={1,2,3}
 spawn_next_balls()
 count=0
 local seen={}
 for v in all(b) do if v>0 then count+=1 seen[v]=true end end
 check(count==3 and seen[1] and seen[2] and seen[3],"spawn preview")
 start_lines()
 key=5 update_lines()
 check(quit_confirm and scr==s_lines,"quit asks")
 update_lines()
 check(not quit_confirm and scr==s_lines,"quit cancels")
 key=-1
 pet.hunger=37 pet.happy=64 pet.weight=12
 save_state()
 pet.hunger=0 pet.happy=0 pet.weight=1
 load_save()
 check(pet.hunger==37 and pet.happy==64 and pet.weight==12,"save roundtrip")
 scr=s_settings menu_i=5 settings_i=1 key=4
 local on=sound_on
 update_settings()
 check(sound_on~=on,"sound toggle")
 sound_on=false
 settings_i=2 on=hints_on
 update_settings()
 check(hints_on~=on,"hints toggle")
 key=-1 hints_on=true
 pet.hunger=15 pet.happy=55 pet.weight=10
 msg="" pet.eating_t=0 pet.sleeping_t=0
 scr=s_pet menu_i=1
 snap("pet")
 for state=0,4 do
  cls(7)
  draw_pet_sprite(52,52,state)
  flip()
  extcmd("set_filename","expression_"..state)
  extcmd("screen",4)
 end
 start_lines()
 empty_board()
 b[idx(7,1)]=1 b[idx(6,3)]=2
 b[idx(3,6)]=3 b[idx(6,6)]=1 b[idx(5,7)]=3
 next_balls={1,2,3} score=120
 snap("lines")
 sel=idx(7,1) cx=7 cy=1
 snap("selected")
 quit_confirm=true
 snap("quit")
 quit_confirm=false sel=0
 msg="no path"
 snap("message")
 msg=""
 scr=s_stats menu_i=3
 snap("stats")
 stats_i=2
 snap("stats_sleep")
 scr=s_records menu_i=4
 snap("records")
 scr=s_settings menu_i=5
 snap("settings")
 scr=s_result result_reason="quit"
 snap("result")
 scr=s_lines score=32767 pet.happy=100 pet.hunger=0
 snap("large_values")
 empty_board() msg="" sel=0 cx=8 cy=8
 for i=1,5 do b[i]=i end
 next_balls={1,2,3}
 snap("five_colours_a")
 next_balls={4,5,1}
 snap("five_colours_b")
 printh("PASS: "..passed.." native checks")
 extcmd("shutdown")
end
"""
head, tail = source.split("__gfx__", 1)
cart = OUT / "review.p8"
cart.write_text(head + test + "\n__gfx__" + tail)
env = dict(os.environ, SDL_VIDEODRIVER="dummy", SDL_AUDIODRIVER="dummy")
result = subprocess.run(
    [str(Path.home() / ".local/bin/pico8"), "-desktop", str(OUT), "-x", str(cart)],
    env=env, capture_output=True, text=True, timeout=60,
)
print(result.stdout, result.stderr)
assert result.returncode == 0, "PICO-8 exited with an error"
assert "PASS: 51 native checks" in result.stdout, "Native checks did not finish"
assert "FAIL:" not in result.stdout, "Native assertion failed"
for name in ("pet", "lines", "stats", "records", "settings", "quit", "result"):
    assert (OUT / (name + ".png")).exists(), "Missing screenshot: " + name
    image = Image.open(OUT / (name + ".png")).convert("RGB")
    assert image.size == (512, 512), name + " dimensions"
    assert 3 < len(image.getcolors(512 * 512)) <= 16, name + " palette"
    pixels = image.load()
    for y in range(0, 512, 4):
        for x in range(0, 512, 4):
            assert all(pixels[x + dx, y + dy] == pixels[x, y]
                       for dx in range(4) for dy in range(4)), name + " pixel grid"
print("Native screenshots:", OUT)

# The queue must use the same unscaled sprite and background as the board.
for name, colours in (("five_colours_a", (1, 2, 3)),
                      ("five_colours_b", (4, 5, 1))):
    pixels = Image.open(OUT / (name + ".png")).convert("RGB").load()
    for slot, colour in enumerate(colours):
        board_x = (8 + (colour - 1) * 9) * 4
        queue_x = (90 + slot * 10) * 4
        for y in range(32):
            for x in range(32):
                assert pixels[board_x+x, 23*4+y] == pixels[queue_x+x, 93*4+y], (
                    name, slot, "queue sprite differs from board", x, y
                )
print("PASS: all five queue colours match board sprites pixel-for-pixel")
