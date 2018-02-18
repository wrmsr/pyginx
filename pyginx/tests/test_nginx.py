import unittest

import pkg_resources


class TestNginx(unittest.TestCase):

    def test_nginx(self):
        self.assertIsInstance(pkg_resources.resource_filename('pyginx', 'nginx.exe'), str)
