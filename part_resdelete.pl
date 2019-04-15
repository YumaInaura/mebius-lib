
package main;
use strict;
use Mebius::Export;

#-----------------------------------------------------------
# レスの自主削除
#-----------------------------------------------------------
sub bbs_res_selfdelete{

# 局所化
my($line,$flag,$no,$res,$file_handle);
my($q) = Mebius::query_state();
our($moto,$realmoto,$username);
my($basic_init) = Mebius::basic_init();
my($now_date) = Mebius::now_date();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my(%edit_res,$do_title,@BCL);


	# 投稿制限
	if($ENV{'REQUEST_METHOD'} eq "POST"){
		main::axscheck();
	}

	# エラー
	if(! our $candel_mode && !$init_bbs->{'allow_user_delete'} && !$init_bbs->{'allow_thread_master_delete'}){ &error({ NotRepairURL => 1 },"この掲示板ではレス操作は出来ません。"); }

# ファイル定義
my $no = $q->param('no');
	if($no eq "" || $no =~ /\D/){ &error({ NotRepairURL => 1 },"記事を指定してください。"); }

# レス番指定
my $res_number = $q->param('res');
	if($res_number eq "" || $res_number =~ /\D/){ &error({ NotRepairURL => 1 },"レス番を指定してください。"); }
	if($res_number eq "0"){ main::error({ NotRepairURL => 1 },"0番の書き込みは削除できません。"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , GetAllLine => 1 , FileCheckError => 1 } , $realmoto,$no);

push @BCL, { url => $thread->{'url'} , title => $thread->{'sub'} } ;
push @BCL,"レス操作";

		# ▼記事主によるレス削除
		if($q->param('do') eq "thread_master"){

			$do_title = "記事主による削除";

			my($allow_delete_flag) = Mebius::BBS::allow_thread_master_delete_judge($thread,$thread->{'res_data'}->{$res_number},$init_bbs);
				if($allow_delete_flag == 1){
					$edit_res{$res_number}{'comment'} = qq(【記事主より削除】 ( $now_date ));
					$edit_res{$res_number}{'deleted'} = $thread->{'res_data'}->{$res_number}->{'comment'};
					$edit_res{$res_number}{'.'}{'concept'} = qq( Deleted-comment Deleted-by-thread-master);
				} else {
					Mebius::Encoding::from_to('utf8','sjis',$allow_delete_flag);
					main::error({ NotRepairURL => 1 },"$allow_delete_flag");
				}

		# ▼自主削除
		}	else {

			$do_title = "自分自身による削除";

				if($thread->{'res_data'}->{$res_number}->{'concept'} =~ /Deleted-comment/){ main::error({ NotRepairURL => 1 },"既に削除済みのレスです。"); }
				if(!$thread->{'res_data'}->{$res_number}){ main::error({ NotRepairURL => 1 },"該当のレスが存在しません。"); }
				if(!$thread->{'res_data'}->{$res_number}->{'user_name'}){ main::error({ NotRepairURL => 1 },"削除できるレスではありません。"); }
				if($thread->{'res_data'}->{$res_number}->{'user_name'} ne $username){ main::error({ NotRepairURL => 1 },"自分のレスではありません。"); }
				if($thread->{'res_data'}->{$res_number}->{'deleted'} eq "" && $q->param('type') eq "delete"){
					$edit_res{$res_number}{'comment'} = qq(【投稿者により削除】 ( $now_date ));
					$edit_res{$res_number}{'deleted'} = $thread->{'res_data'}->{$res_number}->{'comment'};
					$edit_res{$res_number}{'.'}{'concept'} = qq( Deleted-comment Deleted-by-user);
				
				} else {
					 main::error({ NotRepairURL => 1 },"モードを選択してください。");
				}

		}

	# ●確認画面を表示
	if($ENV{'REQUEST_METHOD'} eq "GET"){

		my ($form,$guide_line);

		$guide_line .= qq(<h1>$do_title</h1>);
		$guide_line .= qq(<div class="margin"><a href="$basic_init->{'guide_url'}%B5%AD%BB%F6%BC%E7%A4%CB%A4%E8%A4%EB%A5%EC%A5%B9%BA%EF%BD%FC" target="_blank" class="blank">削除のガイド</a></div>);

		# HTML
		$form .= qq(<h2>実行</h2>);
		$form .= qq(<form action="" method="post"$main::sikibetu>);
		$form .= qq(以下の書き込みを削除しますか？);
		$form .= qq(<div class="margin">$thread->{'res_data'}->{$res_number}->{'handle'}</div>);
		$form .= qq(<div class="margin">$thread->{'res_data'}->{$res_number}->{'comment'}</div>);
			foreach($q->param()){
				my $query = $q->param($_);
				$form .= qq(<input type="hidden" name=").e($_).qq(" value=").e($query).qq(">\n);
			}
		$form .= qq(<input type="submit" value="削除を実行する" class="isubmit">\n);
		$form .= qq(</form>);


		my $print = $guide_line . $form;
		Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , Title => "レス操作" , BCL => \@BCL },$print);

		exit;

	}

my($renewed) = Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , res_edit => \%edit_res }, $realmoto,$no);

# リダイレクト
Mebius::Redirect("","./$no.html#S$res_number");

# タイトル定義
my $head_link2 = qq( &gt; レス操作);

# HTML
my $print = qq(実行しました。<a href="./">戻る</a>);

Mebius::Template::gzip_and_print_all({ Title => "レス操作" , BCL => \@BCL },$print);

# 終了
exit;

}

1;
