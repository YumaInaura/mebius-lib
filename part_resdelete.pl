
package main;
use strict;
use Mebius::Export;

#-----------------------------------------------------------
# ���X�̎���폜
#-----------------------------------------------------------
sub bbs_res_selfdelete{

# �Ǐ���
my($line,$flag,$no,$res,$file_handle);
my($q) = Mebius::query_state();
our($moto,$realmoto,$username);
my($basic_init) = Mebius::basic_init();
my($now_date) = Mebius::now_date();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my(%edit_res,$do_title,@BCL);


	# ���e����
	if($ENV{'REQUEST_METHOD'} eq "POST"){
		main::axscheck();
	}

	# �G���[
	if(! our $candel_mode && !$init_bbs->{'allow_user_delete'} && !$init_bbs->{'allow_thread_master_delete'}){ &error({ NotRepairURL => 1 },"���̌f���ł̓��X����͏o���܂���B"); }

# �t�@�C����`
my $no = $q->param('no');
	if($no eq "" || $no =~ /\D/){ &error({ NotRepairURL => 1 },"�L�����w�肵�Ă��������B"); }

# ���X�Ԏw��
my $res_number = $q->param('res');
	if($res_number eq "" || $res_number =~ /\D/){ &error({ NotRepairURL => 1 },"���X�Ԃ��w�肵�Ă��������B"); }
	if($res_number eq "0"){ main::error({ NotRepairURL => 1 },"0�Ԃ̏������݂͍폜�ł��܂���B"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , GetAllLine => 1 , FileCheckError => 1 } , $realmoto,$no);

push @BCL, { url => $thread->{'url'} , title => $thread->{'sub'} } ;
push @BCL,"���X����";

		# ���L����ɂ�郌�X�폜
		if($q->param('do') eq "thread_master"){

			$do_title = "�L����ɂ��폜";

			my($allow_delete_flag) = Mebius::BBS::allow_thread_master_delete_judge($thread,$thread->{'res_data'}->{$res_number},$init_bbs);
				if($allow_delete_flag == 1){
					$edit_res{$res_number}{'comment'} = qq(�y�L������폜�z ( $now_date ));
					$edit_res{$res_number}{'deleted'} = $thread->{'res_data'}->{$res_number}->{'comment'};
					$edit_res{$res_number}{'.'}{'concept'} = qq( Deleted-comment Deleted-by-thread-master);
				} else {
					Mebius::Encoding::from_to('utf8','sjis',$allow_delete_flag);
					main::error({ NotRepairURL => 1 },"$allow_delete_flag");
				}

		# ������폜
		}	else {

			$do_title = "�������g�ɂ��폜";

				if($thread->{'res_data'}->{$res_number}->{'concept'} =~ /Deleted-comment/){ main::error({ NotRepairURL => 1 },"���ɍ폜�ς݂̃��X�ł��B"); }
				if(!$thread->{'res_data'}->{$res_number}){ main::error({ NotRepairURL => 1 },"�Y���̃��X�����݂��܂���B"); }
				if(!$thread->{'res_data'}->{$res_number}->{'user_name'}){ main::error({ NotRepairURL => 1 },"�폜�ł��郌�X�ł͂���܂���B"); }
				if($thread->{'res_data'}->{$res_number}->{'user_name'} ne $username){ main::error({ NotRepairURL => 1 },"�����̃��X�ł͂���܂���B"); }
				if($thread->{'res_data'}->{$res_number}->{'deleted'} eq "" && $q->param('type') eq "delete"){
					$edit_res{$res_number}{'comment'} = qq(�y���e�҂ɂ��폜�z ( $now_date ));
					$edit_res{$res_number}{'deleted'} = $thread->{'res_data'}->{$res_number}->{'comment'};
					$edit_res{$res_number}{'.'}{'concept'} = qq( Deleted-comment Deleted-by-user);
				
				} else {
					 main::error({ NotRepairURL => 1 },"���[�h��I�����Ă��������B");
				}

		}

	# ���m�F��ʂ�\��
	if($ENV{'REQUEST_METHOD'} eq "GET"){

		my ($form,$guide_line);

		$guide_line .= qq(<h1>$do_title</h1>);
		$guide_line .= qq(<div class="margin"><a href="$basic_init->{'guide_url'}%B5%AD%BB%F6%BC%E7%A4%CB%A4%E8%A4%EB%A5%EC%A5%B9%BA%EF%BD%FC" target="_blank" class="blank">�폜�̃K�C�h</a></div>);

		# HTML
		$form .= qq(<h2>���s</h2>);
		$form .= qq(<form action="" method="post"$main::sikibetu>);
		$form .= qq(�ȉ��̏������݂��폜���܂����H);
		$form .= qq(<div class="margin">$thread->{'res_data'}->{$res_number}->{'handle'}</div>);
		$form .= qq(<div class="margin">$thread->{'res_data'}->{$res_number}->{'comment'}</div>);
			foreach($q->param()){
				my $query = $q->param($_);
				$form .= qq(<input type="hidden" name=").e($_).qq(" value=").e($query).qq(">\n);
			}
		$form .= qq(<input type="submit" value="�폜�����s����" class="isubmit">\n);
		$form .= qq(</form>);


		my $print = $guide_line . $form;
		Mebius::Template::gzip_and_print_all({ BodyPrint => 1 , Title => "���X����" , BCL => \@BCL },$print);

		exit;

	}

my($renewed) = Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , res_edit => \%edit_res }, $realmoto,$no);

# ���_�C���N�g
Mebius::Redirect("","./$no.html#S$res_number");

# �^�C�g����`
my $head_link2 = qq( &gt; ���X����);

# HTML
my $print = qq(���s���܂����B<a href="./">�߂�</a>);

Mebius::Template::gzip_and_print_all({ Title => "���X����" , BCL => \@BCL },$print);

# �I��
exit;

}

1;
