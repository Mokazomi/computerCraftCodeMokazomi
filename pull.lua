-- wget https://raw.githubusercontent.com/Mokazomi/computerCraftCodeMokazomi/main/pull.lua
-- git add . && git commit -m "6" && git push

shell.run("wget https://raw.githubusercontent.com/Konijima/cc-git-clone/master/gitclone.lua")

if fs.exists("computerCraftCodeMokazomi") then
    shell.run("rm computerCraftCodeMokazomi")
end

shell.run("gitclone Mokazomi computerCraftCodeMokazomi main ./")
