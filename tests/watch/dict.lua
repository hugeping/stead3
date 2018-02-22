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
	nam = '$dict';
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
			local r = type(act) == 'function' and act() or act;
			r = '{#recurse|'..r..'}'
			return r
		end;
		used = function()
			use = use or act
			local r = type(use) == 'function' and use() or use;
			r = '{#recurse|'..r..'}'
			return r
		end;
	}
	place(o, 'dict')
end
