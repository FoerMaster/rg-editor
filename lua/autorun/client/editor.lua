rgedit = {ui={},vars = {["show_bounds"] = true, ["show_class"] = true, }}

rgedit.editdata = {
    selected = nil,
    ents_list = {}
}


for i = 1, 50 do
    surface.CreateFont( "rgedit.font."..i, {
        font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        size = i,
        weight = 500,
        antialias = true,
    } )
    
end

for i = 1, 50 do
    surface.CreateFont( "rgedit.font.mini."..i, {
        font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        size = i,
        weight = 1,
        antialias = true,
    } )
    
end

concommand.Add("rgeditor_gui", function( ply, cmd, args )

    local traceScreen = util.QuickTrace(LocalPlayer():GetShootPos(), gui.ScreenToVector(gui.MousePos()) * 1000,LocalPlayer())

    hook.Add("PreDrawOpaqueRenderables","rgedit.DrawBoxs",function()
        if !IsValid(rgedit.ui.MainHeader) then return end
        gui.EnableScreenClicker( !input.IsMouseDown( MOUSE_RIGHT ) )
        
        traceScreen = util.QuickTrace(LocalPlayer():GetShootPos(), gui.ScreenToVector(gui.MousePos()) * 1000,LocalPlayer())

        
        for k,v in pairs(rgedit.editdata.ents_list) do
            if !IsValid(v)then rgedit.editdata.ents_list[k] = nil continue end

            if (!rgedit.vars["show_bounds"] and rgedit.editdata.selected ~= v ) then  continue end
            render.SetMaterial( Material( "vgui/white" ) )
            render.DrawBox( v:GetPos(), v:GetAngles(), v:OBBMins(), v:OBBMaxs(), rgedit.editdata.selected == v and Color( 255, 238, 0,50) or Color( 255, 255, 255,50 ) )
            

        end
    end)

    local function CheckEnt()
        if !input.IsMouseDown( MOUSE_RIGHT ) and input.IsMouseDown( MOUSE_LEFT ) then 
            for k,v in pairs(ents.FindInSphere(traceScreen.HitPos,15)) do

                if v.dataClass then
                    rgedit.editdata.selected = v
                    return
                end
            end

        end
    end

    hook.Add("HUDPaint","rgedit.DrawOverlay",function()
        if !IsValid(rgedit.ui.MainHeader) then return end

        local s_Pos = traceScreen.HitPos:ToScreen()

        if input.IsMouseDown( MOUSE_RIGHT ) then 
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawOutlinedRect( ScrW()/2-5, ScrH()/2-5, 10, 10, 2 )
        end

        CheckEnt()
        
        for k,v in pairs(rgedit.editdata.ents_list) do
            if !IsValid(v)  then rgedit.editdata.ents_list[k] = nil continue end
            if (!rgedit.vars["show_class"] and rgedit.editdata.selected ~= v ) then  continue end
            local s_Pos = v:GetPos():ToScreen()
            draw.SimpleText( v.dataClass.classTable.class, "DermaDefault", s_Pos.x,s_Pos.y+1, Color(0,0,0,255),1,1 )
            draw.SimpleText( v.dataClass.classTable.class, "DermaDefault", s_Pos.x,s_Pos.y, rgedit.editdata.selected == v and Color( 255, 238, 0,255) or Color(255,255,255,255),1,1 )

        end
    end)

    function rgedit.CreateItem(iType,class)
        local iClass = {}
        if iType == "SWEP" then
            iClass = {classTable = weapons.Get( class ), class = class, model = weapons.Get( class ).WorldModel}
        else
            iClass = {classTable = scripted_ents.Get( class ), class = class, model = scripted_ents.Get( class ).Model}
        end
        local ent = ents.CreateClientProp()
        ent:SetPos( LocalPlayer():GetEyeTrace().HitPos )
        ent:SetModel( iClass.model )
        local id = #rgedit.editdata.ents_list + 1
        ent.dataClass = {classTable = iClass, id = id}
        ent:Spawn()

        rgedit.editdata.ents_list[id] = ent
    end


    for k,v in pairs(rgedit.ui) do
        if type(v) != 'function' and IsValid(v) then
            v:Remove()
        end
    end

    rgedit.ui.DefaultDraw = function(self,w,h)
        surface.SetDrawColor(40,40,40,255)
        surface.DrawRect(0,0,w,h)
    end

    rgedit.ui.MainHeader = vgui.Create("DPanel")
    rgedit.ui.MainHeader:Dock(TOP)
    rgedit.ui.MainHeader:SetHeight(57)
    rgedit.ui.MainHeader.Paint = function() end

    rgedit.ui.Header = vgui.Create("DIconLayout",rgedit.ui.MainHeader)
    rgedit.ui.Header:Dock(FILL)
    rgedit.ui.Header:SetSpaceY( 6 )
    rgedit.ui.Header:SetSpaceX( 2 )
    rgedit.ui.Header.Paint = rgedit.ui.DefaultDraw

    rgedit.ui.Header.AddButton = function(icon,text,callback,dock)
        local button = rgedit.ui.Header:Add("DButton") -- or use self
        button:SetText("")
        button:SetSize(40,40)
        button:DockMargin(2,5,4,6)
        button:Dock(dock or LEFT)
        button.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))

            surface.SetMaterial(Material(icon))
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRectRotated(w/2,h/2,25,25,0)
        end
        button.DoClick = callback
    end

    function rgedit.ui.Header:PaintOver(w,h)
        surface.SetDrawColor(69,69,69,255)
        surface.DrawRect(0,h-1,w,1)
    end

    rgedit.ui.MainFooter = vgui.Create("DPanel")
    rgedit.ui.MainFooter:Dock(BOTTOM)
    rgedit.ui.MainFooter:SetHeight(200)
    rgedit.ui.MainFooter.Paint = function() end


    rgedit.ui.MainFooter:SetWide(461 + 200*3 + 10*4)
    rgedit.ui.MainFooter:Center()
    rgedit.ui.MainFooter:Dock(0)
    rgedit.ui.MainFooter:SetPos(rgedit.ui.MainFooter:GetX(), ScrH()-200)
    rgedit.ui.MainFooter.Hide = false

    rgedit.ui.HideButton = vgui.Create("DButton")
    rgedit.ui.HideButton:SetPos(rgedit.ui.MainFooter:GetX()+rgedit.ui.MainFooter:GetWide()/2 - 30,rgedit.ui.MainFooter:GetY()-25)
    rgedit.ui.HideButton:SetSize(60,25)
    rgedit.ui.HideButton:SetText("---")
    function rgedit.ui.HideButton:Think()
        rgedit.ui.HideButton:SetPos(rgedit.ui.MainFooter:GetX()+rgedit.ui.MainFooter:GetWide()/2 - 30,rgedit.ui.MainFooter:GetY()-25)
    end
    function rgedit.ui.HideButton:DoClick()
        rgedit.ui.MainFooter.Hide = !rgedit.ui.MainFooter.Hide
        rgedit.ui.MainFooter:MoveTo(rgedit.ui.MainFooter:GetX(),rgedit.ui.MainFooter.Hide and ScrH() or ScrH()-200,0.5)
    end

    rgedit.ui.HideButton.Paint = function(self,w,h)
        draw.RoundedBox(5,0,0,w,h+3,Color(69,69,69,255))
        draw.RoundedBox(4,1,1,w-2,h-2+3,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
    end


    rgedit.ui.Footer = vgui.Create("DIconLayout",rgedit.ui.MainFooter)
    rgedit.ui.Footer:Dock(FILL)
    rgedit.ui.Footer:SetSpaceY( 5 )
    rgedit.ui.Footer:SetSpaceX( 0 )
    rgedit.ui.Footer.Paint = function(self,w,h)
        draw.RoundedBoxEx(5,0,0,w,h,Color(40,40,40),true,true,false,false)
    end


    rgedit.ui.Footer.AddPanel = function(wide,callback)
        local panel = rgedit.ui.Footer:Add("DPanel") -- or use self
        panel:SetText("")
        panel:SetWide(wide)
        panel:DockMargin(5,5,5,0)
        panel:DockPadding(1,1,1,6)
        panel:Dock(LEFT)
        panel.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h-4,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(40,40,40,255))
        end
        callback(panel)
    end

    rgedit.ui.Header.AddButton("rgplay/icons.48/add.png","test",function()

        if IsValid(rgedit.ui.EntsList) then
            return
        end

        rgedit.ui.EntsList = vgui.Create("DFrame")
        rgedit.ui.EntsList:SetSize(500,400)
        rgedit.ui.EntsList:SetTitle("Entity list")
        rgedit.ui.EntsList:Center()
        rgedit.ui.EntsList:MakePopup()
        rgedit.ui.EntsList:ShowCloseButton(false)
        rgedit.ui.EntsList.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h-4,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(40,40,40,255))
        end

        local button = vgui.Create("DButton",rgedit.ui.EntsList)
        button:SetText("Close")
        button:SetPos(430,5)
        button:SetSize(65,25)
        button.DoClick = function()
            rgedit.ui.EntsList:Remove()

            
        end
        button.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
        end
        
        local TextEntry = vgui.Create( "DTextEntry", rgedit.ui.EntsList ) -- create the form as a child of frame
        TextEntry:Dock( TOP )
        TextEntry:SetHeight(30)
        TextEntry:DockMargin(0,5,0,5)
        TextEntry.Paint = function( self,w,h)
            draw.RoundedBox(5,0,0,w,h,self:HasFocus() and Color(255,255,255,255) or Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
            
            if self:GetValue() == "" then
                draw.SimpleText( "ent_some", "DermaDefault", 5, h/2, Color(255,255,255,30),0,1 )
            end

            local x = draw.SimpleText( self:GetValue() or "", "DermaDefault", 5, h/2, Color(255,255,255,150),0,1 )

        end

        TextEntry.OnChange = function( self )
            rgedit.ui.EntsList.List:Clear()
            for k,v in pairs(list.Get( "Weapon" )) do
                if (!string.find(string.lower(k),string.lower(self:GetValue()))) and self:GetValue() ~= "" then continue end
                if !k or !weapons.Get( k ) then continue end
                local SpawnIcon = rgedit.ui.EntsList.List:Add( "DButton" )
                SpawnIcon:SetSize( 66, 66 )
                SpawnIcon:SetText("")
                SpawnIcon:SetTooltip(weapons.Get( k ).PrintName)
                SpawnIcon.Icon = vgui.Create( "ModelImage", SpawnIcon )
                SpawnIcon.Icon:SetMouseInputEnabled( false )
                SpawnIcon.Icon:SetKeyboardInputEnabled( false )
                SpawnIcon.Icon:SetModel( weapons.Get( k ).WorldModel )
                SpawnIcon.Icon:SetSize( 60, 60 )
                SpawnIcon.Icon:Center()
        
                SpawnIcon.Paint = function(self,w,h)
                    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,self:IsHovered() and 150 or 60))
                end
                SpawnIcon.DoClick = function()
                    rgedit.CreateItem("SWEP",k)
                end
            end

            for k,v in pairs(scripted_ents.GetList()) do
                if !v.t.Model then continue end
                if (!string.find(string.lower(v.t.ClassName),string.lower(self:GetValue())))  and self:GetValue() ~= "" then continue end

                local SpawnIcon = rgedit.ui.EntsList.List:Add( "DButton" )
                SpawnIcon:SetSize( 66, 66 )
                SpawnIcon:SetText("")
                SpawnIcon.Icon = vgui.Create( "ModelImage", SpawnIcon )
                SpawnIcon.Icon:SetMouseInputEnabled( false )
                SpawnIcon.Icon:SetKeyboardInputEnabled( false )
                SpawnIcon.Icon:SetModel( v.t.Model )
                SpawnIcon.Icon:SetSize( 60, 60 )
                SpawnIcon.Icon:Center()
        
                SpawnIcon.Paint = function(self,w,h)
                    draw.RoundedBox(0,0,0,w,h,Color(0,0,0,self:IsHovered() and 150 or 60))
                end
                SpawnIcon.DoClick = function()
                    rgedit.CreateItem("ENT",v.t.ClassName)
                end
            end
        end

        local Scroll = vgui.Create( "DScrollPanel", rgedit.ui.EntsList )
        Scroll:Dock( FILL )
        Scroll.VBar:SetWidth(6)

        local sbar = Scroll:GetVBar()
        Scroll.VBar:SetHideButtons( true )
        
        function sbar:Paint(w, h)  draw.RoundedBoxEx(5,0,0,w,h,Color(0,0,0,100),false,true,false,true)  end
        function sbar.btnGrip:Paint(w, h) draw.RoundedBoxEx(5,0,0,w,h,Color(255,255,255,100),false,true,false,true) end

        rgedit.ui.EntsList.List = vgui.Create( "DIconLayout", Scroll )
        rgedit.ui.EntsList.List:Dock( FILL )
        rgedit.ui.EntsList.List:SetSpaceY( 3 )
        rgedit.ui.EntsList.List:SetSpaceX( 3 )
        
        for k,v in pairs(list.Get( "Weapon" )) do
            if !k or !weapons.Get( k ) then continue end
            local SpawnIcon = rgedit.ui.EntsList.List:Add( "DButton" )
            SpawnIcon:SetSize( 66, 66 )
            SpawnIcon:SetText("")
            SpawnIcon:SetTooltip(weapons.Get( k ).PrintName)
            SpawnIcon.Icon = vgui.Create( "ModelImage", SpawnIcon )
            SpawnIcon.Icon:SetMouseInputEnabled( false )
            SpawnIcon.Icon:SetKeyboardInputEnabled( false )
            SpawnIcon.Icon:SetModel( weapons.Get( k ).WorldModel )
            SpawnIcon.Icon:SetSize( 60, 60 )
            SpawnIcon.Icon:Center()

            SpawnIcon.Paint = function(self,w,h)
                draw.RoundedBox(0,0,0,w,h,Color(0,0,0,self:IsHovered() and 150 or 60))
            end
            SpawnIcon.DoClick = function()
                rgedit.CreateItem("SWEP",k)
            end
        end

        for k,v in pairs(scripted_ents.GetList()) do
            if !v.t.Model then continue end

            local SpawnIcon = rgedit.ui.EntsList.List:Add( "DButton" )
            SpawnIcon:SetSize( 66, 66 )
            SpawnIcon:SetText("")
            SpawnIcon.Icon = vgui.Create( "ModelImage", SpawnIcon )
            SpawnIcon.Icon:SetMouseInputEnabled( false )
            SpawnIcon.Icon:SetKeyboardInputEnabled( false )
            SpawnIcon.Icon:SetModel( v.t.Model )
            SpawnIcon.Icon:SetSize( 60, 60 )
            SpawnIcon.Icon:Center()

            SpawnIcon.Paint = function(self,w,h)
                draw.RoundedBox(0,0,0,w,h,Color(0,0,0,self:IsHovered() and 150 or 60))
            end
            SpawnIcon.DoClick = function()
                rgedit.CreateItem("ENT",v.t.ClassName)
            end
        end


    end)

    rgedit.ui.Header.AddButton("rgplay/icons.48/edit.png","test",function()
        
        local Menu = DermaMenu()
        Menu:AddOption( "Items" )

        Menu:AddSpacer()

        
        for k,v in pairs(rgedit.editdata.ents_list) do
            if !IsValid(v) then rgedit.editdata.ents_list[k] = nil continue end

            Menu:AddOption( v.dataClass.classTable.class , function() rgedit.editdata.selected = v end ):SetIcon( "icon16/group.png" )

        end

        Menu:Open()
        
    end)

    rgedit.ui.Header.AddButton("rgplay/icons.48/exit.png","Exit",function() 
        for k,v in pairs(rgedit.ui) do
            if type(v) != 'function' and IsValid(v) then
                v:Remove()
            end
        end

        for k,v in pairs(rgedit.editdata.ents_list) do
            if IsValid(v) then
                v:Remove()
            end
            rgedit.editdata.ents_list[k] = nil

        end
        gui.EnableScreenClicker( false )
    end,RIGHT)

    function rgedit.FilledCircle(x, y, radius, seg, color, fraction)
        surface.SetDrawColor(color)
        surface.DrawPoly(rgedit.GenerateCircle(x, y, radius, seg, fraction))
    end

    function rgedit.GenerateCircle(x, y, radius, seg, fraction)
        fraction = fraction or 1
        local circlePolygon = {}

        surface.SetTexture(0)
        table.insert(circlePolygon, { x = x, y = y, u = 0.5, v = 0.5 })

        for i = 0, seg do
            local a = math.rad((i / seg) * -360 * fraction)
            table.insert(circlePolygon, { x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 } )
        end

        local a = math.rad(0)
        table.insert(circlePolygon, { x = x, y = y, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5 })
        return circlePolygon
    end


    function rgedit.CheckBox(mPanel,text,var)

        local GUI = vgui.Create("DPanel",mPanel)
        GUI:Dock(TOP)
        GUI:DockMargin(0, 5, 0, 0)
        GUI:SetTall(40)
        function GUI:Paint(w,h)
            draw.SimpleText( text, "rgedit.font.17", 10, h/2, Color(255,255,255,255),0,1 )

        end

        local Button = vgui.Create("DButton", GUI)
        Button:Dock(RIGHT)
        Button:DockMargin(0, 0, 5, 0)
        Button:SetText('')
        Button:SetSize(60,40)
        local alpha = 0
        local move = 0
        function Button:Paint(w,h)
            draw.RoundedBox(8, 10, 13, w-20, h-(13*2), Color(50+move*3,50+move*3,50+move*3))

            if Button:IsHovered() then
        
                if alpha < 100 then
                    alpha = alpha + 10
                end

            else

                if alpha > 0 then
                    alpha = alpha - 10
                end

            end

            if rgedit.vars[var] then
        
                if move < 20 then
                    move = move + 5
                end

            else

                if move > 0 then
                    move = move - 5
                end

            end

            rgedit.FilledCircle(h/2+move, h/2, 20, 20, Color(120+move*6,120+move*6,120+move*6,alpha))

            rgedit.FilledCircle(h/2+move, h/2, 10, 20, Color(120+move*6,120+move*6,120+move*6))
        end

        function Button:DoClick()
            rgedit.vars[var] = !rgedit.vars[var]
        end

        return Button

    end

    rgedit.ui.Header.AddButton("rgplay/icons.48/settings.png","test",function()

        if IsValid(rgedit.ui.Settings) then
            return
        end

        rgedit.ui.Settings = vgui.Create("DFrame")
        rgedit.ui.Settings:SetSize(300,400)
        rgedit.ui.Settings:SetTitle("Settings")
        rgedit.ui.Settings:Center()
        rgedit.ui.Settings:MakePopup()
        rgedit.ui.Settings:ShowCloseButton(false)
        rgedit.ui.Settings.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h-4,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(40,40,40,255))
        end

        local button = vgui.Create("DButton",rgedit.ui.Settings)
        button:SetText("Close")
        button:SetPos(230,5)
        button:SetSize(65,25)
        button.DoClick = function()
            rgedit.ui.Settings:Remove()
        end
        button.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
        end

        rgedit.CheckBox(rgedit.ui.Settings,"Show bounds","show_bounds")
        rgedit.CheckBox(rgedit.ui.Settings,"Show class","show_class")
    end,RIGHT)

    rgedit.ui.Footer.AddPanel(461,function(panel)

        panel.Builded = false
        panel:DockPadding(5,5,5,5)

        local icon = vgui.Create( "DModelPanel", panel )
        icon:Dock(RIGHT)
        icon:SetWidth(200)
        icon:SetModel( "nil" )

        function icon:PaintOver( w,h ) draw.RoundedBox(0,0,0,w,h,Color(0,0,0,100)) end 
        function icon.Entity:GetPlayerColor() return Vector (1, 0, 0) end

        panel.PaintOver = function(self,w,h)

            if !IsValid(rgedit.editdata.selected) then
                draw.RoundedBox(4,1,1,w-2,h-2-4,Color(20,20,20,255))
                draw.SimpleText( "Select entity!", "DermaDefault", w/2, h/2, Color(255,255,255,50),1,1 )
            else

                local entPos = rgedit.editdata.selected:GetPos()

                icon:SetModel( rgedit.editdata.selected:GetModel() )
                local mn, mx = icon.Entity:GetRenderBounds()
                local size = 0
                size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
                size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
                size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )
                
                icon:SetFOV( 45 )
                icon:SetCamPos( Vector( size, size, size ) )
                icon:SetLookAt( (mn + mx) * 0.5 )

                draw.RoundedBox(0,5,5,135,85,Color(0,0,0,100))

                draw.SimpleText( "Position", "DermaDefault", 10, 10, Color(255,255,255,70) )
                draw.SimpleText( "X:", "DermaDefault", 10, 30, Color(255,0,0,120) )
                draw.SimpleText( "Y:", "DermaDefault", 10, 50, Color(51,255,0,120) )
                draw.SimpleText( "Z:", "DermaDefault", 10, 70, Color(0,38,255,120) )


                draw.SimpleText( entPos.x, "DermaDefault", 25, 30, color_white )
                draw.SimpleText( entPos.y, "DermaDefault", 25, 50, color_white )
                draw.SimpleText( entPos.z, "DermaDefault", 25, 70, color_white )


                local entAng = rgedit.editdata.selected:GetAngles()

                draw.RoundedBox(0,143,5,110,85,Color(0,0,0,100))

                draw.SimpleText( "Angles", "DermaDefault", 150, 10, Color(255,255,255,70) )
                draw.SimpleText( "P:", "DermaDefault", 150, 30, Color(255,0,0,120) )
                draw.SimpleText( "Y:", "DermaDefault", 150, 50, Color(51,255,0,120) )
                draw.SimpleText( "R:", "DermaDefault", 150, 70, Color(0,38,255,120) )


                draw.SimpleText( entAng.x, "DermaDefault", 165, 30, color_white )
                draw.SimpleText( entAng.y, "DermaDefault", 165, 50, color_white )
                draw.SimpleText( entAng.z, "DermaDefault", 165, 70, color_white )

                draw.RoundedBox(0,5,95,248,95,Color(0,0,0,100))

                draw.SimpleText( "General", "DermaDefault", 10, 100, Color(255,255,255,70) )

                draw.SimpleText( "Model: ", "DermaDefault", 10, 120, Color(255,255,255,120) )
                draw.SimpleText( rgedit.editdata.selected:GetModel(), "DermaDefault", 48, 120, Color(255,255,255,255) )

                draw.SimpleText( "Class: ", "DermaDefault", 10, 135, Color(255,255,255,120) )
                draw.SimpleText( rgedit.editdata.selected.dataClass.classTable.class, "DermaDefault", 48, 135, Color(255,255,255,255) )
                
            end
        end

        local button = vgui.Create("DButton",panel)
        button:SetText("Delete")
        button:SetSize(120,30)
        button:SetPos(10, 155)
        button.DoClick = function()
            rgedit.editdata.selected:Remove()
            rgedit.editdata.selected = nil
        end
        button.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
        end

        local button = vgui.Create("DButton",panel)
        button:SetText("Copy")
        button:SetSize(113,30)
        button:SetPos(135, 155)
        button.Paint = function(self,w,h)
            draw.RoundedBox(5,0,0,w,h,Color(69,69,69,255))
            draw.RoundedBox(4,1,1,w-2,h-2,self:IsHovered() and Color(69,69,69,255) or Color(40,40,40,255))
        end

        button.DoClick = function()
            local pos = rgedit.editdata.selected:GetPos()
            local ang = rgedit.editdata.selected:GetAngles()
            local prepare = [[
            -- class = ]]..rgedit.editdata.selected.dataClass.classTable.class..[[.
            -- model = ]]..rgedit.editdata.selected:GetModel()..[[.
            -- Vector(]]..pos.x..[[,]]..pos.y..[[,]]..pos.z..[[) -- Position.
            -- Angle(]]..ang.x..[[,]]..ang.y..[[,]]..ang.z..[[) -- Angles
            ]]
            SetClipboardText(prepare)
        end

    end)
    local oldMousePos = {x=0,y=0}
    local oldEditorPos_XY = {x=0,y=0}
    rgedit.ui.Footer.AddPanel(200,function(panel)

        panel:SetCursor("sizeall")
        panel.PaintOver = function(self,w,h)
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(20,20,20,255))
        

            for i=1,9 do
                
                draw.RoundedBox(0,i*20,1,1,h-2,Color(30,30,30,255))

            end

            for i=1,9 do
                
                draw.RoundedBox(0,1,i*20,w-2,1,Color(30,30,30,255))

            end


            if !IsValid(rgedit.editdata.selected) then
                draw.SimpleText( "Select entity!", "DermaDefault", w/2, h/2, Color(255,255,255,50),1,1 )
            else
                
                draw.SimpleText( "XY Pos editor", "DermaDefault", w/2, 30, Color(255,255,255,10),1,1 )

                if self:IsHovered() and input.IsMouseDown( MOUSE_LEFT ) and !input.IsMouseDown( MOUSE_RIGHT ) then
                    local x,y = gui.MousePos()
                    rgedit.editdata.selected:SetPos(rgedit.editdata.selected:GetPos() - Vector((oldMousePos.x - x)/5,-(oldMousePos.y - y)/5,0))
    

                    oldEditorPos_XY.x = oldEditorPos_XY.x - (oldMousePos.x - x)
                    oldEditorPos_XY.y = oldEditorPos_XY.y - (oldMousePos.y - y)

                    oldMousePos.x = x
                    oldMousePos.y = y
                else
                    local x,y = gui.MousePos()
                    oldMousePos.x = x
                    oldMousePos.y = y

                    oldEditorPos_XY.x = 0
                    oldEditorPos_XY.y = 0
                end

                    
                draw.RoundedBox(5,oldEditorPos_XY.x+w/2 - 15,oldEditorPos_XY.y+h/2 - 15,30,30,Color(255,255,255,10))
                
            end
        end

    end)

    local oldMousePos_YZ = {x=0,y=0}
    local oldEditorPos_YZ = {x=0,y=0}
    rgedit.ui.Footer.AddPanel(200,function(panel)
        
        panel:SetCursor("sizeall")
        panel.PaintOver = function(self,w,h)
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(20,20,20,255))
        

            for i=1,9 do
                
                draw.RoundedBox(0,i*20,1,1,h-2,Color(30,30,30,255))

            end

            for i=1,9 do
                
                draw.RoundedBox(0,1,i*20,w-2,1,Color(30,30,30,255))

            end


            if !IsValid(rgedit.editdata.selected) then
                draw.SimpleText( "Select entity!", "DermaDefault", w/2, h/2, Color(255,255,255,50),1,1 )
            else
                
                draw.SimpleText( "YZ Pos editor", "DermaDefault", w/2, 30, Color(255,255,255,10),1,1 )

                if self:IsHovered() and input.IsMouseDown( MOUSE_LEFT ) and !input.IsMouseDown( MOUSE_RIGHT ) then
                    local x,y = gui.MousePos()
                    rgedit.editdata.selected:SetPos(rgedit.editdata.selected:GetPos() - Vector(0,(oldMousePos_YZ.x - x)/5,-(oldMousePos_YZ.y - y)/5))
    

                    oldEditorPos_YZ.x = oldEditorPos_YZ.x - (oldMousePos_YZ.x - x)
                    oldEditorPos_YZ.y = oldEditorPos_YZ.y - (oldMousePos_YZ.y - y)

                    oldMousePos_YZ.x = x
                    oldMousePos_YZ.y = y
                else
                    local x,y = gui.MousePos()
                    oldMousePos_YZ.x = x
                    oldMousePos_YZ.y = y

                    oldEditorPos_YZ.x = 0
                    oldEditorPos_YZ.y = 0
                end

                    
                draw.RoundedBox(5,oldEditorPos_YZ.x+w/2 - 15,oldEditorPos_YZ.y+h/2 - 15,30,30,Color(255,255,255,10))
                
            end
        end

    end)


    local oldMousePos_ROT = {x=0,y=0}
    local oldEditorPos_ROT = {x=0,y=0}
    rgedit.ui.Footer.AddPanel(200,function(panel)

        panel:SetCursor("sizeall")
        panel.PaintOver = function(self,w,h)
            draw.RoundedBox(4,1,1,w-2,h-2-4,Color(20,20,20,255))
        

            for i=1,9 do
                
                draw.RoundedBox(0,i*20,1,1,h-2,Color(30,30,30,255))

            end

            for i=1,9 do
                
                draw.RoundedBox(0,1,i*20,w-2,1,Color(30,30,30,255))

            end


            if !IsValid(rgedit.editdata.selected) then
                draw.SimpleText( "Select entity!", "DermaDefault", w/2, h/2, Color(255,255,255,50),1,1 )
            else
                
                draw.SimpleText( "YZ Angle editor", "DermaDefault", w/2, 30, Color(255,255,255,10),1,1 )

                if self:IsHovered() and input.IsMouseDown( MOUSE_LEFT ) and !input.IsMouseDown( MOUSE_RIGHT ) then
                    local x,y = gui.MousePos()
                    rgedit.editdata.selected:SetAngles(rgedit.editdata.selected:GetAngles() - Angle(0,(oldMousePos_ROT.x - x)/2,-(oldMousePos_ROT.y - y)/2))
    

                    oldEditorPos_ROT.x = oldEditorPos_ROT.x - (oldMousePos_ROT.x - x)
                    oldEditorPos_ROT.y = oldEditorPos_ROT.y - (oldMousePos_ROT.y - y)

                    oldMousePos_ROT.x = x
                    oldMousePos_ROT.y = y
                else
                    local x,y = gui.MousePos()
                    oldMousePos_ROT.x = x
                    oldMousePos_ROT.y = y

                    oldEditorPos_ROT.x = 0
                    oldEditorPos_ROT.y = 0
                end

                    
                draw.RoundedBox(5,oldEditorPos_ROT.x+w/2 - 15,oldEditorPos_ROT.y+h/2 - 15,30,30,Color(255,255,255,10))
                
            end
        end

    end)
end)