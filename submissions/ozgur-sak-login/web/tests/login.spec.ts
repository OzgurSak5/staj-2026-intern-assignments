import { test, expect } from '@playwright/test';

test('kayıtlı kullanıcı giriş yapıp profiline ulaşabilir', async ({ page }) => {
  await page.goto('http://localhost:5173/login');

  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Şifre').fill('sifre1234');

  await page.getByRole('button', { name: 'Giriş Yap' }).click();

  await expect(page).toHaveURL('http://localhost:5173/profile');
  await expect(page.getByText('test@example.com')).toBeVisible();
});

test('token olmadan profile erişim login sayfasına yönlendirir', async ({ page }) => {
  await page.goto('http://localhost:5173/profile');

  await expect(page).toHaveURL('http://localhost:5173/login');
});

test('yeni kullanıcı kayıt olup giriş sayfasına yönlendirilir', async ({ page }) => {
  const uniqueEmail = `test${Date.now()}@example.com`;

  await page.goto('http://localhost:5173/register');

  await page.getByLabel('Email').fill(uniqueEmail);
  await page.getByLabel('Şifre').fill('sifre1234');

  await page.getByRole('button', { name: /kayıt ol/i }).click();

  await expect(page).toHaveURL('http://localhost:5173/login');
});

test('çıkış yapınca token silinir ve login sayfasına döner', async ({ page }) => {
  await page.goto('http://localhost:5173/login');

  await page.getByLabel('Email').fill('test@example.com');
  await page.getByLabel('Şifre').fill('sifre1234');
  await page.getByRole('button', { name: 'Giriş Yap' }).click();

  await expect(page).toHaveURL('http://localhost:5173/profile');

  await page.getByRole('button', { name: /çıkış yap/i }).click();

  await expect(page).toHaveURL('http://localhost:5173/login');

  const accessToken = await page.evaluate(() => localStorage.getItem('accessToken'));
  expect(accessToken).toBeNull();
});