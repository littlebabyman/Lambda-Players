local file = file
local JSONToTable = util.JSONToTable
local Decompress = util.Decompress
local TableToJSON = util.TableToJSON
local Compress = util.Compress
local table_insert = table.insert
local table_RemoveByValue = table.RemoveByValue
local ipairs = ipairs
local table_HasValue = table.HasValue
local table_Add = table.Add
local mergevoicelines = GetConVar( "lambdaplayers_voice_mergeaddonvoicelines" )

file.CreateDir( "lambdaplayers" )
file.CreateDir( "lambdaplayers/custom_profilepictures" )
-- Lambda File System
LAMBDAFS = {}

function LAMBDAFS:WriteFile( filename, content, type ) 
	local f = file.Open( filename, "w", "DATA" )
	if !f then return end

    if type == "json" then 
        content = TableToJSON( content, true )
    elseif type == "compressed" then
        content = TableToJSON( content )
        content = Compress( content, #content )
    end

	f:Write( content )
	f:Close()
end

-- Updates a file or creates a new file if it doesn't exist
-- type should be json or compressed
function LAMBDAFS:UpdateFile( filename, addcontent, type ) 
    local contents = LAMBDAFS:ReadFile( filename, type, "DATA" )

    if contents then
        if addcontent[ 1 ] == "!!INSERT" then table_insert( contents, addcontent[ 2 ] ) else contents[ addcontent[ 1 ] ] = addcontent[ 2 ] end
        LAMBDAFS:WriteFile( filename, contents, type ) 
    else
        local newtbl = {}
        if addcontent[ 1 ] == "!!INSERT" then table_insert( newtbl, addcontent[ 2 ] ) else newtbl[ addcontent[ 1 ] ] = addcontent[ 2 ] end
        LAMBDAFS:WriteFile( filename, newtbl, type ) 
    end

end

-- If a file has the provided value
-- Only works if the file is sequential
function LAMBDAFS:FileHasValue( filename, value, type ) 
    if !file.Exists( filename, "DATA" ) then return false end
    local contents = LAMBDAFS:ReadFile( filename, type, "DATA" )
    return table_HasValue( contents, value )
end

-- Removes the specified value or key from a file.
function LAMBDAFS:RemoveDataFromFile( filename, removevar, iskey, type ) 
    local contents = LAMBDAFS:ReadFile( filename, type, "DATA" )

    for k, v in pairs( contents ) do
        if iskey and k == removevar or !iskey and v == removevar then if isnumber( k ) then table.remove( contents, k ) else contents[ k ] = nil end end
    end

    LAMBDAFS:WriteFile( filename, contents, type ) 
end



function LAMBDAFS:ReadFile( filename, type, path )
	if !path then path = "DATA" end

	local f = file.Open( filename, "r", path )
	if !f then return nil end

	local str = f:Read( f:Size() )

	f:Close()

	if !str then return nil end

    if str != "" and type == "json" then 
        str = JSONToTable( str )
    elseif str != "" and type == "compressed" then
        str = Decompress( str, #str )
        str = JSONToTable( str )
    end

	return str
end

function LAMBDAFS:GetNameTable()
    local customcontent = LAMBDAFS:ReadFile( "lambdaplayers/customnames.json", "json" ) or {}
    local defaultcontent = LAMBDAFS:ReadFile( "materials/lambdaplayers/data/names.vmt", "json", "GAME" )
    local mergedtable = table_Add( defaultcontent, customcontent )
    return mergedtable
end

function LAMBDAFS:GetPropTable()
    local customcontent = LAMBDAFS:ReadFile( "lambdaplayers/customprops.json", "json" ) or {}
    local defaultcontent = LAMBDAFS:ReadFile( "materials/lambdaplayers/data/props.vmt", "json", "GAME" )
    local mergedtable = table_Add( defaultcontent, customcontent )
    return mergedtable
end

function LAMBDAFS:GetMaterialTable()
    local customcontent = LAMBDAFS:ReadFile( "lambdaplayers/custommaterials.json", "json" ) or {}
    local defaultcontent = LAMBDAFS:ReadFile( "materials/lambdaplayers/data/materials.vmt", "json", "GAME" )
    local mergedtable = table_Add( defaultcontent, customcontent )
    return mergedtable
end

function LAMBDAFS:GetVoiceLinesTable()
    LambdaVoiceLinesTable = { taunt = {}, idle = {}, death = {}, kill = {} }

    local function MergeDirectory( dir, tbl )
        dir = dir .. "/"
        local files, dirs = file.Find( "sound/" .. dir .. "*", "GAME", "nameasc" )
        for k, v in ipairs( files ) do table_insert( tbl, dir .. v ) end
        for k, v in ipairs( dirs ) do MergeDirectory( dir .. v, tbl ) end
    end
    
    MergeDirectory( GetConVar( "lambdaplayers_voice_deathdir" ):GetString(), LambdaVoiceLinesTable.death )
    MergeDirectory( GetConVar( "lambdaplayers_voice_tauntdir" ):GetString(), LambdaVoiceLinesTable.taunt )
    MergeDirectory( GetConVar( "lambdaplayers_voice_idledir" ):GetString(), LambdaVoiceLinesTable.idle )
    MergeDirectory( GetConVar( "lambdaplayers_voice_killdir" ):GetString(), LambdaVoiceLinesTable.kill )
    
    -- This allows the ability to make addons that add voice lines
    if mergevoicelines:GetBool() then
        MergeDirectory( "lambdaplayers/vo/custom/death", LambdaVoiceLinesTable.death )
        MergeDirectory( "lambdaplayers/vo/custom/taunt", LambdaVoiceLinesTable.taunt )
        MergeDirectory( "lambdaplayers/vo/custom/idle", LambdaVoiceLinesTable.idle )
        MergeDirectory( "lambdaplayers/vo/custom/kill", LambdaVoiceLinesTable.kill )
    end
    
    return LambdaVoiceLinesTable
end

function LAMBDAFS:GetProfilePictures()
    Lambdaprofilepictures = {}

    local function MergeDirectory( dir )
        dir = dir .. "/"
        local files, dirs = file.Find( "materials/" .. dir .. "*", "GAME", "nameasc" )
        for k, v in ipairs( files ) do table_insert( Lambdaprofilepictures, dir .. v ) end
        for k, v in ipairs( dirs ) do MergeDirectory( dir .. v ) end
    end

    MergeDirectory( "lambdaplayers/custom_profilepictures" )
    
    return Lambdaprofilepictures
end