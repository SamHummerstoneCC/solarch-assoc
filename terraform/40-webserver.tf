resource "aws_launch_configuration" "lc" {
  image_id = "${var.ami_id}"
  instance_type = "${var.default_instance_type}"

  iam_instance_profile = "${aws_iam_instance_profile.app_instance_profile.id}"

  name = "solarch-ws-launchconfig"

  security_groups = ["${aws_security_group.sg_public_subnet.id}"]

  user_data = "${data.template_file.template-userdata-ws.rendered}"

  lifecycle {
    create_before_destroy = false
  }

}

resource "aws_autoscaling_group" "asg"{
  launch_configuration = "${aws_launch_configuration.lc.id}"

  max_size = "${var.web_asg_max}"
  min_size = "${var.web_asg_min}"

  name = "web-asg"

  health_check_grace_period = 300

  health_check_type = "ELB"

  target_group_arns = ["${aws_alb_target_group.tg.arn}"]

  vpc_zone_identifier = ["${aws_subnet.public.*.id}"]

  lifecycle {
    create_before_destroy = false
  }

  tag {
    key = "Env"
    propagate_at_launch = true
    value = "solarch"
  }

  tag {
    key = "Name"
    propagate_at_launch = true
    value = "web-asg"
  }
}
