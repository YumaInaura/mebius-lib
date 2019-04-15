#-----------------------------------------------------------
# メンテナンス中の表示
#-----------------------------------------------------------
sub all_mente{

# 管理者はリターン
if($ENV{'REMOTE_ADDR'} eq $main::master_addr){ return; }

# ヘッダ
print "Status: 503 Service Unavailable\n";
print "Content-type:text/html\n\n";


# HTML
print qq(
<html lang="ja">
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
</head>
<body>
503 Service Unavailable<br><br>
ただいまサイトのメンテナンス中です、しばらくお待ちください。
</body>
</html>
);

exit;

}


1;
