function custom_select_callback_handler(hDlg, hSrc)

  slConfigUISetVal(hDlg, hSrc, 'ModelReferenceCompliant', 'on');
  slConfigUISetEnabled(hDlg, hSrc, 'ModelReferenceCompliant', false);

  slConfigUISetVal(hDlg, hSrc, 'ParMdlRefBuildCompliant', 'on');
  slConfigUISetEnabled(hDlg, hSrc, 'ParMdlRefBuildCompliant', false);
end

