import os
import subprocess
import time
import unittest
import urllib.request

import pkg_resources


class TestNginx(unittest.TestCase):

    TIMEOUT = 5

    def test_nginx(self):
        nginx_path = os.path.abspath(pkg_resources.resource_filename('pyginx', 'nginx.exe'))
        conf_path = os.path.abspath(pkg_resources.resource_filename('pyginx.tests', 'nginx_test.conf'))
        proc = subprocess.Popen([nginx_path, '-c', conf_path])
        self.assertIsInstance(proc.pid, int)

        start = time.time()
        while True:
            try:
                resp = urllib.request.urlopen('http://localhost:8181/nginx')
            except Exception:
                if (time.time() - start) >= self.TIMEOUT:
                    raise
            else:
                break

        self.assertEqual(resp.status, 200)
        self.assertEqual(resp.read(), b'Hi')

        proc.kill()
