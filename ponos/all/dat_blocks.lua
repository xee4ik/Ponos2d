--[[
    тут пишется то, как будет выглядеть каждый блок
	
	что:
	  1. 

]]

special_blocks = {
    ["if_condition"] = {"end_if"},
	["repeat_loop"] = {"end_loop"},
	["timer"] = {"end_timer"},
	["add_touch_listener"] = {"end_listener"},
	["while_loop"] = {"end_while"},
	['for_loop'] = {'end_for'},
	["wait_until"] = {"end_wait"},
	["local_function"] = {"end_func"},
	["global_function"] = {"end_func"},
	["in_comment"] = {"end_comment"},
}

special_blocks_struct = {
    ["end_if"] = {
		index = "end_if",
		params = {}
    },
    ["end_loop"] = {
		index = "end_loop",
		params = {}
    },
	["end_while"] = {
		index = "end_while",
		params = {}
    },
	["end_timer"] = {
		index = "end_timer",
		params = {}
    },
    ["end_listener"] = {
		index = "end_listener",
		params = {}
    },
	["end_wait"] = {
		index = "end_wait",
		params = {}
    },
	["end_func"] = {
		index = "end_func",
		params = {}
    },
	["end_comment"] = {
		index = "end_comment",
		params = {}
    },
	['end_for'] = {
	    index = 'end_for',
		params = {}
	},
}

function updateBlocksWords()

local words = {}
if ponosSettings['engBlocks'] then
    words = require("ponos.words.eng")
else
    words = app.words
end

GLOB_C_C_C_C_BLOCKCKCKCK = {
    brown = {207/255,87/255,23/255},
	blue = {62/255, 134/255, 193/255},
	green = {96/255, 147/255, 64/255},
	green_orange = {127/255, 156/255, 63/255},
	object = {63/255,156/255,175/255},
	orange = {249/255,147/255,95/255},
	orange_else = {216/287,133/287,91/287},
	gold = {149/255,109/255,4/255},
	red = {255/255,106/255,106/255},
	red_orange = {219/255,93/255,79/255},
	comment = {0.28,0.28,0.28},
	blue_dark = {62/320,134/320,193/320},
	blue_dark = {62/320,134/320,193/320},
	phys_main = {30/255, 160/255, 143/255}
}

blocks_choose = {
    ['listener'] = {
	    {"нажатие", '"touch"'},
	},
	['tween_property'] = {
        {"X", 'x'},
        {"Y", 'y'},
        {app.words[307], 'width'},
        {app.words[308], 'height'},
        {app.words[309], 'alpha'},
        {app.words[310], 'xScale'},
        {app.words[311], 'yScale'},
        {app.words[312], 'rotation'},
    },
    ['transition'] = {
        {"linear", "linear"},
        --{"loop", "loop"},
        {"inQuad", "inQuad"},
        {"outQuad", "outQuad"},
        {"inOutQuad", "inOutQuad"},
        {"outInQuad", "outInQuad"},
        {"inQuart", "inQuart"},
        {"outQuart", "outQuart"},
        {"inOutQuart", "inOutQuart"},
        {"outInQuart", "outInQuart"},
        {"inExpo", "inExpo"},
        {"outExpo", "outExpo"},
        {"inOutExpo", "inOutExpo"},
        {"outInExpo", "outInExpo"},
        {"inCirc", "inCirc"},
        {"outCirc", "outCirc"},
        {"inOutCirc", "inOutCirc"},
        {"outInCirc", "outInCirc"},
        {"inBack", "inBack"},
        {"outBack", "outBack"},
        {"inOutBack", "inOutBack"},
        {"outInBack", "outInBack"},
        {"inElastic", "inElastic"},
        {"outElastic", "outElastic"},
        {"inOutElastic", "inOutElastic"},
        {"outInElastic", "outInElastic"},
        {"inBounce", "inBounce"},
        {"outBounce", "outBounce"},
        {"inOutBounce", "inOutBounce"},
        {"outInBounce", "outInBounce"},
    },
	['body_type'] = {
        { app.words[313], "'dynamic'" },
        { app.words[314], "'static'" },
        { app.words[315], "'kinematic'" },
    },
	["OnOrOff"] = {
	    { app.words[316], 'true'},
		{ app.words[317], 'false'}
	},
	['bool_state'] = {
        { app.words[318], "true" },
        { app.words[319], "false" },
    },
	['events'] = {
        { app.words[320], "'touch'" },
        { app.words[321], "'collision'" },
		{ app.words[322], "'preCollision'" },
		{ app.words[323], "'postCollision'" }
    },
}

all_blocks = {
    ['system_multitouch'] = {
	    type = "block",
		color = GLOB_C_C_C_C_BLOCKCKCKCK.gold,
		params = {
		    {"text", "мультитач"}, {"choose", "OnOrOff"},
		}
	},
	["set_size"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
	    params = {
	        	{"text", words[94]},{"cell"},{"text", words[95]},
	 		{"enter"},
		 	{"text", words[96]},{"cell"},
	    }
	},
	["new_rounded_rect"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
	   params = {
	       	{"text", words[97]},{"cell"},{"text", words[98]}, {"cell"},
			{"enter"},{"text", words[99]},{"text",words[91]},{"cell"},{"text", words[92]},{"cell"},{"enter"},
			{"text", words[100]},{"cell"},{"text", words[101]},{"cell"},
	   }
	},
	["set_object_var"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
	   params = {
	       	{"text", words[324]},{"cell"},{"enter"},
			{"text", words[325]}, {"cell"}, {"text", app.words[326]}, {"cell"}
	   }
	},
	["add_touch_listener"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	    params = {
	        	{"text", words[102]},{"cell"},
		 	{"text", words[103]}, {"cell"}
	    },
	    special = "cycle"
	},
	["add_object_event_listener"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	    params = {
	        {"text", words[327]},{"choose", "events"},
		 	{"text", words[328]}, {"cell"}, {"text",app.words[329]}, {"cell"}
	    }
	},
	["end_listener"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	   params = {
	       	{"text", words[104]}
	   },
	   special = "end"
	},
	
	["comment"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.comment,
	   params = {
	       	{"editText"}
	   }
	},
	["in_comment"] = {
	    type = "block",
		color = GLOB_C_C_C_C_BLOCKCKCKCK.comment,
		params = { {"text", "закоментировать"}},
		special = "cycle"
	},
	["end_comment"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.comment,
	   params = {
	       	{"text", "конец комментария"}
	   },
	   special = "end"
	},
	
	["remove_listener"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	    params = {
	        {"text", words[238]},{"cell"},{"enter"},
		 	{"text", words[239]}, {"choose", "listener"}
	    },
	},
	["set_focus"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	    params = {
	        {"text", words[273]},{"cell"}
	    },
	},
	["remove_focus"]={
	    type = "block",
	    color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
	    params = {
	        {"text", words[274]}
	    },
	},
	["set_position"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[90]}, {"cell"}, {"text", words[330]}, {"enter"}, {"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"}
	   }
	},
	["set_x"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[105]}, {"cell"}, {"text", words[106]}, {"cell"}
	   }
	},
	["set_y"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[107]}, {"cell"}, {"text", words[106]}, {"cell"}
	   }
	},
	["change_x"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[331]}, {"cell"}, {"text", words[134]}, {"cell"}
	   }
	},
	["change_y"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[332]}, {"cell"}, {"text", words[134]}, {"cell"}
	   }
	},
	
	["tween"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[333]}, {"cell"}, {"enter"},
            {"text", words[334]}, {"choose", "tween_property"},
            {"enter"},
            {"text", words[335]}, {"cell"},
            {"text", words[336]}, {"cell"}, {"text", words[337]}, {"enter"},
			{"text", words[338]}, {"choose", "transition"}
        }
    },
	
	["camera_position"] = {
	 type = "block",
	 color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	 params = {
	  {"text", words[339]}, {"enter"}, 
	  {"text", app.words[91]}, {"cell"}, {"text", app.words[92]}, {"cell"}
	 }
	},
	["camera_position_x"] = {
	 type = "block",
	 color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	 params = {
	  {"text", words[340]}, {"cell"}
	 }
	},
	["camera_position_y"] = {
	 type = "block",
	 color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	 params = {
	  {"text", words[341]}, {"cell"}
	 }
	},
	
-- ФИЗИКА ТУТ

["add_body"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[342]}, {"cell"},
        {"enter"},
        {"text", words[343]}, {"choose", "body_type"},
        {"enter"},
        {"text", words[344]}, {"cell"}, {"text", words[345]}, {"cell"},
        {"enter"},
        {"text", words[346]}, {"cell"}, {"text", words[347]}, {"cell"}
    }
},
["remove_body"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[348]}, {"cell"}
    }
},
["set_body_type"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[349]}, {"cell"}, {"text", words[350]}, {"choose", "body_type"}
    }
},
["upd_hitbox"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[351]}, {"cell"}
    }
},

["set_hitbox_box"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[352]}, {"cell"},
        {"enter"},
        {"text", words[100]}, {"cell"}, {"text", words[101]}, {"cell"}
    }
},
["set_hitbox_circle"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[353]}, {"cell"},
        {"enter"},
        {"text", words[354]}, {"cell"}
    }
},
["set_hitbox_polygon"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[355]}, {"cell"},
        {"enter"},
        {"text", words[356]}, {"cell"}
    }
},

["set_linear_velocity"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[357]}, {"cell"},
        {"enter"},
        {"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"}
    }
},
["set_linear_velocity_x"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[358]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_linear_velocity_y"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[359]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["apply_force"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[360]}, {"cell"},
        {"enter"},
        {"text", words[361]}, {"cell"}, {"text", words[362]}, {"cell"},
        {"enter"},
        {"text", words[363]}, {"cell"}, {"text", words[364]}, {"cell"}
    }
},
["apply_impulse"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[365]}, {"cell"},
        {"enter"},
        {"text", words[366]}, {"cell"}, {"text", words[367]}, {"cell"},
        {"enter"},
        {"text", words[368]}, {"cell"}, {"text", words[369]}, {"cell"}
    }
},
["set_angular_velocity"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[370]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["apply_torque"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[371]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_angular_impulse"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[372]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},

["set_gravity_scale"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[373]}, {"cell"}, {"text", words[374]}, {"cell"}
    }
},
["set_sensor"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[375]}, {"cell"}, {"enter"},{"text", words[376]}, {"choose", "OnOrOff"}
    }
},
["set_fixed_rotation"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[377]}, {"cell"}, {"enter"},{"text", words[376]}, {"choose", "OnOrOff"}
    }
},
["set_bullet"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[378]}, {"cell"}, {"enter"},{"text", words[376]}, {"choose", "OnOrOff"}
    }
},
["set_linear_damping"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[379]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_angular_damping"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[380]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_awake"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[381]}, {"cell"}
    }
},

["set_pivot_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[382]}, {"cell"},
        {"enter"},
        {"text", words[383]}, {"cell"}, {"text", words[384]}, {"cell"},
        {"enter"},
        {"text", words[385]}, {"cell"}, {"text", words[386]}, {"cell"}
    }
},
["set_distance_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[387]}, {"cell"},
        {"enter"},
        {"text", words[388]}, {"cell"}, {"text", words[389]}, {"cell"},
        {"enter"},
        {"text", words[390]}, {"cell"}, {"text", words[391]}, {"cell"},
        {"enter"},
        {"text", words[392]}, {"cell"}, {"text", words[391]}, {"cell"}
    }
},
["set_weld_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[393]}, {"cell"},
        {"enter"},
        {"text", words[388]}, {"cell"}, {"text", words[389]}, {"cell"},
        {"enter"},
        {"text", words[385]}, {"cell"}, {"text", words[386]}, {"cell"}
    }
},
["set_piston_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[394]}, {"cell"},
        {"enter"},
        {"text", words[383]}, {"cell"}, {"text", words[395]}, {"cell"},
        {"enter"},
        {"text", words[385]}, {"cell"}, {"text", words[386]}, {"cell"},
        {"enter"},
        {"text", words[396]}, {"cell"}, {"text", words[397]}, {"cell"}
    }
},
["set_wheel_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[398]}, {"cell"},
        {"enter"},
        {"text", words[383]}, {"cell"}, {"text", words[399]}, {"cell"},
        {"enter"},
        {"text", words[385]}, {"cell"}, {"text", words[386]}, {"cell"},
        {"enter"},
        {"text", words[396]}, {"cell"}, {"text", words[397]}, {"cell"}
    }
},
["set_touch_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[400]}, {"cell"},
        {"enter"},
        {"text", words[384]}, {"cell"},
        {"enter"},
        {"text", words[385]}, {"cell"}, {"text", words[386]}, {"cell"}
    }
},
["set_rope_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[401]}, {"cell"},
        {"enter"},
        {"text", words[388]}, {"cell"}, {"text", words[389]}, {"cell"},
        {"enter"},
        {"text", words[390]}, {"cell"}, {"text", words[391]}, {"cell"},
        {"enter"},
        {"text", words[392]}, {"cell"}, {"text", words[391]}, {"cell"}
    }
},
["delete_joint"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[402]}, {"cell"}
    }
},
["set_pivot_motor"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[403]}, {"cell"},
        {"enter"},
        {"text", words[376]}, {"cell"},
        {"enter"},
        {"text", words[404]}, {"cell"}, {"text", words[405]}, {"cell"}
    }
},
["set_pivot_limits"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[406]}, {"cell"},
        {"enter"},
        {"text", words[376]}, {"cell"},
        {"enter"},
        {"text", words[407]}, {"cell"}, {"text", words[408]}, {"cell"}
    }
},
["set_distance_settings"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[409]}, {"cell"},
        {"enter"},
        {"text", words[410]}, {"cell"}, {"text", words[411]}, {"cell"},
        {"enter"},
        {"text", words[412]}, {"cell"}
    }
},
["set_touch_target"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[413]}, {"cell"},
        {"enter"},
        {"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"}
    }
},

["set_bounce"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[414]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_friction"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[415]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["set_tangent_speed"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[416]}, {"cell"}, {"text", words[350]}, {"cell"}
    }
},
["disable_collision"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[417]}, {"cell"}
    }
},

["set_world_gravity"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[472]},
        {"enter"},
        {"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"}
    }
},
["start_physics"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[418]}
    }
},
["pause_physics"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[419]}
    }
},
["resume_physics"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[420]}
    }
},
["stop_physics"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[421]}
    }
},
["show_physics_debug"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[422]}
    }
},
["hide_physics_debug"]={
    type = "block",
    color = GLOB_C_C_C_C_BLOCKCKCKCK.phys_main,
    params = {
        {"text", words[423]}
    }
},
	
	---- ---- ---- ---- ---- 
	
	["set_width_height"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
	   params = {
	       	{"text", words[108]}, {"cell"}, {"text", words[109]}, {"enter"}, {"text", words[100]}, {"cell"}, {"text", words[101]}, {"cell"}
	   }
	},
	["set_width"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
	   params = {
	       	{"text", words[110]}, {"cell"}, {"text", words[106]}, {"cell"}
	   }
	},
	["set_height"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
	   params = {
	       	{"text", words[111]}, {"cell"}, {"text", words[106]}, {"cell"}
	   }
	},
    ["set_rotation"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[112]}, {"cell"}, {"text", words[113]}, {"cell"}, {"text", words[114]}
	   }
	},
    ["rotate_right"]={
	   type = "block",
	   color = GLOB_C_C_C_C_BLOCKCKCKCK.blue,
	   params = {
	       	{"text", words[424]}, {"cell"}, {"text", words[134]}, {"cell"}, {"text", words[114]}
	   }
	},
	
	["if_condition"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[115]}, {"cell"}, {"text", words[116]}
        },
		special = "cycle"
    },
    ["else_condition_then"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange_else,
        params = {
            {"text", words[117]}, {"cell"}, {"text", words[118]}
        },
    },
	["else_condition"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange_else,
        params = {
            {"text", words[117]}
        },
    },
    ["end_if"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[119]}
        },
		special = "end"
    },
    ["repeat_loop"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[120]}, {"cell"}, {"text", words[121]},
        },
		special = "cycle"
    },
    ["end_loop"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[122]}
        },
		special = "end"
    },
	["while_loop"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[123]}, {"cell"}, {"text", words[451]},
        },
		special = "cycle"
    },
    ["end_while"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[122]}
        },
		special = "end"
    },
	["for_loop"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {'text', words[425]}, {"cell"}, {"text", words[426]}, {'cell'}, {'enter'}, {'text', words[427]}, {'cell'}
        },
		special = "cycle"
    },
	['end_for'] = {
	    type = 'block',
		color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
		params = { {'text', words[428]} },
		special = 'end',
	},
	["timer"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[120]}, {"cell"}, {"text", words[121]}, {"enter"}, {"text", words[125]}, {"cell"}, {"text", words[126]},
        },
		special = "cycle"
    },
    ["end_timer"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[122]}
        },
		special = "end"
    },
	["wait_until"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[429]}, {"cell"}, {"text", words[430]}
        },
		special = "cycle"
    },
	["wait"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[431]}, {"cell"}, {"text", words[337]}
        }
    },
	["return"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[432]}, {"cell"}
        }
    },
	["enter_lua_code"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.gold,
        params = {
            {"text", words[127]}, {"cell"}
        },
    },
	["console_log"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.gold,
        params = {
            {"text", words[433]}, {"cell"}
        },
    },
	["input_alert"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.gold,
        params = {
            {"text", app.words[240]}, {"cell"}, {"enter"},
			{"text" , app.words[241]}, {"cell"}
        },
    },
	["text_alert"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.gold,
        params = {
            {"text", words[434]}, {"cell"}
        },
    },
	["set_global_var"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.red,
        params = {
            {"text", words[128]}, {"cell"}, {"enter"}, {"text", words[129]}, {"cell"}
        },
    },
	["set_local_var"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.red_orange,
        params = {
            {"text", words[130]}, {"cell"}, {"enter"}, {"text", words[129]}, {"cell"}
        },
    },
	["set_var"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.red,
        params = {
            {"text", words[131]}, {"cell"}, {"enter"}, {"text", words[132]}, {"cell"}
        },
    },
	["change_var"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.red,
        params = {
            {"text", words[133]}, {"cell"}, {"enter"}, {"text", words[134]}, {"cell"}
        },
    },
	["set_key_var"]={
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.red,
        params = {
            {"text", words[135]}, {"cell"}, {"enter"}, {"text", words[136]}, {"cell"}, {"text", words[137]}, {"cell"}
        },
    },
    ["new_circle"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[138]}, {"cell"},
            {"enter"},
            {"text", words[99]},{"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"},
            {"enter"},
            {"text", words[272]}, {"cell"}
        }
    },
    ["new_text"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[139]}, {"cell"},
            {"enter"},
            {"text", words[140]}, {"cell"},
            {"enter"},
            {"text", words[141]},{"text", words[91]}, {"cell"}, {"text", words[92]}, {"cell"},
            {"enter"},
            --{"text", words[142]}, {"cell"},
			{"text", words[143]}, {"cell"}
        }
    },
    ["new_image"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[144]}, {"cell"},
            {"enter"},
            {"text", words[145]}, {"cell"}
        }
    },
    
    ["new_group"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[146]}, {"cell"}
        }
    },
    ["new_container"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[435]}, {"cell"}, {"enter"}, 
			{"text",words[436]}, {"cell"}, {"text",words[437]}, {"cell"}
        }
    },
    ["insert_to_group"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[147]}, {"cell"}, {"text", words[148]}, {"cell"}
        }
    },
    ["remove_object"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[438]}, {"cell"}
        }
    },
	
	["button_behavior"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.object,
        params = {
            {"text", words[439]}, {"cell"}, {"enter"}, {"text", words[440]}, {"slider"}
        }
    },
	
    ["set_alpha"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[149]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
    ["set_visible"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[151]}, {"cell"},
            {"enter"},
            {"text", words[152]}, {"cell"}
        }
    },
    ["set_fill_color"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[153]}, {"cell"},
            {"enter"},
            {"text", "R:"}, {"cell"}, {"text", "G:"}, {"cell"}, {"text", "B:"}, {"cell"}
        }
    },
    ["set_hex_color"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[441]}, {"cell"},
            {"enter"},
            {"text", "HEX:"}, {"cell"}
        }
    },
	["set_stroke_color_hex"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green_orange,
        params = {
            {"text", words[442]}, {"cell"},
            {"enter"},
            {"text", "HEX:"}, {"cell"}
        }
    },
    ["set_stroke_color"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green_orange,
        params = {
            {"text", words[154]}, {"cell"},
            {"enter"},
            {"text", "R:"}, {"cell"}, {"text", "G:"}, {"cell"}, {"text", "B:"}, {"cell"}
        }
    },
    ["set_stroke_width"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green_orange,
        params = {
            {"text", words[155]}, {"enter"}, {"text", words[156]}, {"cell"},
            {"text", words[157]}, {"cell"}
        }
    },
    ["set_anchor"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[158]}, {"cell"},
            {"enter"},
            {"text", words[159]}, {"cell"}, {"text", words[160]}, {"cell"}
        }
    },
	["set_anchorX"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[227]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
	["set_anchorY"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[228]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
    ["set_scale"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[161]}, {"cell"},
            {"enter"},
            {"text", words[162]}, {"cell"}, {"text", words[163]}, {"cell"}
        }
    },
	["set_xScale"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[164]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
	["set_yScale"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green,
        params = {
            {"text", words[165]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
	["set_text"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green_orange,
        params = {
            {"text", words[166]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
	["set_font_size"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.green_orange,
        params = {
            {"text", words[167]}, {"cell"},
            {"enter"},
            {"text", words[150]}, {"cell"}
        }
    },
	["end"] = {
        type = "block",
        color = {0,0,0},
        params = {
            {"text", ""}
        },
		special = "end"
    },
	["end_wait"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.orange,
        params = {
            {"text", words[443]}
        },
		special = "end"
    },
	["local_function"] = {
	    type = "block",
		color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
		params = { {"text", words[444]}, {"cell"}, {"text", words[445]}, {"cell"} },
		special = "cycle"
	},
	["global_function"] = {
	    type = "block",
		color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
		params = { {"text", words[446]}, {"cell"}, {"text", words[447]}, {"cell"} },
		special = "cycle"
	}, 
	["end_func"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
        params = {
            {"text", words[448]}
        },
		special = "end"
    },
	["call_func"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
        params = {
            {"text", words[449]},
			{"cell"}
        }
    },
	["call_func_params"] = {
        type = "block",
        color = GLOB_C_C_C_C_BLOCKCKCKCK.brown,
        params = {
            {"text", words[449]},
			{"cell"},
			{"text", words[450]},
			{"cell"}
        }
    },
}

end

updateBlocksWords()