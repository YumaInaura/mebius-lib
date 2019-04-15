
#-------------------------------------------------
# 編集を実行 - マイアカウント
#-------------------------------------------------
sub auth_editprof{

# 局所化
my($change_name_flag,$redirect_flag);

# モード分岐
if($in{'type'} eq "cancel_mail"){ require "${int_dir}auth_cancelmail.pl"; }
if($in{'type'} eq "get"){ require "${int_dir}auth_editprof2.cgi"; }

# アクセス制限
&axscheck("NOLOCK");

# 開くファイルを定義
if($in{'account'} && $myadmin_flag){ $file = $in{'account'}; }
else{ $file = $pmfile; }

# 汚染チェック
$file =~ s/[^0-9a-z]//;
if($file eq ""){ &auth_editprof_error("ログインしてください。"); }

# エラー時の追加表示
$fook_error = qq(<strong>送信内容：</strong><br><br>筆名：$in{'name'}<br><br>$in{'prof'});

# 編集モード、開くファイルを選別
$edit_flag = 1;

# タイトルなど定義
$head_link3 = "&gt; 編集";

# ドメインブロック
if(!$postflag){ &auth_editprof_error("ＧＥＴ送信は出来ません。"); }
if($server_domain ne $auth_domain){ &auth_editprof_error("サーバーが違います。"); }

# ID、トリップ付与
&trip($in{'name'});
&id();

# 各種チェック
require "${int_dir}regist_allcheck.pl";
($in{'name'}) = &name_check($in{'name'});
($in{'prof'}) = &all_check($in{'prof'});

# アカウントを開く
&open($file);

# 編集内容の処理
my $length = int(length($in{'prof'}));
if($length > 5000*2){ $e_error .= qq(▼プロフィールが長すぎます。( $length文字 / 5000文字 )<br>); $emd++; }
if($in{'prof'} =~ /前略/ && $in{'prof'} =~ /([0-9]{8,})/){ $e_error .= qq(▼前略プロフィールのＩＤを書き込まないでください。<br>); $emd++; }
if($pmkey eq "2" && $in{'prof'} ne ""){ $e_error .= qq(▼アカウントがロックされている場合、プロフィールを完全に削除しなければ、設定変更できません。<br>); $emd++; }

# エラーとプレビュー
&error_view("AERROR Target","auth_editprof_error");

# ロック開始
&lock("auth$file") if($lockkey);

# アカウントファイルを開く
&open($file);

# リダイレクトする場合
if($pporireki ne $in{'pporireki'}){ $redirect_flag = 1; }

# 筆名変更をチェック
if($in{'name'} ne $ppname){ $change_name_flag = 1; }

# 自分のアカウント以外は編集できない
if(!$myprof_flag && !$myadmin_flag){ &auth_editprof_error("自分のアカウント以外編集できません。"); }

# メルアド認証
if($in{'email'}){
require "${int_dir}main_sendcermail.cgi";
&send_cermail($in{'email'});
}

# アカウント名，パスが一致しない場合エラー
if(!$idcheck){ &auth_editprof_error("編集するにはログインしてください。"); }

$in{'ppocomment'} =~ s/\D//g;
if(length($in{'ppocomment'}) >= 4){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'ppocomment'} > 4){ &auth_editprof_error("設定値が変です。"); }

$in{'ppodiary'} =~ s/\D//g;
if(length($in{'ppodiary'}) >= 2){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'ppodiary'} > 2){ &auth_editprof_error("設定値が変です。"); }

$in{'ppobbs'} =~ s/\D//g;
if(length($in{'ppobbs'}) >= 2){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'ppobbs'} > 2){ &auth_editprof_error("設定値が変です。"); }

$in{'pposdiary'} =~ s/\D//g;
if(length($in{'pposdiary'}) >= 2){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'pposdiary'} > 2){ &auth_editprof_error("設定値が変です。"); }
if($pplevel < 1 && $mebi_mode){ $in{'pposdiary'} = ""; };

$in{'pposbbs'} =~ s/\D//g;
if(length($in{'pposbbs'}) >= 2){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'pposbbs'} > 2){ &auth_editprof_error("設定値が変です。"); }
if($pplevel < 1 && $mebi_mode){ $in{'pposbbs'} = ""; };

$in{'pporireki'} =~ s/\D//g;
if(length($in{'pporireki'}) >= 2){ &auth_editprof_error("設定値が変です。"); }
elsif($in{'pporireki'} > 2){ &auth_editprof_error("設定値が変です。"); }

$in{'ppcolor1'} =~ s/\W//g;
if(length($in{'ppcolor1'}) > 3){ &auth_editprof_error("設定値が変です。"); }

$in{'ppcolor2'} =~ s/\W//g;
if(length($in{'ppcolor2'}) > 3){ &auth_editprof_error("設定値が変です。"); }

# メルアド処理
if($ppmlpass eq ""){ $ppemail = $in{'email'}; }
if($in{'reset_email'}){ $ppemail = ""; $ppmlpass = ""; }

# 自分のプロフィールの場合
if($myprof_flag){ $ppencid = $encid; }

# 変更内容の定義
my $put_ppprof = $in{'prof'};
$ppmtrip = $i_trip;
$ppname = $i_handle;
$ppenctrip = $enctrip;

$ppcolor1 = $in{'ppcolor1'};
$ppcolor2 = $in{'ppcolor2'};

$ppocomment = $in{'ppocomment'};
$ppodiary = $in{'ppodiary'};

$ppobbs = $in{'ppobbs'};
$pposdiary = $in{'pposdiary'};
$pposbbs = $in{'pposbbs'};

$pporireki = $in{'pporireki'};


# 編集実行
require "${int_dir}auth_seditprof.pl";
&seditprof($file);

# プロフィール編集実行
open(PROF_OUT,">${int_dir}_id/$file/${file}_prof.cgi");
print PROF_OUT qq($put_ppprof<>\n);
close(PROF_OUT);
chmod($logpms,"${int_dir}_id/$file/${file}_prof.cgi");

# 筆名履歴の更新
&auth_renew_namefile($file);

# ロック解除
&unlock("auth$file") if($lockkey);

# 筆名変更の場合、全アカウントファイルを更新
if($change_name_flag){
require "${int_dir}auth_avnewac.pl";
&auth_renew_allaccount("CHANGENAME",$file,$i_handle);
}

# リダイレクト
if($redirect_flag && !$alocal_mode){ &redirect("http://aurasoul.mb2.jp/_auth/?mode=editprof&type=get&pporireki=$in{'pporireki'}&account=$in{'account'}"); }

# 編集後、ページジャンプ
$jump_sec = $auth_jump;
if($in{'email'}){ $jump_sec = 10; }
$jump_url = qq(${file}/#EDIT);
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# ヘッダ
&header();

# メルアド入力した場合
my($sendcermail_text1);
if($sendcermail_flag){
$sendcermail_text1 = qq(<br><span class="red">入力されたメールアドレスに認証メールを発行しました。<br>
メールボックスを開いて、認証を続けてください。</span>);
}

# 認証メール発行できなかった場合
if($return){
$return = qq(<br>ただし、次の理由により認証メールは発行できませんでした。<br>
<span class="red">…$return</span>);
}


# HTML
print <<"EOM";
<div class="body1">
編集しました。
<a href="$jump_url">マイアカウント</a>へ移動します。<br>
$sendcermail_text1$after_text1$return
</div>
EOM

# フッタ
&footer();

# 処理終了
exit;

}

#-----------------------------------------------------------
# プレビューとエラー
#-----------------------------------------------------------
sub auth_editprof_error{

# 局所化
my($error) = @_;

# エラー時アンロック
if($lockflag) { &unlock($lockflag); }

# エラー表示
if($error){
$error_line .= qq(
<h2 id="ERROR">エラー</h2>
<div class="error">$error</div>
);
}

$error_line = qq(
<h1>編集フォーム</h1>
$error_line
<h2 id="PREV">プレビュー</h2>
<div class="prev">$in{'prof'}</div>
$myform
);

# マイフォームを取り込み
require "${int_dir}auth_myform.pl";
&auth_myform("",$error_line);

# ヘッダ
&header();

# HTML
print qq(
<div class="body1">
$myform
</div>
);

# フッタ
&footer();

exit;

}


#-----------------------------------------------------------
# 筆名履歴ファイルの更新
#-----------------------------------------------------------
sub auth_renew_namefile{

# 局所化
my($file) = @_;
my($line,$flag,$i);

# ファイル定義
$file =~ s/[^0-9a-z]//;
if($file eq ""){ return; }

# ファイルを開く
open(NAME_IN,"${int_dir}_id/$file/${file}_name.cgi");
while(<NAME_IN>){
$i++;
if($i > 5){ last; }
chomp;
my($name) = split(/<>/);
if($name eq $in{'name'}){ $flag = 1; }
$line .= qq($name<>\n);
}
close(NAME_IN);

if(!$flag){ $line = qq($in{'name'}<>\n) . $line; }

# ファイルを書き込む
open(NAME_OUT,">${int_dir}_id/$file/${file}_name.cgi");
print NAME_OUT $line;
close(NAME_OUT);
chmod($logpms,"${int_dir}_id/$file/${file}_name.cgi");
}

1;
