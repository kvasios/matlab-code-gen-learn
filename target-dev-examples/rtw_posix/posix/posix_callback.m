function posix_callback(dlg, src, element)
    state = slConfigUIGetVal(dlg, src, element);

    if strcmp(element, 'NoClockSource')
        if strcmp(state, 'on')
            slConfigUISetEnabled(dlg, src, 'ExternalClockSource', false);
            slConfigUISetEnabled(dlg, src, 'ExternalTimerSource', false);
            slConfigUISetEnabled(dlg, src, 'ExternalTimerIncludes', false);
            slConfigUISetEnabled(dlg, src, 'ExternalTimerLibraries', false);
            slConfigUISetEnabled(dlg, src, 'ExternalTimerPrefix', false);
        else
            slConfigUISetEnabled(dlg, src, 'ExternalClockSource', true);        
            posix_callback(dlg, src, 'ExternalClockSource');
        end
    elseif strcmp(element, 'ExternalClockSource')
        flag = strcmp(state, 'on');
        slConfigUISetEnabled(dlg, src, 'ExternalTimerSource', flag);
        slConfigUISetEnabled(dlg, src, 'ExternalTimerIncludes', flag);        
        slConfigUISetEnabled(dlg, src, 'ExternalTimerLibraries', flag);
        slConfigUISetEnabled(dlg, src, 'ExternalTimerPrefix', flag);
    end
