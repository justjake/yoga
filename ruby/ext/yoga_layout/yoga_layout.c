#include "yoga_layout.h"

VALUE rb_mYogaLayout;

void
Init_yoga_layout(void)
{
  rb_mYogaLayout = rb_define_module("YogaLayout");
}
