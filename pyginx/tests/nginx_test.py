import os
import unittest

import pkg_resources


class TestNginx(unittest.TestCase):

    def test_nginx(self):
        self.assertTrue(os.path.exists(pkg_resources.resource_filename('pyginx', 'nginx.exe')))
