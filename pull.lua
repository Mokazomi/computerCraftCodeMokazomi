-- wget https://raw.githubusercontent.com/Mokazomi/computerCraftCodeMokazomi/main/pull.lua

shell.run("wget https://raw.githubusercontent.com/Konijima/cc-git-clone/master/gitclone.lua")

shell.run("rm computerCraftCodeMokazomi")

shell.run("gitclone Mokazomi computerCraftCodeMokazomi main ./")
