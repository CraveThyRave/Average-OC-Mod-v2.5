function onEvent(name, value1, value2)
    if name ~= 'Thorns Background' then return end
    local enabled = tostring(value2):lower() ~= 'false'
    setThornsBackground(value1, enabled)
end