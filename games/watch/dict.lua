obj {
	nam = 'dict';
	obj = {
		obj {
			nam = '#recurse';
			act = true;
			use = true;
		}
	}
}

dict = obj {
	nam = '$d';
	act = function(s, w, n)
		if not seen 'dict' then
			put 'dict'
		end
		return "{#dict-"..w.."|"..n.."}";
	end;
}

function dict.add(word, act, use)
	local o = obj {
		nam = '#dict-'..word;
		act = function()
			if type(act) == 'function' then
				return act()
			end
			return act
		end;
		used = function()
			use = use or false -- act
			if type(use) == 'function' then
				return use()
			end
			return use
		end;
	}
	place(o, 'dict')
end
