
package Mebius::Dungeon;
use strict;

#-----------------------------------------------------------
# ��{�ݒ����荞��
#-----------------------------------------------------------
sub Init{

# �錾
my($dungeon_url);

# CSS��`
$main::css_text .= qq(
.body1{background:#000;color:#fff;padding:1.5em;}
div.actions{word-spacing:0.3em;}
div.navilinks{margin:1em 0em;}
ul{margin:0.5em 0em;}
);

	# ��{�t�q�k
	if($main::kflag){
		$dungeon_url = qq(http://$main::server_domain/imode/_games/dungeon/);
	}
	else{
		$dungeon_url = qq(http://$main::server_domain/_games/dungeon/);
	}

# �ݒ�l��n��
return(
"basemode" => "",
"title" => "�_���W�������[�N",
"dungeon_url" => "$dungeon_url",
"white_style" => qq( style="color:#fff;"),
"levy_blankhour" => 1
);

}

#-----------------------------------------------------------
# �Q�[�����[�h�U�蕪��
#-----------------------------------------------------------
sub Mode{

# �錾
my(%init) = &Init();

	# ��{�^�C�g�����`
	$main::head_link3 = qq( &gt; <a href="./"$main::sikibetu>$init{'title'}</a> );
	$main::sub_title = $init{'title'};

	# �O���[�o���ϐ���������
	our(%done) = undef;

	# ���C���p�b�P�[�W�̃O���[�o���ϐ����`	
	$main::kboad_link_select = qq( <a href="./" accesskey="3"$main::sikibetu>�B�ƭ�</a>);
	$main::kboad_link_select2 = qq( �B�ƭ�);

	# ���[�h�U�蕪��
	if($main::mode eq ""){ &Index("Pure-index"); }
	elsif($main::submode1 eq "status"){ &Status("Page-view Detail Select",$main::submode2); }
	elsif($main::submode1 eq "member"){ &Member("Page-view Index"); }
	elsif($main::mode eq "aube"){ &Aube("Page-view"); }
	elsif($main::mode eq "go"){ &Go("",$main::in{'select'}); }
	elsif($main::mode eq "newstart"){ &Newstart(); }
	else{ main::error("�y�[�W�����݂��܂���B"); }

}


#-----------------------------------------------------------
# �_���W�����g�b�v�y�[�W ( �������[�v�ɒ��ӁI )
#-----------------------------------------------------------
sub Index{

# ��{�ݒ���擾
my($type,$h1,$message) = @_;
my(%init) = &Init();
my($status_line,%status,$newstart_line,$action_line,$navilinks_line,$otherlinks_line);
our(%done);

	# �������[�v�����
	if($done{'index'}){ return(); }
	$done{'index'} = 1;

	# ���C���p�b�P�[�W�̃O���[�o���ϐ����`	
	$main::kboad_link_select = qq( �B�ƭ�);
	$main::kboad_link_select2 = qq( �B�ƭ�);

	# �w�b�_�����N���`
	if($type =~ /Pure-index/){
		$main::head_link3 = qq( &gt; $init{'title'} );
		$main::sub_title = $init{'title'};
	}

	# �X�e�[�^�X
	if($type !~ /Only-view/){ ($status_line,%status) = &Status("Me"); }

	# �V�K�o�^�t�H�[��
	if($type !~ /Only-view/){
			if($status{'key'} eq "1"){ }
			else{
				$newstart_line = qq(
				$main::khrtag<h2$main::kfontsize_h2>�V�K�o�^</h2>
				<form action="./" method="post"$main::sikibetu>
				<div>
				<input type="hidden" name="moto" value="games"$main::xclose>
				<input type="hidden" name="game" value="dungeon"$main::xclose>
				<input type="hidden" name="mode" value="newstart"$main::xclose>
				<input type="submit" value="�V�K�o�^����"$main::xclose>
				$main::kinputtag
				</div>
				</form>
				);
			}
	}

	# �s���t�H�[�����擾
	if($type !~ /Only-view/){ ($action_line) = &Form("Action",%status); }

	# H1���`
	if($h1){
		$main::sub_title = qq($h1 | $init{'title'});
		$main::head_link4 = qq( &gt; $h1);
		$h1 = qq(<h1$main::kfontsize_h1>$h1</h1>);
	}
	else{
		$h1 = qq(<h1$main::kfontsize_h1>$init{'title'}</h1>);
	}

	# ���b�Z�[�W���`
	if($message){ $message = qq($message);}
	else{ 
		$message = qq(
		���̃Q�[���̓e�X�g���ł��B<strong class="red">�{���ɁA�\\���Ȃ���</strong>�A���ׂẴQ�[���f�[�^�͍폜�����ꍇ������܂��B
		);
	}
	if($type =~ /Link-to-back/){ $message .= qq(<a href="$init{'dungeon_url'}"$init{'white_style'}$main::sikibetu>�߂�</a>); }

	# �i�r�Q�[�V���������N���`
	if($type =~ /Navi-links/){ 
		$navilinks_line .= qq(<a href="./"$init{'white_style'}$main::sikibetu>���j���[�ɖ߂�</a>\n);
	}
	if($type =~ /Status-view/){
		$navilinks_line .= qq(<a href="./member"$init{'white_style'}$main::sikibetu>�Q����</a>\n);
	}
	if($navilinks_line){ $navilinks_line = qq(<div class="navilinks">$navilinks_line</div>); } 

	# ���̑��̃����N ( ���O�C�����Ă��Ȃ��Ă��\������ )
	if($type !~ /Only-view/){
		$otherlinks_line .= qq($main::khrtag<h2$main::kfontsize_h2>�ꗗ</h2>);
		$otherlinks_line .= qq(<a href="./member"$init{'white_style'}$main::sikibetu>�Q����</a>);
	}


# �w�b�_
main::header("Body-print Not-search-me Mobile-background-black Not-hr");

# HTML
print qq(
$h1
$navilinks_line
<div class="message">$message</div>
$newstart_line
<div class="actions">$action_line</div>
$status_line
$otherlinks_line
);

# �t�b�^
main::footer("Body-print Not-hr");

exit;


}

#-----------------------------------------------------------
# �s���t�H�[�����擾
#-----------------------------------------------------------
sub Form{

# �錾
my($type) = @_;
my(%init) = &Init();
my($line,$monster_link,$levy_link,$fight_link);

	# �}�C�f�[�^���擾
	my(%status) = &Datafile("Me Get");

	# �}�C�f�[�^���Ȃ��ꍇ���^�[������
	if($status{'key'} ne "1"){ return(); }

# ���`
$line .= qq($main::khrtag<h2$main::kfontsize_h2>�s��</h2>\n);

	# �_�E�����Ă���ꍇ
	if($status{'down_flag'}){ $line .= qq($status{'down_flag'}); }

	else{

		# �h�����𑝂₷�h�����N
		($monster_link) = &Buy("Get-link",undef,%status);
		$line .= $monster_link;

		# �h�ŋ��𒥎��h�����N
		($levy_link) = &Levy("Get-link",undef,%status);
		$line .= $levy_link;

		# �h�G���}�����h�����N
		($fight_link) = &Fight("Get-link",undef,%status);
		$line .= $fight_link;

	}

# ���`
$line .= qq($main::khrtag<h2$main::kfontsize_h2>���̑�</h2>\n);

	# �h�I�[�u�h�����N
	if($status{'aube'} eq ""){}
	else{ $line .= qq(<a href="./aube"$init{'white_style'}$main::sikibetu>�I�[�u($status{'aube'})</a>); }

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �s������i�S�ʁj
#-----------------------------------------------------------
sub Go{

# �錾
my($type,$select) = @_;
my(%init) = &Init();
my(%renew,%status,$status_line,$message,$action_line,$message2,$h1,$this_title);

# �f�[�^���擾
(%status) = &Datafile("Me Get Action");

	# �_�E�����Ă���ꍇ
	if($status{'down_flag'}){ main::error("$status{'down_flag'}"); }

	# �L�[�������ꍇ
	if($status{'key'} eq ""){ Mebius::Redirect("",$init{'dungeon_url'}); }

	# �^�C�v�U�蕪��
	if($main::in{'type'} eq "buy"){
		($message,$this_title,%status) = &Buy("Buy",undef,%status);
	}
	elsif($main::in{'type'} eq "fight"){
		($message,$this_title,%status) = &Fight("",undef,%status);
	}
	elsif($main::in{'type'} eq "levy"){
		($message,$this_title,%status) = &Levy("",undef,%status);
	}
	elsif($main::in{'type'} eq "aube"){
		($message,$this_title,%status) = &Aube("Use",$main::in{'select'},%status);
	}
	elsif($main::in{'type'} eq "edit"){
		($message,$this_title,%status) = &Edit("Edit",undef,%status);
	}
	else{
		main::error("�s���^�C�v��I��ł��������B");
	}

# �f�[�^�t�@�C�����X�V
&Datafile("Me Renew Action",%status);

# �^�C�g����`
$main::sub_title = qq(�A�N�V���� | $init{'title'});
$main::head_link3 = qq( &gt; �A�N�V����);

# �W�����v
#$main::jump_url = "./";
#$main::jump_sec = 5;

# �C���f�b�N�X��\��
&Index("Link-to-back",$this_title,"$message $message2");

exit;


}


#-----------------------------------------------------------
# �G���}������
#-----------------------------------------------------------
sub Fight{

# �錾
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$killed_monster,$get_exp,$this_title);
my($return_link);

	# ���̃A�N�V�����̃^�C�g����`
	$this_title = qq(�G���}������);

	# ��{�����N
	$return_link = qq($this_title($status{'fight_count'}/$status{'fight_maxcount'}));

	# �S�[���h������Ȃ��ꍇ
	if($status{'fight_count'} <= 0){
			if($type =~ /Get-link/){ return qq($return_link\n); }
			else{ main::error("�����͂����킦�܂���B"); }
	}
	if($status{'monster'} <= 0){
			if($type =~ /Get-link/){ return qq($this_title(�����s��)\n); }
			else{ main::error("���������Ȃ��Đ킦�܂���B�񕜂��Ă��������B"); }
	}

	# �����N�擾�̏ꍇ�A���^�[��
	if($type =~ /Get-link/){
		$return_link = qq(<a href="./?mode=go&amp;type=fight&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	return($return_link);
	}


# �X�e�[�^�X�𒲐�
$killed_monster = int(rand(5))+1;
$status{'monster'} -= $killed_monster;
if($status{'monster'} <= 0){ $status{'monster'} = 0; }

# �o���l�̏���
$get_exp = int(rand(10))+1;
$status{'exp'} += $get_exp;


# �퓬�����𒲐�
$status{'fight_count'} -= 1;
$status{'lastfight_yearmonthday'} = "$main::thisyear-$main::thismonthf-$main::todayf";
$message = qq(�G�Ɛ�����I�@������$killed_monster�̌������B $get_exp �̌o����ς񂾁B);

	# ���x���A�b�v����
	if($status{'exp'} > $status{'nextexp'}){
		$status{'level'} += 1;
		$status{'aube'} += 1;
		$status{'exp'} -= $status{'nextexp'};
		$message .= qq(<br$main::xclose>���x���A�b�v�I ���x���� $status{'level'} �ɂȂ�A�I�[�u�� $status{'aube'}�ɑ������B);
	}

	# HP���Ȃ��Ȃ�_�E�������ꍇ
	if($status{'monster'} <= 0){
		$status{'downtime'} = $main::time + 30*60;
		$message .= qq(<br$main::xclose>�������[���ɂȂ�A���Ȃ��̓_�E�����Ă��܂����I);
	}

# ���^�[��
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# �I�[�u
#-----------------------------------------------------------
sub Aube{

# �錾
my($type,$select,%status) = @_;
my(%init) = &Init();
my($line,$h1,$message,$this_title);

	# ���̃A�N�V�����̃^�C�g����`
	$this_title = qq(�I�[�u���g��);

	# �X�e�[�^�X�������ꍇ�͎擾
	if(!keys(%status)){ (%status) = &Datafile("Me Get"); }

	# ��p�y�[�W�Ƃ��ĕ\������ꍇ
	if($type =~ /Page-view/){

		# ���o�����`
		$h1 = qq(�I�[�u);

		# HTML����
		$line .= qq(<div>);
		$line .= qq(���Ȃ��̃I�[�u�F ���� $status{'aube'} �@���x���A�b�v����ƃI�[�u�������܂��B);
		$line .= qq(<ul>);

			# �I�[�u������ꍇ�̂ݕ\�����镔��
			if($status{'aube'} >= 1){
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=yellow&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>�C�G���[�I�[�u</a></li>);
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=green&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>�O���[���I�[�u</a></li>);
				$line .= qq(<li><a href="./?mode=go&amp;type=aube&amp;select=purple&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>�p�[�v���I�[�u</a></li>);
			}
			else{
				$line .= qq(<li>�I�ׂ�g�����Ⴀ��܂���B</li>);	
			}

		# HTML����
		$line .= qq(</ul>);
		$line .= qq(</div>);

		# ��p�y�[�W�Ƃ��ĕ\������
		&Index("Only-view Navi-links",$h1,$line);

	}

	# �I�[�u���g��
	if($type =~ /Use/){

		# �I�[�u�������ꍇ
		if($status{'aube'} <= 0){ main::error("�I�[�u�͂P������܂���B"); }

		# ���s�����ꍇ
		if(rand(3.5) < 1){
			$message = qq(���s�����B�I�[�u�͕��X�ɍӂ��U��A�Â��ł̒��ւƗn���Ă������B);
		}

		# �����𑝂₷
		elsif($select eq "yellow"){
			$status{'income'} += int(rand(2)) + 1;
			$message = qq(�I�[�u���g�����I �����𑝂₵���B);
		}

		# �ő哢�����𑝂₷
		elsif($select eq "green"){
			$status{'fight_maxcount'} += 1;
			$status{'fight_count'} = $status{'fight_maxcount'};
			$message = qq(�I�[�u���g�����I �ő哢������ 1 ���₵���B);
		}

		# �����̍ő吔���グ��
		elsif($select eq "purple"){
			$status{'monster_max'} += int(rand(2)) + 1;
			$status{'monster'} = $status{'monster_max'};
			$message = qq(�I�[�u���g�����I �����̍ő吔�𑝂₵���B);
		}

		# �I���������ꍇ
		else{
			main::error("�I�[�u�̎g������w�肵�Ă��������B");
		}

		# �I�[�u�������炷
		$status{'aube'} -= 1;
	}


# ���^�[��
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# ���{����������
#-----------------------------------------------------------
sub Buy{

# �錾
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$spend_gold,$plused_monster,$return_link,$this_title);

# �����̒l�i
$spend_gold = 10;

	# ���̃A�N�V�����̃^�C�g����`
	$this_title = qq(�����𑝈�);

	# ��{�����N
	if($type =~ /Get-link/){
		$return_link = qq($this_title($status{'monster'}/$status{'monster_max'}));
	}

	# �S�[���h������Ȃ��ꍇ
	if($status{'gold'} < $spend_gold){
			if($type =~ /Get-link/){ return qq($this_title($status{'monster'}/$status{'monster_max'})\n); }
		main::error("����������܂���B");
	}
	
	# �������}�b�N�X�̏ꍇ
	if($status{'monster'} >= $status{'monster_max'}){
			if($type =~ /Get-link/){ return qq($this_title($status{'monster'}/$status{'monster_max'})\n); }
		main::error("�����������ς��ł��B");
	}

	# ����݂̂̏ꍇ���^�[��
	if($type =~ /Get-link/){
		return qq(<a href="./?mode=go&amp;type=buy&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	}

# �S�[���h����
$status{'gold'} -= $spend_gold;

# �����𑝂₷
$plused_monster = int(rand(3))+1;
$status{'monster'} += $plused_monster;

# ���b�Z�[�W
$message = qq($spend_gold G�Ŗ����� $plused_monster�̑��������B);

# ���^�[��
return($message,$this_title,%status);

}

#-----------------------------------------------------------
# �ŋ��𒥎�����
#-----------------------------------------------------------
sub Levy{

# �錾
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$return_link,$this_title);

	# ���̃A�N�V�����̃^�C�g����`
	$this_title = qq(�ŋ��𒥎�);

	# �����N��`
	$return_link = qq($this_title($status{'income'}G/1h));

	# �����f�[�^���Ȃ��ꍇ�A 1���ԕ� ��������
	if($status{'lastlevytime'} eq ""){ $status{'levygold'} = $status{'income'}*1; }

	# �����ł�����z���Ȃ��ꍇ
	if($status{'levygold'} <= $status{'income'} / 6){
			if($type =~ /Get-link/){ return qq($this_title($status{'income'}G/1h)\n); }
			else{ main::error("�����ł�����z������܂���B�b���̒��������܂�̂�҂��Ă��������B"); }
	}

	# �����N��Ԃ��ꍇ
	if($type =~ /Get-link/){
		return qq(<a href="./?mode=go&amp;type=levy&amp;action_salt=$status{'action_salt'}"$init{'white_style'}$main::sikibetu>$return_link</a>\n);
	}

# �����X�^�[�𑝂₷
$status{'gold'} += $status{'levygold'};
$status{'lastlevytime'} = $main::time;
$message = qq(�b������$status{'levygold'} G�𒥎������B);

# ���^�[��
return($message,$this_title,%status);

}

#-----------------------------------------------------------
# �ݒ�ҏW
#-----------------------------------------------------------
sub Edit{

# �錾
my($type,$select,%status) = @_;
my(%init) = &Init();
my($message,$return_link,$this_title,$edit_form);

	# �^�C�g����`
	$this_title = "�ݒ�ҏW";

	# ���b�Z�[�W���`
	$message = qq(�ݒ��ҏW�����B);

	# ���e��ҏW
	if($type =~ /Edit/){
		require "${main::int_dir}regist_allcheck.pl";
		$status{'handle'} = $main::in{'handle'};
		$status{'dungeon_handle'} = $main::in{'dungeon_handle'};
		($status{'handle'}) = Mebius::Regist::HandleCheck(undef,$status{'handle'});
		($status{'dungeon_handle'}) = Mebius::Regist::HandleCheck(undef,$status{'dungeon_handle'});
		main::error_view();
	}

	# �ҏW�t�H�[�����擾
	if($type =~ /Get-form/){
		$edit_form .= qq(<h2$main::kfontsize_h2>�ҏW</h2>);
		$edit_form .= qq(<form action="./" method="post"$main::sikibetu><div>\n);
		$edit_form .= qq(<input type="hidden" name="moto" value="games">\n);
		$edit_form .= qq(<input type="hidden" name="game" value="dungeon">\n);
		$edit_form .= qq(<input type="hidden" name="mode" value="go">\n);
		$edit_form .= qq(<input type="hidden" name="type" value="edit">\n);
		$edit_form .= qq(<input type="hidden" name="action_salt" value="$status{'action_salt'}">\n);
		$edit_form .= qq(���O<input type="text" name="handle" value="$status{'handle'}">\n);
		$edit_form .= qq(�_���W�����̖��O<input type="text" name="dungeon_handle" value="$status{'dungeon_handle'}">\n);
		$edit_form .= qq(<input type="submit" value="����">\n);
		$edit_form .= qq(</div></form>\n);
		return($edit_form);
	}

# ���^�[��
return($message,$this_title,%status);

}


#-----------------------------------------------------------
# �V�K�o�^
#-----------------------------------------------------------
sub Newstart{

# �錾
my($type) = @_;
my(%init) = &Init();
my(%renew,$flag,$message);

# ��{�f�B���N�g�����쐬
Mebius::Mkdir("","${main::int_dir}_dungeon",$main::dirpms);
Mebius::Mkdir("","${main::int_dir}_dungeon/_member_dungeon",$main::dirpms);

# �f�[�^�t�@�C�����X�V
($flag) = &Datafile("Me Newstart Renew");

# ���b�Z�[�W���`
$message = qq(�V�K�o�^���܂����I);

# �C���f�b�N�X��\��
&Index("Newstart",undef,$message);

exit;

}





#-----------------------------------------------------------
# �X�e�[�^�X�\������
#-----------------------------------------------------------
sub Status{

# �錾
my($type,$file) = @_;
my(%init) = &Init();
my($status_line,%status,%mystatus,$mydata_flag);

# CSS��`
#$main::css_text .= qq(
#div.status_left{float:left;}
#);

	# �f�[�^�t�@�C�����擾
	if($type =~ /Select/){
		(%status) = &Datafile("Get",$file);
		(%mystatus) = &Datafile("Me Get");
	}
	else{
		(%status) = &Datafile("Me Get");
	}

	# ������F��
	if($status{'file'} && $status{'file'} eq $mystatus{'file'}){ $mydata_flag = 1; }

	# �f�[�^�����݂��Ȃ��ꍇ
	if($status{'key'} eq ""){
		if($type =~ /Select/){ main::error("�L�����f�[�^�����݂��܂���B"); }
		else{ return(); }
	}

	# �\�������𐮌`
	if($status{'key'} eq "1"){
		$status_line .= qq(<ul>);
		#$status_line .= qq(</ul>);
		#$status_line .= qq(<ul>);
			if($type =~ /Detail/){ $status_line .= qq(<li>���O�F $status{'handle'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>�_���W�����̖��O�F $status{'dungeon_handle'}</li>); }
		$status_line .= qq(<li>���x���F $status{'level'}</li>);
		$status_line .= qq(<li>�o���F $status{'exp'} / $status{'nextexp'}</li>);
		$status_line .= qq(<li>�����F $status{'gold'} G</li>);
			if($type =~ /Detail/){ $status_line .= qq(<li>�����F $status{'monster'} / $status{'monster_max'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>�����F $status{'income'} G / 1����</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>�I�[�u�F $status{'aube'}</li>); }
			if($type =~ /Detail/){ $status_line .= qq(<li>�ő哢�����F $status{'fight_maxcount'}</li>); }
		$status_line .= qq(</ul>);
	}
	else{ $status_line = qq(�X�e�[�^�X�͂���܂���B); }

	# ���`
	if($type =~ /Detail/){
		$status_line = qq(
			$main::khrtag<h2$main::kfontsize_h2>�X�e�[�^�X - $status{'file'}</h2>
			<div class="status"$status_line</div>
			);
	}
	else{
		$status_line = qq(
			$main::khrtag<h2$main::kfontsize_h2>	<a href="./status-$status{'file'}"$init{'white_style'}$main::sikibetu>�X�e�[�^�X - $status{'file'}</a></h2>
			<div class="status">$status_line</div>
		);
	}

	# �Ǘ��҂⎩�����g�̏ꍇ�A�ҏW�t�H�[����\��
	if($type =~ /Page-view/ && ($main::myadmin_flag || $mydata_flag)){
		my($edit_form) = &Edit("Get-form",undef,%status);
		$status_line .= $edit_form;
	}

	# ���̂܂܃X�e�[�^�X�y�[�W��\������ꍇ
	if($type =~ /Page-view/){
		&Index("Only-view Navi-links Status-view","$status{'allhandle'} �̃X�e�[�^�X",$status_line);
	}

# �]�v�ȃ^�u�𐮌`
$status_line =~ s/\t//g;

# ���^�[��
return($status_line,%status);

}


#-----------------------------------------------------------
# �����̃f�[�^���J��
#-----------------------------------------------------------
sub Datafile{

# �錾
my($type,$file) = @_;
my(undef,%renew) = @_;
my(%init) = &Init();
my($statusfile,$status_handler,$nextexp);
my(%top,$allhandle);
my(%status,@renewline,$gethost,$levygold,$fight_flag,$i,$down_flag);

	# �{�b�g�͎��f�[�^���擾�ł��Ȃ�
	if($type =~ /Me/ && $main::bot_access){ return(); }

	# �o�^�ł��Ȃ���
	if($type =~ /Renew/){
			#if($main::k_access && !$main::kaccess_one){
			#	main::error("���s�ł��܂���ł����B�ő̎��ʔԍ��𑗐M�A�܂��̓I���ɂ��Ă��������B");
			#}
			if(!$main::pmfile && !$main::kaccess_one){
				my($enc_backurl_dungeon) = Mebius::Encode("",$init{'dungeon_url'});
				main::error("���s�ł��܂���ł����B���̃Q�[�����v���C����ɂ�<a href=\"${main::auth_url}?backurl=$enc_backurl_dungeon\">�A�J�E���g�Ƀ��O�C���i�܂��͓o�^�j</a>���Ă��������B");
			}
	}

	# �A�N�Z�X����
	if($type =~ /Renew/){ ($gethost) = main::axscheck(""); }

	# �����̏ꍇ�̃t�@�C����`
	if($type =~ /Me/){

		my($mobile_hash);
		my($read_device) = Mebius::my_real_device();

			# �ő̎��ʔԍ�����n�b�V�����쐬
			if($main::k_accesses){
				($mobile_hash) = Mebius::Crypt("MD5",$main::k_accesses,"4F");
				($mobile_hash) = Mebius::Crypt("MD5",$mobile_hash,"Bt");
				$mobile_hash =~ s/[^a-zA-Z0-9]//g;
				$mobile_hash = qq(_$mobile_hash);
			}

		if($mobile_hash){ $file = $mobile_hash; }
		elsif($main::pmfile){ $file = $main::pmfile; }
		else{ return(0); }
	}

	# �t�@�C����`
	$file =~ s/[^a-zA-Z0-9_-]//g;
	if($file eq ""){ return(0); }
	$statusfile = "${main::int_dir}_dungeon/_member_dungeon/${file}_member_dungeon.log";

	# ��x�͐V�K�o�^�ł��Ȃ�
	if($type =~ /Newstart/ && -e $statusfile){ main::error("�����o�^�ς݂ł��B"); }

	# �f�[�^�t�@�C�����Ȃ��ꍇ�̏���
	if(!-e $statusfile){ 
			if($type =~ /Newstart/){ Mebius::Fileout("NEWMAKE",$statusfile); }
			elsif($type =~ /Renew/){ main::error("�L�����f�[�^�����݂��܂���B"); }
			else{ return(0); }
	}


# �f�[�^�t�@�C�����J��
open($status_handler,"+<$statusfile");
flock($status_handler,2);

	# �t�@�C����W�J�A�P�s���g�b�v�f�[�^�Ƃ��Ē�`
	while(<$status_handler>){
		$i++;
		chomp;
		$top{$i} = $_;
	}

# �e��f�[�^�𕪉�
my($key,$count,$action_salt,$handle,$dungeon_handle) = split(/<>/,$top{'1'});
my($firsttime,$firsthost,$firstagent,$firstcnumber,$firstencid) = split(/<>/,$top{'2'});
my($lasttime,$lasthost,$lastagent,$lastcnumber,$lastencid) =  split(/<>/,$top{'3'});
my($hp,$maxhp,$mp,$maxmp,$sp,$maxsp,$gold,$income,$exp,$level,$aube) = split(/<>/,$top{'4'});
my($downtime,$lastlevytime) = split(/<>/,$top{'5'});

my($monster,$monster_max) = split(/<>/,$top{'6'});

my($lastfight_yearmonthday,$fight_count,$fight_maxcount) = split(/<>/,$top{'11'});

	# �_�E�����Ă���ꍇ
	if($main::time < $downtime){
		my($leftsplittime) = Mebius::SplitTime("",$downtime-$main::time);
		$down_flag = qq(�_�E�����̂��ߍs���ł��܂���B�i����$leftsplittime�j);
	}

	# ��ʍX�V�ɂ��A���s�����֎~
	if($type =~ /Action/ && $action_salt && $action_salt ne $main::in{'action_salt'}){
		close($status_handler);
		Mebius::Redirect("",$init{'dungeon_url'},301);
		main::error("��ʍX�V�ɂ��A���s���͏o���܂���B�܂��u���E�U�̖߂�@�\\���g���ƁA����ɑ��M�ł��Ȃ��ꍇ������܂��B");
	}

	# �퓬�J�E���g�̏���
	if($lastfight_yearmonthday ne "$main::thisyear-$main::thismonthf-$main::todayf"){
		$fight_count = $fight_maxcount;
	}
	
	# �����ł�����z���v�Z
	if($lastlevytime){ $levygold = int ( ( ($main::time - $lastlevytime) / (60*60) ) * $income); }
	if($levygold > $income * 24){ $levygold = $income * 24; }

	# ���S�ȃn���h���l�[��
	if($handle){ $allhandle = qq($handle - $file); }
	else{ $allhandle = qq($file); }

	# ���񃌃x���A�b�v�̌o���l���v�Z
	$nextexp = $level*10;

	# ���n�b�V���ɂ��ăf�[�^��Ԃ��ꍇ
	#if($type =~ /Get/){

		# �f�[�^���n�b�V����
		%status = (
			key=>$key , handle=>$handle , dungeon_handle => $dungeon_handle ,
			hp=>$hp , sp=>$sp , maxhp=>$maxhp, gold=>$gold , income=>$income , exp=>$exp , level=>$level , aube=>$aube ,
			downtime => $downtime , lastlevytime => $lastlevytime ,
			action_salt => $action_salt,
			monster => $monster , monster_max => $monster_max, 
			fight_count => $fight_count , fight_maxcount => $fight_maxcount , 
			file => $file, levygold => $levygold, fight_flag => $fight_flag , nextexp=>$nextexp , down_flag => $down_flag , allhandle=>$allhandle ,
		);

	#}

	# ���t�@�C���X�V���̏������݃f�[�^���`
	if($type =~ /Renew/){

		# �X�V�J�E���g�𑝂₷
		$count++;

		# ID���擾����
		my($encid) = main::id();

			# �V�K�o�^�̏ꍇ�A��{�f�[�^��ǉ�����
			if($type =~ /Newstart/){
				$key = 1;
				$firsttime = $main::time;
				$firsthost = $gethost;
				$firstagent = $main::agent;
				$firstcnumber = $main::cnumber;
				$firstencid = $encid;
			}

			# �K�{�f�[�^���Ȃ��ꍇ�A�f�[�^��������i��ɐV�K�o�^���j
			if($hp eq ""){ $hp = 20; }
			if($maxhp eq ""){ $maxhp = 20; }
			if($mp eq ""){ $mp = 20; }
			if($maxmp eq ""){ $maxmp = 20; }
			if($sp eq ""){ $sp = 20; }
			if($maxsp eq ""){ $maxsp = 20; }
			if($gold eq ""){ $gold = 200; }
			if($income eq ""){ $income = 20; }
			if($lastlevytime eq ""){ $lastlevytime = $main::time - 6*60*60; }
			if($monster eq ""){ $monster = 50; }
			if($monster_max eq ""){ $monster_max = 50; }
			if($fight_count eq ""){ $fight_count = 10; }
			if($fight_maxcount eq ""){ $fight_maxcount = 10; }

			
			# �f�[�^�ύX
			if($renew{'handle'} ne ""){ $handle = $renew{'handle'}; }
			if($renew{'dungeon_handle'} ne ""){ $dungeon_handle = $renew{'dungeon_handle'}; }
			if($renew{'hp'} ne ""){ $hp = $renew{'hp'}; }
			if($renew{'monster'} ne ""){ $monster = $renew{'monster'}; }
			if($renew{'monster_max'} ne ""){ $monster_max = $renew{'monster_max'}; }
			if($renew{'gold'} ne ""){ $gold = $renew{'gold'}; }
			if($renew{'downtime'} ne ""){ $downtime = $renew{'downtime'}; }
			if($renew{'lastlevytime'} ne ""){ $lastlevytime = $renew{'lastlevytime'}; }
			if($renew{'income'} ne ""){ $income = $renew{'income'}; }
			if($renew{'exp'} ne ""){ $exp = $renew{'exp'}; }
			if($renew{'level'} ne ""){ $level = $renew{'level'}; }
			if($renew{'aube'} ne ""){ $aube = $renew{'aube'}; }
			if($renew{'fight_count'} ne ""){ $fight_count = $renew{'fight_count'}; }
			if($renew{'fight_maxcount'} ne ""){ $fight_maxcount = $renew{'fight_maxcount'}; }
			if($renew{'lastfight_yearmonthday'} ne ""){ $lastfight_yearmonthday = $renew{'lastfight_yearmonthday'}; }

			# �ڑ��f�[�^�����L�^
			if($type =~ /Me/){
				$lasthost = $gethost;
				$lastagent = $main::agent;
				$lastcnumber = $main::cnumber;
				$lastencid = $encid;
				$lasttime = $main::time;
			}

			# �A�N�V�����\���g��ݒ�
			if($type =~ /Me/){ $action_salt = int rand(99999999); }

		# �X�V�s��ǉ����� ( ��{�f�[�^ )
		push(@renewline,"$key<>$count<>$action_salt<>$handle<>$dungeon_handle<>\n");
		push(@renewline,"$firsttime<>$firsthost<>$firstagent<>$firstcnumber<>$firstencid<>\n");
		push(@renewline,"$lasttime<>$lasthost<>$lastagent<>$lastcnumber<>$lastencid<>\n");
		push(@renewline,"$hp<>$maxhp<>$mp<>$maxmp<>$sp<>$maxsp<>$gold<>$income<>$exp<>$level<>$aube<>\n");
		push(@renewline,"$downtime<>$lastlevytime<>\n");

		# �X�V�s��ǉ����� ( �_���W�����֌W )
		push(@renewline,"$monster<>$monster_max<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");

		# �X�V�s��ǉ����� ( �퓬�֌W 
		push(@renewline,"$lastfight_yearmonthday<>$fight_count<>$fight_maxcount<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");

		# �X�V�s��ǉ����� ( �A�C�e���֌W �j 
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
		push(@renewline,"<>\n");
	}

	# �t�@�C�����X�V
	if($type =~ /Renew/){
		seek($status_handler,0,0);
		truncate($status_handler,tell($status_handler));
		print $status_handler @renewline;
	}

# �f�[�^�t�@�C�������
close($status_handler);

		# �����o�[�t�@�C�����X�V
		if($type =~ /Renew/){
			&Member("Renew",$file,%status);
		}


# �n�b�V�������^�[��
return(%status);


}


#-----------------------------------------------------------
# �����o�[�t�@�C��
#-----------------------------------------------------------
sub Member{

# �錾
my($type,$file,%status) = @_;
my($member_handler,$memberfile,$top1,@renewline,$i_member,$index_line);
my(%init) = &Init();

# �t�@�C����`
$memberfile = qq(${main::int_dir}_dungeon/member_dungeon.log);

# �t�@�C���������ꍇ�͍쐬
if($type =~ /Renew/ && !-e $memberfile){ Mebius::Fileout("NEWMAKE",$memberfile); }

	# �f�[�^�t�@�C�����J��
	open($member_handler,"+<$memberfile");

			# �t�@�C�����b�N
			if($type =~ /Renew/){ flock($member_handler,2); }

		# �g�b�v�f�[�^�𕪉�
		$top1 = <$member_handler>;
		my($tkey,$tlasttime) = split(/<>/,$top1);
		
			# �t�@�C����W�J
			while(<$member_handler>){

				# ���E���h�J�E���^
				$i_member++;

				# �ő�s���ɒB�����ꍇ
				if($i_member >= 500){ next; }

				# ���̍s�𕪉�
				chomp;
				my($key2,$file2,$lasttime2,$allhandle2,$level2) = split(/<>/,$_);

				# �������o�[���X�g�擾�p
				if($type =~ /Index/){

					# �C���f�b�N�X�s��ǉ�
					$index_line .= qq(<li><a href="./status-$file2"$init{white_style}$main::sikibetu>$allhandle2</a> (Lv.$level2)</li>);
				
				}

				# ���t�@�C���X�V�p
				if($type =~ /Renew/){

					# �����̏ꍇ�̓G�X�P�[�v
					if($file2 eq $file){ next; }

					# �ǉ�����s
					push(@renewline,"$key2<>$file2<>$lasttime2<>$allhandle2<>$level2<>\n")

				}

			}

		# �V�����ǉ�����s
		if($type =~ /Renew/){ unshift(@renewline,"1<>$file<>$main::time<>$status{'allhandle'}<>$status{'level'}<>\n") }

		# �g�b�v�f�[�^��ǉ�
		if($type =~ /Renew/){
			if($tkey eq ""){ $tkey = 1; }
			unshift(@renewline,"$tkey<>$main::time<>\n");
		}

		# ���t�@�C�����X�V
		if($type =~ /Renew/){
			seek($member_handler,0,0);
			truncate($member_handler,tell($member_handler));
			print $member_handler @renewline;
		}

	close($member_handler);

	# �C���f�b�N�X�����^�[��
	if($type =~ /Index/){
		if($type =~ /Page-view/){ &Index("Only-view Navi-links","�Q���҈ꗗ",$index_line); }
		else{ return($index_line); }
	}

# ���^�[��
return(1);

}


#-----------------------------------------------------------
# �R�����g�A�E�g
#-----------------------------------------------------------

#		<form action="./" method="post"$main::sikibetu>
#		<div>
#		<input type="hidden" name="moto" value="games">
#		<input type="hidden" name="game" value="dungeon">
#		<input type="hidden" name="mode" value="go">
#		<input type="hidden" name="action_salt" value="$status{'action_salt'}">
#		<input type="submit" value="�~�b�V�����J�n">
#		</div>
#		</form>

1;
