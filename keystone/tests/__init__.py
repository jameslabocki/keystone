# Copyright 2013 OpenStack Foundation
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import six


if six.PY3:
    # NOTE(dstanek): This block will monkey patch libraries that are not
    # yet supported in Python3. We do this that that it is possible to
    # execute any tests at all. Without monkey patching modules the
    # tests will fail with import errors.

    import sys
    from unittest import mock  # noqa: our import detection is naive?

    # NOTE(dstanek): oslo.config is imported there so that later module
    # that use it will still have access. If we don't import it now then
    # it won't be available because of how I am patching oslo below.
    import oslo.config  # noqa: need this imported before the monkey patching
    import oslo.db  # noqa: need this imported before the monkey patching
    sys.modules['eventlet'] = mock.Mock()
    sys.modules['eventlet.green'] = mock.Mock()
    sys.modules['eventlet.wsgi'] = mock.Mock()
    sys.modules['oslo'] = mock.Mock()
    sys.modules['oslo.messaging'] = mock.Mock()
    sys.modules['pycadf'] = mock.Mock()
    sys.modules['paste'] = mock.Mock()


# NOTE(dstanek): gettextutils.enable_lazy() must be called before
# gettextutils._() is called to ensure it has the desired lazy lookup
# behavior. This includes cases, like keystone.exceptions, where
# gettextutils._() is called at import time.
from keystone.openstack.common import gettextutils as _gettextutils

_gettextutils.enable_lazy()

from keystone.tests.core import *  # noqa
