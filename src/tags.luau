return {
	-- Rarities formatting tags
	secret = {
		open = '<font color="rgb(255, 0, 0)"><stroke color="rgb(63,0,0)" thickness="3"><uppercase>',
		close = "</uppercase></stroke></font>",
	},
	mythic = {
		open = '<font color="rgb(255, 255, 255)"><stroke color="rgb(50,50,50)" thickness="3"><uppercase>',
		close = "</uppercase></stroke></font>",
	},
	legendary = {
		open = '<font color="rgb(255, 204, 0)"><stroke color="rgb(190,125,12)" thickness="3"><uppercase>',
		close = "</uppercase></stroke></font>",
	},
	epic = {
		open = '<font color="rgb(159, 111, 255)"><stroke color="rgb(58,19,86)" thickness="3"><uppercase>',
		close = "</uppercase></stroke></font>",
	},
	rare = {
		open = '<font color="rgb(33, 159, 255)"><stroke color="rgb(17,32,86)" thickness="3"><uppercase>',
		close = "</uppercase></stroke></font>",
	},

	damage = { open = '<font color="rgb(255, 70, 70)">', close = "</font>" },
	critChance = {
		open = '<font color="rgb(255, 150, 50)"><stroke color="rgb(100,0,0)" thickness="1" transparency="0.5">',
		close = "</stroke></font>",
	},

	-- Standard RichText tags
	b = { open = "<b>", close = "</b>" },
	i = { open = "<i>", close = "</i>" },
	u = { open = "<u>", close = "</u>" },
	s = { open = "<s>", close = "</s>" },
	sub = { open = "<sub>", close = "</sub>" },
	sup = { open = "<sup>", close = "</sup>" },
	small = { open = "<small>", close = "</small>" },
	br = { open = "<br/>", close = "" },

	-- Text case tags
	uppercase = { open = "<uppercase>", close = "</uppercase>" },
	uc = { open = "<uc>", close = "</uc>" },
	smallcaps = { open = "<smallcaps>", close = "</smallcaps>" },
	sc = { open = "<sc>", close = "</sc>" },
}
