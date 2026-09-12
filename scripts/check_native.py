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
local held=-1
btn=function(k) return k==held end
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
 -- Original-style A/B/C navigation: X is cancel, O opens/accepts.
 pet.hunger=60 pet.happy=50 pet.weight=10 pet.eating_t=0
 show_pet() key=5 update_pet()
 check(pet.hunger==60 and care_mode==0,"x is harmless on main lcd")
 sound_on=true held=5 key=0 update_pet()
 check(not sound_on and menu_i==1,"x plus left toggles sound")
 held=-1
 key=0 update_pet()
 check(menu_i==7,"left wraps care icons")
 key=1 update_pet()
 check(menu_i==1,"right wraps care icons")
 key=4 update_pet()
 check(care_mode==1 and pet.hunger==60,"food icon opens menu")
 update_pet()
 check(pet.hunger==35 and pet.weight==11 and pet.eating_t>0,
       "meal restores hunger and adds weight")
 update_pet()
 check(pet.hunger==35 and pet.weight==11,"eating blocks repeat meal")
 pet.eating_t=0 key=1 update_pet()
 check(care_choice==2,"food menu selects snack")
 key=4 update_pet()
 check(pet.happy==65 and pet.weight==13,"snack raises happiness and weight")
 key=5 update_pet()
 check(care_mode==0,"x closes submenu")
 for screen in all({s_pet,s_lines,s_result}) do
  start_lines()
  scr=screen care_clock=0 menu_i=1
  care_mode=0 pet.hunger=60 pet.tomatoes=10 pet.eating_t=0
  key=5
  for i=1,120 do _update() end
  check(pet.hunger==60 and pet.tomatoes==10 and pet.eating_t==0,
        "repeated x never feeds from screen "..screen)
 end
 -- Light, toilet, medicine, status and discipline are distinct actions.
 show_pet() menu_i=2 key=4 update_pet()
 check(care_mode==2,"light icon opens menu")
 key=1 update_pet() key=4 update_pet()
 check(not pet.lights_on,"light can be turned off")
 key=5 update_pet()
 pet.poop=2 pet.toilet_ok=false menu_i=5 key=4 update_pet()
 check(pet.poop==0 and pet.toilet_ok,"toilet flushes all mess")
 pet.sick=true pet.medicine_left=2 menu_i=4 key=4 update_pet()
 check(pet.sick and pet.medicine_left==1,"medicine may need another dose")
 update_pet()
 check(not pet.sick and pet.medicine_left==0,"medicine cures final dose")
 pet.false_call=true pet.discipline=20 menu_i=7 key=4 update_pet()
 check(not pet.false_call and pet.discipline==30,"valid discipline clears call")
 local mood=pet.happy
 update_pet()
 check(pet.happy==mood-5,"unjust discipline lowers happiness")
 menu_i=6 key=4 update_pet()
 check(care_mode==3 and status_page==1,"status opens first page")
 key=1 update_pet()
 check(status_page==2,"status pages cycle")
 key=5 update_pet()
 check(care_mode==0,"status closes with x")
 key=-1 pet.eating_t=0 pet.sleeping_t=0 pet.lights_on=true
 pet.poop=0 pet.sick=false pet.false_call=false pet.hunger=20 pet.happy=60
 pet.energy=80 pet.care_ticks=5
 advance_care()
 check(pet.energy==78 and pet.poop==1,"care tick drains energy and adds mess")
 pet.poop=1 pet.care_ticks=11
 advance_care()
 check(pet.poop==2 and pet.sick and pet.medicine_left>0,
       "unclean mess causes illness")
 pet.sick=false pet.poop=0 pet.hunger=20 pet.happy=60
 pet.energy=10 pet.sleeping_t=0 pet.care_ticks=1
 advance_care()
 check(pet.sleeping_t>0 and attention_needed(),"tired pet sleeps and calls for light")
 set_light(false)
 check(not attention_needed(),"light off answers sleep call")
 local sleep_left=pet.sleeping_t local old_energy=pet.energy
 for i=1,30 do update_sleep() end
 check(pet.energy==old_energy+2 and pet.sleeping_t==sleep_left-30,
       "sleep restores energy gradually")
 moves=1 tick_pet_play()
 check(pet.energy==old_energy+1,"successful move consumes energy")
 pet.energy=0 tick_pet_play()
 check(pet.energy==0,"energy never negative")
 scr=s_pet start_lines()
 check(scr==s_pet,"empty energy blocks new session")
 pet.energy=80 pet.sleeping_t=0 pet.lights_on=true
 pet.poop=2 pet.sick=true pet.medicine_left=2 pet.false_call=true
 pet.care_mistakes=7 pet.care_ticks=8
 save_state()
 pet.poop=0 pet.sick=false pet.medicine_left=0 pet.false_call=false
 pet.care_mistakes=0 pet.care_ticks=0
 load_save()
 check(pet.poop==2 and pet.sick and pet.medicine_left==2 and pet.false_call,
       "new care state survives reload")
 check(pet.care_mistakes==7 and pet.care_ticks==8,"care history survives reload")
 pet.dead=true pet.egg_t=0 save_state()
 pet.dead=false load_save()
 check(pet.dead,"death survives reload")
 key=4 update_pet()
 check(not pet.dead and pet.egg_t==150 and pet.age==0 and pet.health==100,
       "new egg restarts life")
 save_state() pet.egg_t=0 load_save()
 check(pet.egg_t==150,"egg countdown survives reload")
 scr=s_pet start_lines()
 check(scr==s_pet,"egg cannot start game")
 pet.egg_t=0
 pet.energy=80 pet.sleeping_t=0 pet.lights_on=true
 key=-1
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
 key=-1 hints_on=true
 pet.hunger=15 pet.happy=55 pet.weight=10
 msg="" pet.eating_t=0 pet.sleeping_t=0
 scr=s_pet menu_i=1
 snap("pet")
 care_mode=1 care_choice=1
 snap("pet_food")
 care_mode=2 care_choice=2
 snap("pet_light")
 care_mode=3 status_page=1
 snap("pet_status")
 care_mode=0 pet.poop=2 pet.sick=true pet.false_call=true
 snap("pet_attention")
 pet.poop=0 pet.sick=false pet.false_call=false
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
assert "PASS: 50 native checks" in result.stdout, "Native checks did not finish"
assert "FAIL:" not in result.stdout, "Native assertion failed"
for name in ("pet", "pet_food", "pet_light", "pet_status", "pet_attention",
             "lines", "quit", "result"):
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
