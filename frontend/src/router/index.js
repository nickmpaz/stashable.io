import Vue from 'vue'
import VueRouter from 'vue-router'
import Index from '../views/Index.vue'
import SignIn from '../views/SignIn.vue'
import { Auth } from 'aws-amplify'

Vue.use(VueRouter)

const routes = [
  {
    path: '/',
    name: 'Index',
    component: Index,
    meta: { requiresAuth: true }
  },
  {
    path: '/auth',
    name: 'Auth',
    component: SignIn,
    meta: { requiresAuth: false }
  },
  {
    path: '/about',
    name: 'About',
    component: () => import('../views/About.vue'),
    meta: { requiresAuth: true }
  }
]

const router = new VueRouter({
  routes
})

router.beforeEach((to, from, next) => {
  console.log('entering router guard')
  var authenticated = false
  Auth.currentAuthenticatedUser()
    .then(() => {
      console.log('authed')
      authenticated = true
    })
    .catch(() => {
      console.log('not authed')
      authenticated = false
    })
    .finally(() => {
      if (
        to.matched.some(record => record.meta.requiresAuth) &&
        !authenticated
      ) {
        console.log(
          'not authenticated, trying to access restricted page. redirect to auth'
        )
        next('/auth')
      } else if (
        !to.matched.some(record => record.meta.requiresAuth) &&
        authenticated
      ) {
        console.log('authenticated trying to access auth. redirect to index')
        next('/')
      } else {
        console.log('good permissions. continuing')
        next()
      }
    })
})

export default router