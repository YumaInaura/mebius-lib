
use strict;
package Mebius::Auth::Vote;
use Mebius::Export;

#-----------------------------------------------------------
# ��{�ݒ�
#-----------------------------------------------------------
sub Init{

my($comments);

# ���t���擾
my($multi_date) = Mebius::now_date_multi();

	if($multi_date->{'ymdf'} =~ /^(\d+)-01-(01|02|03)$/){ $comments .= qq( �����܂��Ă��߂łƂ� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-02-03$/){ $comments .= qq( �܂߂܂� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-02-14$/){ $comments .= qq( ���傱��[�� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-03-03$/){ $comments .= qq( �ЂȂ��� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-03-14$/){ $comments .= qq( �ق킢�Ƃ��傱 ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-07-07$/){ $comments .= qq( �����̂͂��炳�� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-10-31$/){ $comments .= qq( ���ڂ��� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-12-(24|25)$/){ $comments .= qq( �߂肭�肷�܂� ); }
	if($multi_date->{'ymdf'} =~ /^(\d+)-12-31$/){ $comments .= qq( �����˂񂨂��ꂳ�� ); }

$comments .= '�ɂ�[ ���肪�Ƃ� ���߂łƂ� �ɂ����悩���� �ӂ����� �����ꂳ�� ���߂�Ȃ��� ���₷�� ���͂悤 ���Ȃ�������';
return(
maxvote=>3,
comments=>$comments,
);
}

#-----------------------------------------------------------
# �A�J�E���g�̊֘A�L����\��
#-----------------------------------------------------------
sub Mode{

# �錾
my($type,$submode2,%in) = @_;
my(%account);

# �A�J�E���g���J��
(%account) = Mebius::Auth::File("Option",$in{'account'});

	# �^�C�v��`
	if($submode2 eq ""){ &Index("",%account); }
	elsif($submode2 eq "plus"){
		main::axscheck("Postonly ACCOUNT");
		&Data("Renew Plus",$account{'file'});
	}
	else{ main::error("���s�^�C�v���w�肵�Ă��������B"); }

# ��O�G���[
main::error("����������܂���B");

exit;

}

#-----------------------------------------------------------
# ���[�̊�{�y�[�W
#-----------------------------------------------------------
sub Index{

# �錾
my($type,%account) = @_;
my(%init) = &Init();
my(%data,$submit_button,$vote_form,%myaccount,$index_line,$history_line,$reason_select,$index_line_view,$disabled_flag);

# �����̎c�蓊�[�|�C���g���`�F�b�N
#(%myaccount) = Mebius::Auth::Optionfile("Get",$main::pmfile);
my($my_account) = Mebius::my_account();

# ���[�f�[�^�̃C���f�b�N�X���擾
($index_line,$history_line) = &Data("Index",$account{'file'});

	# �c�蓊�[�|�C���g�������ꍇ
	#if($main::cgold <= -1){
	#	$submit_button = qq(<span style="color:#f00;font-size:small;">�����Ȃ��̋��݂��}�C�i�X�̂��߁A�L�𑝂₹�܂���B</span>);
	#	$disabled_flag = 1;
	#}
	#els

	if($my_account->{'allow_vote'} eq "not-use"){
		$submit_button = qq(<span style="color:#f00;font-size:small;">�����Ȃ����L���󂯎��Ȃ��ݒ�ɂ��Ă���ƁA�L���������܂���B</span>);
		$disabled_flag = 1;
	}
	elsif($my_account->{'todayvotepoint'} <= 0){
		$submit_button = qq(<span style="color:#f00;font-size:small;">���莝���̃|�C���g������܂���A�����܂ł��҂����������B</span>);
		$disabled_flag = 1;
	}
	elsif($account{'allow_vote'} eq "not-use"){
		$submit_button = qq(<span style="color:#f00;font-size:small;">�����̃����o�[�͔L���󂯎���Ă��܂���B</span>);
		$disabled_flag = 1;
	}
	else{
		$submit_button = qq(<input type="submit" value="�L�𑝂₷"$main::xclose>);
	}

# CSS��`
$main::css_text .= qq(
td,th{padding:0.2em 1em 0.2em 0em;}
div.about_sozai{text-align:right;}
img.nekoasi{width:20px;height:19px;}
table.vote th{text-align:left;}
);

	# ���[���R�̃Z���N�g�{�b�N�X
	if(!$disabled_flag){
		$reason_select .= qq(<select name="reason">\n);
		#$reason_select .= qq(<option>�C����</option>\n);
			foreach(split(/\s/,$init{'comments'})){
				if(!$_){ next; }
				$reason_select .= qq(<option>$_</option>\n);
			}
		$reason_select .= qq(</select>);
	}

# �t�H�[����`
$vote_form = qq(
<h2$main::kfontsize_h2>�L�𑝂₷</h2>
<ul>
<li><a href="$main::auth_url$account{'file'}/">$account{'name'} - $account{'file'}</a> ����̔L�𑝂₹�܂��B</li>
<li>�����͂��� <strong style="color:#f00;">$my_account->{'todayvotepoint'}��</strong> �܂Ŏ��s�ł��܂��B</li>
</ul>
<form action="$main::auth_url" method="post"$main::sikibetu>
<div>
<input type="hidden" name="mode" value="vote-plus"$main::xclose>
<input type="hidden" name="account" value="$account{'file'}"$main::xclose>
<br$main::xclose>$submit_button
$reason_select
</div>
</form>
);

	
	# ���O�C�����Ă��Ȃ��ꍇ�A�t�H�[��������
	if(!$main::idcheck){ $vote_form = ""; }

	# �����̏ꍇ
	if($account{'myprof_flag'}){ $vote_form = ""; }
	
	# �L�����ꂽ�l����
	if($index_line){
		$index_line_view .= qq(<h2$main::kfontsize_h2>�L�����ꂽ�l����</h2>);
			if($main::kflag){ $index_line_view .= qq($main::khrtag); }
			else{ $index_line_view .= qq(<table summary="�L����" class="width100 vote"><tr><th>���C�ځH</th><th colspan="3">�L�����ꂽ�l</th><th>���̎��̋C����</th><th>����</th></tr>); }
		$index_line_view .= qq($index_line);
			if(!$main::kflag){ $index_line_view .= qq(</table>); }

		# �A�C�R���z�z����\��
		$index_line_view .= qq(<div class="about_sozai"><a href="${main::guide_url}%A5%E9%A5%A4%A5%BB%A5%F3%A5%B9#p2">�A�C�R���f�ނɂ���</a></div>);
	}

	# CSS��`
	if($account{'color1'}){
		$main::css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};});
	}

# HTML����
my $print = qq(
$vote_form
$index_line_view
<h2$main::kfontsize_h2>�L����(����)</h2>
<ul>
$history_line
</ul>
);


# �w�b�_
main::auth_html_print($print,"�L",\%account);

exit;

}

#-----------------------------------------------------------
# �ʃf�[�^�t�@�C��
#-----------------------------------------------------------
sub Data{

# �錾
my($type,$file) = @_;
my(%init) = &Init();
my($basic_init) = Mebius::basic_init();
my($my_account) = Mebius::my_account();
my(undef,undef,$max_view) = @_ if($type =~ /Index/);
my($datafile,$vote_handler,@renewline,$i,$maxline,%account,%renew_option,%myaccount,%renew_myoption,$index_line);
my($same_yearmonth_flag,@thistory,$history_line,$newreason,$hit_index,$all_vote_count,$new_vote_point,$new_account2_vote_point);

# �t�@�C����`
$file =~ s/\W//g;
if($file eq ""){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

$datafile = "${account_directory}${file}_vote.log";

	# ���t�@�C���X�V�p�̑O����
	if($type =~ /Renew/){

		# �A�N�Z�X���� # �Ȃ������ŃA�N�Z�X�������H
		#main::axscheck("Postonly ACCOUNT");

		# ����̃A�J�E���g���J��
		(%account) = Mebius::Auth::File("Hash Option Lock-check",$file);

		# �����̃A�J�E���g���J��
		(%myaccount) = Mebius::Auth::File("Hash Option",$main::pmfile);

			# �L�𑝂₷�ꍇ�̊e��G���[
			if($type =~ /Plus/){
					if($my_account->{'allow_vote'} eq "not-use"){ main::error("�L���󂯎��Ȃ��ݒ�ɂ��Ă���ƁA�L���������܂���B"); }
					if($account{'allow_vote'} eq "not-use"){ main::error("���̃����o�[�͔L���󂯎���Ă��܂���B"); }
					if($myaccount{'todayvotepoint'} <= 0){ main::error("�莝���̔L�|�C���g������܂���B�����܂ő҂��Ă��������B"); }
					if($account{'myprof_flag'} && !Mebius::alocal_judge()){ main::error("�����̔L�͑��₹�܂���B"); }
					if($account{'sameaccess_flag'} && !$main::myadmin_flag && !Mebius::alocal_judge()){ main::error("�����̔L�͑��₹�܂���B"); }
					if(!$main::pmfile){ main::error("�L�𑝂₷�ɂ́A�A�J�E���g�Ƀ��O�C�����Ă��������B"); }
					#if($main::cgold <= -1){ main::error("���Ȃ��̋��݂��}�C�i�X�̂��߁A�L�𑝂₹�܂���B"); }
			}
	}

# �ő�s��
$maxline = 10;

# �ő�\���s��
if(!$max_view){ $max_view = 10 ;}

# �t�@�C�����J��
open($vote_handler,"<",$datafile);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($vote_handler,1); }

#�g�b�v�f�[�^�𕪉�����
chomp(my $top1 = <$vote_handler>);
my($tkey,$tlasttime,$thistory) = split(/<>/,$top1);

	# ���[���A���[�|�C���g�̑���
	if($type =~ /Plus/){
		#main::axscheck("ACCOUNT");
		$renew_option{'+'}{'votepoint'} = 1;
		$new_vote_point = $account{'votepoint'} + 1;
		$renew_myoption{'lastvote'} = "$main::thisyear-$main::thismonthf-$main::todayf";
		$renew_myoption{'-'}{'todayvotepoint'} = 1;
	}

	# ���[���R
	if($type =~ /Plus/){
			foreach(split(/\s/,$init{'comments'})){
				if($main::in{'reason'} eq $_){ $newreason = $_; }
			}
	}

	# ���[�������ʂɕ�������
	foreach(split(/\s/,$thistory)){
		my($year2,$month2,$count2) = split(/=/,$_);
			if("$year2=$month2" eq "$main::thisyear=$main::thismonthf"){
					if($type =~ /Renew/){ $count2++; }
				#$thismonthcount = $count2;
				$same_yearmonth_flag = 1;
			}
		$all_vote_count += $count2;

			if($type =~ /Index/){ $history_line .= qq(<li>$year2/$month2 - $count2�L</li>); }
		push(@thistory,"$year2=$month2=$count2");
	}

	# ���Ă��܂��������f�[�^�����ɖ߂�	# 2012/1/25 
	#if($all_vote_count > $account{'votepoint'}){
	#	$renew_option{'votepoint'} = $all_vote_count;
	#}

	# ���[�����������ꍇ�A�����[���������ĐV�K�쐬
	if(@thistory <= 0 && $type =~ /Plus/){ unshift(@thistory,"$main::thisyear=$main::thismonthf=$account{'votepoint'}"); }

	# �V�������̏ꍇ
	elsif(!$same_yearmonth_flag && $type =~ /Plus/){
		unshift(@thistory,"$main::thisyear=$main::thismonthf=1");
	}

	# �g�b�v�f�[�^���擾���ăn�b�V���Ƃ��ĕԂ�
	#if($type =~ /Topdata/){
	#	close($vote_handler);
	#}

	# �t�@�C����W�J����
	while(<$vote_handler>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$account2,$handle2,$lasttime2,$date2,$votenum2,$comment2,$account2_vote_point2) = split(/<>/);

			# ���t�@�C���X�V�p�̏���
			if($type =~ /Renew/){

				# �ő�s���ɒB�����ꍇ
				if($i >= $maxline){ next; }
				
				# �X�V�s��ǉ�
				push(@renewline,"$key2<>$account2<>$handle2<>$lasttime2<>$date2<>$votenum2<>$comment2<>$account2_vote_point2<>\n");

			}

			#�� �C���f�b�N�X�\���p�̏���
			if($type =~ /Index/){

				# �Ǐ���
				my($votelink2,$mylink2,$nekoasi_image,$nekoasi_number,%account2);

				# �q�b�g�J�E���^
				$hit_index++;

					# �ő�\���s���ɒB�����ꍇ
					if($hit_index > $max_view){ last; }

					# �A�J�E���g�f�[�^���擾
					if($type !~ /Not-get-account/){

						#(%account2) = Mebius::Auth::File("Hash Option",$account2);

							# �e�A�J�E���g�̔L�����N
							#if($account2{'allow_vote'} eq "not-use"){ }
							#else{ $votelink2 = qq(<a href="$basic_init->{'auth_url'}$account2/vote">�L($account2{'votepoint'})</a>); }
							#if($account2_vote_point2 ne "not-use"){
								$votelink2 .= qq(<a href="$basic_init->{'auth_url'}$account2/vote">);
								$votelink2 .= qq(�L);
								$votelink2 .= qq/($account2_vote_point2)/ if $account2_vote_point2;
								$votelink2 .= qq(</a>);
							#}

					}

				# �������߂t�q�k
				if($account2{'mylink'}){
						if($main::kflag){ $mylink2 = qq(<a href="$account2{'myurl'}">URL</a>); }
						else{ $mylink2 = qq($account2{'mylink'}); }
				}
		
				# ���C�ڂ̔L�H
				if($votenum2 eq ""){ $votenum2 = "�H"; }

				# ���Չ摜
				$nekoasi_number = int((($votenum2 / 10) % 5)+1);
				$nekoasi_image = qq(<img src="/pct/nekoasi$nekoasi_number.png" alt="����" class="nekoasi">);
				
				my($howlong_stamp2) = shift_jis(Mebius::second_to_howlong({ ColorView => 1 , HowBefore => 1 , GetLevel => "top" },time - $lasttime2));

				# �g�є�
				if($main::kflag){
					$index_line .= qq($votenum2�C�� $comment2);
					$index_line .= qq(<br$main::xclose><a href="$basic_init->{'auth_url'}$account2/">$handle2 - $account2</a> $mylink2 );
					$index_line .= qq(<br$main::xclose>$howlong_stamp2);
					$index_line .= qq($main::khrtag);
				}

				# PC��
				else{
					$index_line .= qq(<tr>);
					$index_line .= qq(<td>$nekoasi_image $votenum2�C��</td>);
					$index_line .= qq(<td><a href="$basic_init->{'auth_url'}$account2/">$handle2 - $account2</a></td>);
					$index_line .= qq(<td>$votelink2</td>);
					$index_line .= qq(<td>$mylink2</td>);
					$index_line .= qq(<td>$comment2 </td>);
					$index_line .= qq(<td>$howlong_stamp2</td>);
					$index_line .= qq(</tr>\n);
				}
			}

	}

close($vote_handler);

	# ���C���f�b�N�X�擾�p�̌㏈��
	if($type =~ /Index/){
			if($index_line eq ""){ $index_line = qq(�f�[�^������܂���B); }
		return($index_line,$history_line);
	}

	# ���t�@�C���X�V�̌㏈��
	elsif($type =~ /Renew/){


		# ���݂��̋֎~��Ԃ��`�F�b�N
		Mebius::Auth::FriendStatus("Deny-check-error",$account{'file'},$main::myaccount{'file'});
		Mebius::Auth::FriendStatus("Deny-check-error",$main::myaccount{'file'},$account{'file'});

		# ����̃I�v�V�����t�@�C�����X�V 
		#Mebius::Auth::Optionfile("Renew",$file,%renew_option);
		my(%renewed_target) = Mebius::Auth::File("Renew Option",$file,\%renew_option);

		# �����̃I�v�V�����t�@�C�����X�V 
		#Mebius::Auth::Optionfile("Renew",$main::pmfile,%renew_myoption);
		my(%renewed_my_account) = Mebius::Auth::File("Renew Option",$main::pmfile,\%renew_myoption);

		# �V�����s��ǉ�����
		unshift(@renewline,"1<>$main::pmfile<>$main::pmname<>$main::time<>$main::date<>$new_vote_point<>$newreason<>$renewed_my_account{'votepoint'}<>\n");

		# �g�b�v�f�[�^��ǉ�����
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline,"$tkey<>$main::time<>@thistory<>\n");

		# �t�@�C�����X�V
		Mebius::Fileout("",$datafile,@renewline);

		# �����̍s���������X�V����
		Mebius::Auth::History("Renew",$main::pmfile,$file,qq(��<a href="$basic_init->{'auth_url'}$file/vote">�L</a>�𑝂₵�܂����B));

		# ��{���e�������X�V
		Mebius::HistoryAll("RENEW My-file");

		# ����̐V�������X�V����
		Mebius::Auth::News("Renew Hidden-from-index Log-type-vote",$file,$main::pmfile,$main::myaccount{'handle'},qq(<a href="$basic_init->{'auth_url'}$file/vote">�L</a>�����炢�܂��� ($renewed_target{'votepoint'}�C��)));

		# ���_�C���N�g
		Mebius::Redirect("","$basic_init->{'auth_url'}$file/vote");

	}

return();

}


1;
