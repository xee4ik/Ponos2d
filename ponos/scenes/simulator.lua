local M = {}

-- Тут мы просто тупо запускаем игру. Этот файлик нужен только, чтобы сделать красивую анимацию перехода и обеспечить будующее удобство

function M.create(group, params)
 load_game(params.project_data, group, nil, params.back_scene)
end

return M